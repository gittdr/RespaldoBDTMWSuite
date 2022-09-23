SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_CarrierCSALogDtl]
( @CarrierCSALogHdr_id  INT
, @docket               VARCHAR(15)
, @CarrierCSALogDtl_id  INT OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.sp_CarrierCSALogDtl
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to ID a CSA Update Log DTL
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 * @CarrierCSALogHdr_id INT
 * @docket              VARCHAR(15)
 * @CarrierCSALogDtl_id INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/18/2013
 *
 **/

SET NOCOUNT ON

BEGIN
   BEGIN TRAN sp_CarrierCSALogDtl
      INSERT INTO CarrierCSALogDtl(CarrierCSALogHdr_id, docket)
      VALUES(@CarrierCSALogHdr_id, @docket)

      SELECT @CarrierCSALogDtl_id = SCOPE_IDENTITY()
   COMMIT TRAN sp_CarrierCSALogDtl

END
GO
GRANT EXECUTE ON  [dbo].[sp_CarrierCSALogDtl] TO [public]
GO
