SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  View [dbo].[vTTSTMW_SafetyObservation]

As

Select
	vTTSTMW_SafetyReport.*,
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
	(select cty_name from city (NOLOCK) where cty_code = obs_ObserverCity) as [Observer City],
	obs_ObserverCountry as [ObserverCountry],
	obs_ObserverCtynmstct as [Observer City Name State],
	obs_ObserverHomePhone as [Observer HomePhone],
	obs_ObserverName as [Observer Name],
	obs_ObserverState as [Observer State],
	obs_ObserverWorkPhone as [Observer WorkPhone],
	obs_ObserverZip as [Observer Zip],
	obs_OccurranceDate as [Occurrance Date],
	obs_Sequence as [Observer Sequence]


From    Observation (NOLOCK),
        vTTSTMW_SafetyReport (NOLOCK)

Where   vTTSTMW_SafetyReport.[Rpt Report ID] = Observation.srp_ID



GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyObservation] TO [public]
GO
