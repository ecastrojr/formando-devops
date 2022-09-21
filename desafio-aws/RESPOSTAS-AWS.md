# Desafio AWS

As questões abaixo devem ser respondidas no arquivo [RESPOSTAS-AWS.md](RESPOSTAS-AWS.md) em um fork desse repositório. Algumas questões necessitam de evidências visuais. Nesses casos, um snapshot da tela com o resultado esperado é o suficiente.
Nas demais questões, o formato é livre. Quanto mais sucinto e direto, melhor.
Envie o endereço do seu repositório para desafio@getupcloud.com.

# Preparação Inicial

1 - Você precisa instalar e configurar o aws-cli em seu equipamento: [AWS CLI Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

2 - Obtenha o AccessKey e SecretKey do seu usuário e configure o aws cli:

```
aws configure
AWS Access Key ID [****************]: [SEU ACCESS KEY AQUI]
AWS Secret Access Key [****************.]: [SEU SECRET KEY AQUI]
Default region name []: us-east-1
Default output format [None]:
```
Dúvidas: [AWS CLI Credentials](https://docs.aws.amazon.com/pt_br/IAM/latest/UserGuide/id_credentials_access-keys.html)


# Criação do Ambiente de Controle

Baixe esse repositório e execute:
```
cd desafio-aws
export STACK_NAME="stack-controle"
export STACK_FILE="file://aws-controle.json"
aws cloudformation create-stack --region us-east-1 --template-body "$STACK_FILE" --stack-name "$STACK_NAME" --no-cli-pager
aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME" (esse comando não possui output. Apenas liberará seu terminal quando a criação da stack finalizar)
```

Os comandos acima criarão na região US-EAST-1 da sua conta AWS os seguintes recursos:
- 1 VPC
- 4 Subnets
- 1 Internet Gateway
- 1 EC2

Execute o comando abaixo, copie o IP e abra em seu navegador:
```
aws cloudformation describe-stacks --region us-east-1 --query "Stacks[?StackName=='"$STACK_NAME"'][].Outputs[?OutputKey=='PublicIp'].OutputValue" --output text --no-cli-pager
```

Se tudo ocorreu bem até aqui, você verá um texto que remete ao desafio e o recurso que acabou de ser criado.

Agora, reserve um tempo para analisar os recursos que foram criados e suas configurações. Após isso, **destrua esse ambiente** e vamos ao desafio!

```
aws cloudformation delete-stack --region us-east-1 --stack-name "$STACK_NAME"
```

# Desafio AWS

## 1 - Setup de ambiente

Execute os mesmos passos de criação de ambiente descritos anteriormente, ***porém atenção:*** dessa vez utilize o arquivo "formandodevops-desafio-aws.json"

```
export STACK_FILE="file://formandodevops-desafio-aws.json"
aws cloudformation create-stack --region us-east-1 --template-body "$STACK_FILE" --stack-name "$STACK_NAME" --no-cli-pager
aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"
```
**`Resposta:`**
```bash
$ aws cloudformation delete-stack --region us-east-1 --stack-name "$STACK_NAME"
$ export STACK_NAME="stack-desafio"
$ export STACK_FILE="file://formandodevops-desafio-aws.json"
$ aws cloudformation create-stack --region us-east-1 --template-body "$STACK_FILE" --stack-name "$STACK_NAME" --no-cli-pager
$ aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"
$ aws cloudformation describe-stacks --region us-east-1 --query "Stacks[?StackName=='"$STACK_NAME"'][].Outputs[?OutputKey=='PublicIp'].OutputValue" --output text --no-cli-pager
18.204.4.2
```

## 2 - Networking

A página web dessa vez não está sendo exibida corretamente. Verifique as **configurações de rede** que estão impedindo seu funcionamento.

**`Resposta:`**

A regra do grupo de segurança estava configurada com um intervalo(81-8080) de portas diferente do que a instancia EC2 estava escutando(80). A Origem também estava configurada para 0.0.0.0/1, alterado para 0.0.0.0/0. 

![Após editar a regra foi possível acessar](2-Networking.png)

## 3 - EC2 Access

Para acessar a EC2 por SSH, você precisa de uma *key pair*, que **não está disponível**. Pesquise como alterar a key pair de uma EC2.

**`Resposta:`**
Acredito que o jeito mais rápido e fácil é utilizar o "Gerenciador de Sessões".

Ref: https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-quick-setup.html

Habilitado através do "Quick setup" somente na instancia sem a key pair, criado uma nova chave na console aws e liberado a porta 22 para meu IP no security group.

Para recuperar a chave publica após gerar uma nova:

```bash
$ ssh-keygen -y -f desafio-aws.pem
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOspjTbxjIORKZ8klztW3CBOPBNmAyLK2fseT6cZs4Qg
```

![Gerenciador de Sessões](3-EC2Access.png)


Após trocar a key pair

1 - acesse a EC2:
```
ssh -i [sua-key-pair] ec2-user@[ip-ec2]
```

**`Resposta:`**
```bash
ssh -i desafio-aws.pem ec2-user@18.204.4.2
The authenticity of host '18.204.4.2 (18.204.4.2)' cant be established.
ED25519 key fingerprint is SHA256:Eu2bY3yBL8/cH3VaTnElgoCQiWX5f11dAQET/Cxiroo.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '18.204.4.2' (ED25519) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
48 package(s) needed for security, out of 91 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-10-0-1-114 ~]$ 
```

2 - Altere o texto da página web exibida, colocando seu nome no início do texto do arquivo ***"/var/www/html/index.html"***.

**`Resposta:`**
```bash
$ cat /var/www/html/index.html
<html><body><h1>Formando DevOps - EC2 Rodando na Region: us-east-1<h1></body></html>
$ sudo sed -i 's/Formando/Euclides A. de Castro Jr - Formando/' /var/www/html/index.html 
```
![web após edição](3.2-web.png)

## 4 - EC2 troubleshooting

No último procedimento, A EC2 precisou ser desligada e após isso o serviço responsável pela página web não iniciou. Encontre o problema e realize as devidas alterações para que esse **serviço inicie automaticamente durante o boot** da EC2.

**`Resposta:`**

Não foi necessário desligar o servidor para alterar a key pair, mas reiniciei manualmente para causar a falha.

```bash
$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: man:httpd.service(8)
$ sudo systemctl enable httpd
Created symlink from /etc/systemd/system/multi-user.target.wants/httpd.service to /usr/lib/systemd/system/httpd.service.
$ sudo systemctl start httpd
```

## 5 - Balanceamento

Crie uma cópia idêntica de sua EC2 e inicie essa segunda EC2. Após isso, crie um balanceador, configure ambas EC2 nesse balanceador e garanta que, **mesmo com uma das EC2 desligada, o usuário final conseguirá acessar a página web.**

**`Resposta:`**

```
Para criar uma Imagens de máquina da Amazon (AMIs)
Na tela de instancias EC2: Ações > Imagem e modelos > Criar uma imagem
Para criar uma nova instancia a partir de uma AMI customizada:
Na tela Imagens > AMIs selecionar a AMI recém criada e botão "Executar Instância na AMI"
Criado um Target Group apontando para as duas instâncias com Health Check
Criado um Application Load Balancer

```


## 6 - Segurança

Garanta que o acesso para suas EC2 ocorra somente através do balanceador, ou seja, chamadas HTTP diretamente realizadas da sua máquina para o EC2 deverão ser barradas. Elas **só aceitarão chamadas do balanceador** e esse, por sua vez, aceitará conexões externas normalmente.

**`Resposta:`**
