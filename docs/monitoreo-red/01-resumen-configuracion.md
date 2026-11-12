# Monitoreo de Red - Configuración Inicial

**Fecha:** 2026-11-12  
**Objetivo:** Preparar Zabbix para monitoreo de switches de red (tráfico por puerto, estado de interfaces)

## Lo que se configuró

### 1. Trigger deshabilitado en eitretl

Se deshabilitó la alerta **"Windows: High memory utilization (>90% for 5m)"** en el host `eitretl` para evitar alertas falsas por uso de memoria al 90.04%.

- **Ruta:** Configuration > Hosts > eitretl > Triggers
- **Trigger:** `Windows: High memory utilization (>90% for 5m)`
- **Estado:** Deshabilitado

### 2. Regla de Network Discovery SNMP

Se creó la regla **"SNMP Network Discovery - EIT"** que escanea automáticamente la red en busca de dispositivos.

| Parámetro | Valor |
|-----------|-------|
| Nombre | SNMP Network Discovery - EIT |
| Rango IP | 10.200.42.1-254 |
| Intervalo | 1 hora |
| Check 1 | SNMPv2 agent — OID: sysDescr.0 (community: "public") |
| Check 2 | ICMP ping |

> **Nota:** El community string "public" es un placeholder. Debe reemplazarse por el valor real una vez que se obtengan las credenciales SNMP de los switches.

**Resultado:** La regla descubrió **más de 25 dispositivos activos** en la red, incluyendo servidores ya monitoreados (EITDC1, EITSQL, EITFS2, EITWEB) y otros equipos (EITAPP, EITFS, EITAC, EITGRAP, EITOPIS, etc.).

### 3. Dashboard "Monitoreo de Red - EIT"

Se creó un nuevo dashboard con dos widgets:

| Widget | Tipo | Descripción |
|--------|------|-------------|
| Estado Discovery Red | Discovery status | Muestra dispositivos Up/Down encontrados por la regla SNMP |
| Problemas Red | Problem hosts | Tabla de host groups con problemas activos |

**Ruta:** Monitoring > Dashboards > Monitoreo de Red - EIT
