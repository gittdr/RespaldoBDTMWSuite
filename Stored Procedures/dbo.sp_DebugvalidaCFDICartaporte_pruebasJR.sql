SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
Fecha: 23 Dic 2021 12:13 hrs
Version 1.0

Stored Proc que valida los datos para generar la carta
y la parsea en un formato con salto de lineas para mejor visualización

Recibe como parametro el numero de de legheader
dado que en una orden segmentado son varios los recursos involucrados.


Sentencia de prueba
 sp_DebugvalidaCFDICartaporte  1234980
*/



CREATE proc [dbo].[sp_DebugvalidaCFDICartaporte_pruebasJR] (@leg varchar(20))
as

Declare @tablevar table(cadena varchar(max), resultado varchar(10))
insert into @tablevar(cadena, resultado) 

select * from @tablevar

--exec  sp_validaCFDICartaporte_pruebasJR  @leg

--SELECT replace(cadena, '<br>',CHAR(13))  FROM @tablevar
GO
