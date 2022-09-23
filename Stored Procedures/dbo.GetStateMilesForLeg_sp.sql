SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[GetStateMilesForLeg_sp] @lgh int
AS

--BEGIN PTS 64373 SPN
DECLARE @CalculateLegMiles CHAR(1)
--END PTS 64373 SPN

--BEGIN PTS 64373 SPN
SELECT @CalculateLegMiles = dbo.fn_GetSetting('CalculateLegMiles','C1')
--END PTS 64373 SPN

--PTS63300 MBR 09/25/14 Rewriting select to use JOIN and mt_identity > 0
SELECT sm_state, SUM(ISNULL(sm_miles, 0)), SUM(sm_tollmiles) 
  FROM stops JOIN statemiles ON stops.stp_lgh_mileage_mtid = statemiles.mt_identity AND
                                statemiles.mt_identity > 0
 WHERE stops.lgh_number = @lgh AND
      (CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage
            ELSE stops.stp_lgh_mileage
       END) > 0
GROUP BY sm_state

/*
Select sm_state,SUM(IsNull(sm_miles,0)),SUM(sm_tollmiles) from stops,statemiles
--Where stp_number in (Select stp_number from stops where lgh_number = @lgh)
Where stops.lgh_number = @lgh
and statemiles.mt_identity = stp_lgh_mileage_mtid
and (CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END) > 0
Group by sm_state
*/

GO
GRANT EXECUTE ON  [dbo].[GetStateMilesForLeg_sp] TO [public]
GO
