#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
validate $? "Installing monfodb sever"

systemctl enable mongod &>>$LOGS_FILE
validate $? "mongodb enable"

systemctl start mongod
validate $? "mongodb start"

systemctl status mongod

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Allowing remote connections"

systemctl restart mongod &>>$LOGS_FILE
validate $? "restart mongodb"

total_time