terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.39.0"
    }
  }
}

provider "aws" {
  # Configuration options
    region = "us-east-2"

}

resource "aws_instance" "build-vm" {
  ami           = "ami-00399ec92321828f5" # us-east-2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = [aws_security_group.my_sec_group]

  network_interface {
    network_interface_id = aws_network_interface.my_net_int.id
    device_index         = 0
  }

  tags = {
    Name = "build-vm"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "192.168.10.0/24"

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "192.168.10.0/24"
  availability_zone = "us-east-2"

  tags = {
    Name = "tf-subnet"
  }
}

resource "aws_network_interface" "my_net_int" {
  subnet_id   = aws_subnet.my_subnet.id


  tags = {
    Name = "tf-network_interface"
  }
}

resource "aws_security_group" "my_sec_group" {
  name        = "my_sec_group"

  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "for tomcat"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.my_vpc.cidr_block]
    
  }
  ingress {
    description      = "for ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.my_vpc.cidr_block]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tf-security_group"
  }
}


output "public_ip_vm_1" {
  value = aws_instance.build-vm.public_ip
}

output "public_ip_vm_2" {
  value = aws_instance.build-vm.public_ip
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

