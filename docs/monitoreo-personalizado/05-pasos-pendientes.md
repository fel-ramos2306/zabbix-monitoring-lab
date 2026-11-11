# Pasos Pendientes — Activación del Monitoreo

## Estado actual

El template **EIT Monitoreo Personalizado** está completo (9 items, 6 triggers) pero **no está vinculado** a ningún host.

## Paso 1: Vincular template a los servidores

1. Ir a **Configuration → Hosts**
2. Filtrar por grupo **Windows Server**
3. Seleccionar los 16 servidores (checkbox de cada uno)
4. Click en **Mass update**
5. En la pestaña **Templates**, marcar **Link**
6. Buscar y seleccionar **EIT Monitoreo Personalizado**
7. Click en **Update**

## Paso 2: Verificar agente Zabbix en cada servidor

Los items de tipo "Zabbix agent (active)" requieren que el agente esté instalado y configurado en cada servidor Windows.

Verificar en el archivo de configuración del agente (`C:\Program Files\Zabbix Agent\zabbix_agentd.conf` o similar):

```ini
ServerActive=10.200.42.56
Hostname=<nombre del host en Zabbix>
```

Reiniciar el servicio "Zabbix Agent" después de cualquier cambio en la configuración.

## Paso 3: Verificar recopilación de datos

Una vez vinculado el template:

- Los items **ICMP** (Simple check) comenzarán a recopilar datos de inmediato.
- Los items de **Zabbix agent** comenzarán cuando el agente se conecte al servidor.
- Verificar en **Monitoring → Latest data** que los items estén recibiendo valores.

## Paso 4: Renombrar items a español (opcional)

Los nombres de los 9 items están en inglés. Para renombrarlos:

1. Ir a **Configuration → Templates → EIT Monitoreo Personalizado → Items**
2. Click en el nombre del item
3. Modificar el campo **Name**
4. Click en **Update**

Las keys no se modifican, solo el nombre visible.
