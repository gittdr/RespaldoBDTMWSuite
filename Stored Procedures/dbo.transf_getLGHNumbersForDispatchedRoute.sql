SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getLGHNumbersForDispatchedRoute] 
			(	
				@ord_route varchar(15)
				,@disp_date datetime
				,@ord_fromorder varchar(12)
			)
AS

set nocount on

	declare @from_date datetime
	declare @to_date datetime

	IF @ord_route IS NULL or LTRIM(RTRIM(@ord_route)) = ''
		SELECT @ord_route = 'UNKNOWN'

	set @from_date = convert(datetime, convert(varchar(12),@disp_date, 101) + ' 00:00:00')
	SET @to_date = CONVERT(DATETIME, CONVERT(VARCHAR(12), @disp_date, 101) + ' 23:59:59')

	SELECT DISTINCT s.lgh_number
	FROM    stops s
			JOIN orderheader o ON s.mov_number = o.mov_number
				and o.ord_route = @ord_route
				and o.ord_fromorder = @ord_fromorder
	WHERE	(
			(select stp_schdtearliest
				from stops
				where  mov_number = s.mov_number and stp_mfh_sequence=1) 
			between @from_date and @to_date
		)
	ORDER BY s.lgh_number

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_getLGHNumbersForDispatchedRoute] TO [public]
GO
