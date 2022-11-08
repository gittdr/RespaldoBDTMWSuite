SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_Insert_Api_MercadoL_Errores_JC](
@ship_id varchar(20)
)
as
begin
		
		INSERT INTO ApiMercadoLErrores(
		Shipment_id
		)
		VALUES(
@ship_id
		) 
end
GO
