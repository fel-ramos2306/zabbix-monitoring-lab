# Análisis de Causa Raíz (RCA)
## Falsa Alarma "Zabbix Agent is not running" — Host EITAPP

| Campo | Detalle |
|-------|---------|
| **ID Incidente** | INC-2026-001 |
| **Fecha del incidente** | 09 de noviembre de 2026, 20:50 hrs |
| **Fecha de resolución** | 09 de noviembre de 2026, 21:15 hrs |
| **Tiempo de resolución** | ~25 minutos |
| **Severidad** | Average |
| **Impacto real** | Ninguno (falsa alarma) |
| **Sistema afectado** | Zabbix 6.0.26 — Host EITAPP (10.200.42.32) |
| **Responsable del análisis** | Felipe Ramos Farías — Supervisor de TI |

---

## 1. Resumen Ejecutivo

Se generó una alerta falsa en la plataforma de monitoreo Zabbix indicando que el servicio "Zabbix Agent" no estaba ejecutándose en el servidor EITAPP. La investigación determinó que la alerta fue producida por un **trigger huérfano** que monitoreaba un servicio obsoleto (Zabbix Agent v1) que ya había sido reemplazado por Zabbix Agent 2 durante una migración reciente. No hubo impacto operacional; el monitoreo del servidor nunca se interrumpió.

---

## 2. Cronología de Eventos

| Hora | Evento |
|------|--------|
| 20:50:59 | Zabbix genera alerta: `"Zabbix Agent" (Zabbix Agent) is not running` en host EITAPP |
| 20:57 | Se detecta la alerta en el dashboard "Monitor Plataforma" |
| 20:58 | Se verifica localmente que Zabbix Agent 2 está corriendo (`Running`) |
| 21:00 | Se accede a EITAPP vía RDP para diagnóstico remoto |
| 21:03 | Se confirma que Zabbix Agent 2 v8.0.0 está operativo y el servicio "Zabbix Agent" v1 no existe |
| 21:08 | Se identifica el item y trigger huérfano generado por Windows services discovery |
| 21:12 | Se deshabilita el trigger en Zabbix frontend |
| 21:15 | Se valida en dashboard que la alerta desapareció |

---

## 3. Descripción del Incidente

### 3.1 Síntoma Observado

En el dashboard de monitoreo de Zabbix se activó la siguiente alerta:

- **Alerta:** `"Zabbix Agent" (Zabbix Agent) is not running (startup type automatic)`
- **Operational data:** `No such service (255)`
- **Host:** EITAPP (10.200.42.32)
- **Severidad:** Average
- **Duración al momento de detección:** ~7 minutos

### 3.2 Contexto Operacional

El servidor EITAPP fue recientemente migrado de **Zabbix Agent v1 (4.2.8)** a **Zabbix Agent 2 (v8.0.0)** como parte del plan de modernización de agentes en la plataforma EIT Logística. La migración implicó:

- Desinstalación del servicio `zabbix_agentd.exe` (Agent v1)
- Instalación del servicio `zabbix_agent2.exe` (Agent 2)
- Verificación de conectividad (ZBX verde, 97 items operativos, 0 items unsupported)

---

## 4. Análisis de Causa Raíz

### 4.1 Metodología: 5 Porqués (5 Whys)

| # | Pregunta | Respuesta |
|---|----------|-----------|
| 1 | ¿Por qué se generó la alerta? | Porque el trigger evaluaba que el servicio "Zabbix Agent" no estaba corriendo |
| 2 | ¿Por qué el servicio no estaba corriendo? | Porque el servicio "Zabbix Agent" (v1) fue desinstalado del servidor durante la migración a Agent 2 |
| 3 | ¿Por qué Zabbix seguía monitoreando un servicio que ya no existe? | Porque la regla de **Windows services discovery** había creado automáticamente un item y trigger para el servicio "Zabbix Agent" cuando este aún existía |
| 4 | ¿Por qué el item/trigger no se eliminó al desinstalar el agente v1? | Porque Zabbix no tiene un mecanismo automático para eliminar items/triggers descubiertos cuando el servicio monitoreado deja de existir; solo los marca como "unsupported" o retorna error |
| 5 | ¿Por qué no se incluyó la limpieza de triggers en el procedimiento de migración? | Porque **no existía un procedimiento documentado de migración** que incluyera la limpieza post-migración en Zabbix |

### 4.2 Causa Raíz Identificada

**Causa raíz:** Ausencia de un procedimiento de post-migración que contemple la limpieza de items y triggers huérfanos en Zabbix tras la migración de agentes v1 a v2.

### 4.3 Causa Técnica Directa

El trigger descubierto automáticamente por la regla "Windows services discovery" continuaba evaluando la existencia del servicio "Zabbix Agent" (v1) después de que este fue desinstalado:

- **Item:** `service.info["Zabbix Agent",state]`
- **Trigger:** `min(/EITAPP/service.info["Zabbix Agent",state],#3)<>0`
- **Retorno:** `No such service (255)` → condición `<>0` → **PROBLEM**

### 4.4 Diagrama de Ishikawa (Causa-Efecto)

```
                                    FALSA ALARMA
                                   "Zabbix Agent is not running"
                                         │
        ┌────────────────┬───────────────┼───────────────┬────────────────┐
        │                │               │               │                │
   PROCEDIMIENTO      SISTEMA        CONFIGURACIÓN    PERSONAS        MONITOREO
        │                │               │               │                │
   No existe          Zabbix no       Discovery        Migración      Sin validación
   procedimiento      elimina items   auto-genera      ejecutada      post-cambio
   de migración       huérfanos       triggers sin     sin checklist  en dashboard
   documentado        automáticamente lifecycle mgmt   de limpieza
```

---

## 5. Acciones Correctivas Ejecutadas

| # | Acción | Estado | Fecha |
|---|--------|--------|-------|
| 1 | Deshabilitar trigger huérfano `"Zabbix Agent" is not running` en host EITAPP | ✅ Completado | 09-11-2026 |
| 2 | Verificar que el monitoreo de Agent 2 opera correctamente (97 items, ZBX verde) | ✅ Completado | 09-11-2026 |
| 3 | Validar que la alerta desapareció del dashboard | ✅ Completado | 09-11-2026 |
| 4 | Documentar incidente en repositorio de versionamiento | ✅ Completado | 10-11-2026 |

---

## 6. Acciones Preventivas (Plan de Mejora)

| # | Acción Preventiva | Prioridad | Responsable | Plazo |
|---|-------------------|-----------|-------------|-------|
| 1 | **Crear checklist de migración Agent v1 → v2** que incluya: desinstalar v1, instalar v2, verificar items, deshabilitar/eliminar triggers huérfanos, validar dashboard | Alta | Felipe Ramos | Semana 2 |
| 2 | **Revisar host EITAPPPUIG** (10.200.42.58) por mismo patrón de falso positivo | Alta | Felipe Ramos | Semana 2 |
| 3 | **Auditar todos los hosts migrados** para identificar triggers huérfanos de servicios v1 | Media | Felipe Ramos | Semana 3 |
| 4 | **Evaluar configuración de discovery** — ajustar `Keep lost resources period` o agregar filtros para excluir servicios obsoletos | Media | Felipe Ramos | Semana 4 |
| 5 | **Deshabilitar item huérfano** `service.info["Zabbix Agent",state]` en EITAPP para evitar recolección innecesaria | Baja | Felipe Ramos | Semana 2 |
| 6 | **Ajustar acción EITADMIN** para cubrir severidades Warning/Average (actualmente solo High/Disaster) | Crítica | Felipe Ramos | Semana 1 |

---

## 7. Lecciones Aprendidas

1. **La migración de agentes no termina con la instalación.** El cambio de servicio genera items y triggers huérfanos que deben limpiarse en Zabbix como parte del procedimiento estándar.

2. **Las reglas de discovery automático requieren gestión de ciclo de vida.** Los items descubiertos no se eliminan solos cuando el recurso desaparece; deben gestionarse manualmente o mediante políticas de retención (`Keep lost resources period`).

3. **La validación post-cambio debe incluir el monitoreo.** Verificar que el nuevo agente funciona no es suficiente; también se debe confirmar que no quedan artefactos del agente anterior generando falsas alarmas.

4. **La brecha en notificaciones amplifica el problema.** Si la acción EITADMIN hubiera cubierto severidad Average, este falso positivo habría generado una notificación que se habría investigado más rápidamente. La combinación de falsa alarma + notificación mal configurada = problema silencioso.

---

## 8. Información Técnica de Referencia

### Host EITAPP

| Campo | Valor |
|-------|-------|
| Hostname | EITAPP |
| IP | 10.200.42.32 |
| Puerto | 10050 |
| Template | Windows by Zabbix agent |
| Agente anterior | Zabbix Agent v1 (4.2.8) — `zabbix_agentd.exe` |
| Agente actual | Zabbix Agent 2 v8.0.0 — `zabbix_agent2.exe` |
| Items | 97 (0 unsupported) |
| Triggers | 70 |
| Discovery rules | 4 |
| Server Zabbix | 10.200.42.56 (Zabbix 6.0.26) |

### Comandos de Verificación Utilizados

```powershell
# Verificar servicios Zabbix en el servidor
Get-Service *zabbix*

# Verificar versión del agente
& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t agent.version

# Verificar si existe servicio antiguo
Get-Service "Zabbix Agent"
```

---

*Análisis de Causa Raíz generado el 10 de noviembre de 2026*
*Implementación Zabbix — EIT Logística S.A.*
*Repositorio: [zabbix-monitoring-lab](https://github.com/fel-ramos2306/zabbix-monitoring-lab)*
