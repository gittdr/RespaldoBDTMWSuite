SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_mb_footerimage13] 
	@remitname char(50),
	@remitaddr char(120),
	@termsstmnt char(120),
	@continued char(1),
	@pagenumber smallint
AS

--PTS 35444
DECLARE @procname varchar(128)
SELECT @procname = gi_string2 FROM generalinfo WHERE gi_name = 'SpoolFileImageName'
IF RTRIM(ISNULL(@procname,'')) > ''
BEGIN
	SELECT @procname = 'd_mb_footerimage_' + RTRIM(@procname)
	EXEC @procname @remitname, @remitaddr, @termsstmnt, @continued, @pagenumber
	RETURN
END

/* 
 create the information at the bottom of an masterbill.  Much of what is passed is not used,
 the arguments are the same as for the invoice documents.  returns only the terms and
 remit to name and address
         MODIFICATION LOG
  
 created 2/12/01 DPETE for Cowan transportation

*/  

DECLARE @remitline1 char(50),
	@remitline2 char(50),
	@remitline3 char(50),
	@remitline4 char(50),
	@termsline1 char(50),
	@termsline2 char(50),
	@termsline3 char(50),
	@termsline4 char(50),
	@continuedtext char(9),
	@ret int,
	@line varchar(250)
                    


IF ISNULL(@continued,'N') = 'Y' SELECT @continuedtext = 'CONTINUED'
ELSE SELECT @continuedtext = '         '





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
   image varchar(250),linenbr int
)

  INSERT INTO #image
	SELECT 
	'065' +
	@remitname + 
	@termsline1 +
	REPLICATE(' ',75), 65

  
  INSERT INTO #image
	SELECT 
	'066' +
	@remitline1 + 
	@termsline2 +
	REPLICATE(' ',75),66

  INSERT INTO #image
	SELECT 
	'067' +
	@remitline2 + 
	@termsline3 +
	REPLICATE(' ',75),67

    INSERT INTO #image
	SELECT 
	'068' +
	@remitline3 + 
	@termsline4 +
	REPLICATE(' ',75),68

   INSERT INTO #image
	SELECT 
	'069' +
	REPLICATE(' ',50) + 
	@termsline4 +
	REPLICATE(' ',75),69

  
/* this line is modified by the code to add CONTINUED and page number */
  INSERT INTO #image
	SELECT 
	'070' +
	@continuedtext +
	' PAGE '+
	CONVERT(varchar(5),@pagenumber),70

 SELECT  image from #image order by linenbr

GO
GRANT EXECUTE ON  [dbo].[d_mb_footerimage13] TO [public]
GO
