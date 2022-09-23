SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKAccountCanDelete]
	@tck_account_tck_account_number varchar (10)
AS

	SELECT top 1 crd_cardnumber
	FROM [cashcard]
	WHERE 	crd_accountid = @tck_account_tck_account_number and crd_vendor = 'TCHEK'
	--SELECT count (*)
	--FROM [cashcard]
	--WHERE 	crd_accountid = @tck_account_tck_account_number and crd_vendor = 'TCHEK'


GO
GRANT EXECUTE ON  [dbo].[core_TCKAccountCanDelete] TO [public]
GO
