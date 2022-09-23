SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[AdjustDateForZoneShift]
 @P_origincity int, @p_Destcity int , @p_datetime datetime output

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
 * Pass an origin city, a destination city  and a datetime.  
 *    translate the date passed (valid in origin city time zone) to the destination city time zone

 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_Origincity    -- cty_code for the city we are coming form
 * 002 - @p_DestCity     -- cty_code for the city we are going to
 * 003 - @p_datetime    -- datetime coputed in the time zone of the origin city that we want to translate to the dest
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 3/20/07 DPETE PTS35747 DPETE  - Created stored proc for SR requireing all  trips to be adjusted for the time zone.

 *
 **/
 Declare @V_OrigTZ int,@v_OrigDSTCode int,@V_OrigAddnlMins int
 Declare @V_DestTZ int,@v_DestDSTCode int,@V_DestAddnlMins int

Select @V_OrigTZ = isnull(cty_gmtdelta,5),@v_OrigDSTCode = case isnull(cty_DSTapplies,'Y') when 'y' then 0 else -1 end ,@V_OrigAddnlMins = isnull(cty_TZMins,0)
from city where cty_code = @P_origincity


Select @V_DestTZ = isnull(cty_gmtdelta,5),@v_DestDSTCode = case isnull(cty_DSTapplies,'Y') when 'y' then 0 else -1 end ,@V_DestAddnlMins = isnull(cty_TZMins,0)
from city where cty_code = @P_destcity

select @p_datetime =  dbo.ChangeTZ(@p_datetime,@V_OrigTZ ,@v_OrigDSTCode,@V_OrigAddnlMins,@V_DestTZ ,@v_DestDSTCode ,@V_DestAddnlMins)

GO
GRANT EXECUTE ON  [dbo].[AdjustDateForZoneShift] TO [public]
GO
