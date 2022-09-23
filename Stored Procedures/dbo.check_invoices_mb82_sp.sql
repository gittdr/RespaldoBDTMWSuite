SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[check_invoices_mb82_sp] (@p_ref_type VARCHAR(6), 
				 @p_ref_number VARCHAR(30), 
				 @p_cmp_id VARCHAR(8),
				 @p_OrdPend	int OUTPUT,
			         @p_HeldInvoice	int OUTPUT)
AS

/**
 * 
 * NAME:
 * dbo.check_invoices_mb82_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This stored proc checks invoices on hold and pending orders to ensure there are none.
 * If we find there are some, we need to stop the printing of the mb.
 *
 * RETURNS:
 * N/A 
 * 
 * RESULT SETS: 
 * See selection list
 *
 * PARAMETERS:
 * 001 - @p_ref_type VARCHAR(6), input
 *       This Parameter will filter our output by reference type from the referencenumber table. 
 *     
 * 002 - @p_ref_number VARCHAR(30), input
 *      The ref numbers to check.  We will look for orders/invoices belonging to this refnum
 *
 * 003 - @p_cmp_id INT, input
 *       Company we are printing the MasterBill for.
 *
 * 004 -  @p_OrdPend	int OUTPUT
 *       Sends back a count of the orders that are in a particular status.
 *
 * 005 -  @p_HeldInvoice int OUTPUT
 *       Sends back a count of the invoices that are on hold.
 *
 *
 *
 * REFERENCES: NONE
 *
 * 
 * REVISION HISTORY:
 * 07/12/2006.01 - PRB - Created Proc.
 *
 **/

CREATE TABLE #reftemp (	ord_hdrnumber int NOT NULL,
			ref_number varchar(20) NULL,
			ref_sequence INT NULL
		       )

INSERT INTO #reftemp
SELECT ord_hdrnumber, ref_number, ref_sequence
FROM referencenumber
WHERE ref_type = @p_ref_type
AND ref_table = 'orderheader'
GROUP BY ref_number, ord_hdrnumber, ref_sequence
ORDER BY ord_hdrnumber

--SELECT * FROM #reftemp

--Check pending orders to see if there are any with our refnum.
SELECT @p_OrdPend = COUNT(*)
		     From orderheader 
		     Where ord_hdrnumber in (SELECT DISTINCT(r.ord_hdrnumber)
			FROM referencenumber r, #reftemp
			WHERE r.ref_number = @p_ref_number
			AND #reftemp.ord_hdrnumber = r.ord_hdrnumber
			AND r.ref_sequence = (SELECT MIN(ref_sequence)
		     			      FROM #reftemp
		      			      WHERE r.ref_type = @p_ref_type
		      			      AND r.ord_hdrnumber = #reftemp.ord_hdrnumber))
						 					
And ord_billto = @p_cmp_id
And ord_invoicestatus in ('PND','AVL')

--Check invoices to see if any are on hold.

SELECT @p_HeldInvoice = COUNT(*)
			FROM invoiceheader
			WHERE ord_hdrnumber in (SELECT r.ord_hdrnumber
						FROM referencenumber r, #reftemp
						WHERE r.ref_number = @p_ref_number
						AND #reftemp.ord_hdrnumber = r.ord_hdrnumber
						AND r.ref_sequence = (SELECT MIN(ref_sequence)
		      			      			      FROM #reftemp
		     			      			      WHERE r.ref_type = @p_ref_type
		                                		      AND r.ord_hdrnumber = #reftemp.ord_hdrnumber))
And ivh_billto = @p_cmp_id
And ivh_invoicestatus IN ('HLD', 'HLA')


DROP TABLE #reftemp

GO
GRANT EXECUTE ON  [dbo].[check_invoices_mb82_sp] TO [public]
GO
