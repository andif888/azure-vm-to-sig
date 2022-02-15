data "azurerm_managed_disk" "source" {
  name                = var.azure_source_managed_disk_name
  resource_group_name = var.azure_source_managed_disk_resource_group_name
}

resource "azurerm_resource_group" "vm" {
  name     = var.azure_temp_resource_group_name
  location = var.azure_location
}

resource "azurerm_virtual_network" "vm" {
  name                = var.azure_temp_virtual_network_name
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name
  address_space       = ["10.0.0.0/16"]

  tags       = { environment = "temp" }
  depends_on = [azurerm_resource_group.vm]
}

resource "azurerm_subnet" "vm" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.vm.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.vm]
}

resource "azurerm_managed_disk" "copy" {
  name                 = "${var.azure_temp_vm_name}-osdisk"
  resource_group_name  = azurerm_resource_group.vm.name
  location             = azurerm_resource_group.vm.location
  storage_account_type = "Standard_LRS"
  create_option        = "Copy"
  source_resource_id   = data.azurerm_managed_disk.source.id
  hyper_v_generation   = var.azure_temp_managed_disk_hyper_v_generation
  os_type              = "Windows"

  depends_on = [azurerm_resource_group.vm]
}

resource "azurerm_public_ip" "vm" {
  name                = "${var.azure_temp_vm_name}-pip"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  allocation_method   = "Dynamic"

  depends_on = [azurerm_resource_group.vm]
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.azure_temp_vm_name}-nic"
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location

  ip_configuration {
    name                          = "${var.azure_temp_vm_name}-ip"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
  depends_on = [azurerm_public_ip.vm]
}

resource "azurerm_virtual_machine" "vm" {
  name                  = var.azure_temp_vm_name
  resource_group_name   = azurerm_resource_group.vm.name
  location              = azurerm_resource_group.vm.location
  network_interface_ids = [azurerm_network_interface.vm.id]
  vm_size               = var.azure_temp_vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_os_disk {
    name              = azurerm_managed_disk.copy.name
    caching           = "ReadWrite"
    create_option     = "Attach"
    managed_disk_type = "Standard_LRS"
    os_type           = "Windows"
    managed_disk_id   = azurerm_managed_disk.copy.id
  }

  depends_on = [azurerm_managed_disk.copy, azurerm_network_interface.vm]
}

data "azurerm_public_ip" "applied" {
  name                = "${var.azure_temp_vm_name}-pip"
  resource_group_name = azurerm_resource_group.vm.name
  depends_on          = [azurerm_network_interface.vm, azurerm_virtual_machine.vm]
}


output "vm_public_ip" {
  value = data.azurerm_public_ip.applied.ip_address
}
