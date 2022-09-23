SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE      PROC [dbo].[d_masterbill100_subreport_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),@ivh_invoicenumber varchar(12))
AS

/*
 * 
 * NAME:d_masterbill100_subreport_sp
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return SET of all the invoices a master bill.
 * 
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
 * 001 - @reprintflag, varchar, input; Is the masterbill a reprint
 * 002 - @mbnumber, int, input; Masterbill number
 * 003 - @billto, varchar, input; Masterbill Billto
 * 004 - @revtype1, varchar, input, NULL; Revtype 1
 * 005 - @revtype2, varchar, input, NULL; Revtype 2
 * 006 - @mbstatus, varchar, input; Status of mastebill RTP, PRN, etc.
 * 007 - @shipstart, datetime, input, 01/01/1950;
 * 008 - @shipend, datetime, input, 12/31/2049;
 * 009 - @billdate, datetime, input, currentdate;
 * 010 - @shipper, varchar, input, NULL; invoice shipper
 * 011 - @consignee, varchar, input, NULL; invoice consignee
 * 012 - @ivh_invoicenumber, varchar, input, NULL;
 *
 * REFERENCES: (called by AND calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 08/20/2007.01 - PTS38242 - EMK 	- Created for Modern Transportation Services
 * 09/10/2007.02 - PTS38242 - EMK - No changes, re-checked in for UNICODE problem
 * 09/20/2007.03 - PTS 39494 - EMK - Added billto in when not repriting.
 **/
SET NOCOUNT ON
DECLARE @v_int0  int
SELECT @v_int0 = 0

CREATE TABLE #masterbill_temp (ord_hdrnumber int,
		ivh_invoicenumber varchar(12),  
		ivh_hdrnumber int NULL, 
		ivd_number int NULL,
		ivd_sequence int NULL,    
		ivd_charge money NULL,
		cht_itemcode varchar(6) NULL,
		cht_basis varchar(6) NULL,
		cht_description varchar(30) NULL,
		cht_primary char(1) NULL)

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
BEGIN
    INSERT INTO	#masterbill_temp
    SELECT IsNull(invoiceheader.ord_hdrnumber, -1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		ivd.ivd_number,
		ivd.ivd_sequence, 	   
		ivd.ivd_charge,
		CASE WHEN cht.cht_primary = 'Y' THEN 'ZZZZLH' 
			 ELSE cht.cht_itemcode
	    END AS cht_itemcode,
		cht.cht_basis,
		cht.cht_description,
		cht.cht_primary
	FROM invoiceheader 
		INNER JOIN invoicedetail ivd ON invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber 
		INNER JOIN chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode 
	WHERE     (invoiceheader.ivh_mbnumber = @mbnumber) 
			AND (@shipper IN (invoiceheader.ivh_shipper, 'UNKNOWN')) 
			AND (@consignee IN (invoiceheader.ivh_consignee, 'UNKNOWN')) 
END

-- for master bills with 'RTP' status
IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	#masterbill_temp
     SELECT IsNull(invoiceheader.ord_hdrnumber, -1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		ivd.ivd_number, 	
		ivd.ivd_sequence,
		ivd.ivd_charge,
		CASE WHEN cht.cht_primary = 'Y' THEN 'XXLHXX' 
			 ELSE cht.cht_itemcode
	    END AS cht_itemcode,
		cht.cht_basis,
		cht.cht_description,
		cht.cht_primary
	FROM invoiceheader 
		INNER JOIN invoicedetail ivd ON invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber 
		INNER JOIN chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode 
		--PTS 38242 EMK - Removed invoiceheader.ivh_mbnumber = @mbnumber 
		--PTS 39494 EMK - Added billto line
		WHERE  @shipper IN (invoiceheader.ivh_shipper, 'UNKNOWN')
				AND (invoiceheader.ivh_billto = @billto )   
				AND @consignee IN (invoiceheader.ivh_consignee, 'UNKNOWN')
				AND @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master')
				AND invoiceheader.ivh_deliverydate between @shipstart AND @shipend 
				AND invoiceheader.ivh_mbstatus = 'RTP'  
				AND @revtype1 in (invoiceheader.ivh_revtype1,'UNK')
				AND @revtype2 in (invoiceheader.ivh_revtype2,'UNK') 
  END


CREATE TABLE #subtotal_temp (
		cht_itemcode varchar(6) NULL,
		cht_description varchar(30) NULL,
		charges money NULL)

--Line haul charges are grouped under cht_itemcode = 'ZZZZLH'
INSERT INTO #subtotal_temp 
SELECT cht_itemcode,cht_description, sum(ivd_charge) as charges from #masterbill_temp 
GROUP BY cht_itemcode,cht_description 

SELECT cht_itemcode,cht_description,charges from #subtotal_temp
WHERE charges <> 0
order by cht_itemcode DESC

DROP TABLE 	#subtotal_temp
DROP TABLE 	#masterbill_temp

GO
GRANT EXECUTE ON  [dbo].[d_masterbill100_subreport_sp] TO [public]
GO
