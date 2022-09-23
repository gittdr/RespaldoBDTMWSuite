SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_309_company_record] 
	@p_cmp_id varchar( 8 ),
	@p_n101code varchar(2),
	@p_e309batch int,
	@p_mov_number	int
as

/**
 * 
 * NAME:
 * dbo.edi_309_company_record
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the #2 or company record in the EDI 309 document.
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
 * 002 - @p_n101code, varchar(2), input, not null;
 *       This parameter indicates the company role for the current stop.
 *		 Consignee - CN, Shipper - SH, BillTo -  BT
 * 003 - @e309batch, int, input, not null
 *		 This parameter indocates the EDI document ID
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_309_manifest_header
 * CalledBy002 ? 

 * 
 * REVISION HISTORY:
 * 02/21/2006.01 ? PTS31886 - A.Rossman ? Initial Release
 * 09/25/2006.02 - PTS34601 - A.Rossman - Updates to support identification for pre-registered entities
 *					  this will support the future rollout of preferred manifest by CBP.
 **/

DECLARE	@aceidtype  varchar(6)



CREATE TABLE #309_temp 
(
	n101code	varchar(2)  NULL,
	cmp_name	varchar(30) NULL,
	cmp_addr1	varchar(30) NULL,
	cmp_addr2	varchar(30) NULL,
	city		varchar(18) NULL,
	state		varchar(6)  NULL,
	zip		varchar(10) NULL,
	country		varchar(50) NULL,
	contact_type	varchar(2)  NULL,
	contact_number	varchar(50) NULL,
	aceid_type	varchar(6)  NULL,	--PTS 34601
	ace_id		varchar(30) NULL	--PTS 34601
)
  
--Insert the record into the temp table  
  
  
/* put the data into a temp table so that it can be massaged */
 INSERT INTO #309_temp
 SELECT    n101code=ISNULL(@p_n101code,'??'),
    	    cmp_name = SUBSTRING(ISNULL(company.cmp_name,' '),1,30),
    	    cmp_address1=substring(isnull(cmp_address1,' '),1,30),
    	    cmp_address2 =SUBSTRING(ISNULL(company.cmp_address2,' '),1,30),
   	    city=SUBSTRING(ISNULL(city.cty_name,' '),1,18),
   	    state=SUBSTRING(ISNULL(city.cty_state,' '),1,2),
    	    zip = Case 
		When Datalength(Rtrim(Isnull(company.cmp_zip,''))) > 0 Then Substring(company.cmp_zip,1,9)
		Else IsNull(city.cty_zip,' ')
		End,
	    country = ISNULL(LEFT(cmp_country,2),'??'),
	    contact_type = 'TE',
	    contact_number = ISNULL(company.cmp_primaryphone,' '),
	    aceid_type = ISNULL(cmp_aceidtype,'UNK'),
	    ace_id = ISNULL(cmp_aceid,'')  
  FROM company,city,statecountry
  WHERE company.cmp_id=@P_cmp_id 
  		and city.cty_code=company.cmp_city 
		and city.cty_state = statecountry.stc_state_c


--get the aceid qualifier for the record type
IF (SELECT ISNULL(aceid_type,'UNK')FROM #309_temp) <> 'UNK'
    SELECT @aceidtype = LEFT(edicode,2)
    FROM   labelfile
    	INNER JOIN #309_temp
    		ON labelfile.abbr = aceid_type
    WHERE  labeldefinition = 'ACEIDType'

IF (@p_n101code  IN ('CN','SH') AND @aceidtype IN ('A7','PY','1')) OR (@p_n101code = 'IM' AND @aceidtype IN('A7','1','FI','CU')) OR (@p_n101code = 'CN' AND @aceidtype = 'FI')
BEGIN

	IF @p_n101code  IN ('CN','SH') AND @aceidtype IN ('A7','PY','1')		--valid ID types for Shipper and Consignee 
		BEGIN
			INSERT edi_309 (data_col,batch_number,mov_number)
			SELECT
			data_col = '2' + '|' +		-- Record ID
			'10' + '|' +				-- Record Version
			n101code + '|' +		--code
			 '|' +					-- name
			 '|' +					-- address
			 '|' +					-- address2
			 '|' + 					-- city
			 '|' + 					-- state
			 '|' +					-- zip
			 '|' +					-- country code
			 '|' +					-- contact type
			 '|' +					-- contact number
			CASE  @aceidtype
				WHEN 'PY' THEN 'FT'
				WHEN '8S' THEN 'BF'
				ELSE @aceidtype
			END	+ '|' +		-- ID Type qualifier
			 RTRIM(ace_id) +'|' ,	-- ID number
			batch_number = @p_e309batch,
			mov_number   = @p_mov_number
			FROM	#309_temp
		END 

	IF @p_n101code = 'IM' AND @aceidtype IN('A7','1','FI','CU')		--Importer valid document types
		BEGIN
			INSERT edi_309 (data_col,batch_number,mov_number)
			SELECT
			data_col = '2' + '|' +		-- Record ID
			'10' + '|' +				-- Record Version
			n101code + '|' +		-- code
			'|' +					-- name
			'|' +					-- address
			 '|' +					-- address2
			 '|' + 					-- city
			 '|' + 					-- state
			 '|' +					-- zip
			 '|' +					-- country code
			 '|' +					-- contact type
			 '|' +					-- contact number
			 @aceidtype
			+ '|' +				-- ID Type qualifier
			 RTRIM(ace_id) +'|' ,	-- ID number
			batch_number = @p_e309batch,
			mov_number   = @p_mov_number
			FROM	#309_temp
		END 

	IF @p_n101code = 'CN' AND @aceidtype = 'FI'		--Taxpayer ID for Consignee only
		BEGIN
			INSERT edi_309 (data_col,batch_number,mov_number)
			SELECT
			data_col = '2' + '|' +		-- Record ID
			'10' + '|' +				-- Record Version
			n101code + '|' +		-- code
			 '|' +					-- name
			 '|' +					-- address
			 '|' +					-- address2
			 '|' + 					-- city
			 '|' + 					-- state
			 '|' +					-- zip
			 '|' +					-- country code
			 '|' +					-- contact type
			 '|' +					-- contact number
			 @aceidtype
			+ '|' +				-- ID Type qualifier
			 RTRIM(ace_id) +'|' ,	-- ID number
			batch_number = @p_e309batch,
			mov_number   = @p_mov_number
			FROM	#309_temp
		 END 
 END
ELSE  --Provide full company information
	-- return the row from the temp table
	INSERT edi_309 (data_col,batch_number,mov_number)
	SELECT 
	data_col = '2' + '|' +			-- Record ID
	'10' + '|' +					-- Record Version
	n101code + '|' +			-- N101 code
	cmp_name + '|' +			-- name
	cmp_addr1 + '|' +			-- address
	cmp_addr2 + '|' +			--address line 2
	city + '|' +					-- city
	state +	'|' +				-- state
	zip + '|' +					-- zip
	country + '|' +				--country code
	contact_type  + '|' +			--contact type TE - telephone
	contact_number +'|'+		-- Contact number
	'|' +						-- ID Qualifier
	'|',						-- ID Number

	batch_number = @p_e309batch,
	mov_number = @p_mov_number

	FROM #309_temp

GO
GRANT EXECUTE ON  [dbo].[edi_309_company_record] TO [public]
GO
