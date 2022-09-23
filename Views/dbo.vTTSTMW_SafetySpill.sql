SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE     View [dbo].[vTTSTMW_SafetySpill]

As

Select

vTTSTMW_SafetyReport.*,
cmd_code as [Commodity Code],
lgh_number as [Leg Header Number],
mov_number as [Move Number],
ord_number as [Order Number],
spl_AccdntPreventability as [Accident Preventability],
spl_ActionTaken as [Action Taken],
spl_carrier as [Carrier ID],
spl_Comment as [Comment],
spl_Damage as [Damage],
spl_Description as [Description],
spl_Driver1 as [Driver1],
spl_Driver2 as [Driver2],
spl_HazMat as [HazMat],
spl_ID as [ID],
spl_LawEnfDeptAddress as [LawEnf Dept Address],
IsNull((select cty_name from city (NOLOCK) where cty_code=spl_LawEnfDeptCity),'') as [LawEnf Dept City],
spl_LawEnfDeptCountry as [LawEnf Dept Country],
spl_LawEnfDeptctynmstct as [LawEnf Dept City Name State],
spl_LawEnfDeptName as [LawEnf Dept Name],
spl_LawEnfDeptPhone as [LawEnf Dept Phone],
spl_LawEnfDeptState as [LawEnf Dept State],
spl_LawEnfDeptZip as [LawEnf Dept Zip],
spl_LawEnfOfficer as [LawEnf Officer],
spl_LawEnfOfficerBadge as [LawEnf OfficerBadge],
spl_OwnerAddress1 as [Owner Address1],
spl_OwnerAddress2 as [Owner Address2],
IsNull((select cty_name from city (NOLOCK) where cty_code=spl_OwnerCity),'') as [Owner City],
spl_OwnerCmpID as [Owner CmpID],
spl_OwnerCountry as [Owner Country],
spl_OwnerCtynmstct as [Owner City Name State],
spl_OwnerIs as [OwnerIs],
spl_OwnerName as [Owner Name],
spl_OwnerPhone as [Owner Phone],
spl_OwnerState as [Owner State],
spl_OwnerZip as [Owner Zip],
spl_Pictures as [Pictures],
spl_PoliceReportNumber as [Police Report Number],
spl_shipper as [Shipper ID],
spl_SpillType1 as [Spill Type1],
spl_SpillType2 as [Spill Type2],
spl_TicketIssued as [Ticket Issued],
spl_tractor as [Tractor ID],
spl_TrafficViolation as [Traffic Violation],
spl_trailer1 as [Trailer1 ID],
spl_trailer2 as [Trailer2 ID],
srp_ID as [Report ID]

From Spill (NOLOCK),vTTSTMW_SafetyReport (NOLOCK)

Where   vTTSTMW_SafetyReport.[Rpt Report ID] = srp_ID





GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetySpill] TO [public]
GO
