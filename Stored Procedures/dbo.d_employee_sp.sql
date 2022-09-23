SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[d_employee_sp] @eeID varchar(8) 
As
/* 
SR 17782 DPETE created 10/13/03 for editing new employeeprofile
4/2/4 argument was varchar(6) when it should be 8

*/

Create table #emp (
  emp_ID varchar(8) null,
  emp_firstname varchar(100) null,
  emp_middleInit char(1) null,
  emp_LastName varChar(100) null
)

Insert Into #emp
Select emp_id = EE_ID, 
 emp_firstname = ee_FirstName,
 emp_middleInit= ee_MiddleInit,
 emp_lastname = ee_LastName
 From Employeeprofile
 Where ee_id = (Select ee_SuperVisorID From EmployeeProfile p2 where p2.ee_ID = @eeID)

If @@rowcount < 1
 Insert Into #emp
 Select  emp_id = Mpp_ID,
  emp_firstname = mpp_Firstname,
  emp_MiddleInit= Left(mpp_middlename,1),
  emp_lastnamr = mpp_lastname
  From manpowerprofile 
  Where mpp_id = (Select ee_SuperVisorID From EmployeeProfile p1 where p1.ee_ID = @eeID)



Select ee_ID,
  ee_FirstName,
  ee_MiddleInit,
  ee_LastName,
  ee_SSN,
  ee_Address1,
  ee_Address2,
  ee_city,
  ee_Ctynmstct,
  ee_State,
  ee_zip,
  ee_country,
  ee_terminal = IsNull(ee_terminal,'UNK'), 
  ee_SupervisorID,
  ee_HireDate,
  ee_TerminationDt =IsNull(ee_terminationdt,'12-31-2049 23:59'),  
  ee_active = IsNull(ee_active,'Y'),
  ee_DateOfBirth,
  ee_WorkPhone,
  ee_HomePhone,
  ee_Title,
  ee_NbrDependents,
  ee_worklocation = IsNull(ee_workLocation,'UNK'),ee_WorkLocation_t = 'WorkLocation',
  ee_ManagementLevel = IsNull(ee_managementLevel,'UNK'), ee_managementLevel_t = 'ManagementLevel',
  ee_EmerName,
  ee_emerphone,
  ee_LicenseNumber,
  ee_licenseState,
  SupervisorName = IsNull(#emp.emp_firstname+' ','')+IsNull(#emp.emp_MiddleInit+' ','')+IsNull(#emp.emp_lastname,''),
  ee_gender = IsNull(ee_gender,''),
  ee_maritalstatus = IsNull(ee_Maritalstatus,''),
  ee_occupation= IsNull(ee_occupation,''),
  ee_workstate,
	--PTS 42298 JJF 20090223 add notes
  0 as cnote_count
	--END PTS 42298 JJF 20090223 add notes
  
From EMPLOYEEPROFILE  LEFT OUTER JOIN  #emp  ON  ee_SupervisorID  = #emp.emp_id
Where ee_ID = @eeID 
  
GO
GRANT EXECUTE ON  [dbo].[d_employee_sp] TO [public]
GO
