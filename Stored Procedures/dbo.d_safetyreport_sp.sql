SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 
Create Proc [dbo].[d_safetyreport_sp] @srpnbr varchar(20)   
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
 SR 17782 DPETE created 10/13/03  
 DPETE 22516 add srp_cargodamagecost
 DPETE PTS 32543 (33171) add indication that pictures exist
 * 11/1/2007.01 ? PTS40115 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * DPETE PTS 44645 add some user fields
 * DPETE PTS50647 return ord_booked_revtype1, lgh_booked_revtype1, ord_billto, ord_shipper,ord_consignee
 *         added to safetyreport.  Changed retrieval of reported by name.
 * DPETE PTS50647 add branch and carrier info to datawindow
 * DPETE PTS50984 Command asks to also see the paretn of the branches (bookign and executing)
 *    
 **/

DECLARE @v_srpreportedby varchar(8),@v_reportedbyname varchar(103) 

Select @v_srpreportedby = srp_reportedby from safetyreport where srp_number = @srpnbr  

If @v_srpreportedby is null or @v_srpreportedby = 'UNKNOWN' 
  Select @v_reportedbyname = ''
else
  BEGIN
    if exists (select 1 from manpowerprofile where mpp_id = @v_srpreportedby)
      Select @v_reportedbyname  = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,'')
      From manpowerprofile where mpp_id = @v_srpreportedby
    Else
      BEGIN
        If exists (select 1 from employeeprofile where employeeprofile.ee_id  = @v_srpreportedby)
          Select @v_reportedbyname  = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,'')
          From employeeprofile 
          Where employeeprofile.ee_id = @v_srpreportedby
        else
          Select @v_reportedbyname  = ''
      END 
  END

    


  
Select 
  srp_ID,  
  srp_number,  
  srp_description,  
  srp_Classification = IsNull(srp_Classification,'UNK'),srp_Classification_t = 'SafetyClassification',  
  srp_SafetyType1 = IsNull(srp_SafetyType1,'UNK'), srp_SafetyeType1_t = 'SafetyType1',  
  srp_SafetyType2 = IsNull(srp_SafetyType2,'UNK'), srp_SafetyeType1_t = 'SafetyType2',  
  srp_SafetyType3 = IsNull(srp_SafetyType3,'UNK'), srp_SafetyeType1_t = 'SafetyType3',  
  srp_SafetyType4 = IsNull(srp_SafetyType4,'UNK'), srp_SafetyeType1_t = 'SafetyType4',  
  srp_SafetyStatus = IsNull(srp_safetyStatus,'UNK'), srp_SafetyStatus_t = 'SafetyStatus',  
  srp_Reportedby = IsNull(srp_Reportedby,'UNKNOWN'),  
  srp_Req1Complete = IsNUll(srp_Req1Complete,'N'),  
  srp_Req2Complete = IsNUll(srp_Req2Complete,'N'),  
  srp_Req3Complete = IsNUll(srp_Req3Complete,'N'),  
  srp_Req4Complete = IsNUll(srp_Req4Complete,'N'),  
  srp_Req5Complete = IsNUll(srp_Req5Complete,'N'),  
  srp_Req6Complete = IsNUll(srp_Req6Complete,'N'),  
  srp_ResponsibleParty = IsNull(srp_responsibleParty,'UNK'),srP_ResponsibleParty_t = 'ResponsibleParty',  
  srp_ResponsiblePartyDesc,  
  Accidentcount = (Select Count(*) From Accident Where Accident.srp_id = SafetyReport.srp_id),  
  InjuryCount = (Select Count(*) From Injury Where Injury.srp_id = SafetyReport.srp_id),  
  IncidentCount = (Select Count(*) From Incident Where Incident.srp_id = SafetyReport.srp_id),  
  ObservationCount = (Select Count(*) From Observation Where Observation.srp_id = SafetyReport.srp_id),  
  srp_req1complete_t = (Select gi_string1 From Generalinfo Where gi_Name = 'SafetyReqStep1' ),  
  srp_req2complete_t = (Select gi_string1 From Generalinfo Where gi_Name = 'SafetyReqStep2' ),  
  srp_req3complete_t = (Select gi_string1 From Generalinfo Where gi_Name = 'SafetyReqStep3' ),  
  srp_req4complete_t = (Select gi_string1 From Generalinfo Where gi_Name = 'SafetyReqStep4' ),  
  srp_req5complete_t = (Select gi_string1 From Generalinfo Where gi_Name = 'SafetyReqStep5' ),  
  srp_req6complete_t = (Select gi_string1 From Generalinfo Where gi_Name = 'SafetyReqStep6' ),  
  srp_Req1DtDone,  
  srp_Req2DtDone,  
  srp_Req3DtDone,  
  srp_Req4DtDOne,  
  srp_Req5DtDOne,  
  srp_Req6DtDone,  
  srp_EstCost = ISNull(srp_EstCost,0),  
  srp_TotalPaidByCmp = IsNull( srp_TotalPaidByCmp,0),  
  srp_TotalPaidByIns = IsNull(srp_TotalPaidByIns,0),  
  srp_TotalReserves = IsNull(srp_TotalReserves,0),  
  srp_TotalRecovered = IsNull(srp_TotalRecovered ,0) ,   
  srp_EventLoc = IsNull(srp_EventLoc,''),  
  srp_EventAddress1 = IsNull(srp_EventAddress1,''),  
  srp_EventAddress2 = IsNull(srp_EventAddress2,''),  
  srp_Eventcity = IsNull(srp_EventCity,0),  
  srp_EventCtynmstct = IsNull(srp_EventCtynmstct,'UNKNOWN'),  
  srp_EventState = IsNull(srp_EventState,''),  
  srp_EventZip = IsNull(srp_eventZip,''),  
  srp_EventCountry = IsNull(srp_EventCountry,''),  
  srp_ReportedDate,  
  srp_EventDate,  
  srp_EventLocIs = IsNull(srp_EventLocIs,'O'),  
  srp_EventLocCmpID = IsNull(srp_EventLocCmpID,'UNKNOWN'),  
  reportedbyname = '', -- IsNull(emp_name,''),  
  srp_terminal = IsNull(srp_terminal,'UNK'),  
  srp_terminal_t= IsNull('RevType' +(Select gi_string1 From generalinfo Where gi_Name = 'TerminalRevType'),'RevType1'),
  --JJF 25959 Add mappedrevtype2
  srp_mappedrevtype2 = IsNull(srp_mappedrevtype2,'UNK'),  
  srp_mappedrevtype2_t= 'RevType' + IsNull((Select gi_string1 From generalinfo Where gi_Name = 'SafetyReportMappedRevType2'), '0'),  
  srp_tractor    
  , srp_trailer1  
  , srp_trailer2     
  , srp_driver1        
  , srp_driver2      
  , srp_mpporeeid    
  , srp_carrier   
  , safetyreport.cmd_code  
  ,srp_Hazmat  
  ,srp_OnPremises  
  ,srp_InsCompany  
  ,srp_inscoaddress  
  ,srp_inscocity  
  ,srp_inscoctynmstct  
  ,srp_inscostate  
  ,srp_inscozip  
  ,srp_inscocountry  
  ,srp_inscophone  
  ,srp_Reportedtoinsurance  
  ,srp_inscoreportdate  
  ,srp_claimnbr 
  ,srp_Inspolicynbr = IsNull(srp_insPolicynbr,'')
  ,cmp_address1 = isnull  (company.cmp_address1,'')
  ,cmp_address2 = IsNull(company.cmp_address2,'')
  ,cmp_ctynmstct = IsNull(company.cty_nmstct,'UNKNOWN') 
  ,ord_number = isnull(ord_number,'')
  ,mov_number = IsNull(mov_number,0)
  ,lgh_number = isNull(lgh_number,0)
  ,srp_cargodamagecost = IsNull(srp_cargodamagecost,0) 
  ,srp_propdamagecost = IsNull(srp_propdamagecost,0)
  ,srp_vdamagecost = IsNull(srp_vdamagecost,0)
  ,picturecount = (select count(*) from ps_blob_data where blob_table = 'safetyreport' and blob_key = srp_number)
  ,srp_string1 = isnull(srp_string1,'')
  ,srp_string2 = isnull(srp_string2,'')
  ,srp_string3 = isnull(srp_string3,'')
  ,srp_string4 = isnull(srp_string4,'')
  ,srp_string5 = isnull(srp_string5,'')
  ,srp_number1 = isnull(srp_NUMBER1,0)
  ,srp_number2 = isnull(srp_NUMBER2,0)
  ,srp_number3 = isnull(srp_NUMBER3,0)
  ,srp_number4 = isnull(srp_NUMBER4,0)
  ,srp_number5 = isnull(srp_NUMBER5,0)
  ,srp_SafetyType5 = IsNull(srp_SafetyType5,'UNK'), srp_SafetyType5_t = 'SafetyType5'
  ,srp_SafetyType6 = IsNull(srp_SafetyType6,'UNK'), srp_SafetyType6_t = 'SafetyType6'
  ,srp_SafetyType7 = IsNull(srp_SafetyType7,'UNK'), srp_SafetyType7_t = 'SafetyType7'
  ,srp_SafetyType8 = IsNull(srp_SafetyType8,'UNK'), srp_SafetyType8_t = 'SafetyType8'
  ,srp_date1
  ,srp_date2
  ,srp_date3
  ,srp_date4
  ,srp_date5
  ,srp_reportedbyname = IsNull(srp_reportedbyname,@v_reportedbyname)  -- replacing non editable reportedby above
  ,srp_insagent= isnull(srp_insagent,'')
  ,srp_CkBox1 = isnull(srp_ckBox1,'N')
  ,srp_CkBox2 = isnull(srp_ckBox2,'N')
  ,srp_CkBox3 = isnull(srp_ckBox3,'N')
  ,srp_CkBox4 = isnull(srp_ckBox4,'N')
  ,srp_CkBox5 = isnull(srp_ckBox5,'N')
  ,ord_booked_revtype1 = isnull(ord_booked_revtype1,'UNKNOWN')
  ,lgh_booked_revtype1 = isnull(lgh_booked_revtype1,'UNKNOWN')
  ,ord_billto = isnull(ord_billto,'UNKNOWN')
  ,ord_shipper = isnull(ord_shipper,'UNKNOWN')
  ,ord_consignee = isnull(ord_consignee,'UNKNOWN')
  ,billtoname = bcmp.cmp_name
  ,shippername = scmp.cmp_name
  ,consigneename = ccmp.cmp_name
  ,carriername = carrier.car_name
  ,delivering = 'O'
  , BBranchParent =  bb.brn_parent
  , EBranchParent =  eb.brn_parent
From SAFETYREPORT 
    LEFT OUTER JOIN company ON SAFETYREPORT.srp_EventLocCmpID = company.cmp_id 
    LEFT OUTER JOIN company bcmp on SAFETYREPORT.ord_billto = bcmp.cmp_id 
    LEFT OUTER JOIN company scmp on SAFETYREPORT.ord_shipper = scmp.cmp_id 
    LEFT OUTER JOIN company ccmp on SAFETYREPORT.ord_consignee = ccmp.cmp_id 
    LEFT OUTER JOIN carrier  on SAFETYREPORT.srp_carrier = car_id
    LEFT OUTER JOIN branch bb on safetyreport.ord_booked_revtype1 = bb.brn_id
    LEFT OUTER JOIN branch eb on safetyreport.lgh_booked_revtype1 = eb.brn_id


Where srp_number = @srpnbr  

  
GO
GRANT EXECUTE ON  [dbo].[d_safetyreport_sp] TO [public]
GO
