resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Project_1_VPC"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "Public Subnets Route Table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "Example Security Group"
  vpc_id      = aws_vpc.example_vpc.id
}

resource "aws_instance" "example" {
  count           = 3
  ami             = "ami-0bb4c991fa89d4b9b"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.example.id]

  tags = {
    Name = "Test_Instances"
  }
}
