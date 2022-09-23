SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[DriverAwareSuite_ValidateCompanyID] (@CompanyID varchar(255))

As

Set NOCount On

Declare @ValidateCompanyID varchar(255)
Declare @Error varchar(255)

Select cmp_id
From   company (NOLOCK)
Where  cmp_id = @CompanyID
 


GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_ValidateCompanyID] TO [public]
GO
