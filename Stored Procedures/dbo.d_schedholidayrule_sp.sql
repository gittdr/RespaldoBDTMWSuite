SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_schedholidayrule_sp]
 @p_schnumber int

AS
/**
 * 
 * NAME:
 * dbo.d_schedholidayrule_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns the list f holiday rules attached to a schedule
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * shr_id	int identity,
 * sch_number     int,
 * hrule_id int
 *
 * PARAMETERS:
 * 001 - @p_schnumber   -- 
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 3/20/07 DPETE PTS35747 DPETE  - Created stored proc for SR requiring creating holiday rules for the order scheduler
 * 7/25/07 dpete 38586 key between scedule and holiday rules should be sch_masterID not sch_number
 *
 **/
 
select  shr_ident
--,sch_number = 0 -- column remoded from table
,sch.hrule_id
,hrule_code
,hrule_name
,hrule_holiday
,hrule_holiday_group
,sch_masterid
,sch_number
from schedule_holidayrules sch
join holidayrule hr on sch.hrule_id = hr.hrule_id
where sch.sch_masterid =  @p_schnumber 
GO
GRANT EXECUTE ON  [dbo].[d_schedholidayrule_sp] TO [public]
GO
