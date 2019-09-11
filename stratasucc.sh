#!/bin/bash

usage() {
  echo "Read and write to Stratasucc(TM) EEPROM chips"
  echo "Usage: stratasucc.sh [-rw]"
  echo "-r              Read from EEPROM"
  echo "-w              Write to EEPROM"
  echo "-h              Display this help text and exit"
  exit
}

function GetChipID() {
  #cd in to that pesky serial number folder
  cd /sys/bus/w1/devices/w1_bus_master1/
  
  #get ID path (the one with the dash)
  IDp=$(ls | grep 23-)
  
  if [ ! -z "$IDp" ];
  then
    cd $IDp
  else
    echo 'Stratasys EEPROM device not found!'
    exit
  fi
  
  #Get chip ID (non dashed one)
  ID=$(xxd -p id)
  echo 'Found chip: '$ID
}

function ReadEE() {
  GetChipID

  cp eeprom ~/stratasucc/read.bin
  cd ~/stratasucc
  stratatools eeprom_decode -t prodigy -e $ID read.bin read.txt

  echo 'done!'
  cat read.txt
}

function WriteEE() {
  GetChipID

  cd ~/stratasucc

  stratatools eeprom_encode -t prodigy -e $ID write.txt write.bin

  cd /sys/bus/w1/devices/w1_bus_master1/
  cd $IDp

  sudo cp ~/stratasucc/write.bin eeprom
  echo 'done!'
}


while getopts ':rw?h' c
do
  case $c in
    r) ReadEE
      exit ;;
    w) WriteEE
      exit ;;
    h|?) usage ;;
    :) usage ;;
  esac
done
