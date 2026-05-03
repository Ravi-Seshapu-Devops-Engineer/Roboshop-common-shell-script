#!/bin/bash

source ./common.sh
app_name=redis
check_root



dnf module disable $app_name -y &>>$LOGS_FILE
dnf module enable $app_name:7 -y &>>$LOGS_FILE
validate $? "Redis module disabled and module 7 enabled"

dnf install $app_name -y &>>$LOGS_FILE
validate $? "$app_name installation"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOGS_FILE
validate $? "Allowing remote access"

systemctl enable redis &>>$LOGS_FILE
systemctl start redis &>>$LOGS_FILE
validate $? " enabling and starting redis"