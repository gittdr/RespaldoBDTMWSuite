SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE FUNCTION [dbo].[convert_to_local_dispatch_time_func]  (
	@p_city			int,
	@p_city_time	datetime,
	@p_getdate		datetime)
	returns datetime
AS  
begin
/**
 * 
 * NAME:
 * dbo.convert_to_local_dispatch_time_func
 *
 * TYPE:
 * Function
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
 * 06/28/07.01 PTS38117 - vjh - created function
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
DECLARE @v_tmwuser varchar (255),@v_DefaultCity int --from getusertimezoneinfo
DECLARE @temp_user varchar (255) --from gettmwuser
if @p_city is null return @p_city_time
if @p_city = 0 return @p_city_time
  
/* Is local time option set (GI integer1 is the city code of the dispatch office) */   
select @V_GILocalTimeOption = Upper(isnull(gi_string1,''))   
from generalinfo where gi_name = 'LocalTimeOption'  
Select @V_GILocalTimeOption = isnull(@V_GILocalTimeOption,'')  
select @v_LocalCityTZAdjFactor = 0  

If @V_GILocalTimeOption = 'LOCAL'   
  BEGIN  
	/* if server is in different time zone that dipatch office there may be a few hours of error going in and out of DST */  
	select @DSTCountryCode = 0 /* if you want to work outside North America, set this value see proc ChangeTZ */  
	select @InDSTFactor = case dbo.InDst(@p_getdate,@DSTCountryCode) when 'Y' then 1 else 0 end  
	select @v_LocalCityTZAdjFactor = 0 
	--SQL 2000 does not allow procs to be called from within a function.  So I am incouding the code here.
	-- begin exec getusertimezoneinfo @V_LocalGMTDelta output,@v_LocalDSTCode output,@V_LocalAddnlMins  output
		-- begin exec gettmwuser @v_tmwuser output
			SELECT @temp_user = suser_sname()
			IF charindex ('\', @temp_user) > 0
			BEGIN
				SELECT @v_tmwuser = Max (usr_userid)
				FROM ttsusers
				WHERE usr_windows_userid = suser_sname()
				IF @v_tmwuser IS NULL or @v_tmwuser='' SELECT @v_tmwuser = @temp_user
			END
			ELSE
			BEGIN
				SELECT @v_tmwuser = @temp_user	
			END
			SELECT @v_tmwuser = Right (@v_tmwuser, 20)
			SELECT @v_tmwuser = Rtrim (@v_tmwuser)
		-- end exec gettmwuser
		select @v_defaultCity = isnull(gi_integer1,-99)
		from generalinfo where gi_name = 'LocalTimeOption'
		select @V_LocalGMTDelta = isnull(usr_GMTDelta,5)
		,@v_LocalDSTCode = case isnull(usr_DSTApplies,'Y') when 'y' then 0 else -1 end 
		,@V_LocalAddnlMins = isnull(usr_TZmins,0)
		from ttsusers where usr_userid = @v_tmwuser
		If @V_LocalGMTDelta is null
		   Select @V_LocalGMTDelta  = isnull(ABS(cty_gmtdelta),5)
		  ,@v_LocalDSTCode = case isnull(cty_DSTapplies,'Y') when 'y' then 0 else -1 end 
		  ,@V_LocalAddnlMins = isnull(cty_TZMins,0)
		from city where cty_code = @v_defaultCity
		select @V_LocalGMTDelta  = isnull(@V_LocalGMTDelta  ,5)
		,@v_LocalDSTCode = isnull(@v_LocalDSTCode,0)
		,@V_LocalAddnlMins = isnull(@V_LocalAddnlMins,0)
	-- end exec getusertimezoneinfo
	select @v_LocalCityTZAdjFactor = 
		((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins
	select @p_city_time =  dateadd(minute, -1 * (@v_LocalCityTZAdjFactor - ((isnull(cty_GMTDelta,5) + (@InDSTFactor * (case cty_DSTApplies when 'Y' then 0 else +1 end)))* 60) + isnull(cty_TZMins,0)), @p_city_time)  
	from city
	where cty_code = @p_city
  END  
  return @p_city_time
end
GO
GRANT EXECUTE ON  [dbo].[convert_to_local_dispatch_time_func] TO [public]
GO
