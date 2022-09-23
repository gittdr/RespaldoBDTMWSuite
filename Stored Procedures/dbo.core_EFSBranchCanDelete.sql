SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSBranchCanDelete]
    	@cdcustcode_cac_id varchar (10), 
	@cdcustcode_ccc_id varchar (10)

AS
	SELECT top 1 crd_cardnumber
	FROM [cashcard]
	WHERE 	crd_accountid = @cdcustcode_cac_id and crd_customerid = @cdcustcode_ccc_id and crd_vendor = 'EFS'

GO
GRANT EXECUTE ON  [dbo].[core_EFSBranchCanDelete] TO [public]
GO
