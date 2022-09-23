SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/********
exec sp_tractor_trailer_kms_jr  '2021-10-07T00:00:00', '2021-10-17T23:59:00', 'INTRA2501181256xTrFl33t'

*********/

CREATE proc [dbo].[sp_tractor_trailer_kms_jr] ( @fechainicio datetime, @fechafin datetime,@token varchar(254))

as



declare @TrcFlet xml

set @TrcFlet = 

(

select * from(
	select trc_number as Economico, 
	(select replace(replace(name,'&',' AND '),'/','') from labelfile where labeldefinition = 'fleet' and abbr=  trc_fleet) as flota,

isnull((select max(geo_odometro) from QSP.[dbo].[GeotabMeters] where geo_trcnum = tractorprofile.trc_number
  and geo_fecha between @fechainicio and  @fechafin
	  and @token = 'INTRA2501181256xTrFl33t')

,

isnull((select sum(stp_lgh_mileage) from stops where  stp_departure_status ='DNE' 
 and stp_number in
   (select stp_number from event where evt_tractor = trc_number
     and evt_enddate between @fechainicio and  @fechafin
	  and @token = 'INTRA2501181256xTrFl33t')


),0)

) as kms,

isnull(

(select case when max(geo_odometro) > 0 then 'Si'else 'No' end from QSP.[dbo].[GeotabMeters] where geo_trcnum = tractorprofile.trc_number
  and geo_fecha between @fechainicio and  @fechafin
	  and @token = 'INTRA2501181256xTrFl33t')

,'No') as Geotab


 from tractorprofile
where trc_status <> 'OUT'
) as q


FOR XML PATH ('Tractor'), root ('Tractors')

)

---- Trailers

+ 
(

select * from(
	select trl_number as EconomicoRem1, 
	(select replace(replace(name,'&',' AND '),'/','') from labelfile where labeldefinition = 'fleet' and abbr=  trl_fleet) as flota,

isnull((select max(geo_odometro) from QSP.[dbo].[GeotabMeters] where geo_trcnum = trailerprofile.trl_number
  and geo_fecha between @fechainicio and  @fechafin
	  and @token = 'INTRA2501181256xTrFl33t')

,

isnull((select sum(stp_lgh_mileage) from stops where  stp_departure_status ='DNE' 
 and stp_number in
   (select stp_number from event where evt_trailer1 = trl_number
     and evt_enddate between @fechainicio and  @fechafin
	  and @token = 'INTRA2501181256xTrFl33t')


),0)

) as kms,

isnull(

(select case when max(geo_odometro) > 0 then 'Si'else 'No' end from QSP.[dbo].[GeotabMeters] where geo_trcnum = trailerprofile.trl_number
  and geo_fecha between @fechainicio and  @fechafin
	  and @token = 'INTRA2501181256xTrFl33t')

,'No') as Geotab


 from trailerprofile
where trl_status <> 'OUT'
) as q2


FOR XML PATH ('Trailer'), root ('Trailers')

)

select @TrcFlet as TrcFleet
GO
