# Tabla A — Acción EITADMIN (Notificaciones)

## Ubicación en Zabbix

Administration → Actions → Trigger actions → **EITADMIN**

## Cambio realizado

Se amplió el rango de severidades que disparan notificaciones por correo electrónico al usuario **eitmon**.

| Parámetro | Antes | Después |
|-----------|-------|---------|
| Severidades habilitadas | Disaster, High | Disaster, High, Average, Warning |
| Destinatario | eitmon | eitmon (sin cambio) |
| Medio de envío | Email | Email (sin cambio) |

## Efecto

Cualquier trigger de severidad **Warning o superior** genera notificación automática por correo al usuario eitmon. Anteriormente solo se notificaban los eventos de severidad High y Disaster.
