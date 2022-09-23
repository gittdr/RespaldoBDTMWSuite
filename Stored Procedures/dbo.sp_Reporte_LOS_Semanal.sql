SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
Store Procedure que el reporte del depto de comercial de LOS con parametros de la fecha de inicio, fin y cliente para cuando se requiera correr el reporte de un cliente en especifico y de una fecha en específico.

Este reporte por lo regular lo pide SACNORTE para mostrarlo a los de CEMS
13/03/2013
*/
-- 
--Drop Proc  sp_Reporte_LOS_Semanal
--exec sp_Reporte_LOS_Semanal '2013-03-08', '2013-03-13', 'HOMEDEP'
CREATE procedure [dbo].[sp_Reporte_LOS_Semanal] @fechaInicio datetime, @fechaFin datetime, @Billto varchar(8)
AS
Declare @numerodedia int
Declare @fechasabadoini datetime
Declare @fechaviernesfin datetime
Declare @ls_hora varchar(2)
Declare @ls_min varchar(2)
Declare @ls_seg varchar(2)
Declare @ls_fechasabini varchar(20)
Declare @ls_fechaviefin varchar(20)
declare @fechahoy datetime
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)



-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechaInicio,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechaInicio,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechaInicio,111)),9,2)

Select @ls_fechasabini = @ls_anio+@ls_mes+@ls_dia

Select @ls_anio = Substring((select CONVERT(char(10), @fechaFin,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechaFin,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechaFin,111)),9,2)
Select @ls_hora  = Substring((select CONVERT(char(19), @fechaFin,120)),12,2)
Select @ls_min  = Substring((select CONVERT(char(19), @fechaFin,120)),15,2)
Select @ls_seg  = Substring((select CONVERT(char(19), @fechaFin,120)),18,2)


Select @ls_fechaviefin = @ls_anio+@ls_mes+@ls_dia+ ' ' + @ls_hora +':' +@ls_min + ':'+@ls_seg

print @ls_fechasabini
print @ls_fechaviefin



----Delete from MR_SessionID where ses_SPID=@@SPID 
--
--delete LegHeaderSummary_VentasSemanal
--insert into [LegHeaderSummary_VentasSemanal]
--EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD] 1,1,1,@ls_fechasabini,@ls_fechaviefin, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='STD,CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'
--
--
--Update LegHeaderSummary_VentasSemanal set Fechaini = @ls_fechasabini, Fechafin = @ls_fechaviefin
--
--select  * from LegHeaderSummary_VentasSemanal
--where (RevType4 != 'UNKNOWN')
--
----exec sp_Execute_Metric_OpsByAssetsXD_VentasSemanal_ResultsNow
--

set DATEFIRST  6
select *,  CASE Lider  WHEN 'FR' THEN 'Abraham Soto'  WHEN 'GS' THEN 'Gisela Servín' WHEN 'GL' THEN 'Raymundo Almaguer' WHEN 'RA' THEN 'Roberto Águila' WHEN 'LA' THEN 'Lizeth Anaya' WHEN 'JZ' THEN 'Juan A. Zuppa' WHEN 'CHV' THEN 'Carlos Sánchez' WHEN 'IO' THEN 'Israel Orihuela' WHEN 'AM' THEN 'Denisse Mujica' WHEN 'DM' THEN 'Denisse Mujica' WHEN 'CVM' THEN 'Carlos Vázquez' WHEN 'FNG' THEN 'Carlos Vázquez' WHEN 'SV' THEN 'Jesús Huerta' WHEN 'JG' THEN 'Joaquín González' END AS nombreLider
from v_excepvsordenes
where Fecha between @ls_fechasabini and @ls_fechaviefin
--datepart(ww, @fechaInicio) >  datepart(ww, getdate())-2 and datepart(ww,@fechaFin)< datepart(ww, getdate()) and  year(fecha)= year(getdate())  
--semana > datepart(ww, getdate())-2 and semana < datepart(ww, getdate())  and  year(fecha)= year(getdate())  
AND proyecto != 'PORT' and Cliente = @Billto and ([Descripción Falla] != '')
order by día desc
GO
