SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  FUNCTION [dbo].[locked_date_fn](@mov_number int)  
RETURNS datetime
AS 
BEGIN 
	RETURN (select top 1 session_date from recordlock where ord_hdrnumber = @mov_number order by session_date desc)
END
GO
GRANT EXECUTE ON  [dbo].[locked_date_fn] TO [public]
GO
