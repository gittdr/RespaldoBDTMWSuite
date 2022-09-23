SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[usp_BullLoad_Jc](
@EstructuraCargaxOrden EstructuraCargaxOrden READONLY,                                      
@Resultado int output
)
as

begin
	begin
		CREATE TABLE ##temporal(
		id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
		Ai_orden int,
		Av_cmd_code varchar(8),
		Av_cmd_description varchar(500),
		Af_count float,
		Av_countunit varchar(6),
		Av_description_parts varchar(500),
		Af_weight float,
		Av_weightunit varchar(6),
		Av_description_units varchar(500)
		)
		INSERT INTO ##temporal(Ai_orden,Av_cmd_code,Av_cmd_description,Af_count,Av_countunit,Av_description_parts,Af_weight,Av_weightunit,Av_description_units)
		select Ai_orden,Av_cmd_code,Av_cmd_description,Af_count,Av_countunit,Av_description_parts,Af_weight,Av_weightunit,Av_description_units from @EstructuraCargaxOrden
	end
	BEGIN TRY
			DECLARE @i int = 1,@id int = 1,@existe int, @total int,@Ai_orden int,@Av_cmd_code varchar(8),@Av_cmd_description varchar(500),@Af_count float,@Av_countunit varchar(6),@Af_weight float, @Av_weightunit varchar(6)
			select @Ai_orden = Ai_orden from @EstructuraCargaxOrden
			SELECT   @existe = COUNT(Ai_orden) FROM CargaPorOrdenJc WHERE Ai_orden = @Ai_orden
			IF @existe > 0
			BEGIN
			SET @Resultado = 0
			END
			ELSE
			SELECT @total = COUNT(Ai_orden)FROM ##temporal
			WHILE (@i <=@total)
				BEGIN
					select @Ai_orden = Ai_orden,@Av_cmd_code = Av_cmd_code,@id = Id,@Av_cmd_description = Av_cmd_description,@Af_count = Af_count,@Av_countunit = Av_countunit,@Af_weight = Af_weight, @Av_weightunit = Av_weightunit from ##temporal Where Id = @Id
					exec usp_cargarorden @Ai_orden, @Av_cmd_code,@Av_cmd_description,@Af_count,@Av_countunit,@Af_weight,@Av_weightunit
					SELECT @Av_cmd_description = SUBSTRING(@Av_cmd_description,1,60)
		            SELECT @Af_weight = CAST (@Af_weight AS DECIMAL(8,2))
					exec sp_Obtiene_Stops_Orden_JR @Ai_orden, @Av_cmd_code,@Av_cmd_description,@Af_weight,@Av_weightunit,@Af_count,@Av_countunit
					SET @id = @id +1
					SET @i = @i + 1
					SET @Resultado = 1
				END
		--DROP TABLE temporal
		--PRIMERA MODIFICACION
		-- otra modificacion
	END TRY
	BEGIN CATCH
		SET @Resultado = 0
	END CATCH
end
GO
