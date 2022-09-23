SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_210_record_id_2_39_sp] 
	@cmp_id varchar( 8 ),
	@n101code varchar(2),
	@trpid varchar(20),
	@billto varchar(8),
	@docid  varchar(30),
	@ord int
AS

/**
 * 
 * NAME:
 * dbo.edi_210_record_id_2_39_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the "2" record  or company record on the 210 for an invoice.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @cmp_id, varchar(8), input, not null;
 *       This parameter indicates company that the current record is being processed for.
 * 002 - @n101code, varchar(2), input, not null;
 *       This parameter indicates the company role on the current invoice, SH,CN or BT are accepted .
 * 003 - @trpid, varchar(20), input, null;
 *       This parameter indicates the trading partner id 
 * 004 - @billto varchar(8);
 *		 This parameter indicates the billto ID on the current invoice.
 * 005 - @docid varchar(30);
 *	     This parameter indicates the edi document ID for the current 210
 * 006 - @ord int;
 *		 This parameter indicates the order number associated with the current invoice.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_210_all_39_sp 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 *
 *  add code to truncate long fields 3/3/00
 *	pts 11689 dpete state filed changed to 6 char on database, must truncate for flat file
 *                 PTS14844 - id zip is blank on company, city zip is not picked up
 *                 PTS27374-Aross - Appendeded cmp_address2 to the end of the record based on GeneralInfo Setting
 * 								    Added country code to the end of the record	
 *                 PTS28400 - Aross - Fix for shipper or consignee that is a city/state only with a company ID of UNKNOWN.	
 *                  PTS28909 Aross - address line 2 should take precedence over the geoloc setting	  
 * 10/17/2005.07 - PTS30185 - A. Rossman - Updated to create a dummy record for UNKNOWN shipper or Consignee.
 * 02/14/2007.06  PTS36039 - A.Rossman - Allow for use of full location codes from cmpcmp table
 * 06/11/2008.07 PTS 42883 - A.Rossman - Add city splc code to the output code.
 **/
 
 
DECLARE @datacol varchar(255), @ediloccode varchar(30), @geo char(1), @mode char(2),@addr2_flag char(1),@trp_uselongcodes char(1),@splc_flag char(1)

SELECT @trpid = SUBSTRING(ISNULL(@trpid,'MISSING'),1,20)

SELECT @n101code = SUBSTRING(ISNULL(@n101code,'XX'),1,2)

select @geo = left(isnull(gi_string1,'N'),1) from generalinfo where gi_name = 'EDI210GeoRegion'

SELECT	 @trp_uselongcodes = ISNULL(trp_long_storecodes,'N'),
		   	@splc_flag = ISNULL(trp_210_splc,'N')
FROM 	    	edi_trading_partner WHERE trp_210id  = @trpid		--PTS 36039


SELECT	@mode = left(isnull(ref_number,'M'),2) 
FROM	referencenumber 
WHERE	ref_table = 'orderheader' 
   	 AND ref_tablekey = @ord 
  	  AND ref_type = 'MS3'

--Aross PTS 27374
SELECT	@addr2_flag = left(isnull(gi_string1,'N'),1) 
FROM	generalinfo 
WHERE	gi_name = 'EDI_AddrLine2'


CREATE TABLE #210_temp_company (
	cmp_name	VARCHAR(30) NULL,
	cmp_address1	VARCHAR(30) NULL,
	cty_state	VARCHAR(2) NULL,
	cty_name	VARCHAR(18) NULL,
	zip	VARCHAR(9) NULL,
	cmp_id 	VARCHAR(8) NULL,
	cmp_geoloc varchar(30) null,
	cmp_address2 VARCHAR(30) NULL,
	country	VARCHAR(3) NULL,
	splc	VARCHAR(9) NULL			--PTS #42883
	)

IF @cmp_id <> 'UNKNOWN'		  --PTS 28400 Aross
-- put the data into a temp table so that it can be massaged
INSERT INTO #210_temp_company
  SELECT
	SUBSTRING(ISNULL(company.cmp_name,'MISSING'),1,30) cmp_name,
	SUBSTRING(ISNULL(company.cmp_address1,' '),1,30) cmp_address1,
	SUBSTRING(ISNULL(city.cty_state,' '),1,2) cty_state,
	SUBSTRING(ISNULL(city.cty_name,' '),1,18) cty_name,
	--(MMSQL7 ONY)SUBSTRING(REPLACE(isnull(ISNULL(company.cmp_zip,city.cty_zip),' '),'-',''),1,9) zip,
	zip = Case 
		When Datalength(Rtrim(Isnull(company.cmp_zip,''))) > 0 Then Substring(company.cmp_zip,1,9)
		Else IsNull(city.cty_zip,' ')
		End,
	company.cmp_id,
	cmp_geoloc = case @mode
		when 'GR' then left(isnull(company.cmp_geoloc,' '),30)
		when 'GS' then left(isnull(company.cmp_geoloc_forsearch,' '),30)
		else ' '
		end,
	cmp_address2 = case @addr2_flag
				when 'Y' then 	SUBSTRING(ISNULL(company.cmp_address2,' '),1,30)
				when 'N' then ''
				else  ''
				end,
	country = LEFT(stc_country_c,3),
	ISNULL(CAST(city.cty_splc as VARCHAR(9)),'         ')
  FROM company,city,statecountry
  WHERE company.cmp_id=@cmp_id 
	and city.cty_code=company.cmp_city 
	and city.cty_state = statecountry.stc_state_c

	ELSE	
		--insert a dummy record for UNKNOWN company and UNKNOWN city/state combination
		INSERT INTO #210_temp_company	
		SELECT
			'UNKNOWN' cmp_name,
			' '	  cmp_address1,
			'XX' cty_state,
			'UNKNOWN' cty_name,
			' ' zip,
			'UNKNOWN' cmp_id,
			' ' cmp_geoloc,
			' ' cmp_address2,
			'UNK' country,
			'000000000' splc

		
  SELECT @ediloccode =  CASE @trp_uselongcodes
  						WHEN 'N'  THEN SUBSTRING(cmpcmp.ediloc_code,1,10)
  						WHEN 'Y'  THEN cmpcmp.ediloc_code
  						ELSE ' '
  					   END	
  FROM cmpcmp 
  Where cmpcmp.billto_cmp_id = @billto
  and   cmpcmp.cmp_id = @cmp_id

 /* SELECT @ediloccode = SUBSTRING(cmpcmp.ediloc_code,1,10)
  FROM cmpcmp 
  Where cmpcmp.billto_cmp_id = @billto
  and   cmpcmp.cmp_id = @cmp_id

	*/
    SELECT @ediloccode = ISNULL(@ediloccode,'   ')
    
-- set up the data_col value



  SELECT @datacol = 
	ISNULL('2' +			-- Record ID
	'39' +					-- Record Version
	@n101code +				-- N101 code
	replicate(' ',2-datalength(@n101code)) +
	cmp_name +				-- name
	replicate(' ',30-datalength(cmp_name)) +
	cmp_address1 +				-- address
	replicate(' ',30-datalength(cmp_address1)) +
	cty_state +				-- state
	replicate(' ',2-datalength(cty_state)) +
	cty_name +				-- city
	replicate(' ',18-datalength(cty_name)) +
	zip +					-- zip
	replicate(' ',9-datalength(zip)) +
	@cmp_id +	
	replicate(' ',20-datalength(@cmp_id)) + -- locationcode
	SUBSTRING(@ediloccode,1,10)  +
	replicate(' ',10-datalength(SUBSTRING(@ediloccode,1,10))) +
	'XX' + 
	case @addr2_flag--@geo 
		WHEN 'Y' THEN cmp_address2 +  replicate(CHAR(32),30-datalength(cmp_address2))
		when 'N' then isnull(cmp_geoloc,' ') + replicate(' ',30-datalength(cmp_geoloc)) 
		else '' end,'NULL') +
		country +			--country code
	replicate(CHAR(32),3-datalength(country)) +
	CASE @trp_uselongcodes
			WHEN 'Y' THEN @ediloccode + replicate(CHAR(32),30 - datalength(@ediloccode))
			ELSE replicate(CHAR(32),30 )				--PTS36039 **update this to replicate CHAR(32) 30 times if additional data fields are added to the records to act as a placeholder**
	END +
	CASE @splc_flag									--PTS 42883::added splc to output
			WHEN 'Y' THEN splc + replicate(CHAR(48),9-datalength(splc))
			ELSE replicate(CHAR(32),9)
	END			
  FROM #210_temp_company

-- return the row from the temp table
  INSERT Into EDI_210 (data_col,doc_id,trp_id)
  VALUES (@datacol,@docid, @trpid)


GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_2_39_sp] TO [public]
GO
