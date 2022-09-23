SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[IsEditBlockedBySettlementStatus_sp](@BlockEditLevelAfterSettlement AS VARCHAR(10),
                                                    @LghNumber AS INTEGER,
                                                    @MovNumber AS INTEGER,
                    	                            @IsBlocked AS BIT OUTPUT)

AS
/**
 * 
 * NAME:
 * dbo.IsEditBlockedBySettlementStatus_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Checks if there are locks due to setttlements.
 *
 * RETURNS:
 * @IsBlocked AS BIT
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @BlockEditLevelAfterSettlement VARCHAR(10)
 * 002 - @LghNumber AS INTEGER
 * 003 - @MovNumber AS INTEGER
 * 004 - @IsBlocked AS BIT OUTPUT
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 04/24/2014 - PTS #76531 - BW - Created.
 * 04/25/2014 - PTS #76531 - BW - Added defaults for parameters if they are NULL.
 **/

SET  NOCOUNT ON 

DECLARE @BlockCounter AS INTEGER

-- Checks parameters
IF (@BlockEditLevelAfterSettlement IS NULL) SELECT @BlockEditLevelAfterSettlement = ''
IF (@LghNumber IS NULL) SELECT @LghNumber = 0
IF (@MovNumber IS NULL) SELECT @MovNumber = 0
SELECT @IsBlocked = 0

SELECT @BlockCounter = 
  CASE @BlockEditLevelAfterSettlement
       WHEN 'MOV'   THEN
           ( SELECT  COUNT(*) 
             FROM dbo.assetassignment AA
             INNER JOIN dbo.paydetail PD
			   ON (AA.lgh_number = PD.lgh_number)
             WHERE (AA.pyd_status = 'PPD')
               AND (AA.mov_number = @MovNumber))
       WHEN 'NON'    THEN
           ( SELECT 0 )
       WHEN 'LEGALL' THEN
			(	SELECT  COUNT(*) 
				FROM	dbo.assetassignment AA
						INNER JOIN dbo.paydetail PD ON (AA.lgh_number = PD.lgh_number) 
				WHERE	AA.lgh_number = @LghNumber
			)
       WHEN 'MOVALL' THEN
			(	SELECT	COUNT(*) 
				FROM	dbo.assetassignment AA
						INNER JOIN dbo.paydetail PD ON (AA.lgh_number = PD.lgh_number)
				WHERE	AA.mov_number = @MovNumber
			)
       ELSE -- 'LEG' -- default
           ( SELECT  COUNT(*) 
             FROM dbo.assetassignment AA
             INNER JOIN dbo.paydetail PD
			   ON (AA.lgh_number = PD.lgh_number)
             WHERE (AA.pyd_status = 'PPD')
               AND (AA.lgh_number = @LghNumber))
  END

 SELECT @IsBlocked = CASE WHEN @BlockCounter > 0 THEN 1 ELSE 0 END
 
GO
GRANT EXECUTE ON  [dbo].[IsEditBlockedBySettlementStatus_sp] TO [public]
GO
