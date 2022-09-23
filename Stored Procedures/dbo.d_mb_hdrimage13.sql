SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_mb_hdrimage13] 
	@billto varchar(8),
	@mbnumber int,
	@logoname varchar(50),
	@logoaddr varchar(120),
	@copies smallint,
	@remitname varchar(50),
	@remitaddr varchar(120),
	@termsstmnt varchar(120),
	@mbdate		varchar(10)
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
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

--PTS 35444
DECLARE @procname varchar(128)
SELECT @procname = gi_string2 FROM generalinfo WHERE gi_name = 'SpoolFileImageName'
IF RTRIM(ISNULL(@procname,'')) > ''
BEGIN
	SELECT @procname = 'd_mb_hdrimage_' + RTRIM(@procname)
	EXEC @procname @billto, @mbnumber, @logoname, @logoaddr, @copies, @remitname, @remitaddr, @termsstmnt, @mbdate
	RETURN
END

/* 
  money fields convert right adjusted with convert(char(nn),moneyfield)
  varchar                                  convert(char(nn),varchar)
  float,int                                replicate(' ',nn - datalength(...)+CONVER..

PTS 10198 add mb date to arg list and print; sequence records on final select
PTS10505 4/9/1 incorporate code to allow mail to override name, address and ID

*/  

DECLARE @billtoid varchar(8),
	@billtocompany char(30),
	@billtoaddr1 char(30),
	@billtoaddr2 char(30),  
	@billtoctstzp char(40),
	@btcmpmisc1 char(30), 
	@btcmpmisc2 char(30), 
	@btcmpmisc3 char(30), 
	@btcmpmisc4 char(30),
	@line varchar(254),
	@logoaddrline1 char(50),
	@logoaddrline2 char(50),
	@logoaddrline3 char(50),
	@logoaddrline4 char(50),
	@ret int
                    
 /* get billto information */
                    

SELECT 
@billtoID = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  
		THEN ISNULL(cmp_altid,@billto)
		ELSE @billto
	END,
@billtocompany = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  
		THEN CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_mailto_name,' '),1,30)) 
		ELSE CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_name,' '),1,30)) 
	END,


@billtoaddr1 = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  
		THEN CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_mailto_address1,' '),1,30)) 
		ELSE CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_address1,' '),1,30))
	END ,
@billtoaddr2 = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  
		THEN CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_mailto_address2,' '),1,30))
		ELSE CONVERT(char(30),SUBSTRING(ISNULL(bc.cmp_address2,' '),1,30)) 
	END,
@billtoctstzp = 
	CASE 
		WHEN LEN(RTRIM(ISNULL(cmp_mailto_name,''))) > 0  
		THEN CONVERT(char(40),SUBSTRING(
		SUBSTRING(mailto_cty_nmstct,1,CHARINDEX('/',mailto_cty_nmstct) - 1)+' '+ISNULL(cmp_mailto_zip,''),
		1,40))
		ELSE CONVERT(char(40),SUBSTRING(
   		ISNULL(bcc.cty_name,' ') + ', '+ISNULL(bcc.cty_state,' ')+' '+ISNULL(bc.cmp_zip,' ')   ,
  		 1,40))
	END

FROM company bc left outer join city bcc on bcc.cty_code = bc.cmp_city
WHERE bc.cmp_id = @billto
--AND bcc.cty_code =* bc.cmp_city



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
   image varchar(250),
   linenbr    int
)

  INSERT INTO #image
	SELECT 
	'001' +
	REPLICATE(' ',2) +
	@logoname  +
	REPLICATE (' ',58) +
	REPLICATE (' ',30) +
	'BT= ' + @billto +
	REPLICATE (' ',2) +
	'COPIES= ' +CONVERT(varchar(2),@copies) + 
	REPLICATE (' ',6) ,1 
  
  INSERT INTO #image
	SELECT   
	'002' +
	REPLICATE(' ',2) +
	@logoaddrline1 +
	REPLICATE(' ',58) +
	REPLICATE (' ',30) +
	@btcmpmisc1 ,2

  INSERT INTO #image
	SELECT 
	'003' +
	REPLICATE(' ',2) +
	@logoaddrline2 +
	REPLICATE(' ',58) +
	REPLICATE (' ',30) +
	@btcmpmisc2 ,3

  
  INSERT INTO #image
	SELECT  
	'004' +
	REPLICATE(' ',2) +
	@logoaddrline3 +
	REPLICATE(' ',58) +
	REPLICATE (' ',30) +
	@btcmpmisc3 ,4

  
  INSERT INTO #image
	SELECT 
	'005' +
	REPLICATE(' ',2) + 
	@logoaddrline4 +
	REPLICATE(' ',28) +
	CONVERT(varchar(12) , @mbnumber) + REPLICATE (' ',12 - LEN(CONVERT(varchar(12) , @mbnumber)))+
	REPLICATE(' ',48) +
	REPLICATE(' ',30),5

  INSERT INTO #image
	SELECT 
	'006' +
	REPLICATE(' ',80) + 
	@mbdate +
	REPLICATE(' ',52) + 
 	REPLICATE(' ',30) ,6 
  
INSERT INTO #image
	SELECT
	'007' +
	REPLICATE(' ',7)+
	CONVERT(CHAR(8),@billtoID) +
	REPLICATE(' ',120),7

INSERT INTO #image
	SELECT 
	'008' +
	REPLICATE(' ',140) + 
 	REPLICATE(' ',30) ,8 
  
  INSERT INTO #image
 	SELECT 
	'009' + 
	REPLICATE(' ',7) +
 	@billtocompany+' '+
	REPLICATE(' ',63) +
	REPLICATE(' ',30) +
	REPLICATE(' ',30),9
	
  
  INSERT INTO #image
 	SELECT 
	'010' + 
	REPLICATE(' ',7) +
 	@billtoaddr1+' '+
	REPLICATE(' ',120) ,10
	
   
  
  INSERT INTO #image
 	SELECT 
	'011' + 
	REPLICATE(' ',7) +
 	@billtoaddr2+' '+
	REPLICATE (' ',120),11 
	 
  INSERT INTO #image
 	SELECT 
	'012' + 
	REPLICATE(' ',7) +
 	@billtoctstzp+' '+
	REPLICATE (' ',120),12 
	
  INSERT INTO #image
 	SELECT 
	'013' + 
	REPLICATE(' ',140) +
	REPLICATE(' ',30) ,13

   INSERT INTO #image
 	SELECT 
	'014' + 
	REPLICATE(' ',140) +
	REPLICATE(' ',30),14       
  
 
    
  
  
 
  
  
 
 SELECT  image from #image order by linenbr
GO
GRANT EXECUTE ON  [dbo].[d_mb_hdrimage13] TO [public]
GO
