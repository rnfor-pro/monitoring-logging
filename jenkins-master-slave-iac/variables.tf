variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0cd59ecaf368e5ccf"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "devtf-key"
}

variable "slave_ami_id" {
  default = "ami-0cd59ecaf368e5ccf"
} 

variable "slave_instance_type" {
  default = "t2.micro"
}

variable "slave_key_name" {
  default = "devtf-key"
}

variable "bucket" {
  default = "jenkins-s3-bucket-etechapp"
}

variable "acl" {
  default = "private"
}
