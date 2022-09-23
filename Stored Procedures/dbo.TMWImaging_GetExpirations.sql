SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TMWImaging_GetExpirations]
@IDTYPE CHAR(3), @CODE VARCHAR(6)
AS

/*******************************************************************************************************************  
  Object Description:
  Fetch open expirations for checking against documents. (Used to make sure people aren't editing expirations set by TMW Imaging.)

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  08/07/2017   Chip Ciminero    WE-209653   Created
*******************************************************************************************************************/

SELECT	*
FROM	expiration
WHERE   exp_idtype = @IDTYPE AND exp_code = @CODE AND exp_completed = 'N'
ORDER BY exp_id
GO
GRANT EXECUTE ON  [dbo].[TMWImaging_GetExpirations] TO [public]
GO
