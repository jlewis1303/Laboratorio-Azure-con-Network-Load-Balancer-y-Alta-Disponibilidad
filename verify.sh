Verificación de Funcionamiento
Probar acceso HTTP:

bash
# Realizar 4 peticiones para ver Round Robin
for i in {1..4}; do
  curl $LB_IP
done
Salida esperada (alterna entre VMs):

html
<h1>Servido desde VM1</h1>
<h1>Servido desde VM2</h1>
<h1>Servido desde VM1</h1>
<h1>Servido desde VM2</h1>
Verificar estado del balanceador:

bash
az network lb show \
  --name NLB-HA \
  --resource-group $RESOURCE_GROUP \
  --query "{provisioningState:provisioningState, backendPool:backendAddressPools[0].backendIpConfigurations}"
