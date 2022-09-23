SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vista_remolquesese] 

as

select 
'<ner:DtoGenericVehiclePosition>' as ini,

vehiculo = '<ner:VehicleId>'+trl_number+'</ner:VehicleId>'+
'<ner:DateTime>"' + convert(varchar,GETUTCDATE(),120) +'"</ner:DateTime>'+
'<ner:PositionDateTime>"' + convert(varchar,(isnull(DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), trl_gps_date),GETUTCDATE())),120) + '"<ner:PositionDateTime>'  +
'<ner:Latitude>'+cast(isnull(trl_gps_latitude / 3600.00 ,'19.2333333') as varchar(20))+'</ner:Latitude>'+
'<ner:Longitude>'+ cast(isnull(-1* (trl_gps_longitude/ 3600.00),'-97.7494444') as varchar(20))+ '</ner:Longitude>',
'</ner:DtoGenericVehiclePosition>' as fin
from trailerprofile
where trl_fleet = '13' and trl_gps_desc is not null




GO
