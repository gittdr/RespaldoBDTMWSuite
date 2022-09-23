SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_heniffcon_billoflading] (@ordnum int)
AS
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

CREATE TABLE #hbol_con (
STOP_EVENT varchar(6) NULL,
STOP_MFH_SEQUENCE INT NULL,
CONSIGNEE_NAME varchar(100) NULL,
CONSIGNEE_ID  VARCHAR(8) NULL,
CONSIGNEE_ADDR1 VARCHAR(100) NULL,
CONSIGNEE_ADDR2 VARCHAR(100) NULL,
STATE varchar(6) NULL ,
CITY varchar(18) NULL,
)

INSERT INTO #hbol_con
SELECT       
         
       STP.STP_TYPE STOP_EVENT,  
       STP.STP_MFH_SEQUENCE STOP_MFH_SEQUENCE ,    
       CMP.CMP_NAME CONSIGNEE_NAME,
       CMP.CMP_ID CONSIGNEE_ID,
       CMP.CMP_ADDRESS1 CONSIGNEE_ADDR1,
       CMP.CMP_ADDRESS2 CONSIGNEE_ADDR2,
       STP.STP_STATE STATE, 
       CTY.CTY_NAME CITY
FROM  stops stp  LEFT OUTER JOIN  company cmp  ON  STP.CMP_ID  = CMP.CMP_ID   
				LEFT OUTER JOIN  city cty  ON  STP.STP_CITY  = CTY.CTY_CODE ,
	 orderheader ord 
WHERE	 ORD.ORD_HDRNUMBER  = @ordnum
 AND	ORD.ORD_HDRNUMBER  = STP.ORD_HDRNUMBER

--Get the final results set
SELECT * FROM #hbol_con WHERE stop_event = 'DRP'
GO
GRANT EXECUTE ON  [dbo].[d_heniffcon_billoflading] TO [public]
GO
