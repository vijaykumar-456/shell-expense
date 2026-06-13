#!/bin/bash

LOG_FOLDER='/var/log/expense'
mkdir -p $LOG_FOLDER
sudo chown -R ec2-user:ec2-user $LOG_FOLDER
sudo chmod -R 755 $LOG_FOLDER
LOG_FILE="/$LOG_FOLDER/$0.log"


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

dnf module disable nodejs -y &>> $LOG_FILE
dnf module enable nodejs:20 -y &>> $LOG_FILE
dnf install nodejs -y &>> $LOG_FILE

id expense &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense &>>$LOG_FILE
    VALIDATE $? "Creating expense system user"
else
    echo -e "$R User Already present with this name $N ... $Y SKIPPING $N"
fi

rm -rf /app
VALIDATE $? "Removing Existing app/code"

rm -rf /tmp/expense-backend.zip
VALIDATE $? "Removing Exisiting expense-backend"

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Creating app folder for code"

curl -o /tmp/expense-backend.zip curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-90s/expense-documentation/refs/heads/main/artifacts/expense-backend-v3.tar.gz  &>>$LOG_FILE
cd /app
unzip /tmp/expense-backend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the expense-backend code"

npm install &>> $LOG_FILE
VALIDATE $? "Installing npm dependencies"

cp $SCRIPT_DIR/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Creating systemctl service"


dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.learndevopskills.shop -u root -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Loading data ... "

systemctl daemon-reload &>> $LOG_FILE
systemctl enable backend &>> $LOG_FILE
systemctl restart backend &>> $LOG_FILE
VALIDATE $? "Enabling and restaring the backend "

