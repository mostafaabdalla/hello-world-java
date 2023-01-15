resource "aws_instance" "tomcat" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  key_name = "devops_project"

  security_groups = [aws_security_group.tomcat-sg.name]

  user_data = <<EOF
    #!/bin/bash
    yum update -y
    yum upgrade
    amazon-linux-extras install java-openjdk11 -y
    cd /opt
    wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.27/bin/apache-tomcat-10.0.27.tar.gz
    tar -xvzf /opt/apache-tomcat-10.0.27.tar.gz
    mv apache-tomcat-10.0.27 tomcat ; rm -rf apache-tomcat-10.0.27.tar.gz
    chmod +x /opt/tomcat/bin/startup.sh 
    chmod +x /opt/tomcat/bin/shutdown.sh
    ln -s /opt/tomcat/bin/startup.sh /usr/local/bin/tomcatup
    ln -s /opt/tomcat/bin/shutdown.sh /usr/local/bin/tomcatdown
    tomcatup

    EOF

  tags = {
    Name = "Tomcat_Server"
  }
}

resource "aws_security_group" "tomcat-sg" {
  name        = "Tomcat_sg"
  description = "Tomcat_sg"
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

output "tomcat_public_dns_name" {
     value = aws_instance.tomcat.public_dns
}