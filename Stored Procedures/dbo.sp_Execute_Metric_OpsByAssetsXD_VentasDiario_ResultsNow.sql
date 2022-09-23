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
--Drop Proc  sp_Execute_Metric_OpsByAssetsXD_VentasDiario_ResultsNow
--exec sp_Execute_Metric_OpsByAssetsXD_VentasDiario_ResultsNow '12/11/2012 05:08:40'
CREATE procedure [dbo].[sp_Execute_Metric_OpsByAssetsXD_VentasDiario_ResultsNow] @fechaactual datetime

AS
Declare @fechahoy datetime
Declare @fechamanana datetime
Declare @Fechaini datetime
Declare @Fechafin datetime
Declare @ls_fechaini varchar(20)
Declare @ls_fechafin varchar(20)
Declare @ls_fechaini2 varchar(20)
Declare @ls_fechafin2 varchar(20)
Declare @ls_dia varchar(2)
Declare @ls_hora varchar(2)
Declare @ls_min varchar(2)
Declare @ls_seg varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)
Declare @fechalunesini datetime
Declare @fechamartesini datetime
Declare @fechamiercolesini datetime
Declare @fechajuevesini datetime
Declare @fechaviernesini datetime
Declare @fechasabadoini datetime
Declare @fechadomingoini datetime
Declare @fechahoyini datetime
Declare @fechahoyfin datetime
Declare @ls_fechaliderini varchar(20)
Declare @ls_fechaliderfin varchar(20)

select @fechahoy = @fechaactual
select @fechamanana = @fechaactual + 1

Print 'Fechas hoy y mañana sin formato'
print @fechahoy
print @fechamanana

-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)
Select @ls_hora  = Substring((select CONVERT(char(19), @fechahoy,120)),12,2)
Select @ls_min  = Substring((select CONVERT(char(19), @fechahoy,120)),15,2)
Select @ls_seg  = Substring((select CONVERT(char(19), @fechahoy,120)),18,2)



Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'

print 'Fechas Ini y Fin'
print @ls_fechaini
print @ls_fechafin

Select @ls_fechaliderini = @ls_fechaini
Select @ls_fechaliderfin = @ls_fechaliderini + ' ' + @ls_hora + ':' + @ls_min + ':' + @ls_seg

print 'hora y min'
print @ls_fechaliderini
print @ls_fechaliderfin

--Fecha para sacar la venta del dia de mañana
Select @ls_anio = Substring((select CONVERT(char(10), @fechamanana,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechamanana,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechamanana,111)),9,2)

Select @ls_fechaini2 = @ls_anio+@ls_mes+@ls_dia
Select @ls_fechafin2 = @ls_anio+@ls_mes+@ls_dia+ ' 23:59:59'

print 'Fechas Ini2 y Fin2'
print @ls_fechaini2
print @ls_fechafin2

Delete from MR_SessionID where ses_SPID=@@SPID 

delete LegHeaderSummary_Ventasdiario
insert into [LegHeaderSummary_Ventasdiario]
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD] 1,1,1,@ls_fechaliderini,@ls_fechaliderfin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='PLN,STD,CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

Update LegHeaderSummary_Ventasdiario set Fechaini = @ls_fechaliderini, Fechafin = @ls_fechaliderfin


select * from LegHeaderSummary_Ventasdiario
where RevType4 not in ('UNKNOWN')

delete LegHeaderSummary_Ventasdiario_Available
insert into [LegHeaderSummary_Ventasdiario_Available]
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD] 1,1,1,@ls_fechaliderini,@ls_fechaliderfin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='AVL',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

Update LegHeaderSummary_Ventasdiario set Fechaini = @ls_fechaliderini, Fechafin = @ls_fechaliderfin

--select * from LegHeaderSummary_Ventasdiario_Available

delete LegHeaderSummary_Ventasdiario_Available_DiaSiguiente
insert into [LegHeaderSummary_Ventasdiario_Available_DiaSiguiente]
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD] 1,1,1,@ls_fechaini2,@ls_fechafin2, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='AVL',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'


select * from LegHeaderSummary_Ventasdiario_Available_DiaSiguiente

--EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD] 1,1,1,'2012-12-01 00:00:01','2012-12-01 11:59:59', 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='PLN,STD,CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'


----------------------------------------------------------------------------------------------------
--Esta parte es para obtener la venta por dias
-- Fecha del día de Hoy

if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Monday'))<> 0)
begin
delete LegHeaderSummary_Ventasdiario_Sabado
delete LegHeaderSummary_Ventasdiario_Domingo
delete LegHeaderSummary_Ventasdiario_Lunes
delete LegHeaderSummary_Ventasdiario_Martes
delete LegHeaderSummary_Ventasdiario_Miercoles
delete LegHeaderSummary_Ventasdiario_Jueves
delete LegHeaderSummary_Ventasdiario_Viernes 

		Select @fechasabadoini =  dateadd(day,-2,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechasabadoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechasabadoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechasabadoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Sabado: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Sabado
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
		
		Select @fechadomingoini = dateadd(day,-1,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechadomingoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechadomingoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechadomingoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Domingo: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Domingo
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Lunes: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Lunes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
end

else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Tuesday'))<> 0)
begin

delete LegHeaderSummary_Ventasdiario_Sabado
delete LegHeaderSummary_Ventasdiario_Domingo
delete LegHeaderSummary_Ventasdiario_Lunes
delete LegHeaderSummary_Ventasdiario_Martes
delete LegHeaderSummary_Ventasdiario_Miercoles
delete LegHeaderSummary_Ventasdiario_Jueves
delete LegHeaderSummary_Ventasdiario_Viernes 

		Select @fechasabadoini =  dateadd(day,-3,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechasabadoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechasabadoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechasabadoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Sabado: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Sabado
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
		
		Select @fechadomingoini = dateadd(day,-2,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechadomingoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechadomingoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechadomingoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Domingo: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Domingo
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @fechalunesini = dateadd(day,-1,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechalunesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechalunesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechalunesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Lunes: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Lunes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
		
		Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Martes: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Martes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
end


else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Wednesday'))<> 0)
begin

--Borrar la información de las tablas para que en cada ejecucion mande la más actualizada
delete LegHeaderSummary_Ventasdiario_Sabado
delete LegHeaderSummary_Ventasdiario_Domingo
delete LegHeaderSummary_Ventasdiario_Lunes
delete LegHeaderSummary_Ventasdiario_Martes
delete LegHeaderSummary_Ventasdiario_Miercoles
delete LegHeaderSummary_Ventasdiario_Jueves
delete LegHeaderSummary_Ventasdiario_Viernes 

		Select @fechasabadoini =  dateadd(day,-4,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechasabadoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechasabadoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechasabadoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Sabado: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Sabado
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
		
		Select @fechadomingoini = dateadd(day,-3,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechadomingoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechadomingoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechadomingoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Domingo: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Domingo
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @fechalunesini = dateadd(day,-2,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechalunesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechalunesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechalunesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Lunes: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Lunes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
		
		Select @fechamartesini = dateadd(day,-1,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechamartesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechamartesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechamartesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Martes: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Martes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Miercoles: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Miercoles
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
end


else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Thursday'))<> 0)
begin

delete LegHeaderSummary_Ventasdiario_Sabado
delete LegHeaderSummary_Ventasdiario_Domingo
delete LegHeaderSummary_Ventasdiario_Lunes
delete LegHeaderSummary_Ventasdiario_Martes
delete LegHeaderSummary_Ventasdiario_Miercoles
delete LegHeaderSummary_Ventasdiario_Jueves
delete LegHeaderSummary_Ventasdiario_Viernes 

		Select @fechasabadoini =  dateadd(day,-5,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechasabadoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechasabadoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechasabadoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Sabado: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Sabado
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
		
		Select @fechadomingoini = dateadd(day,-4,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechadomingoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechadomingoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechadomingoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Domingo: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Domingo
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @fechalunesini = dateadd(day,-3,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechalunesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechalunesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechalunesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Lunes: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Lunes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
		
		Select @fechamartesini = dateadd(day,-2,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechamartesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechamartesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechamartesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Martes: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Martes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @fechamiercolesini = dateadd(day,-1,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechamiercolesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechamiercolesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechamiercolesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Miercoles: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Miercoles
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Jueves: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Jueves
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

--exec sp_reporteoperaciones_abi_diario

end

--exec sp_Execute_Metric_OpsByAssetsXD_VentasDiario_ResultsNow

else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Friday'))<> 0)
begin

delete LegHeaderSummary_Ventasdiario_Sabado
delete LegHeaderSummary_Ventasdiario_Domingo
delete LegHeaderSummary_Ventasdiario_Lunes
delete LegHeaderSummary_Ventasdiario_Martes
delete LegHeaderSummary_Ventasdiario_Miercoles
delete LegHeaderSummary_Ventasdiario_Jueves
delete LegHeaderSummary_Ventasdiario_Viernes 

		Select @fechasabadoini =  dateadd(day,-6,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechasabadoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechasabadoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechasabadoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Sabado: ' + @ls_fechaini +',' +  @ls_fechafin

insert into LegHeaderSummary_Ventasdiario_Sabado
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

--select sum(SelectedRevenue) from LegHeaderSummary_Ventasdiario_Sabado

		Select @fechadomingoini = dateadd(day,-5,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechadomingoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechadomingoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechadomingoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Domingo: ' + @ls_fechaini +',' +  @ls_fechafin

insert into LegHeaderSummary_Ventasdiario_Domingo
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @fechalunesini = dateadd(day,-4,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechalunesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechalunesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechalunesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Lunes: ' + @ls_fechaini +',' +  @ls_fechafin

insert into LegHeaderSummary_Ventasdiario_Lunes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
		
		Select @fechamartesini = dateadd(day,-3,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechamartesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechamartesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechamartesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Martes: ' + @ls_fechaini +',' +  @ls_fechafin

insert into LegHeaderSummary_Ventasdiario_Martes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @fechamiercolesini = dateadd(day,-2,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechamiercolesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechamiercolesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechamiercolesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Miercoles: ' + @ls_fechaini +',' +  @ls_fechafin

insert into LegHeaderSummary_Ventasdiario_Miercoles
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @fechajuevesini = dateadd(day,-1,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechajuevesini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechajuevesini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechajuevesini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Jueves: ' + @ls_fechaini +',' +  @ls_fechafin

insert into LegHeaderSummary_Ventasdiario_Jueves
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'viernes: ' + @ls_fechaini +',' +  @ls_fechafin

insert into LegHeaderSummary_Ventasdiario_Viernes
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

end

else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Saturday'))<> 0)
begin

delete LegHeaderSummary_Ventasdiario_Sabado
delete LegHeaderSummary_Ventasdiario_Domingo
delete LegHeaderSummary_Ventasdiario_Lunes
delete LegHeaderSummary_Ventasdiario_Martes
delete LegHeaderSummary_Ventasdiario_Miercoles
delete LegHeaderSummary_Ventasdiario_Jueves
delete LegHeaderSummary_Ventasdiario_Viernes 

		Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Sabado: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Sabado
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
end

else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Sunday'))<> 0)
begin

delete LegHeaderSummary_SSRS_ABI_lider_sabado
delete LegHeaderSummary_SSRS_ABI_lider_domingo
delete LegHeaderSummary_SSRS_ABI_lider_lunes
delete LegHeaderSummary_SSRS_ABI_lider_martes
delete LegHeaderSummary_SSRS_ABI_lider_miercoles
delete LegHeaderSummary_SSRS_ABI_lider_jueves
delete LegHeaderSummary_SSRS_ABI_lider_viernes 

		Select @fechasabadoini =  dateadd(day,-1,getdate())
		Select @ls_anio = Substring((select CONVERT(char(10), @fechasabadoini,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechasabadoini,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechasabadoini,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Sabado: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Sabado
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'

		Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
		Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
		Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

		Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
		Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
		Print 'Domingo: ' + @ls_fechaini +',' +  @ls_fechafin
insert into LegHeaderSummary_Ventasdiario_Domingo
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD_Grafica] 1,1,1,@ls_fechaini,@ls_fechafin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
end


--execute sp_reporteoperaciones_abi_diario
Delete from MR_SessionID where ses_SPID=@@SPID

































GO
