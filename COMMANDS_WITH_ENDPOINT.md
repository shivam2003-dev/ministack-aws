# MiniStack AWS - Complete Command Reference with Localhost Endpoint

> **IMPORTANT**: All commands in this guide use `--endpoint-url=http://localhost:4566` explicitly to ensure they connect to your local MiniStack, not your AWS account.

## Environment Setup (Optional)

If you want to set the endpoint globally for all commands:

```bash
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

After setting these, you can omit `--endpoint-url=http://localhost:4566` from commands. But this guide shows **all commands with explicit endpoint** for safety.

---

## 🪣 S3 - Object Storage

### Create Bucket
```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-bucket
```

### List All Buckets
```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

### List Objects in Bucket
```bash
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-bucket
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-bucket --recursive
```

### Upload File
```bash
echo "Hello World" > myfile.txt
aws --endpoint-url=http://localhost:4566 s3 cp myfile.txt s3://my-bucket/
aws --endpoint-url=http://localhost:4566 s3 cp myfile.txt s3://my-bucket/path/to/file.txt
```

### Download File
```bash
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-bucket/myfile.txt ./downloaded.txt
```

### Upload Directory (Recursive)
```bash
aws --endpoint-url=http://localhost:4566 s3 sync ./local-folder s3://my-bucket/remote-folder
```

### Delete Single Object
```bash
aws --endpoint-url=http://localhost:4566 s3 rm s3://my-bucket/myfile.txt
```

### Delete All Objects in Bucket
```bash
aws --endpoint-url=http://localhost:4566 s3 rm s3://my-bucket --recursive
```

### Delete Bucket (Must be empty)
```bash
aws --endpoint-url=http://localhost:4566 s3 rb s3://my-bucket
```

### Enable Versioning
```bash
aws --endpoint-url=http://localhost:4566 s3api put-bucket-versioning \
  --bucket my-bucket \
  --versioning-configuration Status=Enabled
```

### List Versions
```bash
aws --endpoint-url=http://localhost:4566 s3api list-object-versions \
  --bucket my-bucket
```

### Enable Server-Side Encryption
```bash
aws --endpoint-url=http://localhost:4566 s3api put-bucket-encryption \
  --bucket my-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### Set Bucket Lifecycle Policy
```bash
aws --endpoint-url=http://localhost:4566 s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket \
  --lifecycle-configuration '{
    "Rules": [{
      "ID": "archive-old-files",
      "Status": "Enabled",
      "Prefix": "logs/",
      "Transitions": [{
        "Days": 30,
        "StorageClass": "GLACIER"
      }]
    }]
  }'
```

### Get Bucket Info
```bash
aws --endpoint-url=http://localhost:4566 s3api head-bucket --bucket my-bucket
aws --endpoint-url=http://localhost:4566 s3api get-bucket-versioning --bucket my-bucket
aws --endpoint-url=http://localhost:4566 s3api get-bucket-encryption --bucket my-bucket
```

---

## 📨 SQS - Message Queues

### Create Queue
```bash
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name my-queue
```

Output:
```json
{
    "QueueUrl": "https://queue.amazonaws.com/123456789012/my-queue"
}
```

### Create FIFO Queue
```bash
aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name my-queue.fifo \
  --attributes FifoQueue=true,ContentBasedDeduplication=true
```

### Get Queue URL
```bash
QUEUE_URL=$(aws --endpoint-url=http://localhost:4566 sqs get-queue-url \
  --queue-name my-queue \
  --query 'QueueUrl' --output text)

echo $QUEUE_URL
```

### List All Queues
```bash
aws --endpoint-url=http://localhost:4566 sqs list-queues
```

### Send Single Message
```bash
aws --endpoint-url=http://localhost:4566 sqs send-message \
  --queue-url https://queue.amazonaws.com/123456789012/my-queue \
  --message-body "Hello SQS"
```

### Send Batch Messages
```bash
aws --endpoint-url=http://localhost:4566 sqs send-message-batch \
  --queue-url https://queue.amazonaws.com/123456789012/my-queue \
  --entries '[
    {
      "Id": "1",
      "MessageBody": "Message 1"
    },
    {
      "Id": "2",
      "MessageBody": "Message 2"
    },
    {
      "Id": "3",
      "MessageBody": "Message 3"
    }
  ]'
```

### Receive Messages
```bash
aws --endpoint-url=http://localhost:4566 sqs receive-message \
  --queue-url https://queue.amazonaws.com/123456789012/my-queue \
  --max-number-of-messages 10
```

### Delete Message (After Receiving)
```bash
# Get receipt handle from receive-message output first
RECEIPT_HANDLE="AQEBzbVv..."

aws --endpoint-url=http://localhost:4566 sqs delete-message \
  --queue-url https://queue.amazonaws.com/123456789012/my-queue \
  --receipt-handle $RECEIPT_HANDLE
```

### Get Queue Attributes
```bash
aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes \
  --queue-url https://queue.amazonaws.com/123456789012/my-queue \
  --attribute-names All
```

### Set Queue Visibility Timeout
```bash
aws --endpoint-url=http://localhost:4566 sqs set-queue-attributes \
  --queue-url https://queue.amazonaws.com/123456789012/my-queue \
  --attributes VisibilityTimeout=300
```

### Create Dead Letter Queue (DLQ)
```bash
# 1. Create DLQ
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name my-dlq

DLQ_URL=$(aws --endpoint-url=http://localhost:4566 sqs get-queue-url \
  --queue-name my-dlq \
  --query 'QueueUrl' --output text)

# 2. Get DLQ ARN
DLQ_ARN=$(aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes \
  --queue-url $DLQ_URL \
  --attribute-names QueueArn \
  --query 'Attributes.QueueArn' --output text)

# 3. Configure main queue with DLQ
aws --endpoint-url=http://localhost:4566 sqs set-queue-attributes \
  --queue-url https://queue.amazonaws.com/123456789012/my-queue \
  --attributes RedrivePolicyMessageCount=3,RedrivePolicy="{\"deadLetterTargetArn\": \"$DLQ_ARN\", \"maxReceiveCount\": \"3\"}"
```

### Delete Queue
```bash
aws --endpoint-url=http://localhost:4566 sqs delete-queue \
  --queue-url https://queue.amazonaws.com/123456789012/my-queue
```

---

## 📢 SNS - Pub/Sub Messaging

### Create Topic
```bash
aws --endpoint-url=http://localhost:4566 sns create-topic --name my-topic
```

Output:
```json
{
    "TopicArn": "arn:aws:sns:us-east-1:000000000000:my-topic"
}
```

### List Topics
```bash
aws --endpoint-url=http://localhost:4566 sns list-topics
```

### Create Subscription (SNS to SQS)
```bash
TOPIC_ARN="arn:aws:sns:us-east-1:000000000000:my-topic"
QUEUE_ARN="arn:aws:sqs:us-east-1:000000000000:my-queue"

aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol sqs \
  --notification-endpoint $QUEUE_ARN
```

### Create Subscription (SNS to Email - for testing)
```bash
aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic \
  --protocol email \
  --notification-endpoint user@example.com
```

### Create Subscription (SNS to Lambda)
```bash
aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic \
  --protocol lambda \
  --notification-endpoint arn:aws:lambda:us-east-1:000000000000:function:my-function
```

### Publish Message
```bash
aws --endpoint-url=http://localhost:4566 sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic \
  --message "Hello SNS"
```

### Publish with Message Attributes
```bash
aws --endpoint-url=http://localhost:4566 sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic \
  --message "Alert!" \
  --message-attributes '{
    "severity": {
      "DataType": "String",
      "StringValue": "high"
    },
    "environment": {
      "DataType": "String",
      "StringValue": "production"
    }
  }'
```

### List Subscriptions
```bash
aws --endpoint-url=http://localhost:4566 sns list-subscriptions
aws --endpoint-url=http://localhost:4566 sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic
```

### Delete Subscription
```bash
aws --endpoint-url=http://localhost:4566 sns unsubscribe \
  --subscription-arn arn:aws:sns:us-east-1:000000000000:my-topic:12345678-...
```

### Delete Topic
```bash
aws --endpoint-url=http://localhost:4566 sns delete-topic \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic
```

---

## 🗃️ DynamoDB - NoSQL Database

### Create Table
```bash
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name Users \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Create Table with Sort Key
```bash
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name Orders \
  --attribute-definitions \
    AttributeName=customerId,AttributeType=S \
    AttributeName=orderId,AttributeType=S \
  --key-schema \
    AttributeName=customerId,KeyType=HASH \
    AttributeName=orderId,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST
```

### List Tables
```bash
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### Describe Table
```bash
aws --endpoint-url=http://localhost:4566 dynamodb describe-table \
  --table-name Users
```

### Put Item
```bash
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
  --table-name Users \
  --item '{
    "id": {"S": "user123"},
    "name": {"S": "John Doe"},
    "email": {"S": "john@example.com"},
    "age": {"N": "30"}
  }'
```

### Put Item with TTL
```bash
EXPIRE_TIME=$(($(date +%s) + 3600))  # Expire in 1 hour

aws --endpoint-url=http://localhost:4566 dynamodb put-item \
  --table-name Users \
  --item '{
    "id": {"S": "user456"},
    "name": {"S": "Jane Doe"},
    "expireAt": {"N": "'$EXPIRE_TIME'"}
  }'
```

### Get Item
```bash
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
  --table-name Users \
  --key '{"id": {"S": "user123"}}'
```

### Query (Find by Partition Key)
```bash
aws --endpoint-url=http://localhost:4566 dynamodb query \
  --table-name Orders \
  --key-condition-expression "customerId = :cid" \
  --expression-attribute-values '{":cid": {"S": "customer123"}}'
```

### Scan (Get All Items)
```bash
aws --endpoint-url=http://localhost:4566 dynamodb scan \
  --table-name Users
```

### Scan with Filter
```bash
aws --endpoint-url=http://localhost:4566 dynamodb scan \
  --table-name Users \
  --filter-expression "age > :age" \
  --expression-attribute-values '{":age": {"N": "25"}}'
```

### Update Item
```bash
aws --endpoint-url=http://localhost:4566 dynamodb update-item \
  --table-name Users \
  --key '{"id": {"S": "user123"}}' \
  --update-expression "SET #n = :val, #e = :email" \
  --expression-attribute-names '{"#n": "name", "#e": "email"}' \
  --expression-attribute-values '{
    ":val": {"S": "Jane Doe"},
    ":email": {"S": "jane@example.com"}
  }'
```

### Delete Item
```bash
aws --endpoint-url=http://localhost:4566 dynamodb delete-item \
  --table-name Users \
  --key '{"id": {"S": "user123"}}'
```

### Batch Write Items
```bash
aws --endpoint-url=http://localhost:4566 dynamodb batch-write-item \
  --request-items '{
    "Users": [
      {
        "PutRequest": {
          "Item": {
            "id": {"S": "user1"},
            "name": {"S": "Alice"}
          }
        }
      },
      {
        "PutRequest": {
          "Item": {
            "id": {"S": "user2"},
            "name": {"S": "Bob"}
          }
        }
      }
    ]
  }'
```

### Enable TTL
```bash
aws --endpoint-url=http://localhost:4566 dynamodb update-time-to-live \
  --table-name Users \
  --time-to-live-specification AttributeName=expireAt,Enabled=true
```

### Create Global Secondary Index (GSI)
```bash
aws --endpoint-url=http://localhost:4566 dynamodb update-table \
  --table-name Users \
  --attribute-definitions AttributeName=email,AttributeType=S \
  --global-secondary-index-updates '[{
    "Create": {
      "IndexName": "email-index",
      "KeySchema": [{"AttributeName": "email", "KeyType": "HASH"}],
      "Projection": {"ProjectionType": "ALL"},
      "BillingMode": "PAY_PER_REQUEST"
    }
  }]'
```

### Query GSI
```bash
aws --endpoint-url=http://localhost:4566 dynamodb query \
  --table-name Users \
  --index-name email-index \
  --key-condition-expression "email = :email" \
  --expression-attribute-values '{":email": {"S": "john@example.com"}}'
```

### Delete Table
```bash
aws --endpoint-url=http://localhost:4566 dynamodb delete-table \
  --table-name Users
```

---

## ⚡ Lambda - Serverless Functions

### Create Function File
```bash
cat > lambda_function.py << 'EOF'
def lambda_handler(event, context):
    name = event.get('name', 'World')
    return {
        'statusCode': 200,
        'body': f'Hello {name}!'
    }
EOF
```

### Create Deployment Package
```bash
zip lambda_function.zip lambda_function.py
```

### Create Function
```bash
aws --endpoint-url=http://localhost:4566 lambda create-function \
  --function-name my-function \
  --runtime python3.11 \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda_function.zip
```

### List Functions
```bash
aws --endpoint-url=http://localhost:4566 lambda list-functions
```

### Get Function Info
```bash
aws --endpoint-url=http://localhost:4566 lambda get-function \
  --function-name my-function
```

### Invoke Function Synchronously
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name my-function \
  --payload '{"name": "Alice"}' \
  response.json

cat response.json
```

### Invoke Function Asynchronously
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name my-function \
  --invocation-type Event \
  --payload '{"name": "Bob"}' \
  response.json
```

### Update Function Code
```bash
# Modify lambda_function.py, then:
zip lambda_function.zip lambda_function.py

aws --endpoint-url=http://localhost:4566 lambda update-function-code \
  --function-name my-function \
  --zip-file fileb://lambda_function.zip
```

### Set Environment Variables
```bash
aws --endpoint-url=http://localhost:4566 lambda update-function-configuration \
  --function-name my-function \
  --environment Variables="{DB_HOST=localhost,DB_PORT=5432,debug=true}"
```

### Get Environment Variables
```bash
aws --endpoint-url=http://localhost:4566 lambda get-function-configuration \
  --function-name my-function \
  --query 'Environment.Variables'
```

### Set Timeout
```bash
aws --endpoint-url=http://localhost:4566 lambda update-function-configuration \
  --function-name my-function \
  --timeout 60
```

### Set Memory
```bash
aws --endpoint-url=http://localhost:4566 lambda update-function-configuration \
  --function-name my-function \
  --memory-size 256
```

### Create Layer
```bash
mkdir -p python
pip install requests -t python
zip -r layer.zip python

aws --endpoint-url=http://localhost:4566 lambda publish-layer-version \
  --layer-name my-layer \
  --description "My dependencies" \
  --zip-file fileb://layer.zip
```

### Add Layer to Function
```bash
aws --endpoint-url=http://localhost:4566 lambda update-function-configuration \
  --function-name my-function \
  --layers arn:aws:lambda:us-east-1:000000000000:layer:my-layer:1
```

### Create Event Source Mapping (SQS → Lambda)
```bash
aws --endpoint-url=http://localhost:4566 lambda create-event-source-mapping \
  --event-source-arn arn:aws:sqs:us-east-1:000000000000:my-queue \
  --function-name my-function \
  --batch-size 10
```

### List Event Source Mappings
```bash
aws --endpoint-url=http://localhost:4566 lambda list-event-source-mappings
```

### Delete Function
```bash
aws --endpoint-url=http://localhost:4566 lambda delete-function \
  --function-name my-function
```

---

## 🔐 IAM - Identity & Access Management

### Create User
```bash
aws --endpoint-url=http://localhost:4566 iam create-user --user-name alice
aws --endpoint-url=http://localhost:4566 iam create-user --user-name bob
```

### List Users
```bash
aws --endpoint-url=http://localhost:4566 iam list-users
```

### Create Role
```bash
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws --endpoint-url=http://localhost:4566 iam create-role \
  --role-name lambda-role \
  --assume-role-policy-document file://trust-policy.json
```

### List Roles
```bash
aws --endpoint-url=http://localhost:4566 iam list-roles
```

### Create Policy
```bash
cat > s3-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF

aws --endpoint-url=http://localhost:4566 iam create-policy \
  --policy-name s3-access \
  --policy-document file://s3-policy.json
```

### Attach Policy to Role
```bash
aws --endpoint-url=http://localhost:4566 iam attach-role-policy \
  --role-name lambda-role \
  --policy-arn arn:aws:iam::000000000000:policy/s3-access
```

### Attach AWS Managed Policy to User
```bash
aws --endpoint-url=http://localhost:4566 iam attach-user-policy \
  --user-name alice \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

### Get User
```bash
aws --endpoint-url=http://localhost:4566 iam get-user --user-name alice
```

### Get Role
```bash
aws --endpoint-url=http://localhost:4566 iam get-role --role-name lambda-role
```

### Create Access Key
```bash
aws --endpoint-url=http://localhost:4566 iam create-access-key --user-name alice
```

### Delete User
```bash
# First detach all policies
aws --endpoint-url=http://localhost:4566 iam list-user-policies --user-name bob
aws --endpoint-url=http://localhost:4566 iam detach-user-policy \
  --user-name bob \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Then delete
aws --endpoint-url=http://localhost:4566 iam delete-user --user-name bob
```

---

## 🎫 STS - Security Token Service

### Get Caller Identity
```bash
aws --endpoint-url=http://localhost:4566 sts get-caller-identity
```

### Assume Role
```bash
aws --endpoint-url=http://localhost:4566 sts assume-role \
  --role-arn arn:aws:iam::000000000000:role/lambda-role \
  --role-session-name my-session
```

### Get Session Token
```bash
aws --endpoint-url=http://localhost:4566 sts get-session-token \
  --duration-seconds 3600
```

---

## 🔑 Secrets Manager - Secret Storage

### Create Secret
```bash
aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
  --name my-db-password \
  --secret-string '{"username":"admin","password":"MySecret123!"}'
```

### Create Secret from File
```bash
aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
  --name my-api-key \
  --secret-string file://api-key.txt
```

### Get Secret Value
```bash
aws --endpoint-url=http://localhost:4566 secretsmanager get-secret-value \
  --secret-id my-db-password
```

### List Secrets
```bash
aws --endpoint-url=http://localhost:4566 secretsmanager list-secrets
```

### Update Secret
```bash
aws --endpoint-url=http://localhost:4566 secretsmanager update-secret \
  --secret-id my-db-password \
  --secret-string '{"username":"admin","password":"NewSecret456!"}'
```

### Delete Secret
```bash
aws --endpoint-url=http://localhost:4566 secretsmanager delete-secret \
  --secret-id my-db-password
```

---

## 📊 CloudWatch Logs - Logging

### Create Log Group
```bash
aws --endpoint-url=http://localhost:4566 logs create-log-group \
  --log-group-name /myapp/application
```

### Create Log Stream
```bash
aws --endpoint-url=http://localhost:4566 logs create-log-stream \
  --log-group-name /myapp/application \
  --log-stream-name stream-1
```

### Put Log Events
```bash
TIMESTAMP=$(date +%s000)

aws --endpoint-url=http://localhost:4566 logs put-log-events \
  --log-group-name /myapp/application \
  --log-stream-name stream-1 \
  --log-events timestamp=$TIMESTAMP,message="Application started"
```

### Put Multiple Log Events
```bash
TIMESTAMP=$(date +%s000)

aws --endpoint-url=http://localhost:4566 logs put-log-events \
  --log-group-name /myapp/application \
  --log-stream-name stream-1 \
  --log-events \
    timestamp=$TIMESTAMP,message="Event 1" \
    timestamp=$((TIMESTAMP+1000)),message="Event 2" \
    timestamp=$((TIMESTAMP+2000)),message="Event 3"
```

### Describe Log Groups
```bash
aws --endpoint-url=http://localhost:4566 logs describe-log-groups
```

### Describe Log Streams
```bash
aws --endpoint-url=http://localhost:4566 logs describe-log-streams \
  --log-group-name /myapp/application
```

### Get Log Events
```bash
aws --endpoint-url=http://localhost:4566 logs get-log-events \
  --log-group-name /myapp/application \
  --log-stream-name stream-1
```

### Filter Log Events
```bash
aws --endpoint-url=http://localhost:4566 logs filter-log-events \
  --log-group-name /myapp/application \
  --filter-pattern "ERROR"
```

### Set Retention Policy
```bash
aws --endpoint-url=http://localhost:4566 logs put-retention-policy \
  --log-group-name /myapp/application \
  --retention-in-days 7
```

### Delete Log Group
```bash
aws --endpoint-url=http://localhost:4566 logs delete-log-group \
  --log-group-name /myapp/application
```

---

## 🐘 RDS - Relational Database (Real PostgreSQL/MySQL)

### Create PostgreSQL Instance
```bash
aws --endpoint-url=http://localhost:4566 rds create-db-instance \
  --db-instance-identifier mydb \
  --engine postgres \
  --db-instance-class db.t3.micro \
  --master-username admin \
  --master-user-password admin123 \
  --allocated-storage 20
```

### Create MySQL Instance
```bash
aws --endpoint-url=http://localhost:4566 rds create-db-instance \
  --db-instance-identifier mysqldb \
  --engine mysql \
  --db-instance-class db.t3.micro \
  --master-username admin \
  --master-user-password admin123 \
  --allocated-storage 20
```

### List DB Instances
```bash
aws --endpoint-url=http://localhost:4566 rds describe-db-instances
```

### Get DB Endpoint
```bash
aws --endpoint-url=http://localhost:4566 rds describe-db-instances \
  --db-instance-identifier mydb \
  --query 'DBInstances[0].Endpoint'
```

### Connect to PostgreSQL
```bash
psql -h localhost -p 15432 -U admin -d postgres
```

Inside psql:
```sql
CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100));
INSERT INTO users (name) VALUES ('Alice');
SELECT * FROM users;
```

### Connect to MySQL
```bash
mysql -h localhost -P 13306 -u admin -p
# password: admin123
```

Inside mysql:
```sql
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100));
INSERT INTO users (name) VALUES ('Bob');
SELECT * FROM users;
```

### Delete DB Instance
```bash
aws --endpoint-url=http://localhost:4566 rds delete-db-instance \
  --db-instance-identifier mydb \
  --skip-final-snapshot
```

---

## 🔴 ElastiCache - Redis/Memcached

### Create Redis Cluster
```bash
aws --endpoint-url=http://localhost:4566 elasticache create-cache-cluster \
  --cache-cluster-id my-redis \
  --engine redis \
  --cache-node-type cache.t3.micro
```

### Create Memcached Cluster
```bash
aws --endpoint-url=http://localhost:4566 elasticache create-cache-cluster \
  --cache-cluster-id my-memcached \
  --engine memcached \
  --cache-node-type cache.t3.micro \
  --num-cache-nodes 1
```

### List Cache Clusters
```bash
aws --endpoint-url=http://localhost:4566 elasticache describe-cache-clusters
```

### Connect to Redis
```bash
redis-cli -h localhost -p 16379
```

Inside redis-cli:
```bash
PING          # Should return PONG
SET key1 "value1"
GET key1
DEL key1
```

### Connect to Memcached
```bash
apt-get install memcached-tools  # Or: brew install memcached
telnet localhost 11211
```

### Delete Cache Cluster
```bash
aws --endpoint-url=http://localhost:4566 elasticache delete-cache-cluster \
  --cache-cluster-id my-redis
```

---

## 📄 CloudFormation - Infrastructure as Code

### Create Stack from YAML
```bash
cat > template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-cf-bucket
  MyQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: my-cf-queue
Outputs:
  BucketName:
    Value: !Ref MyBucket
  QueueUrl:
    Value: !Ref MyQueue
EOF

aws --endpoint-url=http://localhost:4566 cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml
```

### Describe Stacks
```bash
aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks
```

### Get Stack Outputs
```bash
aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
  --stack-name my-stack \
  --query 'Stacks[0].Outputs'
```

### List Stack Resources
```bash
aws --endpoint-url=http://localhost:4566 cloudformation list-stack-resources \
  --stack-name my-stack
```

### Delete Stack
```bash
aws --endpoint-url=http://localhost:4566 cloudformation delete-stack \
  --stack-name my-stack
```

---

## 🌊 Kinesis - Data Streaming

### Create Stream
```bash
aws --endpoint-url=http://localhost:4566 kinesis create-stream \
  --stream-name my-stream \
  --shard-count 1
```

### List Streams
```bash
aws --endpoint-url=http://localhost:4566 kinesis list-streams
```

### Put Record
```bash
aws --endpoint-url=http://localhost:4566 kinesis put-record \
  --stream-name my-stream \
  --partition-key "user-123" \
  --data "Hello Kinesis"
```

### Put Batch Records
```bash
aws --endpoint-url=http://localhost:4566 kinesis put-records \
  --stream-name my-stream \
  --records '[
    {
      "Data": "Record 1",
      "PartitionKey": "user1"
    },
    {
      "Data": "Record 2",
      "PartitionKey": "user2"
    }
  ]'
```

### Get Shard Iterator
```bash
SHARD_ID=$(aws --endpoint-url=http://localhost:4566 kinesis describe-stream \
  --stream-name my-stream \
  --query 'StreamDescription.Shards[0].ShardId' --output text)

SHARD_ITERATOR=$(aws --endpoint-url=http://localhost:4566 kinesis get-shard-iterator \
  --stream-name my-stream \
  --shard-id $SHARD_ID \
  --shard-iterator-type TRIM_HORIZON \
  --query 'ShardIterator' --output text)

echo $SHARD_ITERATOR
```

### Get Records
```bash
aws --endpoint-url=http://localhost:4566 kinesis get-records \
  --shard-iterator $SHARD_ITERATOR
```

### Delete Stream
```bash
aws --endpoint-url=http://localhost:4566 kinesis delete-stream \
  --stream-name my-stream
```

---

## 🌐 Route53 - DNS

### Create Hosted Zone
```bash
aws --endpoint-url=http://localhost:4566 route53 create-hosted-zone \
  --name example.com \
  --caller-reference $(date +%s)
```

### List Hosted Zones
```bash
aws --endpoint-url=http://localhost:4566 route53 list-hosted-zones
```

### Get Zone ID
```bash
ZONE_ID=$(aws --endpoint-url=http://localhost:4566 route53 list-hosted-zones \
  --query 'HostedZones[0].Id' --output text | cut -d'/' -f3)

echo $ZONE_ID
```

### Create A Record
```bash
aws --endpoint-url=http://localhost:4566 route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "api.example.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "127.0.0.1"}]
      }
    }]
  }'
```

### Create CNAME Record
```bash
aws --endpoint-url=http://localhost:4566 route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "www.example.com",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{"Value": "example.com"}]
      }
    }]
  }'
```

### List Records
```bash
aws --endpoint-url=http://localhost:4566 route53 list-resource-record-sets \
  --hosted-zone-id $ZONE_ID
```

### Delete Record
```bash
aws --endpoint-url=http://localhost:4566 route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "api.example.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "127.0.0.1"}]
      }
    }]
  }'
```

---

## 🔒 Cognito - User Authentication

### Create User Pool
```bash
aws --endpoint-url=http://localhost:4566 cognito-idp create-user-pool \
  --pool-name my-pool
```

### Get User Pool ID
```bash
POOL_ID=$(aws --endpoint-url=http://localhost:4566 cognito-idp list-user-pools \
  --max-results 10 \
  --query 'UserPools[0].Id' --output text)

echo $POOL_ID
```

### Create App Client
```bash
aws --endpoint-url=http://localhost:4566 cognito-idp create-user-pool-client \
  --user-pool-id $POOL_ID \
  --client-name my-app \
  --explicit-auth-flows ADMIN_NO_SRP_AUTH
```

### Create User
```bash
aws --endpoint-url=http://localhost:4566 cognito-idp admin-create-user \
  --user-pool-id $POOL_ID \
  --username alice \
  --message-action SUPPRESS \
  --temporary-password TempPass123!
```

### Set Permanent Password
```bash
aws --endpoint-url=http://localhost:4566 cognito-idp admin-set-user-password \
  --user-pool-id $POOL_ID \
  --username alice \
  --password Password123! \
  --permanent
```

### Authenticate User
```bash
CLIENT_ID=$(aws --endpoint-url=http://localhost:4566 cognito-idp list-user-pool-clients \
  --user-pool-id $POOL_ID \
  --query 'UserPoolClients[0].ClientId' --output text)

aws --endpoint-url=http://localhost:4566 cognito-idp admin-initiate-auth \
  --user-pool-id $POOL_ID \
  --client-id $CLIENT_ID \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=alice,PASSWORD=Password123!
```

### List Users
```bash
aws --endpoint-url=http://localhost:4566 cognito-idp list-users \
  --user-pool-id $POOL_ID
```

---

## 🔑 KMS - Encryption Keys

### Create Key
```bash
aws --endpoint-url=http://localhost:4566 kms create-key \
  --description "My encryption key"
```

### Get Key ID
```bash
KEY_ID=$(aws --endpoint-url=http://localhost:4566 kms list-keys \
  --query 'Keys[0].KeyId' --output text)

echo $KEY_ID
```

### Create Alias
```bash
aws --endpoint-url=http://localhost:4566 kms create-alias \
  --alias-name alias/my-key \
  --target-key-id $KEY_ID
```

### Encrypt Data
```bash
ENCRYPTED=$(aws --endpoint-url=http://localhost:4566 kms encrypt \
  --key-id alias/my-key \
  --plaintext "Hello World" \
  --query 'CiphertextBlob' --output text)

echo $ENCRYPTED
```

### Decrypt Data
```bash
aws --endpoint-url=http://localhost:4566 kms decrypt \
  --ciphertext-blob $ENCRYPTED \
  --query 'Plaintext' --output text | base64 -d
```

---

## 🔄 Step Functions - Workflow Orchestration

### Create State Machine
```bash
cat > state-machine.json << 'EOF'
{
  "Comment": "A simple state machine",
  "StartAt": "ProcessOrder",
  "States": {
    "ProcessOrder": {
      "Type": "Pass",
      "Result": "Order processed successfully",
      "End": true
    }
  }
}
EOF

aws --endpoint-url=http://localhost:4566 stepfunctions create-state-machine \
  --name my-workflow \
  --definition file://state-machine.json \
  --role-arn arn:aws:iam::000000000000:role/step-functions-role
```

### List State Machines
```bash
aws --endpoint-url=http://localhost:4566 stepfunctions list-state-machines
```

### Get State Machine ARN
```bash
STATE_MACHINE_ARN=$(aws --endpoint-url=http://localhost:4566 stepfunctions list-state-machines \
  --query 'stateMachines[0].stateMachineArn' --output text)

echo $STATE_MACHINE_ARN
```

### Start Execution
```bash
aws --endpoint-url=http://localhost:4566 stepfunctions start-execution \
  --state-machine-arn $STATE_MACHINE_ARN \
  --input '{"orderId": "12345", "amount": 100}'
```

### Describe Execution
```bash
aws --endpoint-url=http://localhost:4566 stepfunctions describe-execution \
  --execution-arn arn:aws:states:us-east-1:000000000000:execution:my-workflow:exec123
```

### Get Execution History
```bash
aws --endpoint-url=http://localhost:4566 stepfunctions get-execution-history \
  --execution-arn arn:aws:states:us-east-1:000000000000:execution:my-workflow:exec123
```

---

## 📨 SES - Email Service

### Verify Email
```bash
aws --endpoint-url=http://localhost:4566 ses verify-email-identity \
  --email-address sender@example.com
```

### Send Email
```bash
aws --endpoint-url=http://localhost:4566 ses send-email \
  --from sender@example.com \
  --to recipient@example.com \
  --subject "Hello" \
  --text "This is a test email"
```

### Send Templated Email (After creating template)
```bash
aws --endpoint-url=http://localhost:4566 ses send-templated-email \
  --from sender@example.com \
  --to recipient@example.com \
  --template my-template \
  --template-data '{"name": "Alice"}'
```

### List Verified Emails
```bash
aws --endpoint-url=http://localhost:4566 ses list-verified-email-addresses
```

---

## ✉️ EventBridge - Event Bus

### Create Event Bus
```bash
aws --endpoint-url=http://localhost:4566 events create-event-bus \
  --name my-bus
```

### Put Rule
```bash
aws --endpoint-url=http://localhost:4566 events put-rule \
  --name order-rule \
  --event-bus-name my-bus \
  --event-pattern '{
    "source": ["myapp"],
    "detail-type": ["Order Placed"]
  }' \
  --state ENABLED
```

### Add Lambda Target
```bash
aws --endpoint-url=http://localhost:4566 events put-targets \
  --rule order-rule \
  --event-bus-name my-bus \
  --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:000000000000:function:my-function"
```

### Put Event
```bash
aws --endpoint-url=http://localhost:4566 events put-events \
  --entries '[{
    "Source": "myapp",
    "DetailType": "Order Placed",
    "Detail": "{\"orderId\": \"123\", \"amount\": 100}",
    "EventBusName": "my-bus"
  }]'
```

### List Rules
```bash
aws --endpoint-url=http://localhost:4566 events list-rules \
  --event-bus-name my-bus
```

---

## 🎯 SSM Parameter Store - Configuration

### Put Parameter
```bash
aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name /myapp/database/host \
  --value localhost \
  --type String

aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name /myapp/database/password \
  --value "SecurePass123!" \
  --type SecureString
```

### Get Parameter
```bash
aws --endpoint-url=http://localhost:4566 ssm get-parameter \
  --name /myapp/database/host

aws --endpoint-url=http://localhost:4566 ssm get-parameter \
  --name /myapp/database/password \
  --with-decryption
```

### Get Parameters by Path
```bash
aws --endpoint-url=http://localhost:4566 ssm get-parameters-by-path \
  --path /myapp/database \
  --recursive
```

### List Parameters
```bash
aws --endpoint-url=http://localhost:4566 ssm describe-parameters
```

### Delete Parameter
```bash
aws --endpoint-url=http://localhost:4566 ssm delete-parameter \
  --name /myapp/database/host
```

---

## 🎮 EC2 - Compute (Virtual Machines)

### Describe Instances
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

### Create Security Group
```bash
aws --endpoint-url=http://localhost:4566 ec2 create-security-group \
  --group-name my-sg \
  --description "My security group"
```

### List Security Groups
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups
```

### Authorize Ingress
```bash
aws --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress \
  --group-id sg-12345 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

---

## 📦 ECR - Container Registry

### Create Repository
```bash
aws --endpoint-url=http://localhost:4566 ecr create-repository \
  --repository-name my-app
```

### List Repositories
```bash
aws --endpoint-url=http://localhost:4566 ecr describe-repositories
```

### Push Image (Tag & Push)
```bash
# First tag your image
docker tag my-local-image:latest localhost:4566/my-app:latest

# Login to ECR (LocalStack)
aws --endpoint-url=http://localhost:4566 ecr get-login-password | \
  docker login --username AWS --password-stdin localhost:4566

# Push
docker push localhost:4566/my-app:latest
```

### List Images
```bash
aws --endpoint-url=http://localhost:4566 ecr describe-images \
  --repository-name my-app
```

---

## 🐳 ECS - Container Orchestration

### Create Cluster
```bash
aws --endpoint-url=http://localhost:4566 ecs create-cluster \
  --cluster-name my-cluster
```

### Register Task Definition
```bash
cat > task-def.json << 'EOF'
{
  "family": "my-task",
  "containerDefinitions": [
    {
      "name": "my-container",
      "image": "nginx",
      "memory": 512,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
}
EOF

aws --endpoint-url=http://localhost:4566 ecs register-task-definition \
  --cli-input-json file://task-def.json
```

### Run Task
```bash
aws --endpoint-url=http://localhost:4566 ecs run-task \
  --cluster my-cluster \
  --task-definition my-task:1 \
  --launch-type EC2
```

---

## 🏥 Health Check

### Check All Services
```bash
curl -s http://localhost:4566/_localstack/health | jq '.services | keys'
```

### Check Specific Service Status
```bash
curl -s http://localhost:4566/_localstack/health | jq '.services.s3'
curl -s http://localhost:4566/_localstack/health | jq '.services.lambda'
```

---

## 💡 Pro Tips

### Save Endpoint as Alias
```bash
echo 'export AWS_ENDPOINT_URL=http://localhost:4566' >> ~/.zshrc
source ~/.zshrc

# Now you can use shorter commands
aws s3 ls
aws dynamodb list-tables
```

### Use JSON Output for Scripting
```bash
aws --endpoint-url=http://localhost:4566 s3api list-buckets --query 'Buckets[].Name' --output text
```

### Format Output with jq
```bash
aws --endpoint-url=http://localhost:4566 s3api list-buckets | jq '.Buckets[] | {Name: .Name, CreationDate: .CreationDate}'
```

### Disable Pagination
```bash
export AWS_PAGER=""
```

### Get Help
```bash
aws --endpoint-url=http://localhost:4566 s3 help
aws --endpoint-url=http://localhost:4566 dynamodb help create-table
```
