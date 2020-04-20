#!/bin/bash

source ./lib/extract_cfg_value.sh

test_extract_cfg_value() {
  local key=$1
  local section=$2
  local value
  value=$(extract_cfg_value "$section" "$key" <example.cfg)
  if [[ $? != 0 ]]; then
    printf "The value of key '%s' in section '%s' was NOT found!\n" "$key" "$section"
  elif [[ -n $value ]]; then
    printf "The value of key '%s' in section '%s' was found to be '%s'\n" "$key" "$section" "$value"
  else
    printf "The value of key '%s' in section '%s' was an empty string\n" "$key" "$section"
  fi
}

main() {
  # test_extract_cfg_value "main1" "Section C" 
  # test_extract_cfg_value "KeyThree" "Section C"
  # test_extract_cfg_value "KeyThreeBogus" "Section C"
  # test_extract_cfg_value "KeyThree" "Section Bogus"
  test_extract_cfg_value "KeyThree"
  test_extract_cfg_value "def1"
  test_extract_cfg_value "def2"
  test_extract_cfg_value "def3"
}

main

