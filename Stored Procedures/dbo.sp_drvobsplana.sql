SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[sp_drvobsplana] (@fini datetime, @ffin datetime)

as

select mpp_id as Operador, dro_observationdt as Fecha,
(select (select name from labelfile where labeldefinition = 'fleet' and abbr =  mpp_fleet)
 from manpowerprofile where manpowerprofile.mpp_id =driverobservation.mpp_id)  as Proyecto, dro_code as CodigoObservacion, 
 
 
case dro_Code 
when 'EXVEL' then 'Exceso Velocidad'
when 'EXCVE' then 'Exceso Velocidad'
when 'INCPR' then 'Proceso' 
when NULL then 'NA'
when 'DMTELE' then 'Dispositivo Telemetria'
when 'SINRE' then 'Siniestro Relevante'
when 'HABMAN' then 'Habitos de Manejo'
when 'VIATIR' then 'No se presento'
when 'TEMP' then 'Temporal'
end as Observacion,
road_conditions as CodigoArea,
(select name from labelfile where labeldefinition = 'RoadSurface' and abbr = road_conditions) as Area, dro_points,dro_observedby as RegistradoPor,
dro_description as ComentariosArea, dro_drivercomments ComentariosOperador  from driverobservation
where dro_observationdt  between @fini and @ffin



GO
