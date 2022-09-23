SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [dbo].[vista_kmsxmttto]

as


SELECT
t.displayname  as tractor,
cumulativeodometerkm + CalibrationOdometerKm as odocalib,
m.kms_servicio_ultimo ultserv,
m.kms_servicio_sig sigserv,
m.fecha_servicio_sig as fsigserv,
(m.kms_servicio_sig -(cumulativeodometerkm + CalibrationOdometerKm))  as paraserv


  FROM [QSP].[dbo].[navman_ic_api_vehiclesnapshot] r
  left join [QSP].[dbo].navman_ic_api_vehicle t on r.VehicleID = t.VehicleID
  left join [tdrsilt].[dbo].[mtto_unidades] m on id_unidad = (select displayname from [QSP].[dbo].navman_ic_api_vehicle o where r.VehicleID = o.VehicleID)
  where m.id_tipo_unidad = 1
  

 -- select * from vista_kmsxmttto

GO
