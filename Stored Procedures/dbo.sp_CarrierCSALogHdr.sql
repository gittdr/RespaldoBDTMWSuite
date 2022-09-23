SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_CarrierCSALogHdr]
( @ProviderName         VARCHAR(30)
, @CarrierCSALogHdr_id  INT OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.sp_CarrierCSALogHdr
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to ID a CSA Update Log
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 * @ProviderName        VARCHAR(30)
 * @CarrierCSALogHdr_id INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/18/2013
 *
 **/

SET NOCOUNT ON

BEGIN
   BEGIN TRAN sp_CarrierCSALogHdr
      INSERT INTO CarrierCSALogHdr(ProviderName)
      VALUES(@ProviderName)

      SELECT @CarrierCSALogHdr_id = SCOPE_IDENTITY()
   COMMIT TRAN sp_CarrierCSALogHdr

END
GO
GRANT EXECUTE ON  [dbo].[sp_CarrierCSALogHdr] TO [public]
GO
