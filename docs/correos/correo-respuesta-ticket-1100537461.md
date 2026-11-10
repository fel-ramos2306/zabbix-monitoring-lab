# Correo de Respuesta — Ticket #1100537461

**Para:** John Soto <jsoto@iia.cl>
**CC:** César Lazo <clazo@eit.cl>, Eduardo Muñoz <emunoz@iia.cl>, Alejandra Sandoval <asandoval@iia.cl>
**Asunto:** RE: Ticket #1100537461 - RE: Revisar Servidor activo - RESUELTO

---

Estimado John,

Junto con saludar, informo que se realizó el upgrade del Agente Zabbix en el servidor **EITAPP (10.200.42.32)** según lo recomendado en el ticket.

## Trabajo realizado

- Se desinstaló **Zabbix Agent V1** (versión 4.2.8, \`zabbix_agentd.exe\`)
- Se instaló **Zabbix Agent 2** (\`zabbix_agent2.exe\`) con la siguiente configuración:
  - **Hostname:** EITAPP
  - **Server / ServerActive:** 10.200.42.56
  - **Puerto:** 10050
- Se verificó el correcto funcionamiento del nuevo agente

## Resultados de la verificación

1. **Servicio activo:** Zabbix Agent 2 corriendo como servicio de Windows (estado: Running)
2. **Conectividad:** Host EITAPP muestra indicador **ZBX en verde** en el frontend de Zabbix
3. **Ítems:** Los 97 ítems del host están operativos, incluyendo los ítems \`wmi.getall\` que anteriormente reportaban "unsupported item key"
4. **Ítems no soportados:** 0 (cero) — filtro "Not supported" muestra "No data found"

Se adjuntan capturas de pantalla como evidencia:
- **01-EITAPP-ZBX-verde-hosts.jpg** — Vista de hosts mostrando EITAPP con ZBX verde, Status Enabled
- **02-EITAPP-cero-items-unsupported.jpg** — Vista de ítems con filtro "Not supported" sin resultados

Con esto damos por resuelto el ticket #1100537461. Quedo atento ante cualquier consulta.

Saludos cordiales,

**Felipe Ramos Farías**
Supervisor de TI
EIT Logística S.A.
