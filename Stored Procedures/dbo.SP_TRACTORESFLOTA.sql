SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[SP_TRACTORESFLOTA]  (@token varchar(254))
--exec [dbo].[SP_TRACTORESFLOTA] 'INTRA2501181256xTrFl33t'

as

declare @FleetTrc xml

set @FleetTrc =

(
select  trc_number as eco,
(select name from labelfile where labeldefinition = 'fleet' and abbr = trc_Fleet) as flota
--,
--isnull((select max(geo_odometro) from QSP.[dbo].[GeotabMeters] where geo_trcnum = tractorprofile.trc_number
  --and @token = 'INTRA2501181256xTrFl33t')

--,

--isnull((select sum(stp_lgh_mileage) from stops where  stp_departure_status ='DNE' 
 --and stp_number in
   --(select stp_number from event where evt_tractor = trc_number
     -- and @token = 'INTRA2501181256xTrFl33t')


--),0)

--) as kms
from tractorprofile
where trc_status <> 'OUT' and trc_number <> 'UNKNOWN'  
and trc_fleet is not null
and (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_Fleet) is not null
and @token = 'INTRA2501181256xTrFl33t'
FOR XML PATH ('TRACTOR'), ROOT ('TRACTORES')

)



select @FleetTrc as FleetTrc


GO
