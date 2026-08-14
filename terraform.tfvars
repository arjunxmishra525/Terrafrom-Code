RG = {
  RG-VNET = "central India"
}

NSG = {
  NSG1 = {
    name     = "Dev-NSG-test"
    location = "Central India"
    rg_name  = "RG-VNET"
  }
}

nsg-rule = {
  rule-ssh = {
    resource_group_name         = "RG-VNET"
    network_security_group_name = "Dev-NSG-test"
  }


}


VNET = {
  VNET1 = {
    name                = "prod-vnet-test"
    location            = "Central India"
    address_space       = ["10.0.0.0/16"]
    dns_servers         = ["10.0.1.4", "10.0.2.5"]
    resource_group_name = "RG-VNET"

  }
}
subnet = {
  subnet1 = {
    name                 = "Prod-VNET-Prefixs"
    resource_group_name  = "RG-VNET"
    virtual_network_name = "prod-vnet-test"
    address_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/27"]
  }
}

publicip = {
  pup-ip = {
    name                = "vm-public-ip"
    location            = "Central India"
    resource_group_name = "RG-VNET"
    allocation_method   = "Static"
  }
}


nic = {
  nic1 = {
    name                = "Prod-VM-NIC"
    location            = "Central India"
    resource_group_name = "RG-VNET"
    subnet_key          = "subnet1"
    public_ip_key       = "pup-ip"
  }
}

vm = {
  vm1 = {
    name                 = "prod-test-vm"
    rg_name              = "RG-VNET"
    size                 = "Standard_D2s_v3"
    admin_username       = "Devopsarjun"
    admin_password       = "Devops@12345"
    nic_key              = "nic1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    publisher            = "Canonical"
    offer                = "0001-com-ubuntu-server-jammy"
    sku                  = "22_04-lts"
    version              = "latest"
  }
}
