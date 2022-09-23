SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
Store Procedure que el reporte del depto de comercial de ventas diario
Este SP ejecuta varios sp que componen el reporte de ventas, como son:
	* Venta de diario CMP, STD
	* Ventas que aún no están completada AVL
	* Ventas por lider y terminal
	* Grafica de lo que se acumula en la semana del día sabado al día actual
		-Para esta gráfica se crearon 7 sp's y 7 tablas uno por cada dia de la semana
		 para que se pueda obtener la venta total de los dias anteriores.
		 sp_TTSTMWAllocateRevVsPay_SSRS1_ABI_lider_sabado...
*/
-- 
--Drop Proc  sp_Execute_Metric_OpsByAssetsXD_VentasSemanal_ResultsNow
--exec sp_Execute_Metric_OpsByAssetsXD_VentasSemanal_ResultsNow '17-12-2012 05:08:40'
CREATE procedure [dbo].[sp_Execute_Metric_OpsByAssetsXD_VentasSemanal_ResultsNow] @fechaactual datetime
AS
Declare @numerodedia int
Declare @fechasabadoini datetime
Declare @fechaviernesfin datetime
Declare @Fechaini datetime
Declare @Fechafin datetime
Declare @ls_hora varchar(2)
Declare @ls_min varchar(2)
Declare @ls_seg varchar(2)
Declare @ls_fechasabini varchar(20)
Declare @ls_fechaviefin varchar(20)
declare @fechahoy datetime
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)



--se que este reporte se correra cada dia Lunes.
-- por lo tanto para sacar el sabado y viernes se hace lo sig.
 if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Monday'))<> 0)
begin
       --select @fechasabadoini = dateadd(day,-2,getdate())
       --select @fechaviernesfin = dateadd(day,0,getdate())
		select @fechasabadoini = dateadd(day,-2,@fechaactual)
		select @fechaviernesfin = dateadd(day,0,@fechaactual)
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Tuesday'))<> 0)
begin
       --select @fechasabadoini = dateadd(day,-3,getdate())
       --select @fechaviernesfin = dateadd(day,0,getdate())
		select @fechasabadoini = dateadd(day,-3,@fechaactual)
		select @fechaviernesfin = dateadd(day,0,@fechaactual)
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Wednesday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-4,@fechaactual)
       select @fechaviernesfin = dateadd(day,0,@fechaactual)

print @fechasabadoini
print @fechaviernesfin
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Thursday'))<> 0)
begin
       --select @fechasabadoini = dateadd(day,-5,getdate())
       --select @fechaviernesfin = dateadd(day,0,getdate())
	   select @fechasabadoini = dateadd(day,-5,@fechaactual)
       select @fechaviernesfin = dateadd(day,0,@fechaactual)

end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Friday'))<> 0)
begin
      -- select @fechasabadoini = dateadd(day,-6,getdate())
      -- select @fechaviernesfin = dateadd(day,0,getdate())
		select @fechasabadoini = dateadd(day,-6,@fechaactual)
		select @fechaviernesfin = dateadd(day,0,@fechaactual)
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Saturday'))<> 0)
begin
       --select @fechasabadoini = dateadd(day,0,getdate())
      -- select @fechaviernesfin = dateadd(day,0,getdate())
		select @fechasabadoini = dateadd(day,0,@fechaactual)
		select @fechaviernesfin = dateadd(day,0,@fechaactual)
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Sunday'))<> 0)
begin
      -- select @fechasabadoini = dateadd(day,-1,getdate())
       --select @fechaviernesfin = dateadd(day,0,getdate())
		select @fechasabadoini = dateadd(day,-1,@fechaactual)
		select @fechaviernesfin = dateadd(day,0,@fechaactual)
end


-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechasabadoini,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechasabadoini,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechasabadoini,111)),9,2)

Select @ls_fechasabini = @ls_anio+@ls_mes+@ls_dia

Select @ls_anio = Substring((select CONVERT(char(10), @fechaviernesfin,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechaviernesfin,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechaviernesfin,111)),9,2)
Select @ls_hora  = Substring((select CONVERT(char(19), @fechaactual,120)),12,2)
Select @ls_min  = Substring((select CONVERT(char(19), @fechaactual,120)),15,2)
Select @ls_seg  = Substring((select CONVERT(char(19), @fechaactual,120)),18,2)


Select @ls_fechaviefin = @ls_anio+@ls_mes+@ls_dia+ ' ' + @ls_hora +':' +@ls_min + ':'+@ls_seg

print @ls_fechasabini
print @ls_fechaviefin



--Delete from MR_SessionID where ses_SPID=@@SPID 

delete LegHeaderSummary_VentasSemanal
insert into [LegHeaderSummary_VentasSemanal]
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD] 1,1,1,@ls_fechasabini,@ls_fechaviefin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='STD,CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'


Update LegHeaderSummary_VentasSemanal set Fechaini = @ls_fechasabini, Fechafin = @ls_fechaviefin

select  * from LegHeaderSummary_VentasSemanal
where (RevType4 != 'UNKNOWN')

--exec sp_Execute_Metric_OpsByAssetsXD_VentasSemanal_ResultsNow

GO
