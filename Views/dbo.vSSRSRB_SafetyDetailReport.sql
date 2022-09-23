SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_SafetyDetailReport]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on custom detail safety report provided by a 
 * client to replicate
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_SafetyDetailReport]

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
 * 10/27/2014 EJD created view
 ***********************************************************/


CREATE VIEW [dbo].[vSSRSRB_SafetyDetailReport]

AS 


SELECT 
	srp.srp_id,
	srp.srp_number as 'Report Number',
	mpp.mpp_lastname + ', ' + mpp.mpp_firstname as 'Name', -- Driver 
	mpp.mpp_address1,
	mpp.mpp_address2,
	mmpCty.cty_name,
	mpp.mpp_state,
	mpp.mpp_zip,
	substring(mpp.mpp_currentphone,1,3) + '-' + SUBSTRING(mpp.mpp_currentphone,4,3) + '-' + SUBSTRING(mpp.mpp_currentphone,7,4) as 'Driver Current Phone Number',
	mpp.mpp_terminal as 'Driver Terminal',
	mpp.mpp_tractornumber as 'Tractor',
	srp.srp_trailer1 as 'Trailer',
	
	cls.[name] AS 'Classification',

	CASE srp.srp_Classification
		when 'ACC' then  accType1.name
		when 'SPILL'  then splType1.name
		when 'INJ'  then injType1.name
		when 'OBS'  then obsType1.name
		when 'INC'  then incType1.name
	ELSE ''
	END AS 'Type',
		
	srp.srp_eventctynmstct 'Event Location',
	srp.srp_EventAddress1 as 'Event Address',
	srp.srp_EventDate as 'Event Date',

	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_description,'')
		when 'SPILL'  then isnull(spl.spl_description,'')
		when 'INJ'  then isnull(inj.inj_description,'')
		when 'OBS'  then isnull(obs.obs_description,'')
		when 'INC'  then isnull(inc.inc_description,'')
		
	else
		'Classification Not Found'
	end as 'Description',

	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_Comment,'')
		when 'SPILL'  then isnull(spl.spl_Comment,'')
		when 'INJ'  then isnull(inj.inj_Comment,'')
		when 'OBS'  then isnull(obs.obs_FollowUpDesc,'')
		when 'INC'  then isnull(inc.inc_Comment,'')
		
	else
		'Classification Not Found'
	end as 'Comment',

	ISNULL(eer.eer_Comment,'') AS  'Response',
	
	spl.spl_Damage as 'Spill Damage',
	spl.spl_ActionTaken as 'Spill Action Taken',
	srp.srp_EventLoc,
	srp.srp_EventZip,
	srp.srp_SafetyStatus,
	srp.srp_estcost as 'Estimated Cost',
	srp.srp_TotalPaidByCmp as 'Total Paid By Company',
	srp.srp_TotalRecovered,
	srp.srp_cargodamagecost,
	srp.srp_propdamagecost,
	srp.srp_vdamagecost,
	srp.srp_terminal,
	srp.srp_Classification,
	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_lawenfdeptname,'')
		when 'SPILL'  then ''
		when 'INJ'  then ''
		when 'OBS'  then ''
		when 'INC'  then ''
		
	else
		''
	end as 'LawDepartmentName',

	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_lawenfdeptaddress,'')
		when 'SPILL'  then ''
		when 'INJ'  then ''
		when 'OBS'  then ''
		when 'INC'  then ''
		
	else
		''
	end as 'LawAddress',

	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_lawenfdeptctynmstct,'')
		when 'SPILL'  then ''
		when 'INJ'  then ''
		when 'OBS'  then ''
		when 'INC'  then ''
		
	else
		''
	end as 'LawCity',

	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_lawenfdeptzip,'')
		when 'SPILL'  then ''
		when 'INJ'  then ''
		when 'OBS'  then ''
		when 'INC'  then ''
		
	else
		''
	end as 'LawZip',

	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_lawenfofficer,'')
		when 'SPILL'  then ''
		when 'INJ'  then ''
		when 'OBS'  then ''
		when 'INC'  then ''
		
	else
		''
	end as 'LawOfficer',

	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_policereportnumber,'')
		when 'SPILL'  then ''
		when 'INJ'  then ''
		when 'OBS'  then ''
		when 'INC'  then ''
		
	else
		''
	end as 'LawReportNumber',

	case srp.srp_Classification
		when 'ACC' then  isnull(acc.acd_lawenfofficerbadge,'')
		when 'SPILL'  then ''
		when 'INJ'  then ''
		when 'OBS'  then ''
		when 'INC'  then ''
		
	else
		''
	end as 'LawOfficerBadge',

	case srp.srp_Classification
		when 'ACC' then  isnull(substring(acc.acd_lawenfdeptphone,1,3) + '-' + substring(acc.acd_lawenfdeptphone,4,3) + '-' + substring(acc.acd_lawenfdeptphone,7,4),'')
		when 'SPILL'  then ''
		when 'INJ'  then ''
		when 'OBS'  then ''
		when 'INC'  then ''
		
	else
		''
	end as 'LawPhone',
	
	trc.trc_make,
	trc.trc_model,
	trc.trc_year,
	trc.trc_serial,
	trc.trc_licnum,
	trl.trl_make,
	trl.trl_model,
	trl.trl_year,
	trl.trl_serial,
	trl.trl_licnum,
	acc.acd_trl1damage,
	acc.acd_trcdamage,

	case when srp.srp_Classification = 'ACC' then accPrv.name
	     else srpPrv.name
	end 'Preventability',
	
	ovd.ovd_drivername as 'other name',
	ovd.ovd_driveraddress1 as 'other address',
	ovd.ovd_driverctynmstct as 'other city',
	ovd.ovd_driverzip as 'other zip',
	substring(ovd.ovd_driverphone,1,3) + '-' + substring(ovd.ovd_driverphone,4,3) + '-' + substring(ovd.ovd_driverphone,6,4) as 'other phone number',
	ovd.ovd_vehiclemake as 'other make',
	ovd.ovd_vehiclemodel as 'other model',
	ovd.ovd_vehicleyear as 'other year',
	ovd.ovd_vehiclevin as 'other vin',
	ovd.ovd_vehiclelicense as 'other license',
	ovd.ovd_value as 'other value',
	ovd.ovd_comment as 'other comment',
	ovd.ovd_actiontaken as 'other action taken',
	ovd.ovd_damage as 'other damage',
	ovd.ovd_VehicleType as 'other vehicle type',
	acc.acd_nbrofinjuries as 'Number of Injuries',
	acc.acd_NbrOfFatalities as 'Number of Fatalities',
	acc.acd_CVDamage as 'Company Vehicle Damage',
	acc.acd_OVDamaged as 'Other Vehicle Damage',
	acd_OPDamaged as 'Property Damage',
	srp.srp_reportedbyname as 'Reported by'
			        	
	
FROM safetyreport srp WITH (NOLOCK)
		
	left join labelfile cls WITH (NOLOCK)
	on cls.labeldefinition = 'SafetyClassification' 
	and cls.abbr = srp.srp_Classification
	
	left join city RptCty  WITH (NOLOCK)
	on RptCty.cty_code = srp.srp_EventCity
	
	left join accident acc WITH (NOLOCK)
	on acc.srp_id = srp.srp_id

	left join labelfile accPrv WITH (NOLOCK)
	on accPrv.labeldefinition = 'AccdntPreventability' 
	and accPrv.abbr = acc.acd_AccdntPreventability
	
	left join labelfile accType1 WITH (NOLOCK)
	on accType1.labeldefinition = 'AccidentType1' 
	and accType1.abbr = acc.acd_AccidentType1
	
	left join labelfile srpPrv WITH (NOLOCK)
	on srpPrv.labeldefinition = 'SafetyType2' 
	and srpPrv.abbr = srp.srp_SafetyType2
	
	left join spill spl WITH (NOLOCK)
	on spl.srp_id = srp.srp_id
	
	left join labelfile splType1 
	on splType1.labeldefinition = 'SpillType1' 
	and splType1.abbr = spl.spl_SpillType1
	
	left join injury inj WITH (NOLOCK)
	on inj.srp_id = srp.srp_id
	
	left join labelfile injType1 WITH (NOLOCK)
	on injType1.labeldefinition = 'InjuryType1' 
	and injType1.abbr = inj.inj_InjuryType1
	
	
	left join incident inc WITH (NOLOCK)
	on inc.srp_id = srp.srp_id
	
	left join labelfile incType1 WITH (NOLOCK)
	on incType1.labeldefinition = 'IncidentType1' 
	and incType1.abbr = inc.inc_IncidentType1

	left join observation obs WITH (NOLOCK)
	on obs.srp_id = srp.srp_id
	
	left join labelfile obsType1 WITH (NOLOCK)
	on obsType1.labeldefinition = 'ObservationType1' 
	and obsType1.abbr = obs.obs_ObservationType1

	left join dbo.manpowerprofile mpp WITH (NOLOCK)
	on (mpp.mpp_id = acc.acd_driver1 
	    and srp.srp_Classification = 'ACC') or 
									 (mpp.mpp_id = spl.spl_driver1 and srp.srp_Classification = 'SPILL') or
									 (mpp.mpp_id = inj.inj_MppOrEeID and srp.srp_Classification = 'INJ') or
									 (mpp.mpp_id = inc.inc_MppOrEeID and srp.srp_Classification = 'INC') or
									 (mpp.mpp_id = obs.obs_MppOrEeID and srp.srp_Classification = 'OBS')

	left join dbo.city mmpCty WITH (NOLOCK)
	on mmpCty.cty_code = mpp.mpp_city	
	
	left join tractorprofile trc WITH (NOLOCK)
	on (trc.trc_number = acc.acd_tractor and srp.srp_Classification = 'ACC') or 
									(trc.trc_number = srp.srp_string1)
									
	left join trailerprofile trl WITH (NOLOCK)
	on (trl.trl_number = acc.acd_trailer1 
	and srp.srp_Classification = 'ACC') or 
	(trl.trl_id = srp.srp_string2)
													 
	left join OTHERVEHICLEDAMAGE ovd WITH (NOLOCK)
	on ovd.srp_ID = srp.srp_ID
	
	left join EERESPONSE eer WITH (NOLOCK)
	on eer.srp_ID = srp.srp_ID	
		

	
	


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyDetailReport] TO [public]
GO
