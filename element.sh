#!/bin/bash
ARG=$1
ARG_SIZE=${#ARG}
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -t -A -c"
# if there is no argument:
if [[ -z $ARG ]]; then
  echo "Please provide an element as an argument."
else
  # check if argument might be an atomic number, then query for atomic number
  if [[ $1 =~ ^[0-9]+$ ]]; then  
    ATOMIC_NUMBER_QUERY_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$ARG")
  # check if argument might be an element symbol, then query for atomic number
  elif [[ ! $1 =~ '^[0-9]+$' ]] && [ $ARG_SIZE -le 2 ]; then
    ATOMIC_NUMBER_QUERY_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$ARG'")
  # argument might be an element name, then query for atomic number
  else
    ATOMIC_NUMBER_QUERY_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ARG'")
  fi

  # if element doesn't exist in database
  if [[ -z $ATOMIC_NUMBER_QUERY_RESULT ]]; then
    echo "I could not find that element in the database."
  # if it does
  else
    # querying for every property
    ATOMIC_NUMBER=$ATOMIC_NUMBER_QUERY_RESULT
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER_QUERY_RESULT")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER_QUERY_RESULT")
    TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER_QUERY_RESULT")
    MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER_QUERY_RESULT")
    MELT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER_QUERY_RESULT")
    BOIL=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER_QUERY_RESULT")

    # printing the full info
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  fi  
fi