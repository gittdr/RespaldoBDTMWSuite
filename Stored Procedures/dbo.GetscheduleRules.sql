SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetscheduleRules]
 @p_schnumber int

AS
/**
 * 
 * NAME:
 * dbo.GetscheduleRules
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Pass a schedule and get all the hoidays rules linked to it
 *
 * 
 *
 * RETURNS:
 * no return code
 *
 * RESULT SETS: 
 *  hr.hrule_code
 * hrule_holiday = isnull(hr.hrule_holiday,'UNK')
 * hrule_holiday_group = isnull(hrule_holiday_group,'UNK')
 * hrd_observedDayofweek 
 * hrd_tripstartdayadj = isnull(hrd_tripstartdayadj,0)
 * hrd_tripStartrule
 * hrd_tripstartadj = isnull(hrd_tripstartadj,0)
 * hrd_tripInProgRule
 * hrd_tripinprogAdj
 * PARAMETERS:
 * 001 -  @p_schnumber int
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 6/2/07 DPETE PTS35747 DPETE  - Created stored proc for SR requiring all  trips to be adjusted for the time zone.
 * 7/25/07 38586 DPETE change link to holidays from sch_number to sch_masterid
 *
 **/




select hr.hrule_code
,hrule_holiday = isnull(hr.hrule_holiday,'UNK')
,hrule_holiday_group = isnull(hrule_holiday_group,'UNK')
,hrd_firststopflag = isnull(hrd_firststopflag,'Y')
,hrd_observedDayofweek 
,hrd_tripstartdayadj = isnull(hrd_tripstartdayadj,0)
,hrd_tripStartrule
,hrd_tripstartadj = isnull(hrd_tripstartadj,0)
,sch.sch_masterid  --sch.sch_number
from schedule_holidayrules sch 
join holidayrule hr on sch.hrule_id = hr.hrule_id
join holidayruleDetail hrd on hr.hrule_id = hrd.hrule_id
/* Where sch.sch_number = @p_schnumber */
Where sch.sch_masterid = @p_schnumber


GO
GRANT EXECUTE ON  [dbo].[GetscheduleRules] TO [public]
GO
