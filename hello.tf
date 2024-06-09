# Provider configuration
provider "aws" {
  region  = "us-west-2"
  profile = "default"  # Ensure AWS CLI is configured with this profile
}

# Define a VPC
resource "aws_vpc" "example_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "example-vpc"
  }
}

# Define a Subnet
resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "example-subnet"
  }
}

# Define an Internet Gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "example-igw"
  }
}

# Define a Route Table
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
  tags = {
    Name = "example-route-table"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "example_route_table_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

# Define a Security Group
resource "aws_security_group" "example_sg" {
  vpc_id = aws_vpc.example_vpc.id
  description = "Allow SSH and HTTP"

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

  tags = {
    Name = "example-sg"
  }
}

# Define an EC2 Instance
resource "aws_instance" "example_instance" {
  ami             = "ami-0abcdef1234567890" # Replace with a valid AMI ID
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.example_subnet.id
  security_groups = [aws_security_group.example_sg.name]
  key_name        = "my-key-pair"  # Ensure you have this key pair created in AWS

  tags = {
    Name = "example-instance"
  }
}

# Output the Instance's Public IP
output "instance_public_ip" {
  value = aws_instance.example_instance.public_ip
}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.example_vpc.id
}

# Output the Subnet ID
output "subnet_id" {
  value = aws_subnet.example_subnet.id
}
