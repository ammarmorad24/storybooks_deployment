

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

  // allow https port
  ingress {
    description = "Allow HTTPS on port 443"
    from_port   = 50000
    to_port     = 50000
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

  // allow mongodb port and sonarqube port
  ingress {
    description = "Allow MongoDB port 27017"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SonarQube port 9000"
    from_port   = 9000
    to_port     = 9000
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
# Create one EC2 instance
resource "aws_instance" "jenkins_instance" {
  ami           = "ami-08ec94f928cf25a9d"
  instance_type = "t2.medium"

  key_name = "storybooks_deployment" # Replace with your key pair name

  # Associate the instance with the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  # User data (optional)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              EOF

  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "docker_instance" {
  ami           = "ami-08ec94f928cf25a9d"
  instance_type = "t2.medium"

  key_name = "storybooks_deployment" # Replace with your key pair name

  # Associate the instance with the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  # User data (optional)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              EOF

  tags = {
    Name = "docker"
  }
}

resource "aws_instance" "storybooks_instance" {
  ami           = "ami-08ec94f928cf25a9d"
  instance_type = "t2.medium"

  key_name = "storybooks_deployment" # Replace with your key pair name

  # Associate the instance with the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  # User data (optional)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              EOF

  tags = {
    Name = "storybooks"
  }
}

resource "aws_instance" "sonarqube_instance" {
  ami           = "ami-08ec94f928cf25a9d"
  instance_type = "t2.medium"

  key_name = "storybooks_deployment" # Replace with your key pair name

  # Associate the instance with the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  # User data (optional)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              EOF

  tags = {
    Name = "sonarqube"
  }
}

# Outputs for the EC2 instance
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.ec2_instance.public_dns
}
