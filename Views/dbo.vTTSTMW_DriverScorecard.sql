SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE   View [dbo].[vTTSTMW_DriverScorecard]

As

Select vTTSTMW_DriverProfile.*,
       [Calculation Type],
       Calculation,
       [Calculation Date],
	--Day
       	   (Cast(Floor(Cast([Calculation Date] as float))as smalldatetime)) as [Calculation Date Only] 
       

From vTTSTMW_DriverProfile Left Join

       (Select  mpp_id,
		'Complaints' as [Calculation Type],
	        1 as [Calculation],
	        drc_dateoccured as [Calculation Date]

	From
		drivercomplaint (NOLOCK)

	Union
		
	Select  mpp_id,
		'Accidents' as [Calculation Type],
	        1 as [Calculation],
	        dra_accidentdate as [Calculation Date]

	From
		driveraccident (NOLOCK)

	Union

	Select  mpp_id,
		'Observations' as [Calculation Type],
	        1 as [Calculation],
	        dro_observationdt as [Calculation Date]

	From
		driverobservation (NOLOCK)

	Union

	Select  lgh_driver1 as mpp_id,
		'Total Miles' as [Calculation Type],
		Sum(IsNull(stp_lgh_mileage,0)) as [Calculation],
		stp_arrivaldate as [Calculation Date]	

	From    stops (NOLOCK),legheader (NOLOCK)
	Where   stops.lgh_number = legheader.lgh_number
		And
		stops.stp_status = 'DNE'
		
	Group By lgh_driver1,stp_arrivaldate

	Union

	Select  lgh_driver1 as mpp_id,
		'Loaded Miles' as [Calculation Type],
		Sum(IsNull(stp_lgh_mileage,0)) as [Calculation],
		stp_arrivaldate as [Calculation Date]	

	From    stops (NOLOCK),legheader (NOLOCK)
	Where   stops.lgh_number = legheader.lgh_number
		And
		stops.stp_status = 'DNE'
		And
		stops.stp_loadstatus = 'LD'
	Group By lgh_driver1,stp_arrivaldate
	
	Union

	Select  lgh_driver1 as mpp_id,
		'Empty Miles' as [Calculation Type],
		Sum(IsNull(stp_lgh_mileage,0)) as [Calculation],
		stp_arrivaldate as [Calculation Date]	

	From    stops (NOLOCK),legheader (NOLOCK)
	Where   stops.lgh_number = legheader.lgh_number
		And
		stops.stp_status = 'DNE'
		And
		stops.stp_loadstatus <> 'LD'
	Group By lgh_driver1,stp_arrivaldate


) As TempDriverScores On TempDriverScores.mpp_id = vTTSTMW_DriverProfile.[Driver ID]


--Where mpp_terminationdt > GETDATE() 





GO
GRANT SELECT ON  [dbo].[vTTSTMW_DriverScorecard] TO [public]
GO
