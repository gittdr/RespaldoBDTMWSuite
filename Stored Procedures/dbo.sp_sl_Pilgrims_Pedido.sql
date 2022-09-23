SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Pedido] (@pedido_Id int, @entrega varchar(50), @factura varchar(50), @client_Id int, @secuencia int, @lugarEntrega int, @domicilio varchar(50), @cP varchar(50), @ciudad varchar(50), @estado varchar(50), @pais varchar(50), @destino int, @caja int,@accion int )
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 1)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into [dbo].[Sl_Pilgrims_Pedido](Pedido_Id, Entrega, Factura, Client_Id, Secuencia, LugarEntrega, Domicilio, CP, Ciudad, Estado, Pais, Destino, Caja)
	values(@pedido_Id, @entrega, @factura, @client_Id, @secuencia, @lugarEntrega, @domicilio, @cP, @ciudad, @estado, @pais, @destino, @caja)
END
IF(@accion = 2)
BEGIN
	delete from [dbo].[Sl_Pilgrims_Pedido]
END
END

GO
