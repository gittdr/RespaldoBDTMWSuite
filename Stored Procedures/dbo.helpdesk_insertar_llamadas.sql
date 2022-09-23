SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[helpdesk_insertar_llamadas] (@fechaInicio datetime, @fechaFinal datetime, @monitorista varchar(100), @operador varchar(50))

as
begin
insert into [helpdesk_llamadas] (fechaInicio, fechaFinal, monitorista, operador) 
values (@fechaInicio, @fechaFinal, @monitorista, @operador)
end

GO
