resource "aws_instance" "default" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  key_name = "devops_project"

  security_groups = [aws_security_group.default.name]

  user_data = <<EOF
    #!/bin/bash
    sudo yum update -y
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum upgrade
    sudo amazon-linux-extras install java-openjdk11 -y
    sudo yum install jenkins -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    # install git
    sudo yum install git -y
    # install maven
    sudo wget -O /opt/apache-maven-3.8.7-bin.tar.gz https://dlcdn.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz
    sudo tar -xvf /opt/apache-maven-3.8.7-bin.tar.gz ; sudo rm -rf /opt/apache-maven-3.8.7-bin.tar.gz
    sudo mv apache-maven-3.8.7-bin maven
    sudo echo "export M2_HOME=/opt/maven M2=/opt/maven/bin JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.16.0.8-1.amzn2.0.1.x86_64" >> ~/.bash_profile
    sudo source ~/.bash_profile
    
    EOF

  tags = {
    Name = "Jenkins_Server"
  }
}

resource "aws_security_group" "default" {
  name        = "Jenkins_sg"
  description = "Jenkins_sg"
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

output "public_dns_name" {
     value = aws_instance.default.public_dns
}