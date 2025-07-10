#!/bin/bash

LOGS_FOLDER="/var/log/expense-shell"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
CHECK_ROOT(){
if [ $USERID -ne 0 ]
then
    echo "please run the user with root privilleges"
    exit 1
fi
}

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo -e "$2 is..$R FAILURE $N" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$2 is..$G SUCCESS $N" | tee -a $LOG_FILE    
fi
}

echo "script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "installing MySQL server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enabled MySQL server"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Started MySQL server"

mysql -h mysql-database.narayanarao.cloud -u root -pExpenseApp@1 -e "show databases:" &>> $LOG_FILE
if [ $? ne 0 ]
then
    echo "MySQL root password is not setup, setting up" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting UP root password"
else
    echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi