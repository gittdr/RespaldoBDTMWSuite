SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Store Procedure que obtiene la venta del dia
--Drop Proc  sp_ejecutaventadiaria

CREATE procedure [dbo].[sp_ejecutaventadiaria]
AS
Declare @numerodedia int
Declare @fechahoyini datetime
Declare @fechahoyfin datetime
Declare @ls_fechahoyini varchar(20)
Declare @ls_fechahoyfin varchar(20)
declare @fechahoy datetime
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)



-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), Getdate(),111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), Getdate(),111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), Getdate(),111)),9,2)

Select @ls_fechahoyini = @ls_anio+@ls_mes+@ls_dia
Select @ls_fechahoyfin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'

Delete from MR_SessionID where ses_SPID=@@SPID Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'ActiveTargetedCurrency','MX$')  Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypeRevenue','Delivery Date')  Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypePay','Pay Period Date')

Execute sp_TTSTMWAllocateRevVsPay_SSRS  'S',@ls_fechahoyini,@ls_fechahoyfin,'','','',' ','N','Y','N','PLN,AVL,STD,PKD,CMP,DSP',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','N','Y',' ',' '

Delete from MR_SessionID where ses_SPID=@@SPID Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'ActiveTargetedCurrency','MX$')  Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypeRevenue','Delivery Date')  Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypePay','Pay Period Date')
GO
