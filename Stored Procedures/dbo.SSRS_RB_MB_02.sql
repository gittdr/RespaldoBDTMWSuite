SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROC [dbo].[SSRS_RB_MB_02] (@reprintflag VARCHAR(10), @mbnumber INT, @ivh_billto VARCHAR(8),
					@ivh_revtype1 VARCHAR(6), @ivh_revtype2 VARCHAR(6), @ivh_revtype3 VARCHAR(6), @ivh_revtype4 VARCHAR(6), @ivh_mbstatus VARCHAR(6),
					@datetype VARCHAR(1), @startdate DATETIME, @enddate DATETIME, @billdate DATETIME,
					@shipcmpid VARCHAR(8), @conscmpid VARCHAR(8), @ivh_invoicenumber VARCHAR(12),
					@orderbycmpid VARCHAR(8), @taxacc VARCHAR(6),@ord_FROMorder VARCHAR(12),@ivs_number INT)
AS
CREATE TABLE #fuel
	(
		RefType VARCHAR(10) NULL
	)

	DECLARE @RefID varchar(10), @Pos int, @RefList VARCHAR(100)

	SET @RefList = (SELECT gi_string1
		        FROM generalinfo WHERE gi_name = 'MasterBill85FuelTypes')

	SET @RefList = LTRIM(RTRIM(@RefList))+ ','
	SET @Pos = CHARINDEX(',', @RefList, 1)

	IF REPLACE(@RefList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @RefID = LTRIM(RTRIM(LEFT(@RefList, @Pos - 1)))
			IF @RefID <> ''
			BEGIN
				INSERT INTO #fuel (RefType) VALUES (@RefID)
			END
			SET @RefList = RIGHT(@RefList, LEN(@RefList) - @Pos)
			SET @Pos = CHARINDEX(',', @RefList, 1)

		END
	END	


IF @ivh_mbstatus <> 'RTP' SELECT @reprINTflag = 'REPRINT'

DECLARE @ivh_hdrnumber INT
DECLARE @shipstart DATETIME
DECLARE @shipEND DATETIME
DECLARE @delstart DATETIME
DECLARE @delEND DATETIME
DECLARE @INT0  INT

SET @INT0 = 0
SET @ord_FROMorder = ISNULL(@ord_FROMorder,'')  
IF @datetype = 'S'
		BEGIN 
			SET @shipstart = @startdate
			SET @shipEND   = @ENDdate
			SET @delstart = CONVERT(CHAR(12),'01/01/1950')+'00:00:00'
			SET @delEND   = CONVERT(CHAR(12),'12/31/2049')+'23:59:59'
		END
	ELSE
		BEGIN
			SET @shipstart = CONVERT(CHAR(12),'01/01/1950')+'00:00:00'
			SET @shipEND   = CONVERT(CHAR(12),'12/31/2049')+'23:59:59'
			SET @delstart = @startdate
			SET @delEND   = @ENDdate
		END

SELECT 
	ISNULL(ivh.ord_hdrnumber,-1) 'ord_hdrnumber',
	ivh.ivh_invoicenumber  'Invoice Header Invoice Number',
	ivh.ivh_hdrnumber , 
	ivh.ivh_billto 'Invoice Header Bill To',
	bc.cmp_name 'Invoice Header Bill To Name',
	bc.cmp_address1 'Invoice Header Bill To Add1',
	bc.cmp_address2 'Invoice Header Bill To Add2',
	bcty.cty_name 'Invoice Header Bill To City',
	bcty.cty_state 'Invoice Header Bill To State',
	bc.cmp_zip 'Invoice Header Bill To Zip',
	ivh.ivh_shipper,
	shipcmp.cmp_name 'Invoice Header Shipper Name',
	shipcmp.cmp_address1 'Invoice Header Shipper Add1',
	shipcmp.cmp_address2 'Invoice Header Shipper Add2',
	shipcty.cty_name 'Invoice Header Shipper City',
	shipcty.cty_state 'Invoice Header Shipper State',
	shipcmp.cmp_zip 'Invoice Header Shipper Zip',
	ivh.ivh_consignee,
	concmp.cmp_name 'Invoice Header Consignee Name',
	concmp.cmp_address1 'Invoice Header Consignee Add1',
	concmp.cmp_address2 'Invoice Header Consignee Add2',
	concty.cty_name 'Invoice Header Consignee City',
	concty.cty_state 'Invoice Header Consignee State',
	concmp.cmp_zip 'Invoice Header Consignee Zip',
	ivh.ivh_totalCHARge,   
	ivh.ivh_shipdate,   
	ivh.ivh_deliverydate,
	ivh.ivh_revtype1,
	ISNULL(CASE  
		WHEN UPPER(@reprINTflag) = 'REPRINT' THEN ivh.ivh_mbnumber
		ELSE @mbnumber
	END,'') 'ivh_mbnumber',
	ISNULL(CASE  
		WHEN UPPER(@reprINTflag) = 'REPRINT' THEN ivh.ivh_billdate
		WHEN @billdate = '01/01/1950' THEN ivh.ivh_billdate
		ELSE @billdate
	END,'') 'ivh_billdate',
	ivd.ivd_quantity,
	ISNULL(ivd.ivd_unit, '') 'ivd_unit' ,	
	ISNULL(ivd.ivd_rate, 0) 'ivd_rate',
	ISNULL(ivd.ivd_rateunit, '') 'ivd_rateunit',
	ivd.ivd_CHARge,
	cht.cht_description,
	cht.cht_primary,
	cmd.cmd_name,
	ISNULL(ivd_description, '') 'ivd_description',
	ivd.ivd_type,
	ivd_sequence,
	ISNULL(stp.stp_number, -1) 'stp_number',
	ivh.ivh_CHARge,
	ivd.cht_basisunit,
	@taxacc 'tax_acc',
	ivd.cht_itemcode,
	ref_po_v = ISNULL((SELECT TOP 1 ref_number FROM referencenumber WHERE referencenumber.ord_hdrnumber = ivh.ord_hdrnumber and ref_type = 'PO/V#'),''),
	ref_ship_tick = ISNULL((SELECT TOP 1 ref_number FROM referencenumber WHERE referencenumber.ord_hdrnumber = ivh.ord_hdrnumber and ref_type = 'RFTKT'),''),
	ref_bol = ISNULL((SELECT TOP 1 ref_number FROM referencenumber WHERE referencenumber.ord_hdrnumber = ivh.ord_hdrnumber and ref_type = 'LPBL'),''),
	ivs.ivs_logocompanyname,
	ivs.ivs_logocompanyloc,
	ivs.ivs_remittocompanyname,
	ivs.ivs_remittocompanyloc,
	ivs.ivs_terms,
	ivh.ivh_totalweight,
	ord.ord_contact,
	[dbo].[TMWSSRS_fcn_referencenumbers_CRLF](ivh.ord_hdrnumber,'orderheader') as refnumbers,
		   --PRB ADDED
	   fueltotal = ISNULL((SELECT SUM(ISNULL(ivd_charge, 0))
	   		 	FROM invoicedetail
	   		 	WHERE ivh_hdrnumber = ivh.ivh_hdrnumber
	   		 	AND cht_itemcode IN(SELECT RefType
						    FROM #fuel)), 0),
	   ivh.ord_number,
           --Need to select all other possible Acc. charges minus the fueltotal.
	   otheracc_total = ISNULL((SELECT SUM(ISNULL(ivd_charge, 0))
	   		 	FROM invoicedetail
				INNER JOIN chargetype
				ON invoicedetail.cht_itemcode = chargetype.cht_itemcode
	   		 	WHERE ivh_hdrnumber = ivh.ivh_hdrnumber
	   		 	AND invoicedetail.cht_itemcode NOT IN(SELECT RefType
						    		      FROM #fuel)
				AND chargetype.cht_basis = 'ACC'), 0)
	   --PRB END
INTO #masterbill_temp
FROM  invoiceheader ivh
	INNER JOIN invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber and ivd.ivd_CHARge > 0
	LEFT JOIN sTOPs stp on ivd.stp_number = stp.stp_number 
	LEFT JOIN  commodity cmd on ivd.cmd_code = cmd.cmd_code
	INNER JOIN company bc on bc.cmp_id = ivh.ivh_billto
	INNER JOIN city bcty on bcty.cty_code = bc.cmp_city
	INNER JOIN company shipcmp on shipcmp.cmp_id = ivh.ivh_shipper
	INNER JOIN city shipcty on shipcty.cty_code = shipcmp.cmp_city
	INNER JOIN company concmp on concmp.cmp_id = ivh.ivh_consignee
	INNER JOIN city concty on concty.cty_code = concmp.cmp_city	
	INNER JOIN CHARgetype cht on ivd.cht_itemcode = cht.cht_itemcode
	LEFT JOIN orderheader ord on ivh.ord_hdrnumber = ord.ord_hdrnumber  
	LEFT JOIN invoiceSELECTion ivs on ivs.ivs_number = @ivs_number         
WHERE 
	((
	UPPER(@reprINTflag) <> 'REPRINT' AND 
	ivh.ivh_billto = @ivh_billto and
    ( ivh.ivh_shipdate between @shipstart AND @shipEND) AND
    ( ivh.ivh_deliverydate between @delstart AND @delEND ) AND
    ivh.ivh_mbstatus = 'RTP' and 
    @ivh_invoicenumber IN (ivh.ivh_invoicenumber, 'Master')	AND -- extra line FROM template
	(@ivh_revtype1 in (ivh.ivh_revtype1,'UNK')) AND
	(@ivh_revtype2 in (ivh.ivh_revtype2,'UNK')) AND
	(@ivh_revtype3 in (ivh.ivh_revtype3,'UNK')) AND
	(@ivh_revtype4 in (ivh.ivh_revtype4,'UNK')) AND
	(@shipcmpid IN (ivh.ivh_shipper,'UNKNOWN')) AND
	(@conscmpid IN (ivh.ivh_consignee,'UNKNOWN')) AND
	ivd_CHARge <> 0 AND
	(cht.cht_primary = 'Y' or ISNULL(cht.cht_rollINTOlh,0) = 0)   
	)

	or
	( 
	UPPER(@reprINTflag) = 'REPRINT' AND
	( ivh.ivh_mbnumber = @mbnumber ) AND
	ivd_CHARge <> 0 AND
	( cht.cht_primary = 'Y' or ISNULL(cht.cht_rollINTOlh,0) = 0)
	))

SET @ivh_hdrnumber = 0
--WHILE 1=1 BEGIN
WHILE (@mbnumber > 0 and UPPER(@reprINTflag) <> 'REPRINT') BEGIN
    SELECT @ivh_hdrnumber = MIN (ivh_hdrnumber) FROM #masterbill_temp WHERE ivh_hdrnumber > @ivh_hdrnumber            
    SET  @ivh_hdrnumber = ISNULL (@ivh_hdrnumber, 0)
    IF @ivh_hdrnumber > 0 
		BEGIN
			UPDATE invoiceheader SET ivh_mbnumber_custom = @mbnumber
			WHERE invoiceheader.ivh_hdrnumber = @ivh_hdrnumber
		END
    ELSE 
		BREAK
END

    
SELECT * 
FROM #masterbill_temp
ORDER BY [Invoice Header Shipper City], [ord_hdrnumber], ivd_sequence

GO
