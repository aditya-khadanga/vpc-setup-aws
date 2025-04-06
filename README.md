# AWS VPC Setup with Terraform with Remote Backend

This project sets up a basic AWS VPC using Terraform, complete with public and private subnets, Internet Gateway, NAT Gateway, and remote state management via S3 and DynamoDB.

---

## 📦 Features
- VPC with CIDR block `10.0.0.0/16`
- Public subnet: `10.0.1.0/24`
- Private subnet: `10.0.2.0/24`
- Internet Gateway for public subnet
- NAT Gateway for private subnet
- Route tables and associations
- S3 remote backend for state
- DynamoDB table for state locking

---

## 📁 Project Structure
```
├── main.tf              # VPC, subnets, route tables, gateways
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── provider.tf          # AWS provider config
├── backend.tf           # Remote backend configuration
├── .gitignore           # Files to exclude from git
├── README.md            # This file
```

## Expectation

![Screenshot 2025-04-05 1857051](https://github.com/user-attachments/assets/1527b31f-b6d5-4591-bdb6-8d26d9dc24b6)

---

## ✅ Prerequisites
- AWS CLI installed and configured with access key and secret key
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws --version
aws configure
```

- Terraform installed (>= 1.0)
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
terraform -v
```
- An S3 bucket and DynamoDB table created manually (see below)

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/aditya-khadanga/vpc-setup-aws.git
cd vpc-setup-aws
```

### 2. Update Backend Config
Edit `backend.tf` and replace:
```hcl
bucket         = "your-terraform-state-bucket-name"
dynamodb_table = "terraform-locks"
```
with your actual bucket and DynamoDB table names.

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Validate Configuration
```bash
terraform validate
```

### 5. Plan the Infrastructure
```bash
terraform plan
```

### 6. Apply the Infrastructure
```bash
terraform apply -auto-approve
```
Confirm when prompted.

![Screenshot 2025-04-05 185705](https://github.com/user-attachments/assets/d345da08-7310-4d26-8dfb-77256f09139c)


---

## 🗃️ Create S3 Bucket and DynamoDB Table (Manual)
### S3 Bucket
```bash
aws s3api create-bucket \
  --bucket your-terraform-state-bucket-name \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
aws s3api put-bucket-versioning --bucket your-terraform-state-bucket-name --versioning-configuration Status=Enabled
```

### DynamoDB Table
```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

---

## 🧪 Backend Health Check
Use the helper script `check-backend-health.sh` to verify backend status:
```bash
chmod +x check-backend-health.sh
./check-backend-health.sh
```
![Screenshot 2025-04-06 122900](https://github.com/user-attachments/assets/aa8dee41-fcf4-4a3e-a32c-a90ce607da5d)


### ✅ Simulate a Lock
Try running `terraform apply -auto-approve` and leave it running. Then in another terminal, try:

```bash
terraform apply -auto-approve
```

You should get a message like:

```yaml
Error acquiring the state lock
Lock Info:
  ID:               terraform-20240406...
  Path:             aws-vpc/terraform.tfstate
  Operation:        OperationTypeApply
  Who:              user@hostname
  Info:             ...
```

This confirms Terraform is using DynamoDB for locking.

---

## 🧹 Cleanup
To destroy all created resources:
```bash
terraform destroy -auto-approve
```

---

## 📜 License
MIT

---

## 🙋‍♂️ Questions or Issues?
Open an issue or reach out at [adityakhadanga5@gmail.com]

