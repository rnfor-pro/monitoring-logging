output "ssh_command" {
  value = replace("ssh -i \"netflixkp.pem\" ubuntu@${aws_instance.netflix_server.public_dns}", "\\", "")
}

output "ssh_command2" {
  value = replace("ssh -i \"netflixkp.pem\" ubuntu@${aws_instance.monitoring_server.public_dns}", "\\", "")
}

output "netflix_ip" {
  value = aws_eip.netflix_elastic_ip.public_ip
}

output "monitoring_ip" {
  value = aws_eip.monitoring_elastic_ip.public_ip
}
