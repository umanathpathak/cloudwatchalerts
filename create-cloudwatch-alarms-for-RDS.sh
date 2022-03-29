#!/bin/sh

#set -ex

#================================================================================================================
#
# Maintainer : Umanath Pathak
# 
# FILE: create-cloudwatch-alarms-for-RDS.sh
#
# USAGE: ./create-cloudwatch-alarms-for-RDS.sh
#
# This script creates AWS CloudWatch alarms for RDS based on selected metrics and user input (variables) to setup alarms.
#
# DESCRIPTION:- Script creates below 4 alarms for RDS instance-
# 1. Create RDS High Database Connections alarm
# 2. Create RDS High CPU Utilization alarm
# 3. Create RDS Low FreeLocalStorage alarm
# 4. Create RDS Low FreeableMemory alarm
#
#================================================================================================================


#Alerts to be Created:-

#1
databaseConnectionsAlarm
echo "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/DatabaseConnections     -> Alert Created..."
#2
cpuUtilizationAlarm
echo "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/CPUUtilization          -> Alert Created..."
#3
freeLocalStorageAlarm
echo "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/FreeLocalStorage     -> Alert Created..."
#4
freeableMemoryAlarm
echo "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/FreeableMemory    -> Alert Created..."


#================================================================================================================


#Defining Variables

AccountName="TataskyOTT"
ARN_OF_SNS_TOPIC="arn:aws:sns:ap-south-1:588561276378:testing-pathak"
RDS_INSTANCE_NAME="Test"
RDS_Database_Connections_THRESHOLD="1700"
RDS_CPUUtilization_THRESHOLD="10"
RDS_FreeLocalStorage_THRESHOLD="2000000000"
RDS_FreeableMemory_THRESHOLD="2000000000"

#================================================================================================================

# RDS Alarms


# 1) Create RDS High Database Connections alarm
databaseConnectionsAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/DatabaseConnections"\
 --alarm-description "Alarm when Database Connections exceeds ${RDS_Database_Connections_THRESHOLD}"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --treat-missing-data missing\
 --metric-name DatabaseConnections\
 --namespace AWS/RDS\
 --statistic Maximum\
 --dimensions "Name=DBInstanceIdentifier,Value=${RDS_INSTANCE_NAME}"\
 --period 60\
 --threshold "${RDS_Database_Connections_THRESHOLD}"\
 --comparison-operator GreaterThanThreshold\
 --datapoints-to-alarm 5\
 --evaluation-periods 5\
 --unit Count
}
#databaseConnectionsAlarm
#echo "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/DatabaseConnections"


# 2) Create RDS High CPU Utilization alarm
cpuUtilizationAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/CPUUtilization"\
 --alarm-description "Alarm when RDS CPU Utilization exceeds ${RDS_CPUUtilization_THRESHOLD}%"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --treat-missing-data missing\
 --metric-name CPUUtilization\
 --namespace AWS/RDS\
 --statistic Average\
 --dimensions "Name=DBInstanceIdentifier,Value=${RDS_INSTANCE_NAME}"\
 --period 3000\
 --threshold "${RDS_CPUUtilization_THRESHOLD}"\
 --comparison-operator GreaterThanThreshold\
 --datapoints-to-alarm 2\
 --evaluation-periods 2\
 --unit Percent
}
#cpuUtilizationAlarm
#echo "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/CPUUtilization"


# 3) Create RDS Low FreeLocalStorage alarm
freeLocalStorageAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/FreeLocalStorage"\
 --alarm-description "Alarm when RDS FreeLocalStorage drops ${RDS_FreeLocalStorage_THRESHOLD}"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --treat-missing-data missing\
 --metric-name FreeLocalStorage\
 --namespace AWS/RDS\
 --statistic Maximum\
 --dimensions "Name=DBInstanceIdentifier,Value=${RDS_INSTANCE_NAME}"\
 --period 3000\
 --threshold "${RDS_FreeLocalStorage_THRESHOLD}"\
 --comparison-operator LessThanThreshold\
 --datapoints-to-alarm 2\
 --evaluation-periods 2\
 --unit Bytes
}
#freeLocalStorageAlarm
#echo "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/FreeLocalStorage"


# 4) Create RDS Low FreeableMemory alarm
freeableMemoryAlarm()
{
aws cloudwatch put-metric-alarm \
 --alarm-name "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/FreeableMemory"\
 --alarm-description "Alarm when RDS FreeableMemory drops ${RDS_FreeableMemory_THRESHOLD}"\
 --actions-enabled \
 --alarm-actions "${ARN_OF_SNS_TOPIC}"\
 --insufficient-data-actions "${ARN_OF_SNS_TOPIC}"\
 --treat-missing-data missing\
 --metric-name FreeableMemory\
 --namespace AWS/RDS\
 --statistic Maximum\
 --dimensions "Name=DBInstanceIdentifier,Value=${RDS_INSTANCE_NAME}"\
 --period 3000\
 --threshold "${RDS_FreeableMemory_THRESHOLD}"\
 --comparison-operator LessThanThreshold\
 --datapoints-to-alarm 2\
 --evaluation-periods 2\
 --unit Bytes
}
#freeableMemoryAlarm
#echo "MSP/${AccountName}/AWS/RDS/${RDS_INSTANCE_NAME}/FreeableMemory"