provider "aws" {
    region = "us-east-1"
  
}

resource "aws_instance" "name" {

    ami = "ami-03a6eaae9938c858c"
    instance_type = "t2.micro"
    key_name = "new1"
  
}