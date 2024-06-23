variable "resource_group_location" {
  description = "Location of the resource group."
  default     = "northeurope"
}

variable "username" {
  description = "Name the admin user in the VM."
  default     = "ubuntu"
}

variable ansible_ssh_public_key_filename {
  type        = string
  description = "Location of ansible SSH public key file."
  default = "./private_admin_id_rsa.pub"
}

variable "csgo_client_access_password" {
  description = "Password clients use to connect to the server"
  default = "CheatersWillBeKicked"
}

variable "csgo_server_rcon_password" {
  description = "Password for accessing the rcon on the server"
  default = "SuperSecret"
}

variable "csgo_one_for_local_zero_for_global" {
  description = "0 = internet, 1 = LAN"
  default = "1"
}

variable "csgo_server_name" {
  description = "The name of the server displayed in the server browser"
  default = "You-Really-Need-To-Change-This"
}

variable "csgo_steam_server_token" {
  description = "GSLT token to allow csgo server to be listed in the public section of servers. https://steamcommunity.com/dev/managegameservers"
  default = "EMPTY"
}
