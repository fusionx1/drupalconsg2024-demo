output "id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  # Result is a map of subnet id to cidr block
  # ex: {"subnet_1234" => "10.0.1.0/4", ...}
  value = {
    for subnet in aws_subnet.public :
    subnet.id => subnet.cidr_block
  }
}