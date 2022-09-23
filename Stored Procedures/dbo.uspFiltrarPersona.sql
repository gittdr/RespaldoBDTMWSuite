SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspFiltrarPersona]
@nombrecompleto varchar(100),
@iidsexo int
as 
begin
declare @sql NVARCHAR(400)
set @sql='
select p.IIDPERSONA, p.NOMBRE+'' ''+p.APPATERNO+'' ''+p.APMATERNO as NombreCompleto,s.NOMBRE,p.NUMEROTELEFONICO
from Persona p
inner join Sexo s on p.IIDSEXO = S.IIDSEXO
where p.BHABILITADO=1
'
if @nombrecompleto!=''
set @sql=@sql+ ' AND p.NOMBRE+'' ''+p.APPATERNO+'' ''+p.APMATERNO LIKE ''%'+@nombrecompleto+'%'''
if @iidsexo!=0
set @sql=@sql+ ' AND p.IIDSEXO ='+CONVERT(VARCHAR,@iidsexo)
EXECUTE SP_EXECUTESQL @sql
end
GO
