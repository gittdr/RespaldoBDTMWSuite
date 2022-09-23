SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[getusertimezoneinfo]
@p_GMDelta smallint output,@p_DSTAppplies smallint output,
@p_TZmins smallint output
AS 
/**
 * 
 * NAME:
 * dbo.AdjustDateForZoneShift
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * return the current user time zone information
 * first chise is user profile
 * if no info for user go to GI LocalTimeOption for a defaul city code
 * if no info in GI, assume EST, Daylifght savings applies and zzero mins offset
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * Arguments are output variables
 *
 * PARAMETERS:
 * @p_GMDelta smallint output
 * @p_DSTAppplies char(1) output,
 * @p_TZmins smallint output
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 4/14/07 DPETE PTS35747 DPETE  - Created stored proc for SR requireing all  trips to be adjusted for the time zone.

 *
 **/

DECLARE @v_tmwuser varchar (255),@v_DefaultCity int
exec gettmwuser @v_tmwuser output

select @v_defaultCity = isnull(gi_integer1,-99)
from generalinfo where gi_name = 'LocalTimeOption'


select @p_GMDelta = isnull(usr_GMTDelta,5)
,@p_DSTAppplies = case isnull(usr_DSTApplies,'Y') when 'y' then 0 else -1 end 
,@p_TZmins = isnull(usr_TZmins,0)
from ttsusers where usr_userid = @v_tmwuser

If @p_GMDelta is null
   Select @p_GMDelta  = isnull(ABS(cty_gmtdelta),5)
  ,@p_DSTAppplies = case isnull(cty_DSTapplies,'Y') when 'y' then 0 else -1 end 
  ,@p_TZmins = isnull(cty_TZMins,0)
from city where cty_code = @v_defaultCity

select @p_GMDelta  = isnull(@p_GMDelta  ,5)
,@p_DSTAppplies = isnull(@p_DSTAppplies,0)
,@p_TZmins = isnull(@p_TZmins,0)

GO
GRANT EXECUTE ON  [dbo].[getusertimezoneinfo] TO [public]
GO
