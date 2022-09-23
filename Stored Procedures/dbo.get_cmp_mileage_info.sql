SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[get_cmp_mileage_info] @cmp_id varchar(8), 
	@cmp_zip varchar(10) output, 
	@cmp_city int output,
	@cmp_usestreetaddr char(1) output, 
	--PTS# 18117 ILB 07/09/03 
        --increase the size of the address variables due to the
        --increase in the size of the cmp_mapaddress column on the company
        --table from 40 char to 50 char.
	--@cmp_mapaddress varchar(40) output
          @cmp_mapaddress varchar(50) output
as

SELECT @cmp_zip = company.cmp_zip, 
	@cmp_city = company.cmp_city, 
	@cmp_usestreetaddr = company.cmp_usestreetaddr, 
	@cmp_mapaddress = company.cmp_mapaddress
 FROM company 
 WHERE company.cmp_id = @cmp_id
GO
GRANT EXECUTE ON  [dbo].[get_cmp_mileage_info] TO [public]
GO
