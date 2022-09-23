SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  FUNCTION [dbo].[locked_by_fn](@mov_number int)  
RETURNS VARCHAR(20)
AS 
BEGIN 
	RETURN (select top 1 locked_by from recordlock where ord_hdrnumber = @mov_number order by session_date desc)
END  
GO
GRANT EXECUTE ON  [dbo].[locked_by_fn] TO [public]
GO
