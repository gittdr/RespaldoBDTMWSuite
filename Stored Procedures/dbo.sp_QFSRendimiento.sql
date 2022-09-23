SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--exec sp_QFSRendimiento  '09-01-2012', '09-05-2012'



CREATE PROCEDURE [dbo].[sp_QFSRendimiento]  @fechaini datetime, @fechafin datetime
AS

DECLARE	
	@V_unidad		        varchar(500),
	@V_distancia			int,
	@V_fuelusedroll			int


DECLARE @TTQfs_Rendimientos TABLE(
		TTL_unidad              varchar(500) not null,
        TTL_viajes              integer NULL,
		TTL_distancia		    integer  NULL,
		TTL_fuelusedroll		integer NULL,
        TTL_rendimiento         float(2) NULL)

SET NOCOUNT ON



BEGIN

INSERT Into @TTQfs_Rendimientos 

--unidad 
SELECT     displayName,

--viajes
(select(count(tripid))from qsp.dbo.QFSactivityems 
where  qsp.dbo.QFSVehicles.vehicleID = qsp.dbo.QFSactivityems.vehicleID
and month(qsp.dbo.QFSactivityems.startDateTime) between month(@fechaini) and month(@fechafin) 
and year(qsp.dbo.QFSactivityems.startDateTime) between year(@fechaini) and year(@fechafin)
and day(qsp.dbo.QFSactivityems.startDateTime) between day(@fechaini) and day(@fechafin)),


--distancia
(select isnull(sum(distance/10),0) from qsp.dbo.QFSactivityems 
where  qsp.dbo.QFSVehicles.vehicleID = qsp.dbo.QFSactivityems.vehicleID
and month(qsp.dbo.QFSactivityems.startDateTime) between month(@fechaini) and month(@fechafin) 
and year(qsp.dbo.QFSactivityems.startDateTime) between year(@fechaini) and year(@fechafin)
and day(qsp.dbo.QFSactivityems.startDateTime) between day(@fechaini) and day(@fechafin)),

--litros
(select isnull(sum(fuelusedroll),0) from qsp.dbo.QFSactivityems 
where  qsp.dbo.QFSVehicles.vehicleID = qsp.dbo.QFSactivityems.vehicleID
and month(qsp.dbo.QFSactivityems.startDateTime) between month(@fechaini) and month(@fechafin) 
and year(qsp.dbo.QFSactivityems.startDateTime) between year(@fechaini) and year(@fechafin)
and day(qsp.dbo.QFSactivityems.startDateTime) between day(@fechaini) and day(@fechafin)),

--rendimiento
case when   (select isnull(sum(fuelusedroll),0) from qsp.dbo.QFSactivityems 
where  qsp.dbo.QFSVehicles.vehicleID = qsp.dbo.QFSactivityems.vehicleID
and month(qsp.dbo.QFSactivityems.startDateTime) between month(@fechaini) and month(@fechafin) 
and year(qsp.dbo.QFSactivityems.startDateTime) between year(@fechaini) and year(@fechafin)
and day(qsp.dbo.QFSactivityems.startDateTime) between day(@fechaini) and day(@fechafin))
 <> 0 then

cast((select isnull(sum(cast((distance/10) as float(2))),0) from qsp.dbo.QFSactivityems
 where  qsp.dbo.QFSVehicles.vehicleID = qsp.dbo.QFSactivityems.vehicleID
and month(qsp.dbo.QFSactivityems.startDateTime) between month(@fechaini) and month(@fechafin) 
and year(qsp.dbo.QFSactivityems.startDateTime) between year(@fechaini) and year(@fechafin)
and day(qsp.dbo.QFSactivityems.startDateTime) between day(@fechaini) and day(@fechafin))
 /
(select replace(isnull(sum(fuelusedroll),0),0,1) from qsp.dbo.QFSactivityems
 where  qsp.dbo.QFSVehicles.vehicleID = qsp.dbo.QFSactivityems.vehicleID
and month(qsp.dbo.QFSactivityems.startDateTime) between month(@fechaini) and month(@fechafin) 
and year(qsp.dbo.QFSactivityems.startDateTime) between year(@fechaini) and year(@fechafin)
and day(qsp.dbo.QFSactivityems.startDateTime) between day(@fechaini) and day(@fechafin))
as float(2)) else 0 end 

FROM         qsp.dbo.QFSVehicles


--select * from @TTQfs_Rendimientos

select  TTL_unidad, TTL_viajes, TTL_distancia, TTL_fuelusedroll, TTL_rendimiento, --trc_number, abbr,name,
Case abbr when (select abbr='01')then 'ABIERTO'  when  (select abbr='08') then 'ABIERTO'  when '05' then 'FULL SURESTE' when '20' then 'FULL SURESTE' else UPPER(name)  end as Flota2
from @TTQfs_Rendimientos
left outer join tractorprofile on TTL_Unidad = trc_number
left outer join labelfile on trc_fleet = abbr
 where labeldefinition = 'Fleet' and (trc_number is not NULL) and (name != 'UNKNOWN') 
and TTL_Rendimiento != 0

END --1 Principal





GO
