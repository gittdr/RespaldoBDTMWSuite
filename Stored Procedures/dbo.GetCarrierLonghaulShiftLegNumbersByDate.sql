SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[GetCarrierLonghaulShiftLegNumbersByDate] @eqpid varchar(13), @plandate datetime
as
select assetassignment.lgh_number from assetassignment inner join legheader on assetassignment.lgh_number = legheader.lgh_number 
	where asgn_id = @eqpid and asgn_type = 'CAR' and lgh_plandate = @plandate order by asgn_date
GO
GRANT EXECUTE ON  [dbo].[GetCarrierLonghaulShiftLegNumbersByDate] TO [public]
GO
