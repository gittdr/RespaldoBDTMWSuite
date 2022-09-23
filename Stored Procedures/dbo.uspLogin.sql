SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspLogin]
@nombreusuario varchar(100),
@contra varchar(100)
as
begin
select u.IIDUSUARIO,p.nombre+' '+p.appaterno+' '+p.APMATERNO as NOMBRECOMPLETO , 
IIDTIPOUSUARIO
from  Usuario u
inner join Persona p
on u.iidpersona=p.iidpersona
where u.nombreusuario=@nombreusuario and u.contra=@contra and p.BHABILITADO=1

end
GO
