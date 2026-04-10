# MiniStack AWS - Complete Local AWS Environment

A complete, production-like AWS testing environment with real infrastructure. Includes 40+ AWS services with actual databases, caches, and a web UI.

## 🚀 Quick Start

```bash
# Start everything
docker-compose up -d

# Verify services
curl http://localhost:4566/_localstack/health | jq '.services | keys'

# Try S3
aws s3 mb s3://test-bucket --endpoint-url=http://localhost:4566
aws s3 ls --endpoint-url=http://localhost:4566
```

## 🎯 Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| **MiniStack API** | `http://localhost:4566` | All AWS services (S3, Lambda, DynamoDB, etc.) |
| **MinIO Console** | `http://localhost:9001` | Visual S3 bucket browser |
| **PostgreSQL (RDS)** | `localhost:15432` | Real database (user: `admin`, pwd: `admin123`) |
| **Redis (ElastiCache)** | `localhost:16379` | Real Redis cache |

## 📚 Complete Service Guide

👉 **See [AWS_SERVICES_GUIDE.md](AWS_SERVICES_GUIDE.md)** for comprehensive examples of all 40+ AWS services including:

- **Storage**: S3 (buckets, versioning, encryption, lifecycle, replication)
- **Messaging**: SQS, SNS (queues, topics, subscriptions, DLQ)
- **Databases**: DynamoDB (CRUD, queries, transactions, TTL, GSI), RDS (Postgres, MySQL)
- **Cache**: ElastiCache (Redis, Memcached)
- **Compute**: Lambda (functions, layers, event source mapping), ECS (task execution)
- **Orchestration**: Step Functions (state machines), EventBridge (event bus)
- **Streaming**: Kinesis (shards, records)
- **APIs**: API Gateway (REST, HTTP), AppSync (GraphQL)
- **Security**: IAM, STS, Cognito, KMS, Secrets Manager, ACM, WAF
- **Logging**: CloudWatch Logs, CloudWatch Metrics, SSM Parameter Store
- **Routing/DNS**: Route53, CloudFront
- **Deployment**: CloudFormation
- **Advanced**: Glue, Athena, Firehose, SES

## 🔧 Prerequisites

- Docker & Docker Compose
- AWS CLI (optional, for commands)

## 📋 Quick Commands

### Set Endpoint (One-time)
```bash
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

### S3 Examples
```bash
aws s3 mb s3://my-bucket
aws s3 ls
aws s3 cp myfile.txt s3://my-bucket/
```

### Connect to Real Database
```bash
# PostgreSQL (RDS)
psql -h localhost -p 15432 -U admin -d postgres

# MySQL (if created)
mysql -h localhost -P 13306 -u admin -p
```

### Connect to Redis
```bash
redis-cli -h localhost -p 16379
redis-cli -h localhost -p 16379 PING
```

### Browse S3 via Web UI
Open http://localhost:9001 (no login required)

## 🛑 Stop & Cleanup

```bash
# Stop
docker-compose down

# Stop + remove all volumes
docker-compose down -v

# Clean orphaned containers
docker-compose down --remove-orphans -v
```

## 📊 Architecture

```
MiniStack (All 40+ AWS Services in 1 Container)
├── S3, SQS, SNS, DynamoDB, Lambda, IAM, Cognito
├── API Gateway, Step Functions, EventBridge, Route53
├── CloudWatch, CloudFormation, KMS, Secrets Manager
└── +20 more services

Real Infrastructure
├── PostgreSQL (for RDS)
├── Redis (for ElastiCache)
└── (Docker can run ECS tasks)

UIs
├── MinIO Console (S3 Browser) :9001
└── LocalStack Dashboard :4571
```

## 🐛 Troubleshooting

**Port already in use?**
```bash
lsof -i :4566  # Find what's using it
# Edit docker-compose.yml and change port mapping
```

**Services won't start?**
```bash
docker-compose logs ministack
docker-compose logs postgres-rds
docker-compose logs redis-elasticache
```

**Connection errors?**
```bash
# Make sure RDS/Redis start before MiniStack
docker-compose up -d postgres-rds redis-elasticache
docker-compose up -d ministack
```

**AWS CLI returning wrong endpoint?**
```bash
# Always specify endpoint explicitly
aws --endpoint-url=http://localhost:4566 s3 ls
```

## 📚 Resources

- [Comprehensive AWS Services Guide](AWS_SERVICES_GUIDE.md) - Examples for all 40+ services
- [MiniStack GitHub](https://github.com/nahuelnucera/ministack)
- [LocalStack Docs](https://docs.localstack.cloud/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/)

## ✅ What's Included

✅ **40+ AWS Services** - S3, Lambda, DynamoDB, RDS, ElastiCache, API Gateway, Step Functions, and more  
✅ **Real Databases** - PostgreSQL, MySQL containers running actual database engines  
✅ **Real Cache** - Redis, Memcached containers for actual caching  
✅ **Real Container Runtime** - ECS can start actual Docker containers  
✅ **Web UIs** - MinIO for S3, LocalStack Dashboard  
✅ **Persistent Storage** - Docker volumes preserve data  
✅ **Production-like** - Use same AWS CLI/SDK as production  

Perfect for:
- Local AWS development without cloud costs
- Integration testing with real services
- Learning AWS architecture patterns
- Testing CI/CD pipelines locally
- Ensuring reproducible builds and tests

---

**Start now:**
```bash
docker-compose up -d
curl http://localhost:4566/_localstack/health | jq
```
