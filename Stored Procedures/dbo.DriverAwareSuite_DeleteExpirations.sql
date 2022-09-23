SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE       Procedure [dbo].[DriverAwareSuite_DeleteExpirations] (@Exp_key int)
As

	Set NOCount On

	Delete from expiration
        Where  exp_key = @Exp_key
	       

















GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_DeleteExpirations] TO [public]
GO
