SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- Store Procedure que el reporte del depto de operaciones
--Drop Proc  sp_reporteoperaciones_ded
--exec sp_reporteoperaciones_ded
CREATE procedure [dbo].[sp_reporteoperaciones_ded]
AS
Declare @numerodedia int
Declare @fechasabadoini datetime
Declare @fechaviernesfin datetime
Declare @fechahoyini datetime
Declare @fechahoyfin datetime
Declare @ls_fechasabini varchar(20)
Declare @ls_fechaviefin varchar(20)
declare @fechahoy datetime
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)

begin

--se que este reporte se correra cada dia Lunes.
-- por lo tanto para sacar el sabado y viernes se hace lo sig.
 if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Monday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-9,getdate())
       select @fechaviernesfin = dateadd(day,-3,getdate())
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Tuesday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-10,getdate())
       select @fechaviernesfin = dateadd(day,-4,getdate())
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Wednesday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-11,getdate())
       select @fechaviernesfin = dateadd(day,-5,getdate())
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Thursday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-12,getdate())
       select @fechaviernesfin = dateadd(day,-6,getdate())
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Friday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-13,getdate())
       select @fechaviernesfin = dateadd(day,-7,getdate())
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Saturday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-14,getdate())
       select @fechaviernesfin = dateadd(day,-8,getdate())
end
else if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Sunday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-15,getdate())
       select @fechaviernesfin = dateadd(day,-9,getdate())
end



-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechasabadoini,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechasabadoini,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechasabadoini,111)),9,2)

Select @ls_fechasabini = @ls_anio+@ls_mes+@ls_dia

Select @ls_anio = Substring((select CONVERT(char(10), @fechaviernesfin,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechaviernesfin,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechaviernesfin,111)),9,2)


Select @ls_fechaviefin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'
print cast(@ls_fechasabini as nvarchar(30)) + ' fechaFin: ' + cast(@ls_fechaviefin as nvarchar(30))

Delete from MR_SessionID where ses_SPID=@@SPID 
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'ActiveTargetedCurrency','MX$')  
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypeRevenue','Delivery Date')  
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypePay','Pay Period Date') 
Execute sp_TTSTMWAllocateRevVsPay_SSRS1_ded 'D',@ls_fechasabini,@ls_fechaviefin,'','','',' ','N','Y','N','CMP',' ',' ',' ',' ',' ',' ','SAY,FULO,P&G,GAM,HED','',' ',' ',' ',' ','N','Y',' ',' ' 
--Execute sp_TTSTMWAllocateRevVsPay_SSRS1_ded 'D',@ls_fechasabini,@ls_fechaviefin,'','','',' ','N','Y','N','CMP',' ',' ',' ',' ',' ',' 
--','SAY,FULO,P&G,GAM,HED','DED',' ',' ',' ',' ','N','Y',' ',' '
Delete from MR_SessionID where ses_SPID=@@SPID

end






GO
