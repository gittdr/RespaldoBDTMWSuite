SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKAccountExists]
	@tck_account_tck_account_number varchar (10)
AS
	IF Exists (	SELECT tck_account_number
			FROM [tck_account]
			WHERE 	tck_account_number = @tck_account_tck_account_number)
	Begin
		select cast (1 as bit)
	End
	Else Begin
		select cast (0 as bit)
	End

	SELECT 
	Count(tck_account_number)
	FROM [tck_account]
	WHERE 	tck_account_number = @tck_account_tck_account_number

GO
GRANT EXECUTE ON  [dbo].[core_TCKAccountExists] TO [public]
GO
