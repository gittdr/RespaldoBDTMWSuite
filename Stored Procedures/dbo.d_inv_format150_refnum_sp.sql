SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE PROC [dbo].[d_inv_format150_refnum_sp](  
@ord_hdrnumber int,
@ivh_hdrnumber int   
)  
AS  

CREATE TABLE #temp_ref (
ref_number varchar(30)
)

IF @ord_hdrnumber > 0 
	BEGIN
		INSERT INTO #temp_ref
		SELECT top 4 ref_number
		FROM referencenumber
		WHERE ord_hdrnumber = @ord_hdrnumber
		AND ref_table = 'orderheader'
		ORDER BY ref_sequence

		INSERT INTO #temp_ref
		SELECT top 7 ref_number
		FROM referencenumber
		WHERE ord_hdrnumber = @ord_hdrnumber
		AND ref_table = 'stops'
		ORDER BY ref_sequence
	END

IF @ivh_hdrnumber > 0 and @ord_hdrnumber = 0 

		INSERT INTO #temp_ref
		SELECT top 9 ref_number
		FROM referencenumber
		WHERE ref_table = 'invoiceheader'
		AND ref_tablekey = @ivh_hdrnumber
		ORDER BY ref_sequence


SELECT top 9 ref_number FROM #temp_ref

GO
GRANT EXECUTE ON  [dbo].[d_inv_format150_refnum_sp] TO [public]
GO
