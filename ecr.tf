resource "aws_ecr_repository" "flask_backend" {
  name                 = "flask-backend"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "express_frontend" {
  name                 = "express-frontend"
  image_tag_mutability = "MUTABLE"
}

output "flask_ecr_url" {
  value = aws_ecr_repository.flask_backend.repository_url
}

output "express_ecr_url" {
  value = aws_ecr_repository.express_frontend.repository_url
}