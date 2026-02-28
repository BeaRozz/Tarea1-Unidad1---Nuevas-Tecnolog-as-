provider "aws" {
  region = var.aws_region
}

# 1. Crear VPC
resource "aws_vpc" "bearozz_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 2. Crear Subnet Pública
resource "aws_subnet" "bearozz_public_subnet" {
  vpc_id                  = aws_vpc.bearozz_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "bearozz_igw" {
  vpc_id = aws_vpc.bearozz_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 4. Route Table y Asociación
resource "aws_route_table" "bearozz_rt" {
  vpc_id = aws_vpc.bearozz_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bearozz_igw.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

resource "aws_route_table_association" "bearozz_rta" {
  subnet_id      = aws_subnet.bearozz_public_subnet.id
  route_table_id = aws_route_table.bearozz_rt.id
}

# 5. Security Group (HTTP y SSH)
resource "aws_security_group" "bearozz_sg" {
  name        = "${var.project_name}-sg"
  description = "Permitir trafico HTTP y SSH"
  vpc_id      = aws_vpc.bearozz_vpc.id

  ingress {
    description = "HTTP de internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH de internet"
    from_port   = 22
    to_port     = 22
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
    Name = "${var.project_name}-sg"
  }
}

# 6. Instancia EC2 con Apache (user_data)
resource "aws_instance" "bearozz_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.bearozz_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bearozz_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hola, digo mu 🐮</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
