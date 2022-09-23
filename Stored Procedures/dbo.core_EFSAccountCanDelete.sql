SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSAccountCanDelete]
	@efs_account_efs_account_number varchar (10)
AS

	SELECT top 1 crd_cardnumber
	FROM [cashcard]
	WHERE 	crd_accountid = @efs_account_efs_account_number and crd_vendor = 'EFS'
	--SELECT count (*)
	--FROM [cashcard]
	--WHERE 	crd_accountid = @efs_account_efs_account_number and crd_vendor = 'EFS'

GO
GRANT EXECUTE ON  [dbo].[core_EFSAccountCanDelete] TO [public]
GO
