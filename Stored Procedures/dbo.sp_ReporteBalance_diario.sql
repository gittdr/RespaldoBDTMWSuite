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
--Drop Proc  sp_reporteoperaciones_abi_diario
--exec sp_ReporteBalance_diario
CREATE procedure [dbo].[sp_ReporteBalance_diario]
AS
Declare @fechahoy datetime
Declare @fechamanana datetime
Declare @ls_fechaini varchar(20)
Declare @ls_fechafin varchar(20)
Declare @ls_fechaini2 varchar(20)
Declare @ls_fechafin2 varchar(20)
Declare @ls_dia varchar(2)
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

select @fechahoy = getdate()
select @fechamanana = getdate()+1

-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia
Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'

Select @ls_fechaliderini = @ls_fechaini
Select @ls_fechaliderfin = @ls_fechaliderini + ' 23:59:59'


--Fecha para sacar la venta del dia de mañana
Select @ls_anio = Substring((select CONVERT(char(10), @fechamanana,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechamanana,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechamanana,111)),9,2)

Select @ls_fechaini2 = @ls_anio+@ls_mes+@ls_dia
Select @ls_fechafin2 = @ls_anio+@ls_mes+@ls_dia+ ' 23:59:59'

Print @ls_fechaliderini+','+ @ls_fechaliderfin
Print @ls_fechaini2+','+ @ls_fechafin2

Delete from MR_SessionID where ses_SPID=@@SPID 
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'ActiveTargetedCurrency','MX$')  
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypeRevenue','Delivery Date')  
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypePay','Pay Period Date') 


Execute sp_TTSTMWAllocateRevVsPay_SSRS1_ABI  'D',@ls_fechaini,@ls_fechafin,'','','',' ','Y','Y','N','STD,CMP',' ','GUD,LAD,MEX,MTE,QRO',' ',' ',' ',' ','BAJ',' ',' ',' ',' ',' ','N','Y',' ',' ' 


Delete from MR_SessionID where ses_SPID=@@SPID




























GO
