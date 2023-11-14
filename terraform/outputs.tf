# Output the ip address of the servers
output "web_server_ip" {
  value = aws_instance.web_server.private_ip
}

output "db_server_ip" {
  value = aws_instance.db_server.private_ip
}

output "zabbix_server_ip" {
  value = aws_instance.zabbix_server.private_ip
}

# Output the public ip address of the servers
output "js_public_ip" {
  value = "Jump server IP: ${aws_instance.jump_server.public_ip}"
}