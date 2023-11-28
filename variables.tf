variable "authorized_keys" {}
variable "admin_user" {}
variable "region" {}
variable "node_count" {}
variable "instance_type" {}

resource "random_string" "password" {
  length  = 64
  special = true
  upper   = true
  lower   = true
  number  = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

variable "backups_enabled" {
  type    = bool
  default = false
}

variable "image" {}
variable "label" {
  default = "example_web_instance_label"
}
# variable "swap_size" {
#   #TODO: should be defined by the  instance size using the var linode_type..
#   description = "Swap size in MB."
#   type        = number
# }
variable "group" {
  type    = string
  default = "webservers"
}
variable "tags" {
  type    = list(string)
  default = ["example"]
}

variable "DOMAIN" {
  description = "Root or subdomain."
  type        = string
  default     = ""
}

variable "SITE" {
  description = "Site name of the project/app."
  default     = ""
}

variable "ID" {
  description = "Id of the release, usually an int."
  type        = number
  default     = 1
}

variable "create_users" {
  type    = bool
  default = false
}