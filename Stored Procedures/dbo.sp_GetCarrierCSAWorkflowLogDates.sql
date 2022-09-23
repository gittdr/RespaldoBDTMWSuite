SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_GetCarrierCSAWorkflowLogDates]
( @st_lastupdatedate DATETIME
, @en_lastupdatedate DATETIME
)
AS

/**
 *
 * NAME:
 * dbo.sp_GetCarrierCSAWorkflowLogDates
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to return workflow dates from TmwXmlImportLog
 *
 * RETURNS:
 *
 * RESULTSET
 *
 * PARAMETERS:
 * @st_lastupdatedate DATETIME
 * @en_lastupdatedate DATETIME
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/21/2013
 *
 **/

SET NOCOUNT ON

BEGIN


   IF @st_lastupdatedate IS NULL
      SELECT @st_lastupdatedate = DATEADD(dd, DATEDIFF(dd,30, GetDate()), 0)

   IF @en_lastupdatedate IS NULL
      SELECT @en_lastupdatedate = GETDATE()

   SELECT id                  AS TmwXmlImportLog_Id
        , lastupdatedate      AS LogDate
        , activity_name       AS activity_name
        , CarrierCSALogHdr_id AS CarrierCSALogHdr_id
     FROM TmwXmlImportLog
    WHERE lastupdatedate >= @st_lastupdatedate
      AND lastupdatedate <= @en_lastupdatedate
   ORDER BY lastupdatedate DESC

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetCarrierCSAWorkflowLogDates] TO [public]
GO
