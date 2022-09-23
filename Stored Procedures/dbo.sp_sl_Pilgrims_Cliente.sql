SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Cliente] (@idClient varchar(50), @clienteDescripcion varchar(50) ,@fechaEntregaMin varchar(50),@fechaEntregaMax varchar(50),@client_Id int,@embarque_id int,@distancia DECIMAL(18,2),@accion int )
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 1)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	insert into [dbo].[Sl_Pilgrims_Cliente](IdClient,ClienteDescripcion ,FechaEntregaMin, FechaEntregaMax,Client_Id, Embarque_Id, Distancia)
	values (@idClient,@clienteDescripcion , @fechaEntregaMin, @fechaEntregaMax, @client_Id,@embarque_Id,@distancia)
END

IF(@accion = 2)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
delete from [dbo].[Sl_Pilgrims_Cliente]
END
END

GO
