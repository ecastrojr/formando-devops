resource "aws_instance" "docker" {
  ami           = "ami-026b57f3c383c2eec"
  instance_type = "t2.micro"
  key_name      = "desafio-aws2.pem"
  subnet_id     = "subnet-0362d86d0de23917b"
  vpc_security_group_ids = ["sg-0db2b0add013740bb"]
  

  tags = {
    Name = "desafio-terraform"
  }
}