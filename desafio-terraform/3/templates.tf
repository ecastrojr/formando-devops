locals {
  templates = [
    "alo_mundo.txt.tpl",
  ]
  calculo = [for x in range(100,0) : x if x%var.divisor == 0]

  templates_vars = {
    nome  = var.nome_aluno
    data  = formatdate("D", timestamp())
    div   = var.divisor
    resultado = jsonencode(local.calculo)
  }
}




resource "local_file" "templates" {
  for_each = toset(local.templates)
  content  = templatefile("${path.module}/templates/${each.value}", local.templates_vars)
  filename = pathexpand(replace("${each.value}",".tpl",""))
}