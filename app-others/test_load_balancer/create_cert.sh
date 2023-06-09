#!/bin/bash

# move tf file to ./
mv ./app-others/test_load_balancer/app-ACM.tf ./

# terraform apply
terraform apply


# command to clean
if [ "$" == "clean" ]; then
    mv app-ACM.tf ./app-others/test_load_balancer/app-ACM.tf
fi