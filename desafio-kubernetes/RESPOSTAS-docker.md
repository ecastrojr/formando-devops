# Desafio Docker

As questões abaixo devem ser respondidas no arquivo [RESPOSTAS-docker.md](RESPOSTAS-docker.md) em um fork desse repositório. Quanto mais sucinto e direto, melhor. Envie o endereço do seu repositório para desafio@getupcloud.com.

1. Execute o comando `hostname` em um container usando a imagem `alpine`. Certifique-se que o container será removido após a execução.

*`Resposta:`*

```bash
$ docker container run --rm  alpine hostname
Resolved "alpine" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull docker.io/library/alpine:latest...
Getting image source signatures
Copying blob 213ec9aee27d done  
Copying config 9c6f072447 done  
Writing manifest to image destination
Storing signatures
ba75ca20a85a
```


2. Crie um container com a imagem `nginx` (versão 1.22), expondo a porta 80 do container para a porta 8080 do host.

*`Resposta:`*

```bash
$ docker container run --name questao2 -p 8080:80 -d nginx:1.22
Resolved "nginx" as an alias (/home/alexcastro/.cache/containers/short-name-aliases.conf)
Trying to pull docker.io/library/nginx:1.22...
Getting image source signatures
Copying blob 55bbc49cb4de done  
Copying blob a8acafbf647e done  
Copying blob a3949c6b4890 done  
Copying blob b9e696b15b8a done  
Copying blob e9995326b091 done  
Copying blob 6cc239fad459 done  
Copying config 0ccb255938 done  
Writing manifest to image destination
Storing signatures
81cff8d4138658eb2192a831826cfedea354d6cd7da84596a6e87285402f508a
```

3. Faça o mesmo que a questão anterior (2), mas utilizando a porta 90 no container. O arquivo de configuração do nginx deve existir no host e ser read-only no container.

*`Resposta:`*

```vim
# Arquivo ./nginx-conf/default.conf
server {
    listen       90;
    listen  [::]:90;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
```


```bash
$ docker container run --name questao3 --mount type=bind,source=nginx-conf,target=/etc/nginx/conf.d,readonly -p 8080:90 -d nginx:1.22
```

4. Construa uma imagem para executar o programa abaixo:

```python
def main():
   print('Hello World in Python!')

if __name__ == '__main__':
  main()
```

*`Resposta:`*

```Dockerfile
FROM python:3

WORKDIR /usr/src/app

COPY app.py ./

CMD [ "python", "./app.py" ]

```

```bash
$ docker build -t python-app .
STEP 1/4: FROM python:3-alpine
Resolved "python" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull docker.io/library/python:3-alpine...
Getting image source signatures
Copying blob 0002f9a00c2b done  
Copying blob 213ec9aee27d done  
Copying blob 975aa27f4e8a done  
Copying blob 6a71c7b1785e done  
Copying blob 47858aee13bf done  
Copying config 5f9e8f452a done  
Writing manifest to image destination
Storing signatures
STEP 2/4: WORKDIR /usr/src/app
--> 1c3b90073a7
STEP 3/4: COPY app.py ./
--> a91c644d209
STEP 4/4: CMD [ "python", "./app.py" ]
COMMIT python-app
--> 8d51c1fa773
Successfully tagged localhost/python-app:latest
8d51c1fa77318096e628329788ecc9acc5c82c4544b466ceb577ac49f92cda2c

$ docker run -it --rm --name app python-app
Hello World in Python!

```

5. Execute um container da imagem `nginx` com limite de memória 128MB e 1/2 CPU.

*`Resposta:`*

```bash
$ docker container run -d -m 128M --cpus 0.5 -p 8080:80 --name nginx nginx
```

```bash
$ docker container inspect nginx
        "Memory": 134217728,
        "NanoCpus": 500000000,
```


6. Qual o comando usado para limpar recursos como imagens, containers parados, cache de build e networks não utilizadas?

*`Resposta:`*

```bash
$ docker system prune --all # adicionar --volumes para limpar também os volumes
```

7. Como você faria para extrair os comandos Dockerfile de uma imagem?

*`Resposta:`*

```bash
$ docker history --no-trunc --format '{{.CreatedBy}}' docker.io/library/nginx:latest | tac
```