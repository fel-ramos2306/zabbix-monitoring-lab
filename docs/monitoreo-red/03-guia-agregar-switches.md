# Guía: Agregar Switches al Monitoreo

Una vez que se tengan los accesos y credenciales SNMP, seguir estos pasos para completar el monitoreo de red.

## Paso 1 — Crear host group "Equipos de Red"

1. Ir a **Configuration > Host groups > Create host group**
2. Nombre: `Equipos de Red`
3. Guardar

> Requiere permisos de super admin.

## Paso 2 — Crear Discovery Actions

Las Discovery Actions automatizan la incorporación de switches descubiertos como hosts monitoreados.

1. Ir a **Configuration > Actions > Discovery actions > Create action**
2. Configurar:

**Pestaña Action:**
| Campo | Valor |
|-------|-------|
| Name | Auto-agregar switches SNMP |
| Conditions | Discovery rule = "SNMP Network Discovery - EIT" |
| | Discovery check = SNMPv2 agent |
| | Discovery status = Up |

**Pestaña Operations:**
| Operación | Valor |
|-----------|-------|
| Add host | ✓ |
| Add to host groups | Equipos de Red |
| Link to templates | (según marca del switch — ver Paso 3) |

## Paso 3 — Asignar templates SNMP

Zabbix 6.0 incluye 115+ templates de red. Según la marca del switch:

| Marca | Template recomendado |
|-------|---------------------|
| Cisco | `Cisco IOS by SNMP` o `Cisco Catalyst by SNMP` |
| HP / HPE | `HP Enterprise Switch by SNMP` |
| Mikrotik | `MikroTik by SNMP` |
| D-Link | `D-Link DES/DGS by SNMP` |
| TP-Link | `TP-Link by SNMP` |
| Genérico | `Network Generic Device by SNMP` |

### Template clave: "Interfaces by SNMP"

Además del template específico de la marca, agregar **"Interfaces by SNMP"** (ubicado en `Templates/Modules`) a cada switch. Este template:

- Usa **LLD (Low-Level Discovery)** para descubrir automáticamente todas las interfaces/puertos
- Monitorea por cada puerto:
  - Tráfico entrante y saliente (bits/s)
  - Errores de entrada/salida
  - Descartes (discards)
  - Estado operacional (up/down)
  - Velocidad del enlace

### Cómo asignar templates a un host existente

1. **Configuration > Hosts** > click en el switch
2. Pestaña **Templates**
3. En "Link new templates", buscar y agregar:
   - El template de la marca (ej: `Cisco IOS by SNMP`)
   - `Interfaces by SNMP`
4. Click **Update**

### Configurar macros SNMP en el host

En la pestaña **Macros** del host:

| Macro | Valor |
|-------|-------|
| `{$SNMP_COMMUNITY}` | (community string real) |
| `{$SNMP.TIMEOUT}` | 5s |

Si es SNMPv3:

| Macro | Valor |
|-------|-------|
| `{$SNMPV3_USER}` | (usuario) |
| `{$SNMPV3_AUTH_PROTOCOL}` | SHA o MD5 |
| `{$SNMPV3_AUTH_PASSPHRASE}` | (contraseña auth) |
| `{$SNMPV3_PRIV_PROTOCOL}` | AES o DES |
| `{$SNMPV3_PRIV_PASSPHRASE}` | (contraseña priv) |

## Paso 4 — Verificar descubrimiento de interfaces

Después de aplicar los templates, esperar ~1 hora para que el LLD descubra los puertos.

1. Ir a **Monitoring > Latest data**
2. Filtrar por el host del switch
3. Buscar items que contengan "Interface"
4. Verificar que aparezcan datos de tráfico por cada puerto

También se puede revisar en **Configuration > Hosts > (switch) > Discovery rules** que las reglas LLD estén activas y hayan encontrado interfaces.

## Paso 5 — Agregar widgets al dashboard

En el dashboard **"Monitoreo de Red - EIT"**, agregar widgets para visualizar el tráfico:

### Widget: Gráfico de tráfico por interfaz
- Tipo: **Graph (classic)**
- Host: (seleccionar switch)
- Graph: "Network traffic" o el gráfico generado por LLD para cada interfaz

### Widget: Top puertos con mayor tráfico
- Tipo: **Top hosts**
- Host group: Equipos de Red
- Columns: agregar "Bits received" y "Bits sent"
- Order: By "Bits received" descendente

### Widget: Estado de puertos
- Tipo: **Data overview**
- Host group: Equipos de Red
- Items: filtrar por "Operational status"
- Muestra un mapa de calor con el estado up/down de todos los puertos

## Resultado esperado

Con esta configuración se logra la visualización completa:
- **Qué bocas están conectadas** → estado operacional de cada puerto (up/down)
- **Cuánto tráfico pasa por cada una** → gráficos de bits/s entrante y saliente por puerto
- **Problemas de red** → alertas automáticas por interfaces caídas, errores o saturación
