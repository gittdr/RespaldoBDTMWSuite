SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create view [dbo].[vSSRSRB_DriverTraining]
AS

/**
 *
 * NAME:
 * dbo.vSSRSRB_DriverTraining
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for drivertraining
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created 
 **/

select
	drr_code as [Training Code],
	drr_description as [Training Description],
	drr_hours as [Training Hours],
	drr_instructor as [Training Instructor],
	drr_traindate as [Training Date],
	drr_type as [Training Type],
  m.*
from drivertraining d
join vSSRSRB_DriverProfile m on d.mpp_id = m.[Driver ID]

GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverTraining] TO [public]
GO
