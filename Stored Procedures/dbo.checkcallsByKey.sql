SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[checkcallsByKey] (@lookupby varchar(20),@lookupkey  varchar(25),@LatDir char(1),@LongDir char(1)) as
/*

Created 1/15/05 DPETE 25189  Pass type odf lookup (O = order, M = Move, L = leg) plus the
   key for the type and the default direction for lat and long (ini setting)



*/
Select @LatDir = IsNull(@LatDir,'N')
Select @LongDir = IsNull(@LongDir,'W')


If @lookupby = 'M'
SELECT  checkcall.ckc_lghnumber   
  ,checkcall.ckc_asgntype   
  ,checkcall.ckc_asgnid 
  ,checkcall.ckc_tractor  
  ,checkcall.ckc_date
  ,checkcall.ckc_comment
  ,checkcall.ckc_cityname
  ,checkcall.ckc_state
  ,latitude = Convert(varchar(15),Convert(decimal(9,4),Round(IsNull(ckc_latseconds,0) / 3600.000,4)))  + @LatDir
  ,longitude = Convert(varchar(15),Convert(decimal(9,4),Round(IsNull(ckc_longseconds,0) / 3600.000,4)))  + @LongDir
  ,checkcall.ckc_vehicleignition
  ,checkcall.ckc_milesfrom
  ,checkcall.ckc_directionfrom 
  ,checkcall.ckc_updatedby
 
   FROM (Select Distinct Lgh_number From Stops Where mov_number = @lookupkey) LEGS
     Join  checkcall on checkcall.ckc_lghnumber = LEGS.lgh_number   
   Order BY ckc_date

If @lookupby = 'L'
SELECT  checkcall.ckc_lghnumber   
  ,checkcall.ckc_asgntype   
  ,checkcall.ckc_asgnid 
  ,checkcall.ckc_tractor  
  ,checkcall.ckc_date
  ,checkcall.ckc_comment
  ,checkcall.ckc_cityname
  ,checkcall.ckc_state
  ,latitude = Convert(varchar(15),Convert(decimal(9,4),Round(IsNull(ckc_latseconds,0) / 3600.000,4)))  + @LatDir
  ,longitude = Convert(varchar(15),Convert(decimal(9,4),Round(IsNull(ckc_longseconds,0) / 3600.000,4)))  + @LongDir
  ,checkcall.ckc_vehicleignition
  ,checkcall.ckc_milesfrom
  ,checkcall.ckc_directionfrom 
  ,checkcall.ckc_updatedby

   FROM checkcall   
   WHERE   checkcall.ckc_lghnumber = @lookupkey
   Order BY ckc_date

If @lookupby = 'O'
SELECT  checkcall.ckc_lghnumber   
  ,checkcall.ckc_asgntype   
  ,checkcall.ckc_asgnid 
  ,checkcall.ckc_tractor  
  ,checkcall.ckc_date
  ,checkcall.ckc_comment
  ,checkcall.ckc_cityname
  ,checkcall.ckc_state
  ,latitude = Convert(varchar(15),Convert(decimal(9,4),Round(IsNull(ckc_latseconds,0) / 3600.000,4)))  + @LatDir
  ,longitude = Convert(varchar(15),Convert(decimal(9,4),Round(IsNull(ckc_longseconds,0) / 3600.000,4)))  + @LongDir
  ,checkcall.ckc_vehicleignition
  ,checkcall.ckc_milesfrom
  ,checkcall.ckc_directionfrom 
  ,checkcall.ckc_updatedby
 
   FROM (Select Distinct lgh_number From stops where mov_number in (Select distinct mov_number From stops Where ord_hdrnumber = @LookupKey)) LEGS
    Join checkcall   on checkcall.ckc_lghnumber = LEGS.lgh_number
   Order BY ckc_date

GO
GRANT EXECUTE ON  [dbo].[checkcallsByKey] TO [public]
GO
