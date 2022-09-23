SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name> Linda y Erik
-- Create date: <Create Date,,> 23/12/19
-- Description:	<Description,,> Actualiza la descripcion del anticipo y/o reembolso (pyd_description) con el concepto de la tabla 
--								Codigos_comprobacion correpondiente (id_codigo).También copia este número en el campo pyd_tprsplit_number 
--								el cual se utiliza para el analisis de los indicadores de normatividad en el cubo  
--								(VistaGratificacionesRoger_por_Orden)
-- Exec [dbo].[sp_ActualizarAnticiposYReembolsos] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_ActualizarAnticiposYReembolsos] (@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
		UPDATE paydetail
		SET 
		--select 
		pyd_tprsplit_number= pyd_description,
		pyd_description = 'GC ' +(SELECT descripcion FROM Codigos_comprobacion WHERE paydetail.pyd_description = CAST(id_codigo AS VARCHAR))
		--from paydetail
		WHERE pyt_itemcode = 'COMGRA' and ord_hdrnumber IN 
						(SELECT ord_hdrnumber 
						FROM paydetail py
						INNER JOIN Codigos_comprobacion cod 
						ON py.pyd_description = CAST(cod.id_codigo AS VARCHAR)
						WHERE py.pyt_itemcode = 'COMGRA') and (SELECT descripcion FROM Codigos_comprobacion WHERE paydetail.pyd_description = CAST(id_codigo AS VARCHAR)) is not null
						--and pyd_description in (SELECT cast(id_codigo as varchar) FROM Codigos_comprobacion)
	END
END
GO
