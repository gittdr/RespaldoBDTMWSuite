SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspRecuperarPersona]
@idpersona int
as
begin
select p.*,isnull(u.IIDUSUARIO,0) as BTIENEUSUARIO, isnull(u.NOMBREUSUARIO,'') as NOMBREUSUARIO,isnull(u.IIDTIPOUSUARIO,0) as IIDTIPOUSUARIO from persona p
left join usuario u
on p.iidpersona=u.iidpersona
where p.IIDPERSONA=@idpersona
end
GO
