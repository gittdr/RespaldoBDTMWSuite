SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[GetLonghaulShiftLegNumbersByDate] @eqptype varchar(6), @eqpid varchar(13), @startdate datetime, @enddate datetime
as
select lgh_number from assetassignment where asgn_id = @eqpid and asgn_type = @eqptype and asgn_date <= @enddate and asgn_enddate >= @startdate order by asgn_date
GO
GRANT EXECUTE ON  [dbo].[GetLonghaulShiftLegNumbersByDate] TO [public]
GO
