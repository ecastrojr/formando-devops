variable "apt_install" {
  type = list
  description = "Lista com dos pacotes desejados para instalar"
  default = []
  #default = ["kubectl=1.6.2-00","sl","cowsay","figlet"]

}

variable "apt_remove" {
  type = list
  description = "Lista com dos pacotes indesejados para remover"
  default = []
  #default = ["curl"]

}