SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_propertydamage_sp] @srpid int
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
	DPETE 2/11/4 remove insurance info PTS21787
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *  7/14/09 PTS44645 add user defineable fields
 **/
Select prp_ID,
 srp_ID,
 prp_Sequence,
 prp_Description = IsNull(prp_description,''),
 prp_Damage = IsNull(prp_Damage,''),
 prp_Comment = IsNull(prp_Comment,''),
 prp_value = IsNull(prp_value,0),
 prp_ActionTaken = IsNull(prp_actionTaken,''),
 prp_OwnerIs = IsNull(prp_OwnerIs,'O'),
 prp_OwnerCompanyID = IsNull(prp_OwnerCompanyID,'UNKNOWN'),
 prp_OwnerName = IsNull(prp_ownerName,''),
 prp_OwnerAddress1 = IsNull(prp_OwnerAddress1,''),
 prp_OwnerAddress2 = IsNull(prp_OwnerAddress2,''),
 prp_ownercity = IsNull(prp_ownercity,0),
 prp_OwnerCtynmstct = IsNull(prp_OwnerCtynmstct,'UNKNOWN'),
 prp_OwnerState = IsNull(prp_OwnerState,''),
 prp_OwnerZip = IsNull(prp_OwnerZip,''),
 prp_OwnerCountry = IsNull(prp_OwnerCountry,''),
-- prp_InsCompany = IsNull(prp_InsCompany,''),
-- prp_InsCoAddress = IsNull(prp_InsCoAddress,''),
-- prp_InsCoCity = IsNull(prp_InsCoCity,0),
-- prp_InsCoCtynmstct = IsNull(prp_InsCoCtynmstct,''),
-- prp_InsCoState = ISNull(prp_InsCoState,''),
-- prp_InsCoZip = IsNull(prp_InsCoZip,''),
-- prp_InsCoCountry = IsNull(prp_InsCoCountry,''),
-- prp_InsCoPhone  = IsNull(prp_InsCoPhone,''),
-- prp_ReportedToInsurance = IsNull(prp_ReportedToInsurance,'N'),
-- prp_InsCoReportDate,
 cmpname = IsNull(cmp_name,''),
 cmpaddress1 = IsNull(cmp_address1,''),
 cmpAddress2 = IsNull(cmp_address2,''),
 cmpcity = IsNull(cmp_city,0),
 cmpctynmstct = IsNull(company.cty_nmstct,'UNKNOWN'),
 cmpzip = IsNull(cmp_zip,''),
 cmpstate = IsNull(cmp_state,''),
 cmpcountry = IsNull(cmp_country,''),
 cmpphone = IsNull(cmp_primaryphone,''),
 prp_OwnerPhone,
 prp_string1,
  prp_string2,
  prp_string3,
  prp_string4,
  prp_string5,
  prp_number1,
  prp_number2,
  prp_number3,
  prp_number4,
  prp_number5,
  prp_PropDamageType1=IsNull(prp_PropDamageType1,'UNK'),prp_PropDamageType1_t='PropertyDamageType1',
  prp_PropDamageType2=IsNull(prp_PropDamageType2,'UNK'),prp_PropDamageType2_t='PropertyDamageType2',
  prp_PropDamageType3=IsNull(prp_PropDamageType3,'UNK'),prp_PropDamageType3_t='PropertyDamageType3',
  prp_PropDamageType4=IsNull(prp_PropDamageType4,'UNK'),prp_PropDamageType4_t='PropertyDamageType4',  
  prp_date1,
  prp_date2,
  prp_date3,
  prp_date4,
  prp_date5,
  prp_CKBox1 = isnull(prp_CKBox1,'N'),
  prp_CKBox2 = isnull(prp_CKBox2,'N'),
  prp_CKBox3 = isnull(prp_CKBox3,'N'),
  prp_CKBox4 = isnull(prp_CKBox4,'N'),
  prp_CKBox5 = isnull(prp_CKBox5,'N')
From propertydamage LEFT OUTER JOIN company ON company.cmp_id = prp_OwnerCompanyID
Where srp_id = @srpid
 --and company.cmp_id =* prp_OwnerCompanyID
Order by prp_sequence
 

GO
GRANT EXECUTE ON  [dbo].[d_propertydamage_sp] TO [public]
GO
