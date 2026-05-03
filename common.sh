#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/Roboshop-shell"
LOGS_FILE="/var/log/Roboshop-shell/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.seshapudevops.online
MYSQL_HOST=mysql.seshapudevops.online
mkdir -p $LOGS_FOLDER


Start_time=$(date +%s)
echo "$(date "+%Y-%m-%d %H:%M:%S") | Script started executing at: $(date)" | tee -a $LOGS_FILE

check_root(){
if [ $USERID -ne 0 ]; then
  echo -e "$R run the script with root user access $N" | tee -a $LOGS_FILE
  exit 1
fi
}


validate(){
  if [ $1 -ne 0 ]; then
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
    exit 1
  else
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
  fi
}

total_time(){
  end_time=$(date +%s)
  total_time=$(($end_time-$Start_time))
  echo "total time to run the script is $total_time seconds"
}

nodejs_setup(){
  dnf module disable nodejs -y &>>$LOGS_FILE
  validate $? "disabling existing nodejs" 

  dnf module enable nodejs:20 -y &>>$LOGS_FILE
  validate $? "enabling nodejs 20 version" 

  dnf install nodejs -y &>>$LOGS_FILE
  validate $? "installing nodejs"

  npm install &>>$LOGS_FILE
  validate $? "installing node package manager"
}

java_setup(){
  dnf install maven -y &>>$LOGS_FILE
  validate $? "Installation of maven"

  cd /app 
  mvn clean package &>>$LOGS_FILE
  validate $? "Installing and building $app_name"

  mv target/$app_name-1.0.jar $app_name.jar
  validate $? "moving the jar file to $app_name.jar"
}

app_setup(){
  id roboshop &>>$LOGS_FILE
  if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    validate $? "user creation"
  else
    echo -e "roboshop user aready exists $Y skipping $N"
  fi

  mkdir -p /app &>>$LOGS_FILE
  validate $? "app directory creation"

  curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOGS_FILE
  validate $? "Downloading the code"

  cd /app &>>$LOGS_FILE
  validate $? "directory changed to app"

  rm -rf /app/* &>>$LOGS_FILE
  validate $? "Removing the existing code"

  unzip /tmp/$app_name.zip &>>$LOGS_FILE
  validate $? "Unzipping the code"
}

systemd_setup(){
  cp $SCRIPT_DIR/$app_name.service /etc/systemd/system//$app_name.service &>>$LOGS_FILE
  validate $? "creating systemctl service"

  systemctl daemon-reload &>>$LOGS_FILE
  validate $? "deamon reload"

  systemctl enable $app_name &>>$LOGS_FILE
  validate $? "enabling /$app_name"

  systemctl start $app_name &>>$LOGS_FILE
  validate $? "$app_name started"
}

app_restart(){
  systemctl restart $app_name
  validate $? "$app_name restart"
}