SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_rutaGlobalMapEjes] (@origen varchar(1000), @Destino varchar(1000),@ejes int,@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
	--insertar casetas en la tabla 13
	--origen destino compania datos 
	--select 1
	
	Select * from [dbo].[mileagetable_GlobalMap] 
	where [mt_cmporigen] = @origen
	and  [mt_cmpdestino] = @Destino and mt_ejes= @ejes 

	END
		

END
GO
