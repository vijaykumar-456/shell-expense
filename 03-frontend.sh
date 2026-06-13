#!/bin/bash

LOG_FOLDER='/var/log/expense'
mkdir -p $LOG_FOLDER
sudo chown -R ec2-user:ec2-user $LOG_FOLDER
sudo chmod -R 755 $LOG_FOLDER
LOG_FILE="/$LOG_FOLDER/$0.log"

SCRIPT_DIR=$PWD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S" )

SCRIPT_DIR=$PWD

USER_ID=$( id -u )

if [ "$USER_ID" -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR]  Please login with sudo access ... $R FAILURE $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a  $LOG_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 ... $G SUCCESS $N" | tee -a  $LOG_FILE
    fi
}

dnf install nginx -y
VALIDATE $? "Installing nginx"

systemctl enable nginx
systemctl start nginx
VALIDATE $? "Enabling and restarting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing default html page"

curl -o /tmp/frontend.tar.gz https://raw.githubusercontent.com/daws-90s/expense-documentation/refs/heads/main/artifacts/expense-frontend-v3.tar.gz

cd /usr/share/nginx/html
tar -xzf /tmp/frontend.tar.gz --strip-components=1
VALIDATE $? "loading and unzipping frontend code"

cp $SCRIPT_DIR/etc/nginx/default.d/expense.conf
VALIDATE $? "Installing npm dependencies"

systemctl restart nginx
VALIDATE $? "restarting nginx"