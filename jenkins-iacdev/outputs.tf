output "public_dns" {
  description = "output the jenkins server public ip"
  value = aws_instance.jenkins-ec2.public_dns
}