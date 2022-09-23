SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE     View [dbo].[vTTSTMW_SafetyIncident]

As

Select

vTTSTMW_SafetyReport.*,
inc_Comment as [Comment],
inc_ComplAddress1 as [Compl Address1],
inc_ComplAddress2 as [Compl Address2],
inc_ComplaintantIs as [Complaintant Is],
IsNull((select cty_name from city (NOLOCK) where cty_code=inc_ComplCity),'') as [Compl City],
inc_ComplCmpID as [Compl CmpID],
inc_ComplCountry as [Compl Country],
inc_ComplCtynmstct as [Compl City Name State],
inc_ComplHomePhone as [Compl Home Phone],
inc_ComplName as [Compl Name],
inc_ComplState as [Compl State],
inc_ComplWorkPhone as [Compl Work Phone],
inc_ComplZip as [Compl Zip],
inc_Description as [Description],
inc_EEComplaintant as [EE Complaintant],
inc_FollowUpCompleted as [FollowUp Completed],
inc_FollowUpCompletedDate as [FollowUp Completed Date],
inc_FollowUpDesc as [FollowUp Desc],
inc_FollowUpRequired as [FollowUp Required],
inc_HandledBy as [HandledBy],
inc_ID as [Incident ID],
inc_IncidentType1 as [Incident Type1],
inc_IncidentType2 as [Incident Type2],
inc_MppOrEeID as [Mpp Or EeID],
inc_Points as [Points],
inc_ReceivedBy as [Received By],
inc_ReportedDate as [Reported Date],
inc_Sequence as [Incident Sequence],
inc_TicketIssued as [Ticket Issued],
inc_TrafficViolation as [Traffic Violation],
srp_ID as [Report ID]

From Incident (NOLOCK),vTTSTMW_SafetyReport (NOLOCK)

Where   vTTSTMW_SafetyReport.[Rpt Report ID] = Incident.srp_id
	







GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyIncident] TO [public]
GO
