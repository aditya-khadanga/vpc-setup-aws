#!/bin/bash

# CONFIGURE THESE
BUCKET="remote-backend-ak"
DDB_TABLE="terraform-locks"
STATE_KEY="aws-vpc/terraform.tfstate"
REGION="ap-south-1"

echo "🔍 Checking Terraform backend health..."

# 1. Check S3 Bucket Exists
echo -n "📦 Checking S3 bucket '$BUCKET'... "
aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null

if [ $? -ne 0 ]; then
  echo "❌ NOT FOUND"
else
  echo "✅ OK"
fi

# 2. Check DynamoDB Table Exists
echo -n "🗃️  Checking DynamoDB table '$DDB_TABLE'... "
aws dynamodb describe-table --table-name "$DDB_TABLE" --region "$REGION" > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "❌ NOT FOUND"
else
  echo "✅ OK"
fi

# 3. Check for Active Lock in DynamoDB
echo -n "🔐 Checking active lock for state key '$STATE_KEY'... "
LOCK_EXISTS=$(aws dynamodb get-item \
  --table-name "$DDB_TABLE" \
  --key "{\"LockID\": {\"S\": \"$STATE_KEY\"}}" \
  --region "$REGION" \
  --query "Item.LockID.S" \
  --output text 2>/dev/null)

if [[ "$LOCK_EXISTS" == "$STATE_KEY" ]]; then
  echo "⚠️ LOCKED"
else
  echo "✅ Not locked"
fi

