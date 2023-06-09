#!/bin/bash

# Check if $1 matches $i and move files accordingly
for (( i=6; i<=20; i++ )); do
  if [ "$1" == "$i" ]; then
    mv ./tmp/"${i}-"* ./
  fi
done

# Run "terraform apply" command
terraform apply