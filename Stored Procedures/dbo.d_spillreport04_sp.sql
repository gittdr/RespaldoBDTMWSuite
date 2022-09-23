SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_spillreport04_sp] @srpid int 
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
	SR 21430 DPETE created 2/24/4
	PTTS23452 DPETE bring back labelfile name for type of report 
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 12/07/2010.01 - PTS53564 - vjh - new report format 04 based on 02
 *
 **/

DECLARE @ReportName varchar(50)
Select @ReportName = name
From labelfile 
where labeldefinition = 'SafetyClassification'
and abbr = 'SPILL'

Select @ReportName = IsNull(@reportName,'Spill')

Select safetyreport.srp_ID,
  srp_number,
  srp_reporteddate,
  srp_Reportedby,
  reportedbyname = IsNull(e1.emp_name,''),
  srp_description = IsNull(srp_description,''),
  srp_ClassificationName = (Select name From labelfile Where labeldefinition = 'SafetyClassification' and abbr =  IsNull(srp_Classification,'UNK')),
--  injcount = IsNull(spl_nbrofinjuries,0),
--  ovdcount = (Select count(*) From othervehicledamage Where othervehicledamage.srp_id = @srpid),
--  opdcount = (Select count(*) From propertydamage Where propertydamage.srp_id = @srpid),
  srp_Eventdate,
  srp_terminal,
  terminalname = (Select name From Labelfile Where abbr = IsNull(srp_terminal,'UNK') and labeldefinition = 'RevType' + 
    IsNull((Select gi_string1 From generalinfo Where gi_name = 'terminalRevType'),'1')),
  srp_EventLoc = IsNull(srp_EventLoc,''),
  srp_EventAddress1 = IsNull(srp_EventAddress1,''),
  srp_EventAddress2 = IsNull(srp_EventAddress2,''),
  srp_Eventcity = IsNull(srp_EventCity,0),
  srp_EventCtynmstct = IsNull(srp_EventCtynmstct,'UNKNOWN'),
  srp_EventState = IsNull(srp_EventState,IsNull(city2.cty_state,'')),
  srp_EventZip = IsNull(srp_eventZip,''),
  srp_EventCountry = IsNull(srp_EventCountry,''),
  spl_description = IsNull(spl_description,''),
  spl_lawenfdeptaddress = IsNull(spl_lawenfdeptaddress,''),
  spl_lawenfdeptname = IsNull(spl_lawenfdeptname,''),
  spl_lawenfofficer = IsNull(spl_lawenfofficer,''),
  spl_lawenfofficerbadge = IsNull(spl_lawenfofficerbadge,''),
  spl_policereportnumber = IsNull(spl_policereportnumber,''),
  spl_Tractor = Case IsNull(spl_tractor,'UNKNOWN') When 'UNKNOWN' Then '' Else spl_tractor End,
  trc_year = IsNull(trc_year,''),
  trc_make = IsNull(trc_make,''),
  trc_model = IsNull(trc_model,''),
  trc_serial = IsNull(trc_serial,''),
  trc_licnum = IsNull(trc_licnum,''),
  trc_LicState = IsNull(trc_LicState,''),
  trcownername = case IsNull(Rtrim(trc_owner),'UNKNOWN') When 'UNKNOWN' Then '' When ''  Then '' Else
     IsNull(pttrc.pto_Fname+' ','')+IsNull(pttrc.pto_lname,'') + IsNull(' of '+ pttrc.pto_companyname,'') End,
  trcowneraddress = case IsNull(trc_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else
    IsNull(pttrc.pto_address1,'') End,
  trcownercitystatezip = case IsNull(trc_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else
     Case pttrc.pto_city When 0 Then '' Else 
     (Select IsNull(c1.cty_name,'')+', '+IsNull(c1.cty_state,'') From city c1 Where c1.cty_code = pttrc.pto_city) 
        + '    ' +IsNull(pttrc.pto_zip,'') End End,
  trcownerphone = case IsNull(trc_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else
    IsNull(pttrc.pto_phone1,'') End,
  spl_trailer1 = case IsNull(spl_trailer1,'UNKNOWN') When 'UNKNOWN' then '' Else spl_trailer1 End,
  trl1_year = IsNull(tr1.trl_year,''),
  trl1_make = IsNull(tr1.trl_make,''),
  trl1_Model = IsNull(tr1.trl_model,''),
  trl1_serial = IsNull(tr1.trl_serial,''),
  trl1_licnum = IsNull(tr1.trl_licnum,''),
  trl1_licState = isNull(tr1.trl_licState,''),
  trl1ownername = Case isNull(Rtrim(tr1.trl_owner),'UNKNOWN') When 'UNKNOWN' Then '' When '' Then ''  Else
     IsNull(pttr1.pto_Fname+' ','')+IsNull(pttr1.pto_lname,'')+ IsNull(' of '+ pttr1.pto_companyname,'') End,
  trl1owneraddress = Case IsNull(tr1.trl_Owner,'UNKNOWN') When 'UNKNOWN' Then '' Else
     IsNull(pttr1.pto_address1,'') End,
  trl1ownercitystatezip = Case IsNull(tr1.trl_Owner,'UNKNOWN') When 'UNKNOWN' Then '' Else
     Case pttr1.pto_city When 0 Then '' Else 
     (Select IsNull(c1.cty_name,'')+', '+IsNull(c1.cty_state,'') From city c1 Where c1.cty_code = pttr1.pto_city) 
     +'    '+ IsNull(pttr1.pto_zip,'') End End,
  trl1ownerphone = IsNull(pttr1.pto_phone1,''),
  spl_driver1 = Case IsNull(spl_driver1,'UNKNOWN') When 'UNKNOWN' Then '' Else spl_Driver1 End,
  drv1name = IsNull(mpp1.mpp_firstname,'')+ ' '+IsNull(mpp1.mpp_lastname,''),
  drv1homephone = IsNull(mpp1.mpp_homephone,''),
  drv1address = IsNull(mpp1.mpp_address1,''),
  drv1citystatezip = Case IsNull(mpp1.mpp_city,0) When 0 Then '' Else
     (Select IsNull(c2.cty_name,'')+', '+IsNull(c2.cty_state,'') From city c2 Where c2.cty_code = mpp1.mpp_city) + IsNull(mpp1.mpp_zip,'') End,
  drv1license = IsNull(mpp1.mpp_licenseNumber,''),
  drv1licensestate = IsNull(mpp1.mpp_LicenseState,''),
  drv1terminalname = (Select name From labelfile l2 Where l2.labeldefinition = 'Terminal' and l2.abbr = isNull(mpp1.mpp_terminal,'UNK')),
  drv2name = IsNull(mpp2.mpp_firstname,'')+ ' '+IsNull(mpp2.mpp_lastname,''),
  drv2homephone = IsNull(mpp2.mpp_homephone,''),
  drv2address = IsNull(mpp2.mpp_address1,''),
  drv2citystatezip = Case IsNull(mpp2.mpp_city,0) When 0 Then '' Else
     (Select IsNull(c3.cty_name,'')+', '+IsNull(c3.cty_state,'') From city c3 Where c3.cty_code = mpp2.mpp_city) + IsNull(mpp2.mpp_zip,'') End,
  drv2license = IsNull(mpp2.mpp_licenseNumber,''),
  drv2licensestate = IsNull(mpp2.mpp_LicenseState,''),
  drv2terminalname = (Select name From labelfile l3 Where l3.labeldefinition = 'Terminal' and l3.abbr = isNull(mpp2.mpp_terminal,'UNK')),
  spl_LawEnfDeptPhone = IsNull(spl_LawEnfDeptPhone,'') ,
  splspilltype1name = IsNull(lb1.name,''),
  spllawenfdeptcitystatezip = IsNull(city.cty_name+', ','')+IsNull(spl_lawenfdeptState,'')+IsNull('    '+spl_LawEnfDeptZip,''),
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
  step6 = IsNull((Select gi_string1 From generalinfo Where gi_name = 'SafetyReqStep6'),''),
  cmd_name = IsNull(cmd_name,''),
  srp_eventlocis = IsNull(srp_eventlocis,'O'),
  srp_eventloccmpid = IsNull(srp_eventloccmpid,'UNKNOWN'),
  spl_damage = IsNull(spl_damage,''),
  spl_actiontaken = IsNull(spl_actiontaken,''),
  spill.cmd_code
  ,srp_estcost  
   ,srp_totalreserves  
   ,srp_totalpaidbycmp  
  ,srp_totalpaidbyins  
  ,srp_totalrecovered   
  ,@ReportName
  ,srp_cargodamagecost = IsNull(srp_cargodamagecost,0)
  From 
    tractorprofile
   , trailerprofile tr1
   , manpowerprofile mpp1
   ,manpowerprofile mpp2
   ,payto pttrc
 , payto pttr1
  ,(Select 
       emp_id = mpp_id,
       emp_name = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,''),
       emp_terminal = mpp_terminal 
       From manpowerprofile 
       Where mpp_id in(Select distinct srp_reportedby From safetyreport where srp_id = @srpid and srp_reportedby <> 'UNKNOWN')
       Union All
       Select
       emp_id = ee_id, 
       emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),
       emp_terminal = ee_terminal
       From employeeprofile 
       Where ee_id  in (Select distinct srp_reportedby From safetyreport where srp_id = @srpid and srp_reportedby <> 'UNKNOWN' ))
    e1 RIGHT OUTER JOIN safetyreport ON e1.emp_id = safetyreport.srp_reportedby
		LEFT OUTER JOIN city city2 ON city2.cty_code = safetyreport.srp_eventcity,
    labelfile lb1,
    city RIGHT OUTER JOIN spill ON city.cty_code = spill.spl_LawEnfDeptCity
		LEFT OUTER JOIN commodity ON commodity.cmd_code = spill.cmd_code
  Where safetyreport.srp_id = @srpid
  And spill.srp_id = safetyreport.srp_id
  And tractorprofile.trc_number = IsNull(spl_tractor,'UNKNOWN')
  And tr1.trl_id = IsNull(spl_Trailer1,'UNKNOWN')
  and mpp1.mpp_id = IsNull(spl_Driver1,'UNKNOWN')
  And mpp2.mpp_id = IsNull(spl_Driver2,'UNKNOWN')
  and pttrc.pto_id = (Case IsNull(Rtrim(tractorprofile.trc_owner),'UNKNOWN') When '' Then 'UNKNOWN' Else IsNull(tractorprofile.trc_owner,'UNKNOWN') End )
  and pttr1.pto_id = (Case IsNull(Rtrim(tr1.trl_owner),'UNKNOWN') When '' Then 'UNKNOWN' Else IsNull(tr1.trl_owner,'UNKNOWN') End )
  --and e1.emp_id =* srp_reportedby
  and lb1.labeldefinition = 'SpillType1' 
  and lb1.abbr = IsNull(spl_Spilltype1,'UNK')
  --and city.cty_code =* spl_LawEnfDeptCity
  --and commodity.cmd_code =* spill.cmd_code
  --and city2.cty_code =* srp_eventcity

GO
GRANT EXECUTE ON  [dbo].[d_spillreport04_sp] TO [public]
GO
