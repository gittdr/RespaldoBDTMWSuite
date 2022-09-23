SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSBranchUpdate]
    	@cdcustcode_cac_id varchar (10), 
	@cdcustcode_ccc_id varchar (10),
	@cdcustcode_ccc_description varchar (40)

AS
	UPDATE [cdcustcode]
	SET
	    cac_id = @cdcustcode_cac_id,
	    ccc_id = @cdcustcode_ccc_id,
	    ccc_description = @cdcustcode_ccc_description
	WHERE 	cac_id = @cdcustcode_cac_id
	AND     ccc_id = @cdcustcode_ccc_id

GO
GRANT EXECUTE ON  [dbo].[core_EFSBranchUpdate] TO [public]
GO
