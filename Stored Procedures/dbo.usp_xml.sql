SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_xml](
@usuario varchar(100),
@narchivo varchar(200),
@Resultado int output
)
as

begin
	   BEGIN
		 
			--SELECT @Av_cmd_description = SUBSTRING(@Av_cmd_description,1,60)
			--SELECT @Af_weight = CAST (@Af_weight AS DECIMAL(8,2))
			INSERT INTO RCSAYER(usuario,narchivo)
			VALUES(@usuario,@narchivo)
			SET @Resultado = 1;
		END
	
		BEGIN
		  SET @Resultado = 0;
		END
end


GO
