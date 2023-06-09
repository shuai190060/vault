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

## How to deploy:

- initiate the eks cluster with 1 t3.medium node, and with karpenter provisioned.
    
    ```jsx
    # initiate the cluster by running this script
    ./init.sh
    
    # apply the karpenter provisioner and AWSnodetemplate
    kubectl apply -f karpenter/0-provisioner.yaml
    ```
    
- Optional install the tools with helm package manager by running script
    
    ```jsx
    # install by running script
    ./tools_helm.sh <the number reflect the package>
    ```
    
    | Number | Package | Name space |
    | --- | --- | --- |
    | 7 | nginx ingress controller | ingress-nginx |
    | 8 | prometheus-stack | monitoring |
    | 9 | argocd | argocd |
    | 10 | argocd-image-updater | argocd |
    | 11 | vault | vault |
    | 12 | sealed-secret | kube-system |
    | 13 | elasticsearch  | N/A |
    | 14 | fluent-bit | logging |
    | 15 | EFS | N/A |
    | 16 | cert-manager | cert-manager |
    | 17 | Istio | istio-system, istio-ingress |
    | 18 | aws application load balancer | kube-system |
    
- clean up
    
    ```jsx
    # clean up by running script
    ./clean.sh
    ```


## CI/CD

Two options to detect update and roll out the new deployment

- web hook to monitor the GitHub repo source
    - In another GitHub-repo to build and push the change the /app folder, so that it will trigger to new deployment
- argocd image updater to watch the image update from docker hub

## Metrics

- kube-state-metric
- cadvisor
- visualisation (Grafana)

## Node auto-scaling

- scaling base on cpu usage
- initiate with 1 t3.Medium instance, scale up with c5,m5,r5. medium/large
- refer to Karpenter provisioner in folder `/karpenter`

## Security

- mTLS with cert-manager
    - Letsencrypt
    - domain *.shuhai.de
- secret ingestion
    - vault
        - need to provision vault first in the cluster first
        - create secret and configure the kube-config in vault

## Logging

- logs shipper: fluent-bit
- log: container logs
- process: send logs to `cloudwatch`, then `subscriber filter` to send logs to `Elasticsearch domain`

## Others

- ingress controller: Nginx
- storage: EBS(add-on is ready), EFS(need to provision and setup security group)