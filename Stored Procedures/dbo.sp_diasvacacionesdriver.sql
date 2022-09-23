SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_diasvacacionesdriver] @driver varchar(20)

as


select 'Dias vacaciones: ' + cast(dias_vacaciones as varchar(10)) +  ' Dias tomados: ' + cast(dias_tomados as varchar(10)) +
 ' Dias disponibles: ' + cast(dias_vacaciones- dias_tomados  as varchar(10)) as Vacaciones from tdrsilt.dbo.vista_vacacionesoper
where id_personal = (select mpp_otherid  from manpowerprofile where mpp_id= @driver)


--exec sp_diasvacacionesdriver 'FLOPe'
GO
