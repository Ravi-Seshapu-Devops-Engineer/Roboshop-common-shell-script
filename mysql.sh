#!/bin/bash

source ./common.sh
app_name=mysql
check_root

dnf install mysql-server -y &>>$LOGS_FILE
validate $? "installation of mysql server is "

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld  &>>$LOGS_FILE
validate $? "Enablinh mysqld and starting mysqld is "

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILE
validate $? "secure installation is "