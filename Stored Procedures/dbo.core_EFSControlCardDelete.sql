SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSControlCardDelete]
    @controlcard_cac_id varchar(10),
    @controlcard_ccc_id varchar(10),
    @controlcard_csc_userid varchar(20),
    @controlcard_csc_vendor varchar (50)
AS
	DELETE FROM [cdsecuritycard] 
	WHERE	cac_id = @controlcard_cac_id
    	AND 	ccc_id = @controlcard_ccc_id
	AND    	csc_userid = @controlcard_csc_userid
	AND  csc_vendor = @controlcard_csc_vendor
GO
GRANT EXECUTE ON  [dbo].[core_EFSControlCardDelete] TO [public]
GO
