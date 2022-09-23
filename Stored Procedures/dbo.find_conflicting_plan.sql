SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[find_conflicting_plan] 
	@movenum int out,
	@startdate datetime out,
	@enddate datetime out,
	@asgntype char(6),
	@asgnid char (13)
AS
-- PTS 3436 PG 1/8/97 changed stops in From clause to legheader

SET ROWCOUNT 1		
SELECT 	@movenum = d.mov_number,
	@startdate = asgn_date,
	@enddate = asgn_enddate
FROM 	assetassignment, legheader d
WHERE 	asgn_status = 'PLN'
	AND asgn_type = @asgntype
	AND asgn_id = @asgnid
	AND asgn_date <= @enddate
	AND d.lgh_number = assetassignment.lgh_number 
	AND d.mov_number <> @movenum
SET ROWCOUNT 0	
GO
GRANT EXECUTE ON  [dbo].[find_conflicting_plan] TO [public]
GO
