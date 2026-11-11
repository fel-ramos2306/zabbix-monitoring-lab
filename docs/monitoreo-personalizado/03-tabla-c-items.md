# Tabla C — Items del Template (9)

## Ubicación en Zabbix

Configuration → Templates → **EIT Monitoreo Personalizado** → Items

## Items creados

| # | Nombre | Tipo | Key | Intervalo | Tipo de información | Unidades | Descripción |
|---|--------|------|-----|-----------|---------------------|----------|-------------|
| 1 | ICMP ping | Simple check | `icmpping` | 1m | Numeric (unsigned) | — | Verifica si el host responde a ICMP ping (1=OK, 0=Fallo) |
| 2 | ICMP packet loss | Simple check | `icmppingloss` | 1m | Numeric (float) | % | Porcentaje de paquetes ICMP perdidos |
| 3 | ICMP response time | Simple check | `icmppingsec` | 1m | Numeric (float) | s | Tiempo de respuesta ICMP en segundos |
| 4 | Windows Event Log - System Errors | Zabbix agent (active) | `eventlog[System,,,,,,^(Error)$]` | 1m | Log | — | Monitorea errores críticos en el Event Log de Sistema de Windows |
| 5 | Windows Event Log - Application Errors | Zabbix agent (active) | `eventlog[Application,,,,,,^(Error)$]` | 1m | Log | — | Monitorea errores críticos en el Event Log de Aplicación de Windows |
| 6 | Windows Service - Zabbix Agent status | Zabbix agent (active) | `service.info[Zabbix Agent,state]` | 1m | Numeric (unsigned) | — | Estado del servicio Zabbix Agent en Windows |
| 7 | Windows Service - Windows Update status | Zabbix agent (active) | `service.info[wuauserv,state]` | 5m | Numeric (unsigned) | — | Estado del servicio Windows Update |
| 8 | Windows Service - SQL Server status | Zabbix agent (active) | `service.info[MSSQLSERVER,state]` | 1m | Numeric (unsigned) | — | Estado del servicio SQL Server (si existe) |
| 9 | Backup folder last modification | Zabbix agent (active) | `vfs.file.time[C:\Backup,modify]` | 1h | Numeric (unsigned) | unixtime | Última modificación del directorio de backups |

## Notas técnicas

- **Items 1–3 (Simple check):** Ejecutados directamente por el servidor Zabbix. No requieren agente instalado en los hosts.
- **Items 4–9 (Zabbix agent active):** Requieren que el Zabbix Agent esté instalado y configurado en cada servidor Windows con `ServerActive=10.200.42.56` en el archivo de configuración del agente.
- **Item 9 (Backup):** Intervalo de 1 hora para no sobrecargar el sistema de archivos con verificaciones frecuentes.
