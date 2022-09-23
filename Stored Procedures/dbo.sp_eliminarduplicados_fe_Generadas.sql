SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		erik juarez
-- Create date: getdate()
-- Description:	<Description,,>
-- exec [dbo].[sp_ConvoyCorreoClientePatron] 1
-- =============================================
create PROCEDURE [dbo].[sp_eliminarduplicados_fe_Generadas] (@accion int)
	
AS
BEGIN
IF(@accion = 1)
BEGIN
		Delete  VISTA_fe_generadas WHERE invoice IN (

select invoice from VISTA_fe_generadas
where rutapdf = '' AND INVOICE IN(select invoice 

from  VISTA_fe_generadas WHERE rutapdf <> '')
) AND 
nmaster IN (

select nmaster from VISTA_fe_generadas
where rutapdf = '' AND INVOICE IN(select invoice 

from  VISTA_fe_generadas WHERE rutapdf <> '') 
)
and rutapdf = ''

END
END

GO
