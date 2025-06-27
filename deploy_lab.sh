#!/bin/bash

# Variables globales
RG="lab-balancer"
LOCATION="eastus"
VM_SIZE="Standard_B1s"
IMAGE="UbuntuLTS"
USERNAME="azureuser"
PASSWORD="Password1234!" # solo para ejemplo, usar auth por clave en producción

# Etiquetas
TAGS="proyecto=laboratorio finops=true propietario=waton entorno=dev caducidad=7d"

az group create --name $RG --location $LOCATION --tags $TAGS

az network vnet create \
  --resource-group $RG \
  --name lab-vnet \
  --subnet-name lab-subnet \
  --tags $TAGS

  az network public-ip create \
  --resource-group $RG \
  --name lb-public-ip \
  --sku Basic \
  --allocation-method Static \
  --tags $TAGS

  az network lb create \
  --resource-group $RG \
  --name lab-lb \
  --frontend-ip-name lb-frontend \
  --backend-pool-name lb-backend-pool \
  --public-ip-address lb-public-ip \
  --sku Basic \
  --tags $TAGS

  az network lb probe create \
  --resource-group $RG \
  --lb-name lab-lb \
  --name health-probe \
  --protocol tcp \
  --port 80

az network lb rule create \
  --resource-group $RG \
  --lb-name lab-lb \
  --name lb-rule-web \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name lb-frontend \
  --backend-pool-name lb-backend-pool \
  --probe-name health-probe \
  --load-distribution Default

  for i in 1 2; do
  az network nic create \
    --resource-group $RG \
    --name nic-vm$i \
    --vnet-name lab-vnet \
    --subnet lab-subnet \
    --tags $TAGS
done

for i in 1 2; do
  az vm create \
    --resource-group $RG \
    --name vm$i \
    --nics nic-vm$i \
    --image $IMAGE \
    --size $VM_SIZE \
    --admin-username $USERNAME \
    --admin-password $PASSWORD \
    --no-wait \
    --tags $TAGS \
    --public-ip-address ""
done

for i in 1 2; do
  az vm run-command invoke \
    --command-id RunShellScript \
    --name vm$i \
    --resource-group $RG \
    --scripts "sudo apt-get update; sudo apt-get install -y apache2; echo 'Hola desde VM$i' | sudo tee /var/www/html/index.html"
done

for i in 1 2; do
  az network nic ip-config address-pool add \
    --address-pool lb-backend-pool \
    --ip-config-name ipconfig1 \
    --nic-name nic-vm$i \
    --resource-group $RG \
    --lb-name lab-lb
done
