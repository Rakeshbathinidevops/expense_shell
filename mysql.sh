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
        echo -e "$2 is $G FAILED $N"
        exit 1
    else    
        echo -e "$2 is $G SUCCESSFUL $N"
fi
}

if [ $USERID -ne 0]
then
    echo "You are not a root user"
    exit 1
else
    echo " You are a root user"
fi

dnf install mysql-server -y 2>>$LOGFILE
VALIDATE $? "installation of mysqlserver"
systemctl start mysqld 2>>$LOGFILE
VALIDATE $? "Starting mysqlserver"
systemctl enable mysqld 2>>$LOGFILE
VALIDATE $? "enabling mysqlserver"
mysql -h 172.31.43.26 -uroot -pExpenseApp@1 -e 'show databases;' 2>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 2>>$LOGFILE
    VALIDATE $? "my root password setup"
else
    echo -e "Root password already set $Y SKIPPIBG $N"
fi





