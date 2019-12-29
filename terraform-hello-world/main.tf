provider "aws" {
  region = "us-west-2"
}

// # 1st part
// resource "aws_instance" "linux2" {
//   ami           = "ami-0c5204531f799e0c6"
//   instance_type = "t2.micro"
  
//   tags = {
//       Name = "HelloWorld"
//     }
// }

# 2nd part
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami = "ami-0c5204531f799e0c6"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  #test
  key_name = "APP-KEY"

  user_data = <<-EOF
              #!/bin/bash
              sudo amazon-linux-extras install nginx1.12 -y
              sudo service nginx start
              EOF

  tags = {
    Name = "HelloWorld"
  }
}
