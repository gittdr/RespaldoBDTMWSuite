SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_CarrierCSALogHdrMessage]
( @CarrierCSALogHdr_id  INT
, @Message              VARCHAR(250)
) AS
/**
 *
 * NAME:
 * dbo.sp_CarrierCSALogHdrMessage
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for writing messages in table CarrierCSALogHdrMessage
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 CarrierCSALogHdr_id INT
 * 002 Message             VARCHAR(250)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 13/02/15 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN

   If @CarrierCSALogHdr_id IS NULL OR @Message IS NULL OR @CarrierCSALogHdr_id = 0 OR @Message = ''
      RETURN

   INSERT INTO CarrierCSALogHdrMessage(CarrierCSALogHdr_id, Message)
   VALUES(@CarrierCSALogHdr_id,@Message)

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_CarrierCSALogHdrMessage] TO [public]
GO
