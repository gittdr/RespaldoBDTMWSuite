SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











-- Store Procedure para corre el sP [sp_ObtieneanticiposenGral]
--exec sp_executa_sp_ObtieneanticiposenGral_Acumulado
CREATE procedure [dbo].[sp_executa_sp_ObtieneanticiposenGral_Acumulado]
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



--se que este reporte se correra cada dia Viernes.
-- por lo tanto para sacar el sabado y viernes se hace lo sig.
 if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Monday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-9,getdate())
       select @fechaviernesfin = dateadd(day,-3,getdate())
			--select @fechasabadoini = dateadd(day,-2,getdate())
			--select @fechaviernesfin = dateadd(day,0,getdate())
end
 if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Tuesday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-10,getdate())
       select @fechaviernesfin = dateadd(day,-4,getdate())
end

 if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Wednesday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-11,getdate())
       select @fechaviernesfin = dateadd(day,-5,getdate())
			--select @fechasabadoini = dateadd(day,-4,getdate())
			--select @fechaviernesfin = dateadd(day,0,getdate())
end

 if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Friday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-13,getdate())
       select @fechaviernesfin = dateadd(day,-7,getdate())
end
 
if( (select CHARINDEX ( DATENAME(dw, getdate()) , 'Saturday'))<> 0)
begin
       select @fechasabadoini = dateadd(day,-7,getdate())
       select @fechaviernesfin = dateadd(day,-1,getdate())
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

Print @ls_fechasabini+','+ @ls_fechaviefin

Execute sp_ObtieneanticiposenGral @ls_fechasabini,@ls_fechaviefin





















GO
