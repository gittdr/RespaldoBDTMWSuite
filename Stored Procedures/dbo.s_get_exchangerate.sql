SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.s_get_exchangerate    Script Date: 6/1/99 11:54:39 AM ******/
CREATE PROCEDURE [dbo].[s_get_exchangerate] (	@from_curr 	varchar(12),
					@to_curr	varchar(12),
					@on_date	datetime,
                                        @ex_rate        float OUT)
AS

DECLARE @max_date datetime

	select @max_date = (select Max(cex_date)  from currency_exchange
		   	   where (cex_date <= @on_date)
		   	   And (cex_from_curr = @from_curr)
		   	   And (cex_to_curr = @to_curr))

	select @ex_rate = cex_rate 
	from currency_exchange
	where 	(cex_date = @max_date)
		And (cex_from_curr = @from_curr)
		And (cex_to_curr = @to_curr)

	select @ex_rate


GO
GRANT EXECUTE ON  [dbo].[s_get_exchangerate] TO [public]
GO
