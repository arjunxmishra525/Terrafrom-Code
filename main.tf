#RG creation 

resource "azurerm_resource_group" "RG1" {
  for_each = var.RG
  name     = each.key
  location = each.value
}

#NSG Creation

resource "azurerm_network_security_group" "NSG1" {
  for_each            = var.NSG
  name                = each.value.name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.RG1[each.value.rg_name].name
}

# SSH Port allow Rule

resource "azurerm_network_security_rule" "rule" {
  depends_on                  = [azurerm_network_security_group.NSG1]
  for_each                    = var.nsg-rule
  name                        = "SSH-VM"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.network_security_group_name
}

# VNET Creation

resource "azurerm_virtual_network" "Vnet1" {
  for_each            = var.VNET
  name                = each.value.name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.RG1[each.value.resource_group_name].name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  tags = {
    environment = "Production"
  }
}

# Subnet Creation 

resource "azurerm_subnet" "subnet1" {
  depends_on = [ azurerm_virtual_network.Vnet1 ]
  for_each             = var.subnet
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes
}

# Public IP Creation 

resource "azurerm_public_ip" "publicip" {
depends_on = [ azurerm_resource_group.RG1 ]
  for_each            = var.publicip
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = "Standard"
}

#NIC Creation

resource "azurerm_network_interface" "NIC1" {
  depends_on = [azurerm_subnet.subnet1 ]
  for_each            = var.nic
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.public_ip_address_id
  }
}


# NIC association With NSG

resource "azurerm_network_interface_security_group_association" "Nsgassociation" {
  depends_on = [azurerm_network_interface.NIC1]
  network_interface_id      = "/subscriptions/47dee290-327a-4dce-bd51-67498ad35606/resourceGroups/RG-VNET/providers/Microsoft.Network/networkInterfaces/Prod-VM-NIC"
  network_security_group_id = "/subscriptions/47dee290-327a-4dce-bd51-67498ad35606/resourceGroups/RG-VNET/providers/Microsoft.Network/networkSecurityGroups/Dev-NSG-test"
}


#Linux VM 

resource "azurerm_linux_virtual_machine" "vm1" {
  depends_on = [azurerm_network_interface.NIC1 ]
  name                            = "prod-test-vm"
  resource_group_name             = "RG-VNET"
  location                        = "central india"
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  admin_password                  = "arjun!@#123"
  network_interface_ids           = azurerm_network_interface.NIC1.id
  disable_password_authentication = false
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

