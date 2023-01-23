module "jenkins-server" {
  source              = "../modules/ec2"
  ami                 = "ami-0b5eea76982371e91"
  instance_type       = "t2.micro"
  key_name            = "devops_project"
  security_group_name = "jenkins-server-sg"
  user_data           = <<EOF
    #!/bin/bash
    yum update -y
    wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum upgrade
    amazon-linux-extras install java-openjdk11 -y
    yum install jenkins -y
    systemctl enable jenkins
    systemctl start jenkins
    ###########################
    # install git
    sudo yum install git -y
    ###########################
    # install maven
    cd /opt/
    wget https://dlcdn.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz
    tar -xvzf /opt/apache-maven-3.8.7-bin.tar.gz
    mv apache-maven-3.8.7 maven ; rm -rf apache-maven-3.8.7-bin.tar.gz
    sed -i '$ d' ~/.bash_profile
    echo "M2_HOME=/opt/maven
M2=/opt/maven/bin
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.16.0.8-1.amzn2.0.1.x86_64" >> ~/.bash_profile
    echo "PATH=$PATH:$HOME/bin:/opt/maven:/opt/maven/bin:/usr/lib/jvm/java-11-openjdk-11.0.16.0.8-1.amzn2.0.1.x86_64" >> ~/.bash_profile
    echo "export PATH" >> ~/.bash_profile
    sudo source ~/.bash_profile
    EOF
  tags = {
    Name = "Jenkins_Server"
  }
}

output "instance_public_dns_name" {
  value = module.jenkins-server.instance_public_dns_name
}