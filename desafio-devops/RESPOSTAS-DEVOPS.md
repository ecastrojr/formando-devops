# Desafio DevOps

Utilizando o repositório do app [podinfo](https://github.com/stefanprodan/podinfo) como base, crie um novo repositório
com as seguintes features:

O repositório deve conter o código para implementar as fetaures acima e screenshots com evidencias de
todos os itens entregues.

Utilize a versão que desejar para cada ferramenta.
Envie a URL do seu repositório para desafio@getupcloud.com.

### Respostas em: [https://gitlab.com/ecastrojr/desafio-devops/](https://gitlab.com/ecastrojr/desafio-devops/)

## 1. Gitlab

```
  -> pipeline com build da imagem do app
     -> [plus] linter do Dockerfile (tip: use o https://github.com/hadolint/hadolint)
        -> falhar se houver severidade >= Warning
  -> [plus] scan da imagem usando Trivy (https://github.com/aquasecurity/trivy) standalone (binário)
     -> falhar se houver bug crítico
```

Tips:

- Instale o [GitLab CI/CD workflow agent](https://docs.gitlab.com/ee/user/clusters/agent/#gitlab-cicd-workflow) para fazer o build e aplicar os manifestos no cluster (caso não use fluxcd): https://docs.gitlab.com/ee/user/clusters/agent/install/
- Para fazer o build da imagem, utilize como base o pipeline em https://gitlab.com/gitlab-org/gitlab-foss/-/blob/master/lib/gitlab/ci/templates/Docker.gitlab-ci.yml
- Utilize o seguinte nome para a imagem: `$CI_REGISTRY/$SEU_USER_GITLAB/podinfo:$CI_COMMIT_SHORT_SHA`

### Resposta: 
Repositório: [https://gitlab.com/ecastrojr/desafio-devops/](https://gitlab.com/ecastrojr/desafio-devops/)


- [x] [pipeline com build da imagem do app](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/.gitlab-ci.yml)
- [x] [[plus] linter do Dockerfile e falhar se houver severidade >= Warning](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/.gitlab-ci.yml#6)
- [x] [[plus] scan da imagem usando Trivy e falhar se houver bug crítico](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/.gitlab-ci.yml)


## 2. Terraform

```
  -> criar cluster kind
  -> [plus] criar repo no gitlab
```
### Resposta:
Repositório: [https://gitlab.com/ecastrojr/desafio-devops/](https://gitlab.com/ecastrojr/desafio-devops/)
- [x] [criar cluster kind](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/terraform/kind/kind_cluster.tf)
- [x] [[plus] criar repo no gitlab](https://gitlab.com/ecastrojr/desafio-devops/-/tree/main/terraform/)

`Criado Cluster Kind com terraform. Junto com o KinD é entregue o metrics-server, prometheus, grafana, alertmanager e loki configurados`

`No repositório tem um Vagrantfile onde é possível executar/replicar os testes do desafio`

## 3. Kubernetes

```
  -> implementar no app
     -> probes liveness e readiness
     -> definir resource de cpu e memória
  -> [plus] escalar app com base na métrica `requests_total`
     -> escalar quando observar > 2 req/seg.
  -> [plus] instalar app com fluxcd
```
### Resposta:
Repositório: [https://gitlab.com/ecastrojr/desafio-devops/](https://gitlab.com/ecastrojr/desafio-devops/)
- [x] [implementar no app, robes liveness e readiness e definir resource de cpu e memória](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/fluxcd/app/deployment.yaml)
- [x] [[plus] escalar app com base na métrica `requests_total` e escalar quando observar > 2 req/seg.](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/fluxcd/app/hpa.yaml)
- [x] [[plus] instalar app com fluxcd](https://gitlab.com/ecastrojr/desafio-devops/-/tree/main/fluxcd)

` Criado arquivos para deploy do app com probes liveness e readiness através do flux, com HPA, service e monitoramento da métrica pelo prometheus`

` Criado terraform para efetuar o deploy do flux e configurar o repositório com os arquivos do flux`

`Testando o hpa:`

```bash
# k get horizontalpodautoscalers.autoscaling  -w
NAME      REFERENCE            TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
podinfo   Deployment/podinfo   418m/2    2         10        2          4m6s
podinfo   Deployment/podinfo   2481m/2   2         10        2          5m
podinfo   Deployment/podinfo   3190m/2   2         10        3          5m15s
podinfo   Deployment/podinfo   2236m/2   2         10        3          5m30s
podinfo   Deployment/podinfo   1707m/2   2         10        4          5m45s
podinfo   Deployment/podinfo   1093m/2   2         10        4          6m
podinfo   Deployment/podinfo   490m/2    2         10        4          11m
podinfo   Deployment/podinfo   502m/2    2         10        3          12m
podinfo   Deployment/podinfo   514m/2    2         10        3          12m
podinfo   Deployment/podinfo   563m/2    2         10        2          12m
```

## 4. Observabilidade

```
  -> prometheus stack (prometheus, grafana, alertmanager)
  -> retenção de métricas 3 dias
     -> storage local (disco), persistente
  -> enviar alertas para um canal no telegram
  -> logs centralizados (loki, no mesmo grafana do monitoramento)
  -> [plus] monitorar métricas do app `request_duration_seconds`
     -> alertar quando observar > 3 seg.
  -> [plus] tracing (Open Telemetry)
```
### Resposta:
Repositório: [https://gitlab.com/ecastrojr/desafio-devops/](https://gitlab.com/ecastrojr/desafio-devops/)
- [x] [prometheus stack (prometheus, grafana, alertmanager)](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/terraform/kind/prometheus_stack.tf)
- [x] [retenção de métricas 3 dias com storage local (disco), persistente](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/terraform/kind/values-kube-prometheus-stack.yaml)
- [x] [enviar alertas para um canal no telegram]()
- [x] [logs centralizados (loki, no mesmo grafana do monitoramento)](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/terraform/kind/grafana_loki.tf)
- [x] [[plus] monitorar métricas do app `request_duration_seconds` e alertar quando observar > 3 seg.](https://gitlab.com/ecastrojr/desafio-devops/-/blob/main/templates/imgs/alerta%20prometheus.png)  `faltou ajustes finais`

` Deploy do prometheus stack efetuado pelo terraform e helm`