SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[GetStateMilesForOrder_sp] @ord INTEGER 
AS
DECLARE @statetable TABLE (
sm_state CHAR(2),
sm_miles FLOAT,
sm_tollmiles DECIMAL(9,1),
sm_percent	DECIMAL(5,2)
)

DECLARE @sum     FLOAT

INSERT INTO @statetable
   SELECT sm_state, SUM(ISNULL(sm_miles, 0)), SUM(sm_tollmiles), 0
     FROM stops JOIN statemiles ON stops.stp_lgh_mileage_mtid = statemiles.mt_Identity AND
                                   statemiles.mt_identity > 0
    WHERE stp_number in (SELECT stp_number 
                           FROM stops 
                          WHERE ord_hdrnumber = @ord)
GROUP BY sm_state

SELECT @sum = SUM(sm_miles)
  FROM @statetable

IF @sum > 0 
BEGIN
   UPDATE @statetable
      SET sm_percent = (sm_miles/@sum) * 100
END

SELECT * from @statetable

/*
Select sm_state,SUM(IsNull(sm_miles,0)),SUM(sm_tollmiles) from stops,statemiles
Where stp_number in (Select stp_number from stops where ord_hdrnumber = @ord)
and statemiles.mt_identity = stp_lgh_mileage_mtid
Group by sm_state
*/

GO
GRANT EXECUTE ON  [dbo].[GetStateMilesForOrder_sp] TO [public]
GO
