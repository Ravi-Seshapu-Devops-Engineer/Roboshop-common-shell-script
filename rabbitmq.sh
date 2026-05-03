#!/bin/bash


source ./common.sh
app_name=rabbitmq

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? " Rabbitmq addition"

dnf install rabbitmq-server -y &>>$LOGS_FILE
validate $? "Installation of mysql server"

systemctl enable rabbitmq-server &>>$LOGS_FILE
systemctl start rabbitmq-server &>>$LOGS_FILE
validate $? " Enabling and starting of rabbitmq "

rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
validate $? "created user and given permissions"