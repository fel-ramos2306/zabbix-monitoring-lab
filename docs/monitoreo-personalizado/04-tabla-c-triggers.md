# Tabla C — Triggers del Template (6)

## Ubicación en Zabbix

Configuration → Templates → **EIT Monitoreo Personalizado** → Triggers

## Triggers creados

| # | Nombre | Severidad | Cierre manual | Descripción |
|---|--------|-----------|---------------|-------------|
| 1 | Host {HOST.NAME} no responde a ICMP ping | High | No | El host no ha respondido al ping ICMP en las últimas 3 verificaciones |
| 2 | Pérdida de paquetes ICMP alta en {HOST.NAME} (>{ITEM.LASTVALUE}%) | Warning | No | Más del 20% de paquetes ICMP perdidos en los últimos 5 minutos |
| 3 | Tiempo de respuesta ICMP alto en {HOST.NAME} (>{ITEM.LASTVALUE}s) | Warning | No | Tiempo de respuesta ICMP promedio mayor a 500ms en los últimos 5 minutos |
| 4 | Error crítico en Event Log System de {HOST.NAME} | Average | Sí | Se detectó un error en el Event Log de Sistema de Windows |
| 5 | Error crítico en Event Log Application de {HOST.NAME} | Average | Sí | Se detectó un error en el Event Log de Aplicación de Windows |
| 6 | Servicio SQL Server detenido en {HOST.NAME} | High | Sí | El servicio SQL Server no está corriendo. Valor 0=running, 255=no existe |

## Expresiones de los triggers

### Trigger 1 — ICMP ping
```
max(/EIT Monitoreo Personalizado/icmpping,#3)=0
```
Se activa cuando las últimas 3 verificaciones de ping han fallado (valor 0).

### Trigger 2 — Pérdida de paquetes ICMP
```
min(/EIT Monitoreo Personalizado/icmppingloss,5m)>20
```
Se activa cuando el mínimo de pérdida de paquetes en 5 minutos supera el 20%.

### Trigger 3 — Tiempo de respuesta ICMP
```
avg(/EIT Monitoreo Personalizado/icmppingsec,5m)>0.5
```
Se activa cuando el promedio de tiempo de respuesta en 5 minutos supera 500ms (0.5s).

### Trigger 4 — Event Log System
```
nodata(/EIT Monitoreo Personalizado/eventlog[System,,,,,,^(Error)$],1800)=0 and length(last(/EIT Monitoreo Personalizado/eventlog[System,,,,,,^(Error)$]))>0
```
Se activa cuando hay datos en los últimos 30 minutos (1800s) y el último registro contiene un error.

### Trigger 5 — Event Log Application
```
nodata(/EIT Monitoreo Personalizado/eventlog[Application,,,,,,^(Error)$],1800)=0 and length(last(/EIT Monitoreo Personalizado/eventlog[Application,,,,,,^(Error)$]))>0
```
Misma lógica que el trigger 4 pero para el Event Log de Application.

### Trigger 6 — SQL Server
```
last(/EIT Monitoreo Personalizado/service.info[MSSQLSERVER,state])<>0 and last(/EIT Monitoreo Personalizado/service.info[MSSQLSERVER,state])<>255
```
Se activa cuando el servicio SQL Server no está corriendo (estado distinto de 0) y el servicio existe (estado distinto de 255).

## Notas

- Los triggers con **cierre manual** (4, 5, 6) requieren que un operador cierre el problema manualmente en Zabbix una vez resuelto.
- El trigger 6 excluye el valor 255 para evitar falsos positivos en servidores donde SQL Server no está instalado.
