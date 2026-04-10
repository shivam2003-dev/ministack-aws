# AWS CLI Quick Reference (for MiniStack)

Set endpoint first:
```bash
export AWS_ENDPOINT_URL=http://localhost:4566
```

## S3 - Object Storage
```bash
aws s3 mb s3://bucket-name              # Create bucket
aws s3 ls                               # List buckets
aws s3 ls s3://bucket-name              # List objects
aws s3 cp file.txt s3://bucket-name/    # Upload
aws s3 cp s3://bucket-name/file.txt .   # Download
aws s3 rm s3://bucket-name/file.txt     # Delete object
aws s3 rb s3://bucket-name              # Delete bucket
```

## DynamoDB - NoSQL Database
```bash
aws dynamodb create-table \
  --table-name Users \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

aws dynamodb put-item \
  --table-name Users \
  --item '{"id":{"S":"user1"},"name":{"S":"Alice"}}'

aws dynamodb get-item \
  --table-name Users \
  --key '{"id":{"S":"user1"}}'

aws dynamodb scan --table-name Users

aws dynamodb delete-table --table-name Users
```

## SQS - Message Queue
```bash
aws sqs create-queue --queue-name my-queue

QUEUE_URL=$(aws sqs get-queue-url --queue-name my-queue --query 'QueueUrl' --output text)

aws sqs send-message --queue-url $QUEUE_URL --message-body "Hello"

aws sqs receive-message --queue-url $QUEUE_URL

aws sqs delete-queue --queue-url $QUEUE_URL
```

## SNS - Pub/Sub
```bash
aws sns create-topic --name my-topic

TOPIC_ARN=$(aws sns list-topics --query 'Topics[0].TopicArn' --output text)

aws sns publish --topic-arn $TOPIC_ARN --message "Hello SNS"

aws sns delete-topic --topic-arn $TOPIC_ARN
```

## Lambda - Serverless Functions
```bash
# Create function
zip lambda.zip lambda.py
aws lambda create-function \
  --function-name my-func \
  --runtime python3.11 \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --handler lambda.handler \
  --zip-file fileb://lambda.zip

# Invoke
aws lambda invoke \
  --function-name my-func \
  --payload '{"key":"value"}' \
  response.json

# List
aws lambda list-functions

# Delete
aws lambda delete-function --function-name my-func
```

## IAM - Users & Roles
```bash
# Create user
aws iam create-user --user-name alice

# Create role
aws iam create-role \
  --role-name my-role \
  --assume-role-policy-document file://trust-policy.json

# Attach policy
aws iam attach-role-policy \
  --role-name my-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# List
aws iam list-users
aws iam list-roles
```

## RDS - Relational Database
```bash
# Create instance
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --engine postgres \
  --master-username admin \
  --master-user-password secret123

# Describe
aws rds describe-db-instances

# Delete
aws rds delete-db-instance --db-instance-identifier mydb
```

## ElastiCache - Redis/Memcached
```bash
# Create cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id my-redis \
  --engine redis \
  --cache-node-type cache.t3.micro

# Describe
aws elasticache describe-cache-clusters

# Delete
aws elasticache delete-cache-cluster --cache-cluster-id my-redis
```

## EC2 - Virtual Machines
```bash
# Describe instances
aws ec2 describe-instances

# Create security group
aws ec2 create-security-group \
  --group-name my-sg \
  --description "My security group"

# List security groups
aws ec2 describe-security-groups
```

## CloudWatch Logs
```bash
# Create log group
aws logs create-log-group --log-group-name /myapp

# Put log events
aws logs put-log-events \
  --log-group-name /myapp \
  --log-stream-name stream1 \
  --log-events timestamp=$(date +%s000),message="test"

# Query
aws logs describe-log-groups
```

## Secrets Manager
```bash
# Create secret
aws secretsmanager create-secret \
  --name my-secret \
  --secret-string '{"username":"admin","password":"secret"}'

# Get secret
aws secretsmanager get-secret-value --secret-id my-secret

# Delete
aws secretsmanager delete-secret --secret-id my-secret
```

## SSM Parameter Store
```bash
# Put parameter
aws ssm put-parameter \
  --name /myapp/db-host \
  --value localhost \
  --type String

# Get parameter
aws ssm get-parameter --name /myapp/db-host

# List parameters
aws ssm describe-parameters
```

## Step Functions - Workflows
```bash
# Create state machine
aws stepfunctions create-state-machine \
  --name my-workflow \
  --definition file://state-machine.json \
  --role-arn arn:aws:iam::000000000000:role/step-functions-role

# Start execution
aws stepfunctions start-execution \
  --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:my-workflow \
  --input '{"name":"Alice"}'

# List
aws stepfunctions list-state-machines
```

## CloudFormation - Infrastructure as Code
```bash
# Create stack
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml

# Describe stacks
aws cloudformation describe-stacks

# Delete stack
aws cloudformation delete-stack --stack-name my-stack
```

## Health Check
```bash
# Check all services
curl http://localhost:4566/_localstack/health | jq '.services | keys'

# Count available services
curl http://localhost:4566/_localstack/health | jq '.services | keys | length'
```

---

**Pro Tips:**
- Save frequently used commands as bash functions
- Use `--query` to filter output: `aws s3 ls --query 'Buckets[].Name'`
- Add `jq` for JSON pretty-printing: `| jq '.'`
- Set `AWS_PAGER=""` to disable paging: `export AWS_PAGER=""`
- Most commands support `--output json|text|table`
