resource "aws_security_group" "sq-desafio-terraform" {
  name        = "sq-desafio-terraform"
  description = "sq-desafio-terraform"
  vpc_id      = "vpc-0fc9e49420c6093ba"
}

resource "aws_security_group_rule" "ingressHTTP" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-0db2b0add013740bb"
}

resource "aws_security_group_rule" "ingressHTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-0db2b0add013740bb"
}

resource "aws_security_group_rule" "ingressSSH" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["189.61.35.36/32"]
  security_group_id = "sg-0db2b0add013740bb"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-0db2b0add013740bb"
}