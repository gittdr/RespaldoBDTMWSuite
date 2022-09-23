SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_GetCarrierCSALog]
( @ProviderName   VARCHAR(30)
, @docket         VARCHAR(15)
)
AS

/**
 *
 * NAME:
 * dbo.sp_GetCarrierCSALog
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
 * @ProviderName  VARCHAR(30)
 * @as_docket     VARCHAR(15)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/20/2013
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
   IF @docket IS NULL OR @docket = '' OR @ProviderName IS NULL OR @ProviderName = ''
   BEGIN
      SELECT *
        FROM @CSALogDetail
      RETURN
   END

   --Determine latest update @CarrierCSALogHdr_id from the @docket and the given @providername
   SELECT TOP 1
          @CarrierCSALogHdr_id   = l.CarrierCSALogHdr_id
     FROM fn_CarrierCsaDocketLastUpdate(@docket) l
    WHERE l.ProviderName = @ProviderName

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
   END

   --Carrier411 log
   IF @ProviderName = 'Carrier411'
   BEGIN
      INSERT INTO @CSALogDetail
      ( CarrierCSALogHdr_id
      , LogDateTime
      , LogSource
      , LogMessage
      )
      SELECT cw.CarrierCSALogHdr_id
           , cwl.LastUpdateDate
           , cw.method
           , cwl.FaultMessage
        FROM carrier411ws cw
        JOIN carrier411wslog cwl ON cw.BATCH_ID = cwl.BATCH_ID
       WHERE cw.CarrierCSALogHdr_id = @CarrierCSALogHdr_id
   END

   --Only RegistryMonitoring provided Errors
   IF @ProviderName = 'RegistryMonitoring' AND @CarrierCSALogHdr_id IS NULL
   BEGIN
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
       WHERE il.id = (SELECT MAX(id) FROM TmwXmlImportLog WHERE lastupdatedate >= @today)
   END

   SELECT *
     FROM @CSALogDetail
   ORDER BY LogDateTime ASC
          , LogSource DESC

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetCarrierCSALog] TO [public]
GO
