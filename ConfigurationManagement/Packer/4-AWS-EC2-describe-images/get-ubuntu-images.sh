#!/usr/bin/env bash

# Note: Before invoking this script, you need to grant it permissions, like this:
#   chmod +x get-ubuntu-images.sh 
# 
# AWS Documentation: https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html

aws ec2 describe-images \
--owners 099720109477 \
--filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-2019*" \
--query 'sort_by(Images, &CreationDate)[].{Name:Name,ID:ImageId}'