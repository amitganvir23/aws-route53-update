#!/usr/bin/env bash

echo "Running server.sh"

region=$1
adminUsername=$2
adminPassword=$3
services=$4
stackName=$5

apt-get -y update
apt-get -y install jq

apt-get install -y awscli ansible

curl -O https://bootstrap.pypa.io/get-pip.py
export PATH=~/.local/bin:$PATH
python get-pip.py --user
pip install awscli --upgrade --user
pip install boto

pip install ansible --upgrade

if [ -z "$6" ]
then
  echo "This node is part of the autoscaling group that contains the rally point."
  rallyPrivateDNS=`getrallyPrivateDNS`
else
  rallyAutoScalingGroup=$6
  echo "This node is not the rally point and not part of the autoscaling group that contains the rally point."
  echo rallyAutoScalingGroup \'$rallyAutoScalingGroup\'
  rallyPrivateDNS=`getrallyPrivateDNS ${rallyAutoScalingGroup}`
fi

## Getting Instance ID
instanceID=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document \
  | jq '.instanceId' \
  | sed 's/^"\(.*\)"$/\1/' )

nodePrivateDNS=`curl http://169.254.169.254/latest/meta-data/hostname`

## Infor
echo "Using the settings:"
echo adminUsername \'$adminUsername\'
echo adminPassword \'$adminPassword\'
echo services \'$services\'
echo stackName \'$stackName\'
echo rallyPrivateDNS \'$rallyPrivateDNS\'
echo region \'$region\'
echo instanceID \'$instanceID\'
echo nodePrivateDNS \'$nodePrivateDNS\'

if [ -z "$6" ]
then
    aws ec2 create-tags \
    --region ${region} \
    --resources ${instanceID} \
    --tags Key=Name,Value=${stackName}-Server Key=Role,Value=${services} Key=StackService,Value=${stackName}-${services}
else
    aws ec2 create-tags \
    --region ${region} \
    --resources ${instanceID} \
    --tags Key=Name,Value=${stackName}-Server-Rally Key=Role,Value=${services} Key=StackService,Value=${stackName}-${services}
fi
