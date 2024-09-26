# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnets (two public subnets)
resource "aws_subnet" "subnet" {
  count           = 2
  vpc_id          = aws_vpc.main_vpc.id
  cidr_block      = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index)
  availability_zone = element(["eu-central-1a", "eu-central-1b"], count.index)
  map_public_ip_on_launch = true   # Ensure public IP is assigned
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Create Route Table and Route
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  subnet_id      = element(aws_subnet.subnet[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# Security Group allowing SSH and all outbound traffic
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Allow SSH from any IP (open for demo)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances (two instances with public IPs)
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0e04bcbe83a83792e" # Ubuntu AMI
  instance_type = "t2.micro"
  key_name      = "storybooks_deployment"
  subnet_id     = element(aws_subnet.subnet[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  
  associate_public_ip_address = true   # Assign a public IP

  tags = {
    Name = "web-instance-${count.index + 1}"
  }
}
