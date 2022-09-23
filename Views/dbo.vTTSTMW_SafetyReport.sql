SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO













CREATE           View [dbo].[vTTSTMW_SafetyReport]

As

Select

srp_ID  [Rpt Report ID],
srp_number  [Rpt Number],
srp_EventDate  [Rpt Event Date],
srp_EventLocIs  [Rpt Event Location Is],
Case When srp_EventLocIs = 'A' Then
	(select acd_dotRecordable from Accident (NOLOCK) where Accident.srp_id = SafetyReport.srp_id)
     Else
	'NA'
End as [Rpt DOT Recordable],
srp_EventLocCmpID  [Rpt Event Location Company ID],
srp_EventLoc  [Rpt Event Location],
srp_EventAddress1  [Rpt Event Address1],
srp_EventAddress2  [Rpt Event Address2],
IsNull((select cty_name from city (NOLOCK) where cty_code=srp_EventCity),'') as [Rpt Event City],
srp_Eventctynmstct  [Rpt Event City Name State],
srp_EventState  [Rpt Event State],
srp_EventZip  [Rpt Event Zip],
srp_EventCountry  [Rpt Event Country],
srp_OnPremises  [Rpt OnPremises],
srp_description  [Rpt Description],
srp_Classification  [Rpt Classification],
srp_SafetyType1  [Rpt SafetyType1],
srp_SafetyType2  [Rpt SafetyType2],
srp_SafetyType3  [Rpt SafetyType3],
srp_SafetyType4  [Rpt SafetyType4],
srp_SafetyStatus  [Rpt SafetyStatus],
srp_ReportedBy  [Rpt ReportedBy],
srp_ReportedDate  [Rpt Reported Date],
srp_Req1Complete  [Rpt Req1Complete],
srp_Req1DtDone  [Rpt Req1DtDone],
srp_Req2Complete  [Rpt Req2Complete],
srp_Req2DtDone  [Rpt Req2DtDone],
srp_Req3Complete  [Rpt Req3Complete],
srp_Req3DtDone  [Rpt Req3DtDone],
srp_Req4Complete  [Rpt Req4Complete],
srp_Req4DtDone  [Rpt Req4DtDone],
srp_Req5Complete  [Rpt Req5Complete],
srp_Req5DtDone  [Rpt Req5DtDone],
srp_Req6Complete  [Rpt Req6Complete],
srp_Req6DtDone  [Rpt Req6DtDone],
srp_ResponsibleParty  [Rpt Responsible Party],
srp_ResponsiblePartyDesc  [Rpt Responsible Party Description],
srp_EstCost  [Rpt Estimated Cost],
srp_TotalPaidByCmp  [Rpt Total PaidBy Company],
srp_TotalPaidByIns  [Rpt Total PaidBy Insurance],
srp_TotalReserves  [Rpt Total Reserves],
srp_TotalRecovered  [Rpt Total Recovered],
srp_terminal  [Rpt Terminal],
srp_tractor  [Rpt Tractor ID],
srp_trailer1  [Rpt Trailer1 ID],
srp_trailer2  [Rpt Trailer2 ID],
srp_driver1  [Rpt Driver1 ID],
srp_driver2  [Rpt Driver2 ID],
Case When srp_mpporeeid = 'UNKNOWN' Then srp_driver1 Else srp_mpporeeid End  [Rpt DriverOrEmployee ID],
srp_mpporeeid [Rpt Employee ID],
[Rpt DriverOrEmployee Name] = IsNull(IsNull((select mpp_lastfirst from manpowerprofile (NOLOCK) where srp_driver1 = manpowerprofile.mpp_id and manpowerprofile.mpp_id <> 'UNKNOWN'),(select IsNull(ee_lastname,'') + ',' + IsNull(ee_firstname,'') from employeeprofile (NOLOCK) where srp_mpporeeid = employeeprofile.ee_ID and ee_ID <> 'UNKNOWN')),(select mpp_lastfirst from manpowerprofile (NOLOCK) where srp_mpporeeid = manpowerprofile.mpp_id)),
srp_carrier  [Rpt Carrier ID],
cmd_code [Rpt Commodity Code],
srp_Hazmat  [Rpt Hazmat],
srp_inscompany  [Rpt Insurance Company],
srp_inscoaddress  [Rpt InsuranceCo Address],
IsNull((select cty_name from city (NOLOCK) where cty_code=srp_inscocity),'') as [Rpt InsuranceCo City],
srp_inscoctynmstct  [Rpt InsuranceCo City Name State],
srp_inscostate  [Rpt InsuranceCo State],
srp_inscozip  [Rpt InsuranceCo Zip],
srp_inscocountry  [Rpt InsuranceCo Country],
srp_inscophone  [Rpt InsuranceCo Phone Number],
srp_reportedtoinsurance  [Rpt ReportedToInsurance],
srp_InsCoReportDate  [Rpt InsuranceCo Report Date],
srp_claimnbr  [Rpt Claim Number],
srp_inspolicynbr  [Rpt Insurance Policy NBR],
ord_number [Rpt Order Number],
mov_number [Rpt Move Number],
lgh_number [Rpt Leg Header Number],
[Bill To ID] = IsNull((select top 1 ivh_billto from invoiceheader (NOLOCK) where invoiceheader.ord_number = SafetyReport.ord_number), (select ord_billto from orderheader (NOLOCK) where orderheader.ord_number = SafetyReport.ord_number)),
RevType1=(select ord_revtype1 from orderheader (NOLOCK) where orderheader.ord_number = safetyreport.ord_number),
RevType2=(select ord_revtype2 from orderheader (NOLOCK) where orderheader.ord_number = safetyreport.ord_number),
RevType3=(select ord_revtype3 from orderheader (NOLOCK) where orderheader.ord_number = safetyreport.ord_number),
RevType4=(select ord_revtype4 from orderheader (NOLOCK) where orderheader.ord_number = safetyreport.ord_number),
[Rpt Picture Count] = IsNull((Select count(*) from ps_blob_data (NOLOCK) where blob_table = 'safetyreport' and blob_key = SafetyReport.srp_number),0)



From SafetyReport (NOLOCK)













GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyReport] TO [public]
GO
