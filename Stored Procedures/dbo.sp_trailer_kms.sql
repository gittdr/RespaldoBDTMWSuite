SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/********
exec sp_trailer_kms  '2021-07-01T00:00:00', '2021-07-30T23:59:00', 'INTRA2501181256xTrFl33t'




*********/


CREATE proc [dbo].[sp_trailer_kms] ( @fechainicio datetime, @fechafin datetime,@token varchar(254))

as



declare @TrlFlet xml

set @TrlFlet = 




(

select * from(
select trl_number as Economico, 
(select replace(name,'&',' AND ') from labelfile where labeldefinition = 'fleet' and abbr=  trl_fleet) as flota,

isnull((select sum(stp_lgh_mileage) from stops where  stp_departure_status ='DNE' 
 and stp_number in
   (select stp_number from event where evt_trailer1 = trl_number
     and evt_enddate between @fechainicio and  @fechafin
	  and @token = 'INTRA2501181256xTrFl33t')
),0) as kms

 from trailerprofile
where trl_status <> 'OUT'
) as q
where kms > 0

FOR XML PATH ('Trailer'), root ('Trailers')

)



select @TrlFlet as TrlFleet
GO
