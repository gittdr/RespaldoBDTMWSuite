SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetCarIdByDocket]
( @docket VARCHAR(15)
) RETURNS VARCHAR(8)

AS
/**
 *
 * NAME:
 * dbo.fn_GetCarIdByDocket
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns CAR_ID from carrier profile for given car_iccnum
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @docket VARCHAR(15)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 02/07/2013 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @CAR_ID   VARCHAR(8)

   SELECT @CAR_ID = car_id
     FROM carrier
    WHERE car_iccnum = @docket

   IF @CAR_ID IS NULL
      SELECT @CAR_ID = 'UNKNOWN'

   RETURN @CAR_ID

END
GO
GRANT EXECUTE ON  [dbo].[fn_GetCarIdByDocket] TO [public]
GO
