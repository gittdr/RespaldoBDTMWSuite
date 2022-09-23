SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 CREATE FUNCTION [dbo].[udf_trl_9_fn] (@p_trl_number varchar(8), @Label_or_Data char(1))	returns varchar(255) AS begin declare @return varchar(255) if @Label_or_Data = 'L' select @return = 'udf_trl_9' else select @return = '' return @return end
GO
GRANT EXECUTE ON  [dbo].[udf_trl_9_fn] TO [public]
GO
