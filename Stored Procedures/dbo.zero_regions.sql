SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.zero_regions    Script Date: 6/1/99 11:54:42 AM ******/
create proc [dbo].[zero_regions] @ctycode int as 

while ( select count(*) from city where cty_code > @ctycode ) > 0 begin

	set rowcount 1

	update city
		set cty_region1 = '?', 
			cty_region2 = '?', 
			cty_region3 = '?', 
			cty_region4 = '?' 
		where cty_code > @ctycode 

	select @ctycode = cty_code from city where cty_code > @ctycode 

end 

return



GO
GRANT EXECUTE ON  [dbo].[zero_regions] TO [public]
GO
