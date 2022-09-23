SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GlobalMap_Mileagetable] (@origen varchar(1000), @Destino varchar(1000), @kms varchar(1000), @horas varchar(1000),@tollCost varchar(1000), @ejes int,@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
	--insertar casetas en la tabla 13
	--origen destino compania datos 
	--select 1

	IF not exists(Select * from [dbo].[mileagetable_GlobalMap] where [mt_cmporigen] = @origen and [mt_cmpdestino] = @Destino and mt_ejes = @ejes)
	begin 
		insert into [dbo].[mileagetable_GlobalMap] (mt_type, mt_origintype, [mt_cmporigen], mt_destinationtype, [mt_cmpdestino], mt_miles, mt_hours, mt_updatedby, mt_updatedon, mt_tolls_cost, mt_ejes)
		--Values('13','C','test','C','test2', '10','11','sa',getdate(),'10.45','')
		Values('13','C',@origen,'C',@Destino, @kms,@horas,'sa',getdate(),@tollCost,@ejes)
	end
	END
		

END



GO
