SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TMWImaging_GetContactInfo]
@CMP_ID VARCHAR(8)
AS

/*******************************************************************************************************************  
  Object Description:
  This stored retrieves contact information for a bill-to.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  08/15/2017   Jennifer Jackson WE-209778    Created
*******************************************************************************************************************/
--DECLARE @CMP_ID VARCHAR(8)
--SELECT @CMP_ID = 'IMPCLE'

BEGIN
	SELECT *
	FROM companyemail ce
	WHERE ce.cmp_id = @CMP_ID
END

GO
GRANT EXECUTE ON  [dbo].[TMWImaging_GetContactInfo] TO [public]
GO
