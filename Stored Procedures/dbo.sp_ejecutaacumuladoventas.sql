SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Store Procedure que obtiene el acumulado de la semana.
-- y hace que se execute el SP para llenar la tabla del acumulado.
--Drop Proc sp_ejecutaacumuladoventas

CREATE procedure [dbo].[sp_ejecutaacumuladoventas]
AS
Declare @numerodedia int
Declare @fechasabado datetime
Declare @ls_fechasabado varchar(20)
declare @fechahoy datetime
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)

-- Dom 1, Lun 2, Mar 3, Mie 4, Jue 5, Vie 6, Sab 7
-- se obtiene el numero del dia de la fecha.
SELECT @numerodedia = DATEPART(dw, GETDATE())

Select @numerodedia = @numerodedia*-1
-- se obtiene la fecha del sabado anterior proximo
SELECT  @fechasabado = DATEADD(Day, @numerodedia, GETDATE())
--select CONVERT(char(10), Getdate(),111)
--Select  Substring((select CONVERT(char(10), Getdate(),111)),1,4)
--Select  Substring((select CONVERT(char(10), Getdate(),111)),6,2)
--Select  Substring((select CONVERT(char(10), Getdate(),111)),9,2)

select @ls_fechasabado 	= CONVERT(char(10), @fechasabado,111)
Select @ls_anio 	= Substring(@ls_fechasabado,1,4)
Select @ls_mes  	= Substring(@ls_fechasabado,6,2)
Select @ls_dia  	= Substring(@ls_fechasabado,9,2)

--arma el formato de la fecha sabado
Select @ls_fechasabado = @ls_anio+@ls_mes+@ls_dia

-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), Getdate(),111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), Getdate(),111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), Getdate(),111)),9,2)

Select @fechahoy = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'

Delete from MR_SessionID where ses_SPID=@@SPID Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'ActiveTargetedCurrency','MX$')  Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypeRevenue','Delivery Date')  Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypePay','Pay Period Date')


Execute sp_TTSTMWRevVsPayAcum_SSRS  'S',@ls_fechasabado,@fechahoy,'','','',' ','N','Y','N','PLN,AVL,STD,PKD,CMP,DSP',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','N','Y',' ',' '

Delete from MR_SessionID where ses_SPID=@@SPID Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'ActiveTargetedCurrency','MX$')  Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypeRevenue','Delivery Date')  Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypePay','Pay Period Date')
GO
