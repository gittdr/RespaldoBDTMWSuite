SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_usuarios]

as



declare @Usu xml

set @Usu = (
select * 
 from tlbUserAccess



FOR XML PATH ('Usuario'), root ('Usuarios')
)


select @Usu as Usuarios
GO
