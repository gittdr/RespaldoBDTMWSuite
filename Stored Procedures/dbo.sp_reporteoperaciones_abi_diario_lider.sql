SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- Store Procedure que el reporte del depto de comercial de ventas diario
--Drop Proc  sp_reporteoperaciones_abi_diario
--exec sp_reporteoperaciones_abi_diario_lider
CREATE procedure [dbo].[sp_reporteoperaciones_abi_diario_lider]
AS
Declare @fechahoy datetime
Declare @ls_fechaini varchar(20)
Declare @ls_fechafin varchar(20)
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)

select @fechahoy = getdate()


-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia

Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)


Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'



Delete from MR_SessionID where ses_SPID=@@SPID 
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'ActiveTargetedCurrency','MX$')  
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypeRevenue','Delivery Date')  
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypePay','Pay Period Date') 
--Execute sp_TTSTMWAllocateRevVsPay_SSRS1 'D','20120113','20120121 23:59:59','','','',' ','N','Y','N','CMP',' ',' ',' ','DED',' ',' ','TOL,FULS,QRL,EUC,ABI',' ',' ',' ',' ',' ','N','Y',' ',' ' 
--Execute sp_TTSTMWAllocateRevVsPay_SSRS1_ABI 'D',@ls_fechaini,@ls_fechafin,'','','',' ','Y','Y','N','STD,CMP',' ','GUD,LAD,MEX,MTE,QRO',' ',' ',' ',' ','BAJ',' ',' ',' ',' ',' ','N','Y',' ',' ' 
Execute sp_TTSTMWAllocateRevVsPay_SSRS1_ABI_lider 'D',@ls_fechaini,@ls_fechafin,'','','',' ','Y','Y','N','STD,CMP,AVL',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','N','Y',' ',' '

Delete from MR_SessionID where ses_SPID=@@SPID






GO
