SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_CargoDamage_sp] @srpID int 
As
/* 
SR 22516 DPETE created 7/7/4 for retrieving and maintaining cargo damage for a safetyreport
  
 5/2009 44645 DPETE add user defined fields
*/

Select 
cdm_ID 
,srp_ID
,cdm_Sequence
,cmd_code=d.cmd_code
,cdm_Description
,cdm_Damage
,cdm_quantity
,cdm_unit
,cdm_Value
,cdm_CargoDamageType1=IsNull(cdm_CargoDamageType1,'UNK'),cdm_CargoDamageType1_t='CargoDamageType1'
,cdm_CargoDamageType2=IsNull(cdm_CargoDamageType2,'UNK'),cdm_CargoDamageType2_t='CargoDamageType2'
,cdm_CargoDamageType3=IsNull(cdm_CargoDamageType3,'UNK'),cdm_CargoDamageType3_t='CargoDamageType3'
,cdm_CargoDamageType4=IsNull(cdm_CargoDamageType4,'UNK'),cdm_CargoDamageType4_t='CargoDamageType4'
,cdm_OwnerIs 
,cdm_OwnerCompanyID
,cdm_OwnerName
,cdm_OwnerAddress1
,cdm_OwnerAddress2
,cdm_OwnerCity
,cdm_OwnerCtynmstct
,cdm_OwnerState
,cdm_OwnerZip
,cdm_OwnerCountry
,cdm_OwnerPhone
,cmp_address1=IsNull(cmp_address1,'')
,cmp_address2=IsNull(cmp_address2,'')
,cmp_city=IsNull(cmp_city,0)
,cdm_hazmat
,cdm_string1
 ,cdm_string2
 ,cdm_string3
 ,cdm_string4
 ,cdm_string5
 ,cdm_number1
 ,cdm_number2
 ,cdm_number3
 ,cdm_number4
 ,cdm_number5
 ,cdm_CargoDamageType5=IsNull(cdm_CargoDamageType5,'UNK'),cdm_CargoDamageType5_t='CargoDamageType5'
 ,cdm_CargoDamageType6=IsNull(cdm_CargoDamageType6,'UNK'),cdm_CargoDamageType6_t='CargoDamageType6'
 ,cdm_date1
 ,cdm_date2
 ,cdm_date3
 ,cdm_date4
 ,cdm_date5
 ,cdm_CKBox1  = isnull(cdm_CKBox1,'N')
 ,cdm_CKBox2  = isnull(cdm_CKBox2,'N')
 ,cdm_CKBox3  = isnull(cdm_CKBox3,'N')
 ,cdm_CKBox4  = isnull(cdm_CKBox4,'N')
 ,cdm_CKBox5  = isnull(cdm_CKBox5,'N')
From CARGODAMAGE d
LEFT OUTER JOIN company c ON  c.cmp_id = d.cdm_OwnerCompanyID 
Where srp_id = @srpid

GO
GRANT EXECUTE ON  [dbo].[d_CargoDamage_sp] TO [public]
GO
