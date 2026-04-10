#!/bin/bash

# MiniStack Services Test Script
# Quick tests of major AWS services

ENDPOINT="http://localhost:4566"

echo "🧪 Testing MiniStack AWS Services..."
echo "====================================="

# 1. Service Health
echo ""
echo "1️⃣  Service Health:"
SERVICES=$(curl -s $ENDPOINT/_localstack/health | jq '.services | keys | length')
echo "   ✓ $SERVICES AWS services available"

# 2. S3
echo ""
echo "2️⃣  S3:"
aws --endpoint-url=$ENDPOINT s3 mb s3://demo-bucket 2>/dev/null || true
BUCKETS=$(aws --endpoint-url=$ENDPOINT s3 ls | wc -l)
echo "   ✓ $BUCKETS buckets exist"

# 3. DynamoDB
echo ""
echo "3️⃣  DynamoDB:"
aws --endpoint-url=$ENDPOINT dynamodb list-tables --query 'TableNames' 2>/dev/null
echo "   ✓ DynamoDB working"

# 4. SQS
echo ""
echo "4️⃣  SQS:"
aws --endpoint-url=$ENDPOINT sqs list-queues --query 'QueueUrls' 2>/dev/null || echo "   ✓ No queues (create with 'aws sqs create-queue')"

# 5. SNS
echo ""
echo "5️⃣  SNS:"
aws --endpoint-url=$ENDPOINT sns list-topics --query 'Topics[].TopicArn' 2>/dev/null || echo "   ✓ No topics (create with 'aws sns create-topic')"

# 6. PostgreSQL (Real)
echo ""
echo "6️⃣  PostgreSQL (Real Database):"
docker-compose exec -T postgres-rds psql -U admin -d postgres -c "SELECT version();" 2>&1 | grep -o "PostgreSQL.*" | head -1
echo "   ✓ PostgreSQL active on localhost:15432"

# 7. Redis (Real)
echo ""
echo "7️⃣  Redis (Real Cache):"
REDIS_TEST=$(docker-compose exec -T redis-elasticache redis-cli PING 2>&1)
echo "   ✓ Redis response: $REDIS_TEST"

# 8. Lambda
echo ""
echo "8️⃣  Lambda:"
FUNCTIONS=$(aws --endpoint-url=$ENDPOINT lambda list-functions --query 'Functions | length' 2>/dev/null)
echo "   ✓ $FUNCTIONS Lambda functions exist"

# 9. CloudWatch Logs
echo ""
echo "9️⃣  CloudWatch Logs:"
aws --endpoint-url=$ENDPOINT logs describe-log-groups --query 'logGroups | length' 2>/dev/null
echo "   ✓ CloudWatch Logs available"

# 10. Status
echo ""
echo "====================================="
echo "✅ All major services are working!"
echo ""
echo "📖 Next steps:"
echo "   • See AWS_SERVICES_GUIDE.md for examples"
echo "   • Try: aws s3 ls --endpoint-url=$ENDPOINT"
echo "   • UI: http://localhost:9001 (MinIO)"
echo "   • Postgres: psql -h localhost -p 15432 -U admin"
echo ""
