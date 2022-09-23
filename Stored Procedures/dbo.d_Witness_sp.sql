SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_Witness_sp] @srpID int 
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
    SR 17782 DPETE created 10/13/03 for retrieving and maintaining witness information.  Brings back all for
    a safetye report, must be filtered for an accident or injury within the incident.
    If witness is employee, name and address, etc. come from Manpoer or employee. If
    outside person, name and address are stored in record
 * 11/12/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 3/17/09 DPETE PTS 44645 add user fields
 *
 **/


Select wit_ID,
   srp_ID,
   wit_Sequence,
   wit_witnessIs ,
   wit_MppOrEeID,  -- in case witness is an employee
   wit_name = IsNull(wit_name,''),             -- in case witness is not employee (info is held in table)
   wit_Address1 = IsNull(wit_address1,''),
   wit_Address2= IsNull(wit_address2,''),
   wit_City= Isnull(wit_city,0),
   wit_Ctynmstct= IsNull(wit_ctynmstct,'UNKNOWN'),
   wit_State= IsNull(wit_state,''),
   wit_Zip= IsNull(wit_zip,''),
   wit_HomePhone,
   wit_WorkPhone,
   wit_Comment,
   empname = IsNull(emp_name,''),
   empAddress1 = IsNull(emp_address1,''),
   empAddress2 = IsNull(emp_address2,''),
   empCity = IsNull(emp_city,0),
   empctynmstct = IsNull( emp_ctynmstct,'UNKNOWN'),
   empstate = IsNull(emp_state,''),
   empZip = IsNull(emp_zip,''),
   empWorkPhone = IsNull(emp_workphone,''),
   empHomePhone = IsNull(emp_Homephone,''),
  wit_string1,
  wit_string2,
  wit_string3,
  wit_string4,
  wit_string5,
  wit_number1,
  wit_number2,
  wit_number3,
  wit_number4,
  wit_number5,
  wit_WitnessType1 = IsNull(wit_WitnessType1,'UNK'),wit_WitnessType1_t = 'WitnessType1',
  wit_WitnessType2 = IsNull(wit_WitnessType2,'UNK'),wit_WitnessType2_t = 'WitnessType2',
  wit_WitnessType3 = IsNull(wit_WitnessType3,'UNK'),wit_WitnessType3_t = 'WitnessType3',
  wit_WitnessType4 = IsNull(wit_WitnessType4,'UNK'),wit_WitnessType4_t = 'WitnessType4',
  wit_WitnessType5 = IsNull(wit_WitnessType5,'UNK'),wit_WitnessType5_t = 'WitnessType5',
  wit_WitnessType6 = IsNull(wit_WitnessType6,'UNK'),wit_WitnessType6_t = 'WitnessType6',
  wit_date1,
  wit_date2,
  wit_date3,
  wit_date4,
  wit_date5,
  wit_ckbox1= isnull(wit_ckbox1,'N'),
  wit_ckbox2= isnull(wit_ckbox2,'N'),
  wit_ckbox3= isnull(wit_ckbox3,'N'),
  wit_ckbox4= isnull(wit_ckbox4,'N'),
  wit_ckbox5= isnull(wit_ckbox5,'N'),
  wit_role = isnull(wit_role,'WIT'),wit_role_t = 'WitnessRoll'

From Witness LEFT OUTER JOIN  --pts40187 outer join conversion
  (Select 
    emp_id = mpp_id,
    emp_name = IsNUll(mpp_firstname+' ','')+IsNull(mpp_Middlename+' ','')+IsNull(mpp_lastname,''),
    emp_address1 = IsNull(mpp_Address1,''),
    emp_Address2 = IsNull(mpp_address2,''),
    emp_city = IsNull(mpp_city,0),
    emp_ctynmstct = IsNull(city.cty_nmstct,'UNKNOWN'),
    emp_state = IsNull(mpp_state,'XX'),
    emp_zip = IsNull(mpp_zip,''),
    emp_HomePhone = IsNull(mpp_homephone,''),
    emp_WorkPhone = ''
   From manpowerprofile , city
   Where mpp_id in(Select distinct wit_MppOrEeID From Witness where srp_id = @srpID  and wit_MppOrEeID <> 'UNKNOWN')
    And city.cty_code = mpp_city  --pts40187 removed the outer join from the co-related query
   Union All
   Select
    emp_id = ee_id, 
    emp_name = IsNUll(ee_firstname+' ','')+IsNull(ee_MiddleInit+' ','')+IsNull(ee_lastname,''),
    emp_address1 = IsNull(ee_Address1,''),
    emp_Address2 = IsNull(ee_address2,''),
    emp_city = IsNull(ee_City,0),
    emp_Ctynmstct = IsNull(ee_Ctynmstct,'UNKNOWN'),
    emp_state = IsNull(ee_state,'XX'),
    emp_zip = IsNull(ee_zip,''),
    emp_HomePhone = IsNull(ee_homephone,''),
    emp_Workphone = IsNull(ee_workphone,'')
   From employeeprofile 
   Where ee_id  in (Select distinct wit_MppOrEeID From Witness where srp_id = @srpID and wit_MppOrEeID <> 'UNKNOWN'))
  e1 ON wit_MppOrEeID = e1.emp_id
Where srp_Id =  @srpID
Order by wit_Sequence


GO
GRANT EXECUTE ON  [dbo].[d_Witness_sp] TO [public]
GO
