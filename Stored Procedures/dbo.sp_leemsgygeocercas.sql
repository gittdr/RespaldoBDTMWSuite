SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Store Procedure para corre el sP sp_executa_leemsgygeocercas
--exec sp_executa_SPValesKms
CREATE procedure [dbo].[sp_leemsgygeocercas] @unidad varchar(10)
AS
Declare @numerodedia int
Declare @fechaini datetime
Declare @fechafin datetime
declare @fechahoy datetime
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)

--select  dateadd(day,-5,getdate())
--select  dateadd(day,2,getdate())

select @fechaini = dateadd(day,-5,getdate())
select @fechafin = dateadd(day,2,getdate())

-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechaini,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechaini,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechaini,111)),9,2)

Select @fechaini = @ls_anio+@ls_mes+@ls_dia

Select @ls_anio = Substring((select CONVERT(char(10), @fechafin,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechafin,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechafin,111)),9,2)

Select @fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'



select displayname, tipo, fecha, movimiento, compañia,evento from qsp..vista_geocercas where displayname = @unidad and
fecha >= @fechaini and fecha <= @fechafin and displayname = @unidad
UNION
	Select  C.displayName Unidad,  LEFT(convert(varchar(50),A.messageBody),50)  , A.SentDatetime, 0,'',''
	From QSP..QFSMessage A, QSP..QFSSites B, QSP..QFSVehicles C
	Where   A.siteID *= B.siteID  and 
		  C.vehicleID = A.senderId and C.displayName = @unidad and
 A.SentDatetime between @fechaini and @fechafin and 
LEFT(convert(varchar(50),A.messageBody),50) in ('Iniciando Viaje', 'Terminando viaje')
	order by 3




GO
