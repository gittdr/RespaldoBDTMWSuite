SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_SecurityCardCreate]
    @securitycard_csc_cardnumber varchar(10),
    @securitycard_cac_id varchar(10),
    @securitycard_csc_generic char(1),
    @securitycard_csc_userid varchar(20),
    @securitycard_csc_ecb char(1),
    @securitycard_csc_codeword varchar(25),
    @securitycard_csc_vendor varchar(50),
    @securitycard_ccc_id varchar(10),
    @securitycard_csc_vendor_userid varchar(20)
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
    @securitycard_csc_cardnumber,
    @securitycard_cac_id,
    @securitycard_csc_generic,
    @securitycard_csc_userid,
    @securitycard_csc_ecb,
    @securitycard_csc_codeword,
    @securitycard_csc_vendor,
    @securitycard_ccc_id,
    @securitycard_csc_vendor_userid
)

GO
GRANT EXECUTE ON  [dbo].[core_SecurityCardCreate] TO [public]
GO
