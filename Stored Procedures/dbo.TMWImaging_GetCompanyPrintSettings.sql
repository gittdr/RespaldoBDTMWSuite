SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TMWImaging_GetCompanyPrintSettings]
@COMPANYID VARCHAR(8)
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc retrieves Company Print Settings by companyId

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  08/17/2017   Jennifer Jackson WE-209653    Created
*******************************************************************************************************************/
--DECLARE @COMPANYID VARCHAR(8)
--SELECT @COMPANYID = 'REDTUA'

BEGIN
	SELECT
        p.*, c.cmp_geoloc_forsearch
    FROM
        company_print_settings p
    RIGHT OUTER JOIN
        company c
    ON
        ( p.cmp_id = c.cmp_id )
    WHERE
        c.cmp_id = @COMPANYID
END

GO
GRANT EXECUTE ON  [dbo].[TMWImaging_GetCompanyPrintSettings] TO [public]
GO
