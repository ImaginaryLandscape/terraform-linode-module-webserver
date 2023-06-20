locals {
  ssh_keys = [
    for value in toset(var.authorized_keys) : chomp(file(value))    
  ]
}

locals {
  ssh_keys_str = join("\n\n", local.ssh_keys)
}

resource "linode_sshkey" "authKeys" {
  for_each        = toset(local.ssh_keys)
  label           = "Initial deploy SSH key"
  ssh_key         = each.value
}

resource "linode_instance" "web" {
  count           = var.node_count
  label           = "${var.SITE}-web${var.ID + count.index}.${var.DOMAIN}"
  image           = var.image
  region          = var.region
  type            = var.instance_type
  backups_enabled = var.backups_enabled
  authorized_keys = local.ssh_keys
  root_pass       = random_string.password.result
  group           = var.group
  tags            = var.tags
  private_ip      = true

  connection {
    type     = "ssh"
    user     = "root"
    password = random_string.password.result
    host     = self.ip_address
  }

  provisioner "file" {
    source      = "sshd_public_key_only.conf"
    destination = "/etc/ssh/sshd_config.d/sshd_public_key_only.conf"
  }

  provisioner "file" {
    source      = "access_setup.sh"
    destination = "/tmp/access_setup.sh"
  }

    provisioner "file" {
    source      = "user.txt"
    destination = "/tmp/user.txt"
  }

   provisioner "file" {
    source      = "useradd.sh"
    destination = "/tmp/useradd.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/access_setup.sh",
      "sudo sh /tmp/access_setup.sh -u ${var.admin_user} -k '${local.ssh_keys_str}'",
      "sudo bash -c \"echo '${var.admin_user}:${random_string.password.result}' | sudo chpasswd\"",
      "service sshd restart",
      "sudo hostnamectl set-hostname '${var.SITE}-web${var.ID + count.index}.${var.DOMAIN}'" 
    ]
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     # add imagescape user
  #     "sudo addgroup worker",
  #     "sudo useradd -d /home/imagescape -s /bin/bash -G sudo,worker -s /bin/bash imagescape",
  #     "sudo bash -c \"echo 'imagescape:${random_string.password.result}' | sudo chpasswd\"",
  #     "sudo mkdir /home/imagescape /home/imagescape/.ssh/",
  #     "sudo bash -c \"echo '${local.ssh_keys_str}' >> /home/imagescape/.ssh/authorized_keys\" ",
  #     "sudo chown -R imagescape:imagescape /home/imagescape",
  #     "sudo chmod 700 /home/imagescape/.ssh/",
  #     "sudo chmod 600 /home/imagescape/.ssh/authorized_keys",
  #     "sudo service sshd restart"
  #    ]
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/setup_script.sh",
  #     "/tmp/setup_script.sh ${count.index + 1}",
  #   ]
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     # install NGINX
  #     "export PATH=$PATH:/usr/bin",

  #     "apt-get -q update",
  #     "mkdir -p /var/www/html/",
  #     "mkdir -p /var/www/html/healthcheck",
  #     "echo healthcheck > /var/www/html/healthcheck/index.html",
  #     "echo node ${count.index + 1} > /var/www/html/index.html",
  #     "apt-get -q -y install nginx",
  #   ]
  # }

}

