SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_incidentreport02_sp] @srpid int
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
	SR 17782 DPETE created 2/27/4
	PTTS23452 DPETE bring back labelfile name for type of report 
	PTS23452 avaoid extra records when employee id is UNKNOWN
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @ReportName varchar(50)
Select @ReportName = name
From labelfile 
where labeldefinition = 'SafetyClassification'
and abbr = 'INC'

Select @ReportName = IsNull(@reportName,'Incident')

Select 
 safetyreport.srp_number,
  srp_reporteddate,
  srp_Reportedby,
  reportedbyname = IsNull(e1.emp_name,''),
  srp_description = IsNull(srp_description,''),
  srp_ClassificationName = (Select name From labelfile Where labeldefinition = 'SafetyClassification' and abbr =  IsNull(srp_Classification,'UNK')),
  srp_Eventdate,
  srp_terminal,
  terminalname = (Select name From Labelfile Where abbr = IsNull(srp_terminal,'UNK') and labeldefinition = 'RevType' + 
    IsNull((Select gi_string1 From generalinfo Where gi_name = 'terminalRevType'),'1')),
  srp_EventLoc = IsNull(srp_EventLoc,''),
  srp_EventAddress1 = IsNull(srp_EventAddress1,''),
  srp_EventAddress2 = IsNull(srp_EventAddress2,''),
  srp_Eventcity = IsNull(srp_EventCity,0),
  srp_EventCtynmstct = IsNull(srp_EventCtynmstct,'UNKNOWN'),
  srp_EventState = IsNull(srp_EventState,''),
  srp_EventZip = IsNull(srp_eventZip,''),
  srp_EventCountry = IsNull(srp_EventCountry,''),
  srp_Req1Complete = IsNull(srp_Req1Complete,'N'),
  srp_Req2Complete = IsNull(srp_Req2Complete,'N'),
  srp_Req3Complete = IsNull(srp_Req3Complete,'N'),
  srp_Req4Complete = IsNull(srp_Req4Complete,'N'),
  srp_Req5Complete = IsNull(srp_Req5Complete,'N'),
  srp_Req6Complete = IsNull(srp_Req6Complete,'N'),
  srp_Req1DtDone,
  srp_Req2DtDone,
  srp_Req3DtDone,
  srp_Req4DtDone,
  srp_Req5DtDone,
  srp_Req6DtDone,
  step1 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep1'),''),
  step2 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep2'),''),
  step3 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep3'),''),
  step4 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep4'),''),
  step5 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep5'),''),
  step6 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep6'),'')
  ,srp_inscompany = IsNull(srp_inscompany,'')
 ,srp_inscoaddress = IsNull(srp_inscoaddress,'')
 ,srp_inscoctynmstct = IsNull(srp_inscoctynmstct,'')
 ,srp_inscozip = IsNull(srp_inscozip,'')
 ,srp_inscophone = isNull(srp_inscophone,'')
 ,srp_reportedtoinsurance = IsNull(srp_reportedtoinsurance,'N')
 ,srp_inscoreportdate 
 ,srp_claimnbr= isNull(srp_claimnbr,'')
  ,inc_ID,
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
  cmpname = IsNull(cmp_name,''),  -- in case complaintant is a company
  cmpaddress1 = IsNull(cmp_address1,''),
  cmpaddress2 = IsNull(cmp_address2,''),
  cmpcity = IsNull(cmp_city,0),
  cmpCtynmstct = IsNull(company.cty_nmstct,''),
  cmpstate = IsNull(cmp_state,''),
  cmpzip = IsNull(cmp_zip,''),
  cmp_phone = IsNull(cmp_Primaryphone,''),
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
  empsupervisor = Case emp_type  When 'E' Then IsNull(emp_supervisor,'UNKNOWN')else IsNull(emp_teamleader,'UNK') End,
  empterminalname = IsNull(emp_terminalname,'')

  ,Supervisorname = Case emp_type When 'E' Then 
     (Select IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,'')
       From employeeprofile ee2 Where ee2.ee_id = ee_SupervisorID)
     Else IsNull(emp_teamleader,'') End
  ,emp_occupation
  , @ReportName  
From SafetyReport,
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
       emp_terminalname = IsNull(lb.name,''),
       emp_occupation = 'Driver'
       From city RIGHT OUTER JOIN manpowerprofile ON city.cty_code = mpp_city, 
			labelfile lb
       Where mpp_id in(Select distinct inc_MppOrEeID From Incident where srp_id = @srpid)
       --And city.cty_code =* mpp_city
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
       emp_terminalname = IsNull(lb.name,''),
       emp_occupation = IsNull(ee_occupation,'')
       From employeeprofile , labelfile lb
       Where ee_id  in (Select distinct inc_MppOrEeID From Incident where srp_id = @srpid)
       and lb.labeldefinition = 'Terminal' and lb.abbr = ee_terminal
       and ee_id <> 'UNKNOWN')
    e1 RIGHT OUTER JOIN Incident ON e1.emp_ID = Incident.inc_MppOrEeID
		LEFT OUTER JOIN company ON Company.cmp_id = Incident.inc_ComplCmpID
Where Safetyreport.srp_id = @srpid
  And Incident.srp_id = safetyreport.srp_id
--  And e1.emp_ID =* inc_MppOrEeID
--  And Company.cmp_id =* inc_ComplCmpID
Order by inc_sequence
  
    

GO
GRANT EXECUTE ON  [dbo].[d_incidentreport02_sp] TO [public]
GO
