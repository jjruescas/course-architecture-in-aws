locals {
  name_prefix = var.env

  default_tags = {
    Environment = var.env
    Product     = var.product
  }

  asg_default_tags = [
    {
      key                 = "Name"
      value               = "APP-ASG"
      propagate_at_launch = "true"
    },
    {
      key                 = "Environment"
      value               = var.env
      propagate_at_launch = "true"
    },
  ]
}

