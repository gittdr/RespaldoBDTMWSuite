SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_214_record_id_2_39_sp] 
	@cmp_id varchar( 8 ),
	@n101code varchar(2),
	@trpid varchar(20),
	@billto  varchar(8),
	@docid varchar(30)
as

/**
 * 
 * NAME:
 * dbo.edi_214_record_id_3_39_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the #2 or company record in the EDI 214 document.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @cmp_id, varchar(8), input, not null;
 *       TMWSUITE ID of the company associated with the current stop. 
 * 002 - @n101code, varchar(2), input, not null;
 *       This parameter indicates the company role for the current stop.
 *		 Consignee - CN, Shipper - SH, BillTo BT
 * 003 - @trpid, varchar(20), input, not null;
 *       This parameter indicates the EDI Trading Partner for the current trip.
 * 004 - @billto, varchar(8), input, not null
 *		 This parameter indicates the billto for the order.
 * 005 - @docid, varchar(30), input, not null
 *		 This parameter indocates the EDI document ID
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_214_record_id_1_39_sp
 * CalledBy002 ? edi_214_record_id_3_39_sp

 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 *				  PTS8038  - D. Petersen - need to pass bill to cmp id to get correct edi location
 * 09/14/2000.02  PTS8848  - D. Petersen - keep recs for a doc together with a doc id
 * 08/20/2001.03  PTS11689 - D. Petersen - state filed on database changed to 6 char, truncate for flat file (substring all other variables)
 * 07/11/2002.04  PTS14844 - D. Petersen - pass back company zip then city zip
 * 03/21/2005.05  PTS27374 - A. Rossman  - Added support to append address line 2 to the record based on general info setting
 * 										   Added country code to the end of the record.
 * 02/14/2007.06  PTS36039 - A.Rossman - Allow for use of full location codes from cmpcmp table
 * 08/10/2012.07  PTS64284 - A.Rossman - Correct issue with edi location codes
 **/




DECLARE @ediloccode varchar(30),
				@addr2_flag char(1),
				@trp_uselongcodes char(1),
				@ediloccode_short varchar(10)	--64284
				
				
		--Aross PTS 27374
  SELECT @addr2_flag = left(isnull(gi_string1,'N'),1) from generalinfo where gi_name = 'EDI_AddrLine2'
  
  SELECT @trp_uselongcodes = ISNULL(trp_long_storecodes,'N') FROM edi_trading_partner WHERE trp_id = @trpid
  
/* put the data into a temp table so that it can be massaged */
  SELECT    n101code=ISNULL(@n101code,'??'),
    cmp_name = SUBSTRING(ISNULL(company.cmp_name,' '),1,30),
    cmp_address1=substring(isnull(cmp_address1,' '),1,30),
    cty_state=SUBSTRING(ISNULL(city.cty_state,' '),1,2),
    cty_name=SUBSTRING(ISNULL(city.cty_name,' '),1,18),
    --(MMSQL7 ONY)SUBSTRING(REPLACE(isnull(ISNULL(company.cmp_zip,city.cty_zip),' '),'-',''),1,9) zip,
	zip = Case 
		When Datalength(Rtrim(Isnull(company.cmp_zip,''))) > 0 Then Substring(company.cmp_zip,1,9)
		Else IsNull(city.cty_zip,' ')
		End,
	cmp_address2 = case @addr2_flag
			when 'Y' then 	SUBSTRING(ISNULL(company.cmp_address2,' '),1,30)
			when 'N' then ' '
			else  ' '
			end,
	country = LEFT(stc_country_c,3)	
  INTO #214_temp_company
  FROM company,city,statecountry
  WHERE company.cmp_id=@cmp_id 
  		and city.cty_code=company.cmp_city 
		and city.cty_state = statecountry.stc_state_c

  --SELECT @ediloccode =  CASE @trp_uselongcodes
  --						WHEN 'N'  THEN SUBSTRING(cmpcmp.ediloc_code,1,10)
  --						WHEN 'Y'  THEN cmpcmp.ediloc_code
  --						ELSE ' '
  --					   END	
SELECT @ediloccode = ISNULL(cmpcmp.ediloc_code,'   ')  			--64284 AJR		   
  FROM cmpcmp 
  Where cmpcmp.billto_cmp_id = @billto
  and   cmpcmp.cmp_id = @cmp_id

 SELECT @ediloccode_short = SUBSTRING(@ediloccode,1,10)

SELECT @ediloccode = ISNULL(@ediloccode,' ')
SELECT @ediloccode_short = ISNULL(@ediloccode_short,' ')

-- return the row from the temp table
INSERT edi_214 (data_col,trp_id,doc_id)    
SELECT    
data_col = '2' +   -- Record ID    
'39' +     -- Record Version    
n101code +    -- N101 code    
	isnull(replicate(' ',2-datalength(n101code)),'') +    
cmp_name +    -- name    
	isnull(replicate(' ',30-datalength(cmp_name)),'') +    
cmp_address1 +    -- address    
	isnull(replicate(' ',30-datalength(cmp_address1)),'') +    
cty_name +    -- city    
	isnull(replicate(' ',18-datalength(cty_name)),'') +    
cty_state +    -- state    
	isnull(replicate(' ',2-datalength(cty_state)),'') +    
zip +     -- zip    
	isnull(replicate(' ',9-datalength(zip)),'') +    
@cmp_id + replicate(' ',10-datalength(@cmp_id)) +       
	@ediloccode_short +    
		isnull(replicate(' ',10-datalength(@ediloccode_short)),'') +    
'XX' +     
cmp_address2 + --address 2    
	isnull(replicate(CHAR(32),30-datalength(cmp_address2)),'') +     
country +    --country code    
  isnull(replicate(CHAR(32),3-datalength(country)),'') +    
CASE @trp_uselongcodes    
	WHEN 'Y' THEN @ediloccode + replicate(CHAR(32),30 - datalength(@ediloccode))    
	ELSE ''    --PTS36039 **update this to replicate CHAR(32) 30 times if additional data fields are added to the records to act as a placeholder**    
END ,    
trp_id=@trpid, doc_id = @docid    

FROM #214_temp_company


GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_2_39_sp] TO [public]
GO
