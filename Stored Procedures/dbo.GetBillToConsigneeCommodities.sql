SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[GetBillToConsigneeCommodities] @BILLTO VARCHAR(50)
AS

/*******************************************************************************************************************  
  Object Description:
  Get the BillTo Consignee's Commodities for specific billTo.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  11/08/2016   Chip Ciminero    WE-202583   Created
*******************************************************************************************************************/

--CONSIGNEES
SELECT	DISTINCT C.CMP_ID, T.CMD_CODE, CO.CMD_NAME
FROM	company C INNER JOIN   
		(SELECT DISTINCT delivery FROM fuelrelations WHERE reltype='BILLSHPCNS' AND billto=@BILLTO) FR ON C.cmp_id=FR.delivery INNER JOIN
		COMPANY_TANKDETAIL T  ON C.cmp_id = T.cmp_id INNER JOIN 
		COMMODITY CO ON T.CMD_CODE = CO.CMD_CODE
WHERE	cmp_active = 'Y'  AND C.cmp_consingee='Y'  
ORDER BY c.cmp_id

GO
GRANT EXECUTE ON  [dbo].[GetBillToConsigneeCommodities] TO [public]
GO
