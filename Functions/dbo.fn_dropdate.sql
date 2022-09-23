SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fn_dropdate] (@trl_id VARCHAR (13), @exp_code VARCHAR (6), @start_date DATETIME, @now DATETIME) RETURNS DATETIME
AS 
BEGIN
	DECLARE @dropdate DATETIME
	
	SELECT @dropdate = ISNUll ((select Min (exp_expirationdate)
				from containerexpiration
				where exp_code = @exp_code
				and exp_id = @trl_id
				and exp_expirationdate >= @start_date
				and exp_expirationdate < '2049-12-31 23:58:00'), @now)
	RETURN @dropdate
END
GO
GRANT EXECUTE ON  [dbo].[fn_dropdate] TO [public]
GO
