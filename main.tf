provider "aws" {
  region = var.region
}

# 1. GENERATE A PRIVATE KEY LOCALLY
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. CREATE THE KEY PAIR IN AWS
resource "aws_key_pair" "deployer_key" {
  key_name   = "assignment-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# 3. SAVE THE KEY TO YOUR LOCAL DIRECTORY (.pem file)
resource "local_file" "tf_key" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = "assignment-key.pem"
}

# 4. SECURITY GROUP
resource "aws_security_group" "app_sg" {
  name        = "flask-express-sg"
  description = "Allow SSH, Flask, and Express traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Flask
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Express
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. EC2 INSTANCE
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.deployer_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Log output to check for errors later
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "Starting Setup..."
              dnf update -y
              dnf install -y python3-pip nodejs npm git

              # RHEL Firewall: Open ports 3000 and 5000
              firewall-cmd --permanent --add-port=5000/tcp
              firewall-cmd --permanent --add-port=3000/tcp
              firewall-cmd --reload

              # Create apps in /opt to avoid home directory permission issues
              mkdir -p /opt/backend /opt/frontend

              # Setup Flask
              cat <<EOT > /opt/backend/app.py
              from flask import Flask
              app = Flask(__name__)
              @app.route('/')
              def hello(): return "Backend Running on RHEL"
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              EOT
              pip3 install flask
              nohup python3 /opt/backend/app.py > /var/log/flask.log 2>&1 &

              # Setup Express
              cd /opt/frontend
              npm init -y
              npm install express
              cat <<EOT > index.js
              const express = require('express');
              const app = express();
              app.get('/', (req, res) => res.send('Frontend Running on RHEL'));
              app.listen(3000, '0.0.0.0');
              EOT
              nohup node index.js > /var/log/express.log 2>&1 &
              
              echo "Setup Complete!"
              EOF

  tags = {
    Name = "Flask-Express-Single-EC2"
  }
}

# 6. OUTPUT THE PUBLIC IP
output "public_ip" {
  value = aws_instance.web_server.public_ip
}