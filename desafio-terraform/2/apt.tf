locals {
  cmd_print_version = jsonencode({
    "\"version\"" = "\"$(apt-cache policy $PACKAGE | grep --color=never Installed | sed 's/Installed: //')\""
  })
}

resource "shell_script" "instala_pacotes" {
  for_each = toset(var.apt_install)

  lifecycle_commands {
    create = format("sudo apt-get install -y --allow-downgrades --no-install-recommends $PACKAGE; echo %s", local.cmd_print_version)
    read   = format("echo %s", local.cmd_print_version)
    update = format("sudo apt-get install -y --allow-downgrades --no-install-recommends --reinstall $PACKAGE; echo %s", local.cmd_print_version)
    delete = "sudo apt-get remove -y $PACKAGE"
  }

  environment = {
    PACKAGE = each.value
  }
}

resource "shell_script" "remove_pacotes" {
  for_each = toset(var.apt_remove)

  lifecycle_commands {
    create = format("sudo apt-get remove -y $PACKAGE; echo %s", local.cmd_print_version)
    read   = format("echo %s", local.cmd_print_version)
    update = format("sudo apt-get remove -y $PACKAGE; echo %s", local.cmd_print_version)
    delete = "" #"sudo apt-get remove -y $PACKAGE"
  }

  environment = {
    PACKAGE = each.value
  }
}