# terraform-module-linode-webserver

## Module

Invoke this module from the root `main.tf` file.

```hcl
module "webserver" {
  source            = "../modules/terraform-linode-module-webserver"
  admin_user        = var.admin_user
  authorized_keys   = var.authorized_keys
  region            = var.LN_REGION
  group             = var.linode_web_instance_group
  image             = var.linode_web_instance_image
  instance_type     = var.linode_web_instance_type
  node_count        = var.linode_web_instance_node_count
  tags              = var.linode_web_instance_tags
  SITE              = var.SITE
  ID                = var.ID
  DOMAIN            = var.DOMAIN
  backups_enabled   = var.linode_web_instance_backups_enabled
  create_users      = var.create_users
}
```
