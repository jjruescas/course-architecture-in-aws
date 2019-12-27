data "aws_ami" "windows2016" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-HyperV-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"] # amazon
}

data "template_file" "jumpbox-config-template" {
  template = "${file("${path.module}/user-data/jumpbox-config.ps1")}"

  vars = {
    INSTANCE_USERNAME = var.temp_windows_user_name
    INSTANCE_PASSWORD = var.temp_windows_user_pass
  }
}

resource "aws_instance" "jumpbox" {
  associate_public_ip_address          = true
  disable_api_termination              = false
  ami                                  = data.aws_ami.windows2016.id
  instance_type                        = var.instance_type
  user_data                            = data.template_file.jumpbox-config-template.rendered
  key_name                             = aws_key_pair.generated_key.key_name
  iam_instance_profile                 = aws_iam_instance_profile.app_instance_profile.name
  vpc_security_group_ids               = [aws_security_group.APP_SG.id]
  subnet_id                            = aws_subnet.COURSE_PUBLIC_SUBNET.id
  instance_initiated_shutdown_behavior = "stop"

  tags = merge(
    {
      "Name" = "${local.name_prefix}-JumpBox"
    },
    local.default_tags,
  )

  # Windows WinRM connection
  connection {
    type     = "winrm"
    timeout  = "180m"
    user     = var.temp_windows_user_name
    password = var.temp_windows_user_pass
  }
}