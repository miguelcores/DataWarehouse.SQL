USE ODS;

INSERT INTO ODS_DM_SEXOS VALUES(1,'MALE',NOW(),NOW());
INSERT INTO ODS_DM_SEXOS VALUES(2,'FEMALE',NOW(),NOW());
INSERT INTO ODS_DM_SEXOS VALUES(99,'NO APLICA',NOW(),NOW()); /*NO ES OBLIGATORIO PONER EL SEXO, PUES HAY GENTE QUE NO SABE SU SEXUALIDAD A CIENCIA CIERTA*/
COMMIT;
ANALYZE TABLE ODS_DM_SEXOS;

INSERT INTO ODS_DM_PROFESIONES (DE_PROFESION, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(PROFESION)),NOW(),NOW()
FROM STAGE.STG_CLIENTES_CRM
WHERE TRIM(PROFESION)!='';                   COMMIT;
INSERT INTO ODS_DM_PROFESIONES VALUES(999,'DESCONOCIDO',NOW(),NOW());          COMMIT;
ANALYZE TABLE ODS_DM_PROFESIONES;

INSERT INTO ODS_DM_COMPANYAS (DE_COMPANYA, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(COMPANY)) , NOW(),NOW()
FROM STAGE.STG_CLIENTES_CRM
WHERE TRIM(COMPANY)!='';                     COMMIT;
INSERT INTO ODS_DM_COMPANYAS VALUES(999,'DESCONOCIDO',NOW(),NOW());             COMMIT;
ANALYZE TABLE ODS_DM_COMPANYAS;


INSERT INTO ODS_DM_PAISES (DE_PAIS, FC_INSERT,FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(COUNTRY)), NOW(),NOW()
FROM STAGE.STG_CLIENTES_CRM
WHERE TRIM(COUNTRY)!='';                      COMMIT;
INSERT INTO ODS_DM_PAISES VALUES(99,'DESCONOCIDO',NOW(),NOW());                  COMMIT;
ANALYZE TABLE ODS_DM_PAISES;

INSERT INTO ODS_DM_CIUDADES_ESTADOS (DE_CIUDAD, DE_ESTADO, ID_PAIS, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(CITY)), UPPER(TRIM(STATE)), PAI.ID_PAIS, NOW(),NOW()
FROM STAGE.STG_CLIENTES_CRM 
INNER JOIN ODS_DM_PAISES PAI ON CASE WHEN LENGTH(TRIM(COUNTRY))!=0 THEN TRIM(COUNTRY) ELSE 'DESCONOCIDO' END=PAI.DE_PAIS
WHERE TRIM(CITY)!='';
INSERT INTO ODS_DM_CIUDADES_ESTADOS VALUES(999,'DESCONOCIDO',99,99,NOW(),NOW());
COMMIT;
ANALYZE TABLE ODS_DM_CIUDADES_ESTADOS;

INSERT INTO ODS_HC_DIRECCIONES (DE_DIRECCION, DE_CP, ID_CIUDAD_ESTADO, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(ADDRESS))
,CASE WHEN LENGTH(TRIM(CLI.POSTAL_CODE))<>0 THEN TRIM(CLI.POSTAL_CODE) ELSE 99999 END CP ,CIU.ID_CIUDAD_ESTADO, NOW(), NOW()
FROM STAGE.STG_CLIENTES_CRM CLI 
INNER JOIN ODS_DM_PAISES PAI ON CASE WHEN LENGTH(TRIM(CLI.COUNTRY))<>0 THEN CLI.COUNTRY ELSE 'DESCONOCIDO'END=PAI.DE_PAIS
INNER JOIN ODS_DM_CIUDADES_ESTADOS CIU ON CASE WHEN LENGTH(TRIM(CLI.CITY))<>0 THEN CLI.CITY ELSE 'DESCONOCIDO'END=CIU.DE_CIUDAD
						    	AND CASE WHEN LENGTH(TRIM(CLI.STATE))<>0 THEN CLI.STATE ELSE 'DESCONOCIDO' END=CIU.DE_ESTADO
WHERE TRIM(ADDRESS)<>'';
INSERT INTO ODS_HC_DIRECCIONES VALUES (999999,'DESCONOCIDO', 99999,999,NOW(),NOW());
COMMIT;
ANALYZE TABLE ODS_HC_DIRECCIONES;

/*Creamos tablas de direcciones temporales por 2 razones:
1. Eficiencia: para que en el relleno de la tabla de clientes no se tenga que hacer todo el proceso de  depuracion de ID_DIRECCIONES
2. Solventar problema de asignar ID a direcciones en mal estado. (Otra opcion es concatenar campos pero....)
*/

DROP TABLE IF EXISTS TMP_DIRECCIONES_CLIENTES;
CREATE TABLE TMP_DIRECCIONES_CLIENTES AS
SELECT DIR.ID_DIRECCION
, DIR.DE_DIRECCION
, DIR.DE_CP
, PAI.DE_PAIS
, CIU.DE_CIUDAD
, CIU.DE_ESTADO
FROM ODS_HC_DIRECCIONES DIR
INNER JOIN ODS_DM_CIUDADES_ESTADOS CIU ON DIR.ID_CIUDAD_ESTADO=CIU.ID_CIUDAD_ESTADO
INNER JOIN ODS_DM_PAISES PAI ON CIU.ID_PAIS=PAI.ID_PAIS;
ANALYZE TABLE TMP_DIRECCIONES_CLIENTES
;

DROP TABLE IF EXISTS TMP_DIRECCIONES_CLIENTES2;
CREATE TABLE TMP_DIRECCIONES_CLIENTES2 AS
SELECT CLI.CUSTOMER_ID ID_CLIENTE
, DIR.ID_DIRECCION
FROM STAGE.STG_CLIENTES_CRM CLI
INNER JOIN TMP_DIRECCIONES_CLIENTES DIR ON CASE WHEN TRIM(CLI.ADDRESS)<>'' THEN UPPER(TRIM(CLI.ADDRESS)) ELSE 'DESCONOCIDO' END=DIR.DE_DIRECCION
									   AND CASE WHEN TRIM(CLI.POSTAL_CODE)<>'' THEN TRIM(CLI.POSTAL_CODE) ELSE 99999 END=DIR.DE_CP
                                       AND CASE WHEN TRIM(CLI.CITY)<>'' THEN CLI.CITY ELSE 'DESCONOCIDO' END=DIR.DE_CIUDAD
                                       AND CASE WHEN TRIM(CLI.STATE)<>'' THEN CLI.STATE ELSE 'DESCONOCIDO' END=DIR.DE_ESTADO
                                       AND CASE WHEN TRIM(CLI.COUNTRY)<>'' THEN CLI.COUNTRY ELSE 'DESCONOCIDO' END=DIR.DE_PAIS;
ANALYZE TABLE TMP_DIRECCIONES_CLIENTES2
;



INSERT INTO ODS_HC_CLIENTES 
SELECT CUSTOMER_ID AS ID_CLIENTE
, CASE WHEN TRIM(FIRST_NAME)!='' THEN UPPER(TRIM(FIRST_NAME)) ELSE 'DESCONOCIDO' END NOMBRE_CLIENTE
, CASE WHEN TRIM(LAST_NAME)!='' THEN UPPER(TRIM(LAST_NAME)) ELSE 'DESCONOCIDO' END APELLIDO_CLIENTE
, CASE WHEN TRIM(IDENTIFIED_DOC)!='' THEN TRIM(UPPER(IDENTIFIED_DOC)) ELSE 'DESCONOCIDO' END NUMDOC_CLIENTE
, SEX.ID_SEXO 
, CASE WHEN TRIM(DIR.ID_DIRECCION)<>'' THEN DIR.ID_DIRECCION ELSE 999999 END ID_DIRECCION_CLIENTE 
, CASE WHEN TRIM(PHONE)!='' THEN REPLACE(PHONE,'-','') ELSE 999999999 END TELEFONO_CLIENTE
, CASE WHEN TRIM(EMAIL)!='' THEN UPPER(TRIM(EMAIL)) ELSE 'DESCONOCIDO' END MAIL_CLIENTE
, CASE WHEN TRIM(BIRTHDAY)!='' THEN STR_TO_DATE(BIRTHDAY, '%d/%m/%Y') ELSE STR_TO_DATE('31/12/9999','%d/%m/%Y') END FC_NACIMIENTO
, PROF.ID_PROFESION
, COMP.ID_COMPANYA
, NOW() 
, STR_TO_DATE('31/12/9999','%d/%m/%Y')
FROM STAGE.STG_CLIENTES_CRM CLI
INNER JOIN ODS_DM_SEXOS SEX ON CASE WHEN TRIM(GENDER)<>'' THEN UPPER(TRIM(CLI.GENDER)) ELSE 'NO APLICA' END=SEX.DE_SEXO
INNER JOIN ODS_DM_PROFESIONES PROF ON CASE WHEN TRIM(PROFESION)<>'' THEN UPPER(TRIM(CLI.PROFESION)) ELSE 'DESCONOCIDO' END=PROF.DE_PROFESION
INNER JOIN ODS_DM_COMPANYAS COMP ON CASE WHEN TRIM(COMPANY)<>'' THEN UPPER(TRIM(CLI.COMPANY)) ELSE 'DESCONOCIDO' END=COMP.DE_COMPANYA
LEFT OUTER JOIN TMP_DIRECCIONES_CLIENTES2 DIR ON DIR.ID_CLIENTE=CLI.CUSTOMER_ID; 

INSERT INTO ODS_HC_CLIENTES VALUES (999999999, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*AÑADO ESTE VAOR PARA PODER CRUZAR TODAS LAS LLAMADAS DE NUMEROS QUE NO ESTAN REGISTRADOS COMO CLIENTES Y CASOS SIMILARES EN LOS QUE SEA NECESRIO GUARDAR 
REGISTROS DE GENTE QUE NO ESTE REGISTRADA COMO CLIENTE*/
                                                COMMIT;
ANALYZE TABLE ODS_HC_CLIENTES;


DROP TABLES TMP_DIRECCIONES_CLIENTES, TMP_DIRECCIONES_CLIENTES2; 


USE ODS;



