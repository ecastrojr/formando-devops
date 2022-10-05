# Desafio Terraform

Em um fork desse repositório, responda as questões abaixo e envie o endereço para desafio@getupcloud.com.
O formato é livre. Quanto mais sucinto e direto, melhor.

Para cada questão prática 1, 2 e 3, crie os arquivos em um diretório com o número do desafio 1/, 2/ e 3/.

Utilize a versão que desejar do terraform.

## 1. Módulos

Escreva um módulo terraform para criar um cluster kind usando o provider `kyma-incubator/kind` com as seguintes características:

- Node `infra` com label `role=infra` e taint `dedicated=infra:NoSchedule`;
- Node `app` com label `role=app`;
- Metrics Server instalado e reportando métricas de nodes e pods.

O módulo deve permitir, no mínimo, as seguintes variáveis:

- cluster_name
- kubernetes_version

O módulo deve retornar, no mínimo, os seguintes atributos:

- api_endpoint
- kubeconfig
- client_certificate
- client_key
- cluster_ca_certificate

*`Respostas:`*

### Utilização

```terraform
module "kind" {
  source             = "./1"
  cluster_name       = "loca"
  kubernetes_version = "v1.23.4"
}
```

### Saídas
```terraform
output "kubeconfig" {
  value = module.kind.kubeconfig
}

output "client_certificate" {
  value = module.kind.client_certificate
}

output "client_key" {
  value = module.kind.client_key
}

output "cluster_ca_certificate" {
  value = module.kind.cluster_ca_certificate
}

output "api_endpoint" {
  value = module.kind.api_endpoint
}
```

### Inputs

| Nome | Descrição | Tipo | Default | Requerido |
|------|-------------|:----:|:-----:|:-----:|
| cluster_name | Define o nome do cluster. | string | `"desafio"` | não |
| kubernetes_version | A Versão do Kubernets. | string | `"v1.23.4"` | não |



## 2. Gerenciando recursos customizados

Utilizando o provider `scottwinkler/shell`, crie um módulo que gerencie a instalação de pacotes em um ambiente linux (local).
Você pode utilizar qualquer gerenciador de pacotes (rpm, deb, tgz, ...).

O módulo deve ser capaz de:

- Instalar e desinstalar um pacote no host;
- Atualizar um pacote já instalado com a nova versão especificada;
- Reinstalar um pacote que foi removido manualmente (fora do terraform).

O módulo deve permitir, no mínimo, as seguintes variáveis:

- install_pkgs: lista de pacotes a serem instalados, com versão;
- uninstall_pkgs: lista de pacotes a serem desinstalados.

*`Respostas:`*

### Utilização

```terraform
module "pacotes" {
  source = "./2"
  apt_install = ["kubectl=1.6.2-00","sl","cowsay","figlet"]
  apt_remove  = ["curl"]
}
```

### Inputs

| Nome | Descrição | Tipo | Default | Requerido |
|------|-------------|:----:|:-----:|:-----:|
| apt_install | Lista com os pacotes desejados para instalar. | Lista | n/a | não |
| apt_remove | Lista com os pacotes indesejados para remover. | Lista | n/a | não |




## 3. Templates

Escreva um código para criar automaticamente o arquivo `alo_mundo.txt` a partir do template `alo_mundo.txt.tpl` abaixo:

```
Alo Mundo!

Meu nome é ${nome} e estou participando do Desafio Terraform da Getup/LinuxTips.

Hoje é dia ${data} e os números de 1 a 100 divisíveis por ${div} são: ${...}

```

Nota:

> A subtituição `${...}` deve ser gerada dinamicamente no formato `a, b, c, ...`
> onde `a`, `b`, `c`, ... são os números cuja divisão por `div` é exata (resto 0).
>
> Ex: Se `div = 15`, então o resultado em `${...}` será `15, 30, 45, 60, 75, 90`

*`Respostas:`*

### Utilização

```terraform
module "templates" {
  source = "./3"
  divisor = 1
}
```

### Inputs

| Nome | Descrição | Tipo | Default | Requerido |
|------|-------------|:----:|:-----:|:-----:|
| divisor | O divisor. | number | 1 | não |


## 4. Assumindo recursos

Descreva abaixo como você construiria um `resource` terraform a partir de um recurso já existente, como uma instância `ec2`.

*`Respostas:`*

Importando recursos para o terraform state:
https://www.terraform.io/cli/import/usage

- Fazendo um inventario, coletando informações dos recursos desejados importar para o código terraform.
- Listando os providers necessários
- Pegando a documentação dos providers que serão utilizados, por exemplo, o provider aws.
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
- Criando um código novo iniciando os providers e criando um novo tfstate. (exemplo no diretório ./4/exemplo_inicio)

```bash
# iniciando o tfstate
$ terraform init
# executando um plan para garantir que nada será criado
$ terraform plan -out=plan
# Escolhendo um recurso para iniciar, no caso uma EC2 com o ID de instância
$ terraform import aws_instance.docker i-0ef9fc1d3988cf6fd
# Ao rodar o comando acima ele irá sugerir um trecho de código para poder importar o recurso. Rodando novamente para realmente importar
$ terraform import aws_instance.docker i-0ef9fc1d3988cf6fd
# Após a importação do recurso pegar detalhes exportando o tfstate e criar código referenciando características do recurso existente que é desejada
$  terraform state pull > import.tfstate
# a cada adição no código comparar utilizando o plan até que não tenha mais diferenças entre o código e o tfstate
$ terraform plan -out=plan
# No changes. Your infrastructure matches the configuration.
```
- Repetir o processo até que todos os recursos e detalhes desejados estejam referenciados no código.
- Alterar o código utilizando variáveis em vez de valores fixos.
