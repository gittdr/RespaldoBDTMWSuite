SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSControlCardCreate]
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
INSERT INTO [cdsecuritycard] (
    csc_cardnumber,
    cac_id,
    csc_generic,
    csc_userid,
    csc_ecb,
    csc_codeword,
    csc_vendor,
    ccc_id,
    csc_vendor_userid)
VALUES (
    @controlcard_csc_cardnumber,
    @controlcard_cac_id,
    @controlcard_csc_generic,
    @controlcard_csc_userid,
    @controlcard_csc_ecb,
    @controlcard_csc_codeword,
    @controlcard_csc_vendor,
    @controlcard_ccc_id,
    @controlcard_csc_vendor_userid
)

GO
GRANT EXECUTE ON  [dbo].[core_EFSControlCardCreate] TO [public]
GO
