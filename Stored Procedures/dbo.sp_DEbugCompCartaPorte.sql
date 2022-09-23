SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
Fecha: 23 Dic 2021 12:13 hrs
Version 1.0

Stored Proc que forma la cadena para complemento carta porte
y la parsea en un formato con salto de lineas para mejor visualización
y carga por FTP

Recibe como parametro el numero de de legheader
dado que en una orden segmentado son varios los recursos involucrados.


Sentencia de prueba  sp_DEbugCompCartaPorte  1234980
*/



CREATE proc [dbo].[sp_DEbugCompCartaPorte] (@leg varchar(20))
as

Declare @tablevar table(cadena varchar(max))
insert into @tablevar(cadena) 

exec sp_compCartaPorte @leg

SELECT replace(cadena, '\n',CHAR(13))  FROM @tablevar
GO
