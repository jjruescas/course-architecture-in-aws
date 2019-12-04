resource "aws_instance" "ubuntu" {
  # "count" creates the number of resources specified.
  count = 1
  
  vpc_security_group_ids = [aws_security_group.allow-http-rdp-winrm.id]
  
  subnet_id = aws_subnet.main-public.id

  ami = var.UBUNTU_BASE_AMI_ID

  instance_type = var.INSTANCE_TYPE
  
  tags = {
    Name = "ubuntu-from-custom-ami"
  }
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = [var.UBUNTU_AMI_SEARCH_EXPRESSION]
  }
}



