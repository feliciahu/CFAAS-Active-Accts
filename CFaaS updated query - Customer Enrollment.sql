SELECT
  CID.CUST_ACCT_ID,
  AC.CUSTOMER_STATUS,
  AC.FIRST_SALE_DATE,
  AC.LAST_SALE_DATE
FROM
 
/* DISTICNT LIST OF CFAAS ACCOUNTS WITH SALES*/
 
  (SELECT
    DISTINCT SUBSTRING(CFS.CUST_SALES, 5, 6) AS CUST_ACCT_ID
  FROM
    PRD_ENT_PL_DATALAKE_DB.CFAAS.V_ACRSDSH100 CFS
  WHERE
    CFS.PLANT IN ('8934') 
    AND BILL_QTY <> 0 
  ) AS CID
 
LEFT JOIN
 
/* CURRENT ACTIVE SALES STATUS */
 
(SELECT      
  SUBSTRING(CFS.CUST_SALES, 5, 6) AS CUST_ACCT_ID,
  MAX(CAST(SUBSTRING(CFS.CALDAY, 5, 2) || '/' || SUBSTRING(CFS.CALDAY, 7, 2) || '/' || SUBSTRING(CFS.CALDAY, 1, 4) AS DATE)) AS LAST_SALE_DATE,
  MIN(CAST(SUBSTR(CFS.CALDAY,5,2) || '/' || SUBSTR(CFS.CALDAY,7,2) || '/' || SUBSTR(CFS.CALDAY,1,4) AS DATE)) AS FIRST_SALE_DATE,
  (CASE 
    WHEN MAX(CAST(SUBSTRING(CFS.CALDAY, 5, 2) || '/' || SUBSTRING(CFS.CALDAY, 7, 2) || '/' || SUBSTRING(CFS.CALDAY, 1, 4) AS DATE)) >= DATEADD(day, -7, CURRENT_DATE) THEN 'Active'
    WHEN MAX(CAST(SUBSTRING(CFS.CALDAY, 5, 2) || '/' || SUBSTRING(CFS.CALDAY, 7, 2) || '/' || SUBSTRING(CFS.CALDAY, 1, 4) AS DATE)) < DATEADD(day, -7, CURRENT_DATE) THEN 'Inactive'
  END) AS CUSTOMER_STATUS
FROM        
  PRD_ENT_PL_DATALAKE_DB.CFAAS.V_ACRSDSH100 CFS
WHERE       
  CFS.PLANT IN ('8934') 
  AND BILL_QTY <> 0
GROUP BY
  SUBSTRING(CFS.CUST_SALES, 5, 6)
 
) AS AC ON AC.CUST_ACCT_ID = CID.CUST_ACCT_ID