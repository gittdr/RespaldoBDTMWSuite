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
--Drop Proc  sp_Execute_Metric_OpsByAssetsXD_VentasMesual_ResultsNow
--exec sp_Execute_Metric_OpsByAssetsXD_VentasMensual_ResultsNow '2012-11-01', '2012-11-30'
CREATE procedure [dbo].[sp_Execute_Metric_OpsByAssetsXD_VentasMensual_ResultsNow]  @fechadia1mesant datetime, @fechaultmesant datetime  

AS
Declare @numerodedia int
--Declare @fechadia1mesant datetime
--Declare @fechaultmesant datetime
Declare @fechahoyini datetime
Declare @fechahoyfin datetime
Declare @ls_fechasabini varchar(20)
Declare @ls_fechaviefin varchar(20)
declare @fechahoy datetime
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)


--se que este reporte se correra cada dia Viernes.
-- por lo tanto para sacar el sabado y viernes se hace lo sig.
 
      -- select @fechadia1mesant = DATEADD(month,DATEDIFF(month, 0, GETDATE())-1,0)
       --select @fechaultmesant = DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) - 1

-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechadia1mesant,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechadia1mesant,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechadia1mesant,111)),9,2)

Select @fechadia1mesant = @ls_anio+@ls_mes+@ls_dia

Select @ls_anio = Substring((select CONVERT(char(10), @fechaultmesant,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechaultmesant,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechaultmesant,111)),9,2)

Select @fechaultmesant = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'

print cast(@fechadia1mesant as nvarchar(30)) + ' fechaFin: ' + cast(@fechaultmesant as nvarchar(30))

--Delete from MR_SessionID where ses_SPID=@@SPID 

delete LegHeaderSummary_VentasMensual
insert into [LegHeaderSummary_VentasMensual]
EXEC [sp_ReporteVentas_Metric_OpsByAssetsXD] 1,1,1,@fechadia1mesant,@fechaultmesant, 1, 9,@DateType='OrderStart',@Numerator='Revenue',@Denominator='DAY',@TypeOfTractorCount='Working',@TypeOfDriverCount='Working',@TypeOfTrailerCount='Working',@EliminateCarrierLoadsYN='Y',@UseTravelMilesForAllocationsYN='Y',@DispatchStatusList='STD,CMP',@IncludeMiscInvoicesYN='N',@ExcludeZeroRatedInvoicesYN='N',@BaseRevenueCategoryTLAFN='T',@SubtractFuelSurchargeYN='N',@ExcludeChargeTypeList='GST,TAX3,PST',@PreTaxYN='N',@ExcludePayTypeList='VIATIC,ANTOP,ANTER,ANTMAN',@WeightUOM='KGS',@VolumeUOM='LTR'


Update LegHeaderSummary_VentasMensual set Fechaini = @fechadia1mesant, Fechafin = @fechaultmesant

select  * from LegHeaderSummary_VentasMensual
where (RevType4 != 'UNKNOWN')

--exec sp_Execute_Metric_OpsByAssetsXD_VentasMensual_ResultsNow



































GO
