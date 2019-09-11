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
  cd /sys/bus/w1/devices/w1_bus_master1/ && cd $(ls | grep 23-)
  #Get chip ID (non dashed one)
  ID=$(xxd -p id)
  echo 'found chip: '$ID
}

function ReadEE() {
  GetChipID()

  cp eeprom ~/strat-chip/read.bin
  cd ~/strat-chip
  stratatools eeprom_decode -t prodigy -e $ID read.bin read.txt

  echo 'done!'
}

function WriteEE() {
  GetChipID()

  cd ~/strat-chip

  stratatools eeprom_encode -t prodigy -e $ID write.txt write.bin

  cd /sys/bus/w1/devices/w1_bus_master1/
  cd $ID

  sudo cp ~/strat-chip/write.bin eeprom
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
