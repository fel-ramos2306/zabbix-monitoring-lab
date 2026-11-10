# Proyecto por Fases — Alertas Zabbix | Plataforma EIT

**Autor:** Felipe Ramos Farías — Supervisor de TI, EIT Logística S.A.  
**Fecha inicio:** 09-Nov-2026  
**Última actualización:** 10-Nov-2026  
**Estado general:** Fase 1 ✅ | Fase 2 ✅ | Fase 3 ⬜ Pendiente

---

## 1. Estado Actual de la Plataforma

### 1.1 Entorno de Monitoreo

| Componente | Detalle |
|-----------|---------|
| Servidor Zabbix | 6.0.26 — IP 10.200.42.56 |
| Hosts monitoreados | 17 (Windows) |
| Template | Windows by Zabbix agent |
| Puerto agente | 10050 |
| Red | 10.200.42.x |

### 1.2 Hosts Monitoreados

| Host | IP | Estado ZBX |
|------|-----|-----------|
| eitapp | 10.200.42.20 | ✅ |
| EITAPPPUIG | 10.200.42.60 | ✅ |
| eitbdp | 10.200.42.10 | ✅ |
| EITBDPPUIG | 10.200.42.50 | ✅ |
| eitdc01 | 10.200.42.2 | ✅ |
| eitdc02 | 10.200.42.3 | ✅ |
| EITDCPUIG | 10.200.42.42 | ✅ |
| EITFS2 | 10.200.42.6 | ✅ |
| eitretl | 10.200.42.11 | ✅ |
| EITRETLPUIG | 10.200.42.52 | ✅ |
| EITSRVAPP01 | 10.200.42.21 | ✅ |
| EITSRVAPP02 | 10.200.42.22 | ✅ |
| EITSRVAPP03 | 10.200.42.23 | ✅ |
| EITSRVAPPUIG01 | 10.200.42.61 | ✅ |
| EITSRVAPPUIG02 | 10.200.42.62 | ✅ |
| EITSRVAPPUIG03 | 10.200.42.63 | ✅ |
| zbx-proxy | 10.200.42.56 | ✅ |

### 1.3 Problemas Activos (al 09-Nov-2026)

| Host | Problema | Severidad | Desde |
|------|---------|-----------|-------|
| eitretl | High memory utilization (>90%) — 94-98% | Average | Reciente |
| EITFS2 | High memory utilization (>90%) — 41% | Average | Reciente |
| EITBDPPUIG | High memory utilization (>90%) — 94% | Average | Reciente |
| eitretl | System time is out of sync | Warning | Jul 2026 |
| EITBDP | High memory utilization (>90%) — 93% | Average | Mar 2026 |

### 1.4 Brecha Crítica Identificada

La acción **"EITADMIN"** (única habilitada) solo dispara en severidades **High y Disaster**, pero la distribución real de triggers es:

| Severidad | Cantidad aproximada |
|-----------|-------------------|
| Information | ~1 |
| Warning | ~10 |
| Average | ~55 |
| **High** | **0** |
| **Disaster** | **0** |

**Resultado:** Cero notificaciones efectivas. Ningún problema activo genera alerta por correo.

---

## 2. Plan de Implementación por Fases

### Fase 1 — Triggers Imprescindibles ✅ COMPLETADA

**Objetivo:** Crear acciones para los 5 triggers más críticos que ya existen en el template.  
**Fecha ejecución:** 09-Nov-2026  
**Estado:** Completada — acciones creadas, **deshabilitadas** pendiente configuración SMTP.

| # | Acción | Action ID | Condición | Operación | Recovery | Status |
|---|--------|-----------|-----------|-----------|----------|--------|
| 1 | Alerta Agente No Disponible | 8 | `Zabbix agent is not available` | eitmon, all media | ✅ | Disabled |
| 2 | Alerta Disco Critico | 9 | `Disk space` | eitmon, all media | ✅ | Disabled |
| 3 | Alerta Memoria Alta | 10 | `High memory utilization` | eitmon, all media | ✅ | Disabled |
| 4 | Alerta Reinicio Host | 11 | `has been restarted` | eitmon, all media | ✅ | Disabled |
| 5 | Alerta Sincronizacion Hora | 12 | `System time is out of sync` | eitmon, all media | ✅ | Disabled |

**Configuración común:**
- Default step duration: 4 horas
- Operations: Step 1 → Send message to users: eitmon via all media — Immediately
- Recovery operations: Send message to users: eitmon via all media
- Pause operations for suppressed problems: ✅
- Notify about canceled escalations: ✅

---

### Fase 2 — Alertas Tempranas ✅ COMPLETADA

**Objetivo:** Cubrir alertas de espacio en disco (warning), swap y CPU.  
**Fecha ejecución:** 10-Nov-2026  
**Estado:** Completada — acciones revisadas/creadas, **deshabilitadas** pendiente SMTP.

**Trabajo realizado:**

| Categoría | Acción | Trabajo | Resultado |
|-----------|--------|---------|-----------|
| Disco | Alerta Disco Critico | Revisión de configuración | ✅ Operación y recovery correctos |
| Swap | Alerta Swap Alto | Revisión de configuración | ✅ Configuración idéntica a Disco |
| CPU | **Alerta CPU Alto** | **CREADA** | ✅ Condición "CPU", eitmon via all media, recovery incluido |

**Nota:** La acción "Alerta Disco Critico" ya existía desde Fase 1. "Alerta Swap Alto" ya había sido creada previamente. El trabajo nuevo de Fase 2 fue la creación de "Alerta CPU Alto" y la verificación de las tres configuraciones.

---

### Fase 3 — Servicios Windows ⬜ PENDIENTE

**Objetivo:** Revisar los ~50 servicios Windows por host y determinar cuáles son críticos para el negocio.  
**Plazo estimado:** Tercera semana+

**Consideraciones:**
- Requiere definir con las áreas de negocio qué servicios importan por host
- Cada host puede tener ~50 servicios activos — no todos requieren monitoreo
- Se deben crear triggers personalizados por rol de servidor (BD, App, DC, File Server)

---

## 3. Estado Consolidado de Acciones

**Total: 8 acciones** (7 deshabilitadas + 1 legacy habilitada)

| # | Acción | Fase | Condición | Medio | Status |
|---|--------|------|-----------|-------|--------|
| 1 | Alerta Agente No Disponible | F1 | `Zabbix agent is not available` | all media | Disabled |
| 2 | Alerta CPU Alto | **F2** | `CPU` | all media | Disabled |
| 3 | Alerta Disco Critico | F1 | `Disk space` | all media | Disabled |
| 4 | Alerta Memoria Alta | F1 | `High memory utilization` | all media | Disabled |
| 5 | Alerta Reinicio Host | F1 | `has been restarted` | all media | Disabled |
| 6 | Alerta Sincronizacion Hora | F1 | `System time is out of sync` | all media | Disabled |
| 7 | Alerta Swap Alto | F2 | `swap` | all media | Disabled |
| 8 | EITADMIN | Legacy | Disaster / High severity | Email (HTML) | **Enabled** |

---

## 4. Prerrequisitos para Activación

### 4.1 Bloqueante: Configuración SMTP

Para activar las 7 acciones creadas, se requiere:

1. **Acceso administrador a Zabbix** (usuario `eitmon` tiene permisos limitados)
2. **Configurar Media Type SMTP** en Administration → Media types
3. **Verificar media del usuario eitmon** — debe tener email configurado
4. **Habilitar cada acción** individualmente (checkbox Enabled)
5. **Probar con un trigger conocido** — verificar recepción del correo

### 4.2 Pasos para activar (cuando SMTP esté listo)

```
1. Administration → Media types → Email → Configurar SMTP server, puerto, from, auth
2. Administration → Users → eitmon → Media → Verificar/agregar email
3. Configuration → Actions → Seleccionar acción → Enabled ✅ → Update
4. Repetir paso 3 para cada acción
5. Validar con trigger activo (ej: eitretl memory >90% debería disparar)
```

---

## 5. Oportunidades Futuras

### A) Métricas sin triggers (~18 items)
Items que se recopilan pero no tienen trigger de alerta configurado.

### B) Nuevas áreas de monitoreo
- Monitoreo de servicios Windows críticos (Fase 3)
- Monitoreo de red y conectividad
- Monitoreo de aplicaciones específicas

### C) Canales de notificación adicionales
- Telegram Bot
- Microsoft Teams webhook
- Escalamiento a múltiples destinatarios

---

## 6. Recomendaciones (ordenadas por impacto/esfuerzo)

1. **Configurar SMTP** → Activa todas las alertas de Fase 1 y 2 de inmediato
2. **Ajustar acción EITADMIN** → Ampliar a Warning/Average o deshabilitarla en favor de las nuevas
3. **Definir owners por área** → Necesario para escalar alertas al responsable correcto
4. **Revisar thresholds** → Los umbrales predeterminados del template pueden no ajustarse a la realidad de EIT
5. **Completar migración Agent v1→v2** → Aún hay hosts con Zabbix Agent 4.2.8
6. **Documentar runbooks** → Procedimientos de respuesta para cada tipo de alerta

---

## 7. Historial de Cambios

| Fecha | Fase | Descripción |
|-------|------|-------------|
| 09-Nov-2026 | Fase 1 | Creadas 5 acciones (IDs 8-12) + "Alerta Swap Alto" — todas deshabilitadas |
| 10-Nov-2026 | Fase 2 | Creada "Alerta CPU Alto", revisadas acciones de Disco y Swap — confirmadas correctas |
