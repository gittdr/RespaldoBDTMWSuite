SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_SecurityCardDelete]
    @securitycard_csc_cardnumber varchar(10),
    @securitycard_csc_userid varchar(20),
    @securitycard_csc_vendor varchar(50)
AS
	DELETE FROM [cdsecuritycard] 
	WHERE	csc_cardnumber = @securitycard_csc_cardnumber
    	AND 	csc_userid = @securitycard_csc_userid
	AND    	csc_vendor = @securitycard_csc_vendor

GO
GRANT EXECUTE ON  [dbo].[core_SecurityCardDelete] TO [public]
GO
