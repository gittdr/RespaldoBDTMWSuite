SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_view_commodity_last_multiple] (@stringparm VARCHAR(13), @numberparm INT, @retrieveby CHAR(3))
AS

DECLARE @reftypelist		VARCHAR(100),
	@OrderRefTypeList	VARCHAR(100)

SELECT @reftypelist = gi_string2
  FROM generalinfo
 WHERE gi_name = 'MultipleLastCommodityOrders'

IF LEN(@reftypelist) > 0
BEGIN
   SET @reftypelist = ',' + @reftypelist + ','
END

SELECT @OrderRefTypeList = gi_string1
  FROM generalinfo
 WHERE gi_name = 'ExcludeOrdersFromHistory'
IF LEN(@OrderRefTypeList) > 0
BEGIN
   SET @OrderRefTypeList = ',' + @OrderRefTypeList + ','
END

CREATE TABLE #move(
	mov_number 		INTEGER			NULL,
	asgn_date		DATETIME		NULL
)

CREATE TABLE #freight(
	ord_hdrnumber		INTEGER			NULL,
	evt_enddate		DATETIME		NULL, 
	cmd_code		VARCHAR(8)		NULL, 
	cmd_name		VARCHAR(60)		NULL, 
	fgt_weight		FLOAT			NULL, 
	fgt_weightunit		VARCHAR(6)		NULL, 
	fgt_count		DECIMAL(10,2)		NULL, 
	fgt_countunit		VARCHAR(6)		NULL, 
	fgt_volume		FLOAT			NULL, 
	fgt_volumeunit		VARCHAR(6)		NULL, 
	fgt_quantity		FLOAT			NULL, 
	fgt_unit		VARCHAR(6)		NULL, 
	scm_subcode		VARCHAR(8)		NULL, 
	trailer			VARCHAR(13)		NULL,
	ref_type		VARCHAR(6)		NULL,
	ref_number		VARCHAR(30) 		NULL,
	ord_number		VARCHAR(12)		NULL,
	ord_reftype		VARCHAR(6)		NULL
)

INSERT INTO #move
   SELECT DISTINCT TOP 5 assetassignment.mov_number, asgn_date
     FROM assetassignment JOIN legheader ON assetassignment.lgh_number = legheader.lgh_number AND
                                            legheader.ord_hdrnumber NOT IN (SELECT ref_tablekey
                                                                              FROM referencenumber
                                                                             WHERE ref_table = 'orderheader' AND
                                                                                   ref_tablekey = legheader.ord_hdrnumber AND
                                                                                   cHARINDEX(',' + ref_type + ',', @OrderRefTypeList) > 0) AND
                                            legheader.lgh_number IN (SELECT stops.lgh_number
                                                                       FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                                                                                                event.evt_pu_dr = 'DRP'
                                                                      WHERE stops.lgh_number = legheader.lgh_number)
    WHERE asgn_id = @stringparm AND
          asgn_type = 'TRL' AND
          asgn_status IN ('STD', 'CMP')
   ORDER BY asgn_date DESC 

INSERT INTO #freight
   SELECT DISTINCT event.ord_hdrnumber, event.evt_enddate, commodity.cmd_code, commodity.cmd_name, 
	  freightdetail.fgt_weight, freightdetail.fgt_weightunit, freightdetail.fgt_count, freightdetail.fgt_countunit, 
	  freightdetail.fgt_volume, freightdetail.fgt_volumeunit, freightdetail.fgt_quantity, freightdetail.fgt_unit, 
	  CONVERT(VARCHAR(8), '') scm_subcode, @stringparm, referencenumber.ref_type, referencenumber.ref_number,
          orderheader.ord_number, orderheader.ord_reftype
     FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                              event.evt_pu_dr = 'DRP' AND
                              event.evt_trailer1 = @stringparm
		JOIN freightdetail ON event.stp_number = freightdetail.stp_number
                JOIN orderheader ON event.ord_hdrnumber = orderheader.ord_hdrnumber
                LEFT OUTER JOIN referencenumber ON freightdetail.fgt_number = referencenumber.ref_tablekey AND
                                                   referencenumber.ref_table = 'freightdetail' AND
                                                   CHARINDEX(',' + referencenumber.ref_type + ',', @reftypelist) > 0
                JOIN commodity ON freightdetail.cmd_code = commodity.cmd_code
    WHERE stops.mov_number IN (SELECT mov_number 
	                                  FROM #move)
       
   SELECT DISTINCT ord_hdrnumber, evt_enddate, cmd_code, cmd_name, 
          CASE fgt_weight WHEN 0 THEN NULL ELSE fgt_weight END fbc_weight, 
          CASE fgt_weight WHEN 0 THEN NULL ELSE fgt_weightunit END fgt_weightunit, 
          CASE fgt_count WHEN 0 THEN NULL ELSE fgt_count END fgt_count, 
          CASE fgt_count WHEN 0 THEN NULL ELSE fgt_countunit END fgt_countunit, 
          CASE fgt_volume WHEN 0 THEN NULL ELSE fgt_volume END fbc_volume, 
          CASE fgt_volume WHEN 0 THEN NULL ELSE fgt_volumeunit END fgt_volumeunit, 
          CASE fgt_quantity WHEN 0 THEN NULL ELSE fgt_quantity END fgt_quantity, 
          CASE fgt_quantity WHEN 0 THEN NULL ELSE fgt_unit END fgt_unit, 
          scm_subcode, trailer, ref_type, ref_number, ord_number, ord_reftype
     FROM #freight

GO
GRANT EXECUTE ON  [dbo].[d_view_commodity_last_multiple] TO [public]
GO
