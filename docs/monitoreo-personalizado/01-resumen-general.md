# Resumen General

**Fecha:** 11 de noviembre de 2026  
**Plataforma:** Zabbix 6.0.26  
**Servidor:** http://10.200.42.56/zabbix/

## Objetivo

Configurar monitoreo personalizado en Zabbix para los 16 servidores Windows de EIT Logística, abarcando dos áreas de trabajo:

1. **Tabla A — Notificaciones:** Modificar la acción EITADMIN para incluir severidades Warning y Average en las notificaciones por correo electrónico.

2. **Tabla C — Monitoreo personalizado:** Crear el template "EIT Monitoreo Personalizado" con items y triggers para:
   - Verificación ICMP (ping, pérdida de paquetes, tiempo de respuesta)
   - Monitoreo de Event Log de Windows (System y Application)
   - Estado de servicios críticos (Zabbix Agent, Windows Update, SQL Server)
   - Verificación de backups (última modificación del directorio)

## Resultado

- Template **EIT Monitoreo Personalizado** (ID: 10623) creado con 9 items y 6 triggers.
- Acción **EITADMIN** actualizada para notificar en severidades Warning, Average, High y Disaster.
- Template **no vinculado** a los hosts — pendiente de activación manual.
