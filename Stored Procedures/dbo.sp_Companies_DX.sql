SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name> Linda y Erik
-- Create date: <Create Date,,> 12/11/19
-- Description:	<Description,,> Añade compañías a la tabla dx_Lookup, al cargar un TMS mediante el DX, se realiza una 
--                              búsqueda en la tabla dx_Lookup y si existe genera la orden con sus orígenes y destinos.
-- Exec [dbo].[sp_Companies_DX] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_Companies_DX] (@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
		INSERT INTO dx_Lookup([dx_importid], [dx_lookuptable], [dx_lookuprawdatavalue], [dx_lookuptranslatedvalue])
		SELECT 'dx_Sayer', 'compania',cmp_id ,cmp_id
		FROM company
		WHERE cmp_billto = 'N'
		AND cmp_active = 'Y'
		AND cmp_id NOT IN (SELECT dx_lookuptranslatedvalue FROM dx_Lookup
							WHERE dx_importid = 'dx_Sayer'
							AND dx_lookuptable = 'compania'
							--AND dx_lookuprawdatavalue = dx_lookuptranslatedvalue
							)
							and cmp_id not in ('CASCTLA')
	END
END
GO
