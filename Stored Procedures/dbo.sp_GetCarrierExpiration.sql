SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_GetCarrierExpiration]
( @CarrierCSALogHdr_id  INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_GetCarrierExpiration
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to return rows from Expiration for a given update
 *
 * RETURNS:
 *
 * RESULTSET
 *
 * PARAMETERS:
 * @CarrierCSALogHdr_id  INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/21/2013
 *
 **/

SET NOCOUNT ON

BEGIN

   SELECT e.exp_source
        , e.exp_idtype
        , e.exp_id
        , c.car_name
        , e.exp_code
        , e.exp_description
        , e.exp_priority
        , e.exp_expirationdate
        , e.exp_creatdate
        , e.exp_lastdate
        , e.exp_updateon
        , e.exp_updateby
        , e.exp_completed
        , e.exp_compldate
     FROM carrier c
     JOIN expiration e ON c.car_id     = e.exp_id
                      AND 'CAR'        = e.exp_idtype
                      AND 'Y'          = e.exp_auto_created
     JOIN CarrierCSALogDtl ld ON e.CarrierCSALogDtl_id = ld.id
    WHERE ld.CarrierCSALogHdr_id = @CarrierCSALogHdr_id

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetCarrierExpiration] TO [public]
GO
