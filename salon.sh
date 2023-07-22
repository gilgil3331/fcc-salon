#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

allServices=$($PSQL "SELECT * FROM services;")
i=0
#Header
echo -e "\n~~~~~ MY SALON ~~~~~\n"
# Question
echo -e "\nWelcome to My Salon, how can I help you?\n"


while IFS='|' read -r ID SERVICE; do
  echo "$ID) $SERVICE"
  ((i++))  # Increment the value of i by 1
done < <(echo "$allServices")

read SERVICE_ID_SELECTED
until (($SERVICE_ID_SELECTED >= 1 && $SERVICE_ID_SELECTED <= i))
do
echo -e "\nI could not find that service. What would you like today?\n"
    while IFS='|' read -r ID SERVICE; do
    echo "$ID) $SERVICE"
  done < <(echo "$allServices")
  
  read SERVICE_ID_SELECTED
done

#SERVICE_ID_SELECTED= echo $userInput
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CHECK=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [ -z "$CHECK" ]; then
  # If a customer does not exist
  echo -e "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  echo -e "What time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME
  echo $($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
else
  # If a customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  echo -e "What time would you like your cut, $CUSTOMER_NAME"
  read SERVICE_TIME
fi


CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")

echo $($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES('$SERVICE_ID_SELECTED', '$CUSTOMER_ID', '$SERVICE_TIME');")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'") 

echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
