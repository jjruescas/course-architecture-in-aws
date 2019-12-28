data "template_file" "windows-config-template" {
  template = "${file("${path.module}/user-data/iis-config.ps1")}"

  vars = {
    INSTANCE_USERNAME = var.temp_windows_user_name
    INSTANCE_PASSWORD = var.temp_windows_user_pass
  }
}

resource "aws_instance" "windows_web_server" {
  associate_public_ip_address          = false
  disable_api_termination              = false
  ami                                  = data.aws_ami.windows2016.id
  instance_type                        = var.instance_type
  user_data                            = data.template_file.windows-config-template.rendered
  key_name                             = aws_key_pair.generated_key.key_name
  iam_instance_profile                 = aws_iam_instance_profile.app_instance_profile.name
  vpc_security_group_ids               = [aws_security_group.APP_SG.id]
  subnet_id                            = aws_subnet.COURSE_PRIVATE_SUBNET.id
  instance_initiated_shutdown_behavior = "stop"


  tags = merge(
    {
      "Name" = "${local.name_prefix}-IIS-Server"
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

data "template_file" "ubuntu-config-template" {
  template = "${file("${path.module}/user-data/nginx-config.sh")}"
}

resource "aws_instance" "ubuntu_web_server" {
  associate_public_ip_address          = false
  disable_api_termination              = false
  ami                                  = data.aws_ami.ubuntu.id
  instance_type                        = var.instance_type
  user_data                            = data.template_file.ubuntu-config-template.rendered
  key_name                             = aws_key_pair.generated_key.key_name
  iam_instance_profile                 = aws_iam_instance_profile.app_instance_profile.name
  vpc_security_group_ids               = [aws_security_group.APP_SG.id]
  subnet_id                            = aws_subnet.COURSE_PRIVATE_SUBNET.id
  instance_initiated_shutdown_behavior = "stop"


  tags = merge(
    {
      "Name" = "${local.name_prefix}-Nginx-Server"
    },
    local.default_tags,
  )
}

resource "aws_s3_bucket" "backups_bucket"{
	bucket = "infra-course-backups007"
  acl    = "private"
}