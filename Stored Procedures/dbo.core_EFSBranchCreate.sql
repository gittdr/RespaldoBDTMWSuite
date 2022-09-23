SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSBranchCreate]
    	@cdcustcode_cac_id varchar (10), 
	@cdcustcode_ccc_id varchar (10),
	@cdcustcode_ccc_description varchar (40)
		
AS

INSERT INTO [cdcustcode] (
    cac_id, 
    ccc_id,
    ccc_description,
    ccc_glnumber,
    plusless,
    ccc_company,
    ccc_skt_id,
    ccc_revtype1)
VALUES (
    @cdcustcode_cac_id, 
    @cdcustcode_ccc_id,
    @cdcustcode_ccc_description,
    NULL,
    '',
    'UNKNOWN',
    NULL,
    NULL)
 
GO
GRANT EXECUTE ON  [dbo].[core_EFSBranchCreate] TO [public]
GO
