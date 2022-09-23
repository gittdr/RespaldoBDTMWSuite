SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill106_refsub] (@ord_hdrnumber int, @ivh_hdrnumber int,@maxrows int,@returnset int)

AS  
/**
 * 
 * NAME:
 * dbo.d_masterbill106_refsub
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure returns reference numbers for use in subreports.  It returns
 * either order reference numbers, or if ordernumber is 0, then returns invoiceheader
 * numbers.  Maximum rows dictates how many rows to return.
 * and for the table and key passed 
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * refnumbers varchar (500) a comma separated list of all ref numbers for the table and key values
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber - If not 0, returns matching orderheader ref number. 
 * 002 - @ivh_hdrnumber - When ord_hdrnumber <>0 return matching invoiceheader ref numbers.
 *       The key for the table for which ref numbers are to be returned 
 * 003 - @maxrows - Maximum number of rows to return.  If 0 input, returns up to 1000.
 * 004 - @returnset - When 1, actually return rows, when 0 return no rows Used to keep
 *                    row sizes in datawindow small. 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 (

 * 
 * REVISION HISTORY:
 * 12/07/07 ? PTS40126 - EMK ? Created
 *
 **/


SELECT @ord_hdrnumber = IsNUll(@ord_hdrnumber,0)
SELECT @ivh_hdrnumber = IsNUll(@ivh_hdrnumber,0)

--Set the rowcount
IF IsNull(@maxrows,0) <> 0 SET ROWCOUNT @maxrows

--Set the return set, setting both to zero will force empty return set
if @returnset = 0 select @ord_hdrnumber=0,@ivh_hdrnumber=0


IF @ord_hdrnumber <> 0 
	BEGIN
		--Get orderheader numbers
		SELECT ref_number,ref_type,ref_table,ref_sequence FROM referencenumber
		WHERE ref_table = 'ORDERHEADER' AND ref_tablekey = @ord_hdrnumber
		ORDER BY ref_sequence
	END
ELSE
	IF @ivh_hdrnumber <> 0
		--Get invoiceheader numbers
		BEGIN
			SELECT ref_number,ref_type,ref_table,ref_sequence FROM referencenumber
			WHERE ref_table = 'INVOICEHEADER' AND ref_tablekey = @ivh_hdrnumber
			ORDER BY ref_sequence
		END
	ELSE
		-- Return nothing
		BEGIN
			SELECT ref_number,ref_type,ref_table,ref_sequence FROM referencenumber
			WHERE 1 = 0
		END


GO
GRANT EXECUTE ON  [dbo].[d_masterbill106_refsub] TO [public]
GO
