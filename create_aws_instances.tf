terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.39.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

//ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/sertKey.pem
//ssh-keygen -y -f ~/.ssh/sertKey.pem >> sertKey.pub

resource "tls_private_key" "my_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" {
    command = "echo '${tls_private_key.my_private_key.private_key_pem}' > ./keys/sertKey.pem"
  }
}

resource "aws_key_pair" "my_generated_key" {
  key_name   = "sertKey"
  public_key = "${tls_private_key.my_private_key.public_key_openssh}"
}

provider "aws" {
  # Configuration options
    region = "us-east-2"
}

data "aws_vpc" "my_vpc" {
  default = true
}

data "aws_subnet_ids" "my_subnet_ids" {
  vpc_id = data.aws_vpc.my_vpc.id
}

resource "aws_security_group" "my_sec_group" {
  name        = "my_sec_group"

  vpc_id      = data.aws_vpc.my_vpc.id

  ingress {
    description      = "for tomcat"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "for ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-security_group"
  }
}

resource "aws_instance" "build-vm" {
  ami           = "ami-00399ec92321828f5" # us-east-2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "${aws_key_pair.my_generated_key.key_name}"
  subnet_id = tolist(data.aws_subnet_ids.my_subnet_ids.ids)[0]
  vpc_security_group_ids = [aws_security_group.my_sec_group.id]
  
  tags = {
    Name = "build-vm"
  }

  depends_on = {
    aws_key_pair.my_generated_key,
  }
}

resource "aws_instance" "deploy-vm" {
  ami           = "ami-00399ec92321828f5" # us-east-2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "${aws_key_pair.my_generated_key.key_name}"
  subnet_id = tolist(data.aws_subnet_ids.my_subnet_ids.ids)[0]
  vpc_security_group_ids = [aws_security_group.my_sec_group.id]
 
  tags = {
    Name = "deploy-vm"
  }

  depends_on = {
    aws_key_pair.my_generated_key,
  }
}

output "public_ip_build" {
  value = aws_instance.build-vm.public_ip
}

output "public_ip_deploy" {
  value = aws_instance.deploy-vm.public_ip
}

/*
resource "null_resource" "ansible" {

  provisioner "local-exec" {
    command = <<EOT
     yc iam key create --service-account-name vmmanager -o key.json    
     ansible-playbook ya_roles.yml \
              --extra-vars \
                  "vm1_public_ip=${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address} \
                   vm2_public_ip=${yandex_compute_instance.vm-2.network_interface.0.nat_ip_address} \
                  reg_id=${yandex_container_registry.my-registry.id}"
    EOT
  }
}
*/

