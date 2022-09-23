SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Mercancia] (@myTableType sl_Pilgrims_Mercancia readonly, @accion int )
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 1)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into [dbo].[Sl_Pilgrims_Detalle](Cantidad,unidad,Material,Descripcion, Peso,  unidad_peso, Pedido_Id)
	Select CantidadItem,ClaveUnidad,BienesTransp,Descripcion,PesoEnKg,'KGM', Traslado_id from @myTableType
END
IF(@accion = 2)
BEGIN

	delete from [dbo].[Sl_Pilgrims_Detalle]
END
END

GO
