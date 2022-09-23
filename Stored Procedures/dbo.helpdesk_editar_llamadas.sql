SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[helpdesk_editar_llamadas] (@idTicket INT, @monitotista varchar(50), @operador varchar(8))
as
begin
update [helpdesk_llamadas] set [helpdesk_llamadas].operador = @operador where [helpdesk_llamadas].idTicket = @idTicket
end 
GO
