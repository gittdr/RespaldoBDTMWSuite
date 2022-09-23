SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_incidentreport03_sp] @srpid int
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
	SR 47526 9/2/09 DPETE for DisTech
 * 
 *
 **/

declare @incmpporeeid varchar(8), @inchandledby varchar(8)


declare @associates table( id varchar(8),
firstname varchar(40) null,
lastname varchar(40) null,
fullname varchar(100) null)

declare @shipper varchar(200),@consignee varchar(200),@movnumber varchar(15)
declare @eerid int,@eername varchar(100), @eerdate datetime, @eercomment varchar(4000)
declare @terminalnumber char(1)

select @terminalnumber = left(gi_string1,1) from generalinfo where gi_name = 'TerminalRevType'
select @terminalnumber = case isnull(@terminalnumber,'') when '1' then '1' when '2' then '2' when '3' then '3' when '4' then '4' else '1' end

/* wnats first entry in EE response */
select @eerid = (select min(eer_id) from eeresponse where srp_id = @srpid)
select @eername = eer_name 
,@eercomment = eer_comment
,@eerdate = eer_date
from eeresponse
where eer_id = @eerid

select @incmpporeeid = inc_mpporeeid,@inchandledby = inc_handledby
from incident where srp_id = @srpid

insert into @associates(id,firstname,lastname,fullname)
select mpp_id
,firstname = isnull(mpp_firstname,'')
,lastname = isnull(mpp_lastname,'')
,rtrim(isnull(mpp_firstname+' ','')+isnull(mpp_lastname,''))
from manpowerprofile
where mpp_id = @incmpporeeid

insert into @associates(id,firstname,lastname,fullname)
select ee_id
,firstname = isnull(ee_firstname,'')
,lastname = isnull(ee_lastname,'')
,rtrim(isnull(ee_firstname+' ','')+isnull(ee_lastname,''))
from employeeprofile
where ee_id = @incmpporeeid
AND @incmpporeeid <> 'UNKNOWN'

If @inchandledby <> @incmpporeeid 
  BEGIN
    insert into @associates(id,firstname,lastname,fullname)
    select mpp_id
    ,firstname = isnull(mpp_firstname,'')
    ,lastname = isnull(mpp_lastname,'')
    ,rtrim(isnull(mpp_firstname+' ','')+isnull(mpp_lastname,''))
    from manpowerprofile
    where mpp_id = @inchandledby

    insert into @associates(id,firstname,lastname,fullname)
    select ee_id
    ,firstname = isnull(ee_firstname,'')
    ,lastname = isnull(ee_lastname,'')
    ,rtrim(isnull(ee_firstname+' ','')+isnull(ee_lastname,''))
    from employeeprofile
    where ee_id = @inchandledby
    and @inchandledby <> 'UNKNOWN'
  END


Select @shipper = isnull(cmp_name + ',  '+cty_name+', '+cty_state,''),@movnumber = convert(varchar(15),orderheader.mov_number)
from incident
left outer join orderheader on incident.ord_number = orderheader.ord_number 
left join company on orderheader.ord_shipper = cmp_id
left join city on cmp_city = cty_code
where incident.srp_id = @srpid

select @shipper = isnull(@shipper,' ')
select @movnumber = isnull(@movnumber,' ')


Select @consignee = isnull(cmp_name + ',  '+cty_name+', '+cty_state,'')
from incident
left outer join orderheader on incident.ord_number = orderheader.ord_number 
left join company on orderheader.ord_consignee = cmp_id
left join city on cmp_city = cty_code
where incident.srp_id = @srpid

select @consignee = isnull(@consignee,' ')

Select 
 safetyreport.srp_number,
  srp_reporteddate,
  srp_Reportedby,
  srp_description = IsNull(srp_description,''),
  srp_ClassificationName = (Select name From labelfile Where labeldefinition = 'SafetyClassification' and abbr =  IsNull(srp_Classification,'UNK')),
  srp_Eventdate,
  srp_terminal,
  terminalname = (Select name From Labelfile Where abbr = IsNull(srp_terminal,'UNK') and labeldefinition = 'RevType' + @terminalnumber),
  srp_EventLoc = IsNull(srp_EventLoc,''),
  srp_EventAddress1 = IsNull(srp_EventAddress1,''),
  srp_EventAddress2 = IsNull(srp_EventAddress2,''),
  srp_Eventcity = IsNull(srp_EventCity,0),
  srp_EventCtynmstct = IsNull(cty_name,''),
  srp_EventState = IsNull(cty_state,''),
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
  mpporee_firstname = isnull(incmpporee.firstname,''),
  mpporee_lastname = isnull(incmpporee.lastname,''),
  handleby_fullname = isnull(inchandleby.fullname,''),
  ord_number = isnull(incident.ord_number,''),
  responsibleparty = labl.name,
  shipper = @shipper,
  consignee = @consignee,
  doessopneed = inc_ckbox1,
  whatsopneed = inc_bigstring1,
  eername = @eername,
  eerdate = @eerdate,
  eercomment = @eercomment,
  inc_string1,
  srp_reportedbyname,
  movenumber = @movnumber
From SafetyReport
   RIGHT OUTER JOIN Incident ON safetyreport.srp_id = Incident.srp_id
   LEFT OUTER JOIN @associates incmpporee on inc_mpporeeid = incmpporee.id
   LEFT OUTER JOIN @associates inchandleby on inc_handledby = inchandleby.id
   left outer join (select abbr,name from labelfile where labeldefinition = 'ResponsibleParty') labl on SafetyReport.srp_responsibleparty = labl.abbr
   left outer join city on srp_eventcity = cty_code
Where Safetyreport.srp_id = @srpid
 Order by inc_sequence
 


GO
GRANT EXECUTE ON  [dbo].[d_incidentreport03_sp] TO [public]
GO
