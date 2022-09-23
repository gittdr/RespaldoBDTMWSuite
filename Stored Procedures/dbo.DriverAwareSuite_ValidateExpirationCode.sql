SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[DriverAwareSuite_ValidateExpirationCode] (@ExpCode varchar(255))

As

Set NOCount On

Declare @ValidateCompanyID varchar(255)
Declare @Error varchar(255)

Select abbr
From   labelfile (NOLOCK)
Where  abbr = @ExpCode
       And
       labeldefinition = 'DrvExp'




GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_ValidateExpirationCode] TO [public]
GO
