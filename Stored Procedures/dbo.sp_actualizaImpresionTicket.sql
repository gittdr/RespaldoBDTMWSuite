SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROCEDURE [dbo].[sp_actualizaImpresionTicket]
AS

update AuditoriaVales set actualizado = 'N' from AuditoriaVales join fuelticket on ftk_ticket_number = vale where ftk_printed_by is null and ftk_printed_on is null
update fuelticket set ftk_printed_by = usuario,ftk_printed_on = fecha from fuelticket join  AuditoriaVales on ftk_ticket_number = vale where ftk_printed_by is null and ftk_printed_on is null

GO
