SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
    
CREATE PROCEDURE [dbo].[d_heniff_billoflading] (@ordnum int)
AS
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

CREATE TABLE #hbol (
ord_number varchar(12) NULL,
ord_hdrnumber int null,
LOAD_PICKUPDATE datetime null,
LOAD_DELIVERYDATE datetime NULL,
BILLTO varchar(50) NULL,
SUPPLIER varchar(100) NULL,
ORIGIN varchar(50) NULL,
ORIGIN_STATE VARCHAR(6) NULL,
REFERENCE_NUMBER VARCHAR(30) NULL,
REFERENCE_NUMBER_FGT VARCHAR(30) NULL,
-- PTS 24801 -- (start)
ORDERBY_ID varchar(8)
-- PTS 24801 -- (end)
)

INSERT INTO #hbol
SELECT       
       ORD.ORD_NUMBER DR_NO,
       ORD.ORD_HDRNUMBER ORD_HDRNUMBER,            
       ORD.ORD_ORIGIN_EARLIESTDATE LOAD_PICKUPDATE,
       ORD.ORD_DEST_EARLIESTDATE LOAD_DELIVERYDATE,       
       BILLTO.CMP_NAME BILLTO,
       CASE
	WHEN ORDERBY.CMP_NAME <> 'UNKNOWN' THEN ORDERBY.CMP_NAME
	ELSE SHIPPER.CMP_NAME
	END SUPPLIER,
       CASE WHEN ORDERBY.CMP_NAME <> 'UNKNOWN' THEN ''
	ELSE SHIPPER_CTY.CTY_NAME
	END ORIGIN,
       CASE WHEN ORDERBY.CMP_NAME <> 'UNKNOWN' THEN ''
	ELSE SHIPPER_CTY.CTY_STATE
	END ORIGIN_STATE,
       '' REFERENCE_NUMBER,
       '' REFERENCE_NUMBER_FGT,
-- PTS 24801 -- (start)
	ORDERBY.CMP_ID
-- PTS 24801 -- (end)

FROM  orderheader ord  LEFT OUTER JOIN  company shipper  ON  ORD.ORD_SHIPPER  = SHIPPER.CMP_ID   
		LEFT OUTER JOIN  company billto  ON  ORD.ORD_BILLTO  = BILLTO.CMP_ID   
		LEFT OUTER JOIN  company orderby  ON  ORD.ORD_COMPANY  = ORDERBY.CMP_ID   
		LEFT OUTER JOIN  city shipper_cty  ON  ORD.ORD_ORIGINCITY  = SHIPPER_CTY.CTY_CODE  
WHERE	 ORD.ORD_HDRNUMBER  = @ordnum
 
--Update the origin with the city based on the ord_company
IF EXISTS (SELECT * FROM  #hbol where ORIGIN = '')   
   BEGIN
      UPDATE #HBOL
         SET ORIGIN = CITY.CTY_NAME,
             ORIGIN_STATE = CITY.CTY_STATE
        FROM CITY, #HBOL, company
-- PTS 24801 -- (start)
--       WHERE #HBOL.SUPPLIER = COMPANY.CMP_NAME AND
	WHERE #HBOL.ORDERBY_ID = COMPANY.CMP_ID AND
-- PTS 24801 -- (end)
             COMPANY.CMP_CITY = CITY.CTY_CODE AND 
             #HBOL.ORIGIN = ''
   END   

--Update the temp table with the first reference number created for the order
UPDATE #HBOL
   SET REFERENCE_NUMBER = REF.REF_NUMBER
  FROM REFERENCENUMBER REF,#HBOL
 WHERE #HBOL.ORD_HDRNUMBER = REF.REF_TABLEKEY AND
       REF.REF_TABLE = 'ORDERHEADER' AND
       REF.REF_SEQUENCE = 1

--Update the temp table with the first reference number created for the order
UPDATE #HBOL
   SET REFERENCE_NUMBER_FGT = REF.REF_NUMBER
  FROM REFERENCENUMBER REF
 WHERE REF.ORD_HDRNUMBER = @ordnum AND
       REF.REF_TABLE = 'FREIGHTDETAIL' AND
       REF.REF_SEQUENCE = 1 AND
       REF.REF_TABLEKEY = (SELECT MIN(REF1.REF_TABLEKEY)
                             FROM REFERENCENUMBER REF1
                            WHERE REF1.ORD_HDRNUMBER = @ordnum AND
       	 		          REF1.REF_TABLE = 'FREIGHTDETAIL' AND
         		          REF1.REF_SEQUENCE = 1)
--Get the final results set
Select * from #hbol
GO
GRANT EXECUTE ON  [dbo].[d_heniff_billoflading] TO [public]
GO
