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
  availability_zone = "us-east-1a"

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

resource "tls_private_key" "terrafrom_generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  # Name of key : Write the custom name of your key
  key_name = "netflixkp"
  # Public Key: The public will be generated using the reference of tls_private_key.terrafrom_generated_private_key
  public_key = tls_private_key.terrafrom_generated_private_key.public_key_openssh
  # Store private key :  Generate and save private key(aws_keys_pairs.pem) in current directory
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > netflixkp.pem
      chmod 400 netflixkp.pem
    EOT
  }
}

output "aws_key_pair" {
  value = aws_key_pair.generated_key.key_name
}



resource "aws_instance" "netflix_server" {
  ami                         = "ami-0cd59ecaf368e5ccf"
  key_name                    = "netflixkp"
  instance_type               = "t2.large"
  vpc_security_group_ids      = [aws_security_group.netflix_sg.id]
  subnet_id                   = aws_subnet.netflix-subnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.admin_instance_profile.name
  user_data                   = file("jenkins-install.sh")

  root_block_device {
    volume_type = "gp3"
    volume_size = 35
  }


  tags = {
    "Name" = "Netflix Server"
  }
}

resource "aws_eip" "netflix_elastic_ip" {
  vpc      = true
  instance = aws_instance.netflix_server.id
}

######################SG####################################

resource "aws_security_group" "netflix_sg" {
  name   = "netflix_sg"
  vpc_id = aws_vpc.netflix.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "netflix_sg"
  }
}
resource "aws_route_table" "route-netflix-env" {
  vpc_id = aws_vpc.netflix.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.netflix-gw.id
  }
  tags = {
    Name = "netflix-env-route-table"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.netflix-subnet.id
  route_table_id = aws_route_table.route-netflix-env.id
}

resource "aws_instance" "monitoring_server" {
  ami                         = "ami-0cd59ecaf368e5ccf"
  key_name                    = "netflixkp"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.netflix_sg.id]
  subnet_id                   = aws_subnet.netflix-subnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.admin_instance_profile.name
  user_data                   = file("monitoring.sh")

  root_block_device {
    volume_type = "gp3"
    volume_size = 35
  }

  tags = {
    "Name" = "Monitoring Server"
  }
}

resource "aws_eip" "monitoring_elastic_ip" {
  vpc = true
  instance = aws_instance.monitoring_server.id
}

