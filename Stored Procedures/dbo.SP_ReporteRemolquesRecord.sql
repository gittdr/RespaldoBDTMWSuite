SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[SP_ReporteRemolquesRecord] (@Customer varchar(20), @token varchar(254), @eco varchar(10)) 
as

select ckc_asgnid as economico,
 ckc_date as fecha,
 ckc_comment as ubicacion,
 cast(ckc_latseconds as float) /3600 as latitud,
 cast(ckc_longseconds as float) /3600 * -1 as longitud,
 ckc_cityname as ciudad,
 ckc_state as estado,
  Mapa = 
				'https://www.google.com.mx/maps/dir/' +
				CAST((ckc_latseconds) / 3600.00 AS varchar)  + ',-' +
				CAST((ckc_longseconds)/ 3600.00 AS varchar) 
 
  from checkcall 
  where 
  ckc_asgnid = @eco
   and ckc_asgntype = 'TRL'
  and (select cmp_misc8 from company where cmp_id = replace(@Customer,'AUDI','SESE')) = @token

  order by fecha desc
GO
