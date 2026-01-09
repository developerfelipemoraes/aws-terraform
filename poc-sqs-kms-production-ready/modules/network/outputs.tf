output "public_subnets" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public.id]
}

output "sg_id" {
  description = "Security Group ID"
  value       = aws_security_group.this.id
}
