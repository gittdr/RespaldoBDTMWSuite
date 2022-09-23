SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_incident_sp] @srpid int
As
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	SR 17782 DPETE created 10/13/03. 
	   If complaintant is company, name and address, etc. come from companyprofile. If
		outside person, name and address are stored in record .  If complaint is employee
		name, etc come form manpower or employeeprofile
	PTS38551 DPETE add law enformcement info to screen
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 4/25/09 DPET PTS 44645 genral SUR to add data
 * 5/20/09 DPETE PTS44645 add user columns
 * PTS47526 DPETE add bigstring for customer conformance report
 * PTS50647 DPETE for conistency allow incident tabl entry of order OR lgh OR move
 * PTS68466 SGB 04/02/2013 The column inc_trailer1 is being used for the Trailer 2 column.
 *
 **/
Select inc_ID,
  srp_id ,
  inc_sequence,
  inc_MppOrEeID,
  inc_ReportedDate,
  inc_ReceivedBy = IsNull(inc_ReceivedBy,'UNKNOWN'),
  inc_handledBy = IsNull(inc_HandledBy,'UNKNOWN'),
  inc_TicketIssued,
  inc_TrafficViolation = IsNull(inc_TrafficViolation,'UNK'),inc_Trafficviolation_t = 'TrafficViolation',
  inc_Points= IsNull(inc_Points,0),
  inc_IncidentType1= IsNull(inc_IncidentType1,'UNK'), inc_IncidentType1_t = 'IncidentType1',
  inc_IncidentType2= IsNull(inc_IncidentType2,'UNK'), inc_IncidentType2_t = 'IncidentType2',
  inc_Description= IsNull(inc_description,''),
  inc_Comment = IsNull(inc_Comment,''),
  inc_ComplaintantIs = IsNUll(inc_ComplaintantIs,'O'),  -- c=company,r=carrier (Carrier not yet implmented)
  inc_EEComplaintant= IsNull(inc_EEComplaintant,'UNKNOWN'),     -- iff complaint comes from employee
  inc_ComplCmpID= IsNull(inc_ComplCmpID,'UNKNOWN'),             -- company ID of company complaining 
  inc_ComplName= IsNull(inc_ComplName,''),         -- If not employee or company
  inc_ComplAddress1 = IsNull(inc_ComplAddress1,''),
  inc_ComplAddress2 = IsNull(inc_ComplAddress2,''),
  inc_Complcity,
  inc_ComplCtynmstct= IsNull(inc_ComplCtynmstct,''),
  inc_ComplState = IsNull(Inc_ComplState,''),
  inc_ComplZip = IsNull(inc_ComplZip,''),
  inc_ComplCountry = IsNull(inc_ComplCountry,''),
  inc_ComplHomePhone= IsNull(inc_ComplHomePhone,''),
  inc_ComplWorkPhone = IsNull(inc_ComplWorkPhone,''),
  inc_FollowupRequired= IsNull(inc_FollowupRequired,'N'),
  inc_FollowUpDesc= IsNull(inc_FollowUpDesc,''),
  inc_FollowUpCompleted= IsNull(inc_FollowUpCompleted,'N'),
  inc_FollowUpCompletedDate,
  empname = IsNull(e1.emp_name,''),
  empaddress1 = IsNull(e1.emp_address1,''),
  empaddress2 = IsNull(e1.emp_address2,''),
  empcity = IsNull(e1.emp_city,0),
  empCtynmstct = IsNull(e1.emp_Ctynmstct,''),
  empstate = IsNull(e1.emp_state,''),
  empzip = IsNull(e1.emp_zip,''),
  empCountry = IsNull(emp_Country,''),
  empssn = IsNull(e1.emp_ssn,''),
  emplicensenbr = IsNull(e1.emp_Licensenumber,''),
  emplicensestate = IsNull(e1.emp_licensestate,''),
  emplicenseclass = IsNull(e1.emp_licenseclass,'UNK'),
  emphomephone = IsNull(e1.emp_homephone,''),
  empworkphone = IsNull(e1.emp_WorkPhone,''),
  empdateofbirth = e1.emp_dateofbirth,
  emphiredate = e1.emp_hiredate,
  empterminal = IsNull(e1.emp_terminal,'UNK'),empterminal_t = 'Terminal',
  cmpname = IsNull(company.cmp_name,''),  -- in case complaintant is a company
  cmpaddress1 = IsNull(company.cmp_address1,''),
  cmpaddress2 = IsNull(company.cmp_address2,''),
  cmpcity = IsNull(company.cmp_city,0),
  cmpCtynmstct = IsNull(company.cty_nmstct,''),
  cmpstate = IsNull(company.cmp_state,''),
  cmpzip = IsNull(company.cmp_zip,''),
  cmp_phone = IsNull(company.cmp_Primaryphone,''),
  ReceivedByName = IsNull(IsNull((Select IsNull(ee_firstname + '','')+Isnull(ee_lastname,'')
    From employeeprofile Where ee_id = inc_receivedBy),
    (Select IsNull(mpp_firstname+' ','')+IsNull(mpp_lastname+' ','')+'(Driver)' From manpowerprofile
    Where mpp_Id = inc_ReceivedBy)),''),
  HandledByName = IsNull(IsNull((Select IsNull(ee_firstname + '','')+Isnull(ee_lastname,'')
    From employeeprofile Where ee_id = inc_HandledBy),
    (Select IsNull(mpp_firstname+' ','')+IsNull(mpp_lastname+' ','')+'(Driver)' From manpowerprofile
    Where mpp_Id = inc_HandledBy)),''),
  EEComplaintantName = IsNull(IsNull((Select IsNull(ee_firstname + '','')+Isnull(ee_lastname,'')
    From employeeprofile Where ee_id = inc_EEComplaintant),
    (Select IsNull(mpp_firstname+' ','')+IsNull(mpp_lastname+' ','')+'(Driver)' From manpowerprofile
    Where mpp_Id = inc_EEComplaintant)),''),
  empsupervisor = IsNull(emp_supervisor,'UNKNOWN'),
  empteamleader = IsNull(emp_teamleader,'UNK'),
  empterminalname = IsNull(emp_terminalname,'')
  /* added 7/19/07 */
  ,inc_LawEnfDeptName
  ,inc_LawEnfDeptAddress
  , inc_LawEnfDeptCity 
  , inc_LawEnfDeptCtynmstct =  IsNull(inc_LawEnfDeptctynmstct,'UNKNOWN')
  , inc_LawEnfDeptState
  , inc_LawEnfDeptCountry
  , inc_LawEnfDeptZip
  , inc_LawEnfDeptPhone
  , inc_LawEnfOfficer
  , inc_LawEnfOfficerBadge
  , inc_PoliceReportNumber
 -- exists   inc_TicketIssued   char(1)                null,  -- Y,N
  , inc_TicketIssuedTo
--  exists  inc_TrafficViolation varchar(6)           null,  -- code for reporting label 'TrafficViolation'
  , inc_TicketDesc ,
 -- exists   inc_Points tinyint
  inc_string1 = isnull(inc_string1,''),
  inc_string2 = isnull(inc_string2,''),
  inc_string3 = isnull(inc_string3,''),
  inc_string4 = isnull(inc_string4,''),
  inc_string5 = isnull(inc_string5,''),
  inc_number1 = isnull(inc_number1,0),
  inc_number2 = isnull(inc_number2,0),
  inc_number3 = isnull(inc_number3,0),
  inc_number4 = isnull(inc_number4,0),
  inc_number5 = isnull(inc_number5,0),
  inc_IncidentType3 = IsNull(inc_IncidentType3,'UNK'), inc_IncidentType3_t = 'IncidentType3',
  inc_IncidentType4 = IsNull(inc_IncidentType4,'UNK'), inc_IncidentType4_t = 'IncidentType4',
  inc_IncidentType5 = IsNull(inc_IncidentType5,'UNK'), inc_IncidentType5_t = 'IncidentType5',
  inc_IncidentType6 = IsNull(inc_IncidentType6,'UNK'), inc_IncidentType6_t = 'IncidentType6',
  inc_date1,
  inc_date2,
  inc_date3,
  inc_date4,
  inc_date5,
  incident.ord_number,
  ord_shipper,
  ord_shippername = isnull(scmp.cmp_name,''),
  ord_consignee,
  ord_consigneename = isnull(ccmp.cmp_name,''),
  ord_startdate, 
  inc_driver1 = isnull(inc_driver1,'UNKNOWN'),
  inc_driver2 = isnull(inc_driver2,'UNKNOWN'),
  inc_ttactor = isnull(inc_tractor,'UNKNOWN'),
  inc_trailer1 = isnull(inc_trailer1,'UNKNOWN'),
  --inc_trailer2 = isnull(inc_trailer1,'UNKNOWN'), PTS 68466
  inc_trailer2 = isnull(inc_trailer2,'UNKNOWN'),
  drv1name = IsNUll(drv1.mpp_firstname+' ','')+IsNull(drv1.mpp_lastname,''),
  drv2name = IsNUll(drv2.mpp_firstname+' ','')+IsNull(drv2.mpp_lastname,''),
  inc_carrier = isnull(inc_carrier,'UNKNOWN'),
  incident.lgh_number,
  incident.mov_number,
  carriername = isnull(car_name,''),
  inc_CKBox1,
  inc_CKBox2,
  inc_CKBox3,
  inc_CKBox4,
  inc_CKBox5,
  inc_bigstring1,
  delivering = 'O'
From 
  (Select 
       emp_type = 'D',
       emp_id = mpp_id,
       emp_name = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,''),
       emp_address1 = IsNull(mpp_Address1,''),
       emp_Address2 = IsNull(mpp_address2,''),
       emp_city = IsNull(mpp_city,0),
       emp_ctynmstct = IsNull(city.cty_nmstct,''),
       emp_state = IsNull(mpp_state,''),
       emp_zip = IsNull(mpp_zip,''),
       emp_ssn = IsNull(mpp_ssn,''),
       emp_LicenseNumber = IsNull(mpp_licenseNumber,''), 
       emp_LicenseState = IsNull(mpp_licenseState,0),
       emp_licenseclass = IsNull(mpp_licenseClass,'UNK'),
       emp_HomePhone = IsNull(mpp_homephone,''),
       emp_WorkPhone = '',
       emp_DateOfBirth = mpp_DateOfBirth,
       emp_HireDate = mpp_HireDate,
       emp_terminal = mpp_terminal,
       emp_Country = IsNull(mpp_country,''),
       emp_supervisor = '',
       emp_teamleader = IsNull(mpp_teamleader,'UNK'),
       emp_terminalname = IsNull(lb.name,'')
       From city RIGHT OUTER JOIN manpowerprofile ON city.cty_code = mpp_city, 
			labelfile lb
       Where mpp_id in(Select distinct inc_MppOrEeID From Incident where srp_id = @srpid)
       And lb.labeldefinition = 'terminal' and lb.abbr = mpp_terminal
       Union All
       Select
       emp_type = 'E',
       emp_id = ee_id, 
       emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),
       emp_address1 = IsNull(ee_Address1,''),
       emp_Address2 = IsNull(ee_address2,''),
       emp_city = IsNull(ee_City,0),
       emp_Ctynmstct = IsNull(ee_Ctynmstct,''),
       emp_state = IsNull(ee_state,''),
       emp_zip = IsNull(ee_zip,''),
       emp_ssn = IsNull(ee_ssn,''),
       emp_LicenseNumber = IsNull(ee_licenseNumber,''), 
       emp_LicenseState = IsNull(ee_licenseState,0),
       emp_LicenseClass = 'UNK',
       emp_HomePhone = IsNull(ee_homephone,''),
       emp_workPhone = IsNull(ee_WorkPhone,''),
       emp_DateOfBirth = ee_DateOfBirth,
       emp_HireDate = ee_HireDate,
       emp_terminal = ee_terminal,
       emp_country = IsNull(ee_country,''),
       emp_Supervisor = IsNull(ee_SupervisorID,'UNKNOWN') ,
       emp_teamleader = '',
       emp_terminalname = IsNull(lb.name,'')
       From employeeprofile , labelfile lb
       Where ee_id  in (Select distinct inc_MppOrEeID From Incident where srp_id = @srpid)
       and lb.labeldefinition = 'Terminal' and lb.abbr = ee_terminal and ee_id <> 'UNKNOWN')
    e1 RIGHT OUTER JOIN Incident ON e1.emp_ID = Incident.inc_MppOrEeID
       LEFT OUTER JOIN company ON Company.cmp_id = inc_ComplCmpID
       left outer join orderheader on incident.ord_number = orderheader.ord_number
       left outer join company scmp on ord_shipper = scmp.cmp_id
       left outer join company ccmp on ord_consignee = ccmp.cmp_id
       left outer join manpowerprofile drv1 on inc_driver1 = drv1.mpp_id
       left outer join manpowerprofile drv2 on inc_driver2 = drv2.mpp_id
       left outer join carrier on incident.inc_carrier = carrier.car_id 
Where Incident.srp_id = @srpid
--  And e1.emp_ID =* inc_MppOrEeID
--  And Company.cmp_id =* inc_ComplCmpID
Order by inc_sequence
  
    

GO
GRANT EXECUTE ON  [dbo].[d_incident_sp] TO [public]
GO
