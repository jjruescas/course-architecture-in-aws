provider "aws" {
  region = var.aws_region
}

# terraform {
#   backend "s3" {
#     bucket = "COURSE-TFSTATES"
#     key    = "infra-cm-instructors/terraform.tfstate"
#     region = "${var.aws_region}"
#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

