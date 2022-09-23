SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_SecurityCardExists]
    @securitycard_csc_cardnumber varchar(10),
    @securitycard_csc_userid varchar(20),
    @securitycard_csc_vendor varchar(50)
AS

	IF Exists (	SELECT csc_cardnumber
			FROM [cdsecuritycard]
			WHERE	csc_cardnumber = @securitycard_csc_cardnumber
		    	AND 	csc_userid = @securitycard_csc_userid
			AND    	csc_vendor = @securitycard_csc_vendor)
	Begin
		select cast (1 as bit)
	End
	Else Begin
		select cast (0 as bit)
	End
GO
GRANT EXECUTE ON  [dbo].[core_SecurityCardExists] TO [public]
GO
