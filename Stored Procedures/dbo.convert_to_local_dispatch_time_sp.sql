SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE PROCEDURE [dbo].[convert_to_local_dispatch_time_sp]  (
	@p_city			int,
	@p_city_time	datetime output)
AS  

/**
 * 
 * NAME:
 * dbo.convert_to_local_dispatch_time_func
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Converts the local time at a city to the local dispatch office time.
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * na
 *
 * PARAMETERS:
 *	001 - @p_city int,
 *	002 - @p_city_time datetime
 *
 * REVISION HISTORY:
 * 06/28/07.01 PTS38117 - vjh - created Proc
 *
 **/

    
DECLARE   
	@V_GILocalTImeOption		varchar(20),    
	@v_LocalCityTZAdjFactor		int,  
	@InDSTFactor				int,  
	@DSTCountryCode				int ,
	@V_LocalGMTDelta			smallint,
	@v_LocalDSTCode				smallint,
	@V_LocalAddnlMins			smallint

if @p_city is null return
if @p_city = 0 return
  
/* Is local time option set (GI integer1 is the city code of the dispatch office) */   
select @V_GILocalTimeOption = Upper(isnull(gi_string1,''))   
from generalinfo where gi_name = 'LocalTimeOption'  
Select @V_GILocalTimeOption = isnull(@V_GILocalTimeOption,'')  
select @v_LocalCityTZAdjFactor = 0  

If @V_GILocalTimeOption = 'LOCAL'   
  BEGIN  
    /* if server is in different time zone that dipatch office there may be a few hours of error going in and out of DST */  
    select @DSTCountryCode = 0 /* if you want to work outside North America, set this value see proc ChangeTZ */  
    select @InDSTFactor = case dbo.InDst(getdate(),@DSTCountryCode) when 'Y' then 1 else 0 end  
    select @v_LocalCityTZAdjFactor = 0 
    exec getusertimezoneinfo @V_LocalGMTDelta output,@v_LocalDSTCode output,@V_LocalAddnlMins  output
    select @v_LocalCityTZAdjFactor = 
       ((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins
select @p_city_time =  dateadd(minute, -1 * (@v_LocalCityTZAdjFactor - ((isnull(cty_GMTDelta,5) + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end)))* 60) + isnull(cty_TZMins,0)), @p_city_time)  
from city
where cty_code = @p_city
  END  

GO
GRANT EXECUTE ON  [dbo].[convert_to_local_dispatch_time_sp] TO [public]
GO
