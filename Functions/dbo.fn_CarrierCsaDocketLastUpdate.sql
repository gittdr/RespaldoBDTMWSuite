SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CarrierCsaDocketLastUpdate]
( @docket   VARCHAR(15)
)
RETURNS @Table TABLE(docket VARCHAR(15), providername VARCHAR(30), lastupdatedate DATETIME, CarrierCSALogHdr_id INT)
AS

/**
 *
 * NAME:
 * dbo.fn_CarrierCsaDocketLastUpdate
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Used for listing docket update status from log
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @docket VARCHAR(15)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 02/18/13 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @temp TABLE
   ( docket                VARCHAR(15)
   , CarrierCSALogHdr_id   INT
   )

   IF @docket IS NULL OR @docket = ''
      SELECT @docket = '%'

   INSERT INTO @temp
   ( docket
   , CarrierCSALogHdr_id
   )
   SELECT csa.docket AS docket
        , MAX(h.id)  AS CarrierCSALogHdr_id
     FROM CarrierCSA csa
     JOIN carrierCsaLogDtl d ON csa.CarrierCsaLogDtl_id = d.id
     JOIN carrierCsaLogHdr h ON d.CarrierCSALogHdr_id = h.id
    WHERE csa.docket LIKE @docket
   GROUP BY csa.docket

   INSERT INTO @Table
   ( docket
   , providername
   , lastupdatedate
   , CarrierCSALogHdr_id
   )
   SELECT t.docket
        , h.providername
        , h.lastupdatedate
        , t.CarrierCSALogHdr_id
      FROM @temp t
      JOIN carrierCsaLogHdr h ON t.CarrierCSALogHdr_id = h.id

   RETURN

END
GO
GRANT REFERENCES ON  [dbo].[fn_CarrierCsaDocketLastUpdate] TO [public]
GO
GRANT SELECT ON  [dbo].[fn_CarrierCsaDocketLastUpdate] TO [public]
GO
