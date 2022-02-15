data "azurerm_resource_group" "sig" {
  name = var.azure_sig_resource_group_name
}
data "azurerm_resource_group" "vm" {
  name = var.azure_temp_resource_group_name
}

data "azurerm_managed_disk" "vm" {
  name                = var.azure_temp_managed_disk_name
  resource_group_name = data.azurerm_resource_group.vm.name
}

resource "azurerm_image" "generalized" {
  name                = var.azure_temp_image_name
  location            = data.azurerm_resource_group.sig.location
  resource_group_name = data.azurerm_resource_group.sig.name
  hyper_v_generation  = var.azure_temp_managed_disk_hyper_v_generation
  # source_virtual_machine_id = data.azurerm_virtual_machine.search.id

  os_disk {
    os_type         = "Windows"
    os_state        = "Generalized"
    managed_disk_id = data.azurerm_managed_disk.vm.id
    caching         = "ReadWrite"
  }
}

output "managed_image_id" {
  value = azurerm_image.generalized.id
}
