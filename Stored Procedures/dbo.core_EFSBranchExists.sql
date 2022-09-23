SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSBranchExists]
	@cdcustcode_cac_id varchar (10),
	@cdcustcode_ccc_id varchar(10)
AS
	IF Exists(	SELECT ccc_id
				  FROM cdcustcode
				 WHERE cac_id = @cdcustcode_cac_id
				   AND ccc_id = @cdcustcode_ccc_id
			)
	Begin
		select cast (1 as bit)
	End
	Else Begin
		select cast (0 as bit)
	End

	SELECT count(*)
	  FROM cdcustcode
	 WHERE cac_id = @cdcustcode_cac_id
	   AND ccc_id = @cdcustcode_ccc_id

GO
GRANT EXECUTE ON  [dbo].[core_EFSBranchExists] TO [public]
GO
