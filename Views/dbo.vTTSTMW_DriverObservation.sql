SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE view [dbo].[vTTSTMW_DriverObservation]

As

select
	(select cty_name from city WITH (NOLOCK) where cty_code = dro_city) as [Observation City],
	dro_code as [Observation Code],
	left(dro_description,255) as [Observation Description],
	dro_drivercomments as [Observation Comments],
	dro_headlight as [Observation Headlight],
	dro_observationdt as [Observation Date],
	dro_observedby as [Observed By],
	dro_points as [Observation Points],
	dro_seatbelt as [Observation Seatbelt],
	dro_security as [Observation Security],
	dro_state as [Observation State],
	dro_uniform as [Observation Uniform],
	m.*
	--mpp_id as [Driver ID]
from driverobservation d
	join vTTSTMW_DriverProfile m on d.mpp_id = m.[Driver ID]




GO
GRANT SELECT ON  [dbo].[vTTSTMW_DriverObservation] TO [public]
GO
