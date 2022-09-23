SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.update_event_hubmiles_sp    Script Date: 6/1/99 11:54:41 AM ******/
create proc [dbo].[update_event_hubmiles_sp] (@eventnumber int, @hubmiles int)
as

Update event
set evt_hubmiles = @hubmiles
where evt_number = @eventnumber

return

GO
GRANT EXECUTE ON  [dbo].[update_event_hubmiles_sp] TO [public]
GO
