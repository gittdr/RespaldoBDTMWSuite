SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--DROP PROCEDURE [sp_Inserta_logactividadesQFS_JR]
--GO

-- exec [sp_Inserta_logactividadesQFS_JR] '01-01-2012 12:00','Actividad X',111111,'ejemplo','5551'

CREATE  PROCEDURE [dbo].[sp_Inserta_logactividadesQFS_JR] @a_fecha datetime, @a_actividad varchar(50), 
													   @a_movimiento Integer, @a_resultado varchar(250), 
													   @a_unidad varchar(10), @a_company varchar(20)

AS

SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información de los insumos para capas
	INSERT Into log_actividadesQFS
		(fecha, actividad , movimiento, resultado, unidad, company)
		VALUES(
			@a_fecha, @a_actividad , @a_movimiento, @a_resultado, @a_unidad, @a_company)

END --1 Principal

--delete log_actividadesQFS
GO
