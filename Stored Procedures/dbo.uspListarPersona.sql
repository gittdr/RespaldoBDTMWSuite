SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspListarPersona]
as 
begin
select p.IIDPERSONA, p.NOMBRE+' '+p.APPATERNO+' '+p.APMATERNO as NombreCompleto,s.NOMBRE,p.NUMEROTELEFONICO
from Persona p
inner join Sexo s on p.IIDSEXO = S.IIDSEXO
where p.BHABILITADO=1
end
GO
