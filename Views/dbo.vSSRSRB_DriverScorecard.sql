SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vSSRSRB_DriverScorecard]
As

/**
 *
 * NAME:
 * dbo.[vSSRSRB_DriverScorecard]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View bASed on the old vttstmw_DriverScorecard
 
 *
**************************************************************************

Sample call


SELECT * FROM [vSSRSRB_DriverScorecard]

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
 ***********************************************************/


Select vSSRSRB_DriverProfile.*,
       [Calculation Type],
       Calculation,
       [Calculation Date],
  	   (Cast(Floor(Cast([Calculation Date] as float))as smalldatetime)) as [Calculation Date Only] 
From vSSRSRB_DriverProfile Left Join
       (Select  mpp_id,
		'Complaints' as [Calculation Type],
	        1 as [Calculation],
	        drc_dateoccured as [Calculation Date]
	From drivercomplaint WITH (NOLOCK)

	Union
		
	Select  mpp_id,
		'Accidents' as [Calculation Type],
	        1 as [Calculation],
	        dra_accidentdate as [Calculation Date]
	From driveraccident WITH (NOLOCK)

	Union

	Select  mpp_id,
		'Observations' as [Calculation Type],
	        1 as [Calculation],
	        dro_observationdt as [Calculation Date]
	From driverobservation WITH (NOLOCK)

	Union

	Select  lgh_driver1 as mpp_id,
		'Total Miles' as [Calculation Type],
		Sum(IsNull(stp_lgh_mileage,0)) as [Calculation],
		 (Cast(Floor(Cast([stp_arrivaldate] as float))as smalldatetime)) as [Calculation Date]	
	From    stops WITH (NOLOCK),legheader WITH (NOLOCK)
	Where   stops.lgh_number = legheader.lgh_number
	And	stops.stp_status = 'DNE'
	Group By lgh_driver1, (Cast(Floor(Cast([stp_arrivaldate] as float))as smalldatetime))

	Union

	Select  lgh_driver1 as mpp_id,
		'Loaded Miles' as [Calculation Type],
		Sum(IsNull(stp_lgh_mileage,0)) as [Calculation],
		 (Cast(Floor(Cast([stp_arrivaldate] as float))as smalldatetime)) as [Calculation Date]	
	From    stops WITH (NOLOCK),legheader WITH (NOLOCK)
	Where   stops.lgh_number = legheader.lgh_number
	And stops.stp_status = 'DNE'
	And stops.stp_loadstatus = 'LD'
	Group By lgh_driver1, (Cast(Floor(Cast([stp_arrivaldate] as float))as smalldatetime))
	
	Union

	Select  lgh_driver1 as mpp_id,
		'Empty Miles' as [Calculation Type],
		Sum(IsNull(stp_lgh_mileage,0)) as [Calculation],
		(Cast(Floor(Cast([stp_arrivaldate] as float))as smalldatetime)) as [Calculation Date]	
	From    stops WITH (NOLOCK),legheader WITH (NOLOCK)
	Where   stops.lgh_number = legheader.lgh_number
	And stops.stp_status = 'DNE'
	And stops.stp_loadstatus <> 'LD'
	Group By lgh_driver1, (Cast(Floor(Cast([stp_arrivaldate] as float))as smalldatetime))
) As TempDriverScores On TempDriverScores.mpp_id = vSSRSRB_DriverProfile.[Driver ID]

GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverScorecard] TO [public]
GO
