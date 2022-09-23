SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  Returns vendor export planning board data
  Revision History:
  Date         Name             Label/PTS		 Description
  -----------  ---------------  ----------		----------------------------------------
  11/18/2016   BackOffice       NSUITE-104908    Initial Release
********************************************************************************************************************/
CREATE VIEW [dbo].[VendorExportPlanningBoardView] AS
	SELECT
		pto_id AS paytoId, 
		pto_altid AS paytoAltId,
		pto_status AS paytoStatus,
		pto_lastfirst AS paytoFullName,
        pto_gp_class,
        pto_company,
        pto_fleet,
        pto_division,
        pto_terminal,
        pto_type1,
        pto_type2,
        pto_type3,
        pto_type4,
        pto_updateddate AS lastUpdateDate
	FROM dbo.PayToRowRestrictedView 
GO
GRANT SELECT ON  [dbo].[VendorExportPlanningBoardView] TO [public]
GO
