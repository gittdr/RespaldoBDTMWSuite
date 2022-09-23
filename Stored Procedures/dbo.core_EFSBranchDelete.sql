SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSBranchDelete]
    	@cdcustcode_cac_id varchar (10), 
	@cdcustcode_ccc_id varchar (10)

AS

	IF Exists (select cac_id from cdcustcode where cac_id = @cdcustcode_cac_id and ccc_id = @cdcustcode_ccc_id)
	Begin
		DELETE FROM [cdcustcode]
		WHERE cac_id = @cdcustcode_cac_id
		AND ccc_id = @cdcustcode_ccc_id
	End	

GO
GRANT EXECUTE ON  [dbo].[core_EFSBranchDelete] TO [public]
GO
