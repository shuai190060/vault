#!/bin/bash

# Move files matching patterns to "./tmp"
for (( i=7; i<=20; i++ )); do
  find . -maxdepth 1 -type f -name "${i}-*" -exec mv {} ./tmp/ \;
done

# Run "terraform apply" command
terraform apply