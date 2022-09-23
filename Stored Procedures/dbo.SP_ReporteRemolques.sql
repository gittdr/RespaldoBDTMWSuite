SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[SP_ReporteRemolques] (@Customer varchar(20), @token varchar(254), @status varchar(5)) 
as


if @status  = 'ALL'
begin 

 SELECT  
 trl_number as ID,  
 trailerprofile.trl_licnum as Placas,
 isnull(case when  trl_misc4 like '%Empty%' then 'Vacio'
     when trl_misc4  like '%Loaded%' then 'Cargado'
	 end,'N/A') as LoadEmpt,
case when  trl_misc4  like '%:Untether%' then 'Desenganchado'
     when trl_misc4  like '%:Tether%' then 'Enganchado'
	 end as Enganche,
case when  trl_misc4  like '%Motion:Moving%' then 'Movimiento'
     when trl_misc4  like '%Motion:Start%' then 'Iniciando'
	 when trl_misc4  like '%Motion:Idle%' then 'Ocioso'
	 when trl_misc4  like '%Motion:Stop%' then 'Detenido'
	 end as movimiento,
	 replace(isnull(substring(trl_misc4 ,charindex(']AT',trl_misc4 ,2)+3,1000), 'Remolque sin GPS instalado'),'tregadas en Tijuana Patio Hyundai','Remolque con GPS sin bateria') as Ubicacion,
	 replace(substring(substring(trl_misc4 ,charindex(']AT',trl_misc4 ,2)+3,1000),1,charindex('|',substring(trl_misc4 ,charindex(']AT',trl_misc4 ,2)+3,1000))),'|','') as Yard,
	 trl_gps_date as FechaGPS,
	 isnull(datediff(hh,trl_gps_date,getdate()),99999) as HorasUltPos,
	 cast(trl_gps_latitude as float)/3600 as Latitud,
	 cast(trl_gps_longitude as float)/3600 * -1 as Longitud,
	 Mapa = 
				'https://www.google.com.mx/maps/dir/' +
				CAST((trl_gps_latitude) / 3600.00 AS varchar)  + ',-' +
				CAST((trl_gps_longitude)/ 3600.00 AS varchar) 
  FROM trailerprofile			   
   WHERE trl_fleet = (select abbr from labelfile where labeldefinition = 'fleet' and name =  @Customer)
   and (select cmp_misc8 from company where cmp_id = replace(@Customer,'AUDI','SESE')) = @token
   order by HorasUltPos asc
   --select cmp_misc8 from company where cmp_id = 'SESE'
   


   end
   


GO
