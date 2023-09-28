provider "aws" {
  region = "us-east-1"

}

resource "aws_instance" "ec2_1" {
  ami =         "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = "new1"
  //security_groups = ["my-sg"]
  vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
  subnet_id = aws_subnet.dpp-public_subent_01.id
  for_each = toset(["Jenkins-master", "build-slave","ansible"])
   tags = {
     Name = "${each.key}"
   }
  }


resource "aws_security_group" "demo-sg" {
  name        = "my-sg"
  description = "mysg for EC2"
  vpc_id = aws_vpc.dpp-vpc.id
  
  ingress {
    description      = "ssh port"
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
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh for EC2"
  }
}


resource "aws_vpc" "dpp-vpc" {
       cidr_block = "10.1.0.0/16"
       tags = {
        Name = "dpp-vpc"
     }
}

//Create a Subnet 
resource "aws_subnet" "dpp-public_subent_01" {
    vpc_id = aws_vpc.dpp-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "dpp-public_subent_01"
    }
}

//Creating an Internet Gateway 
resource "aws_internet_gateway" "dpp-igw" {
    vpc_id = aws_vpc.dpp-vpc.id
    tags = {
      Name = "dpp-igw"
    }
}



// Create a route table 
resource "aws_route_table" "dpp-public-rt" {
    vpc_id = aws_vpc.dpp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpp-igw.id
    }
    tags = {
      Name = "dpp-public-rt"
    }
}

// Associate subnet with route table

resource "aws_route_table_association" "dpp-rta-public-subent-1" {
    subnet_id = aws_subnet.dpp-public_subent_01.id
    route_table_id = aws_route_table.dpp-public-rt.id
}