SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template115_subreport] (@invoice_nbr int)  
AS  

/*
 * 
 * NAME:dbo.invoice_template115_subreport
 * 
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoices details
 * based on the invoice selected.
 *
 * RETURNS:
 * 0 - IF NO DATA WAS FOUND  
 * 1 - IF SUCCESFULLY EXECUTED  
 * @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @invoice_nbr, int, input, null;
 *       Invoice number
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 05/07/2007 - PTS 35717 - OS - Created 
 **/
SELECT ivh.ivh_invoicenumber,     
	ivh.ivh_hdrnumber,
	ivd.ivd_charge amount,
	ivd.ivd_quantity gross,     
	ivd.ivd_rate rate, 
	ivd.ivd_count net,
	ivd.ivd_description,
	--ivd.ivd_sequence,
--	case cht_basis when 'ACC' then CASE chargetype.cht_itemcode
--									WHEN 'MIN' THEN ivd.ivd_sequence + 1000
--									ELSE ivd.ivd_sequence + 2000
--									END 
--					else ivd.ivd_sequence 
--	end ivd_sequence,
	case cht_basis when 'ACC' then CASE chargetype.cht_itemcode
									WHEN 'MIN' THEN ivd.ivd_sequence + 1000
									ELSE ivd.ivd_sequence + 3000
									END
					when 'SHP' then ivd.ivd_sequence    
					else ivd.ivd_sequence + 2000 
	end ivd_sequence,
	
	chargetype.cht_description,
	chargetype.cht_itemcode,
	'cht_basis' = case
		when chargetype.cht_itemcode = 'MIN' then 'SHP'
		else chargetype.cht_basis
	end,    
	ivh.ivh_revtype3,
	ivh_revtype3_t = 'RevType3',
	la.name revtype3_name,
	ivh.ivh_billto,
	cmp.cmp_blended_min_qty 
FROM invoiceheader ivh
	JOIN invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
	JOIN chargetype ON ivd.cht_itemcode = chargetype.cht_itemcode
	join labelfile la on la.abbr = ivh.ivh_revtype3 and la.labeldefinition = 'RevType3'
	join company cmp on ivh.ivh_billto = cmp.cmp_id 
WHERE ivh.ivh_hdrnumber = @invoice_nbr
and ivh.ivh_hdrnumber > 0
--and ivd.ivd_charge <> 0

GO
GRANT EXECUTE ON  [dbo].[invoice_template115_subreport] TO [public]
GO
