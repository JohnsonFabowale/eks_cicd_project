resource "aws_eip" "nat-eip" {
  #vpc = true
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-us-east-2b.id
  tags = {
    Name = "nat-gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}