USE STAGE;

/*BIEN, TODO EN ORDEN. SEGUN LOS RESULTADOS ES EVIDENTE QUE HAY QUE ABRIR DIMENSIONES: CICLO DE FACTURACIONES Y METODO DE PAGO.
 BASICAMENTE IGUAL QUE EL MODELO BBASE EXCEPTUANDO LA TBLA DE KMONEDA QUE LA OMITIRÉ PUES ESTAMOS OPERANDO SOLO EN ESTADOS UNIDOS */

SELECT COUNT(*) TOTAL_FACTURAS
, SUM(CASE WHEN LENGTH(TRIM(BILL_REF_NO))<>'' THEN 1 ELSE 0 END) BILL_REF_NO
, COUNT(DISTINCT CASE WHEN LENGTH((BILL_REF_NO))<>'' THEN BILL_REF_NO ELSE 0 END) TOTAL_DISTINTOS_BILL_REF_NO
, SUM(CASE WHEN LENGTH(TRIM(CUSTOMER_ID))<>'' THEN 1 ELSE 0 END) TOTAL_CUSTOMER_ID
, COUNT(DISTINCT CASE WHEN LENGTH((CUSTOMER_ID))<>'' THEN CUSTOMER_ID ELSE 0 END) TOTAL_DISTINTOS_CUSTOMER_ID
, SUM(CASE WHEN LENGTH(TRIM(START_DATE))<>'' THEN 1 ELSE 0 END) TOTAL_START_DATE
, COUNT(DISTINCT CASE WHEN LENGTH((START_DATE))<>'' THEN START_DATE ELSE 0 END) TOTAL_DISTINTOS_START_DATE
, SUM(CASE WHEN LENGTH(TRIM(END_DATE))<>'' THEN 1 ELSE 0 END) TOTAL_END_DATE
, COUNT(DISTINCT CASE WHEN LENGTH((END_DATE))<>'' THEN END_DATE ELSE 0 END) TOTAL_DISTINTOS_END_DATE
, SUM(CASE WHEN LENGTH(TRIM(STATEMENT_DATE))<>'' THEN 1 ELSE 0 END) STATEMENT_DATE
, COUNT(DISTINCT CASE WHEN LENGTH((STATEMENT_DATE))<>'' THEN STATEMENT_DATE ELSE 0 END) TOTAL_DISTINTOS_STATEMENT_DATE
, SUM(CASE WHEN LENGTH(TRIM(PAYMENT_DATE))<>'' THEN 1 ELSE 0 END) TOTAL_PAYMENT_DATE
, COUNT(DISTINCT CASE WHEN LENGTH((PAYMENT_DATE))<>'' THEN PAYMENT_DATE ELSE 0 END) TOTAL_DISTINTOS_PAYMENT_DATE
, SUM(CASE WHEN LENGTH(TRIM(BILL_CYCLE))<>'' THEN 1 ELSE 0 END) TOTAL_BILL_CYCLE
, COUNT(DISTINCT CASE WHEN LENGTH((BILL_CYCLE))<>'' THEN BILL_CYCLE ELSE 0 END) TOTAL_DISTINTOS_BILL_CYCLE
, SUM(CASE WHEN LENGTH(TRIM(AMOUNT))<>'' THEN 1 ELSE 0 END) TOTAL_AMOUNT
, COUNT(DISTINCT CASE WHEN LENGTH((AMOUNT))<>'' THEN AMOUNT ELSE 0 END) TOTAL_DISTINTOS_AMOUNT
, SUM(CASE WHEN LENGTH(TRIM(BILL_METHOD))<>'' THEN 1 ELSE 0 END) TOTAL_BILL_METHOD
, COUNT(DISTINCT CASE WHEN LENGTH((BILL_METHOD))<>'' THEN BILL_METHOD ELSE 0 END) TOTAL_DISTINTOS_BILL_METHOD
FROM STG_FACTURAS_FCT;


