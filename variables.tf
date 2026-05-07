variable "region" {
  default = "eu-north-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  description = "Provided by Red Hat, Inc."
  default     = "ami-076d128fb049922d4"
}