SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_GetCarrierCSALogByTmwXmlImportLogId]
( @TmwXmlImportLog_Id    INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_GetCarrierCSALogByTmwXmlImportLogId
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to return rows from CarrierCSA log tables
 *
 * RETURNS:
 *
 * RESULTSET
 *
 * PARAMETERS:
 * @TmwXmlImportLog_Id   INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/21/2013
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @CarrierCSALogHdr_id  INT
   DECLARE @today                DATETIME

   DECLARE @CSALogDetail TABLE
   ( CarrierCSALogHdr_id   INT
   , LogDateTime           DATETIME
   , LogSource             VARCHAR(100)
   , LogMessage            VARCHAR(1000)
   )

   --Today
   SELECT @today = DATEADD(dd, DATEDIFF(dd,0, GetDate()), 0)

   --Validate Parms
   IF @TmwXmlImportLog_Id IS NULL OR @TmwXmlImportLog_Id <= 0
      RETURN

   SELECT @CarrierCSALogHdr_id = CarrierCSALogHdr_id
     FROM TmwXmlImportLog
    WHERE id = @TmwXmlImportLog_Id

   --Check if key info for latest update found then bring expiration log
   IF @CarrierCSALogHdr_id IS NOT NULL
   BEGIN
      --Expiration
      INSERT INTO @CSALogDetail
      ( CarrierCSALogHdr_id
      , LogDateTime
      , LogSource
      , LogMessage
      )
      SELECT lm.CarrierCSALogHdr_id
           , lm.lastupdatedate
           , 'Expiration'
           , lm.message
        FROM CarrierCSALogHdrMessage lm
       WHERE lm.CarrierCSALogHdr_id = @CarrierCSALogHdr_id
   END

   --XML Import Log
   INSERT INTO @CSALogDetail
   ( CarrierCSALogHdr_id
   , LogDateTime
   , LogSource
   , LogMessage
   )
   SELECT il.CarrierCSALogHdr_id
        , ile.lastupdatedate
        , il.activity_name
        , ile.ErrorInfo
     FROM TmwXmlImportLog il
     JOIN TmwXmlImportLogError ile ON il.id = ile.TmwXmlImportLog_id
    WHERE il.CarrierCSALogHdr_id = @CarrierCSALogHdr_id

   --RegistryMonitoring provided Errors
   INSERT INTO @CSALogDetail
   ( CarrierCSALogHdr_id
   , LogDateTime
   , LogSource
   , LogMessage
   )
   SELECT il.CarrierCSALogHdr_id
        , re.LastUpdateDate
        , il.activity_name
        , re.Error
     FROM TmwXmlImportLog il
     JOIN RMXML_Errors re ON il.id = re.TmwXmlImportLog_id
    WHERE (  il.CarrierCSALogHdr_id = @CarrierCSALogHdr_id
          OR il.id = (SELECT MAX(id) FROM TmwXmlImportLog WHERE lastupdatedate >= @today)
          )

   SELECT *
     FROM @CSALogDetail
   ORDER BY LogDateTime ASC
          , LogSource DESC

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetCarrierCSALogByTmwXmlImportLogId] TO [public]
GO
