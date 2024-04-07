variable "aws_region" {
  default = "us-east-2"
  type    = string
}

variable "ami_id" {
  default = "ami-0b4750268a88e78e0"
  type    = string
}

variable "instance_type" {
  default = "t2.medium"
  type    = string
}

variable "key_name" {
  default = "devtf-key"
  type    = string
}

variable "bucket" {
  default = ""
  type    = string
}

variable "acl" {
  default = "private"
  type    = string
}
