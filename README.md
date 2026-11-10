# Implementación de Zabbix — EIT Logística S.A.

Proyecto de implementación y mejora continua de la plataforma de monitoreo Zabbix para la infraestructura de EIT Logística.

## Entorno

| Componente | Detalle |
|---|---|
| **Zabbix Server** | 6.0.26 |
| **IP Servidor** | 10.200.42.56 |
| **Hosts monitoreados** | 17 (red 10.200.42.x) |
| **Template principal** | Windows by Zabbix agent |
| **Agente** | Zabbix Agent / Zabbix Agent 2 (migración en curso) |

## Estructura del repositorio

\`\`\`
zabbix-monitoring-lab/
├── docs/
│   ├── analisis/          # Análisis y auditorías de la plataforma
│   ├── incidentes/        # Documentación de incidentes resueltos
│   └── correos/           # Comunicaciones formales relacionadas
├── configs/               # Archivos de configuración (futuro)
├── scripts/               # Scripts de automatización (futuro)
├── templates/             # Templates personalizados de Zabbix (futuro)
└── README.md
\`\`\`

## Documentos actuales

### Análisis
- **[Análisis de Alertas Zabbix — Plataforma EIT](docs/analisis/Analisis_Alertas_Zabbix_Plataforma_EIT.pdf)** (09-Nov-2026) — Revisión completa de alertas, triggers y oportunidades de mejora en la instancia Zabbix.

### Incidentes
- **[Incidente ZabbixAgent EITAPP](docs/incidentes/Incidente_ZabbixAgent_EITAPP.md)** (09-Nov-2026) — Falsa alarma por servicio "Zabbix Agent" v1 inexistente tras migración a Agent 2 en servidor EITAPP.

### Correos
- **[Ticket #1100537461](docs/correos/correo-respuesta-ticket-1100537461.md)** — Respuesta formal sobre upgrade de Zabbix Agent v1 a Agent 2 en EITAPP.

## Roadmap

- [ ] Ajustar acción EITADMIN para cubrir severidades Warning y Average
- [ ] Agregar destinatarios y canales de notificación (Telegram, Teams)
- [ ] Escalar severidades de triggers críticos (disco, agente)
- [ ] Crear triggers para métricas sin alerta (memory pool, context switches, procesos)
- [ ] Configurar escalamiento de alertas
- [ ] Implementar monitoreo proactivo (ICMP, web scenarios, event logs)
- [ ] Completar migración de Zabbix Agent v1 a Agent 2 en todos los hosts
- [ ] Verificar host EITAPPPUIG por mismo falso positivo de Agent v1

## Responsable

**Felipe Ramos Farías** — Supervisor de TI, EIT Logística S.A.
