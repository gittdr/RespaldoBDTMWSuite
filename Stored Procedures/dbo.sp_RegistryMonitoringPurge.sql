SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[sp_RegistryMonitoringPurge]
( @DAYS_OLD   INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_RegistryMonitoringPurge
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to delete rows from RegistryMonitoring Logs
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @DAYS_OLD   INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/22/2013
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @SQLString      NVARCHAR(MAX)
   DECLARE @ParmDefinition NVARCHAR(500)

   DECLARE @lastupdatedate DATETIME
   DECLARE @tablename      VARCHAR(50)
   DECLARE @id             INT
   DECLARE @ctr            INT

   DECLARE @TableList TABLE
   ( id        INT IDENTITY
   , tablename VARCHAR(50)
   )

   IF @DAYS_OLD IS NULL OR @DAYS_OLD < 0
      SELECT @DAYS_OLD = 30

   SELECT @lastupdatedate = DATEADD(s, 86399,  DATEADD(dd, DATEDIFF(dd,@DAYS_OLD, GetDate()), 0))

   INSERT INTO @TableList ( tablename )
   SELECT DISTINCT d.staging_table
     FROM TmwXmlInfoHdr h
    JOIN TmwXmlInfoDtl d ON h.id = d.tmwxmlinfohdr_id
    WHERE d.staging_table IS NOT NULL
      AND h.ImportingClassName IN ('RmCarrierStatus','RmCarrierStatusLoadFile')

   SELECT @ctr = COUNT(1) FROM @TableList
   SELECT @id = 0
   WHILE @id < @ctr
   BEGIN
      SELECT @id = @id + 1

      SELECT @tablename = tablename
        FROM @TableList
       WHERE id = @id

      BEGIN TRY
         --Begin Dynamic SQL
         SELECT @SQLString = N'DELETE FROM ' + @tablename +
                           ' WHERE lastupdatedate <= @lastupdatedate'
         SELECT @ParmDefinition = N'@lastupdatedate DATETIME'
         EXECUTE sp_executesql @SQLString, @ParmDefinition, @lastupdatedate = @lastupdatedate
         --End Dynamic SQL
      END TRY
      BEGIN CATCH

      END CATCH
   END
   --End Loop

   --Delete older version of CarrierCSALogDtl
   DELETE CarrierCSALogDtl
     FROM CarrierCSALogDtl d
     JOIN CarrierCSALogHdr h ON d.CarrierCSALogHdr_id = h.id
                            AND h.ProviderName = 'RegistryMonitoring'
     LEFT OUTER JOIN expiration e ON d.id = e.carriercsalogdtl_id
    WHERE d.lastupdatedate <= @lastupdatedate
      AND e.carriercsalogdtl_id IS NULL

   --Delete CarrierCSALogHdr
   DELETE CarrierCSALogHdr
     FROM CarrierCSALogHdr h
     LEFT OUTER JOIN CarrierCSALogDtl d ON h.id = d.CarrierCSALogHdr_id
    WHERE h.ProviderName = 'RegistryMonitoring'
      AND h.lastupdatedate <= @lastupdatedate
      AND d.CarrierCSALogHdr_id IS NULL

   --Delete CarrierCSALogHdrMessage
   DELETE CarrierCSALogHdrMessage
     FROM CarrierCSALogHdrMessage m
     LEFT OUTER JOIN CarrierCSALogHdr h ON m.CarrierCSALogHdr_id = h.id
      AND m.lastupdatedate <= @lastupdatedate
      AND h.id IS NULL

   --Delete XMLImportLog (1)
   DELETE FROM TmwXmlImportLog
    WHERE lastupdatedate <= @lastupdatedate
      AND CarrierCSALogHdr_id IS NULL

   --Delete XMLImportLog (2)
   DELETE TmwXmlImportLog
     FROM TmwXmlImportLog l
     LEFT OUTER JOIN CarrierCSALogHdr h ON l.CarrierCSALogHdr_id = h.id
    WHERE l.lastupdatedate <= @lastupdatedate
      AND h.id IS NULL

   --Delete XMLImportLogError
   DELETE TmwXmlImportLogError
     FROM TmwXmlImportLogError e
     JOIN TmwXmlImportLog l ON e.TmwXmlImportLog_id = l.id
    WHERE e.lastupdatedate <= @lastupdatedate
      AND l.id IS NULL


END
GO
GRANT EXECUTE ON  [dbo].[sp_RegistryMonitoringPurge] TO [public]
GO
