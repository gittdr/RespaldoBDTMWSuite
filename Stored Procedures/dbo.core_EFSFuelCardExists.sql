SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelCardExists]
    @fuelcard_crd_vendor varchar(8),
    @fuelcard_crd_accountid varchar(10),
    @fuelcard_crd_customerid varchar(10),
    @fuelcard_crd_cardnumber varchar(20)
AS
	if Exists (select crd_cardnumber
		         from cashcard
	            where crd_accountid = @fuelcard_crd_accountid 
	              and crd_customerid = @fuelcard_crd_customerid
	              and crd_cardnumber = @fuelcard_crd_cardnumber
		          and crd_vendor = @fuelcard_crd_vendor)
	begin
		select cast (1 as bit)
	end
	else 
	begin
		if exists (select crd_cardnumber 
		             from cashcard
		            where crd_accountid = @fuelcard_crd_accountid 
		              and crd_customerid = @fuelcard_crd_customerid
		              and crd_cardnumber = @fuelcard_crd_cardnumber)
		begin
			update cashcard
			   set crd_vendor = 'EFS'
			 where crd_accountid = @fuelcard_crd_accountid 
		       AND crd_customerid = @fuelcard_crd_customerid
		       AND crd_cardnumber = @fuelcard_crd_cardnumber
			select CAST(1 as bit)
		end
		else
		begin
			select cast (0 as bit)
		end
	end

GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelCardExists] TO [public]
GO
