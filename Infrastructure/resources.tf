resource "aws_vpc" "netflix" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "NetflixClone"
  }
}
resource "aws_subnet" "netflix-subnet" {
  vpc_id            = aws_vpc.netflix.id
  cidr_block        = "172.31.0.0/16"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "netflix"
  }
}
resource "aws_internet_gateway" "netflix-gw" {
  vpc_id = aws_vpc.netflix.id
  tags = {
    Name = "netflix-env-gw"
  }
}

resource "aws_iam_role" "admin_role" {
  name = "NetflixAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

# Attach the AdministratorAccess policy to the IAM role
resource "aws_iam_role_policy_attachment" "admin_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.admin_role.name
}

resource "aws_iam_instance_profile" "admin_instance_profile" {
  name = "AdministratorAccessInstanceProfile"
  role = aws_iam_role.admin_role.name
}


resource "aws_instance" "netflix_server" {
  ami                         = "ami-0e5f882be1900e43b"
  key_name                    = "netflixkp"
  instance_type               = "t2.large"
  vpc_security_group_ids      = [aws_security_group.netflix_sg.id]
  subnet_id                   = aws_subnet.netflix-subnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.admin_instance_profile.name
  user_data                   = file("netflix.sh")

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }


  tags = {
    "Name" = "Netflix Server"
  }
}

resource "aws_eip" "netflix_elastic_ip" {
  vpc = true
  instance = aws_instance.netflix_server.id
}

resource "aws_instance" "monitoring_server" {
  ami                         = "ami-0e5f882be1900e43b"
  key_name                    = "netflixkp"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.netflix_sg.id]
  subnet_id                   = aws_subnet.netflix-subnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.admin_instance_profile.name
  user_data                   = file("monitoring.sh")

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }

  tags = {
    "Name" = "Monitoring Server"
  }
}

resource "aws_eip" "monitoring_elastic_ip" {
  vpc = true
  instance = aws_instance.monitoring_server.id
}




