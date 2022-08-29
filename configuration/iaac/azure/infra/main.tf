provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "nssazure" {
  name     = "nssazure-resources"
  location = "West Europe"
}

resource "azurerm_container_registry" "nssazure" {
  name                = "nssresearchAZCR"
  resource_group_name = azurerm_resource_group.nssazure.name
  location            = azurerm_resource_group.nssazure.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "nssazure" {
  name                = "nssazure-aks"
  location            = azurerm_resource_group.nssazure.location
  resource_group_name = azurerm_resource_group.nssazure.name
  dns_prefix          = "nssazureaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = f82640a4-ed9f-47b8-8d28-6c2af6acfcf1
    client_secret = 7KT8Q~_F1NnBv1s4DSqqCCmjzaG~vaRv_QF.ea6~
  }


  tags = {
    Environment = "Production"
  }
}

resource "azurerm_role_assignment" "nssazure" {
  principal_id                     = azurerm_kubernetes_cluster.nssazure.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.nssazure.id
  skip_service_principal_aad_check = true
}