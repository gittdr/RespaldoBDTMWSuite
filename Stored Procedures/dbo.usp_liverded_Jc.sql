SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_liverded_Jc](
@Ai_orden varchar(100), 
@Av_cmd_code varchar(100),
@Av_cmd_description varchar(200),
@Af_weight varchar(100),
@Av_weightunit varchar(100),
@Af_count varchar(100),
@Av_countunit varchar(100)
)
as
begin
		
		INSERT INTO IMPORTMERLIVERDED(
		Ai_orden,
		Av_cmd_code,
		Av_cmd_description,
		Af_weight,
		Av_weightunit,
		Af_count,
		Av_countunit)
		VALUES(
		@Ai_orden,
		@Av_cmd_code,
		@Av_cmd_description,
		@Af_weight,
		@Av_weightunit,
		@Af_count,
		@Av_countunit) 
		INSERT INTO ##tliverded2(Ai_orden,Av_cmd_code,Av_cmd_description,Af_weight,Av_weightunit,Af_count,Av_countunit)
		select DISTINCT Ai_orden,Av_cmd_code,Av_cmd_description,Af_weight,Av_weightunit,Af_count,Av_countunit from IMPORTMERLIVERDED
end



GO
