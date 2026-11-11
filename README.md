# Zabbix Monitoring - EIT Logística

Documentación de configuración de monitoreo en Zabbix 6.0.26 para la infraestructura de servidores Windows de EIT Logística.

## Estructura del repositorio

```
docs/
├── 01-resumen-general.md          # Resumen del trabajo realizado
├── 02-tabla-a-accion-eitadmin.md   # Configuración de notificaciones (Tabla A)
├── 03-tabla-c-items.md             # Items del template personalizado (Tabla C)
├── 04-tabla-c-triggers.md          # Triggers del template personalizado (Tabla C)
├── 05-pasos-pendientes.md          # Pasos para activar el monitoreo
templates/
├── eit_custom_monitoring.yaml      # Template YAML de referencia con items y triggers
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

- ✅ Tabla A: Acción EITADMIN configurada con severidades Warning, Average, High y Disaster
- ✅ Tabla C: 9 items creados en el template
- ✅ Tabla C: 6 triggers creados en el template
- ⏳ Pendiente: Vincular template a los 16 servidores Windows
