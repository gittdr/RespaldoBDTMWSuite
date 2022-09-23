SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO





CREATE       Procedure [dbo].[DriverAwareSuite_GetCheckCallsForDriver] (@DriverID varchar(255))
As

Set NOCount On

Select ckc_asgnid as [Driver],	
       ckc_tractor as [Tractor ID],
       ckc_date as [GPS Date],
       ckc_comment as [GPS],
       [City/State] = (select cty_nmstct from city (NOLOCK) where cty_code = ckc_city),
       [Latitude] = ckc_latseconds,
       [Longitude] = ckc_longseconds,
       ckc_mileage as Miles

From   checkcall (NOLOCK)
Where  ckc_date >= DateAdd(day,-14,getdate())
       And
       ckc_asgnid = @DriverID
       And
       ckc_asgntype = 'DRV'

order by ckc_date desc























GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetCheckCallsForDriver] TO [public]
GO
