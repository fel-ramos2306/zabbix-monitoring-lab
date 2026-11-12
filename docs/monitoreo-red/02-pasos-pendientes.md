# Pasos Pendientes - Monitoreo de Red

## 1. Obtener acceso de super administrador en Zabbix

El usuario actual `eitmon` (Usuario para reportes EIT) no tiene permisos de super admin. Se necesita acceso de super admin para:

- Crear el host group **"Equipos de Red"**
- Crear Discovery Actions
- Configurar acciones automatizadas

**Acción:** Solicitar al administrador de Zabbix que otorgue permisos de super admin, o que cree el host group "Equipos de Red".

## 2. Obtener credenciales SNMP de los switches

Información requerida por cada switch:

- **Marca y modelo** (Cisco, HP, Mikrotik, D-Link, TP-Link, etc.)
- **IP específica** del switch (algunas ya aparecen en el discovery)
- **Community string SNMP** real (actualmente configurado "public" como placeholder)
- **Versión SNMP** habilitada:
  - Si es **SNMPv2c**: solo community string
  - Si es **SNMPv3**: usuario, protocolo de autenticación (auth) y privacidad (priv)

## 3. Actualizar la regla de Discovery

Una vez obtenido el community string real:

1. Ir a **Configuration > Discovery**
2. Editar **"SNMP Network Discovery - EIT"**
3. En la sección de checks, editar el check SNMPv2
4. Reemplazar `public` por el community string real
5. Guardar

## 4. Habilitar SNMP en los switches (si no está activo)

Si los switches no responden al discovery SNMP:

1. Acceder a la configuración del switch (CLI o web)
2. Habilitar SNMP v2c o v3
3. Configurar el community string
4. Verificar que el puerto UDP 161 esté accesible desde el servidor Zabbix (10.200.42.56)
