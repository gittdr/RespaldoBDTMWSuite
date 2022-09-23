SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create proc [dbo].[ValidateBillToToOrderRevType_sp] (
	@cmp_billto varchar(8),
	@ord_revtype1 varchar(6),
	@validated int output
)


as
/*
	In order entry and invoicing, the application is to compare 
	the branches country (branch.brn_country_c) corresponding to the value in company.cmp_othertype2 for the bill to company 
	with the branches country corresponding to the value in Revtype1 for the order.  
*/
	DECLARE @AssetLocation varchar(20),
			@OrderLocation varchar(20),
			@tmwuser varchar(255)

	set @validated = 0

	set nocount on 

	IF ISNULL(@ord_revtype1, 'UNK') = 'UNK' BEGIN
			exec @tmwuser = dbo.gettmwuser_fn

			SELECT @ord_revtype1 = usr.usr_type1
			FROM ttsusers usr 
			WHERE usr.usr_userid = @tmwuser
	END

	SELECT @AssetLocation = ISNULL(LEFT(cmp.cmp_othertype2, 2), '')
	FROM  company cmp 
	WHERE cmp.cmp_id = @cmp_billto


	SELECT @OrderLocation = ISNULL(LEFT(brn_country_c, 2), '')
	FROM branch brn 
	WHERE brn.brn_id = @ord_revtype1

	IF (@AssetLocation = @OrderLocation) or @cmp_billto = 'UNKNOWN' BEGIN
		SET @validated = 1
	END

	set nocount off

GO
GRANT EXECUTE ON  [dbo].[ValidateBillToToOrderRevType_sp] TO [public]
GO
