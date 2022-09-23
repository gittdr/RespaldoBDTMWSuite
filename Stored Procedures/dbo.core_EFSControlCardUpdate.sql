SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSControlCardUpdate]
    @controlcard_csc_cardnumber varchar(10),
    @controlcard_cac_id varchar(10),
    @controlcard_csc_generic char(1),
    @controlcard_csc_userid varchar(20),
    @controlcard_csc_ecb char(1),
    @controlcard_csc_codeword varchar(25),
    @controlcard_csc_vendor varchar(50),
    @controlcard_ccc_id varchar(10),
    @controlcard_csc_vendor_userid varchar(20)

AS
	UPDATE [cdsecuritycard]
	   SET  csc_generic = @controlcard_csc_generic,
			csc_userid = @controlcard_csc_userid,
			csc_ecb = @controlcard_csc_ecb,
			csc_codeword = @controlcard_csc_codeword,
			csc_vendor_userid = @controlcard_csc_vendor_userid
	 WHERE	cac_id = @controlcard_cac_id
       AND 	ccc_id = @controlcard_ccc_id
	   AND	csc_cardnumber = @controlcard_csc_cardnumber
	   AND  csc_vendor = @controlcard_csc_vendor
GO
GRANT EXECUTE ON  [dbo].[core_EFSControlCardUpdate] TO [public]
GO
