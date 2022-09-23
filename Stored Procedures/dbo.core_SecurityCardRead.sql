SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_SecurityCardRead]
    @securitycard_csc_cardnumber varchar(10),
    @securitycard_csc_userid varchar(20),
    @securitycard_csc_vendor varchar(50)
AS
	SELECT 
	    csc_cardnumber as securitycard_csc_cardnumber,
	    cac_id as securitycard_cac_id,
	    csc_generic as securitycard_csc_generic,
	    csc_userid as securitycard_csc_userid,
	    csc_ecb as securitycard_csc_ecb,
	    csc_codeword as securitycard_csc_codeword,
	    csc_vendor as securitycard_csc_vendor,
	    ccc_id as securitycard_ccc_id,
	    csc_vendor_userid as securitycard_csc_vendor_userid
	FROM [cdsecuritycard]
	WHERE	csc_cardnumber = @securitycard_csc_cardnumber
    	AND 	csc_userid = @securitycard_csc_userid
	AND    	csc_vendor = @securitycard_csc_vendor

GO
GRANT EXECUTE ON  [dbo].[core_SecurityCardRead] TO [public]
GO
