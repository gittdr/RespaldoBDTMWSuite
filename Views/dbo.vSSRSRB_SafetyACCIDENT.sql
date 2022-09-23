SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE View  [dbo].[vSSRSRB_SafetyACCIDENT]
As

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_SafetyACCIDENT]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vSSRSRB_SafetyACCIDENT
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_SafetyACCIDENT]

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
 * 3/31/2014 DW changed view to add links to the Tractor, Trailer & Driver 
 **************************************************************************/

Select

	vSSRSRB_SafetyReport.*,
	[acd_ID] as [Accident ID],
	srp_id as [Report ID],
	[acd_AccidentType1] as [Accident Type 1],
	[Accident Type 1 Name] = (select top 1 labelfile.name from labelfile WITH (NOLOCK) where labeldefinition = 'AccidentType1' and labelfile.abbr = acd_AccidentType1),
	[acd_AccidentType2] as [Accident Type 2],
	[Accident Type 2 Name] = (select top 1 labelfile.name from labelfile WITH (NOLOCK) where labeldefinition = 'AccidentType2' and labelfile.abbr = acd_AccidentType2),
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
	[acd_AlcoholTestResult] as [Alcohol Test Result],
	[acd_DrugTestDone] as [Drug Test Done],
	[acd_HoursToDrugTest] as [Hours To Drug Test],
	[acd_DrugTestDate] as [Drug Test Date],
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
	IsNull((select top 1 cty_name from city WITH (NOLOCK) where cty_code=acd_TowDestCity),'') as [Tow Dest City],
	[acd_TowDestCtynmstct]  as [Tow Dest City Name State],
	[acd_TowDestState]  as [Tow Dest State],
	[acd_TowDestZip] as [Tow Dest Zip],
	[acd_TowDestCountry] as [Tow Dest Country],
	[acd_TowDestPhone] as [Tow Dest Phone],
	[acd_LawEnfDeptName] as [LawEnf DeptName],
	[acd_LawEnfDeptAddress] as [LawEnf Dept Address],
	IsNull((select top 1 cty_name from city WITH (NOLOCK) where cty_code=acd_LawEnfDeptCity),'') as [LawEnf Dept City],
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
	[acd_OVDamaged] as [OV Damaged],
	[acd_OPDamaged] as [OP Damaged],
	[mov_number] as [Move Number],
	accident.[lgh_number] as [Leg Header Number],
	[ord_number] as [Order Number],
	[cmd_code]  as [Code],
	[acd_shipper] as [Shipper ID],
	vSSRSRB_TractorProfile.Tractor,
	vSSRSRB_TractorProfile.Owner,
	vSSRSRB_TractorProfile.TrcType1,
	vSSRSRB_TractorProfile.[TrcType1 Name],
	vSSRSRB_TractorProfile.TrcType2,
	vSSRSRB_TractorProfile.[TrcType2 Name],
	vSSRSRB_TractorProfile.TrcType3,
	vSSRSRB_TractorProfile.[TrcType3 Name],
	vSSRSRB_TractorProfile.TrcType4,
	vSSRSRB_TractorProfile.[TrcType4 Name],
	vSSRSRB_TrailerProfile.Owner AS 'Trailer Owner',
	vSSRSRB_TrailerProfile.TrlType1,
	vSSRSRB_TrailerProfile.[TrlType1 Name],
	vSSRSRB_TrailerProfile.TrlType2,
	vSSRSRB_TrailerProfile.[TrlType2 Name],
	vSSRSRB_TrailerProfile.TrlType3,
	vSSRSRB_TrailerProfile.[TrlType3 Name],
	vSSRSRB_TrailerProfile.TrlType4,
	vSSRSRB_TrailerProfile.[TrlType4 Name],
	vSSRSRB_DriverProfile.[First Name],
	vSSRSRB_DriverProfile.[Last Name],
	vSSRSRB_DriverProfile.Address1,
	vSSRSRB_DriverProfile.Address2,
	vSSRSRB_DriverProfile.City,
	vSSRSRB_DriverProfile.State,
	vSSRSRB_DriverProfile.[Zip Code]
From Accident WITH (NOLOCK)
left join vSSRSRB_SafetyReport 
	on vSSRSRB_SafetyReport.[Rpt Report ID] = Accident.srp_id
Left Join vSSRSRB_TractorProfile 
	On vSSRSRB_TractorProfile.[Tractor] = [acd_tractor]
LEFT JOIN vSSRSRB_TrailerProfile 
	ON [acd_trailer1] = vSSRSRB_TrailerProfile.[Trailer ID]
LEFT JOIN vSSRSRB_DriverProfile
	ON [acd_Driver1] = vSSRSRB_DriverProfile.[Driver ID]
Where  vSSRSRB_SafetyReport.[Rpt Classification] = 'ACC'


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyACCIDENT] TO [public]
GO
