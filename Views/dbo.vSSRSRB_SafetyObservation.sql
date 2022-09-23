SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vSSRSRB_SafetyObservation]
As

/*****************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_SafetyObservation]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vSSRSRB_SafetyObservation
 *
******************************************************************

Sample call
	
select * from [vSSRSRB_SafetyObservation]

******************************************************************
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
 * 3/19/2014 DW created new view
 *****************************************************************/

Select
	vSSRSRB_SafetyReport.*,
	obs_ID as [Observation ID],
	obs_Description as [Description],
	obs_EEObserver as [Employee Observer],
	obs_FollowUpCompleted as [FollowUpCompleted],
	obs_FollowUpCompletedDate as [FollowUp Completed Date],
	obs_FollowUpDesc as [FollowUpDesc],
	obs_FollowUpRequired as [FollowUpRequired],
	obs_MppOrEeID as [DriverOrEmployee ID],
	obs_ObservationType1 as [ObservationType1],
	obs_ObservationType2 as [ObservationType2],
	obs_ObserverAddress1 as [ObserverAddress1],
	obs_ObserverAddress2 as [ObserverAddress2],
	(select cty_name from city WITH (NOLOCK) where cty_code = obs_ObserverCity) as [Observer City],
	obs_ObserverCountry as [ObserverCountry],
	obs_ObserverCtynmstct as [Observer City Name State],
	obs_ObserverHomePhone as [Observer HomePhone],
	obs_ObserverName as [Observer Name],
	obs_ObserverState as [Observer State],
	obs_ObserverWorkPhone as [Observer WorkPhone],
	obs_ObserverZip as [Observer Zip],
	obs_OccurranceDate as [Occurrance Date],
	obs_Sequence as [Observer Sequence]
From Observation WITH (NOLOCK)
JOIN vSSRSRB_SafetyReport WITH (NOLOCK)
	ON OBSERVATION.srp_ID = vSSRSRB_SafetyReport.[Rpt Report ID]
WHERE vSSRSRB_SafetyReport.[Rpt Classification] = 'OBS'
GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyObservation] TO [public]
GO
