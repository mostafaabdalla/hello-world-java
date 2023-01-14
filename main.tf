resource "aws_instance" "jenkins" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  key_name = "devops_project"

  security_groups = [aws_security_group.jenkins-sg.name]

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
    ###########################
    # install git
    sudo yum install git -y
    ###########################
    # install maven
    cd /opt/
    sudo wget https://dlcdn.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz
    sudo tar -xvzf /opt/apache-maven-3.8.7-bin.tar.gz
    sudo mv apache-maven-3.8.7 maven ; sudo rm -rf apache-maven-3.8.7-bin.tar.gz

    sudo echo "M2_HOME=/opt/maven M2=/opt/maven/bin JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.16.0.8-1.amzn2.0.1.x86_64" >> ~/.bash_profile
    sudo echo "PATH=$PATH:$M2:$M2_HOME:$JAVA_HOME" >> ~/.bash_profile
    sudo echo "export PATH" >> ~/.bash_profile

    sudo source ~/.bash_profile
    
    EOF

  tags = {
    Name = "Jenkins_Server"
  }
}

resource "aws_security_group" "jenkins-sg" {
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
output "jenkins_public_dns_name" {
     value = aws_instance.jenkins.public_dns
}
output "tomcat_public_dns_name" {
     value = aws_instance.tomcat.public_dns
}