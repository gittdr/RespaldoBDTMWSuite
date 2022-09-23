SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getNonCmpLGHNumbrsForCarrier_sp] 
			(	
				@car varchar(8),
				@ord_route varchar(15)
			)
AS

set nocount on

declare @to_date datetime

IF @ord_route IS NULL or LTRIM(RTRIM(@ord_route)) = ''
	SELECT @ord_route = 'UNKNOWN'
else
	SELECT @ord_route = @ord_route + '%'

SET @to_date = CONVERT(DATETIME, CONVERT(VARCHAR(12), dateAdd(day, 1, getdate()), 101) + ' 23:59:59')

--Get unique trailers and legs for NON complete legs
SELECT DISTINCT s.lgh_number, s.stp_schdtearliest, ord_route
FROM         stops s INNER JOIN
                      assetassignment a ON s.lgh_number = a.lgh_number INNER JOIN
                      orderheader o ON s.ord_hdrnumber = o.ord_hdrnumber
WHERE     (a.asgn_type = 'CAR') AND (a.asgn_id = @car) AND (s.stp_schdtearliest <= @to_date) AND (a.asgn_status <> 'CMP') AND 
                      (o.ord_route LIKE @ord_route OR @ord_route = 'UNKNOWN')
GROUP BY s.trl_id, s.lgh_number, s.stp_schdtearliest, ord_route
ORDER BY s.stp_schdtearliest, ord_route, s.lgh_number

GO
GRANT EXECUTE ON  [dbo].[transf_getNonCmpLGHNumbrsForCarrier_sp] TO [public]
GO
