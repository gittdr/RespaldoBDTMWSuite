SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_mcclatchy_billoflading](@ordnum int)
AS

DECLARE @ord_hdrnumber int,
        @showshipper varchar(8), 
        @shipper_id varchar(8), 
        @consignee_id varchar(8),
        @showconsignee varchar(8), 
        @consignee_directions1 varchar(254),
        @consignee_directions2 varchar(254)

CREATE TABLE #bol (
	sr varchar(12) NULL,
	shipper_id varchar(8) NULL,
	shipper_name varchar(100) NULL ,
	shipper_addr1 varchar(100) NULL,
	shipper_cty_nmstct varchar(100) NULL,
	consignee_id varchar(8) NULL,
	consignee_name varchar(100) NULL,
	consignee_addr1  varchar(100) NULL,
	consignee_cty_nmstct varchar(100) NULL,
	billto_id varchar(8) NULL,
	billto_name varchar(100) NULL,
	billto_addr1  varchar(100) NULL,
	billto_cty_nmstct varchar(100) NULL,
	billto_cty_zip varchar(10) NULL,
	ord_hdrnumber INT NULL,
	ord_contact varchar(30) NULL,
	consignee_directions1 varchar(254) NULL,
	consignee_directions2 varchar(254) NULL,
	commodity_count int NULL,
	commodity_countunit varchar(10) NULL,
	commodity_description varchar(60) NULL,
	delivery_instructions varchar(100) NULL,
	ord_ref_number1 varchar(30) NULL,
	ord_ref_number2 varchar(30) NULL,
	ord_dest_latestdate datetime NULL,
	ord_availabledate datetime NULL, 
	ord_remarks	varchar(254) NULL
)

INSERT INTO  #bol 
SELECT	ORD.ord_number, 
		ORD.ord_originpoint, 
		shipper.cmp_name, 
		shipper.cmp_address1, 
		shipper_cty.cty_nmstct, 
		ORD.ord_destpoint, 
		consignee.cmp_name AS consignee_name, 
		consignee.cmp_address1 AS consignee_addr1, 
		consignee.cty_nmstct AS consignee_cty_nmstct, 
		ORD.ord_billto, 
		billto.cmp_name AS billto_name, 
		billto.cmp_address1 AS billto_addr1, 
		billto.cty_nmstct AS billto_cty_nmstct, 
		billto.cmp_zip, 
		ORD.ord_hdrnumber, 
		ORD.ord_contact, 
		NULL AS consignee_directions1, 
		NULL AS consignee_directions2, 
		FGT.fgt_count, 
		FGT.fgt_countunit,
		FGT.fgt_description, 
		STP.stp_comment, 
		NULL AS ord_ref_number1, 
		NULL AS ord_ref_number2, 
		STP.stp_schdtlatest, 
		ORD.ord_availabledate, 
		ORD.ord_remark
FROM	stops STP INNER JOIN
		orderheader ORD ON STP.ord_hdrnumber = ORD.ord_hdrnumber INNER JOIN
		freightdetail FGT ON STP.stp_number = FGT.stp_number LEFT OUTER JOIN
		company shipper ON ORD.ord_shipper = shipper.cmp_id LEFT OUTER JOIN
		company consignee ON ORD.ord_consignee = consignee.cmp_id LEFT OUTER JOIN
		company billto ON ORD.ord_billto = billto.cmp_id LEFT OUTER JOIN
		city consignee_cty ON ORD.ord_destcity = consignee_cty.cty_code LEFT OUTER JOIN
		city shipper_cty ON ORD.ord_origincity = shipper_cty.cty_code
WHERE	(ORD.ord_hdrnumber = @ORDNUM) AND 
		(STP.stp_event = 'LUL') 


--Display Show Shipper/Consignee if applicable
SELECT	@ord_hdrnumber = ord_hdrnumber,
		@shipper_id = shipper_id,
		@consignee_id = consignee_id
FROM	#bol

SELECT	@showshipper   = ord_showshipper,
		@showconsignee = ord_showcons
FROM	orderheader
WHERE	ord_hdrnumber = @ord_hdrnumber

IF (@shipper_id <> @showshipper) and (@showshipper <> 'UNKNOWN') BEGIN
	UPDATE	#bol
	SET		#bol.shipper_id = @showshipper,
			#bol.shipper_name = shipper.cmp_name,
			#bol.shipper_addr1 = shipper.cmp_address1,
			#bol.shipper_cty_nmstct = shipper.cty_nmstct
	FROM	company shipper INNER JOIN
			city shipper_cty ON shipper.cmp_city = shipper_cty.cty_code 
	WHERE	@showshipper = shipper.cmp_id and
            #bol.sr = @ord_hdrnumber  
END

IF (@consignee_id <> @showconsignee) and (@showconsignee <> 'UNKNOWN') BEGIN
	UPDATE	#bol
	SET		#bol.consignee_id = @showconsignee,
			#bol.consignee_name = consignee.cmp_name,
			#bol.consignee_addr1 = consignee.cmp_address1,
			#bol.consignee_cty_nmstct = consignee.cty_nmstct
	FROM	company consignee INNER JOIN
			city consignee_cty ON consignee.cmp_city = consignee_cty.cty_code 
	WHERE	@showconsignee = consignee.cmp_id and
			#bol.sr = @ord_hdrnumber	
END


--Get directions from Consignee
SELECT	@consignee_id = consignee_id
FROM	#bol

SELECT	@consignee_directions1 = ISNULL(cmp_misc1, ''), @consignee_directions2 = ISNULL(' ' + cmp_misc2, '')
FROM	company
WHERE	cmp_id = @consignee_id

IF (@consignee_directions1 = '' and @consignee_directions2 = '') BEGIN
	SELECT	@consignee_directions1 = substring(cmp_directions, 1, 254), @consignee_directions2 = substring(cmp_directions, 255, 254)
	FROM	company
	WHERE	cmp_id = @consignee_id
END

UPDATE	#bol
SET		consignee_directions1 = @consignee_directions1,
		consignee_directions2 = @consignee_directions2


--Get Reference numbers
UPDATE	#bol
SET		ord_ref_number1 = referencenumber.ref_number
FROM	referencenumber
WHERE	referencenumber.ord_hdrnumber = @ordnum and
		referencenumber.ref_sequence = 1 and
		referencenumber.ref_table = 'orderheader'      
       
UPDATE	#bol
SET		ord_ref_number2 = referencenumber.ref_number
FROM	referencenumber
WHERE	referencenumber.ord_hdrnumber = @ordnum and
		referencenumber.ref_sequence = 2 and
		referencenumber.ref_table = 'orderheader'      

--12/12/05 PTS 30089 JJF - explicit resultset
SELECT 	sr, 
	shipper_id, 
	shipper_name, 
	shipper_addr1,
	shipper_cty_nmstct, 
	consignee_id, 
	consignee_name, 
	consignee_addr1,
	consignee_cty_nmstct, 
	billto_id, 
	billto_name,
	billto_addr1, 
	billto_cty_nmstct,
	billto_cty_zip, 
	ord_hdrnumber, 
	ord_contact,
	consignee_directions1,
	consignee_directions2,
	commodity_count, 
	commodity_countunit, 
	commodity_description,
	delivery_instructions,
	ord_ref_number1, 
	ord_ref_number2,
	ord_dest_latestdate,
	ord_availabledate,
	ord_remarks
 FROM #bol
GO
GRANT EXECUTE ON  [dbo].[d_mcclatchy_billoflading] TO [public]
GO
