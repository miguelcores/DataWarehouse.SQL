USE ODS;

/*NO COMMENTS */

INSERT INTO ODS_DM_DEPARTAMENTOS_CC (DE_DEPARTAMENTO_CC, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(SERVICE)), NOW(),NOW()
FROM STAGE.STG_CONTACTOS_IVR
WHERE TRIM(SERVICE) !='';
INSERT INTO ODS_DM_DEPARTAMENTOS_CC VALUES(000000,'DESCONOCIDO', NOW(),NOW());
COMMIT;
ANALYZE TABLE ODS_DM_DEPARTAMENTOS_CC
;

INSERT INTO ODS_DM_AGENTES_CC (DE_AGENTE , FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(AGENT)), NOW(),NOW()
FROM STAGE.STG_CONTACTOS_IVR
WHERE TRIM(AGENT)!='';
INSERT INTO ODS_DM_AGENTES_CC VALUES(000000,'DESCONOCIDO',NOW(),NOW());
COMMIT;
ANALYZE TABLE ODS_DM_AGENTES_CC
;


INSERT INTO ODS_HC_LLAMADAS (TELEFONO_LLAMADA,ID_CLIENTE,FC_INICIO_LLAMADA,FC_FIN_LLAMADA,ID_DEPARTAMENTO_CC,FLG_TRANSFERIDO,ID_AGENTE,FC_INSERT,FC_MODIFICACION)
SELECT CASE WHEN TRIM(PHONE_NUMBER)!='' THEN TRIM(PHONE_NUMBER) ELSE 999999999 END TELEFONO_LLAMADA
, CLI.ID_CLIENTE
, CASE WHEN TRIM(START_DATETIME)!='' THEN STR_TO_DATE(REPLACE(MID(START_DATETIME,1,10),'-','/'), '%Y/%m/%d') ELSE STR_TO_DATE('9999/12/31','%Y/%m/%d') END FC_INICIO_LLAMADA
, CASE WHEN TRIM(END_DATETIME)!='' THEN STR_TO_DATE(REPLACE(MID(END_DATETIME,1,10),'-','/'), '%Y/%m/%d') ELSE STR_TO_DATE('9999/12/31','%Y/%m/%d') END FC_FIN_LLAMADA
, DEP.ID_DEPARTAMENTO_CC
, CASE WHEN TRIM(FLG_TRANSFER)='TRUE' THEN 1 ELSE 0 END FLG_TRANSFERIDO
, AG.ID_AGENTE_CC
, NOW() 
, STR_TO_DATE('31/12/9999','%d/%m/%Y')
FROM STAGE.STG_CONTACTOS_IVR CONT
INNER JOIN ODS_HC_CLIENTES CLI ON CASE WHEN ID!=NULL THEN ID ELSE 999999999 END=ID_CLIENTE
INNER JOIN ODS_DM_DEPARTAMENTOS_CC DEP ON CASE WHEN TRIM(SERVICE)<>'' THEN UPPER(TRIM(SERVICE)) ELSE 'DESCONOCIDO' END=DEP.DE_DEPARTAMENTO_CC
INNER JOIN ODS_DM_AGENTES_CC AG ON CASE WHEN TRIM(AGENT)<>'' THEN UPPER(TRIM(AGENT)) ELSE 'DESCONOCIDO' END=AG.DE_AGENTE
;


COMMIT;    ANALYZE TABLE ODS_HC_LLAMADAS;







