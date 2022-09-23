SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_inv_hdrimage12] 
	@inv varchar(12),
	@logoname varchar(50),
	@logoaddr varchar(120),
	@copies smallint,
	@remitname varchar(50),
	@remitaddr varchar(120),
	@termsstmnt varchar(120),
	@EDICode int
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
	SELECT @procname = 'd_inv_hdrimage_' + RTRIM(@procname)
	EXEC @procname @inv, @logoname, @logoaddr, @copies, @remitname, @remitaddr, @termsstmnt, @EDICode
	RETURN
END


/* 
  money fields convert right adjusted with convert(char(nn),moneyfield)
  varchar                                  convert(char(nn),varchar)
  float,int                                replicate(' ',nn - datalength(...)+CONVER..

  MODIFICATION LOG

PTS10952 dpete 6/1/501 use company zip instead of city
PTS 11842 pass EDI indicator to bypas printing on image system

*/  

DECLARE @invoicenumber char(12),
	@ordhdrnumber int,
	@ivhhdrnumber int,
	@billtoid char(8),
	@billtocompany char(30),
	@billtoaddr1 char(30),
	@billtoaddr2 char(30),  
	@billtoctstzp char(40),
	@btcmpmisc1 char(30), 
	@btcmpmisc2 char(30), 
	@btcmpmisc3 char(30), 
	@btcmpmisc4 char(30),
	@shipID varchar(8),  
	@shipcompany char(30),
	@shipaddr1 char(30),
	@shipaddr2 char(30),  
	@shipctstzp char(40),
	@consid varchar(8), 
	@conscompany char(30),
	@consaddr1 char(30),
	@consaddr2 char(30),  
	@consctstzp char(40), 
	@billdate char(8),
	@shipdate char(8),
	@deliverdate char(8),
	@tractor char(8),
	@trailer char(8),
	@driver char(8),
	@revtype1 char(6),
	@revtype2 char(6),
	@revtype3 char(6),
	@revtype4 char(6),
	@commodity char(25),
	@refnbr1 char(22),
	@refnbr2 char(22),
	@refnbr3 char(22),
	@refnbr4 char(22),
	@tariffitem char(12),
	@tariffnumber char(12),
	@terms char(15),
	@line varchar(254),
	@logoaddrline1 char(50),
	@logoaddrline2 char(50),
	@logoaddrline3 char(50),
	@logoaddrline4 char(50),
	@ret int,
	@ivhuser1 char(8),
	@EDIMsg char (3),
	@ord_number char(12) -- RE - 10/04/01 - PTS 11541

SELECT @EDIMsg =
	CASE ISNULL(@EDICode,0)
		WHEN 0 THEN '   '
		ELSE 'EDI'
   END
                    
 /* get invoice information */

 SELECT 
@invoicenumber = CONVERT(char(12),ivh_invoicenumber)  ,
@ivhhdrnumber = ivh_hdrnumber,
@ordhdrnumber = ISNULL(ord_hdrnumber,0),
@billtoid = ISNULL(ivh_billto,'UNKNOWN'),
@shipid = ISNULL(ivh_shipper,'UNKNOWN '),
@consid = ISNULL(ivh_consignee,'UNKNOWN'),
@billdate = ISNULL(CONVERT(char(8),ivh_billdate,1),'19500101') ,
@shipdate = ISNULL(CONVERT(char(8),ivh_shipdate,1) ,'19500101') ,
@deliverdate = ISNULL(CONVERT(char(8),ivh_deliverydate,1) ,'19500101') ,
@tractor = CONVERT(char(8),ISNULL(ivh_tractor,' ')) ,
@trailer = CONVERT(char(8),ISNULL(ivh_trailer,' ')) ,
@driver = CONVERT(char(8),ISNULL(ivh_driver,' ')) ,
@revtype1 = CONVERT(char(8),ISNULL(ivh_revtype1,'UNK')) ,
@revtype2 = CONVERT(char(8),ISNULL(ivh_revtype2,'UNK')) ,
@revtype3 = CONVERT(char(8),ISNULL(ivh_revtype3,'UNK')) ,
@revtype4 = CONVERT(char(8),ISNULL(ivh_revtype4,'UNK')) ,
@tariffnumber = CONVERT(char(12),tar_tarriffnumber) ,
@tariffitem = CONVERT (char(12),tar_tariffitem),
@terms = CONVERT(char(15),
  CASE ivh_terms
    WHEN 'PPD' Then 'Prepaid'
    WHEN 'COL' THen 'Collect'
    WHEN '3RD' Then '3rd Party'
    ELSE ' '
  END),
@ivhuser1= CONVERT(char(8),ISNULL(ivh_user_id1,' ')),
@ord_number = ord_number -- RE - 10/04/01 - PTS 11541
FROM invoiceheader WHERE ivh_invoicenumber = @inv

SELECT 
@billtocompany = CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_name,' '),1,30)) ,
@billtoaddr1 = CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_address1,' '),1,30)) ,
@billtoaddr2 = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(bc.cmp_address2,''))) > 0 THEN
		CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_address2,' '),1,30)) 
		WHEN LEN(RTRIM(ISNULL(bc.cmp_address2,''))) = 0 THEN
		CONVERT(char(30),SUBSTRING(
		ISNULL(bcc.cty_name,' ') + ', '+ISNULL(bcc.cty_state,' ')+' '+ISNULL(bc.cmp_zip,' '),    --ISNULL(bcc.cty_zip,' ')
		1,30))
	END,
@billtoctstzp = 
	CASE
		WHEN LEN(RTRIM(ISNULL(bc.cmp_address2,''))) > 0 THEN 
		CONVERT(char(30),SUBSTRING(
   		ISNULL(bcc.cty_name,' ') + ', '+ISNULL(bcc.cty_state,' ')+' '+ISNULL(bc.cmp_zip,' '),    --ISNULL(bcc.cty_zip,' ')
   		1,30))
		ELSE REPLICATE(' ',30)
	END,
@btcmpmisc1 = CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_misc1,' '),1,30)),
@btcmpmisc2 = CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_misc2,' '),1,30)),
@btcmpmisc3 = CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_misc3,' '),1,30)),
@btcmpmisc4 = CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_misc4,' '),1,30))
FROM company bc LEFT OUTER JOIN city bcc ON bcc.cty_code = bc.cmp_city
WHERE bc.cmp_id = @billtoid
--AND bcc.cty_code =* bc.cmp_city


SELECT
@shipcompany = CONVERT(char(30),SUBSTRING(ISNULL(sc.cmp_name,' '),1,30)) ,
@shipaddr1 = CONVERT(char(30),SUBSTRING(ISNULL(sc.cmp_address1,' '),1,30)) ,
@shipaddr2 = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(sc.cmp_address2,''))) > 0 THEN
		CONVERT(char(30),SUBSTRING(ISNULL(sc.cmp_address2,' '),1,30)) 
		WHEN LEN(RTRIM(ISNULL(sc.cmp_address2,''))) = 0 THEN
		CONVERT(char(30),SUBSTRING(
		ISNULL(scc.cty_name,' ') + ', '+ISNULL(scc.cty_state,' ')+' '+ISNULL(sc.cmp_zip,' ') ,   --ISNULL(scc.cty_zip,' ')
		1,30))
	END,
@shipctstzp = 
	CASE
		WHEN LEN(RTRIM(ISNULL(sc.cmp_address2,''))) > 0 THEN 
		CONVERT(char(30),SUBSTRING(
   		ISNULL(scc.cty_name,' ') + ', '+ISNULL(scc.cty_state,' ')+' '+ISNULL(sc.cmp_zip,' '),    --ISNULL(scc.cty_zip,' ')  ,
   		1,30))
		ELSE REPLICATE(' ',30)
	END
FROM company sc LEFT OUTER JOIN city scc ON scc.cty_code = sc.cmp_city
WHERE sc.cmp_id = @shipid
--AND scc.cty_code =* sc.cmp_city

SELECT
@conscompany = CONVERT(char(30),SUBSTRING(ISNULL(cc.cmp_name,' '),1,30)) ,
@consaddr1 = CONVERT(char(30),SUBSTRING(ISNULL(cc.cmp_address1,' '),1,30)) ,
@consaddr2 = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cc.cmp_address2,''))) > 0 THEN
		CONVERT(char(30),SUBSTRING(ISNULL(cc.cmp_address2,' '),1,30)) 
		WHEN LEN(RTRIM(ISNULL(cc.cmp_address2,''))) = 0 THEN
		CONVERT(char(30),SUBSTRING(
		ISNULL(ccc.cty_name,' ') + ', '+ISNULL(ccc.cty_state,' ')+' '+ISNULL(cc.cmp_zip,' ')   ,                --ISNULL(ccc.cty_zip,' ')   ,
		1,30))
	END,
@consctstzp = 
	CASE
		WHEN LEN(RTRIM(ISNULL(cc.cmp_address2,''))) > 0 THEN 
		CONVERT(char(30),SUBSTRING(
   		ISNULL(ccc.cty_name,' ') + ', '+ISNULL(ccc.cty_state,' ')+' '+ISNULL(cc.cmp_zip,' ')   ,                --ISNULL(ccc.cty_zip,' ')   ,
   		1,30))
		ELSE REPLICATE(' ',30)
	END
FROM company cc LEFT OUTER JOIN city ccc ON ccc.cty_code = cc.cmp_city
WHERE cc.cmp_id = @consid
--AND ccc.cty_code =* cc.cmp_city

/* get order information */
IF @ordhdrnumber > 0 
  BEGIN

    SELECT 
	@commodity = CONVERT(char(25),SUBSTRING(ISNULL(ord_description,' '),1,25)) 
    FROM orderheader where ord_hdrnumber = @ordhdrnumber
  

    SELECT 
	@refnbr1 = CONVERT(char(22),SUBSTRING(MAX(ISNULL(ref_type,''))+'  '+MAX(ISNULL(ref_number,' ')),1,22)) 
    FROM referencenumber
    WHERE ref_table = 'orderheader'
    AND ref_tablekey = @ordhdrnumber
    AND ref_sequence = 1

    IF @refnbr1  is NULL SELECT @refnbr1  = REPLICATE(' ',22)


   SELECT 
	@refnbr2 = CONVERT(char(22),SUBSTRING(MAX(ISNULL(ref_type,''))+'  '+MAX(ISNULL(ref_number,' ')),1,22)) 
    FROM referencenumber
    WHERE ref_table = 'orderheader'
    AND ref_tablekey = @ordhdrnumber
    AND ref_sequence = 2

    IF @refnbr2  is NULL SELECT @refnbr2  = REPLICATE(' ',22)


   SELECT 
	@refnbr3 = CONVERT(char(22),SUBSTRING(MAX(ISNULL(ref_type,''))+'  '+MAX(ISNULL(ref_number,' ')),1,22)) 
    FROM referencenumber
    WHERE ref_table = 'orderheader'
    AND ref_tablekey = @ordhdrnumber
    AND ref_sequence = 3

    IF @refnbr3  is NULL SELECT @refnbr3  = REPLICATE(' ',22)


    SELECT 
	@refnbr4 = CONVERT(char(22),SUBSTRING(MAX(ISNULL(ref_type,''))+'  '+MAX(ISNULL(ref_number,' ')),1,22)) 
    FROM referencenumber
    WHERE ref_table = 'orderheader'
    AND ref_tablekey = @ordhdrnumber
    AND ref_sequence = 4

    IF @refnbr4  is NULL SELECT @refnbr4  = REPLICATE(' ',22)

  END
ELSE
/*   get misc invoice information */
  BEGIN
    SELECT @commodity = REPLICATE(' ',25)

    SELECT 
	@refnbr1 = CONVERT(char(22),SUBSTRING(MAX(ISNULL(ref_type,''))+'  '+MAX(ISNULL(ref_number,' ')),1,22)) 
    FROM referencenumber
    WHERE ref_table = 'invoiceheader'
    AND ref_tablekey = @ivhhdrnumber
    AND ref_sequence = 1

    IF @refnbr1  is NULL SELECT @refnbr1  = REPLICATE(' ',22)


    SELECT 
	@refnbr2 = CONVERT(char(22),SUBSTRING(MAX(ISNULL(ref_type,''))+'  '+MAX(ISNULL(ref_number,' ')),1,22)) 
    FROM referencenumber
    WHERE ref_table = 'invoiceheader'
    AND ref_tablekey = @ivhhdrnumber
    AND ref_sequence = 2

    IF @refnbr2  is NULL SELECT @refnbr2  = REPLICATE(' ',22)


    SELECT 
	@refnbr3 = CONVERT(char(22),SUBSTRING(MAX(ISNULL(ref_type,''))+'  '+MAX(ISNULL(ref_number,' ')),1,22)) 
    FROM referencenumber
    WHERE ref_table = 'invoiceheader'
    AND ref_tablekey = @ivhhdrnumber
    AND ref_sequence = 3

    IF @refnbr3  is NULL SELECT @refnbr3  = REPLICATE(' ',22)


    SELECT 
	@refnbr4 = CONVERT(char(22),SUBSTRING(MAX(ISNULL(ref_type,''))+'  '+MAX(ISNULL(ref_number,' ')),1,22)) 
    FROM referencenumber
    WHERE ref_table = 'invoiceheader'
    AND ref_tablekey = @ivhhdrnumber
    AND ref_sequence = 4

    IF @refnbr4  is NULL SELECT @refnbr4  = REPLICATE(' ',22)

   
  END 

/* parse logo address */
  EXEC @ret = parse_multiline @logoaddr output,  @line output

  SELECT @logoaddrline1 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))

 IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @logoaddr output, @line output
      SELECT @logoaddrline2 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @logoaddrline2 = REPLICATE(' ',50)

  IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @logoaddr output, @line output
      SELECT @logoaddrline3 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @logoaddrline3 = REPLICATE(' ',50)
 
  IF @ret > 0 
    BEGIN
      EXEC @ret = parse_multiline @logoaddr output, @line output
      SELECT @logoaddrline4 = SUBSTRING(@line,1,50) + REPLICATE(' ',50 - DATALENGTH(SUBSTRING(@line,1,50)))
    END  
  ELSE SELECT @logoaddrline4 = REPLICATE(' ',50)



 /*  now build the output records */
 /*  assumes 110 character wide display, 30 characters of buffer, and 30 of misc data */

 
CREATE TABLE #image (
   image varchar(250), linenbr int
)

  INSERT INTO #image
	SELECT 
	'001' +
	REPLICATE(' ',2) +
	@logoname  +
	REPLICATE (' ',58) +
	REPLICATE (' ',30) +
	'BT= ' + @billtoid +
	REPLICATE (' ',2) +
	'COPIES=' +CONVERT(char(2),@copies) + 
	REPLICATE (' ',2) +
	@EDIMsg,
	1  
  
  INSERT INTO #image
	SELECT   
	'002' +
	REPLICATE(' ',2) +
	@logoaddrline1 +
	REPLICATE(' ',58) +
	REPLICATE (' ',30) +
	@btcmpmisc1,
	2 

  INSERT INTO #image
	SELECT 
	'003' +
	REPLICATE(' ',2) +
	@logoaddrline2 +
	REPLICATE(' ',58) +
	REPLICATE (' ',30) +
	@btcmpmisc2,
	3 

  
  INSERT INTO #image
	SELECT  
	'004' +
	REPLICATE(' ',2) +
	@logoaddrline3 +
	REPLICATE(' ',58) +
	REPLICATE (' ',30) +
	@btcmpmisc3 ,
	4

  
  INSERT INTO #image
	SELECT 
	'005' +
	REPLICATE(' ',2) + 
	@logoaddrline4 +
	REPLICATE(' ',28) +
	CONVERT(char(12) , @inv) +
	REPLICATE(' ',48) +
	REPLICATE(' ',30) +
	@ord_number + REPLICATE(' ', 12 - LEN(@ord_number)), -- RE - 10/04/01 - PTS 11541
	5

  INSERT INTO #image
	SELECT 
	'006' +
	REPLICATE(' ',140) + 
 	REPLICATE(' ',30) ,
	6 
  
  
  INSERT INTO #image
 	SELECT 
	'007' + 
	REPLICATE(' ',7) +
 	@shipcompany+' '+
	CONVERT(char(8),@shipid) + REPLICATE (' ',12) +
	@conscompany+' '+
	CONVERT(char(8),@consid) +
	REPLICATE(' ',13) +
	REPLICATE(' ',30) +
	REPLICATE(' ',30),
	7
	
  
  INSERT INTO #image
 	SELECT 
	'008' + 
	REPLICATE(' ',7) +
 	@shipaddr1+' '+
	REPLICATE (' ',20) +
	@consaddr1+' '+
	REPLICATE(' ',13) +
	REPLICATE(' ',38) +
	REPLICATE(' ',30),
	8
	
   
  
  INSERT INTO #image
 	SELECT 
	'009' + 
	REPLICATE(' ',7) +
 	@shipaddr2+' '+
	REPLICATE (' ',20) +
	@consaddr2+' '+
	REPLICATE(' ',13) +
	REPLICATE(' ',38) +
	REPLICATE(' ',30),
	9  
	 
  INSERT INTO #image
 	SELECT 
	'010' + 
	REPLICATE(' ',7) +
 	@shipctstzp+' '+
	REPLICATE (' ',10) +
	@consctstzp+' '+
	REPLICATE(' ',11) +
	REPLICATE(' ',30) +
	REPLICATE(' ',30),
	10  
	
  INSERT INTO #image
 	SELECT 
	'011' + 
	REPLICATE(' ',140) +
	REPLICATE(' ',30),
	11    
  
 
    
  INSERT INTO #image
 	SELECT 
	'012' + 
	REPLICATE(' ',3) +
	@billdate + REPLICATE(' ',3) +
	@shipdate + REPLICATE(' ',3) +
	@tractor  + REPLICATE(' ',2) +
	@trailer  + REPLICATE(' ',2) +
	@revtype4 + REPLICATE(' ',3) +
	@ivhuser1 + REPLICATE(' ',2) +
	@refnbr1  + @commodity +
	REPLICATE(' ',29) +
	REPLICATE(' ',30),
	12

  INSERT INTO #image
 	SELECT 
	'013' + 
	REPLICATE(' ',64) +
	@refnbr2  +
	REPLICATE(' ',54) +
	REPLICATE(' ',30) ,
	13

  
  INSERT INTO #image
 	SELECT
	'014' + 
	REPLICATE(' ',64) +
	@refnbr3  +
	REPLICATE(' ',54) +
	REPLICATE(' ',30) ,
	14

  
  INSERT INTO #image
 	SELECT 
	'015' +
	REPLICATE(' ',3) +
	@terms + 
	REPLICATE(' ',46) +
	@refnbr4  +
	@tariffitem + REPLICATE(' ',1) +
	@tariffnumber + 
	REPLICATE(' ',29) +
	REPLICATE(' ',30) ,
	15

  
  INSERT INTO #image
 	SELECT 
	'016' + 
	REPLICATE(' ',140) +
	REPLICATE(' ',30),
	16   
  
  
 
  
  
 
 SELECT  image from #image order by linenbr
GO
GRANT EXECUTE ON  [dbo].[d_inv_hdrimage12] TO [public]
GO
