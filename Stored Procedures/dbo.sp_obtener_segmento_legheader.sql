SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_obtener_segmento_legheader](                                     
@orden varchar(100)
)
as
begin
	select  min(lgh_number) as segmento 
	from legheader WHERE
	ord_hdrnumber in (SELECT ord_hdrnumber from orderheader where ord_hdrnumber = @orden)
end

--- MODIFICACIONES
GO
