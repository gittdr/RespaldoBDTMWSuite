SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollOutOfRouteView] AS

SELECT DISTINCT oor.oor_id as oor_id,
	oor.oor_approved as ApprovalStatus,
	oor.mov_number as mov_number,
	oor.oor_originalMileage as OriginalMileage,
	oor.oor_toleranceMiles as ToleranceMiles,
	oor.oor_toleranceType as ToleranceType,
	oor.oor_toleranceID as ToleranceID,
	oor.oor_acceptedMileage as RequestedMileage,
	oor.oor_requestby as RequestBy,
	oor.oor_requestdate as RequestDate,
	oor.oor_requestexpdate as RequestExpirationDate,
	oor.oor_decisionby as DecisionBy,
	oor.oor_decisiondate as DecisionDate,
	oor.oor_remark as Remark
FROM [dbo].[OutOfRouteApproval] oor with (nolock)
GO
GRANT DELETE ON  [dbo].[TMWScrollOutOfRouteView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollOutOfRouteView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollOutOfRouteView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollOutOfRouteView] TO [public]
GO
