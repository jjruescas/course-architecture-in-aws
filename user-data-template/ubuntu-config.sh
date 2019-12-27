#! /bin/bash
echo "-------------------------------"
echo "Installing Dependencies..."
sudo apt-get update -y -qq

sudo UCF_FORCE_CONFOLD=1 DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qq -y install python-apt

sudo apt-get install awscli -y -q
sudo apt-get install git -y -q

sudo apt-get install -y -qq software-properties-common
sudo add-apt-repository ppa:ansible/ansible -y

sudo apt-get update -y -qq

sudo apt-get install -y -qq ansible

echo "-------------------------------"
echo 'Installing AWS SSM Agent....'

sudo snap install amazon-ssm-agent --classic

sudo systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service

echo "-------------------------------"
echo "INSERT YOUR CUSTOM CODE BELOW"
