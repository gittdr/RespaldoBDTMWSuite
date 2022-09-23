SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  Returns customer export planning board data
  Revision History:
  Date         Name             Label/PTS		 Description
  -----------  ---------------  ----------		----------------------------------------
  12/20/2016   BackOffice       NSUITE-104906    Initial Release
  10/10/2017   BackOffice       NSUITE-202232    Add last updated date to view result set
********************************************************************************************************************/
CREATE VIEW [dbo].[CustomerExportPlanningBoardView] AS
	SELECT
		cmp_id AS companyId, 
		cmp_altid AS companyAltId,
		cmp_name AS companyName,
		cmp_active AS companyStatus,
        cmp_billto AS companyBillTo,
		cmp_shipper AS companyShipper,
        cmp_consingee AS companyConsignee,
        cmp_subcompany AS companySubCompany,
        cmp_revtype1 AS companyRevType1,
        cmp_revtype2 AS companyRevType2,
        cmp_revtype3 AS companyRevType3,
        cmp_revtype4 AS companyRevType4,
        cmp_gp_class AS companyCustomerClass,
        cmp_updateddate AS lastUpdateDate
	FROM dbo.CompanyRowRestrictedView 
GO
GRANT SELECT ON  [dbo].[CustomerExportPlanningBoardView] TO [public]
GO
