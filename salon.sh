#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?"
  fi

  GET_SERVICES=$($PSQL "SELECT * FROM services") 
  echo "$GET_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_ID_SELECTED ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    fi
    
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
        echo -e "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        CUSTOMER_INSERTION=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    TRIMMED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ *$//g')
    TRIMMED_SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/ *$//g')

    echo -e "What time would you like your $TRIMMED_SERVICE_NAME, $TRIMMED_CUSTOMER_NAME?"
    read SERVICE_TIME

    APPOINTMENT_INSERTION=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $TRIMMED_SERVICE_NAME at $SERVICE_TIME, $TRIMMED_CUSTOMER_NAME."
  fi

}

MAIN_MENU
