#!/bin/bash

# Get the certificate ARN from Terraform output
terraform output
cert_arn=$(terraform output cert_arn)

# Replace "<<ARN_OF_CERTIFICATE>>" in the file "./istio/0-values/2-gateway.yaml" with the certificate ARN

# awk -v cert="$cert_arn" '{gsub("<<ARN_OF_CERTIFICATE>>", cert)}1' ./istio/0-values/2-gateway.yaml > temp.yaml && mv temp.yaml ./istio/0-values/2-gateway.yaml

# # Replace "#add_value" in the file "17-istio.tf" with "values = ["${file(./istio/0-values/2-gateway.yaml)}"]"
# sed -i "s|#add_value|values = [\"\${file(./istio/0-values/2-gateway.yaml)}\"]|g" 17-istio.tf



# if [ "$1" == "clean" ]; then
#     sed -i 's|values = \["\${file(./istio/0-values/2-gateway.yaml)}"\]|#add_value|g' 17-istio.tf
#     sed -i 's|'"$cert_arn"'|<<ARN_OF_CERTIFICATE>>|g' ./istio/0-values/2-gateway.yaml
#     fi


if [[ "$1" == "clean" ]]; then
  # Undo the replacement of "<<ARN_OF_CERTIFICATE>>" with the original placeholder
  awk -v cert="$cert_arn" '{gsub(cert, "<<ARN_OF_CERTIFICATE>>")}1' ./istio/0-values/2-gateway.yaml > temp.yaml && mv temp.yaml ./istio/0-values/2-gateway.yaml

  # Undo the replacement of "#add_value" with the original placeholder
#   awk '{gsub("values = [\"${file("./istio/0-values/2-gateway.yaml")}\"]", "#add_value")}1' 17-istio.tf > temp.txt && mv temp.txt 17-istio.tf

  echo "Changes undone."
else
  # Get the certificate ARN from Terraform output
  cert_arn=$(terraform output cert_arn)

  echo "Certificate ARN: $cert_arn"  # Debugging statement

  # Replace "<<ARN_OF_CERTIFICATE>>" in the file with the certificate ARN
  awk -v cert="$cert_arn" '{gsub("<<ARN_OF_CERTIFICATE>>", cert)}1' ./istio/0-values/2-gateway.yaml > temp.yaml && mv temp.yaml ./istio/0-values/2-gateway.yaml

  # Replace "#add_value" in the file with "values = ["${file(./istio/0-values/2-gateway.yaml)}"]"
#   awk '{gsub("#add_value", "values = [\"${file("./istio/0-values/2-gateway.yaml")}\"]")}1' 17-istio.tf > temp.txt && mv temp.txt 17-istio.tf

  echo "Changes applied."
fi