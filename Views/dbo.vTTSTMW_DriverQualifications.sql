SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[vTTSTMW_DriverQualifications]

as

select
	drq_date as [Qualification Date],
	drq_expire_date as [Qualification Expire Date],
	drq_expire_flag as [Qualification Expire Flag],
	drq_id as [Qualification ID],
	drq_quantity as [Qualification Quantity],
	drq_source as [Qualification Source],
	drq_type as [Qualification Type],
  v.*

from driverqualifications d WITH (NOLOCK)
  join vTTSTMW_DriverProfile v on d.drq_driver = v.[Driver ID]




GO
GRANT SELECT ON  [dbo].[vTTSTMW_DriverQualifications] TO [public]
GO
