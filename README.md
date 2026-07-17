# OngES-INFRA

Infraestrutura, pipelines e manifests Kubernetes do projeto OngES.

## Repositórios utilizados

- `PAIFteam/OngES-Core`
- `PAIFteam/OngES-Worker`
- `PAIFteam/OngES-INFRA`

## Estrutura

```text
OngES-INFRA/
├── docker/
│   ├── core/Dockerfile
│   └── worker/Dockerfile
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── rabbitmq/
│   ├── core/
│   ├── worker/
│   └── ingress/
├── pipelines/
│   ├── azure-pipelines-ci.yml
│   └── azure-pipelines-cd.yml
├── scripts/
│   └── validate-manifests.sh
└── README.md
```

## Variáveis necessárias no Azure DevOps

- `AZURE_SERVICE_CONNECTION`
- `ACR_SERVICE_CONNECTION`
- `ACR_LOGIN_SERVER`
- `AKS_RESOURCE_GROUP`
- `AKS_CLUSTER_NAME`
- `SQL_CONNECTION_STRING` — secreta
- `ADMIN_KEY` — secreta
- `PASSWORD_SALT` — secreta
- `RABBITMQ_USERNAME` — secreta
- `RABBITMQ_PASSWORD` — secreta

Confira os caminhos exatos das solutions e projetos antes da primeira execução.
