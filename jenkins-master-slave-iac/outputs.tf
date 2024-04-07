output "jenkins_master_public_dns" {
  description = "Output the Jenkins server public DNS"
  value       = aws_instance.jenkins_ec2.public_dns
}

output "jenkins_slave_1_public_dns" {
  description = "Output the Jenkins Slave 1 public DNS"
  value       = aws_instance.jenkins_slave[0].public_dns
}

output "jenkins_slave_2_public_dns" {
  description = "Output the Jenkins Slave 2 public DNS"
  value       = aws_instance.jenkins_slave[1].public_dns
}

