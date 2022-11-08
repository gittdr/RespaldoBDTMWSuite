SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_Insert_Api_MercadoL_JC](
@Ai_orden int,
@id int,
@cate varchar(100),
@descript varchar(60),
@weight float,
@uwe varchar(6),
@quanti float,
@unitcode varchar(6)
)
as
begin
		
		INSERT INTO ApiMercadoL(
		Ai_orden,
		Route_id,
		Av_cmd_code,
		Av_cmd_description,
		Af_weight,
		Av_weightunit,
		Af_count,
		Av_countunit
		)
		VALUES(
		@Ai_orden,
@id,
@cate,
@descript,
@weight,
@uwe,
@quanti,
@unitcode
		) 
end

GO
