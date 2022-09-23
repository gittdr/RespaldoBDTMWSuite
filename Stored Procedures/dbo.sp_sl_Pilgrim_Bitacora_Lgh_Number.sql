SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrim_Bitacora_Lgh_Number] (@lgh_number int,@ConjuntoDatos varchar(50), @valeplastico1 varchar(50), @fleje1 varchar(50), @valeplastico2 varchar(50), 
									 @fleje2 varchar(50), @flejeSagarpa1 varchar(50), @flejeSagarpa2 varchar(50),
									 @InicialHT1 varchar(50), @FinalHT1 varchar(50), @TrabajadasHT1 varchar(50), @InicialLT1 varchar(50), @FinalLT1 varchar(50), 
									 @ConsumoLT1 varchar(50), @Rendimiento1 varchar(50), @InicialHT2 varchar(50), @FinalHT2 varchar(50), @TrabajadasHT2 varchar(50), 
									 @InicialLT2 varchar(50), @FinalLT2 varchar(50), @ConsumoLT2 varchar(50), @Rendimiento2 varchar(50), @ProgramadaTemp2 varchar(50), 
									 @SalidaPlanta2 varchar(50), @Ruta2 varchar(50), @Cliente2 varchar(50), @ProgramadaTemp1 varchar(50), @SalidaPlanta1 varchar(50), 
									 @Ruta1 varchar(50), @Cliente1 varchar(50), @Observaciones varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF(@ConjuntoDatos = 'insertLghFle') 
BEGIN

IF EXISTS (SELECT * FROM [dbo].[Sl_Pilgrims_Bitacora_Lgh_Number] WHERE lgh_number = @lgh_number)
BEGIN
print 'aqui entre update'
UPDATE [dbo].[Sl_Pilgrims_Bitacora_Lgh_Number] 
	SET valeplastico1 = @valeplastico1,
		 fleje1 = @fleje1, 
		 valeplastico2= @valeplastico2, 
		 fleje2 = @fleje2, 
		 flejeSagarpa1= @flejeSagarpa1, 
		 flejeSagarpa2= @flejeSagarpa2, 
		 InicialHT1= @InicialHT1, 
		 FinalHT1= @FinalHT1, 
		 TrabajadasHT1= @TrabajadasHT1,
		 InicialLT1= @InicialLT1, 
		 FinalLT1= @FinalLT1, 
		 ConsumoLT1= @ConsumoLT1, 
		 Rendimiento1= @Rendimiento1, 
		 InicialHT2= @InicialHT2,
	     FinalHT2= @FinalHT2, 
		 TrabajadasHT2= @TrabajadasHT2, 
		 InicialLT2= @InicialLT2, 
		 FinalLT2= @FinalLT2, 
		 ConsumoLT2= @ConsumoLT2, 
		 Rendimiento2= @Rendimiento2, 
		 ProgramadaTemp2= @ProgramadaTemp2, 
		 SalidaPlanta2= @SalidaPlanta2, 
		 Ruta2= @Ruta2,
	     Cliente2= @Cliente2, 
		 ProgramadaTemp1= @ProgramadaTemp1, 
		 SalidaPlanta1= @SalidaPlanta1, 
		 Ruta1= @Ruta1, 
		 Cliente1= @Cliente1,
		 Observaciones = @Observaciones

	 where lgh_number = @lgh_number


END
ELSE
print 'entre a insertar'
				insert into [dbo].[Sl_Pilgrims_Bitacora_Lgh_Number](lgh_number, valeplastico1, fleje1, valeplastico2, fleje2, flejeSagarpa1, flejeSagarpa2, InicialHT1, FinalHT1, TrabajadasHT1, InicialLT1, 
														FinalLT1, ConsumoLT1, Rendimiento1, InicialHT2, FinalHT2, TrabajadasHT2, InicialLT2, FinalLT2, ConsumoLT2, Rendimiento2, ProgramadaTemp2, 
														SalidaPlanta2, Ruta2, Cliente2, ProgramadaTemp1, SalidaPlanta1, Ruta1, Cliente1, Observaciones)
				Values(@lgh_number, @valeplastico1, @fleje1, @valeplastico2, @fleje2, @flejeSagarpa1, @flejeSagarpa2, @InicialHT1, @FinalHT1, @TrabajadasHT1, @InicialLT1, @FinalLT1, @ConsumoLT1, @Rendimiento1,
				 @InicialHT2, @FinalHT2, @TrabajadasHT2, @InicialLT2, @FinalLT2, @ConsumoLT2, @Rendimiento2, @ProgramadaTemp2, @SalidaPlanta2, @Ruta2, @Cliente2, @ProgramadaTemp1, @SalidaPlanta1, @Ruta1, @Cliente1, @Observaciones)
END

END

GO
