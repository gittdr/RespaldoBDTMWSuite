SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[image_indexdata002_sp] (@ordnumber varchar(12))    
As  



/**
 * 
 * NAME:
 * dbo.image_indexdata002_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * (for Microdea) used to provide index information given an order
 *
 * RETURNS:
 * [N/A]
 *
 * RESULT SETS: 
 * [See selection list]
 *
 * PARAMETERS:
 * 001 - @ordnumber, varchar(12), input;
 *       This parameter indicates the order number 
 *       to which the result set is associated. The value must be 
 *       non-null and non-empty.
 *
 * REFERENCES: NONE
 * 
 * REVISION HISTORY:
 * 08/13/02.01 - Created PTS 14952 DPETE
 *  Since they only want one result back, the proc currently  picks up the BL# or
 *  BOL ref number with the lowest sequence number in the ref table
 * 08/13/02.02 - MODIFICATION LOG (for Microdea) used to provide index information given an order  
 *
 *	Created PTS 14952 DPETE  
 *
 *	Since they only want one result back, the proc currently  picks up the BL# or
 *	BOL ref number with the lowest sequence number in the ref table
 *
 * 01/19/2006.01 – PTS 31390 - Phil Bidinger
 *  In all cases if there is no such data, return an empty string rather than NULL
 *
 *	If an invoice record exists for this order (Select the one with the lowest ivh_hdrnumber key)
 *
 *	1 - Bill to company id (ivh_billto)
 *	2 - Bill of Lading Number (First or max  orderheader reference number with a ref type of BOL of BL#
 *	3 - Purchase Order Number (First or max  orderheader reference number with PO as the reference type)
 *	4 - Ship date (ivh_shipdate  converted to a char MM/DD/YYYY from datetime)
 *	5 - Invoice number ('')
 *	6 - Master bill number ( '')
 *	7 - Bill date (ord_billdate converted to a date from datetime where ord_number matches)
 *	8 - Pcikup Driver ID (ivh_driver from invoiceheader, if UNKNOWN pass an empty string)
 *
 *	If an invoice does not exist, but an order (orderheader record does exist)  return ....
 *
 *
 *	1 - Bill to company id (ord_billto)
 *	2 - Bill of Lading Number (First or max  orderheader reference number with a ref tyoe of BOL or BL#
 *	3 - Purchase Order Number (First or max  orderheader referencenumber with PO as the reference type)
 *	4 - Ship date (ord_shipdate  converted to a char MM/DD/YYYY from datetime)
 *	5 - Invoice number ( '')
 *	6 - Master bill number ( '')
 *	7 - Bill date ('')
 *	8 - Pcikup Driver ID (ord_driver1 from orderheader, if UNKNOWN pass an empty string)
 *
 **/

-- IF our ordnumber that was passed exists, process rules.  Otherwise return blanks instead of nulls.
IF EXISTS(SELECT 1 FROM orderheader WHERE ord_number = @ordnumber)
BEGIN
	-- Let's check on whether the invoice is there.  Then get our information...no null's allowed.
	IF EXISTS(SELECT 1 FROM invoiceheader WHERE ord_number = @ordnumber)
	BEGIN
	SELECT BillTo = ISNULL(ivh_billto, ' '), 
			ISNULL((Select MAX(ref_number) FROM Referencenumber
					Where ord_hdrnumber = @ordnumber
					AND ref_table = 'orderheader'
					AND ref_type IN('BOL', 'BOL#')), ' ') As BillOfLading,
			ISNULL((Select MAX(ref_number) FROM Referencenumber
					Where ord_hdrnumber = @ordnumber
					AND ref_table = 'orderheader'
					AND ref_type = 'PO'), ' ') As PONumber,
			ISNULL(Convert(CHAR(10),ivh_shipdate, 101), ' ') AS ShipDate,
			ISNULL(ivh_invoicenumber, ' ') AS InvoiceNumber, 
			ISNULL(ivh_mbnumber, ' ') AS MasterBill,
			ISNULL(Convert(CHAR(10),ivh_billdate, 101), ' ') AS BillDate,
			CASE ivh_driver WHEN 'UNKNOWN' THEN ' '
			 ELSE ivh_driver
			 END AS PickupDriverId
			FROM invoiceheader
			WHERE
			ivh_hdrnumber = (SELECT MIN(ivh_hdrnumber) FROM invoiceheader
					  WHERE ord_number = @ordnumber)
			
	END
	ELSE
	BEGIN
	SELECT BillTo = ISNULL(ord_billto, ' '), 
			ISNULL((Select MAX(ref_number) FROM Referencenumber
					Where ord_hdrnumber = @ordnumber
					AND ref_table = 'orderheader'
					AND ref_type IN('BOL', 'BOL#')), ' ') As BillOfLading,
			ISNULL((Select MAX(ref_number) FROM Referencenumber
					Where ord_hdrnumber = @ordnumber
					AND ref_table = 'orderheader'
					AND ref_type = 'PO'), ' ') As PONumber,
			ISNULL(Convert(CHAR(10),ord_completiondate, 101), ' ') AS ShipDate,
			' ' AS InvoiceNumber, 
			' ' AS MasterBill,
			' ' AS BillDate,
			CASE ord_driver1 WHEN 'UNKNOWN' THEN ' '
			 ELSE ord_driver1
			 END AS PickupDriverId
			FROM orderheader
			WHERE
			ord_number = @ordnumber
	END
END
ELSE
BEGIN
	--If our passed ordnumber doesn't exist we need to return blanks not nulls.
	SELECT BillTo = ' ',
	BillOfLading = ' ',
	PoNumber = ' ',
	ShipDate = ' ',
	InvoiceNumber = ' ',
	MasterBillNumber = ' ',
	BillDate = ' ',
	PickupDriverId = ' ' 
END

GO
GRANT EXECUTE ON  [dbo].[image_indexdata002_sp] TO [public]
GO
