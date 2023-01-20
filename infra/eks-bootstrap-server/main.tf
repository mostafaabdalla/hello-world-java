resource "aws_security_group" "eks-bootstrap-sg" {
  name        = "eks_bootstrap_sg"
  description = "eks_bootstrap_sg"
  vpc_id      = "vpc-0c0c7be4f059ab962"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
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
    Name = "allow_tls"
  }
}

resource "aws_iam_role" "eksctl-role" {
  name = "eksctl_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eksctl-attach" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ])
  role       = aws_iam_role.eksctl-role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "eksctl_profile" {
  name = "eksctl_profile"
  role = aws_iam_role.eksctl-role.name
}

resource "aws_instance" "eks-bootstrap" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  key_name = "devops_project"

  security_groups = [aws_security_group.eks-bootstrap-sg.name]

  iam_instance_profile = aws_iam_instance_profile.eksctl_profile.name

  user_data = <<EOF
    #!/bin/bash
    yum update -y
    ####################
    # update AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    ###################
    #install kubectl
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.7/2022-10-31/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
    echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
    ####################
    # install eksctl
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    ####################
    
    EOF

  tags = {
    Name = "eks_bootstrap_server"
  }
}

output "eks-bootstrap_public_dns_name" {
  value = aws_instance.eks-bootstrap.public_dns
}