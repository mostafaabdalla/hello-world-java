module "ansible-server" {
  source = "../modules/ec2"

  ami = "ami-0b5eea76982371e91"

  instance_type = "t2.micro"


  tags = {
    Name = "ansible-server"
  }
  security_group_name = "ansible-server-sg"
  key_name            = "devops_project"
  user_data           = <<EOF
  #!/bin/bash
  hostnamectl set-hostname ansible-server
  yum update -y
  amazon-linux-extras install ansible2
  useradd ansadmin
  usermod -aG wheel ansadmin
  mkdir /opt/docker
  chown ansadmin:ansadmin /opt/docker
  EOF
}

output "instance_public_dns_name" {
  value = module.ansible-server.instance_public_dns_name
}