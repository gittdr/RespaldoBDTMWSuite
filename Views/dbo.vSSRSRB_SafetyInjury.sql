SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View  [dbo].[vSSRSRB_SafetyInjury]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_SafetyInjury
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Safety and injury report
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_SafetyInjury


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Safety and injury information
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created SSRS version of this view
 **/
Select
	vSSRSRB_SafetyReport.*,
	[inj_ID] as [Injury ID],
	[inj_sequence] as [Injury Sequence],
	[inj_ReportedDate] as [Injury Reported Date],
	(Cast(Floor(Cast([inj_ReportedDate] as float))as smalldatetime)) AS [Injury Reported Date Only],
	[inj_Description] as [Injury Description],
	[inj_Comment] as [Injury Comment],
	[inj_HowOccurred] as [Injury Has Occured],
	[inj_DateOfFullRelease] as [Injury Date Of Full Release],
	(Cast(Floor(Cast([inj_DateOfFullRelease]  as float))as smalldatetime)) AS [Injury Date Of Full Release Date Only],
	[inj_PersonIs] as [Injury Person Is],
	[inj_MppOrEeID] as [Injury MppOrEeID],
	[inj_Name] as [Injury Name],
	[inj_Address1] as [Injury Address1],
	[inj_Address2] as [Injury Address2],
	[inj_City] as [Injury City],
	[inj_Ctynmstct] as [Injury CityNameState],
	[inj_State] as [Injury State],
	[inj_zip] as [Injury Zip],
	[inj_Country] as [Injury Country],
	[inj_HomePhone] as [Injury HomePhone],
	[inj_WorkPhone] as [Injury WorkPhone],
	[inj_LastDateWorked] as [Injury LastDateWorked],
	[inj_ExpectedReturn] as [Injury ExpectedReturn],
	[inj_ClaimInDoubt] as [Injury ClaimInDoubt],
	[inj_InjuryType1] as [Injury InjuryType1],
	[inj_InjuryType2] as [Injury InjuryType2],
	[inj_IsFatal] as [Injury Is Fatal],
	[inj_TreatedAtScene] as [Injury Treated At Scene],
	[inj_AtSceneCaregiver] as [Injury At Scene Caregiver],
	[inj_TreatedAwayFromScene] as [Injury Treated Away From Scene],
	[inj_ReportedToInsurance] as [Injury Reported To Insurance],
	[inj_InsCoReportDate] as [Injury InsCoReport Date],
	(Cast(Floor(Cast([inj_InsCoReportDate]  as float))as smalldatetime)) AS [Injury InsCoReport Date Only],
	[inj_maritalstatus] as [Injury Marital Status],
	[inj_gender] as [Injury Gender],
	[inj_nbrdependents] as [Injury Number Of Dependents],
	[inj_NextSchedAppt] as [Injury Next Schedule Appt],
	[inj_DateofBirth] as [Injury Date Of Birth],
	[inj_ssn] as [Injury SSN],
	[inj_workstate] as [Injury WorkState],
	[inj_occupation] as [Injury Occupation],
	[inj_medicalrestrictions] as [Injury Medical Restrictions],
	[acd_ID] as [Accident ID],
	[acd_AccidentType1] as [Accident Type 1],
	[acd_AccidentType2] as [Accident Type 2],
	[acd_VehicleRole]  as [Vehicle Role],
	[acd_Description] as [Description],
	[acd_Comment]  as [Comments],
	[acd_DOTRecordable] as [DOT Recordable],
	[acd_RoadSituation] as [Road Situation],
	[acd_Illumination] as [Illumination],
	[acd_WeatherType]  as [Weather Type],
	[acd_RoadSurface]  as [Road Surface],
	[acd_NbrOfInjuries] as [Nbr Of Injuries],
	[acd_NbrOfFatalities] as [Nbr Of Fatalities],
	[acd_AlcoholTestDone] as [Alcohol Test Done],
	[acd_HoursToAlcoholTest] as [HoursToA lcoholTest],
	[acd_AlcoholTestDate] as [Alcohol Test Date],
	(Cast(Floor(Cast([acd_AlcoholTestDate]  as float))as smalldatetime)) AS [Alcohol Test Date Only],
	[acd_AlcoholTestResult] as [Alcohol Test Result],
	[acd_DrugTestDone] as [Drug Test Done],
	[acd_HoursToDrugTest] as [Hours To Drug Test],
	[acd_DrugTestDate] as [Drug Test Date],
	(Cast(Floor(Cast([acd_DrugTestDate] as float))as smalldatetime)) AS [Drug Test Date Only],
	[acd_DrugTestResult] as [Drug Test Result],
	[acd_CorrectiveActionReq] as [Corrective Action Req],
	[acd_DriverAtWheel] as [DriverAtWheel],
	[acd_Driver1] as [Driver1],
	[acd_Driver2] as [Driver2],
	[acd_tractor] as [Tractor ID],
	[acd_trailer1] as [Trailer1 ID],
	[acd_trailer2] as [Trailer2 ID],
	[acd_carrier] as [Carrier ID],
	[acd_Pictures] as [Pictures],
	[acd_CVDamage] as [CV Damage],
	[acd_Trl1damage] as [Trailer1 Damage],
	[acd_Trl2Damage] as [Trailer2 Damage],
	[acd_TrcDamage] as [Tractor Damage],
	[acd_VehicleTowed]  as [Vehicle Towed],
	[acd_TowDestination] as [Tow Destination],
	[acd_TowDestAddress]  as [Tow Dest Address],
	IsNull((select cty_name from city (NOLOCK) where cty_code=acd_TowDestCity),'') as [Tow Dest City],
	[acd_TowDestCtynmstct]  as [Tow Dest City Name State],
	[acd_TowDestState]  as [Tow Dest State],
	[acd_TowDestZip] as [Tow Dest Zip],
	[acd_TowDestCountry] as [Tow Dest Country],
	[acd_TowDestPhone] as [Tow Dest Phone],
	[acd_LawEnfDeptName] as [LawEnf DeptName],
	[acd_LawEnfDeptAddress] as [LawEnf Dept Address],
	IsNull((select cty_name from city (NOLOCK) where cty_code=acd_LawEnfDeptCity),'') as [LawEnf Dept City],
	[acd_LawEnfDeptCtynmstct] as [LawEnf Dept City Name State],
	[acd_LawEnfDeptState]  as [LawEnf Dept State],
	[acd_LawEnfDeptCountry] as [LawEnf Dept Country],
	[acd_LawEnfDeptZip] as [LawEnf Dept Zip],
	[acd_LawEnfDeptPhone] as [LawEnf Dept Phone],
	[acd_LawEnfOfficer] as [LawEnf Officer],
	[acd_LawEnfOfficerBadge] as [LawEnf Officer Badge],
	[acd_PoliceReportNumber] as [Police Report Number],
	[acd_TicketIssued] as [Ticket Issued],
	[acd_TicketIssuedTo] as [Ticket IssuedTo],
	[acd_TrafficViolation] as [Traffic Violation],
	[acd_TicketDesc] as [Ticket Desc],
	[acd_Points] as [Points],
	[acd_AccdntPreventability] as [Accident Prevent Ability],
	[acd_HazMat] as [Hazmat],
	[acd_EstSpeed] as [Estd Speed],
	[acd_RoadType] as [Road Type],
	[acd_ReportedToInsuranceCo]  as [Reported To Insurance Co],
	[acd_InsReportDate] as [Ins Report Date],
	(Cast(Floor(Cast([acd_InsReportDate] as float))as smalldatetime)) AS [Ins Report Date Only],
	[acd_OVDamaged] as [OV Damaged],
	[acd_OPDamaged] as [OP Damaged],
	[mov_number] as [Move Number],
	[lgh_number] as [Leg Header Number],
	[ord_number] as [Order Number],
	[cmd_code]  as [Code],
	[acd_shipper] as [Shipper ID]

From    vSSRSRB_SafetyReport  with(nolock) 
Inner Join Injury  with(nolock)  On Injury.srp_ID = vSSRSRB_SafetyReport.[Rpt Report ID]
Left Join Accident  with(nolock)  on Accident.[srp_id] = vSSRSRB_SafetyReport.[Rpt Report ID]

Where   vSSRSRB_SafetyReport.[Rpt Classification] = 'INJ'

GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyInjury] TO [public]
GO
