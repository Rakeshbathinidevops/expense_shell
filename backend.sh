#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0]
    then
        echo -e "$2 is $R FAILED $N"
        exit 1
    else
        echo -e "$2 is $G SUCCEED $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Your are not a Root user"
    exit 1
else
    echo "you are a Root user"
fi

dnf module disable nodejs:18 -y 2>>$LOGFILE
VALIDATE $? "disabiling nodejs"
dnf module enable nodejs:20 -y 2>>$LOGFILE
VALIDATE $? "enabling nodejs"
dnf install nodejs -y 2>>$LOGFILE
VALIDATE $? "installing nodejs"

id expense 2>>$LOGFILE
if [ $? -ne 0]
then    
    useradd expense 2>>$LOGFILE
    VALIDATE $? "creating user"
else    
    exho "User already existed"
fi

makedir -p /app 2>>$LOGFILE
VALIDATE $? "creating app dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip 2>>$LOGFILE
VALIDATE $? "downloading backend"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip 2>>$LOGFILE
VALIDATE $? "zip file unzipping"

npm install 2>>$LOGFILE
VALIDATE $? "nodejs dependecies installing"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Client"

mysql -h db.daws78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend"