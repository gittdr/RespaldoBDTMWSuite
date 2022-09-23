SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_inv_footerimage12] 
	@inv char(12),
	@remitname char(50),
	@remitaddr char(120),
	@termsstmnt char(120),
	@continued char(1),
	@pagenumber smallint
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

--PTS 35444
DECLARE @procname varchar(128)
SELECT @procname = gi_string1 FROM generalinfo WHERE gi_name = 'SpoolFileImageName'
IF RTRIM(ISNULL(@procname,'')) > ''
BEGIN
	SELECT @procname = 'd_inv_footerimage_' + RTRIM(@procname)
	EXEC @procname @inv, @remitname, @remitaddr, @termsstmnt, @continued, @pagenumber
	RETURN
END


/* 
 create the information at the bottom of an invoice.  Much of what is passed is not used,
 the arguments are the same as for the call to the hdr records (just to make it more
 straightforward) plus a page number

         MODIFICATION LOG
  
 created 1/30/01 DPETE for Cowan transportation
 PTS10505 4/9/1 dpete use cmp_mailto overrides as does the printed invoice BUT do not
           limit the override to invoices with a primary charge as does the print proc.

*/  

DECLARE @invoicenumber char(12),
	@billtoid varchar(8),
	@billtocompany char(30),
	@billtoaddr1 char(30),
	@billtoaddr2 char(30),  
	@billtoctstzp char(40),
	@remitline1 char(50),
	@remitline2 char(50),
	@remitline3 char(50),
	@remitline4 char(50),
	@termsline1 char(50),
	@termsline2 char(50),
	@termsline3 char(50),
	@termsline4 char(50),
	@continuedtext char(9),
	@ret int,
	@line varchar(250),
	@ivhterms   varchar(6)
                    
SELECT @billtoID = ivh_billto,
	@ivhterms = 
		CASE   
			WHEN  ivh_terms = 'UNK' THEN 'ANY'
			WHEN ivh_terms <> 'UNK' THEN ivh_terms
			ELSE 'ANY'
		END
FROM invoiceheader WHERE ivh_invoicenumber = @inv

IF ISNULL(@continued,'N') = 'Y' SELECT @continuedtext = 'CONTINUED'
ELSE SELECT @continuedtext = '         '

SELECT 
@billtoID = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  AND
			(@ivhterms in (ISNULL(cmp_mailto_crterm1,'ANY'),ISNULL(cmp_mailto_crterm2,'ANY'),ISNULL(cmp_mailto_crterm3,'ANY'))
			OR
			(ISNULL(cmp_mailto_crterm1,'ANY') = 'ANY' AND ISNULL(cmp_mailto_crterm2,'ANY') = 'ANY' and ISNULL(cmp_mailto_crterm3,'ANY')= 'ANY'))
		THEN ISNULL(cmp_altid,@billtoID)
		ELSE @billtoID
	END,
@billtocompany = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  AND
			(@ivhterms in (ISNULL(cmp_mailto_crterm1,'ANY'),ISNULL(cmp_mailto_crterm2,'ANY'),ISNULL(cmp_mailto_crterm3,'ANY'))
			OR
			(ISNULL(cmp_mailto_crterm1,'ANY') = 'ANY' AND ISNULL(cmp_mailto_crterm2,'ANY') = 'ANY' and ISNULL(cmp_mailto_crterm3,'ANY')= 'ANY'))
		THEN CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_mailto_name,' '),1,30)) 
		ELSE CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_name,' '),1,30)) 
	END,


@billtoaddr1 = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  AND
			(@ivhterms in (ISNULL(cmp_mailto_crterm1,'ANY'),ISNULL(cmp_mailto_crterm2,'ANY'),ISNULL(cmp_mailto_crterm3,'ANY'))
			OR
			(ISNULL(cmp_mailto_crterm1,'ANY') = 'ANY' AND ISNULL(cmp_mailto_crterm2,'ANY') = 'ANY' and ISNULL(cmp_mailto_crterm3,'ANY')= 'ANY'))
		THEN CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_mailto_address1,' '),1,30)) 
		ELSE CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_address1,' '),1,30))
	END ,
@billtoaddr2 = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  AND
			(@ivhterms in (ISNULL(cmp_mailto_crterm1,'ANY'),ISNULL(cmp_mailto_crterm2,'ANY'),ISNULL(cmp_mailto_crterm3,'ANY'))
			OR
			(ISNULL(cmp_mailto_crterm1,'ANY') = 'ANY' AND ISNULL(cmp_mailto_crterm2,'ANY') = 'ANY' and ISNULL(cmp_mailto_crterm3,'ANY')= 'ANY'))
		THEN CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_mailto_address2,' '),1,30))
		ELSE CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_address2,' '),1,30)) 
	END,
@billtoctstzp = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  AND
			(@ivhterms in (ISNULL(cmp_mailto_crterm1,'ANY'),ISNULL(cmp_mailto_crterm2,'ANY'),ISNULL(cmp_mailto_crterm3,'ANY'))
			OR
			(ISNULL(cmp_mailto_crterm1,'ANY') = 'ANY' AND ISNULL(cmp_mailto_crterm2,'ANY') = 'ANY' and ISNULL(cmp_mailto_crterm3,'ANY')= 'ANY'))
		THEN CONVERT(char(30),SUBSTRING(
		SUBSTRING(mailto_cty_nmstct,1,CHARINDEX('/',mailto_cty_nmstct) - 1)+' '+ISNULL(cmp_mailto_zip,''),
		1,30))
		ELSE CONVERT(char(30),SUBSTRING(
   		ISNULL(bcc.cty_name,' ') + ', '+ISNULL(bcc.cty_state,' ')+' '+ISNULL(bc.cmp_zip,' ')   ,
  		 1,30))
	END

FROM company bc LEFT OUTER JOIN city bcc ON bcc.cty_code = bc.cmp_city
WHERE bc.cmp_id = @billtoid
--AND bcc.cty_code =* bc.cmp_city


/* now parse the TERMS */
  EXEC @ret = parse_multiline @termsstmnt output, @line output
  SELECT @termsline1  = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
  IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @termsstmnt output, @line output
      SELECT @termsline2 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @termsline2 = REPLICATE(' ',50)
  IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @termsstmnt output, @line output
      SELECT @termsline3 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @termsline3 = REPLICATE(' ',50)
  IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @termsstmnt output, @line output
      SELECT @termsline4 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @termsline4 = REPLICATE(' ',50)

/* now parse the REMITTANCE ADDDRESS */
  EXEC @ret = parse_multiline @remitaddr output, @line output
  SELECT @remitline1  = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
  IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @remitaddr output, @line output
      SELECT @remitline2 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @remitline2 = REPLICATE(' ',50)
  IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @remitaddr output, @line output
      SELECT @remitline3 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @remitline3 = REPLICATE(' ',50)
  IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @remitaddr output, @line output
      SELECT @remitline4 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @remitline4 = REPLICATE(' ',50)

 /*  now build the output records */
 /*  assumes 110 character wide display, 30 characters of buffer, and 30 of misc data */

 
CREATE TABLE #image (
   image varchar(250), linenbr int
)

  INSERT INTO #image
	SELECT 
	'061' +
	REPLICATE(' ',75) +
	@termsline1,
	61

  
  INSERT INTO #image
	SELECT 
	'062' +
	REPLICATE(' ',75) +
	@termsline2,
	62
  
  
  INSERT INTO #image
	SELECT 
	'063' +
	REPLICATE(' ',75) +
	@termsline3,
	63

  
  INSERT INTO #image
	SELECT 
	'064' +
	REPLICATE(' ',75) +
	@termsline4,
	64

  
  INSERT INTO #image
	SELECT 
	'065' +
	@billtocompany +
	@billtoid + REPLICATE(' ',8 - LEN(@billtoID)) +
	REPLICATE (' ',10) +
	@remitname,
	65
   
  INSERT INTO #image
	SELECT 
	'066' +
	@billtoaddr1 +
	REPLICATE (' ',18) +
	@remitline1,
	66
 
    
  INSERT INTO #image
	SELECT 
	'067' +
	@billtoaddr2 +
	REPLICATE (' ',18) +
	@remitline2,
	67

    
  INSERT INTO #image
	SELECT 
	'068' +
	@billtoctstzp +
	REPLICATE (' ',18) +
	@remitline3,
	68

  INSERT INTO #image
	SELECT 
	'069'  +
	REPLICATE (' ',48) +
	@remitline4,
	69

  INSERT INTO #image
	SELECT 
	'070' +
	@continuedtext +
	' PAGE '+
	CONVERT(varchar(5),@pagenumber),
	70

 SELECT  image from #image ORDER BY linenbr
GO
GRANT EXECUTE ON  [dbo].[d_inv_footerimage12] TO [public]
GO
