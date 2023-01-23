module "docker-host" {
  source              = "../modules/ec2"
  ami                 = "ami-0b5eea76982371e91"
  instance_type       = "t2.micro"
  security_group_name = "docker-host-sg"
  key_name            = "devops_project"
  user_data           = <<EOF
  #!/bin/bash
  yum update -y
  yum install docker -y
  service docker start
  useradd dockeradmin
  useradd ansadmin
  usermod -aG docker dockeradmin
  mkdir /opt/docker
  chown dockeradmin:dockeradmin /opt/docker
  EOF
  tags = {
    Name = "docker-host"
  }

}

output "instance_public_dns_name" {
  value = module.docker-host.instance_public_dns_name
}