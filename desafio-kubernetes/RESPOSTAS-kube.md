# Desafio Kubernetes

As questões abaixo devem ser respondidas no arquivo [RESPOSTAS-kube.md](RESPOSTAS-kube.md) em um fork desse repositório. Por ordem e numeradamente. O formato é livre, mas recomenda-se as linhas de comando utilizadas para criar ou alterar resources de cada questão na maioria dos casos. Quanto mais sucinto e direto, melhor. Envie o endereço do seu repositório para desafio@getupcloud.com.

1 - com uma única linha de comando capture somente linhas que contenham "erro" do log do pod `serverweb` no namespace `meusite` que tenha a label `app: ovo`.

*`Resposta:`*

```bash
# Ou filtramos pelo node do Pod ou pelo label.
# error: only a selector (-l) or a POD name is allowed 
$ kubectl logs -n meusite -l app=ovo --all-containers=true| grep -i "erro"
```

2 - crie o manifesto de um recurso que seja executado em todos os nós do cluster com a imagem `nginx:latest` com nome `meu-spread`, nao sobreponha ou remova qualquer taint de qualquer um dos nós.

*`Resposta:`*

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: meu-spread
spec:
  selector:
    matchLabels:
      system: meu-spread
  template:
    metadata:
      labels:
        system: meu-spread
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
  updateStrategy:
    type: RollingUpdate
```

```bash
$ kubectl apply -f meu-spread.yaml
daemonset.apps/meu-spread created

$ kubectl get pods -o wide
NAME               READY   STATUS    RESTARTS   AGE     IP               NODE            NOMINATED NODE   READINESS GATES
meu-spread-55lfg   1/1     Running   0          3m57s   192.168.77.179   master-node     <none>           <none>
meu-spread-h624d   1/1     Running   0          3m57s   192.168.87.217   worker-node01   <none>           <none>
meu-spread-qq84d   1/1     Running   0          3m57s   192.168.158.48   worker-node02   <none>           <none>
```


3 - crie um deploy `meu-webserver` com a imagem `nginx:latest` e um initContainer com a imagem `alpine`. O initContainer deve criar um arquivo /app/index.html, tenha o conteúdo "HelloGetup" e compartilhe com o container de nginx que só poderá ser inicializado se o arquivo foi criado.

*`Resposta:`*

```yaml
# meu-webserver-nginx-initcontainer.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meu-webserver
spec:
  selector:
    matchLabels:
      app: meu-webserver
  template:
    metadata:
      labels:
        app: meu-webserver
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
          - containerPort: 80
        volumeMounts:
          - name: workdir
            mountPath: /usr/share/nginx/html
        startupProbe:
          exec:
            command:
            - cat
            - /usr/share/nginx/html/index.html
          failureThreshold: 10
          periodSeconds: 2
      initContainers:
        - name: init
          image: alpine
          command: ['sh', '-c', 'echo HelloGetup > /app/index.html']          
          volumeMounts:
            - name: workdir
              mountPath: "/app"
      dnsPolicy: Default
      volumes:
      - name: workdir
        emptyDir: {}
```

```bash
$ kubectl apply -f meu-webserver-nginx-initcontainer.yaml
```

4 - crie um deploy chamado `meuweb` com a imagem `nginx:1.16` que seja executado exclusivamente no node master.

*`Resposta:`*

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meuweb
spec:
  selector:
    matchLabels:
      app: meuweb
  template:
    metadata:
      labels:
        app: meuweb
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: meuweb
        image: nginx:1.16
        resources:
          limits:
            memory: "64Mi"
            cpu: "250m"
        ports:
        - containerPort: 80
      nodeSelector:
        node-role.kubernetes.io/master: ""
```

```bash

$ kubectl apply -f meuweb-deploy-master.yaml
deployment.apps/meuweb created

$ kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE   IP               NODE          NOMINATED NODE   READINESS GATES
meuweb-5d5bbb9c66-bz9q2   1/1     Running   0          16s   192.168.77.181   master-node   <none>           <none>
```


5 - com uma única linha de comando altere a imagem desse pod `meuweb` para `nginx:1.19` e salve o comando aqui no repositório.

*`Resposta:`*

```bash
$ kubectl set image deploy meuweb  meuweb=nginx:1.19
deployment.apps/meuweb image updated
```


6 - quais linhas de comando para instalar o ingress-nginx controller usando helm, com os seguintes parâmetros;

    helm repository : https://kubernetes.github.io/ingress-nginx

    values do ingress-nginx : 
    controller:
      hostPort:
        enabled: true
      service:
        type: NodePort
      updateStrategy:
        type: Recreate

*`Resposta:`*

```bash
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
"ingress-nginx" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "kong-z" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈

$ helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.3.0 \
--set controller.hostPort.enabled=true \
--set controller.service.type=NodePort \
--set controller.updateStrategy.type=Recreate
NAME: ingress-nginx
LAST DEPLOYED: Sun Oct 30 06:22:17 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
```


7 - quais as linhas de comando para: 

    criar um deploy chamado `pombo` com a imagem de `nginx:1.11.9-alpine` com 4 réplicas;
    alterar a imagem para `nginx:1.16` e registre na annotation automaticamente;
    alterar a imagem para 1.19 e registre novamente; 
    imprimir a historia de alterações desse deploy;
    voltar para versão 1.11.9-alpine baseado no histórico que voce registrou.
    criar um ingress chamado `web` para esse deploy

*`Resposta:`*

```bash
$ kubectl create deployment pombo --image nginx:1.11.9-alpine --replicas 4
deployment.apps/pombo created

$ kubectl set image deploy pombo nginx=nginx:1.16 --record

$ kubectl set image deploy pombo nginx=nginx:1.19 --record
Flag --record has been deprecated, --record will be removed in the future
deployment.apps/pombo image updated

$ kubectl rollout history deployment pombo 
deployment.apps/pombo 
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deploy pombo nginx=nginx:1.16 --record=true
3         kubectl set image deploy pombo nginx=nginx:1.19 --record=true

$ kubectl rollout undo deployment pombo --to-revision=1
deployment.apps/pombo rolled back

$ kubectl expose deployment pombo --type NodePort --port 80
service/pombo exposed

$ kubectl create ingress pombo-ingress --rule="meuk8s.com/pombo=pombo:80"
```


8 - linhas de comando para; 

    criar um deploy chamado `guardaroupa` com a imagem `redis`;
    criar um serviço do tipo ClusterIP desse redis com as devidas portas.

*`Resposta:`*

```bash
$ kubectl create deployment guardaroupa --image redis --port 6379
deployment.apps/guardaroupa created

$ kubectl expose deployment guardaroupa
service/guardaroupa exposed
```


9 - crie um recurso para aplicação stateful com os seguintes parâmetros:

    - nome : meusiteset
    - imagem nginx 
    - no namespace backend
    - com 3 réplicas
    - disco de 1Gi
    - montado em /data
    - sufixo dos pvc: data

*`Resposta:`*

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
  namespace: backend
  labels:
    app: meusiteset
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meusiteset
  namespace: backend
  labels:
    app: meusiteset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: meusiteset
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: meusiteset
    spec:
      containers:
      - image: nginx
        name: meusiteset
        resources:
          limits:
            memory: "32Mi"
            cpu: "50m"
        ports:
        - containerPort: 80
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: pvc-data
```

```bash
$ kubectl create namespace backend
namespace/backend created

$ kubectl apply -f nginx-pvc.yaml 
persistentvolumeclaim/pvc-data created
deployment.apps/meusiteset configured
```



10 - crie um recurso com 2 replicas, chamado `balaclava` com a imagem `redis`, usando as labels nos pods, replicaset e deployment, `backend=balaclava` e `minhachave=semvalor` no namespace `backend`.

*`Resposta:`*

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: balaclava
  labels:
    backend: balaclava
    minhachave: semvalor
  namespace: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      backend: balaclava
  template:
    metadata:
      labels:
        backend: balaclava
        minhachave: semvalor
    spec:
      containers:
      - name: balaclava
        image: redis
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 6379
```

```bash
$ kubectl create namespace backend
namespace/backend created

$ kubectl create namespace backend
namespace/backend created

$ kubectl get deployments.apps,rs,pods -n backend -L backend,minhachave
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE     BACKEND     MINHACHAVE
deployment.apps/balaclava   2/2     2            2           6m12s   balaclava   semvalor

NAME                                   DESIRED   CURRENT   READY   AGE     BACKEND     MINHACHAVE
replicaset.apps/balaclava-84cc447f47   2         2         2       6m12s   balaclava   semvalor

NAME                             READY   STATUS    RESTARTS   AGE     BACKEND     MINHACHAVE
pod/balaclava-84cc447f47-2zfbl   1/1     Running   0          6m12s   balaclava   semvalor
pod/balaclava-84cc447f47-vtzmm   1/1     Running   0          6m12s   balaclava   semvalor
```


11 - linha de comando para listar todos os serviços do cluster do tipo `LoadBalancer` mostrando também `selectors`.

*`Resposta:`*

```bash
kubectl get services -A -o=custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,EXTERNAL-IP:.status.loadBalancer.ingress[*].ip,PORT(S):.spec.ports[*].port,SELECTOR:.spec.selector' | egrep "NAMESPACE|LoadBalancer"
```


12 - com uma linha de comando, crie uma secret chamada `meusegredo` no namespace `segredosdesucesso` com os dados, `segredo=azul` e com o conteúdo do texto abaixo.

```bash
   # cat chave-secreta
     aW5ncmVzcy1uZ2lueCAgIGluZ3Jlc3MtbmdpbngtY29udHJvbGxlciAgICAgICAgICAgICAgICAg
     ICAgICAgICAgICAgTG9hZEJhbGFuY2VyICAgMTAuMjMzLjE3Ljg0ICAgIDE5Mi4xNjguMS4zNSAg
     IDgwOjMxOTE2L1RDUCw0NDM6MzE3OTQvVENQICAgICAyM2ggICBhcHAua3ViZXJuZXRlcy5pby9j
     b21wb25lbnQ9Y29udHJvbGxlcixhcHAua3ViZXJuZXRlcy5pby9pbnN0YW5jZT1pbmdyZXNzLW5n
     aW54LGFwcC5rdWJlcm5ldGVzLmlvL25hbWU9aW5ncmVzcy1uZ
```

*`Resposta:`*

```bash
$ kubectl create namespace segredosdesucesso
namespace/segredosdesucesso created

$ kubectl create secret generic meusegredo --from-literal segredo=azul --from-file chave-secreta -n segredosdesucesso 
secret/meusegredo created
```


13 - qual a linha de comando para criar um configmap chamado `configsite` no namespace `site`. Deve conter uma entrada `index.html` que contenha seu nome.

*`Resposta:`*

```bash
$ kubectl create namespace site
namespace/site created

$ kubectl create configmap configsite -n site --from-literal index.html="Euclides Alexander de Castro Junior"
configmap/configsite created
```


14 - crie um recurso chamado `meudeploy`, com a imagem `nginx:latest`, que utilize a secret criada no exercício 11 como arquivos no diretório `/app`.

*`Resposta:`*

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meudeploy
  namespace: segredosdesucesso 
spec:
  selector:
    matchLabels:
      app: meudeploy
  template:
    metadata:
      labels:
        app: meudeploy
    spec:
      containers:
      - name: meudeploy
        image: nginx:latest
        resources:
          limits:
            memory: "28Mi"
            cpu: "50m"
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: /app
          name: meusegredovol
      volumes:
      - name: meusegredovol
        secret:
          secretName: meusegredo
```


```bash
$ kubectl apply -f meudeploy-secret.yaml

$ kubectl exec -ti -n segredosdesucesso pods/meudeploy-5f6c78f88-77hrg -- cat /app/chave-secreta
aW5ncmVzcy1uZ2lueCAgIGluZ3Jlc3MtbmdpbngtY29udHJvbGxlciAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgTG9hZEJhbGFuY2VyICAgMTAuMjMzLjE3Ljg0ICAgIDE5Mi4xNjguMS4zNSAg
IDgwOjMxOTE2L1RDUCw0NDM6MzE3OTQvVENQICAgICAyM2ggICBhcHAua3ViZXJuZXRlcy5pby9j
b21wb25lbnQ9Y29udHJvbGxlcixhcHAua3ViZXJuZXRlcy5pby9pbnN0YW5jZT1pbmdyZXNzLW5n
aW54LGFwcC5rdWJlcm5ldGVzLmlvL25hbWU9aW5ncmVzcy1uZ

$ kubectl exec -ti -n segredosdesucesso pods/meudeploy-5f6c78f88-77hrg -- cat /app/segredo
azul
```


15 - crie um recurso chamado `depconfigs`, com a imagem `nginx:latest`, que utilize o configMap criado no exercício 12 e use seu index.html como pagina principal desse recurso.

*`Resposta:`*

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: depconfigs
  namespace: site
  labels:
    name: depconfigs
spec:
  containers:
  - name: nginx
    image: nginx:latest
    volumeMounts:
    - name: configsite-vol
      mountPath: /usr/share/nginx/html/
    resources:
      limits:
        memory: "28Mi"
        cpu: "50m"
  volumes:
  - name: configsite-vol
    configMap:
      name: configsite
```

```bash
$ kubectl apply -f depconfigs-configmap.yaml 
pod/depconfigs created

$ kubectl exec -ti -n site pods/depconfigs -- cat /usr/share/nginx/html/index.html
Euclides Alexander de Castro Junior
```


16 - crie um novo recurso chamado `meudeploy-2` com a imagem `nginx:1.16` , com a label `chaves=secretas` e que use todo conteúdo da secret como variável de ambiente criada no exercício 11.

*`Resposta:`*

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meudeploy-2
  namespace: segredosdesucesso 
  labels:
        app: meudeploy-2
        chaves: secretas
spec:
  selector:
    matchLabels:
      app: meudeploy-2
  template:
    metadata:
      labels:
        app: meudeploy-2
        chaves: secretas
    spec:
      containers:
      - name: meudeploy-2
        image: nginx:1.16
        resources:
          limits:
            memory: "28Mi"
            cpu: "50m"
        ports:
        - containerPort: 80
        env:
          - name: CHAVE_SECRETA
            valueFrom:
              secretKeyRef:
                name: meusegredo
                key: chave-secreta
          - name: SEGREDO
            valueFrom:
              secretKeyRef:
                name: meusegredo
                key: segredo
```


```bash
$ kubectl apply -f meudeploy-2-secret.yaml 
deployment.apps/meudeploy-2 created
```


17 - linhas de comando que;

    crie um namespace `cabeludo`;
    um deploy chamado `cabelo` usando a imagem `nginx:latest`; 
    uma secret chamada `acesso` com as entradas `username: pavao` e `password: asabranca`;
    exponha variáveis de ambiente chamados USUARIO para username e SENHA para a password.

*`Resposta:`*

```bash
$ kubectl create namespace cabeludo
namespace/cabeludo created

$ kubectl create deployment cabelo --image nginx:latest
deployment.apps/cabelo created

$ kubectl create secret generic acesso --from-literal username=pavao --from-literal password=asabranca
secret/acesso created

$ kubectl set env --from=secret/acesso deployment/cabelo
Warning: key password transferred to PASSWORD
Warning: key username transferred to USERNAME
```


18 - crie um deploy `redis` usando a imagem com o mesmo nome, no namespace `cachehits` e que tenha o ponto de montagem `/data/redis` de um volume chamado `app-cache` que NÂO deverá ser persistente.

*`Resposta:`*

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: cachehits
spec:
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 6379
        volumeMounts:
        - mountPath: /data/redis
          name: app-cache
      volumes:
      - name: app-cache
        emptyDir: {}
```

```bash
$ kubectl create ns cachehits
namespace/cachehits created

$ kubectl apply -f redis-deploy-emptydir.yaml 
deployment.apps/redis created
```


19 - com uma linha de comando escale um deploy chamado `basico` no namespace `azul` para 10 replicas.

*`Resposta:`*

```bash
$ kubectl scale deployment -n azul basico --replicas 10
deployment.apps/basico scaled
```


20 - com uma linha de comando, crie um autoscale de cpu com 90% de no mínimo 2 e máximo de 5 pods para o deploy `site` no namespace `frontend`.

*`Resposta:`*

```bash
$ kubectl autoscale deployment -n frontend site --min=2 --max=5 --cpu-percent=90
horizontalpodautoscaler.autoscaling/site autoscaled
```


21 - com uma linha de comando, descubra o conteúdo da secret `piadas` no namespace `meussegredos` com a entrada `segredos`.

*`Resposta:`*

```bash
$ kubectl get secret -n meussegredos piadas -o json | jq '.data | map_values(@base64d)'
{
  "segredos": "olhaSohein!"
}
```


22 - marque o node o nó `k8s-worker1` do cluster para que nao aceite nenhum novo pod.

*`Resposta:`*

```bash
$ kubectl taint node k8s-worker1 chega:NoSchedule
node/k8s-worker1 tainted

# Voltando
kubectl taint node k8s-worker1 chega:NoSchedule-
node/worker-node01 untainted

#ou
$ kubectl cordon k8s-worker1
node/worker-node01 cordoned

# Voltando
$ kubectl uncordon worker-node01
node/worker-node01 uncordoned
```


23 - esvazie totalmente e de uma única vez esse mesmo nó com uma linha de comando.

*`Resposta:`*

```bash
$ kubectl taint node k8s-worker1 vaza:NoExecute
node/k8s-worker1 tainted

# Voltando
$ kubectl taint node k8s-worker1 vaza:NoExecute-
node/k8s-worker1 untainted

#ou

$ kubectl drain k8s-worker1 --force --ignore-daemonsets
node/k8s-worker1 cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/calico-node-kj72q, kube-system/kube-proxy-dkw46, lens-metrics/node-exporter-ddcgt
node/k8s-worker1 drained

# Voltando
$ kubectl uncordon k8s-worker1
node/k8s-worker1 uncordoned

```


24 - qual a maneira de garantir a criação de um pod ( sem usar o kubectl ou api do k8s ) em um nó especifico.

*`Resposta:`*

Criando um Pod estático dentro do nó especifico:

Acessando por ssh o nó;

```bash
mkdir -p /etc/kubernetes/manifests/
cat <<EOF >/etc/kubernetes/manifests/static-web.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    role: myrole
spec:
  containers:
    - name: web
      image: nginx
      ports:
        - name: web
          containerPort: 80
          protocol: TCP
EOF
```


25 - criar uma serviceaccount `userx` no namespace `developer`. essa serviceaccount só pode ter permissão total sobre pods (inclusive logs) e deployments no namespace `developer`. descreva o processo para validar o acesso ao namespace do jeito que achar melhor.

*`Resposta:`*

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: userx
  namespace: developer
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-role
  namespace: developer
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods", "pods/log"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # Pode ser usado ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developer-role-binding
  namespace: developer
subjects:
- kind: ServiceAccount
  name: userx
  namespace: developer
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

```bash
$ kubectl create ns developer
namespace/developer created

$ kubectl apply -f userx-SA-Role-RB.yaml 
serviceaccount/userx created
role.rbac.authorization.k8s.io/developer-role created
rolebinding.rbac.authorization.k8s.io/developer-role-binding created

$ kubectl auth can-i get pods -n developer --as=system:serviceaccount:developer:userx
yes
$ kubectl auth can-i get deployments -n developer --as=system:serviceaccount:developer:userx
yes
$ kubectl auth can-i get pods/logs  -n developer --as=system:serviceaccount:developer:userx
yes
$ kubectl auth can-i create pods -n developer --as=system:serviceaccount:developer:userx
yes
$ kubectl auth can-i delete pods -n developer --as=system:serviceaccount:developer:userx
yes
$ kubectl auth can-i create deployments -n developer --as=system:serviceaccount:developer:userx
yes
$ kubectl auth can-i delete deployments -n developer --as=system:serviceaccount:developer:userx
yes
```

26 - criar a key e certificado cliente para uma usuária chamada `jane` e que tenha permissão somente de listar pods no namespace `frontend`. liste os comandos utilizados.

*`Resposta:`*

```bash
#No computador / term logado como usuário jane
openssl genrsa -out ./jane-k8s.key 4096

openssl req \
  -new 
  -key ./jane-k8s.key \
  -out ./jane-k8s.csr \
  -subj "/CN=jane/O=frontend"

$ cat ./jane-k8s.csr | base64 | tr -d '\n'
```

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jane-csr
spec:
  request: <cole o base64 aqui>
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 8640000
  usages:
    - digital signature
    - key encipherment
    - client auth
```

```bash
#No computador / term logado como usuário administrador
$ kubectl apply -f jane-csr.yaml
certificatesigningrequest.certificates.k8s.io/jane-csr created

$ kubectl get csr
NAME       AGE    SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
jane-csr   115s   kubernetes.io/kube-apiserver-client   kubernetes-admin   100d                Pending

$ kubectl certificate approve jane-csr
certificatesigningrequest.certificates.k8s.io/jane-csr approved

$ kubectl get csr
NAME       AGE     SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
jane-csr   3m35s   kubernetes.io/kube-apiserver-client   kubernetes-admin   100d                Approved,Issued

$ kubectl get csr jane-csr -o jsonpath='{.status.certificate}' | base64 -d > jane-k8s.pem

$ kubectl create ns frontend
namespace/frontend created

$ kubectl create role frontend --verb=list --resource=pods -n frontend

$ kubectl get role -n frontend 
NAME       CREATED AT
frontend   2022-11-01T05:31:51Z

$ kubectl create rolebinding frontend-binding-jane --role=frontend --user=jane -n frontend 
rolebinding.rbac.authorization.k8s.io/frontend-binding-jane created
```

```bash
#No computador / term logado como usuário jane
$ kubectl config set-credentials jane \
  --client-key jane-k8s.key \
  --client-certificate jane-k8s.pem \
  --embed-certs=true
User "jane" set.

# Ajustado campos "clusters:", "contexts:" e "current-context:" do arquivo ~./kube/config do usuário jane

$ kubectl get pods -n frontend
No resources found in frontend namespace.
$ kubectl run pods -n frontend --image=nginx
Error from server (Forbidden): pods is forbidden: User "jane" cannot create resource "pods" in API group "" in the namespace "frontend"

# Criado um pod como adm para poder testar.
$ kubectl get pods -n frontend
NAME   READY   STATUS    RESTARTS   AGE
pods   1/1     Running   0          7s
$ kubectl get pods 
Error from server (Forbidden): pods is forbidden: User "jane" cannot list resource "pods" in API group "" in the namespace "default"
$ kubectl get pods -n azul
Error from server (Forbidden): pods is forbidden: User "jane" cannot list resource "pods" in API group "" in the namespace "azul"
```


27 - qual o `kubectl get` que traz o status do scheduler, controller-manager e etcd ao mesmo tempo

*`Resposta:`*

```bash
$ kubectl get componentstatuses 
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
controller-manager   Healthy   ok                              
scheduler            Healthy   ok                              
etcd-0               Healthy   {"health":"true","reason":""}   
```