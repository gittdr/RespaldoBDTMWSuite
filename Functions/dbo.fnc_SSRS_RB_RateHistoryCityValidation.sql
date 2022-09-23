SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
create function [dbo].[fnc_SSRS_RB_RateHistoryCityValidation]      
 (@SearchType varchar(1),      
  @OriginCityName as varchar(200),        
  @DestCityName as varchar(200)      
  )        
        
returns varchar(max)        
          
as      
      
begin      
 declare @msg as varchar(max)      
 declare @OriginCityCode as int        
 declare @OriginCityLat as dec(12,4)        
 declare @OriginCityLong as dec(12,4)        
 declare @DestCityCode as int        
 declare @DestCityLat as dec(12,4)        
 declare @DestCityLong as dec(12,4)        
      
 -- select  dbo.fnc_SSRS_RB_RateHistoryCityValidation('C','Cleveland,OH','C')
      
 set @msg = ''      
      
 if @SearchType = 'C'       
  begin        
   select top 1         
    @OriginCityCode = cty_code,        
    @OriginCityLat = cty_latitude,        
    @OriginCityLong = cty_longitude        
   from city where ltrim(RTRIM(cty_name)) + ',' + LTRIM(rtrim(cty_state)) = @OriginCityName  
           
   select top 1         
    @DestCityCode = cty_code,        
    @DestCityLat = cty_latitude,        
    @DestCityLong = cty_longitude        
   from city where ltrim(RTRIM(cty_name)) + ',' + LTRIM(rtrim(cty_state))  = @DestCityName 
  end      
 else      
  begin        
   select top 1         
    @OriginCityCode = cty_code,        
    @OriginCityLat = cty_latitude,        
    @OriginCityLong = cty_longitude        
   from city where      
    cty_code = (select top 1 cmp_city from company where cmp_zip = @OriginCityName)      
           
   select top 1         
    @DestCityCode = cty_code,        
    @DestCityLat = cty_latitude,        
    @DestCityLong = cty_longitude        
   from city where      
    cty_code = (select top 1 cmp_city from company where cmp_zip = @DestCityName)      
  end      
        
 if @OriginCityCode is null      
  set @msg = @msg + char(10) + char(13) + 'Error!!! Origin City not found!'      
    else      
  begin        
   if @OriginCityLat is null      
    set @msg = @msg + char(10) + char(13) + 'Error!!! Origin Latitude not set! Please set using file maintenance.'      
   if @OriginCityLong is null      
    set @msg = @msg + char(10) + char(13) + 'Error!!! Origin Longitude not set! Please set using file maintenance.'      
  end      
       
 if @DestCityCode is null      
  set @msg = @msg + char(10) + char(13) + 'Error!!! Dest City not found!'      
    else      
  begin        
   if @DestCityLat is null      
    set @msg = @msg + char(10) + char(13) +  'Error!!! Dest Latitude not set! Please set using file maintenance.'      
   if @DestCityLong is null      
    set @msg =  @msg + char(10) + char(13) + ' Error!!! Dest Longitude not set! Please set using file maintenance.'      
  end      
        
        
        
 return @msg      
        
end      
  
  
GO
