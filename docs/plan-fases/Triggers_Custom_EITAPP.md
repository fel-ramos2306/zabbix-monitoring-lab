# Triggers Custom — EITAPP (Métricas sin Trigger Previo)

**Autor:** Felipe Ramos Farías — Supervisor de TI, EIT Logística S.A.  
**Fecha ejecución:** 10-Nov-2026  
**Host:** EITAPP (10.200.42.20)  
**Triggers antes:** 76 → **Triggers después:** 86  
**Estado:** Todos **DISABLED** — pendiente configuración SMTP

---

## 1. Contexto

El template "Windows by Zabbix agent" recopila ~18 métricas que no tenían trigger asociado.
Se identificaron 10 métricas con potencial de alerta y se crearon triggers custom en EITAPP
como host piloto. Las 8 métricas restantes son informativas (Host name, OS architecture,
System description, Total memory, Zabbix agent version, Network interfaces WMI get) y no
requieren triggers.

---

## 2. Triggers Creados

### 2.1 Prioridad Alta (3 triggers)

| # | Trigger | Key / Expresión | Umbral | Severity |
|---|---------|----------------|--------|----------|
| 1 | Memory pool non-paged < 30MB | `perf_counter_en["\Memory\Pool Nonpaged Bytes"]` | < 31,457,280 bytes (30MB) | Warning |
| 2 | Zabbix agent unreachable 3 min | `nodata(/EITAPP/agent.ping,3m)=1` | Sin datos por 3 min | High |
| 3 | Free swap space < 500MB/200MB | `system.swap.free` | < 524,288,000 (500MB) / < 209,715,200 (200MB) | Warning |

**Justificación:**
- **Memory pool non-paged:** Si se agota, causa BSOD (pantalla azul). Crítico para estabilidad del servidor.
- **Zabbix agent unreachable:** Complementa la alerta existente "Zabbix agent is not available". Doble red de seguridad con detección más rápida (3 min vs timeout estándar).
- **Free swap space:** Complementa "High swap space usage" de Fase 2. Alerta proactiva cuando queda poco espacio disponible en vez de cuando ya está saturado.

### 2.2 Prioridad Media (3 triggers)

| # | Trigger | Key / Expresión | Umbral | Severity |
|---|---------|----------------|--------|----------|
| 4 | Memory page faults/sec > 1000 | `perf_counter_en["\Memory\Page Faults/sec"]` | > 1,000 faults/sec | Average |
| 5 | Number of processes > 300 | `proc.num[]` | > 300 procesos | Average |
| 6 | CPU DPC time > 20% | `perf_counter_en["\Processor Information(_total)\% DPC Time"]` | > 20% | Average |

**Justificación:**
- **Page faults/sec:** Indicador de presión de memoria. Valores sostenidos >1000 sugieren que el sistema está paginando excesivamente.
- **Number of processes:** Detecta fugas de procesos que eventualmente agotan recursos y tumban el servidor.
- **CPU DPC time:** Tiempo excesivo en Deferred Procedure Calls indica problemas con drivers o hardware (NIC, storage controllers).

### 2.3 Prioridad Baja (4 triggers)

| # | Trigger | Key / Expresión | Umbral | Severity |
|---|---------|----------------|--------|----------|
| 7 | Number of threads > 2000 | — | > 2,000 threads | Information |
| 8 | CPU user time > 80% | — | > 80% | Information |
| 9 | Context switches/sec > 15000 | — | > 15,000/sec | Information |
| 10 | Memory cache bytes < 100MB | — | < 104,857,600 bytes (100MB) | Information |

**Justificación:**
- **Number of threads:** Complementa el monitoreo de procesos. Fuga de threads consume handles del kernel.
- **CPU user time:** Complementa el trigger de CPU total del template. Aísla carga de aplicaciones vs sistema.
- **Context switches/sec:** Indicador de contención de CPU. Valores altos sostenidos sugieren demasiados hilos compitiendo por CPU.
- **Cache bytes:** Si baja demasiado, el sistema no tiene memoria para caché de archivos, degradando I/O.

---

## 3. Métricas Informativas (sin trigger necesario)

Las siguientes métricas se recopilan para inventario y contexto, no requieren alertas:

- Host name
- OS architecture
- System description
- Total memory
- Zabbix agent version
- Network interfaces WMI get

---

## 4. Consideraciones para Replicación

Estos 10 triggers fueron creados en **EITAPP como host piloto**. Para replicarlos a los 16 hosts restantes, las opciones son:

1. **Crear un template custom** con los 10 triggers y asignarlo a todos los hosts (recomendado)
2. **Clonar triggers manualmente** host por host (no escalable)
3. **Exportar/importar via XML** desde EITAPP hacia los demás hosts

**Recomendación:** Crear template `Template Custom EIT Windows` que contenga estos 10 triggers y linkearlo junto al template estándar "Windows by Zabbix agent". Así cualquier ajuste de umbral se propaga a todos los hosts.

---

## 5. Umbrales y Tuning

Los umbrales definidos son valores iniciales conservadores basados en buenas prácticas Windows Server. Se recomienda:

- **Monitorear 1-2 semanas** con los triggers disabled antes de habilitar
- **Revisar baselines reales** por host — servidores de BD, App y File Server tienen perfiles diferentes
- **Ajustar umbrales** según comportamiento observado:
  - Servidores de BD (eitbdp, EITBDPPUIG): probablemente necesitan umbrales más altos en page faults y procesos
  - File Servers (EITFS2): umbral de cache bytes más relevante
  - Domain Controllers (eitdc01, eitdc02): context switches pueden ser naturalmente más altos

---

## 6. Próximos Pasos

1. ⬜ Configurar SMTP para activar las acciones existentes (Fase 1 y 2)
2. ⬜ Crear template custom `Template Custom EIT Windows` con los 10 triggers
3. ⬜ Asignar template a los 17 hosts
4. ⬜ Crear acciones correspondientes para los nuevos triggers
5. ⬜ Monitorear baselines y ajustar umbrales
6. ⬜ Avanzar con Fase 3 — Servicios Windows críticos
