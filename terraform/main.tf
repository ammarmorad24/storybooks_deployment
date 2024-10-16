

# Security Group definition allowing inbound traffic on port 8080, 3000, and 22
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Security group to allow SSH, HTTP (8080), and custom port (3000)"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow custom port 3000"
    from_port   = 3000
    to_port     = 3000
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

# Create two EC2 instances
resource "aws_instance" "ec2_instance" {
  count = 2

  ami           = "ami-0e04bcbe83a83792e" # Replace with the latest AMI for your region
  instance_type = "t2.micro"  # Adjust instance type based on your needs

  key_name = "storybooks_deployment"  # Replace with your key pair name

  # Associate the instance with the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  # User data (optional)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              EOF

  tags = {
    Name = "Terraform-EC2-${count.index + 1}"
  }
}

# Outputs for the EC2 instances
output "instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = [aws_instance.ec2_instance[*].public_ip]
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instances"
  value       = [aws_instance.ec2_instance[*].public_dns]
}
