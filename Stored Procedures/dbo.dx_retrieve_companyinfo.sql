SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_retrieve_companyinfo] (
@cmp_id varchar(35), 
@ord_editradingpartner varchar(20), 
@companyname varchar(35) Output, 
@companyaddress1 varchar(35) output, 
@cityname varchar(20) output,
@state varchar(2) output,
@companyaddress2 varchar(35) output,
@altid varchar(12) output,
@country varchar(3) output,
@phone varchar(20) output, 
@companyzip varchar(9) output
)
as
declare @citynmstct varchar(35)
select @companyname =cmp_name, @companyaddress1 =IsNull(cmp_address1,' '), @companyaddress2 = isNull(cmp_address2, ' '),
			@citynmstct =cty_nmstct, @companyzip =cmp_zip, @altid = cmp_altid, @phone = cmp_primaryphone,
			@country = cmp_country
			from company (nolock)
			where cmp_id = @cmp_id 
			

If Exists(select 1 from company_xref (nolock) where
			cmp_id = @cmp_id
			AND src_system = 'EDI'
			AND src_tradingpartner = @ord_editradingpartner)
			select top 1 @companyname =company_xref.cmp_name, @companyaddress1 =IsNull(address1,' '),
			@citynmstct =city + ',' + state,
			@companyaddress2 = '',
			@altid ='',
			@country ='',
			@phone ='', 
			@companyzip = '' 
			FROM company_xref (nolock) join company (nolock) on company_xref.cmp_id = company.cmp_id			
			where company_xref.cmp_id = @cmp_id
			AND src_system = 'EDI'
			AND src_tradingpartner = @ord_editradingpartner
			AND isNull(cmp_active,'Y') = 'Y'
	ELSE  --use old retrieval option for companies not updated with tp data
		If Exists(select 1 from company_xref (nolock) 
			where cmp_id = @cmp_id
			AND src_system = 'EDI')
			select top 1 @companyname = cmp_name, @companyaddress1 =IsNull(address1,' '),
			@citynmstct =city + ',' + state,
			@companyaddress2 = '',
			@altid ='',
			@country ='',
			@phone ='', 
			@companyzip = ''
			FROM company_xref (nolock) 
			where company_xref.cmp_id = @cmp_id
			AND src_system = 'EDI'
		ELSE -- Matched on altid
			/*If Exists(select 1 from company (nolock) where
			cmp_id = @cmp_id and isNull(cmp_altid,'') > '')
				select @companyname =@altid, @companyaddress1 ='', @companyaddress2 = '',
				@citynmstct =',  ', @companyzip ='', @phone = '',
				@country = ''
			*/

			
	declare @commapos int
	
    set @commapos = 0
    SET @commapos = CHARINDEX(',', @citynmstct, 1)   
    IF @commapos > 0 
    BEGIN  
  		SET @cityname = substring(@citynmstct, 1, @commapos - 1)   
  		SET @state = substring(@citynmstct, @commapos + 1, 2)   
  	END

GO
GRANT EXECUTE ON  [dbo].[dx_retrieve_companyinfo] TO [public]
GO
