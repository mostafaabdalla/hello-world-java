resource "aws_instance" "default" {
  instance_type   = var.instance_type
  ami             = var.ami
  tags            = var.tags
  security_groups = [aws_security_group.default.name]
  key_name        = var.key_name
  user_data       = var.user_data
}

resource "aws_security_group" "default" {
  name        = var.security_group_name
  description = var.security_group_name
  vpc_id      = "vpc-01af46ea0ee710a46"
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

output "instance_public_dns_name" {
  value = aws_instance.default.public_dns
}