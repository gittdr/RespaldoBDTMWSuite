SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSControlCardRead]
    @controlcard_cac_id varchar(10),
    @controlcard_ccc_id varchar(10),
    @controlcard_csc_userid varchar(20),
    @controlcard_csc_vendor varchar (50)
AS
	SELECT 
	    csc_cardnumber as controlcard_csc_cardnumber,
	    cac_id as controlcard_cac_id,
	    csc_generic as controlcard_csc_generic,
	    csc_userid as controlcard_csc_userid,
	    csc_ecb as controlcard_csc_ecb,
	    csc_codeword as controlcard_csc_codeword,
	    csc_vendor as controlcard_csc_vendor,
	    ccc_id as controlcard_ccc_id,
	    csc_vendor_userid as controlcard_csc_vendor_userid
	FROM [cdsecuritycard]
	WHERE	cac_id = @controlcard_cac_id
    	AND 	ccc_id = @controlcard_ccc_id
	AND    	csc_userid = @controlcard_csc_userid
	AND  csc_vendor = @controlcard_csc_vendor
GO
GRANT EXECUTE ON  [dbo].[core_EFSControlCardRead] TO [public]
GO
