SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_get_cmp_id_by_trading_partner]
	@@cmp_id varchar(8) OUTPUT,
	@cmp_name varchar(60),
	@cmp_address1 varchar(50),
	@cmp_address2 varchar(50),
	@cmp_city varchar(50),
	@cmp_state varchar(2),
	@cmp_zip varchar(10),
	@trp_id varchar(20),
	@cmp_revtype1 varchar(6)
 AS 

 /*******************************************************************************************************************  
  Object Description:
  dx_get_cmp_id_by_trading_partner

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
  09/14/2016   David Wilks      64858        can pull wrong stop number when more than one dx_sourcedate
********************************************************************************************************************/

DECLARE @cty_code int, @cty_name varchar(50), @cty_state varchar(2), @test_cmp_id varchar(8), @retcode int
	  , @v_rowsecurity char(1), @v_rowsecurityforltsl2 char(1), @v_source varchar(6)

IF RTRIM(ISNULL(@@cmp_id,'')) = '' SELECT @@cmp_id = 'UNKNOWN'

IF @@cmp_id <> 'UNKNOWN'
BEGIN
	EXEC @retcode = dx_does_company_exist @@cmp_id
	RETURN @retcode
END

SELECT @@cmp_id = 'UNKNOWN', @test_cmp_id = ''

IF ISNUMERIC(@cmp_city) = 0  	--city name
	SELECT @cty_name = @cmp_city
	     , @cty_state = @cmp_state
ELSE				--city code
BEGIN
	SELECT @cty_code = convert(int, @cmp_city)
	SELECT @cty_name = cty_name
	     , @cty_state = cty_state
	  FROM city
	 WHERE cty_code = @cty_code
END

SELECT @v_rowsecurity = upper(left(gi_string1,1)) FROM generalinfo WHERE gi_name = 'RowSecurity'
IF ISNULL(@v_rowsecurity,'N') <> 'Y' SELECT @v_rowsecurity = 'N'

SELECT @v_rowsecurityforltsl2 = upper(left(gi_string1,1)) FROM generalinfo WHERE gi_name = 'RowSecurityForLTSL2'
IF ISNULL(@v_rowsecurityforltsl2,'N') <> 'Y' SELECT @v_rowsecurityforltsl2 = 'N'

IF @v_rowsecurityforltsl2 = 'Y'
	SELECT @v_source = CASE WHEN ISNULL(@cmp_revtype1,'') IN ('','UNK') THEN 'EDI' ELSE @cmp_revtype1 END
ELSE
	SELECT @v_source = 'EDI'

--02.12.09 AR - Changes to retrieve based on trading partner id
SELECT @test_cmp_id = max(company_xref.cmp_id)
	  FROM company_xref (nolock) join company (nolock) on company_xref.cmp_id = company.cmp_id
	 WHERE company_xref.cmp_name = RTRIM(ISNULL(@cmp_name,''))
	   AND address1 = RTRIM(ISNULL(@cmp_address1,''))
	--   AND address2 = @cmp_address2
	   AND city = RTRIM(ISNULL(@cty_name,''))
	   AND state = RTRIM(ISNULL(@cty_state,''))
	--   AND zip = @cmp_zip
	   AND (src_system = @v_source or @v_rowsecurityforltsl2 = 'N')
	   AND src_tradingpartner = @trp_id		--retrieve by tp
	   AND isNull(cmp_active,'Y') = 'Y'


IF NOT(SELECT ISNULL(@test_cmp_id,'')) > ''		--use old retrieval option for companies not updated with tp data
	SELECT @test_cmp_id = max(company_xref.cmp_id)
	  FROM company_xref (nolock) join company (nolock) on company_xref.cmp_id = company.cmp_id
	 WHERE company_xref.cmp_name = RTRIM(ISNULL(@cmp_name,''))
	   AND address1 = RTRIM(ISNULL(@cmp_address1,''))
	--   AND address2 = @cmp_address2
	   AND city = RTRIM(ISNULL(@cty_name,''))
	   AND state = RTRIM(ISNULL(@cty_state,''))
	--   AND zip = @cmp_zip
	   AND (src_system = @v_source or @v_rowsecurityforltsl2 = 'N')
	   AND isNull(cmp_active,'Y') = 'Y'
	   

/*
IF RTRIM(ISNULL(@cmp_address1,'')) > '' AND RTRIM(ISNULL(@cty_name,'')) > ''
	SELECT @test_cmp_id = max(cmp_id)
	  FROM company_xref
	 WHERE cmp_name = @cmp_name
	   AND address1 = @cmp_address1
	--   AND address2 = @cmp_address2
	   AND city = @cty_name
	   AND state = @cty_state
	--   AND zip = @cmp_zip
	   AND src_system = 'EDI'
ELSE
BEGIN
	IF RTRIM(ISNULL(@cmp_address1,'')) > ''
		SELECT @test_cmp_id = max(cmp_id)
		  FROM company_xref
		 WHERE cmp_name = @cmp_name
		   AND address1 = @cmp_address1
		   AND src_system = 'EDI'
	ELSE
	BEGIN
		IF RTRIM(ISNULL(@cty_name,'')) > ''
			SELECT @test_cmp_id = max(cmp_id)
			  FROM company_xref
			 WHERE cmp_name = @cmp_name
			   AND city = @cty_name
			   AND state = @cty_state
			   AND src_system = 'EDI'
		ELSE
			SELECT @test_cmp_id = max(cmp_id)
			  FROM company_xref
			 WHERE cmp_name = @cmp_name
			   AND src_system = 'EDI'
	END
END
*/

IF ISNULL(@test_cmp_id,'') > ''
	IF (SELECT COUNT(1) FROM company (nolock) WHERE cmp_id = @test_cmp_id) = 1
	BEGIN
		SELECT @@cmp_id = @test_cmp_id
		RETURN 1
	END

IF ISNUMERIC(@cmp_city) = 1
BEGIN
	IF @v_rowsecurityforltsl2 = 'Y'
		SELECT @@cmp_id = max(cmp_id)
		  FROM company (nolock) 
		 WHERE cmp_name = RTRIM(ISNULL(@cmp_name,''))
		   AND isnull(cmp_address1,'') = RTRIM(ISNULL(@cmp_address1,''))
		   AND cmp_city = @cty_code
		   AND ISNULL(cmp_BelongsTo,'UNK') IN ('UNK', @v_source)
  		   AND isNull(cmp_active,'Y') = 'Y'
	ELSE
		SELECT @@cmp_id = max(cmp_id)
		  FROM company (nolock) 
		 WHERE cmp_name = RTRIM(ISNULL(@cmp_name,''))
		   AND isnull(cmp_address1,'') = RTRIM(ISNULL(@cmp_address1,''))
	--	   AND isnull(cmp_address2,'') = @cmp_address2
		   AND cmp_city = @cty_code
	--	   AND isnull(cmp_zip,'') = @cmp_zip
		   AND isNull(cmp_active,'Y') = 'Y'
END

IF ISNULL(@@cmp_id,'') = ''	SELECT @@cmp_id = 'UNKNOWN'

RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_get_cmp_id_by_trading_partner] TO [public]
GO
