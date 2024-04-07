variable "aws_region" {
  default = "us-east-2"
}

variable "ami_id" {
  default = "ami-0b4750268a88e78e0"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "devtf-key"
}

variable "slave_ami_id" {
  default = "ami-0b4750268a88e78e0"
} 

variable "slave_instance_type" {
  default = "t2.micro"
}

variable "slave_key_name" {
  default = "devtf-key"
}

variable "bucket" {
  default = ""
}

variable "acl" {
  default = "private"
}
