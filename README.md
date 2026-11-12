# Zabbix Monitoring - EIT Logística

Documentación de configuración de monitoreo en Zabbix 6.0.26 para la infraestructura de servidores Windows y red de EIT Logística.

## Estructura del repositorio

```
docs/
├── monitoreo-personalizado/
│   ├── 01-resumen-general.md          # Resumen del trabajo realizado
│   ├── 02-tabla-a-accion-eitadmin.md   # Configuración de notificaciones (Tabla A)
│   ├── 03-tabla-c-items.md             # Items del template personalizado (Tabla C)
│   ├── 04-tabla-c-triggers.md          # Triggers del template personalizado (Tabla C)
│   └── 05-pasos-pendientes.md          # Pasos para activar el monitoreo
├── monitoreo-red/
│   ├── 01-resumen-configuracion.md     # Configuración inicial de monitoreo de red
│   ├── 02-pasos-pendientes.md          # Pasos pendientes para completar
│   └── 03-guia-agregar-switches.md     # Guía paso a paso para agregar switches
├── analisis/                           # Análisis de alertas
├── configuracion-parametros/           # UserParameters de Zabbix Agent
├── correos/                            # Respuestas a tickets
├── dashboard-widgets/                  # Widgets HTML personalizados
├── incidentes/                         # Documentación de incidentes y RCA
└── plan-fases/                         # Plan de implementación por fases
scripts/
└── dashboard-widgets/                  # Scripts PowerShell para UserParameters
templates/
└── eit_custom_monitoring.yaml          # Template YAML de referencia
```

## Datos del entorno

| Parámetro | Valor |
|-----------|-------|
| Servidor Zabbix | http://10.200.42.56/zabbix/ |
| Versión | 6.0.26 |
| Template | EIT Monitoreo Personalizado (ID: 10623) |
| Grupo de hosts | Windows Server (16 servidores) |
| Acción de notificación | EITADMIN |
| Usuario notificado | eitmon |

## Estado actual

### Monitoreo de servidores Windows
- ✅ Tabla A: Acción EITADMIN configurada con severidades Warning, Average, High y Disaster
- ✅ Tabla C: 9 items creados en el template
- ✅ Tabla C: 6 triggers creados en el template
- ⏳ Pendiente: Vincular template a los 16 servidores Windows

### Monitoreo de red (switches)
- ✅ Network Discovery SNMP creado (rango 10.200.42.1-254, SNMPv2 + ICMP)
- ✅ Dashboard "Monitoreo de Red - EIT" creado con widgets de Discovery Status y Problem Hosts
- ✅ 25+ dispositivos descubiertos en la red
- ⏳ Pendiente: Obtener credenciales SNMP de los switches
- ⏳ Pendiente: Crear host group "Equipos de Red" (requiere super admin)
- ⏳ Pendiente: Asignar templates SNMP y configurar monitoreo de interfaces por puerto
