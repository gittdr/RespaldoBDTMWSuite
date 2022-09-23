SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[AssetPaperwork_ByLeg]
@ASSET_TYPE VARCHAR(10), @ASSET_ID VARCHAR(25), @LEGNUMBER INT = NULL, @RECEIVED BIT = NULL, @REQUIRED BIT = NULL, @DOC_TYPE VARCHAR(10) = NULL
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides the ability to lookup asset based paperwork by leg number.  
  Based on what is received and required, it will provide a status to be used in TMW Go.

  Statuses: 4 = Required,
            3 = Pending (This will be applied at the UI/API level via Imaging),
            2 = Received,
            1 = Optional
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  01/05/2018   Chip Ciminero    WE-212980   Created
*******************************************************************************************************************/

--SP PARAMS / TEST DATA
--DECLARE @ASSET_TYPE VARCHAR(10), @ASSET_ID VARCHAR(25)
--		, @LEGNUMBER INT = NULL, @RECEIVED BIT = NULL, @REQUIRED BIT = NULL
--		, @DOC_TYPE VARCHAR(10) = NULL
--SELECT @ASSET_TYPE = 'DRV',  @ASSET_ID = 'ROMAL', @LEGNUMBER = 8272

DECLARE @DATA TABLE (LegNumber INT, OrderNumber INT, DocType VARCHAR(10), DocTypeName VARCHAR(100), [Received] BIT, [Required] BIT)
INSERT	@DATA
SELECT  DISTINCT * 
FROM	(
		SELECT	P.lgh_number AS LegNumber, P.ord_hdrnumber AS OrderNumber, P.abbr AS DocType, L.[name] AS DocTypeName
				,MAX(CASE WHEN P.pw_received = 'Y' THEN 1 ELSE 0 END) AS [Received]
				,MAX(CASE WHEN BDT.bdt_inv_required = 'Y' THEN 1 ELSE 0 END) AS [Required]
		FROM	paperwork P INNER JOIN
				labelfile L ON P.abbr = L.abbr AND L.labeldefinition = 'paperwork' LEFT OUTER JOIN
				(
				SELECT	O.ord_hdrnumber, B.cmp_id, B.bdt_inv_required, B.bdt_doctype
				FROM	orderheader O  INNER JOIN
						BillDoctypes B ON O.ord_billto = B.cmp_id
				) BDT ON P.ord_hdrnumber = BDT.ord_hdrnumber AND P.abbr = BDT.bdt_doctype INNER JOIN
				assetassignment A ON P.lgh_number = A.lgh_number 
		WHERE P.lgh_number = ISNULL(@LEGNUMBER,P.lgh_number) AND A.asgn_type = ISNULL(@ASSET_TYPE, A.asgn_type) AND A.asgn_id = ISNULL(@ASSET_ID,A.asgn_id) 	
				AND P.abbr = ISNULL(@DOC_TYPE, P.abbr)
				AND (l.retired = 'N' or (l.retired = 'Y' and p.pw_received = 'Y'))
		GROUP BY P.lgh_number, P.ord_hdrnumber, P.abbr, L.[name] 		
		) B
WHERE	Received = ISNULL(@RECEIVED,Received) AND [Required] = ISNULL(@REQUIRED,[Required])

SELECT LegNumber, DocType, DocTypeName, [Status] = MAX(CASE WHEN Received = 1 THEN 2 
											 WHEN Received = 0 AND [Required] = 1 THEN 4
											 WHEN Received = 0 AND [Required] = 0 THEN 1
											 END), Orders = COUNT(DISTINCT OrderNumber), OrderNumber=MAX(OrderNumber)

FROM @DATA
GROUP BY LegNumber, DocType, DocTypeName
ORDER BY LegNumber, [Status] DESC, DocTypeName 
GO
GRANT EXECUTE ON  [dbo].[AssetPaperwork_ByLeg] TO [public]
GO
