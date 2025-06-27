# Laboratorio-Azure-con-Network-Load-Balancer-y-Alta-Disponibilidad
Aplicando buenas prácticas de FinOps, etiquetado, seguridad y optimización de costos
 Laboratorio Azure: Network Load Balancer con Alta Disponibilidad

Implementación de una infraestructura de alta disponibilidad en Azure usando un Network Load Balancer y dos VMs con balanceo Round Robin. Este laboratorio aplica mejores prácticas de FinOps, seguridad y optimización de costos.

## Características Clave
✅ **FinOps Avanzado**  
- Etiquetado detallado (`proyecto`, `propietario`, `ambiente`)
- Uso de recursos Free Tier (`Standard_B1ls`)
- Eliminación automática de recursos post-laboratorio

🔒 **Seguridad Reforzada**  
- NSG con reglas mínimas necesarias
- Acceso SSH restringido a IP del administrador
- VMs sin IP pública (protegidas tras balanceador)

🔄 **Alta Disponibilidad**  
- Availability Set con múltiples dominios de fallo
- Balanceo de carga Round Robin
- Health probes para monitoreo continuo

## Componentes Implementados
- 1 Network Load Balancer (Standard SKU)
- 2 Máquinas Virtuales Ubuntu (Free Tier)
- 1 Virtual Network con subred privada
- 1 Network Security Group (NSG)
- 1 Availability Set

## Buenas Prácticas Aplicadas
| Área          | Implementación                                                                 |
|---------------|--------------------------------------------------------------------------------|
| **FinOps**    | Etiquetado para costos, SKUs Free Tier, eliminación automática                 |
| **Seguridad** | NSG restrictivo, IPs privadas, mínimo acceso necesario                         |
| **Operaciones**| Alta disponibilidad, health probes, configuración idempotente con CLI          |
| **Costos**    | Uso de `Standard_B1ls` (0.0052 USD/hora), discos administrados eliminables     |

## Instrucciones de Uso
```bash
# Implementar laboratorio
bash deploy_lab.sh

# Verificar funcionamiento
curl <IP-del-balanceador>
# Realizar múltiples peticiones para ver Round Robin

# Eliminar todos los recursos (post-laboratorio)
az group delete -g FinOpsLab-RG --yes
Estructura del Repositorio
deploy_lab.sh: Script de implementación completo

README.md: Esta documentación

cleanup.sh: Alternativa para eliminación de recursos

Nota: Todos los recursos incluyen etiquetas para seguimiento de costos (proyecto, propietario, ambiente)

text

Esta descripción:
1. Destaca las mejores prácticas implementadas
2. Muestra claramente la arquitectura y componentes
3. Incluye tablas resumen de buenas prácticas
4. Proporciona instrucciones ejecutables
5. Enfatiza el enfoque FinOps y de seguridad
6. Usa emojis y formato claro para mejor legibilidad
