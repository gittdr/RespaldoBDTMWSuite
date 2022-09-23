SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspGuardarUsuario]
@iidusuario int,
@nombreusuario varchar(100),
@contra varchar(100),
@iidpersona int,
@iidtipousuario int
as
begin
if @iidusuario=0
 insert into Usuario(NOMBREUSUARIO,CONTRA,IIDPERSONA,BHABILITADO,IIDTIPOUSUARIO)
 values(@nombreusuario,@contra,@iidpersona,1,@iidtipousuario)
 else
 update usuario
 set NOMBREUSUARIO=@nombreusuario,IIDTIPOUSUARIO=@iidtipousuario
 where IIDUSUARIO=@iidusuario

 end
GO
