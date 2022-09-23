SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_holidayruledetail_sp]
 @p_hruleid int

AS
/**
 * 
 * NAME:
 * dbo.d_holidayruledetail_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns detail information from holidayruledetail table for a single rule

 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * hrule_id	int identity,
 * hrule_id		int,
 * hrd_ObservedDayofWeek smallint,
 * hrd_TripStartDayAdj     smallint null,
 * hrd_TripStartRule    varchar(6) null,
 * hrd_TripStartAdj     int null,
 * hrd_TripInProgRule   varchar(6) null,
 * hrd_TripInProgAdj     int null	 
 *
 * PARAMETERS:
 * 001 - @p_hruleid     -- 
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 3/20/07 DPETE PTS35747 DPETE  - Created stored proc for SR requireing creatiung holiday rules for the order scheduler

 *
 **/
 
select  hrule_id
,hrd_id
,hrd_firststopflag
,hrd_ObservedDayofWeek = isnull(hrd_ObservedDayofWeek,0)
,hrd_TripStartDayAdj= isnull(hrd_TripStartDayAdj,0)
,hrd_TripStartRule = isnull(hrd_TripStartRule,'UNK'),hrd_tripStartRule_t = 'SchStartHolidayRule'
,hrd_TripStartAdj= isnull(hrd_TripStartAdj,0)
--,hrd_TripInProgRule = isnull(hrd_TripInProgRule,'UNK'),hrd_TripInProgRule_t = 'SchStartedHolidayRul'
--,hrd_TripInProgAdj = isnull(hrd_TripInProgAdj,0)
,hrd_UpdatedBy
,hrd_UpdatedDate
from holidayruledetail 
where hrule_id = @p_hruleid
GO
GRANT EXECUTE ON  [dbo].[d_holidayruledetail_sp] TO [public]
GO
