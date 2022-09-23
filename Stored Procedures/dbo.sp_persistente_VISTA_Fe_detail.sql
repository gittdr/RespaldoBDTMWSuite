SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_persistente_VISTA_Fe_detail]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

    delete cache_VISTA_Fe_detail
	insert into cache_VISTA_Fe_detail(folio, cantidad, unidadmedida, unidadmedida33, claveunidad, numidentificacion, consecutivo, idconcepto, descripcion, valorunitario, Importe, tasa_iva, tipo_imp, impuestoiva, tipofactoriva, iva_monto, importe_iva_inc, tasa_ret, Retencion, impuestoret, tipofactorret, ret_monto, importe_ret_inc)
	select * from VISTA_Fe_detail

	delete persistente_VISTA_Fe_detail

	insert into persistente_VISTA_Fe_detail(folio, cantidad, unidadmedida, unidadmedida33, claveunidad, numidentificacion, consecutivo, idconcepto, descripcion, valorunitario, Importe, tasa_iva, tipo_imp, impuestoiva, tipofactoriva, iva_monto, importe_iva_inc, tasa_ret, Retencion, impuestoret, tipofactorret, ret_monto, importe_ret_inc)
		select * from cache_VISTA_Fe_detail

END


GO
