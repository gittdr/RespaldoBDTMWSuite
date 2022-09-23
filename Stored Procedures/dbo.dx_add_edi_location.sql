SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_add_edi_location]
	(@@cmp_id varchar(8) OUTPUT,
	 @@cty_code int OUTPUT,
	 @@cty_nmstct varchar(25) OUTPUT,
	 @cmp_name varchar(100),
	 @cmp_address1 varchar(100),
	 @cmp_address2 varchar(100),
	 @cmp_cityname varchar(18),
	 @cmp_state char(2),
	 @cmp_zip varchar(10),
	 @cmp_county char(3),
	 @cmp_country char(4),
	 @cmp_is_billto char(1),
	 @cmp_is_shipper char(1),
	 @cmp_is_consignee char(1),
	 @cmp_contact varchar(30),
	 @cmp_revtype1 varchar(6),
	 @cmp_revtype2 varchar(6),
	 @cmp_revtype3 varchar(6),
	 @cmp_revtype4 varchar(6),
	 @cmp_altid varchar(25),
	 @cmp_phone varchar(20) = '',
	 @cmp_altphone varchar(20) = '',
	 @cmp_faxphone varchar(20) = '')
as

/*******************************************************************************************************************  
  Object Description:
  dx_add_edi_location

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

declare @ret int
select @ret = 1

if isnull(@cmp_name,'') IN ('UNKNOWN','')
begin
	select @@cmp_id = 'UNKNOWN'
	exec dx_add_city @cmp_cityname, @cmp_state, @cmp_zip, @cmp_county, @cmp_country, 
		@@cty_code OUTPUT, @@cty_nmstct OUTPUT
end
else
begin
	if len(@cmp_phone) > 10
	begin
		select @cmp_phone = replace(@cmp_phone,'(', '')
		select @cmp_phone = replace(@cmp_phone,')', '')
		select @cmp_phone = replace(@cmp_phone,'.', '')
		select @cmp_phone = replace(@cmp_phone,'-', '')
		select @cmp_phone = replace(@cmp_phone,' ', '')
		if len(@cmp_phone) > 10 select @cmp_phone = ''
	end
	if len(@cmp_altphone) > 10
	begin
		select @cmp_altphone = replace(@cmp_altphone,'(', '')
		select @cmp_altphone = replace(@cmp_altphone,')', '')
		select @cmp_altphone = replace(@cmp_altphone,'.', '')
		select @cmp_altphone = replace(@cmp_altphone,'-', '')
		select @cmp_altphone = replace(@cmp_altphone,' ', '')
		if len(@cmp_altphone) > 10 select @cmp_altphone = ''
	end
	if len(@cmp_faxphone) > 10
	begin
		select @cmp_faxphone = replace(@cmp_faxphone,'(', '')
		select @cmp_faxphone = replace(@cmp_faxphone,')', '')
		select @cmp_faxphone = replace(@cmp_faxphone,'.', '')
		select @cmp_faxphone = replace(@cmp_faxphone,'-', '')
		select @cmp_faxphone = replace(@cmp_faxphone,' ', '')
		if len(@cmp_faxphone) > 10 select @cmp_faxphone = ''
	end
	exec @ret = dx_add_company @@cmp_id OUTPUT, @cmp_name, @cmp_address1, @cmp_address2, @cmp_cityname, 
		@cmp_state, @cmp_zip, @cmp_county, @cmp_country, @cmp_is_billto,
		@cmp_is_shipper, @cmp_is_consignee, @cmp_contact, @cmp_revtype1, @cmp_revtype2,
		@cmp_revtype3, @cmp_revtype4, @cmp_altid, @cmp_phone, @cmp_altphone, @cmp_faxphone,'UNKNOWN'
	if @ret = 1
	begin
		select @@cty_code = cmp_city, @@cty_nmstct = cty_nmstct
		  from company where cmp_id = @@cmp_id
	
	--insert newly created company into company xref table
	INSERT INTO company_xref(cmp_id,cmp_name,address1,address2,city,state,zip,crt_date,src_system,upd_date,upd_by)
		VALUES(@@cmp_id,@cmp_name,@cmp_address1,@cmp_address2,@cmp_cityname,@cmp_state,@cmp_zip,GETDATE(),'EDI',GETDATE(),'LTSL2')	  
	end	  
end

return @ret

GO
GRANT EXECUTE ON  [dbo].[dx_add_edi_location] TO [public]
GO
