SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* This proc will add a company.  If the @@cmp_id contains data, it will try to assign that
   company ID (if it is a duplicate an error return is made).  If no company Id is passed
   one will be assigned using the first 3 charactrs of the company name (eliminating spaces
   and other characters) plus the firs three characters of the city name  It that combo is not
   unique, it wall append numeric suffixes and checkfor a duplicate.

   If the city does not pass a call to _does_city_exist, this proc will add the city.
   If it cannot be added (see dx_add_city call),  proc will return -3.

 RETURN codes:
     -1 database error, company not added
     -2 a unique company ID could not be established
     -3 city was not in the database and could not be added
     -4 company ID was passed and it is not unique
     
   Call might look like if you want proc to asign name:
       DECLARE @cmpid varchar(8),@ret int

	EXEC @ret = dx_add_company
	  @cmpid OUTPUT,
	  'Acorn Appliance' ,
          '879 Sharonbrook',
	  '',	
	  'AKRON',
	  'OH',
	  '44143',
	  '',
	  '',
	  'Y',
	  'N',
	  'Y',
	  'Alicia 216-655-5555',
	  'CLE',
	  '',
	  'VAL3',
	  ''

-- Or the following if you want  to assign a name
 DECLARE @cmpid varchar(8),@ret int

	EXEC @ret = dx_add_company
	  'ACORN',
	  'Acorn Appliance' ,
          '879 Sharonbrook',
	  '',	
	  'Akron',
	  'OH',
	  '44143',
	  '',
	  '',
	  'Y',
	  'N',
	  'Y',
	  'Alicia 216-655-5555',
	  'CLE',
	  '',
	  'VAL3',
	  ''


*/
  
CREATE PROCEDURE [dbo].[dx_add_company]
	@@cmp_id  varchar(8) OUTPUT,
	@cmp_name varchar(100) = 'NOT NAMED' ,
    @cmp_address1 varchar(100) = '',
	@cmp_address2 varchar(100) = '',	
	@cmp_cityname varchar(18),
	@cmp_state char(2),
	@cmp_zip varchar(10),
	@cmp_county char(3),
	@cmp_country char(3),
	@cmp_is_billto char(1) = 'N',
	@cmp_is_shipper char(1) = 'N',
	@cmp_is_consignee char(1) = 'N',
	@cmp_contact varchar(30) = '',
	@cmp_revtype1 varchar(6) = 'UNK',
	@cmp_revtype2 varchar(6) = 'UNK',
	@cmp_revtype3 varchar(6) = 'UNK',
	@cmp_revtype4 varchar(6) = 'UNK',
	@cmp_altid varchar(25) = '',
	@cmp_phone varchar(20) = '',
	@cmp_altphone varchar(20) = '',
	@cmp_faxphone varchar(20) = '',
	@cmp_defaultcommodity varchar(8) = 'UNKNOWN'

	
 AS 

  DECLARE @ret int, @count smallint, @counter smallint, @idlength smallint
  DECLARE @part1 varchar(30), @part2 varchar(30)
  DECLARE @cty_code int, @cty_nmstct varchar(25)
 

    /* Check to see if the comapny already exists, if it does return -1 */
  SELECT @@cmp_id = UPPER(ISNULL(@@cmp_id,''))

  IF @@cmp_id = '*AUTOID*'
    BEGIN
     WHILE 1=1
     BEGIN
      EXEC @@cmp_id = dbo.getsystemnumber 'CMPID', null
      SELECT @ret = (SELECT COUNT(1) FROM company WHERE cmp_id = @@cmp_id)
      IF @ret = 0 BREAK
     END
    END
  ELSE
    BEGIN
      IF @@cmp_id > ''
      BEGIN
       SELECT @ret = (SELECT COUNT(1)
	 		FROM company
		 	WHERE cmp_id = @@cmp_id)
 
       IF @ret > 0 RETURN -4
      END
    END

  SELECT @cmp_name = UPPER(@cmp_name)
  SELECT @cmp_cityname = UPPER(@cmp_cityname)
    /* The company does not exist, if there is not company ID, create one */
  IF @@cmp_id = ''
    BEGIN
      
      SELECT @part1 = REPLACE(@cmp_name, ' ', '')
      SELECT @part1 = REPLACE(@part1, '.', '')
      SELECT @part1 = REPLACE(@part1, '-', '')
      SELECT @part1 = REPLACE(@part1, '#', '')
      SELECT @part1 = REPLACE(@part1, '&', '')
      SELECT @part1 = REPLACE(@part1, '/', '')
   --   SELECT @part1 = REPLACE(@part1, "'", '')
      SELECT @part1 = SUBSTRING(@part1,1,3)
      SELECT @part2 = REPLACE(@cmp_cityname, ' ', '')
      SELECT @part2 = REPLACE(@part2, '.', '')
      SELECT @part2 = REPLACE(@part2, '-', '')
      SELECT @part2 = REPLACE(@part2, '#', '')
      SELECT @part2 = REPLACE(@part2, '&', '')
      SELECT @part2 = REPLACE(@part2, '/', '')
   --   SELECT @part2 = REPLACE(@part2, "'", '')
      SELECT @part2 = SUBSTRING(@part2,1,3)
      SELECT @@cmp_id = @part1 + @part2
      /* check for dups, add counter if dup found */
      SELECT @counter = 0
      SELECT @idlength = LEN(@@cmp_id)
      WHILE 1 = 1
         BEGIN
     	   SELECT @count = (SELECT COUNT(*)
			FROM company
			WHERE cmp_id = @@cmp_id)
           IF @count = 0  BREAK
	   SELECT @Counter = @counter + 1
	   IF @counter > 99
		SELECT @@cmp_id = SUBSTRING(@@cmp_id,1,@idlength)+CONVERT(VARCHAR(1), CHAR((@counter / 10) + 55))+CONVERT(VARCHAR(1),@counter % 10)
	   ELSE
		SELECT @@cmp_id = SUBSTRING(@@cmp_id,1,@idlength)+RIGHT('00' + CONVERT(VARCHAR(2),@counter),2)
         END
      IF LEN(@@cmp_id) > 8 RETURN -2
      
    END
 
    /* Next check to see that the city exists. If it does not, add it */

    EXEC dx_add_city
 	@cmp_cityname ,
	@cmp_state ,
	@cmp_zip ,
	@cmp_county ,
	@cmp_country ,
	@cty_code  OUTPUT,
	@cty_nmstct  OUTPUT


  SELECT @cmp_revtype1 = UPPER(ISNULL(@cmp_revtype1,'UNK'))
  IF @cmp_revtype1 = '' SELECT @cmp_revtype1 = 'UNK'
  SELECT @cmp_revtype2 = UPPER(ISNULL(@cmp_revtype2,'UNK'))
  IF @cmp_revtype2 = '' SELECT @cmp_revtype2 = 'UNK'
  SELECT @cmp_revtype3 = UPPER(ISNULL(@cmp_revtype3,'UNK'))
  IF @cmp_revtype3 = '' SELECT @cmp_revtype3 = 'UNK'
  SELECT @cmp_revtype4 = UPPER(ISNULL(@cmp_revtype4,'UNK'))
  IF @cmp_revtype4 = '' SELECT @cmp_revtype4 = 'UNK'
  SELECT @cmp_is_billto = ISNULL(@cmp_is_billto,'Y')
  IF CHARINDEX(@cmp_is_billto,'N',1) = 0 and CHARINDEX(@cmp_is_billto,'Y',1) = 0 
	SELECT @cmp_is_billto = 'Y'
  SELECT @cmp_is_consignee = ISNULL(@cmp_is_consignee,'Y')
  IF CHARINDEX(@cmp_is_consignee,'N',1) = 0 and CHARINDEX(@cmp_is_consignee,'Y',1) = 0 
	SELECT @cmp_is_consignee = 'Y'

  IF ISNULL(@cmp_phone,'') = '' SELECT @cmp_phone = NULL
  IF ISNULL(@cmp_altphone,'') = '' SELECT @cmp_altphone = NULL
  IF ISNULL(@cmp_faxphone,'') = '' SELECT @cmp_faxphone = NULL

  /* Now add the new company */
  INSERT INTO company (
	cmp_id, cmp_active, cmp_address1, 				--1
	cmp_address2, cmp_agedinvflag, cmp_altid, cmp_artype, 		--2
	cmp_billto, cmp_centroidcity, cmp_centroidctynmstct, 		--3
	cmp_city, cmp_consingee, cmp_contact, cmp_createdate, 			--4
	cmp_creditavail, cmp_creditlimit, cmp_defaultbillto, 		--5
	cmp_defaultpriority, cmp_edi210,    	 			--6
	cmp_faxphone, cmd_code, cmp_invcopies, 				--7
	cmp_invoicetype, cmp_lastmb, cmp_mailto_crterm1, 		--8
	cmp_mailto_crterm2, cmp_mailto_crterm3, cmp_max_dunnage, 	--9
	cmp_mbdays, cmp_misc1, cmp_name, 				--10
	cmp_othertype1, cmp_othertype2, cmp_payfrom, 			--11
	cmp_primaryphone, cmp_quickentry, cmp_region1, 			--12
	cmp_region2, cmp_region3, cmp_region4, 				--13
	cmp_revtype1, cmp_revtype2, cmp_revtype3, 			--14
	cmp_revtype4, cmp_secondaryphone, cmp_shipper, 			--15
	cmp_state, cmp_taxtable1, cmp_taxtable2, 			--16
	cmp_taxtable3, cmp_taxtable4, cmp_transfertype, 		--17
	cmp_updatedby, cmp_updateddate, cmp_zip, 			--18
	cty_nmstct, cmp_country)							--19
	values (@@cmp_id,'Y',@cmp_address1,
        @cmp_address2,'N',@cmp_altid,'CSH',
 	@cmp_is_billto,NULL,NULL,
	@cty_code,@cmp_is_consignee,@cmp_contact,getdate(),				--4
	0.0,0.0,'UNKNOWN',						--5
	'UNK',0,							--6
	@cmp_faxphone,@cmp_defaultcommodity,1,						--7
	'INV',getdate(),'ANY',						--8
	'ANY','ANY',0,							--9
	0,NULL,@cmp_name,						--10
	'UNK','UNK','UNKNOWN',						--11
	@cmp_phone,'Y','UNK',
	'UNK','UNK','UNK',
	@cmp_revtype1,@cmp_revtype2,@cmp_revtype3,
	@cmp_revtype4,@cmp_altphone,@cmp_is_shipper,
	@cmp_state,'Y','Y',
	'N','N','INV',
	'dx_add_company',GETDATE(),@cmp_zip,
	@cty_nmstct, @cmp_country)

   RETURN 1
	
GO
GRANT EXECUTE ON  [dbo].[dx_add_company] TO [public]
GO
