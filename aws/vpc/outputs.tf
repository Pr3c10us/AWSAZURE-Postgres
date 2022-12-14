output "vpc_id" {
  value       = aws_vpc.main.id
  description = "the id of the vpc"
}

output "private_subnet_id" {
  value       = aws_subnet.private[0].id
  description = "the id of public subnet"
}

output "public_subnet_id" {
  value       = aws_subnet.public[0].id
  description = "the id of public subnet"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "the cidr block of the vpc"
}

output "private_route_table_id" {
  value = aws_route_table.private.id
  description = "the private route table of the vpc"
}

output "public_route_table_id" {
  value = aws_route_table.public.id
  description = "the public route table of the vpc"
}
