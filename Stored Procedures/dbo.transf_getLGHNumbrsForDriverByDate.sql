SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getLGHNumbrsForDriverByDate]
			(	
				@driver_id varchar(8),
				@asgn_date datetime
			)
AS

set nocount on

	declare @from_date datetime
	declare @to_date datetime

	set @from_date = convert(datetime, convert(varchar(12),@asgn_date, 101) + ' 00:00:00')
	SET @to_date = CONVERT(DATETIME, CONVERT(VARCHAR(12), @asgn_date, 101) + ' 23:59:59')

	--Get unique trailers and legs for NON complete legs
	SELECT DISTINCT s.lgh_number, s.stp_schdtearliest, ord_route
	FROM	stops s 
			INNER JOIN assetassignment a ON s.lgh_number = a.lgh_number 
				and (a.asgn_type = 'DRV') AND (a.asgn_id = @driver_id)
			INNER JOIN orderheader o ON s.mov_number = o.mov_number
	WHERE	(s.stp_schdtearliest between @from_date and @to_date and stp_mfh_sequence=1) 
		--JZ, 3/29/2006 display the std leg ealier than the assigned date, should only be one
		or (s.stp_schdtearliest < @from_date and stp_mfh_sequence=1 and a.asgn_status = 'STD')
	GROUP BY s.trl_id, s.lgh_number, s.stp_schdtearliest, ord_route
	ORDER BY s.stp_schdtearliest, ord_route, s.lgh_number

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[transf_getLGHNumbrsForDriverByDate] TO [public]
GO
