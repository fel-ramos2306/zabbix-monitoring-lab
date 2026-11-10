# Incidente: Falsa Alarma "Zabbix Agent is not running" en EIT APP

**Fecha del incidente:** 09 de noviembre de 2026  
**Responsable de resolución:** Felipe Ramos  
**Sistema afectado:** Zabbix 6.0.26 — Host EITAPP  
**Estado:** ✅ Resuelto

---

## 1. Descripción del Problema

En el dashboard "Monitor Plataforma" de Zabbix (http://10.200.42.56/zabbix), se detectó una alerta activa de severidad **Average** en el host **EIT APP** desde las 20:50:59 hrs:

> **"Zabbix Agent" (Zabbix Agent) is not running (startup type automatic)**

- **Operational data:** No such service (255)
- **Duración al momento de detección:** ~7 minutos

## 2. Diagnóstico

### 2.1 Verificación Local (PC de soporte)

Se ejecutó en PowerShell local:

\`\`\`powershell
Get-Service *zabbix*
\`\`\`

**Resultado:**

| Status  | Name           | DisplayName    |
|---------|----------------|----------------|
| Running | Zabbix Agent 2 | Zabbix Agent 2 |

El equipo local tiene **Zabbix Agent 2** corriendo correctamente. La alerta no corresponde a este equipo sino al host EIT APP.

### 2.2 Verificación en Servidor EIT APP (vía RDP)

Se accedió al servidor EIT APP por RDP y se ejecutaron las siguientes verificaciones:

**Versión del agente instalado:**

\`\`\`powershell
& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t agent.version
\`\`\`

**Resultado:** \`agent.version [s|8.0.0]\`

**Servicio activo:**

\`\`\`powershell
Get-Service *zabbix*
\`\`\`

| Status  | Name           | DisplayName    |
|---------|----------------|----------------|
| Running | Zabbix Agent 2 | Zabbix Agent 2 |

**Servicio "Zabbix Agent" (v1):**

\`\`\`powershell
Get-Service "Zabbix Agent"
\`\`\`

**Resultado:** \`No se encuentra ningún servicio con el nombre 'Zabbix Agent'\`

### 2.3 Hallazgo — Causa Raíz

El servidor EIT APP fue migrado de **Zabbix Agent v1** a **Zabbix Agent 2 (v8.0.0)**. El servicio antiguo "Zabbix Agent" ya no existe en el sistema operativo.

Sin embargo, la regla de **Windows services discovery** de Zabbix había creado automáticamente un item y un trigger que monitoreaban el servicio con el nombre antiguo:

- **Item:** \`service.info["Zabbix Agent",state]\` — Discovered por "Windows services discovery"
- **Trigger:** \`"Zabbix Agent" (Zabbix Agent) is not running\`
- **Expression:** \`min(/EITAPP/service.info["Zabbix Agent",state],#3)<>0\`
- **Severidad:** Average

Como el servicio "Zabbix Agent" (v1) no existe, el item retornaba "No such service (255)", activando permanentemente el trigger.

## 3. Resolución

### Pasos ejecutados en Zabbix:

1. **Navegación:** Menú lateral → Configuration → Hosts
2. **Filtro:** Se buscó el host EITAPP (IP: 10.200.42.32, puerto 10050)
3. **Items:** Se ingresó a Items del host (97 items, 70 triggers)
4. **Búsqueda:** Se filtró por Name = "Zabbix Agent"
5. **Identificación del item problemático:**
   - Nombre: \`State of service "Zabbix Agent" (Zabbix Agent)\`
   - Key: \`service.info["Zabbix Agent",state]\`
   - Tipo: Zabbix agent
   - Origen: Windows services discovery (Discovered)
6. **Acceso al trigger:** Desde el menú contextual (···) del item → Triggers → \`"Zabbix Agent" (Zabbix Agent) is not running\`
7. **Deshabilitación:** Se desmarcó el checkbox **Enabled** del trigger
8. **Confirmación:** Se hizo clic en **Update**
9. **Resultado:** Mensaje "Trigger updated" confirmando el cambio

### Validación post-cambio:

Se verificó en el dashboard "Monitor Plataforma" con filtro EITAPP que la alerta ya no aparece en el panel de Problems. Las únicas alertas activas restantes son:

- EIT FS2: Windows High memory utilization (>40% for 5m) — 41.14%
- EIT BDP PUIG: Windows High memory utilization (>90% for 5m) — 94.72%
- eitretl: Windows System time is out of sync (diff with Zabbix server > 60s)
- EIT BDP: Windows High memory utilization (>90% for 5m) — 93.15%

## 4. Información Técnica del Host

| Campo       | Valor                          |
|-------------|--------------------------------|
| Host        | EITAPP                         |
| IP          | 10.200.42.32                   |
| Puerto      | 10050                          |
| Items       | 97                             |
| Triggers    | 70                             |
| Graphs      | 8                              |
| Discovery   | 4 reglas                       |
| Template    | Windows by Zabbix agent        |
| Agente      | Zabbix Agent 2 v8.0.0          |

## 5. Recomendaciones

1. **Revisar otros hosts:** Verificar si otros servidores del entorno también fueron migrados a Zabbix Agent 2 y podrían tener el mismo falso positivo con el servicio "Zabbix Agent" v1.

2. **Actualizar template de discovery:** Considerar ajustar las reglas de Windows services discovery para que filtren o ignoren servicios que ya no existen, evitando que se generen items/triggers huérfanos.

3. **Deshabilitar el item asociado (opcional):** Además del trigger, se podría deshabilitar también el item \`service.info["Zabbix Agent",state]\` para evitar recolección de datos innecesaria.

4. **Documentar migración de agentes:** Mantener un registro de qué servidores han sido migrados de Zabbix Agent v1 a v2, para facilitar la limpieza de monitoreo en el futuro.

5. **Revisar host EITAPPPUIG:** Este host (IP 10.200.42.58) comparte template similar y podría requerir la misma verificación.

---

*Documento generado el 10 de noviembre de 2026 — Implementación Zabbix, EIT Logística S.A.*
