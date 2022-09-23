SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/**
 *
 * NAME:
 * dbo.vSSRSRB_DriverQualifications
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/

CREATE view [dbo].[vSSRSRB_DriverQualifications]

as

select
	(Cast(Floor(Cast(drq_date as float))as smalldatetime)) as [Qualification Date],
	(Cast(Floor(Cast(drq_expire_date as float))as smalldatetime)) as [Qualification Expire Date],
	DATEDIFF(D,(Cast(Floor(Cast(GETDATE() as float))as smalldatetime)),(Cast(Floor(Cast(drq_expire_date as float))as smalldatetime))) as [Expires in Days],
	drq_expire_flag as [Qualification Expire Flag],
	drq_id as [Qualification ID],
	drq_quantity as [Qualification Quantity],
	drq_source as [Qualification Source],
	drq_type as [Qualification Type],
	ISNULL((select top 1 name from labelfile where labeldefinition = 'DrvAcc' and drq_type = abbr),'') as [Qualification Name],
  v.*

from driverqualifications d WITH (NOLOCK)
  join vSSRSRB_DriverProfile v on d.drq_driver = v.[Driver ID]


GO
GRANT DELETE ON  [dbo].[vSSRSRB_DriverQualifications] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_DriverQualifications] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_DriverQualifications] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverQualifications] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_DriverQualifications] TO [public]
GO
