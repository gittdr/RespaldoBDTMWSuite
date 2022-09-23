SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[import_company_info] @cmp_id varchar(8), @cmp_name varchar(30), @cty_nmstct varchar(25), @cmp_zip varchar(10) as
/* proc to check and add the company returns result set with CMP_id, Cty_code*/

declare @cty_code int

if (select count(*)
	from company
	where cmp_id = @cmp_id) < 1
begin
	select @cty_code = isnull(cty_code, 0)
	from city
	where cty_nmstct = @cty_nmstct

	insert company (cmp_id,	cmp_name, cmp_city, cty_nmstct,	cmp_zip,
		cmp_shipper, cmp_consingee, cmp_billto , cmp_othertype1, cmp_othertype2,
		cmp_revtype1,cmp_revtype2,cmp_revtype3,	cmp_revtype4,cmp_active,
		cmp_mileagetable)
	values (@cmp_id, @cmp_name, @cty_code, @cty_nmstct, @cmp_zip,
		'Y','Y','N','UNK','UNK',
		'UNK','UNK','UNK','UNK','Y',
		'5')
end
else
	select @cty_code = cmp_city
	from company
	where cmp_id = @cmp_id


select @cmp_id, @cty_code

GO
GRANT EXECUTE ON  [dbo].[import_company_info] TO [public]
GO
