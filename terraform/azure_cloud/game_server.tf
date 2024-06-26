data "template_file" "game_user_data" {
  template = file("./game_server-init-actions.yaml")

  # left hand var names are the var names used in the cloud-init yaml.
  vars = {
    ansible_ssh_public_key        = file(var.ansible_ssh_public_key_filename)
    csgo_client_access_password   = var.csgo_client_access_password
    csgo_server_rcon_password     = var.csgo_server_rcon_password
    one_for_local_zero_for_global = var.csgo_one_for_local_zero_for_global
    csgo_server_name              = var.csgo_server_name
    steam_server_token            = var.csgo_steam_server_token
  }
}

data "template_cloudinit_config" "game_commoninit" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.game_user_data.rendered
  }
}

# Create public IPs
resource "azurerm_public_ip" "csgo_public_ip" {
  name                = "csgo-public-ip"
  resource_group_name = azurerm_resource_group.counterstrike_rg.name
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rules
# https://help.steampowered.com/en/faqs/view/2EA8-4D75-DA21-31EB
resource "azurerm_network_security_group" "csgo_nsg" {
  name                = "csgo-nsg"
  resource_group_name = azurerm_resource_group.counterstrike_rg.name
  location            = var.resource_group_location

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_public_ip
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "csgo-server"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "27015"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "csgo-steamworks"
    priority                   = 1110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    # https://forums.alliedmods.net/showthread.php?p=2217316
    # https://support.hashicorp.com/hc/en-us/articles/360042248153-How-to-configure-destination-port-ranges-for-Azure-resource-Manager-via-Terraform
    destination_port_ranges     = ["3478","4379","4380","26900-26901","27005","27014","27016-27030"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "csgo_nic" {
  name                = "csgoNIC"
  resource_group_name = azurerm_resource_group.counterstrike_rg.name
  location            = var.resource_group_location

  ip_configuration {
    name                          = "csgo_nic_configuration"
    subnet_id                     = azurerm_subnet.counterstrike_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.csgo_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "csgo_nsg_association" {
  network_interface_id      = azurerm_network_interface.csgo_nic.id
  network_security_group_id = azurerm_network_security_group.csgo_nsg.id
}




# Create virtual machine
resource "azurerm_linux_virtual_machine" "csgo_vm" {
  name                  = "csgoVM"
  resource_group_name   = azurerm_resource_group.counterstrike_rg.name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.csgo_nic.id]
  # https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-general
  #  D2a v4 or D4a v4
  # az vm list-sizes --location "northeurope"
  # az vm list-skus --location northeurope --size Standard_B --all --output table
  #size = "Standard_B1s"
  size = "Standard_D2_v4"

  # Provide the the cloud-init data.
  custom_data = data.template_cloudinit_config.game_commoninit.rendered

  os_disk {
    name    = "gameOsDisk"
    caching = "ReadWrite"
    # found this by creating a vm via web and then create an ARM template, in 'Parameters' tab
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "csgo"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = var.admin_public_ssh_key
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk
resource "azurerm_managed_disk" "csgo_data_disk" {
  name                 = "csgoDataDisk"
  resource_group_name = azurerm_resource_group.counterstrike_rg.name
  location            = var.resource_group_location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "40"
}

# https://stackoverflow.com/questions/69315208/adding-additional-storage-to-vm-with-terraform
resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.csgo_data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.csgo_vm.id
  lun                ="10"
  caching            = "ReadWrite"
}