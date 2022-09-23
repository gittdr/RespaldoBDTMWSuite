SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_inv_detimage12] 
	@inv char(12),
	@startline int 
	
AS

DECLARE @procname varchar(128)
SELECT @procname = gi_string1 FROM generalinfo WHERE gi_name = 'SpoolFileImageName'
IF RTRIM(ISNULL(@procname,'')) > ''
BEGIN
	SELECT @procname = 'd_inv_detimage_' + RTRIM(@procname)
	EXEC @procname @inv, @startline
	RETURN
END

/* this procedure returns one page of an invoice (detail section ) arguments include the 
   invoice number and the detail item of the invoice to start with. The decimalson???
   dicatates how many decimal places to display on the designated field. It returns a line
   with zero (*00) in position 1 thru 3 if the
   entire invoice is printed, if there is more data to print it returns *nn where nn is the
   next line number

    MODIFICATION LOG

 created 1/25/01 DPETE for Cowan input to Pegasus
 modified 4/3/01 PTS 10437 DPETE When a supplementazl invoice is created with a primary charge, the line is not being
          generated.  

  PTS13652 write out pieces and weigh on seconaday charge lines

*/

DECLARE @minseq int, 
	@ivhhdrnumber int,
	@chtitemcode varchar(6),
	@cmddescription char(25),
	@ivdweight char(8),
	@ivdcount char(6),
	@billqty char(8),
	@cmpid varchar(8),
	@charge char(13),
	@rate char(9),
	@rateunit char(8),
	@chtrateunit varchar(6),
	@chtprimary char(1),
	@accdescription char(30),
	@ivdwgtunit varchar(6),
	@ivdcountunit varchar(6),
	@ivdtype varchar(6),
	@cmpname char(30),
	@cmploc char(30),
	@stpref1 char(14),
	@stpnumber int,
	@linecount smallint,
	@maxseq int,
	@nextline smallint,
	@totalcharge char(13),
	@totalweight char(8),
	@totalcount char(6),
	@weightunit varchar(6),
	@weightuofm char(8),
	@countunit varchar(6),
	@countuofm char(8),
	@remark   char(90)


SELECT @weightunit = REPLICATE(' ',8)
SELECT @countunit = REPLICATE (' ',8)
SELECT @ivhhdrnumber = ivh_hdrnumber FROM invoiceheader WHERE ivh_invoicenumber = @inv

IF @ivhhdrnumber IS NULL RETURN 

SELECT @minseq = ISNULL(@startline,1) - 1

SELECT @remark = CONVERT(char(90),SUBSTRING(ISNULL(ivh_remark,''),1,90))
FROM invoiceheader where ivh_invoicenumber = @inv 

SELECT @linecount = 0

CREATE TABLE #image (
   image varchar(250), linenbr int
)

/* loop thru invoicedetail */
SELECT @nextline = 17
WHILE 1 = 1
 BEGIN
  SELECT @minseq = MIN(ivd_sequence),
	@maxseq = MAX(ivd_sequence)
  FROM invoicedetail
  WHERE ivh_hdrnumber = @ivhhdrnumber
  AND ivd_sequence > @minseq

  IF @minseq IS NULL BREAK
  SELECT @weightuofm = REPLICATE(' ',8)
  SELECT @countuofm = REPLICATE(' ',8)
  SELECT 
	@chtitemcode = ISNULL(invoicedetail.cht_itemcode,'UNK'),
	@cmddescription = 
	  CASE ivd_description
		WHEN 'UNKNOWN' THen '        '
		ELSE ISNULL(ivd_description,'')
	  END,
	@ivdweight = 
	CASE 
	  WHEN ivd_wgt = 0 THEN REPLICATE (' ',8)
	  WHEN CONVERT(decimal(12,4),ISNULL(ivd_wgt,0) - convert(int,ISNULL(ivd_wgt,0)))  = 0
	  	 THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,0))))) +
		CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,0))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivd_wgt,0)*10) - convert(int,(ISNULL(ivd_wgt,0)*10)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,1))))) +
		CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,1))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivd_wgt,0)*100) - convert(int,(ISNULL(ivd_wgt,0)*100)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,2))))) +
		CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,2))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivd_wgt,0)*1000) - convert(int,(ISNULL(ivd_wgt,0)*1000)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,3))))) +
		CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,3))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivd_wgt,0)*10000) - convert(int,(ISNULL(ivd_wgt,0)*10000)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,4))))) +
		CONVERT(varchar(8),CAST(ivd_wgt AS dec(8,4))),'        ')
	  ELSE ' '
	END,
	@ivdcount = 
	CASE ivd_count
	  WHEN 0 THEN REPLICATE (' ',6)
          ELSE
	   REPLICATE(' ',6 - LEN(CONVERT(varchar(6),ISNULL(ivd_count,0))) ) + CONVERT(varchar(6),ISNULL(ivd_count,0))
	END,
	@cmpid = ISNULL(cmp_id,' '),
	@charge = CONVERT(char(13),ISNULL(ivd_charge,0)),
	@rate = 
	CASE 
	  WHEN CONVERT(decimal(13,4),(ISNULL(ivd_rate,0)*100) - convert(int,(ISNULL(ivd_rate,0)*100)))  = 0
		THEN ISNULL(REPLICATE (' ',9 - LEN(CONVERT(varchar(9),CAST(ivd_rate AS dec(9,2))))) +
		CONVERT(varchar(9),CAST(ivd_rate AS dec(9,2))),'        ')
	  ELSE
		ISNULL(REPLICATE (' ',9 - LEN(CONVERT(varchar(9),CAST(ISNULL(ivd_rate,0) AS dec(9,4))))) +
		CONVERT(varchar(9),CAST(ISNULL(ivd_rate,0) AS dec(9,4))),'        ')
	END,
	@chtrateunit = ISNULL(ivd_rateunit,''),
	@billqty = 
	CASE 
	  WHEN ivd_quantity = 0 THEN REPLICATE(' ',8)
	  WHEN CONVERT(decimal(12,4),ISNULL(ivd_quantity,0) - convert(int,ISNULL(ivd_quantity,0)))  = 0
	  	 THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,0))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,0))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivd_quantity,0)*10) - convert(int,(ISNULL(ivd_quantity,0)*10)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,1))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,1))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivd_quantity,0)*100) - convert(int,(ISNULL(ivd_quantity,0)*100)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,2))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,2))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivd_quantity,0)*1000) - convert(int,(ISNULL(ivd_quantity,0)*1000)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,3))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,3))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivd_quantity,0)*10000) - convert(int,(ISNULL(ivd_quantity,0)*10000)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,4))))) +
		CONVERT(varchar(8),CAST(ivd_quantity AS dec(8,4))),'        ')
	  ELSE ' '
	END,
	@chtprimary = ISNULL(cht_primary,'N'),
	@accdescription = ISNULL(CONVERT(char(30),cht_description),REPLICATE(' ',30)),
	@ivdwgtunit = 
	 CASE 
	   WHEN chargetype.cht_primary = 'Y' and ivd_type = 'DRP'  then ivd_wgtunit
	   ELSE ' '
	 END,
	@ivdcountunit = 
	 CASE 
	   WHEN chargetype.cht_primary = 'Y' and ivd_type = 'DRP' then ivd_countunit
	   ELSE ' '
	 END,
	@ivdtype = ivd_type,
	@stpnumber = ISNULL(stp_number,0),
	@weightunit = ISNULL(ivd_wgtunit,'UNK'),
        @countunit = ISNULL(ivd_countunit,'UNK')
  FROM invoicedetail, chargetype
  WHERE ivh_hdrnumber = @ivhhdrnumber
  AND ivd_sequence = @minseq
  AND chargetype.cht_itemcode = invoicedetail.cht_itemcode

  If  @weightunit IS NOT NULL and @weightunit <> 'UNK'
    BEGIN  
     SELECT @weightuofm = ISNULL(name,REPLICATE(' ',8)) 
	FROM labelfile WHERE labeldefinition = 'WeightUnits'
	AND abbr = @weightunit
    END
  SELECT @weightuofm = ISNULL(@weightuofm,REPLICATE(' ',8) )

  IF  @countunit IS NOT NULL and @countunit <> 'UNK'
    BEGIN  
     SELECT @countuofm = name 
	FROM labelfile WHERE labeldefinition = 'CountUnits'
	AND abbr = @countunit
    END
   SELECT @countuofm = ISNULL(@countuofm,REPLICATE(' ',8) )

 /*   ENtry for pickup or delivery   */
  IF @chtprimary = 'Y' and @ivdtype in ('PUP','DRP')
    BEGIN
	SELECT @cmpname = CONVERT(char(30),ISNULL(cmp_name,' ')),
		@cmploc = 
		CASE 
		  WHEN CHARINDEX('/',cty_nmstct,0)> 0 THEN CONVERT(char(30),SUBSTRING(cty_nmstct,1,CHARINDEX('/',cty_nmstct,0)))
		  WHEN LEN(cty_nmstct) > 0 THEN CONVERT(char(30),cty_nmstct)
		  ELSE REPLICATE (' ',30)
		END
	FROM company
	WHERE cmp_id = @cmpid
	
	SELECT @cmpname = ISNULL(@cmpname,REPLICATE (' ',30))

	SELECT @stpref1 = CONVERT(char(14), SUBSTRING(MIN(ref_type) + ' '+ MIN(ref_number),1,14))
	FROM referencenumber
	WHERE ref_table = 'stops'
	AND ref_tablekey = @stpnumber
	AND ref_sequence = 1

	SELECT @stpref1 = ISNULL(@stpref1,REPLICATE(' ',14))

	INSERT INTO #image
	SELECT 
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline)))+CONVERT(varchar(2),@nextline) +
	@cmpname + 
	@stpref1 +
	@ivdweight +
	@ivdcount +
	@billqty +
	REPLICATE(' ',29), @nextline


	INSERT INTO #image
	SELECT 
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline + 1)))+CONVERT(varchar(2),@nextline + 1) +
	@cmploc + 
	REPLICATE(' ',63) ,@nextline + 1
	
	INSERT INTO #image
	SELECT
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline + 2)))+CONVERT(varchar(2),@nextline + 2) +
	@cmddescription + 
	REPLICATE(' ',63),@nextline + 2

	INSERT INTO #image
	SELECT 
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline + 3)))+CONVERT(varchar(2),@nextline+ 3) +
	REPLICATE(' ',93),@nextline + 3

	
	SELECT @nextLine = @nextline + 4
	SELECT @linecount = @linecount + 4
	IF @linecount > 40 BREAK


    END
/* Entry for total charge line */
  ELSE 
    IF @chtprimary = 'Y' and @ivdtype = 'SUB'
    BEGIN
	
	SELECT @rateunit = CONVERT(char(8),SUBSTRING(name,1,8))
	FROM labelfile
	WHERE labeldefinition = 'RateBy'
	AND abbr = @chtrateunit

 	SELECT @rateunit = ISNULL(@rateunit,'        ')

	INSERT INTO #image
	SELECT 
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline)))+CONVERT(varchar(2),@nextline) +
	@accdescription + 
	REPLICATE(' ',28) +
	@billqty +
	@rate +
	@rateunit +
	@charge,@nextline

	INSERT INTO #image
	SELECT
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline + 1)))+CONVERT(varchar(2),@nextline + 1) + 
	replicate(' ',93),@nextline + 1

	SELECT @nextline = @nextline + 2
	SELECT @linecount = @linecount + 2
	IF @linecount > 40 BREAK
  END


 /*   Entry for secondary charge */
 /* IF @chtprimary = 'N' */
  ELSE
    BEGIN
	
	SELECT @rateunit = CONVERT(char(8),SUBSTRING(name,1,8))
	FROM labelfile
	WHERE labeldefinition = 'RateBy'
	AND abbr = @chtrateunit

 	SELECT @rateunit = ISNULL(@rateunit,'        ')

	INSERT INTO #image
	SELECT
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline + 1)))+CONVERT(varchar(2),@nextline + 1) +
	@accdescription +
	REPLICATE(' ',14) +
	@ivdweight +
	@ivdcount +
	@billqty +
	@rate +
	@rateunit +
	@charge,@nextline + 1

	INSERT INTO #image
	SELECT 
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline + 2)))+CONVERT(varchar(2),@nextline+ 2) +
	REPLICATE(' ',93),@nextline + 2

	SELECT @nextline = @nextline + 3
	SELECT @linecount = @linecount + 3
	IF @linecount > 40 BREAK

    END

    

  
 END
  /* if there are more invoice detail entries than can fit on one page, return the next seq */

 
	

 IF @minseq IS NULL 
  BEGIN
	

  /* invoice total line */
    SELECT @totalcharge =  CONVERT(char(13),ivh_totalcharge),
	@totalweight = 
	CASE 
	  WHEN ivh_totalweight = 0 THEN REPLICATE (' ',8)
	  WHEN CONVERT(decimal(12,4),ISNULL(ivh_totalweight,0) - convert(int,ISNULL(ivh_totalweight,0)))  = 0
	  	 THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,0))))) +
		CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,0))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivh_totalweight,0)*10) - convert(int,(ISNULL(ivh_totalweight,0)*10)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,1))))) +
		CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,1))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivh_totalweight,0)*100) - convert(int,(ISNULL(ivh_totalweight,0)*100)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,2))))) +
		CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,2))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivh_totalweight,0)*1000) - convert(int,(ISNULL(ivh_totalweight,0)*1000)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,3))))) +
		CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,3))),'        ')
	  WHEN CONVERT(decimal(12,4),(ISNULL(ivh_totalweight,0)*10000) - convert(int,(ISNULL(ivh_totalweight,0)*10000)))  = 0
		THEN ISNULL(REPLICATE (' ',8 - LEN(CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,4))))) +
		CONVERT(varchar(8),CAST(ivh_totalweight AS dec(8,4))),'        ')
	END,
	@totalcount = 
	CASE
	WHEN ivh_totalpieces = 0 THEN REPLICATE (' ',6)
	ELSE
	REPLICATE (' ',6 - LEN(CONVERT(varchar(6),ISNULL(ivh_totalpieces,0)))) +
		CONVERT(varchar(6),ISNULL(ivh_totalpieces,0))
	END
  FROM invoiceheader 
  WHERE ivh_invoicenumber = @inv


  INSERT INTO #image
	SELECT 
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline)))+CONVERT(varchar(2),@nextline) +
	'*TOTAL AMT DUE' +
	REPLICATE(' ',30) +
	@totalweight +
	@totalcount + 
	REPLICATE(' ',25) +
	@totalcharge,@nextline

  SELECT @nextline = @nextline + 1
  INSERT INTO #image
	SELECT 
	'0' + REPLICATE('0',2 - LEN(CONVERT(varchar(2),@nextline)))+CONVERT(varchar(2),@nextline) +
	@remark +
	REPLICATE(' ',30),@nextline 
 
  END

IF @minseq IS NOT NULL AND @minseq < @maxseq 
   BEGIN
	INSERT INTO #image
	SELECT
	'*' + REPLICATE ('0',3 - LEN(CONVERT(varchar(3),@minseq + 1))) + 
	CONVERT(varchar(3),@minseq + 1) +
	+REPLICATE(' ',93),@minseq + 1
   END
ELSE
  BEGIN
	INSERT INTO #image
	SELECT '*999'+REPLICATE(' ',93),999
  END


SELECT image from #image order by linenbr

GO
GRANT EXECUTE ON  [dbo].[d_inv_detimage12] TO [public]
GO
