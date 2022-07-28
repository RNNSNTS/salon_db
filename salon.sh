#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ SALON ~~~~~\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

 # get available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

   # display available services
    echo -e "\nHere are the services we have available:"
   echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
# ask for bike to rent
    echo -e "\nWhich service would you like to schedule?"
    read SERVICE_ID_SELECTED

    SERVICE_ID_DB=$($PSQL "SELECT service_id FROM services WHERE service_id =$SERVICE_ID_SELECTED;")
  #if the number input not found
    if [[ -z $SERVICE_ID_DB ]]
    then
    # return to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\n Number not found.\nWhat's your name?"
          read CUSTOMER_NAME
          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

        # get customer info
          echo -e "\nWhat time will be your appointment?"
          read SERVICE_TIME
         # if no time input
        if [[ -z $SERVICE_TIME ]]
        then
          MAIN_MENU "You have to input the time, please try again"
        fi

        #insert appointment
          APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_DB, '$SERVICE_TIME')")
        if [[ $APPOINTMENT_RESULT=='INSERT 0 1' ]]
        then
          echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
        else
        MAIN_MENU "Something is wrong, please try again."
        fi
}


MAIN_MENU