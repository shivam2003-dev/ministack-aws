# MiniStack AWS Services Complete Guide

## 🚀 Quick Start

```bash
# Start all services
docker-compose up -d

# Verify health
curl http://localhost:4566/_localstack/health | jq '.services'

# Set endpoint alias (optional)
export AWS_ENDPOINT_URL=http://localhost:4566
```

---

## 📋 All Available Services

### 🪣 **S3** - Object Storage
```bash
# Create bucket
aws s3 mb s3://my-bucket

# List buckets
aws s3 ls

# Upload file
echo "hello" > test.txt
aws s3 cp test.txt s3://my-bucket/

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket my-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# List with versions
aws s3api list-object-versions --bucket my-bucket

# Set lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket \
  --lifecycle-configuration '{
    "Rules": [{
      "ID": "archive-rule",
      "Status": "Enabled",
      "Transitions": [{"Days": 30, "StorageClass": "GLACIER"}]
    }]
  }'
```

**UI**: http://localhost:9001 (MinIO Console)

---

### 📨 **SQS** - Message Queues

```bash
# Create queue
aws sqs create-queue --queue-name my-queue
# Returns: QueueUrl

# Create FIFO queue
aws sqs create-queue \
  --queue-name my-queue.fifo \
  --attributes FifoQueue=true

# Send message
aws sqs send-message \
  --queue-url https://localhost:4566/000000000000/my-queue \
  --message-body "Hello SQS"

# Send batch
aws sqs send-message-batch \
  --queue-url https://localhost:4566/000000000000/my-queue \
  --entries '[
    {"Id": "1", "MessageBody": "Msg 1"},
    {"Id": "2", "MessageBody": "Msg 2"}
  ]'

# Receive messages
aws sqs receive-message \
  --queue-url https://localhost:4566/000000000000/my-queue \
  --max-number-of-messages 10

# Delete message
aws sqs delete-message \
  --queue-url https://localhost:4566/000000000000/my-queue \
  --receipt-handle <ReceiptHandle>

# Create DLQ
aws sqs create-queue --queue-name my-dlq
aws sqs set-queue-attributes \
  --queue-url https://localhost:4566/000000000000/my-queue \
  --attributes '{
    "RedrivePolicy": "{\"deadLetterTargetArn\": \"arn:aws:sqs:us-east-1:000000000000:my-dlq\", \"maxReceiveCount\": \"3\"}"
  }'
```

---

### 📢 **SNS** - Pub/Sub Messaging

```bash
# Create topic
aws sns create-topic --name my-topic
# Returns: TopicArn

# Publish message
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic \
  --message "Hello SNS"

# Create subscription
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:us-east-1:000000000000:my-queue

# Publish with attributes
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic \
  --message "Alert" \
  --message-attributes '{
    "severity": {"DataType": "String", "StringValue": "high"}
  }'

# Set topic attributes
aws sns set-topic-attributes \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-topic \
  --attribute-name DisplayName \
  --attribute-value "My Topic"
```

---

### 🗃️ **DynamoDB** - NoSQL Database

```bash
# Create table
aws dynamodb create-table \
  --table-name Users \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Put item
aws dynamodb put-item \
  --table-name Users \
  --item '{
    "id": {"S": "user123"},
    "name": {"S": "John"},
    "age": {"N": "30"}
  }'

# Get item
aws dynamodb get-item \
  --table-name Users \
  --key '{"id": {"S": "user123"}}'

# Query
aws dynamodb query \
  --table-name Users \
  --key-condition-expression "id = :id" \
  --expression-attribute-values '{":id": {"S": "user123"}}'

# Scan
aws dynamodb scan --table-name Users

# Update item
aws dynamodb update-item \
  --table-name Users \
  --key '{"id": {"S": "user123"}}' \
  --update-expression "SET #n = :val" \
  --expression-attribute-names '{"#n": "name"}' \
  --expression-attribute-values '{":val": {"S": "Jane"}}'

# Delete item
aws dynamodb delete-item \
  --table-name Users \
  --key '{"id": {"S": "user123"}}'

# Enable TTL
aws dynamodb update-time-to-live \
  --table-name Users \
  --time-to-live-specification AttributeName=expireAt,Enabled=true

# Create GSI
aws dynamodb update-table \
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

# Transactions
aws dynamodb transact-write-items \
  --transact-items '[{
    "Put": {
      "TableName": "Users",
      "Item": {"id": {"S": "user456"}, "name": {"S": "Alice"}}
    }
  }]'
```

---

### ⚡ **Lambda** - Serverless Functions

```bash
# Create function (Python)
cat > lambda_function.py << 'EOF'
def handler(event, context):
    return {
        'statusCode': 200,
        'body': f'Hello {event.get("name", "World")}'
    }
EOF

zip lambda_function.zip lambda_function.py

aws lambda create-function \
  --function-name my-function \
  --runtime python3.11 \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --handler lambda_function.handler \
  --zip-file fileb://lambda_function.zip

# Invoke synchronously
aws lambda invoke \
  --function-name my-function \
  --payload '{"name": "Alice"}' \
  response.json
cat response.json

# Invoke asynchronously
aws lambda invoke \
  --function-name my-function \
  --invocation-type Event \
  --payload '{"name": "Bob"}' \
  response.json

# List functions
aws lambda list-functions

# Update function code
aws lambda update-function-code \
  --function-name my-function \
  --zip-file fileb://lambda_function.zip

# Set environment variables
aws lambda update-function-configuration \
  --function-name my-function \
  --environment Variables="{DB_HOST=localhost,DB_PORT=5432}"

# Create layer
zip layer.zip -r python
aws lambda publish-layer-version \
  --layer-name my-layer \
  --description "My layer" \
  --zip-file fileb://layer.zip

# Add layer to function
aws lambda update-function-configuration \
  --function-name my-function \
  --layers arn:aws:lambda:us-east-1:000000000000:layer:my-layer:1

# Create event source mapping (SQS -> Lambda)
aws lambda create-event-source-mapping \
  --event-source-arn arn:aws:sqs:us-east-1:000000000000:my-queue \
  --function-name my-function \
  --batch-size 10
```

---

### 🔐 **IAM** - Identity & Access Management

```bash
# Create user
aws iam create-user --user-name alice
aws iam create-user --user-name bob

# Create role
aws iam create-role \
  --role-name lambda-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach policy
aws iam attach-role-policy \
  --role-name lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Create policy
aws iam create-policy \
  --policy-name s3-access \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }]
  }'

# Attach policy to user
aws iam attach-user-policy \
  --user-name alice \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Get user
aws iam get-user --user-name alice

# List users
aws iam list-users

# Delete user
aws iam delete-user --user-name bob
```

---

### 🎫 **STS** - Security Token Service

```bash
# Get caller identity
aws sts get-caller-identity

# Assume role
aws sts assume-role \
  --role-arn arn:aws:iam::000000000000:role/my-role \
  --role-session-name session-name

# Get session token
aws sts get-session-token \
  --duration-seconds 3600
```

---

### 🔑 **Secrets Manager** - Secret Storage

```bash
# Create secret
aws secretsmanager create-secret \
  --name my-secret \
  --secret-string '{"username": "admin", "password": "secret123"}'

# Get secret
aws secretsmanager get-secret-value --secret-id my-secret

# Update secret
aws secretsmanager update-secret \
  --secret-id my-secret \
  --secret-string '{"username": "admin", "password": "newsecret456"}'

# Rotate secret
aws secretsmanager rotate-secret \
  --secret-id my-secret \
  --rotation-lambda-arn arn:aws:lambda:us-east-1:000000000000:function:rotate

# List secrets
aws secretsmanager list-secrets

# Delete secret
aws secretsmanager delete-secret --secret-id my-secret
```

---

### 📊 **CloudWatch Logs** - Logging

```bash
# Create log group
aws logs create-log-group --log-group-name /aws/lambda/my-function

# Put log events
aws logs put-log-events \
  --log-group-name /aws/lambda/my-function \
  --log-stream-name stream1 \
  --log-events timestamp=$(date +%s000),message="Application started"

# Describe log groups
aws logs describe-log-groups

# Set retention
aws logs put-retention-policy \
  --log-group-name /aws/lambda/my-function \
  --retention-in-days 7

# Filter logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/my-function \
  --filter-pattern "ERROR"

# Create subscription filter (send to Lambda)
aws logs put-subscription-filter \
  --log-group-name /aws/lambda/my-function \
  --filter-name my-filter \
  --filter-pattern "" \
  --destination-arn arn:aws:lambda:us-east-1:000000000000:function:log-processor
```

---

### 🐘 **RDS** - Relational Database

```bash
# Create DB instance (Real PostgreSQL)
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --engine postgres \
  --db-instance-class db.t3.micro \
  --master-username admin \
  --master-user-password admin123 \
  --allocated-storage 20

# Create DB instance (MySQL)
aws rds create-db-instance \
  --db-instance-identifier mysqldb \
  --engine mysql \
  --db-instance-class db.t3.micro \
  --master-username admin \
  --master-user-password admin123

# Describe instances
aws rds describe-db-instances

# Get endpoint
aws rds describe-db-instances \
  --db-instance-identifier mydb \
  --query 'DBInstances[0].Endpoint'

# Connect to PostgreSQL
psql -h localhost -p 15432 -U admin -d postgres

# Delete instance
aws rds delete-db-instance \
  --db-instance-identifier mydb \
  --skip-final-snapshot
```

**Connection Details:**
- Host: `localhost`
- Port: `15432` (PostgreSQL) or `13306` (MySQL)
- User: `admin`
- Password: See your create command

---

### 🔴 **ElastiCache** - Redis/Memcached

```bash
# Create Redis cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id my-redis \
  --engine redis \
  --cache-node-type cache.t3.micro

# Create Memcached cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id my-memcached \
  --engine memcached \
  --cache-node-type cache.t3.micro \
  --num-cache-nodes 1

# Describe clusters
aws elasticache describe-cache-clusters

# Connect to Redis CLI
redis-cli -h localhost -p 16379

# Test Redis
redis-cli -h localhost -p 16379 ping  # PONG

# Set/Get
redis-cli -h localhost -p 16379 SET key "value"
redis-cli -h localhost -p 16379 GET key

# Delete cluster
aws elasticache delete-cache-cluster \
  --cache-cluster-id my-redis
```

**Connection Details:**
- Host: `localhost`
- Port: `16379` (Redis) or `11211` (Memcached)

---

### 📢 **API Gateway** - REST APIs

```bash
# Create REST API
aws apigateway create-rest-api \
  --name my-api \
  --description "My API"

# Get APIs
aws apigateway get-rest-apis

# Get API ID
API_ID=$(aws apigateway get-rest-apis --query 'items[0].id' --output text)

# Get root resource
ROOT_ID=$(aws apigateway get-resources --rest-api-id $API_ID --query 'items[0].id' --output text)

# Create resource
aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part users

# Create method
aws apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $ROOT_ID \
  --http-method GET \
  --authorization-type NONE

# Create integration (Lambda)
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $ROOT_ID \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:my-function/invocations

# Deploy API
aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name prod

# Test endpoint
curl https://localhost:4566/restapis/$API_ID/prod/_user_request_/
```

---

### ⚡ **Step Functions** - Workflow Orchestration

```bash
# Create state machine
cat > state-machine.json << 'EOF'
{
  "Comment": "My state machine",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Pass",
      "Result": "Hello World!",
      "End": true
    }
  }
}
EOF

aws stepfunctions create-state-machine \
  --name my-state-machine \
  --definition file://state-machine.json \
  --role-arn arn:aws:iam::000000000000:role/step-functions-role

# Describe state machines
aws stepfunctions list-state-machines

# Start execution
aws stepfunctions start-execution \
  --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:my-state-machine \
  --input '{"name": "Alice"}'

# Describe execution
aws stepfunctions describe-execution \
  --execution-arn arn:aws:states:us-east-1:000000000000:execution:my-state-machine:exec1
```

---

### 🚌 **EventBridge** - Event Bus

```bash
# Create event bus
aws events create-event-bus --name my-bus

# Put rule
aws events put-rule \
  --name my-rule \
  --event-bus-name my-bus \
  --event-pattern '{
    "source": ["myapp"],
    "detail-type": ["order"]
  }' \
  --state ENABLED

# Add Lambda target
aws events put-targets \
  --rule my-rule \
  --event-bus-name my-bus \
  --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:000000000000:function:my-function"

# Put event
aws events put-events \
  --entries '[{
    "Source": "myapp",
    "DetailType": "order",
    "Detail": "{\"order_id\": \"123\", \"amount\": 100}",
    "EventBusName": "my-bus"
  }]'
```

---

### 🌊 **Kinesis** - Streaming

```bash
# Create stream
aws kinesis create-stream \
  --stream-name my-stream \
  --shard-count 1

# Put record
aws kinesis put-record \
  --stream-name my-stream \
  --partition-key "user-123" \
  --data "Hello Kinesis"

# Get shard iterator
SHARD_ID=$(aws kinesis describe-stream --stream-name my-stream --query 'StreamDescription.Shards[0].ShardId' --output text)

SHARD_ITERATOR=$(aws kinesis get-shard-iterator \
  --stream-name my-stream \
  --shard-id $SHARD_ID \
  --shard-iterator-type TRIM_HORIZON \
  --query 'ShardIterator' --output text)

# Get records
aws kinesis get-records --shard-iterator $SHARD_ITERATOR
```

---

### 🌐 **Route53** - DNS

```bash
# Create hosted zone
aws route53 create-hosted-zone \
  --name example.com \
  --caller-reference $(date +%s)

# List hosted zones
aws route53 list-hosted-zones

# Get zone ID
ZONE_ID=$(aws route53 list-hosted-zones --query 'HostedZones[0].Id' --output text)

# Create record
aws route53 change-resource-record-sets \
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

# Query records
aws route53 list-resource-record-sets \
  --hosted-zone-id $ZONE_ID
```

---

### 🔒 **Cognito** - Authentication

```bash
# Create user pool
aws cognito-idp create-user-pool --pool-name my-pool

# Get pool ID
POOL_ID=$(aws cognito-idp list-user-pools --max-results 10 --query 'UserPools[0].Id' --output text)

# Create user pool client
aws cognito-idp create-user-pool-client \
  --user-pool-id $POOL_ID \
  --client-name my-client \
  --explicit-auth-flows ADMIN_NO_SRP_AUTH

# Create user
aws cognito-idp admin-create-user \
  --user-pool-id $POOL_ID \
  --username alice \
  --message-action SUPPRESS \
  --temporary-password TempPassword123!

# Set permanent password
aws cognito-idp admin-set-user-password \
  --user-pool-id $POOL_ID \
  --username alice \
  --password Password123! \
  --permanent

# Initiate auth
aws cognito-idp admin-initiate-auth \
  --user-pool-id $POOL_ID \
  --client-id <CLIENT_ID> \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=alice,PASSWORD=Password123!
```

---

### 🔑 **KMS** - Key Management

```bash
# Create key
aws kms create-key --description "My key"

# Get key ID
KEY_ID=$(aws kms list-keys --query 'Keys[0].KeyId' --output text)

# Create alias
aws kms create-alias --alias-name alias/my-key --target-key-id $KEY_ID

# Encrypt data
aws kms encrypt \
  --key-id $KEY_ID \
  --plaintext "Hello World" \
  --query 'CiphertextBlob' --output text

# Decrypt data
aws kms decrypt \
  --ciphertext-blob <BASE64_CIPHERTEXT> \
  --query 'Plaintext' --output text
```

---

## 🔧 Environment Setup

### Set AWS Credentials (Optional)
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566
```

### Or use AWS CLI config
```bash
aws configure
# Access Key ID: test
# Secret Access Key: test
# Default region: us-east-1
```

---

## 📊 Health & Monitoring

### Check Service Health
```bash
curl http://localhost:4566/_localstack/health | jq '.services'
```

### View Logs
```bash
docker-compose logs -f ministack

# Specific service
docker-compose logs -f postgres-rds
docker-compose logs -f redis-elasticache
```

### Stop Services
```bash
docker-compose down

# With cleanup
docker-compose down --remove-orphans -v
```

---

## 🎯 Real Infrastructure Benefits

- **RDS**: Actual PostgreSQL/MySQL database - test real SQL queries, transactions, triggers
- **ElastiCache**: Real Redis/Memcached - test caching patterns, pub/sub
- **ECS**: Real Docker containers - test container orchestration
- **S3**: Full S3 API support - versioning, encryption, lifecycle policies, replication

---

## 🐛 Troubleshooting

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart ministack

# Clean rebuild
docker-compose down --remove-orphans -v
docker-compose up -d

# Check connectivity
curl -v http://localhost:4566/_localstack/health
curl -v http://localhost:9001  # MinIO
psql -h localhost -p 15432 -U admin -d postgres -c "SELECT 1"
redis-cli -h localhost -p 16379 ping
```

---

## 📚 External Resources

- [MiniStack GitHub](https://github.com/nahuelnucera/ministack)
- [LocalStack Docs](https://docs.localstack.cloud/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/)
- [DuckDB (for Athena)](https://duckdb.org/)
