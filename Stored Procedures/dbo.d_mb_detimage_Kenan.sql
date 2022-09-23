SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_mb_detimage_Kenan]  
	@billto varchar(8),
	@mbnumber int,
	@revtype1 varchar(6),
	@revtype2 varchar(6),
	@revtype3 varchar(6),
	@revtype4 varchar(6),
	@shipstart datetime,
	@shipend datetime,
	@delstart datetime,
	@delend datetime,
	@shipper varchar(8),
	@consignee varchar(8) 
	
	
AS
/*Version history

	20070412	TJB:KAG	Added support for stop cmp_id to display on stop row.
	20070725	FMM:TMW Rewrote freightdetail referencenumber routine
	20070827	FMM:TMW Disabled rounding of billing rates
	20070910	FMM:TMW Added Bill To ID to master bill details
	20110425    ERB:KAG Changed BOL query to use referencenumber directly instead of the denormalized values from freightdetail
	20111004	NQ :TMW	Added NOLOCK to avoid locking issue when doing SELECTs
*/

SET ANSI_WARNINGS OFF
SET NOCOUNT ON

  DECLARE @nextline smallint,
	@totalamt money,
	@totaldue varchar(12),
	@invoicenumber varchar(12),
 	@deliverydate  varchar(8),
 	@stpname varchar(20),
 	@description varchar(30),
 	@refnumber varchar(20),
	@quantity decimal(8,2),
 	@billquantity varchar(8),
 	@rate varchar(11),
 	@rateunit varchar(5),
 	@charge varchar(13),
	@stpcode varchar(8), --added 20070412
 	@stpcity int,
 	@cmp_id varchar(8),
 	@chargemoney money,
	@ivhhdrnumber int,
	@nextsequence varchar(14),
	@ord_number varchar(12),
	@ivdnumber int,
	@ivhrevtype1 varchar(30),
	@ivdsequence int,
	@tariffnumber varchar(12),
	@grandtotal money,
	@reprintflag char(1),
	@fgtnumber int,
	@ordhdrnumber int,
	@pbanumber varchar(12),
	@ratemoney money  --added 20070827

 DECLARE @image TABLE (
   [image] varchar(250), sequencecontrol varchar(25)
 )

 SELECT @invoicenumber = '', @nextline = 3, @grandtotal = 0, @reprintflag = 'N'
 IF @mbnumber > 0
 BEGIN
	IF (SELECT COUNT(1) FROM invoiceheader WHERE ivh_mbnumber = @mbnumber) > 0 SELECT @reprintflag = 'Y'
 END
 WHILE 1=1
 BEGIN
    IF @reprintflag = 'Y'
		SELECT @invoicenumber = MIN(ivh_invoicenumber) 
		  FROM invoiceheader WITH (NOLOCK)
		  JOIN invoicedetail ivd WITH (NOLOCK) ON (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		 WHERE invoiceheader.ivh_invoicenumber > @invoicenumber
		   AND invoiceheader.ivh_mbnumber = @mbnumber
		   AND (ivd.ivd_volume <> 0 OR ivd_quantity <> 0)
		   AND (ivh_totalcharge >= 0)
	ELSE
		SELECT @invoicenumber = MIN(ivh_invoicenumber) 
		  FROM invoiceheader WITH (NOLOCK)
		  JOIN invoicedetail ivd WITH (NOLOCK) ON (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		 WHERE invoiceheader.ivh_billto = @billto
		   AND invoiceheader.ivh_invoicenumber > @invoicenumber
		   AND invoiceheader.ivh_shipdate between @shipstart AND @shipend
		   AND invoiceheader.ivh_mbstatus = 'RTP'
		   AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK','ALL'))
     		   AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))
		   AND (@revtype3 in (invoiceheader.ivh_revtype3,'UNK'))
		   AND (@revtype4 in (invoiceheader.ivh_revtype4,'UNK'))
		   AND (ivd.ivd_volume <> 0 OR ivd_quantity <> 0)
		   AND (ivh_totalcharge >= 0)

	IF @invoicenumber IS NULL BREAK

	SELECT @ivhhdrnumber = ivh_hdrnumber, @ordhdrnumber = ord_hdrnumber
	  FROM invoiceheader
	 WHERE ivh_invoicenumber = @invoicenumber

	SELECT @ivhrevtype1 = isnull([name],'')
	  FROM labelfile
	 WHERE labeldefinition = 'RevType1'
 	   AND abbr = (SELECT ivh_revtype1 FROM invoiceheader WHERE ivh_invoicenumber = @invoicenumber)

	SELECT @pbanumber = ''
	IF @ordhdrnumber > 0
	BEGIN
		SELECT @pbanumber = MAX(ref_number)
		  FROM referencenumber
		 WHERE ref_table = 'orderheader' AND ref_tablekey = @ordhdrnumber AND ref_type = 'PBA'
		IF ISNULL(RTRIM(@pbanumber),'') = ''
			SELECT @pbanumber = ''
		ELSE
			SELECT @pbanumber = RTRIM(@pbanumber) + 'A'
	END

	INSERT INTO @image
	SELECT
		RIGHT('00000' + convert(varchar, @nextline), 5) + ',' +
		CONVERT(char(12), @ivhhdrnumber) + ',' +
		@invoicenumber + ',' +
		CONVERT(char(30), @ivhrevtype1) + 
	 	CONVERT(char(10), @invoicenumber) +
		CONVERT(char(20), @pbanumber) + ' ' +
		CONVERT(char(12), ivh_shipdate, 101) +
		CONVERT(char(30), ivh_originpoint) +
		CONVERT(char(30), ivh_destpoint), 
		convert(char(10), @invoicenumber) + right('     ' + convert(varchar, @nextline), 5)
	  FROM invoiceheader
	 WHERE ivh_invoicenumber = @invoicenumber
	SELECT @nextline = @nextline + 1

    --FMM 20070910, replace REPLICATE(' ', 73) with REPLICATE(' ', 31) + CONVERT(CHAR(42), @billto) below
	INSERT INTO @image
	SELECT
		RIGHT('00000' + convert(varchar, @nextline), 5) + ',' +
		CONVERT(char(12), @ivhhdrnumber) + ',' +
		@invoicenumber + ',' +
		REPLICATE(' ', 31) + 
		CONVERT(CHAR(42), @billto) + 
		CASE
			WHEN cmp3.cmp_id = 'UNKNOWN' THEN CONVERT(CHAR(30), 'UNKNOWN')
			WHEN cmp3.cmp_mailto_name IS NULL THEN 
				CONVERT(CHAR(30), ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),''))
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   		CONVERT(CHAR(30), ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),''))
			ELSE
				CONVERT(CHAR(30), ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),''))
	    	END +
		CASE
			WHEN CHARINDEX('/',cty2.cty_nmstct) > 1 THEN
				CONVERT(CHAR(30), ISNULL(SUBSTRING(cty2.cty_nmstct,1,(CHARINDEX('/',cty2.cty_nmstct)) - 1),''))
			ELSE
				CONVERT(CHAR(30), cty2.cty_nmstct) END,
		convert(char(10), @invoicenumber) + right('     ' + convert(varchar, @nextline), 5)
	  FROM invoiceheader
	 RIGHT OUTER JOIN company cmp3 ON (cmp3.cmp_id = invoiceheader.ivh_shipper)
	  JOIN city cty2 ON (cty2.cty_code = invoiceheader.ivh_destcity)
	 WHERE ivh_invoicenumber = @invoicenumber
	SELECT @nextline = @nextline + 1

	INSERT INTO @image
	SELECT
		RIGHT('00000' + convert(varchar, @nextline), 5) + ',' +
		CONVERT(char(12), @ivhhdrnumber) + ',' +
		@invoicenumber + ',     Stop At                    Description                     BOL            Quantity  Units        Rate      Charge', 
		convert(char(10), @invoicenumber) + right('     ' + convert(varchar, @nextline), 5)
	SELECT @nextline = @nextline + 1

	SELECT @ivdsequence = 0
	WHILE 1=1
	BEGIN
		SELECT @ivdsequence = MIN(ivd_sequence)
		  FROM invoiceheader WITH (NOLOCK)
		  JOIN invoicedetail ivd WITH (NOLOCK) ON (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		 WHERE invoiceheader.ivh_invoicenumber = @invoicenumber
		   AND ivd.ivd_sequence > @ivdsequence
		   AND (ivd.ivd_volume <> 0 OR ivd_quantity <> 0)
		IF @ivdsequence IS NULL BREAK

		SELECT @stpcode = stops.cmp_id, @stpcity = CASE WHEN ivd.ivd_type IS NULL THEN 0 ELSE ISNULL(stops.stp_city,0) END,
		       @description = CASE 
			WHEN cht.cht_primary = 'Y' AND ISNULL(cmd.cmd_name,'') = 'UNKNOWN' THEN 'Delivery Charge'
			WHEN cht.cht_primary = 'Y' THEN ISNULL(cmd.cmd_name,'')
			ELSE cht.cht_description END,
--		       @refnumber = CASE ISNULL(ivd.fgt_number,0)
--			WHEN 0 THEN '' ELSE ISNULL(f.fgt_refnum,'') END,
		       @tariffnumber = CASE ISNULL(invoiceheader.tar_tarriffnumber,'UNKNOWN')
			WHEN 'UNKNOWN' THEN '' ELSE ISNULL(invoiceheader.tar_tarriffnumber,'') END,
		       @quantity = CASE 
			WHEN ISNULL(ivd_wgt, 0) <> 0 THEN ivd_wgt
			WHEN ISNULL(ivd_volume, 0) <> 0 THEN ivd_volume
			WHEN ISNULL(ivd_count, 0) <> 0 THEN ivd_count
			ELSE ISNULL(ivd_quantity, 0) END,
		       @rateunit = CASE
			WHEN ISNULL(ivd_wgt, 0) <> 0 THEN ivd_wgtunit
			WHEN ISNULL(ivd_volume, 0) <> 0 THEN ivd_volunit
			WHEN ISNULL(ivd_count, 0) <> 0 THEN ivd_countunit
			ELSE ivd_unit END,
		       @ratemoney = ivd_rate,  --20070827
		       @chargemoney = ivd_charge,
			   @fgtnumber = ISNULL(ivd.fgt_number,0)
		  FROM invoiceheader WITH (NOLOCK)
		  JOIN invoicedetail ivd WITH (NOLOCK) ON (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		  JOIN chargetype cht WITH (NOLOCK) ON (ivd.cht_itemcode = cht.cht_itemcode)
	 	  LEFT OUTER JOIN commodity cmd WITH (NOLOCK) ON (ivd.cmd_code = cmd.cmd_code)
		  LEFT OUTER JOIN stops WITH (NOLOCK) ON  (ivd.stp_number = stops.stp_number)
--		  LEFT OUTER JOIN freightdetail f ON ivd.fgt_number = f.fgt_number
		 WHERE invoiceheader.ivh_invoicenumber = @invoicenumber
		   AND ivd.ivd_sequence = @ivdsequence
		   AND (ivd.ivd_volume <> 0 OR ivd_quantity <> 0)

		--FMM 7/25/2007 rewrote freightdetail referencenumber routine
		IF @fgtnumber > 0
		BEGIN
			EXEC denormalize_refnumbers 'freightdetail', @fgtnumber
			--20110425
			SELECT top 1 @refnumber = ISNULL(ref_number,'') FROM referencenumber WHERE ref_tablekey = @fgtnumber and ref_table = 'freightdetail' and ref_type = 'BL#'
			if @@rowcount != 1 select @refnumber = ISNULL(ref_number,'') FROM referencenumber WHERE ord_hdrnumber = @ordhdrnumber and ref_type = 'BL#'				
		END
		ELSE
			SELECT @refnumber = ''

		

		IF @stpcity > 0
			SELECT @stpname = @stpcode + '-' + ISNULL(SUBSTRING(cty_nmstct,1,(CHARINDEX('/',cty_nmstct)) - 1),'')
			  FROM city
			 WHERE cty_code = @stpcity
		ELSE
			SELECT @stpname = ''

		SELECT @billquantity = ''
		IF ABS(@quantity) >= 1000
			SELECT @billquantity = CONVERT(varchar, CAST(FLOOR((ABS(@quantity) / 1000)) AS INT)) + ','
		SELECT @billquantity = @billquantity + SUBSTRING(CONVERT(varchar, CAST(FLOOR(ABS(@quantity)) AS INT)), LEN(@billquantity), 10) + '.'
		IF @quantity < 0
			SELECT @billquantity = '-' + @billquantity, @quantity = ABS(@quantity)
		SELECT @billquantity = @billquantity + RIGHT('00' + CONVERT(varchar, CAST(CONVERT(DECIMAL(8,2), (@quantity - FLOOR(@quantity)) * 100) AS INT)), 2)

		--20070827 begin
		SELECT @rate = ''
		IF ABS(@ratemoney) >= 1000
			SELECT @rate = CONVERT(varchar, CAST(FLOOR((ABS(@ratemoney) / 1000)) AS INT)) + ','
		SELECT @rate = '$' + @rate + SUBSTRING(CONVERT(varchar, CAST(FLOOR(ABS(@ratemoney)) AS INT)), LEN(@rate), 10) + '.'
		IF @ratemoney < 0
			SELECT @rate = '-' + @rate, @ratemoney = ABS(@ratemoney)
		SELECT @rate = @rate + CASE
			WHEN CONVERT(DECIMAL(12, 4), @ratemoney * 100) - CONVERT(INT, @ratemoney * 100) = 0 THEN
				RIGHT('00' + CONVERT(varchar, CAST(CONVERT(DECIMAL(12,2), (@ratemoney - FLOOR(@ratemoney)) * 100) AS INT)), 2)
			WHEN CONVERT(DECIMAL(12, 4), @ratemoney * 1000) - CONVERT(INT, @ratemoney * 1000) = 0 THEN
				RIGHT('000' + CONVERT(varchar, CAST(CONVERT(DECIMAL(12,3), (@ratemoney - FLOOR(@ratemoney)) * 1000) AS INT)), 3)
			ELSE
				RIGHT('0000' + CONVERT(varchar, CAST(CONVERT(DECIMAL(12,4), (@ratemoney - FLOOR(@ratemoney)) * 10000) AS INT)), 4)
			END
		--20070827 end

		SELECT @charge = ''
		IF ABS(@chargemoney) >= 1000
			SELECT @charge = @charge + CONVERT(varchar, CAST(FLOOR((ABS(@chargemoney) / 1000)) AS INT)) + ','
		SELECT @charge = '$' + @charge + SUBSTRING(CONVERT(varchar, CAST(FLOOR(ABS(@chargemoney)) AS INT)), LEN(@charge), 10) + '.'
		IF @chargemoney < 0
		BEGIN
			SELECT @chargemoney = ABS(@chargemoney)
			SELECT @charge = '(' + @charge + RIGHT('00' + CONVERT(varchar, CAST(CONVERT(DECIMAL(8,2), (@chargemoney - FLOOR(@chargemoney)) * 100) AS INT)), 2) + ')'
		END
		ELSE
			SELECT @charge = @charge + RIGHT('00' + CONVERT(varchar, CAST(CONVERT(DECIMAL(8,2), (@chargemoney - FLOOR(@chargemoney)) * 100) AS INT)), 2)

		INSERT INTO @image
		SELECT
			RIGHT('00000' + convert(varchar, @nextline), 5) + ',' +
			CONVERT(char(12), @ivhhdrnumber) + ',' +
			@invoicenumber + ',     ' +
			CONVERT(char(27), @stpname) + 
			CONVERT(char(32), @description) + 
			CONVERT(char(14), @refnumber) +
			RIGHT(REPLICATE(' ',9) + @billquantity, 9) + '  ' +
			CONVERT(char(6), @rateunit) + 
			RIGHT(REPLICATE(' ', 11) + @rate, 11) +
			RIGHT(REPLICATE(' ', 12) + @charge, 12), 
			convert(char(10), @invoicenumber) + right('     ' + convert(varchar, @nextline), 5)
		SELECT @nextline = @nextline + 1
	END
	
	SELECT @totalamt = ivh_totalcharge
	  FROM invoiceheader
	 WHERE ivh_invoicenumber = @invoicenumber

	SELECT @grandtotal = @grandtotal + @totalamt

	SELECT @totaldue = ''
	IF ABS(@totalamt) >= 1000
		SELECT @totaldue = CONVERT(varchar, CAST(FLOOR((ABS(@totalamt) / 1000)) AS INT)) + ','
	SELECT @totaldue = '$' + @totaldue + SUBSTRING(CONVERT(varchar, CAST(FLOOR(ABS(@totalamt)) AS INT)), LEN(@totaldue), 10) + '.'
	IF @totalamt < 0
	BEGIN
		SELECT @totalamt = ABS(@totalamt)
		SELECT @totaldue = '(' + @totaldue + RIGHT('00' + CONVERT(varchar, CAST(CONVERT(DECIMAL(8,2), (@totalamt - FLOOR(@totalamt)) * 100) AS INT)), 2) + ')'
	END
	ELSE
		SELECT @totaldue = @totaldue + RIGHT('00' + CONVERT(varchar, CAST(CONVERT(DECIMAL(8,2), (@totalamt - FLOOR(@totalamt)) * 100) AS INT)), 2)
	
	INSERT INTO @image
	SELECT
		RIGHT('00000' + convert(varchar, @nextline), 5) + ',' +
		CONVERT(char(12), @ivhhdrnumber) + ',' +
		@invoicenumber + ',' +
		REPLICATE(' ',115) +
		'Invoice Subtotal:' +
		RIGHT(REPLICATE(' ', 12) + @totaldue, 12), 
		convert(char(10), @invoicenumber) + right('     ' + convert(varchar, @nextline), 5)
	SELECT @nextline = @nextline + 1

	INSERT INTO @image
	SELECT
		RIGHT('00000' + convert(varchar, @nextline), 5) + ',' +
		CONVERT(char(12), @ivhhdrnumber) + ',' +
		@invoicenumber + ',',
		convert(char(10), @invoicenumber) + right('     ' + convert(varchar, @nextline), 5)
	SELECT @nextline = @nextline + 1
 END
 
 SELECT @totaldue = ''
 IF ABS(@grandtotal) >= 1000
	SELECT @totaldue = CONVERT(varchar, CAST(FLOOR((ABS(@grandtotal) / 1000)) AS INT)) + ','
 SELECT @totaldue = '$' + @totaldue + SUBSTRING(CONVERT(varchar, CAST(FLOOR(ABS(@grandtotal)) AS INT)), LEN(@totaldue), 10) + '.'
 SELECT @totalamt = ABS(@grandtotal)
 IF @grandtotal < 0
	SELECT @totaldue = '(' + @totaldue + RIGHT('00' + CONVERT(varchar, CAST(CONVERT(DECIMAL(8,2), (@totalamt - FLOOR(@totalamt)) * 100) AS INT)), 2) + ')'
 ELSE
	SELECT @totaldue = @totaldue + RIGHT('00' + CONVERT(varchar, CAST(CONVERT(DECIMAL(8,2), (@totalamt - FLOOR(@totalamt)) * 100) AS INT)), 2)

 INSERT INTO @image
 SELECT
	RIGHT('00000' + convert(varchar, @nextline), 5) + ',            ,,' +
	REPLICATE(' ',129) + 'TOTAL:' +
	RIGHT(REPLICATE(' ', 12) + @totaldue, 12), 
	REPLICATE('Z',15)

SELECT [image] FROM @image WHERE (SELECT COUNT(*) FROM @image) > 1 ORDER BY sequencecontrol

GO
GRANT EXECUTE ON  [dbo].[d_mb_detimage_Kenan] TO [public]
GO
