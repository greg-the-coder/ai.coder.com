# Rotate Key

The following Docker image is used to rotate out secrets in AWS Secrets manager and Kubernetes.

This is to be used until the platform matures and be replaced by the K8s `Secrets Store CSI Driver`

## Pushing `rotate-key:ubuntu-noble`

To login

```bash
aws ecr get-login-password --region <Region> --profile demo-coder | docker login --username AWS --password-stdin <AccountId>.dkr.ecr.<Region>.amazonaws.com
```

Commands to run

```bash
docker build --platform=linux/amd64 -f Dockerfile.noble -t <AccountId>.dkr.ecr.<Region>.amazonaws.com/rotate-key:ubuntu-noble --no-cache .
docker push <AccountId>.dkr.ecr.<Region>.amazonaws.com/rotate-key:ubuntu-noble
```

## Troubleshooting

If you get a `404 Not Found`, it possibly means that you either:

1. Don't have access to the image repository in ECR. Make sure to check your permissions (IAM User, Role, etc.) and the repository's permissions on the [ECR console](https://<Region>.console.aws.amazon.com/ecr/private-registry/repositories).

2. The repository doesn't exist. Image's name before the tag is the image repository's name: `<AWSAccountID>.dkr.ecr.<Region>.amazonaws.com/<RepositoryName>:<ImageTag>`
