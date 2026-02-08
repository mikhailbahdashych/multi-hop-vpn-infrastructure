output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.node.public_ip
}

output "id" {
  description = "EC2 instance ID"
  value       = aws_instance.node.id
}
