SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_invoice_notes_sp](@p_ordnum varchar(18), @p_ivhnum varchar(18)) AS  

/**
 * 
 * NAME:
 * dbo.d_invoice_notes_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns notes attached to orderheader or invoiceheader associated with billing.
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_ordnum char;
 * 001 - @p_ivhnum char      
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 *
 * MODIFICATIONS
 * 4/25/07 EMK - Changed requires to NONE.
 **/

SELECT	notes.not_number, 
			notes.not_text, 
			notes.not_type, 
			notes.not_sequence
FROM notes 
WHERE 	notes.not_type = 'B'
		AND ((notes.ntb_table = 'orderheader' AND notes.nre_tablekey = @p_ordnum) -- Notes attached to order
		OR (notes.ntb_table = 'invoiceheader' AND notes.nre_tablekey IN 
				(select ivh_invoicenumber from invoiceheader where ord_hdrnumber = 
					(Select ord_hdrnumber from orderheader where ord_number = @p_ordnum)))) -- Notes attached to invoices associated with order
		OR (notes.ntb_table = 'invoiceheader' AND notes.nre_tablekey = @p_ivhnum) -- Notes attached to invoicenumber
		AND (ISNULL(DATEADD(day, ISNULL((SELECT gi_integer1 FROM generalinfo WHERE gi_name = 'showexpirednotesgrace'), 0), not_expires), getdate()) >= 
			 CASE ISNULL((SELECT gi_string1 FROM generalinfo WHERE gi_name = 'showexpirednotes'), 'Y')
				WHEN 'N' THEN getdate()
				ELSE ISNULL(DATEADD(day, ISNULL((SELECT gi_integer1 FROM generalinfo WHERE gi_name = 'showexpirednotesgrace'), 0), not_expires), getdate()) 
			 END)


GO
GRANT EXECUTE ON  [dbo].[d_invoice_notes_sp] TO [public]
GO
