SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para leer los movimientos que inserta QSP
-- y pasarlos a la tabla checkcall.
--DROP PROCEDURE sp_statusorden
--GO

--exec sp_statusorden

CREATE  PROCEDURE [dbo].[sp_statusorden]
AS

DECLARE	

	@V_ANTENA		Varchar(50),
	@V_DESCRIPCTA		Varchar(10),
	@V_GPSLOCATION		Varchar(255),
	@V_velocidad		Float




SET NOCOUNT ON




-- Si hay movimientos en la tabla continua
	If Exists ( SELECT TOP 1 tmwauditcolumns_id FROM tmwauditcolumns WHERE object ='d_tripfolder_header' AND obj_column ='not_saved' AND status ='Active' )
	BEGIN 
		Select 'La orden necesita ser guardada para continuar'	
	END
	Else
		BEGIN
		Select 'La orden No necesita ser guardada para continuar'	
		END 





GO
