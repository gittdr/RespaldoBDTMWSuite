SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UMPP_3PLActivityTracking]
( @MoveNumber INT
) AS
/*******************************************************************************************************************
  Object Description:
  dbo.UMPP_3PLActivityTracking: Stored Procedure used to inform 3PL active objects tracker

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  05/06/16     Suprakash Nandan PTS:102052  Initial Version Created
********************************************************************************************************************/

SET NOCOUNT ON;

BEGIN

   EXEC TPLActiveObjectsQueue @MoveNumber

END
GO
GRANT EXECUTE ON  [dbo].[UMPP_3PLActivityTracking] TO [public]
GO
