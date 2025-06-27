#!/bin/bash

# Configuración inicial
RESOURCE_GROUP="FinOpsLab-RG"
LOCATION="eastus"
OWNER_TAG="TuNombre"
PROJECT_TAG="HA-Lab"

# Crear grupo de recursos con etiquetas FinOps
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags "proyecto=$PROJECT_TAG" "propietario=$OWNER_TAG" "ambiente=laboratorio"

# Obtener IP pública actual para seguridad
MY_IP=$(curl -s ifconfig.me)

# Crear red virtual y subred
az network vnet create \
  --name LabVnet \
  --resource-group $RESOURCE_GROUP \
  --address-prefix 10.0.0.0/16 \
  --subnet-name privateSubnet \
  --subnet-prefix 10.0.1.0/24

# Crear Network Security Group con reglas
az network nsg create \
  --name LabNSG \
  --resource-group $RESOURCE_GROUP

# Regla de seguridad: Permitir SSH solo desde tu IP (best practice)
az network nsg rule create \
  --name AllowSSH \
  --nsg-name LabNSG \
  --resource-group $RESOURCE_GROUP \
  --priority 100 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "$MY_IP/32" \
  --source-port-ranges "*" \
  --destination-port-ranges 22

# Regla para tráfico HTTP (puerto 80)
az network nsg rule create \
  --name AllowHTTP \
  --nsg-name LabNSG \
  --resource-group $RESOURCE_GROUP \
  --priority 110 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "*" \
  --destination-port-ranges 80

# Crear Availability Set para alta disponibilidad
az vm availability-set create \
  --name HAAvailabilitySet \
  --resource-group $RESOURCE_GROUP \
  --platform-fault-domain-count 2 \
  --platform-update-domain-count 2

# Crear Network Load Balancer
az network lb create \
  --name NLB-HA \
  --resource-group $RESOURCE_GROUP \
  --sku Standard \
  --vnet-name LabVnet \
  --subnet privateSubnet \
  --frontend-ip-name FrontEndIP \
  --backend-pool-name VMPool

# Configurar sondeo de salud (health probe)
az network lb probe create \
  --name HealthProbe \
  --lb-name NLB-HA \
  --resource-group $RESOURCE_GROUP \
  --protocol Tcp \
  --port 80

# Crear regla de balanceo (Round Robin)
az network lb rule create \
  --name HTTPRule \
  --lb-name NLB-HA \
  --resource-group $RESOURCE_GROUP \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name FrontEndIP \
  --backend-pool-name VMPool \
  --probe-name HealthProbe \
  --load-distribution RoundRobin

# Crear dos VMs en modo alta disponibilidad
for i in {1..2}; do
  az vm create \
    --name VM$i \
    --resource-group $RESOURCE_GROUP \
    --vnet-name LabVnet \
    --subnet privateSubnet \
    --nsg LabNSG \
    --availability-set HAAvailabilitySet \
    --image UbuntuLTS \
    --size Standard_B1ls \
    --admin-username azureuser \
    --authentication-type ssh \
    --ssh-key-value ~/.ssh/id_rsa.pub \
    --public-ip-address "" \
    --os-disk-delete-option delete \
    --data-disk-delete-option delete \
    --tags "proyecto=$PROJECT_TAG" "propietario=$OWNER_TAG" "ambiente=laboratorio"

  # Agregar VM al pool del balanceador
  az network nic ip-config update \
    --name ipconfigVM$i \
    --nic-name VM${i}VMNic \
    --resource-group $RESOURCE_GROUP \
    --lb-name NLB-HA \
    --lb-address-pools VMPool

  # Instalar nginx para pruebas (simulando app web)
  az vm run-command invoke \
    --resource-group $RESOURCE_GROUP \
    --name VM$i \
    --command-id RunShellScript \
    --scripts \
      "sudo apt update && sudo apt install nginx -y" \
      "echo '<h1>Servido desde VM$i</h1>' | sudo tee /var/www/html/index.html"
done

# Obtener IP pública del balanceador
LB_IP=$(az network lb frontend-ip show \
  --lb-name NLB-HA \
  --name FrontEndIP \
  --resource-group $RESOURCE_GROUP \
  --query "publicIpAddress" \
  --output tsv)

echo "Balanceador configurado en IP: $LB_IP"
