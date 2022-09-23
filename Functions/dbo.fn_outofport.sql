SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fn_outofport] (@trl_id VARCHAR (13), @exp_code VARCHAR (6), @start_date DATETIME, @end_date DATETIME, @now DATETIME) RETURNS DATETIME
AS 
BEGIN
	DECLARE @outofport DATETIME,
	        @dropdate  DATETIME
	        
	SELECT @dropdate = dbo.fn_dropdate (@trl_id, @exp_code, @start_date, @now)
	
	IF @dropdate > @end_date 
		SELECT @outofport = IsNull (MAX (exp_compldate), (SELECT MAX (evt_enddate)
															FROM event(nolock)
															WHERE evt_enddate < @dropdate
															AND evt_trailer1 = @trl_id
															AND evt_sequence= 1
															AND evt_status = 'DNE'))
			FROM containerexpiration
			WHERE exp_id = @trl_id
			  AND exp_compldate <= @dropdate
	ELSE
		SELECT @outofport = IsNull (MAX (exp_compldate), (SELECT MAX (evt_enddate)
															FROM event (nolock)
															WHERE evt_enddate < @end_date
															AND evt_trailer1 = @trl_id
															AND evt_sequence= 1
															AND evt_status = 'DNE'))
			FROM containerexpiration
			WHERE exp_id = @trl_id
			  AND exp_compldate <= @end_date

	RETURN ISNULL (@outofport, @end_date)
END
GO
GRANT EXECUTE ON  [dbo].[fn_outofport] TO [public]
GO
