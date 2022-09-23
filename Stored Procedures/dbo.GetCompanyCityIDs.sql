SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetCompanyCityIDs]
@TYPE VARCHAR(10),
@VALUES AS IntInParm READONLY
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides ids for companies and cities for moves, legs, orders, and stops

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  04/18/2018   Chip Ciminero    WE-212496   Created
*******************************************************************************************************************/
--DECLARE @VALUES TABLE (intItem INT)
--DECLARE @TYPE VARCHAR(10)
--SET		@TYPE = 'Order' --Move, Leg, Order, Stop

--INSERT	@VALUES
--SELECT	854
       
DECLARE @M table (intItem int)
IF	@TYPE = 'Move'
	BEGIN
		INSERT	@M
		SELECT intItem FROM @VALUES  
	END

IF	@TYPE = 'Leg'
	BEGIN
		INSERT	@M
		SELECT	DISTINCT MOV_NUMBER FROM STOPS L WITH(NOLOCK) INNER JOIN @VALUES T ON L.lgh_number = T.intItem
	END

IF	@TYPE = 'Order'
	BEGIN
		INSERT	@M
		SELECT	DISTINCT MOV_NUMBER FROM STOPS L WITH(NOLOCK) INNER JOIN @VALUES T ON L.ord_hdrnumber = T.intItem
	END

IF	@TYPE = 'Stop'
	BEGIN
		INSERT	@M
		SELECT	DISTINCT MOV_NUMBER FROM STOPS L WITH(NOLOCK) INNER JOIN @VALUES T ON L.stp_number = T.intItem
	END

DECLARE @STOPS table (mov_number INT, lgh_number INT, ord_hdrnumber INT, stp_number INT, cmp_id VARCHAR(10), cty_id INT)	
INSERT	@STOPS
SELECT	DISTINCT  mov_number, lgh_number, ord_hdrnumber, stp_number, cmp_id, cty_id = stp_city
FROM	stops S WITH(NOLOCK) INNER JOIN 
		@M M ON S.mov_number = M.intItem

--GET ANY STOP RELATED COMPANIES FOR THE MOVE
SELECT	DISTINCT  mov_number, lgh_number, ord_hdrnumber, stp_number, cmp_id 
FROM	@STOPS
UNION ALL
--GET ANY RELATED BILLTO COMPANIES FOR THE MOVE
SELECT	 S.mov_number, lgh_number, S.ord_hdrnumber, stp_number, cmp_id = o.ord_billto
FROM	@STOPS S INNER JOIN 
		orderheader O WITH(NOLOCK) ON S.ord_hdrnumber = O.ord_hdrnumber
		
SELECT	DISTINCT mov_number, lgh_number, ord_hdrnumber, stp_number, cty_id
FROM	(
		SELECT	DISTINCT  mov_number, lgh_number, ord_hdrnumber, stp_number, cty_id 
		FROM	@STOPS
		UNION ALL
		SELECT	mov_number, lgh_number, ord_hdrnumber, stp_number, CO.cmp_city 'cty_id'
		FROM	@STOPS s INNER JOIN
				company CO WITH(NOLOCK) on s.cmp_id = CO.cmp_id 
		UNION ALL 
		SELECT	 S.mov_number, lgh_number, S.ord_hdrnumber, stp_number, C.cmp_city 'cty_id'
		FROM	@STOPS S INNER JOIN 
				orderheader O WITH(NOLOCK) ON S.ord_hdrnumber = O.ord_hdrnumber INNER JOIN
				company C ON o.ord_billto = C.cmp_id 
		UNION ALL
		SELECT mov_number, lgh_number, ord_hdrnumber, stp_number, ckc_city 'cty_id'
		FROM	checkcall C WITH(NOLOCK) INNER JOIN 
				@STOPS s ON C.ckc_lghnumber = s.lgh_number
		) D
WHERE	cty_id <> 0
GO
GRANT EXECUTE ON  [dbo].[GetCompanyCityIDs] TO [public]
GO
