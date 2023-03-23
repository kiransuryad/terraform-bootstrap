#!/bin/bash

# Initialize Terraform in the bootstrap directory
cd terraform-bootstrap
terraform init

# Apply the bootstrap configuration to create the S3 bucket
terraform apply -auto-approve

# Output the name of the S3 bucket
bucket_name=$(terraform output s3_bucket_name)
echo "Terraform state bucket created: ${bucket_name}"

# Update the backend configuration in your Terraform configurations to use the new S3 bucket
cd ..
for tf_config in $(find . -name "*.tf"); do
  sed -i "s/my-terraform-state-bucket/${bucket_name}/g" ${tf_config}
done

echo "Backend configuration updated in all Terraform configurations."
