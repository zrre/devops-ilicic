resource "azurerm_public_ip" "this" {
  name                = "pip-${var.vm_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.vm_name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "osdisk-${var.vm_name}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
#cloud-config
package_update: true

packages:
  - ca-certificates
  - curl
  - gnupg
  - lsb-release
  - apt-transport-https
  - docker.io
  - docker-compose-v2
  - dnsutils
  - jq

write_files:
  - path: /tmp/Dockerfile.simple-nginx
    permissions: '0644'
    content: |
      FROM nginx:alpine
      COPY index.html /usr/share/nginx/html/index.html

  - path: /tmp/index.simple-nginx.html
    permissions: '0644'
    content: |
      <!doctype html>
      <html>
        <head>
          <title>ACR Private Endpoint Test</title>
        </head>
        <body>
          <h1>Simple Nginx from Azure Container Registry via Private Endpoint</h1>
        </body>
      </html>

  - path: /tmp/docker-compose.simple-nginx.yml
    permissions: '0644'
    content: |
      services:
        simple-nginx:
          build:
            context: .
            dockerfile: Dockerfile
          image: ${var.acr_login_server}/simple-nginx:1.0
          ports:
            - "8080:80"

runcmd:
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker ${var.admin_username}
  - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
  - mkdir -p /opt/simple-nginx
  - cp /tmp/Dockerfile.simple-nginx /opt/simple-nginx/Dockerfile
  - cp /tmp/index.simple-nginx.html /opt/simple-nginx/index.html
  - cp /tmp/docker-compose.simple-nginx.yml /opt/simple-nginx/docker-compose.yml
  - chown -R ${var.admin_username}:${var.admin_username} /opt/simple-nginx
EOF
  )

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = var.acr_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_linux_virtual_machine.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "key_vault_secrets_officer" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_linux_virtual_machine.this.identity[0].principal_id
}