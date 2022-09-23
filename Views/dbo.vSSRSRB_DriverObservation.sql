SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vSSRSRB_DriverObservation]
AS

/**
 *
 * NAME:
 * dbo.[vSSRSRB_DriverObservation]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View bASed on the old vttstmw_DriverObservation
 
 *
**************************************************************************

Sample call


SELECT * FROM [vSSRSRB_DriverObservation]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 * 11/18/2014 MREED added DriverObservationdate Only
 ***********************************************************/

SELECT
	(SELECT cty_name FROM city WITH (NOLOCK) WHERE cty_code = dro_city) AS [Observation City],
	dro_code AS [Observation Code],
	LEFT(dro_description,255) AS [Observation Description],
	dro_drivercomments AS [Observation Comments],
	dro_headlight AS [Observation Headlight],
	dro_observationdt AS [Observation Date],
	(Cast(Floor(Cast(dro_observationdt as float))as smalldatetime)) as [Observation Date Only],
	dro_observedby AS [Observed By],
	dro_points AS [Observation Points],
	dro_seatbelt AS [Observation Seatbelt],
	dro_security AS [Observation Security],
	dro_state AS [Observation State],
	dro_uniform AS [Observation Uniform],
	road_conditions,
	m.*
FROM driverobservation d
JOIN vSSRSRB_DriverProfile m on d.mpp_id = m.[Driver ID]


GO
GRANT DELETE ON  [dbo].[vSSRSRB_DriverObservation] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_DriverObservation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_DriverObservation] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverObservation] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_DriverObservation] TO [public]
GO
