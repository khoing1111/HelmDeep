#!/bin/bash
check_rtcode () {
    if [ 0 == $1 ]; then
      echo "OK"
    else
      echo_error "Failed"
      # exit will only stop subshell
      # To exit caller shell and nested sell we need to call kill 0 first
      # Ugly? Yes but effective.
      kill -n 1 0; exit 1
    fi
}

echo_h1 () {
  echo -e "\e[1m$1\e[0m"
}

echo_error () {
  echo -e "\e[1;31m$1\e[0m"
}

echo_warning () {
  echo -e "\e[1;33m$1\e[0m"
}

echo_success () {
  echo -e "\e[1;34mSUCCESS\e[0m"
}

promp_confirm () {
  read -p "Are you sure? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo_h1 "Exit now!"
    exit 1
  fi
}
