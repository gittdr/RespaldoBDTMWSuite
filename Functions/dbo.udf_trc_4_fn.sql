SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 CREATE FUNCTION [dbo].[udf_trc_4_fn] (@p_trc_number varchar(8), @Label_or_Data char(1))	returns varchar(255) AS begin declare @return varchar(255) if @Label_or_Data = 'L' select @return = 'udf_trc_4' else select @return = '' return @return end
GO
GRANT EXECUTE ON  [dbo].[udf_trc_4_fn] TO [public]
GO
