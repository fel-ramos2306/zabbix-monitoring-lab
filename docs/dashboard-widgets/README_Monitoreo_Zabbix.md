# Monitoreo Visual de Procesos — Zabbix Dashboard
## EIT Logística S.A. — EITAPP & EITWEB

**Fecha de implementación:** 11 de noviembre de 2026  
**Implementado por:** Felipe Ramos Farías — Supervisor de TI  
**Zabbix Server:** 6.0.26 — http://10.200.42.56/zabbix/  
**Zabbix Agent:** v2 (8.0.0)  
**Dashboard:** "Monitoreo EITAPP & EITWEB" (ID 331)

---

## Descripción General

Implementación de 4 widgets visuales en el dashboard de Zabbix que muestran tablas HTML con barras de colores indicando severidad. Los scripts PowerShell se ejecutan cada 5 minutos vía UserParameter y generan HTML que Zabbix renderiza en widgets Plain Text con la opción "Show text as HTML" habilitada.

### Widgets implementados

| Widget | Métrica | Script |
|--------|---------|--------|
| Top CPU Processes | Top 10 procesos por CPU | `top_cpu_processes.ps1` |
| Top Memory Processes | Top 10 procesos por Memoria | `top_mem_processes.ps1` |
| CPU Usage by User | Uso de CPU agrupado por usuario | `user_cpu_usage.ps1` |
| Memory Usage by User | Uso de memoria agrupado por usuario | `user_mem_usage.ps1` |

### Severidad por colores

**CPU (procesos individuales y por usuario):**
- Verde `#199e70` — < 50
- Amarillo `#c98500` — 50–99
- Naranja `#d95926` — 100–199
- Rojo `#e66767` — >= 200

**Memoria (procesos individuales):**
- Verde `#199e70` — < 256 MB
- Amarillo `#c98500` — 256–511 MB
- Naranja `#d95926` — 512–1023 MB
- Rojo `#e66767` — >= 1024 MB (1 GB)

**Memoria (por usuario):**
- Mismos umbrales que procesos individuales

---

## Arquitectura

```
┌──────────────────────────────────────────────────────┐
│                    Zabbix Server 6.0.26              │
│                    10.200.42.56                       │
│                                                      │
│  Template: "Windows by Zabbix agent" (ID 10081)      │
│  Dashboard: "Monitoreo EITAPP & EITWEB" (ID 331)    │
│  4 Items tipo Text, intervalo 5m                     │
│  4 Widgets Plain Text con "Show text as HTML"        │
└──────────────┬───────────────────────┬───────────────┘
               │                       │
    ┌──────────▼──────────┐ ┌──────────▼──────────┐
    │      EITWEB         │ │      EITAPP         │
    │  Zabbix Agent 2     │ │  Zabbix Agent 2     │
    │  v8.0.0             │ │  v8.0.0             │
    │                     │ │                     │
    │  Config:            │ │  Config:            │
    │  C:\Program Files\  │ │  C:\Program Files\  │
    │  Zabbix Agent 2\    │ │  Zabbix Agent 2\    │
    │  zabbix_agent2.conf │ │  zabbix_agent2.conf │
    │                     │ │                     │
    │  Scripts:           │ │  Scripts:           │
    │  C:\Zabbix\Scripts\ │ │  C:\Zabbix\Scripts\ │
    └─────────────────────┘ └─────────────────────┘
```

---

## Archivos Desplegados

### Scripts PowerShell

Ubicación en ambos servidores: `C:\Zabbix\Scripts\`

| Archivo | Descripción |
|---------|-------------|
| `top_cpu_processes.ps1` | Top 10 procesos por consumo de CPU con tabla HTML |
| `top_mem_processes.ps1` | Top 10 procesos por consumo de memoria con tabla HTML |
| `user_cpu_usage.ps1` | CPU agrupado por usuario con barras proporcionales |
| `user_mem_usage.ps1` | Memoria agrupada por usuario con barras proporcionales |

Cada script:
- Usa `$env:COMPUTERNAME` para mostrar el hostname en el encabezado
- Genera HTML inline con estilos (no requiere CSS externo)
- Muestra barras de color proporcionales al valor máximo
- Acorta nombres de usuario largos (dominio\usuario)
- Retorna el HTML vía `Write-Output`

### Configuración del Agente

Archivo: `C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf`

Líneas UserParameter agregadas (al final del archivo):

```ini
UserParameter=custom.top.cpu.processes,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\top_cpu_processes.ps1"
UserParameter=custom.top.mem.processes,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\top_mem_processes.ps1"
UserParameter=custom.user.cpu.usage,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\user_cpu_usage.ps1"
UserParameter=custom.user.mem.usage,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\user_mem_usage.ps1"
```

Parámetro adicional:
```ini
Timeout=30
```
> El timeout se aumentó a 30 segundos porque `Get-Process -IncludeUserName` puede tardar más de los 3 segundos por defecto.

---

## Items en Template Zabbix

Template: **"Windows by Zabbix agent"** (templateid 10081) — 16 hosts vinculados

| Item Key | Nombre | Tipo | Intervalo |
|----------|--------|------|-----------|
| `custom.top.cpu.processes` | Top CPU Processes | Text | 5m |
| `custom.top.mem.processes` | Top Memory Processes | Text | 5m |
| `custom.user.cpu.usage` | CPU Usage by User | Text | 5m |
| `custom.user.mem.usage` | Memory Usage by User | Text | 5m |

---

## Dashboard Widgets

Dashboard: **"Monitoreo EITAPP & EITWEB"** (dashboardid 331)

Cada widget es tipo **Plain Text** con las siguientes configuraciones:

| Configuración | Valor |
|---------------|-------|
| Show text as HTML | Habilitado |
| Items location | Top (recomendado) |
| Show lines | 25 |
| Show timestamp | Habilitado |

Widgets creados:

1. **Top CPU Processes - EITAPP & EITWEB**
   - Item: `custom.top.cpu.processes` (ambos hosts)

2. **Top Memory Processes - EITAPP & EITWEB**
   - Item: `custom.top.mem.processes` (ambos hosts)

3. **CPU Usage by User - EITAPP & EITWEB**
   - Item: `custom.user.cpu.usage` (ambos hosts)

4. **Memory Usage by User - EITAPP & EITWEB**
   - Item: `custom.user.mem.usage` (ambos hosts)

---

## Procedimiento de Despliegue en Nuevo Servidor

Para replicar en otro servidor (ej: EITAPPPUIG):

### 1. Copiar scripts

```powershell
# Crear directorio si no existe
New-Item -ItemType Directory -Path "C:\Zabbix\Scripts" -Force

# Copiar los 4 archivos .ps1 a C:\Zabbix\Scripts\
```

### 2. Configurar UserParameter

Editar `C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf` y agregar al final:

```ini
UserParameter=custom.top.cpu.processes,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\top_cpu_processes.ps1"
UserParameter=custom.top.mem.processes,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\top_mem_processes.ps1"
UserParameter=custom.user.cpu.usage,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\user_cpu_usage.ps1"
UserParameter=custom.user.mem.usage,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\user_mem_usage.ps1"
Timeout=30
```

> **IMPORTANTE:** Verificar que no existan líneas UserParameter duplicadas. Buscar con:
> ```powershell
> Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf" | Select-String "UserParameter=custom"
> ```

### 3. Reiniciar agente

```powershell
Restart-Service "Zabbix Agent 2"
Get-Service "Zabbix Agent 2"
```

### 4. Verificar en Zabbix

- Si el host usa el template "Windows by Zabbix agent", los items ya están heredados
- Si no, crear los 4 items manualmente (ver sección "Items en Template Zabbix")
- Agregar el host a los widgets existentes o crear widgets nuevos
- Esperar ~5 minutos para la primera recolección

---

## Troubleshooting

### El servicio Zabbix Agent 2 no arranca

```powershell
# Ver log de errores
Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.log" -Tail 20
```

**Error "duplicate user parameter":**
```powershell
# Buscar duplicados
$conf = "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf"
$content = Get-Content $conf
for ($i = 0; $i -lt $content.Length; $i++) {
    if ($content[$i] -match 'UserParameter=custom') {
        Write-Output "$($i+1): $($content[$i])"
    }
}

# Eliminar línea duplicada (reemplazar INDICE con el número de línea - 1)
$lines = [System.Collections.ArrayList]@(Get-Content $conf)
$lines.RemoveAt(INDICE)
Set-Content -Path $conf -Value $lines
Restart-Service "Zabbix Agent 2"
```

### Widget no muestra HTML (muestra texto plano)

- Editar el widget en el dashboard
- Verificar que "Show text as HTML" esté habilitado
- Guardar el dashboard

### Solo aparece un servidor en el widget

- Verificar que el agente esté corriendo en ambos servidores
- Verificar `Timeout=30` en la configuración
- Esperar al siguiente ciclo de recolección (5 minutos)

### Probar script manualmente

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\Scripts\top_cpu_processes.ps1"
```

### Probar desde Zabbix Server

```bash
zabbix_get -s <IP_DEL_HOST> -k custom.top.cpu.processes
```

---

## Historial de Cambios

| Fecha | Cambio | Responsable |
|-------|--------|-------------|
| 2026-11-11 | Implementación inicial en EITAPP y EITWEB | Felipe Ramos |
| 2026-11-11 | Agregado hostname en encabezado de scripts | Felipe Ramos |
| 2026-11-11 | Fix duplicados UserParameter en ambos servidores | Felipe Ramos |
| 2026-11-11 | Timeout aumentado a 30 segundos | Felipe Ramos |
