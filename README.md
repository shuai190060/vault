# DevOps playground to deploy and test app

The idea is to have a playground to deploy and test app the common DevOps tools, so that you can have:
![alt diagram](https://github.com/shuai190060/vault/blob/main/pic/brief.png)

- CI/CD, automate the deployment with `ArgoCD` and `GitHub actions`
- Metrics, monitor cpu, memory and other metrics with `prometheus`
- Flexibility, scale nodes up and down with `karpenter`
- Security,
    - Transfer, expose service with https via `cert-manager`(Letsencrypt)
    - Secrets, secret ingestion via `Vault`
- Logging, collect container logs with `Fluent-bit`, and ship it to cloudwatch
- Analysis, send logs to `AWS Elasticsearch domain` for filter and analysis
- Service, expose app, prometheus, grafana to *.shuhai.de domain via `nginx ingress`
- Storage, ebs and EFS


## Prerequisites

- aws web services
- Terraform, kubectl and helm

## CI/CD

Two options to detect update and roll out the new deployment

- web hook to monitor the GitHub repo source
    - In another GitHub-repo to build and push the change the /app folder, so that it will trigger to new deployment
- argocd image updater to watch the image update from docker hub

## Metrics