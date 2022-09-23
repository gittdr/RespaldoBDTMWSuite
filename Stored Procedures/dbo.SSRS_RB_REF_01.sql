SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[SSRS_RB_REF_01]
	@ord_hdrnumber int,
	@ivh_hdrnumber int   

AS  

CREATE TABLE #temp_ref 
	(
	ref_number varchar(200)
	)

IF @ord_hdrnumber > 0 

		INSERT INTO #temp_ref
--		SELECT ref_type+':'+ref_number as ref_number
		SELECT ref_number as ref_number
		FROM referencenumber
		WHERE ord_hdrnumber = @ord_hdrnumber
		AND ref_table = 'orderheader'
		ORDER BY ref_sequence

IF @ivh_hdrnumber > 0 and @ord_hdrnumber = 0 

		INSERT INTO #temp_ref
--		SELECT ref_type+':'+ref_number as ref_number
		SELECT ref_number as ref_number
		FROM referencenumber
		WHERE ref_table = 'invoiceheader'
		AND ref_tablekey = @ivh_hdrnumber
		ORDER BY ref_sequence

SELECT ref_number FROM #temp_ref

GO
