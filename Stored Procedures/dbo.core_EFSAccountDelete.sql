SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSAccountDelete]
    	@efs_account_efs_account_number varchar (10)
AS

	IF NOT Exists (select crd_cardnumber from cashcard where crd_accountid = @efs_account_efs_account_number and crd_vendor <> 'EFS')
	Begin
		DELETE FROM [cdcustcode]
		WHERE cac_id = @efs_account_efs_account_number

		DELETE FROM [cdacctcode]
		WHERE cac_id = @efs_account_efs_account_number
	End	

	DELETE FROM [efs_account]
	WHERE efs_account_number = @efs_account_efs_account_number

GO
GRANT EXECUTE ON  [dbo].[core_EFSAccountDelete] TO [public]
GO
