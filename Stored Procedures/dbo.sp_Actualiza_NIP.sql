SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_Actualiza_NIP] @Operador varchar(10), @NIP varchar(12)
AS


SET NOCOUNT ON
Declare
	@MBAnterior Varchar(12)

-- Si hay facturas ya de esa orden continua si no no pasa
	If ( SELECT count(*) FROM manpowerprofile WHERE mpp_id = @Operador ) =1
	BEGIN 
		update manpowerprofile set mpp_password = @NIP where mpp_id = @Operador;

		Select 'NIP Actualizado'	

		commit;
	END
	Else
		BEGIN
		Select 'El Operador no existe...'
		END 






GO
