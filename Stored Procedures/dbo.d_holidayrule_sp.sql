SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_holidayrule_sp]
 @p_hrulecode varchar(12)

AS
/**
 * 
 * NAME:
 * dbo.d_holidayrule_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns header information from holidayrule table for a single rule

 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * hrule_id	int identity,
 * hrule_name      varchar(15),
 * hrule_comment varchar(255) null,
 * hrule_holiday   
 *
 * PARAMETERS:
 * 001 - @p_hruleid     -- 
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 3/20/07 DPETE PTS35747 DPETE  - Created stored proc for SR requireing creating holiday rules for hte order scheduler
 * 5/31/07 DPETE 37686 add holiday group
 *
 **/
 
select  hrule_id
,hrule_code
,hrule_name 
,hrule_holiday = isnull(hrule_holiday,'UNK'),hrule_holiday_t ='Holiday'
,hrule_UpdatedBY
,hrule_updateddate
,hrule_holiday_group = isnull(hrule_holiday_group,'UNK'),hrule_holiday_group_t = 'HolidayGroup'
from holidayrule 
where hrule_code = @p_hrulecode
GO
GRANT EXECUTE ON  [dbo].[d_holidayrule_sp] TO [public]
GO
