provider aws {
     # profile="default"
     region = "cn-northwest-1" 
}

# declare a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "caoliang1_VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "cn-northwest-1a"

  tags = {
    Name = "caoliang1_Public Subnet"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "caoliang1_My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_vpc_cn_northwest_1a_public" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
        Name = "caoliang1_Public Subnet Route Table"
    }
}

resource "aws_route_table_association" "my_vpc_cn_northwest_1a_public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.my_vpc_cn_northwest_1a_public.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "caoliang1_allow_ssh_sg"
  }
}

# ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211001 
resource "aws_instance" "my_instance" {
  ami           = "ami-01fac9af96c6500a9"
  instance_type = "t2.micro"
  key_name = "liang_RSA"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true

  tags = {
    Name = "caoliang1_My Instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
