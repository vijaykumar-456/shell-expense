#!/bin/bash

LOG_FOLDER='/var/log/expense'
mkdir -p $LOG_FOLDER
sudo chown ec2-user:ec2-user -R $LOG_FOLDER
sudo chmod -R 755 $LOG_FOLDER

LOG_FILE="$LOG_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S" )

USER_ID=$( id -u )

if [ "$USER_ID" -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR]  Please login with sudo access ... $R FAILURE $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a &>> $LOG_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 ... $G SUCCESS $N" | tee -a &>> $LOG_FILE
    fi
}

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOG_FILE
systemctl start mysqld 
VALIDATE $? "Enabling and restarting mysql"

mysql_secure_installation --set-root-pass ExpenseApp@1 
VALIDATE $? "Setting up root password"


