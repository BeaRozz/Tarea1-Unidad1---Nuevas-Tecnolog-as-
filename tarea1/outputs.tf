output "public_ip" {
  description = "Dirección IP pública de la instancia EC2"
  value       = aws_instance.bearozz_ec2.public_ip
}

output "website_url" {
  description = "URL para acceder al servidor Apache"
  value       = "http://${aws_instance.bearozz_ec2.public_ip}"
}
