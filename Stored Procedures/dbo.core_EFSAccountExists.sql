SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSAccountExists]
	@efs_account_efs_account_number varchar (10)
AS
	IF Exists (	SELECT efs_account_number
			FROM [efs_account]
			WHERE 	efs_account_number = @efs_account_efs_account_number)
	Begin
		select cast (1 as bit)
	End
	Else Begin
		select cast (0 as bit)
	End

	SELECT 
	Count(efs_account_number)
	FROM [efs_account]
	WHERE 	efs_account_number = @efs_account_efs_account_number

GO
GRANT EXECUTE ON  [dbo].[core_EFSAccountExists] TO [public]
GO
