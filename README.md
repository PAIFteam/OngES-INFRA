# OngES-INFRA

Infraestrutura, pipelines e manifests Kubernetes da plataforma **Conexão Solidária**, desenvolvida para a ONG Esperança Solidária.

Projeto desenvolvido durante a Fase 5 (Hackathon) da Pós-Graduação em Arquitetura de Sistemas .NET da FIAP, pelo grupo PAIF Team.

Repositórios complementares:
- OngES-Core — https://github.com/PAIFteam/OngES-Core
- OngES-Worker — https://github.com/PAIFteam/OngES-Worker

## Repositórios utilizados

- `PAIFteam/OngES-Core`
- `PAIFteam/OngES-Worker`
- `PAIFteam/OngES-INFRA`

## Arquitetura da solução

Este repositório concentra tudo o que é necessário para orquestrar o OngES-Core e o OngES-Worker em um cluster Kubernetes, incluindo o broker RabbitMQ usado na comunicação assíncrona entre os dois serviços.

```
                     ┌───────────────────────┐
                     │   Ingress (nginx)     │
                     └──────────┬────────────┘
                                │
                     ┌──────────▼────────────┐
                     │  onges-core-api (Svc) │
                     └──────────┬────────────┘
                                │
                     ┌──────────▼────────────┐
                     │  onges-core-api (Pod) │
                     └───┬──────────────┬─────┘
                         │              │
                 publica │              │ lê/escreve
                 evento  │              │
                         ▼              ▼
                  ┌─────────────┐  ┌──────────────┐
                  │  rabbitmq   │  │  SQL Server   │
                  │  (Pod/Svc)  │  │  (externo)    │
                  └──────┬──────┘  └──────▲────────┘
                         │                │
                 consome │                │ atualiza saldo
                         ▼                │
                  ┌─────────────────┐     │
                  │ onges-worker    │─────┘
                  │ (Pod)           │
                  └─────────────────┘
```

> O banco de dados (SQL Server) é esperado como uma instância externa (local, container avulso ou gerenciada), cuja connection string é injetada via Secret. Ver seção "Pré-requisitos".

## Princípios adotados

- Infrastructure as Code (manifests versionados)
- Configuração via ConfigMap/Secret (12-factor)
- CI/CD orientado a eventos de push
- Namespace isolado (`onges-ns`)
- Health checks via readiness/liveness probe

## Estrutura

```
OngES-INFRA/
├── docker/
│   ├── core/Dockerfile
│   └── worker/Dockerfile
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secrets.yml
│   ├── rabbitmq/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── core/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── worker/
│   │   └── deployment.yaml
│   └── ingress/
│       └── ingress.yaml
├── pipelines/
│   ├── azure-pipelines-ci.yml
│   └── azure-pipelines-cd.yml
├── scripts/
│   └── validate-manifests.sh
└── README.md
```

## Tecnologias

- Kubernetes (Minikube, Kind ou Docker Desktop K8s)
- Docker
- NGINX Ingress Controller
- RabbitMQ 3.13 (management)
- Azure DevOps Pipelines (CI/CD)

## Pré-requisitos

- Docker
- Um cluster Kubernetes local: [Minikube](https://minikube.sigs.k8s.io/), [Kind](https://kind.sigs.k8s.io/) ou Docker Desktop com Kubernetes habilitado
- `kubectl` configurado apontando para o cluster local
- Ingress Controller NGINX habilitado no cluster (no Minikube: `minikube addons enable ingress`)
- Uma instância de SQL Server acessível a partir do cluster (local, container `mcr.microsoft.com/mssql/server`, ou serviço gerenciado), já com o schema aplicado a partir de `OngES-Core/docker/db/init/*.sql`

> **Importante:** antes de aplicar os manifests, confira se as chaves em `k8s/configmap.yaml` e `k8s/secrets.yml` correspondem exatamente às seções lidas pelos apps (`RabbitSettings:*` e `ConnectionStrings:DB_SQL_ONGES` em `appsettings.json`). Nomes divergentes fazem o Pod subir "Running" mas a aplicação não encontrar RabbitMQ/banco.

## Executando localmente

### 1. Subir o cluster

```bash
minikube start
minikube addons enable ingress
```

### 2. Buildar as imagens localmente

A partir da raiz onde os três repositórios estão clonados lado a lado:

```bash
docker build -f OngES-INFRA/docker/core/Dockerfile   -t onges-core-api:local   OngES-Core
docker build -f OngES-INFRA/docker/worker/Dockerfile -t onges-worker:local    OngES-Worker
```

Carregue as imagens para dentro do cluster local (Minikube não enxerga o Docker do host por padrão):

```bash
minikube image load onges-core-api:local
minikube image load onges-worker:local
```

Ajuste temporariamente `image:` em `k8s/core/deployment.yaml` e `k8s/worker/deployment.yaml` para `onges-core-api:local` / `onges-worker:local` (o valor `acrpaifgamesdev.azurecr.io/...` é usado apenas no pipeline de CD contra o ACR/AKS).

### 3. Preencher os Secrets

Edite `k8s/secrets.yml` e substitua os valores `SUBSTITUIR` pela connection string real do SQL Server e pela senha do RabbitMQ.

### 4. Aplicar os manifests (nesta ordem)

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yml
kubectl apply -f k8s/rabbitmq/
kubectl apply -f k8s/core/
kubectl apply -f k8s/worker/
kubectl apply -f k8s/ingress/
```

Ou, para validar antes (dry-run):

```bash
./scripts/validate-manifests.sh
```

### 5. Verificar se subiu

```bash
kubectl get pods -n onges-ns
kubectl get svc -n onges-ns
```

### 6. Acessar a API

```bash
minikube ip
# ou
kubectl port-forward -n onges-ns svc/onges-core-api 8080:80
```

Com o Ingress, o Core fica acessível em `http://<minikube-ip>/onges/swagger` (ou via port-forward, em `http://localhost:8080/swagger`).

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

## Roadmap

- [ ] Manifest de banco de dados (SQL Server) no cluster
- [ ] Health Checks (`/health`) expostos pela API e pelo Worker
- [ ] Observabilidade (Prometheus + Grafana)
- [ ] Alinhamento de nomes de variáveis entre ConfigMap/Secret e `appsettings.json`
- [ ] Docker Compose como alternativa mais simples ao Kubernetes para ambiente local

## Licença

Projeto desenvolvido exclusivamente para fins acadêmicos durante a Pós-Graduação em Arquitetura de Sistemas .NET da FIAP.
