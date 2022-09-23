SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_fuelaudittrc] (@economico varchar(20))
as
SELECT [economico]
      , cast([fecha_final] as datetime)  as fecha_final
      ,round([distancia_recorrida],2) as KmsOdo
	  ,(select isnull(sum(stp_ord_mileage),0) from tmwsuite.dbo.stops where  datediff(dd,stp_arrivaldate,fecha_Final) = 0 and lgh_number in (select lgh_number from tmwsuite..legheader where lgh_tractor = economico and lgh_outstatus not in ('CAN') )) KmsStops
      ,[combustible_inicial]
	  ,[combustible_final]
      ,[volumen_minimo]
      ,[volumen_minimo_fecha]
      ,[volumen_max]
      ,[volumen_max_fecha]
      ,[volumen_recargado]
      ,[volumen_descargado]
      ,[combustible_consumido]
      ,cast([rendimiento_litro] as float) as [rendimiento_litro]
	  ,(select isnull(sum(fp_quantity),0) from tmwsuite.dbo.fuelpurchased where trc_number = economico and datediff(dd,fp_date,fecha_final) = 0 )  as LtsCompra,
      [distancia_recorrida] / ([combustible_consumido] + ((select isnull(sum(fp_quantity),0) from tmwsuite.dbo.fuelpurchased where trc_number = economico and datediff(dd,fp_date,fecha_final) = 0 ) - [volumen_recargado])) as RendReal,
1-([rendimiento_litro] /  ([distancia_recorrida] / ([combustible_consumido] + ((select isnull(sum(fp_quantity),0) from tmwsuite.dbo.fuelpurchased where trc_number = economico and datediff(dd,fp_date,fecha_final) = 0 ) - [volumen_recargado])) )) as dif

  FROM [FUEL].[dbo].[intralix_getperformance1day]
  where 
  datediff(day,fecha_final,getdate()) <= 30
  and
  economico = @economico
GO
