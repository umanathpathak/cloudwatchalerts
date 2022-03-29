#!/bin/sh

#set -ex

#====================================================================================================================
#
# Maintainer : Umanath Pathak
# 
# FILE: install-cw-and-create-cloudwatch-alarms.sh
#
# USAGE: ./install-cw-and-create-cloudwatch-alarms.sh
#
# This script downloads and installs CloudWatch agent. 
#
# This script creates AWS CloudWatch alarms based on selected metrics and user input (variables) to setup alarms.
#
# DESCRIPTION:- Script creates below 6 alarms for instance-
# 1. Create High CPU usage alarm
# 2. Create Instance StatusCheckFailed alarm 
# 3. Create High NetworkIn usage alarm
# 4. Create High NetworkOut usage alarm
# 5. Create High MEMORY usage alarm
# 6. Create High DISK usage alarm
#
#====================================================================================================================



# A. Checking Machine Type
checkMachineType() 
{

uname -a  | grep -i Ubuntu
machinetype=`echo "$?"` 

}
checkMachineType

#====================================================================================================================


# B. Installing Cloud Watch Agent
installCloudWatchAgent()
{
if [ $machinetype -eq 0 ]

then

echo "Machine Type is Debian......................................................................." 

echo "Downloadloading and installing CloudWatch Agent on Ubuntu Machine............................."
cd /opt && wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb && dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo mkdir -p /usr/share/collectd
sudo touch /usr/share/collectd/types.db
sudo cp config.json /opt/aws/amazon-cloudwatch-agent/bin/
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
echo "Restarting Cloud Watch agent.................................................................."
sudo systemctl restart amazon-cloudwatch-agent


else


echo "Machine type is CentOS ........................................................................" 

echo "Downloadloading and installing CloudWatch Agent on CentOS Machine..............................."
sudo yum install amazon-cloudwatch-agent -y 
sudo mkdir -p /usr/share/collectd
sudo touch /usr/share/collectd/types.db
sudo cp config.json /opt/aws/amazon-cloudwatch-agent/bin/
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
echo "Restarting Cloud Watch agent"
sudo systemctl restart amazon-cloudwatch-agent

fi 

}
installCloudWatchAgent


#====================================================================================================================


#Alerts to be Created:-

#1
cpuAlarm
echo "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/CPUUtilization  -> Alert Created..."
#2
statusCheckAlarm
echo "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/StatusCheckFailed  -> Alert Created..."
#3
networkInAlarm
echo "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/NetworkIn  -> Alert Created..."
#4
networkOutAlarm
echo "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/NetworkOut  -> Alert Created..."
#5
memoryUsageAlarm
echo "MSP/${AccountName}/AWS/CWAgent/${INSTANCE_NAME}/${INSTANCE_ID}/mem_used_percent  -> Alert Created..."
#6
diskUsageAlarm
echo "MSP/${AccountName}/AWS/CWAgent/${INSTANCE_NAME}/${INSTANCE_ID}/disk_used_percent  -> Alert Created..."


#====================================================================================================================

#Defining Variables

AccountName="TataskyOTT"
INSTANCE_NAME="Test"
INSTANCE_ID="i-0ccced9a7b42c07df"
ImageId="ami-0851b76e8b1bce90b"
InstanceType="t2.micro"
ARN_OF_SNS_TOPIC="arn:aws:sns:ap-south-1:588561276378:testing-pathak"
CPU_THRESHOLD="10"
NetworkIn_THRESHOLD="100000000"
NetworkOut_THRESHOLD="100000000"
MEMORY_THRESHOLD="80"
DISK_THRESHOLD="80"
MountPath="/"
Disk_Device="xvda1"
fstype="ext4"

#====================================================================================================================

#Alerts


# 1) Create High CPU usage alarm
cpuAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/CPUUtilization"\
 --alarm-description "Alarm when CPU exceeds ${CPU_THRESHOLD}%"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --treat-missing-data missing\
 --metric-name CPUUtilization\
 --namespace AWS/EC2\
 --statistic Average\
 --dimensions Name=InstanceId,Value=${INSTANCE_ID}\
 --period 300\
 --threshold "${CPU_THRESHOLD}"\
 --comparison-operator GreaterThanThreshold\
 --datapoints-to-alarm 2\
 --evaluation-periods 3\
 --unit Percent
}
#cpuAlarm
#echo "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/CPUUtilization  -> Alert Created..."


# 2) Create Instance StatusCheckFailed alarm 
statusCheckAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/StatusCheckFailed"\
 --alarm-description "Alarm when StatusCheck failed"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --metric-name StatusCheckFailed\
 --namespace AWS/EC2\
 --statistic Maximum\
 --dimensions Name=InstanceId,Value=${INSTANCE_ID}\
 --period 60\
 --threshold 1\
 --comparison-operator GreaterThanOrEqualToThreshold\
 --datapoints-to-alarm 1\
 --evaluation-periods 1\
 --unit Count
}
#statusCheckAlarm
#echo "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/StatusCheckFailed  -> Alert Created..."


# 3) Create High NetworkIn usage alarm
networkInAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/NetworkIn"\
 --alarm-description "Alarm when high NeworkIn  traffic"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --metric-name NetworkIn\
 --namespace AWS/EC2\
 --statistic Average\
 --dimensions Name=InstanceId,Value=${INSTANCE_ID}\
 --period 300\
 --threshold "${NetworkIn_THRESHOLD}"\
 --comparison-operator GreaterThanOrEqualToThreshold\
 --datapoints-to-alarm 3\
 --evaluation-periods 3\
 --unit Bytes
}
#networkInAlarm
#echo "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/NetworkIn  -> Alert Created..."


# 4) Create High NetworkOut usage alarm
networkOutAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/NetworkOut"\
 --alarm-description "Alarm when high NetworkOut traffic"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --metric-name NetworkOut\
 --namespace AWS/EC2\
 --statistic Average\
 --dimensions Name=InstanceId,Value=${INSTANCE_ID}\
 --period 300\
 --threshold "${NetworkOut_THRESHOLD}"\
 --comparison-operator GreaterThanOrEqualToThreshold\
 --datapoints-to-alarm 3\
 --evaluation-periods 3\
 --unit Bytes
}
#networkOutAlarm
#echo "MSP/${AccountName}/AWS/EC2/${INSTANCE_NAME}/${INSTANCE_ID}/NetworkOut  -> Alert Created..."


# 5) Create High MEMORY usage alarm
memoryUsageAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/CWAgent/${INSTANCE_NAME}/${INSTANCE_ID}/mem_used_percent"\
 --alarm-description "Alarm when high Memory Utilization"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --metric-name mem_used_percent\
 --namespace CWAgent\
 --statistic Average\
 --dimensions Name=InstanceId,Value="${INSTANCE_ID}" Name=ImageId,Value="${ImageId}" Name=InstanceType,Value="${InstanceType}"\
 --period 60\
 --threshold "${MEMORY_THRESHOLD}"\
 --comparison-operator GreaterThanThreshold\
 --datapoints-to-alarm 10\
 --evaluation-periods 10\
 --unit Percent
}
#memoryUsageAlarm
#echo "MSP/${AccountName}/AWS/CWAgent/${INSTANCE_NAME}/${INSTANCE_ID}/mem_used_percent  -> Alert Created..."


# 6) Create High DISK usage alarm
diskUsageAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/CWAgent/${INSTANCE_NAME}/${INSTANCE_ID}/disk_used_percent"\
 --alarm-description "Alarm when high Disk usage Utilization"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --metric-name disk_used_percent\
 --namespace CWAgent\
 --statistic Average\
 --dimensions Name=path,Value="${MountPath}" Name=InstanceId,Value="${INSTANCE_ID}" Name=ImageId,Value="${ImageId}" Name=InstanceType,Value="${InstanceType}" Name=device,Value="${Disk_Device}" Name=fstype,Value="${fstype}" \
 --period 60\
 --threshold "${DISK_THRESHOLD}"\
 --comparison-operator GreaterThanThreshold\
 --datapoints-to-alarm 10\
 --evaluation-periods 10\
 --unit Percent
}
#diskUsageAlarm
#echo "MSP/${AccountName}/AWS/CWAgent/${INSTANCE_NAME}/${INSTANCE_ID}/disk_used_percent  -> Alert Created..."
