SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[select_toll_charge_types] (@tollfilter	CHAR(1),
                                           @number 	INTEGER) 
AS
CREATE TABLE #temp
(
	tb_name			VARCHAR(100) NULL, 
	tb_axlecount		INTEGER NULL, 
	tb_cash_toll		MONEY NULL, 
	tb_card_toll		MONEY NULL, 
	ord_hdrnumber		INTEGER NULL, 
	lgh_number		INTEGER NULL, 
	mov_number		INTEGER NULL, 
	stp_sequence		INTEGER NULL, 
	orig_city		INTEGER NULL, 
	dest_city		INTEGER NULL, 
	ord_revtype1		VARCHAR(6) NULL, 
	ord_revtype2		VARCHAR(6) NULL, 
	ord_revtype3		VARCHAR(6) NULL, 
	ord_revtype4		VARCHAR(6) NULL, 	
	lgh_type1		VARCHAR(6) NULL, 
	lgh_type2		VARCHAR(6) NULL, 
	lgh_type3		VARCHAR(6) NULL, 
	lgh_type4		VARCHAR(6) NULL, 
	stp_loadstatus		VARCHAR(3) NULL, 
	cht_itemcode		VARCHAR(6) NULL, 
	pyt_itemcode		VARCHAR(6) NULL,
	axle_count			INTEGER	NULL
)

INSERT INTO #temp
   EXECUTE d_get_tolls_sp @tollfilter, @number

SELECT DISTINCT cht_itemcode
  FROM #temp

GO
GRANT EXECUTE ON  [dbo].[select_toll_charge_types] TO [public]
GO
