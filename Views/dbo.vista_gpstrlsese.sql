SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE view [dbo].[vista_gpstrlsese]
as


		SELECT 
		
		DaTime = GETUTCDATE(),
		Latitude=cast((trl_gps_latitude / 3600.00 ) as varchar(20)),
		Longitude= cast((-1* (trl_gps_longitude/ 3600.00)) as varchar(20)),
		--Ubicacion = trl_gps_desc,
		PositionDateTime = convert(varchar,(isnull(DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), trl_gps_date),GETUTCDATE())),126)  ,
		VehicleId = trl_number
		--,Placas = trl_licnum


		from trailerprofile
		where trl_fleet = '13' and trl_gps_desc is not null
		and datediff(MINUTE,trl_gps_date,getdate()) < 30





GO
