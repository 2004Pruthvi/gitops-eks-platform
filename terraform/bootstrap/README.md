# Terraform Remote State Bootstrap Guide

In enterprise infrastructure engineering, Terraform state files (`terraform.tfstate`) must never be stored locally or committed to Git. They must be stored in a centralized, encrypted, and versioned remote backend with distributed state locking.

---

## 1. Architecture of the Backend

1. **Amazon S3**:
   * Stores the `terraform.tfstate` file remotely.
   * **Versioning Enabled**: Enables recovery and history tracking if state is corrupted.
   * **Server-Side Encryption (AES256 / AWS KMS)**: Encrypts state data at rest.
   * **Public Access Blocked**: Prevents accidental exposure of infrastructure metadata.
2. **Amazon DynamoDB**:
   * Uses a primary hash key named `LockID` (string).
   * Provides distributed locking: when Terraform executes, it writes a lock record to DynamoDB, preventing concurrent executions from corrupting state.

---

## 2. Bootstrap Commands (AWS CLI)

To provision the remote state storage prior to running Terraform:

```bash
# Set variables
AWS_REGION="ap-south-1"
BUCKET_NAME="wild-tour-eks-tfstate-123456789012"
TABLE_NAME="wild-tour-eks-tflocks"

# 1. Create S3 Bucket
aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${AWS_REGION}" \
  --create-bucket-configuration LocationConstraint="${AWS_REGION}"

# 2. Enable Bucket Versioning
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

# 3. Enable Server-Side Encryption (AES256)
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# 4. Block All Public Access
aws s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration '{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
  }'

# 5. Create DynamoDB Lock Table (Hash Key: LockID)
aws dynamodb create-table \
  --table-name "${TABLE_NAME}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${AWS_REGION}"
```

---

## 3. Security Best Practices
* **Least-Privilege IAM**: Only Terraform execution roles should possess `s3:GetObject`, `s3:PutObject`, and `dynamodb:PutItem`/`dynamodb:DeleteItem` on these resources.
* **Deletion Protection**: Enable S3 MFA Delete for production backends to prevent accidental destruction.
