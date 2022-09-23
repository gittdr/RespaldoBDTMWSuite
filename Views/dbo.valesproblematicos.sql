SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create view [dbo].[valesproblematicos]

as

select ftk_ticket_number as vale,ord_hdrnumber as orden, mov_number as movimiento, ftk_liters as litros, ftk_cost as costo, ftk_printed_on as Fecha, drv_id as Operador, trc_id as Tractor from fuelticket
where ftk_printed_by = 'VELEC'  and ftk_canceled_by is null and ftk_disper is not null and ftk_ticket_number  not in (select numvale from fuelticketelect )

GO
