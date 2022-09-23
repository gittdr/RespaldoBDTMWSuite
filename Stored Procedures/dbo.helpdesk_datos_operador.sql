SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[helpdesk_datos_operador] (@id_Operador VARCHAR(50))
as
begin 
 select * from dbo.manpowerprofile where mpp_id = @id_Operador;
End 

GO
