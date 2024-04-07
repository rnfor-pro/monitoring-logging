variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0c101f26f147fa7fd"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "devtf-key"
}

variable "slave_ami_id" {
  default = "ami-0c101f26f147fa7fd"
}

variable "slave_instance_type" {
  default = "t2.medium"
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
