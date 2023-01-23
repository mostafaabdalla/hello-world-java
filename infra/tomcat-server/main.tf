module "tomcat-server" {
  source              = "../modules/ec2"
  ami                 = "ami-0b5eea76982371e91"
  instance_type       = "t2.micro"
  key_name            = "devops_project"
  security_group_name = "tomcat-server-sg"

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
output "instance_public_dns_name" {
  value = module.tomcat-server.instance_public_dns_name
}