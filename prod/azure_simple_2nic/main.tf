provider "azurerm" {
 
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "asav-resources-we2nic"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "pip" {
  name                    = "outsie-pip"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "subnet-inside" {
  name                 = "inside"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "subnet-outside" {
  name                 = "outside"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
}



resource "azurerm_network_interface" "inside-int" {
  name                = "inside-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "inside"
    subnet_id                     = azurerm_subnet.subnet-inside.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "outside-int" {
  name                = "outside-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "outside"
    subnet_id                     = azurerm_subnet.subnet-outside.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


resource "azurerm_network_security_group" "asav-nsg" {
  name                = "asav-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_all"
    description                = "Allow all access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
resource "azurerm_network_interface_security_group_association" "nsginside" {
    network_interface_id      = azurerm_network_interface.inside-int.id
    network_security_group_id = azurerm_network_security_group.asav-nsg.id
}
resource "azurerm_network_interface_security_group_association" "nsgoutside" {
    network_interface_id      = azurerm_network_interface.outside-int.id
    network_security_group_id = azurerm_network_security_group.asav-nsg.id
}


resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.rg.name
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "asav-sa" {
  name                        = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "ASAv" {
  name                = "asav-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D4_v3"
  admin_username      = "adminuser"
  computer_name  = "asav-01"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.outside-int.id,
    azurerm_network_interface.inside-int.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("fillout.pub") #fill out with the filepath/name
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {

      storage_account_uri = azurerm_storage_account.asav-sa.primary_blob_endpoint
  }


  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-asav"
    sku       = "asav-azure-byol"
    version   = "913.1.0"
  }

  plan {
      name = "asav-azure-byol"
      product = "cisco-asav"
      publisher = "cisco"
  }
}