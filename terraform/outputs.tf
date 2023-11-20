# Output the public ip address of the servers
output "js_public_ip" {
  value = "Jump server IP: ${aws_instance.jump_server.public_ip}"
}

output "web_server_public_ip" {
  value = "Web server IP: ${aws_instance.web_server.public_ip}"
}

output "template_rendered_db" {
  value = data.template_file.db_server.rendered
}

output "template_rendered_web" {
  value = data.template_file.web_server.rendered
}

output "template_rendered_js" {
  value = data.template_file.user_data.rendered
}