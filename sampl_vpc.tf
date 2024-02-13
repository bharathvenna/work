provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create two availability zones
data "aws_availability_zones" "available" {}

# Create a public subnet in the first availability zone
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

# Create a private subnet in the second availability zone
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

# Create a security group for allowing SSH and HTTP traffic
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a public EC2 instance in the public subnet
resource "aws_instance" "public_instance" {
  ami           = "your_ami_id"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "your_key_pair_name"
  security_groups = [aws_security_group.instance_sg.name]
}

# Create a private EC2 instance in the private subnet
resource "aws_instance" "private_instance" {
  ami           = "your_ami_id"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = "your_key_pair_name"
  security_groups = [aws_security_group.instance_sg.name]
}

# Output availability zones
output "availability_zones" {
  value = data.aws_availability_zones.available.names
}
