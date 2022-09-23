SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadactiveempid_sp] @emp varchar(8) , @number int AS 
/**
 *
 * NAME:
 * dbo.d_loadactiveempid_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns data for drivers AND employees
 *
 * RETURNS:
 * 001 - emptype,
 * 002 - empID,
 * 003 - empname,
 * 004 - empterminal,
 * 005 - empterminalname ,
 * 006 - empaddress1 ,
 * 007 - empaddress2,
 * 008 - empcitynbr ,
 * 009 - empcityname ,
 * 010 - empstate ,
 * 011 - empzip ,
 * 012 - empHomePhone,
 * 013 - empworkphone,
 * 014 - empdependents,
 * 015 - empmanagementlevel,
 * 016 - empemername,
 * 017 - empemerphone ,
 * 018 - empworklocation,
 * 019 - empworklocationame,
 * 020 - empssn,
 * 021 - emphiredate,
 * 022 - empbirthdate,
 * 023 - emplicense,
 * 024 - emplicensestate,
 * 025 - emplicenseclass,
 * 026 - empsupervisor,
 * 027 - empsupervisorname ,
 * 028 - empcountry,
 * 029 - empctynmstct,
 * 030 - empmaritalstatus,
 * 031 - empgender,
 * 032 - empworkstate,
 * 033 - empoccupation
 *
 * RESULT SETS:
 * none.
 *
 * PARAMETERS:
 * 001 - @emp varchar(8)
 *       This parameter is the value that is used to match
 *       to driver and employee IDs 
 * 002 - @number int
 *       This parameter indicates the number of rows to return
 *       It is changed to 1,8,16 or 24 if it is not one of those values
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 * SR 17782 DPETE created 10/13/03  
 * 08/19/2005.01 ? PTS27390 - Vince Herman ? Changed grace logic to standard
 * 10/05/2011 - PTS59383 - MTC. Changed temp tables to table vars to avoid chronic recompilation issues.
 *
 **/

Declare @emp_table table (
emptype char(1) not null,
empid varchar(8) not null,
empname varchar(50) null,
empterminal varchar(6) null,
empterminalname varchar(30) null,
empaddress1 varchar(60) null,
empaddress2 varchar(60) null,
empcitynbr int null,
empcityname varchar(40) null,
empstate varchar(6) null,
empzip varchar(10) null,
empHomePhone varchar(20),
empworkphone varchar(20),
empdependents tinyint null,
empmanagementlevel varchar(6) null,
empemername varchar(60) null,
empemerphone varchar(20) null,
empworklocation varchar(6) null,
empworklocationame varchar(30) null,
empssn varchar(20) null,
emphiredate datetime null,
empbirthdate datetime null,
emplicense varchar(20) null,
emplicensestate varchar(6) null,
emplicenseclass varchar(15) null,
empsupervisor varchar(8) null,
empsupervisorname varchar(50) null,
empcountry varchar(6) null,
empctynmstct varchar(25) null,
empmaritalstatus char(1) null,
empgender char(1) null,
empworkstate varchar(6) null,
empoccupation varchar(30) null
)

Declare @v_date datetime 
Declare @daysout int
-- PTS 31161 -- BL (start)
Declare @employee_grace_period	int
-- PTS 31161 -- BL (end)

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1)
--END PTS 42816 JJF 20080527			

--vjh 27390 use standard Set List Box / Grace logic
SELECT @daysout = -90
-- PTS 31161 -- BL (start)
SELECT @employee_grace_period = gi_integer1, 
		 @v_date = gi_date1 FROM generalinfo WHERE gi_name = 'GRACE_PERIOD_EMPLOYEE'
-- PTS 31161 -- BL (end)

--PTS 39759 Test for Listbox override
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@v_date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
BEGIN
	SELECT @daysout = gi_integer1, 
			 @v_date = gi_date1 FROM generalinfo WHERE gi_name = 'GRACE'

	-- PTS 31161 -- BL (start)
	SELECT @daysout = isnull(@employee_grace_period, @daysout)
	-- PTS 31161 -- BL (end)
END
--PTS 39759

--PTS 53255 JJF 20101130
--PTS 42816 JJF 20080527
--DECLARE @tbl_drvrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 53255 JJF 20101130

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'


IF @rowsecurity = 'Y' BEGIN
	--PTS 53255 JJF 20101130
	--INSERT INTO @tbl_drvrestrictedbyuser
	--SELECT * FROM  rowrestrictbyuser_driver_fn(@emp)
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_manpowerprofile_fn() 
	--PTS 53255 JJF 20101130
END
--END PTS 42816 JJF 20080527

If @daysout <> 999 
	SELECT @v_date = dateadd (day, @daysout, getdate())

Insert into @emp_table
Select emptype = 'D',
  empid = mpp_id , 
  empname = IsNull(mpp_firstname,'')+' '+IsNull(mpp_middlename,'')+' '+IsNull(mpp_lastname,''),
  empterminal = mpp_terminal,
  emptrminalname = IsNull(l.name,IsNull(mpp_terminal,'UNKNOWN')) ,
  empaddress1 = IsNull(mpp_address1,''),
  empAddress2 = IsNull(mpp_address2,''),
  empcitynmbr =  IsNull(mpp_city,0),
  empcityname =  IsNull(cty_name,''),
  empstate = case IsNull(mpp_state,'') When 'XX' Then '' Else IsNull(mpp_state,'') End,
  empzip =  IsNull(mpp_zip,IsNull(cty_zip,'')),
  emphomephone = IsNull(mpp_homephone,''),
  empworkphone = IsNull(mpp_currentphone,''),
  empdependents = IsNull(mpp_nbrdependents,0),
  empmanagementlevel = 'DRIVER',
  empemername = IsNull(mpp_emername,''),
  empemerphone = IsNull(mpp_emerphone,''),
  empworklocation = 'ROAD',
  empworklocationname = 'ROAD' ,
  empssn = Isnull(mpp_ssn,''),
  emphiredate = mpp_hiredate,
  empbirthdate = mpp_dateofbirth,
  emplicense = IsNull(mpp_licensenumber,''),
  emplicensestate = IsNull(mpp_licensestate,''),
  emplicenseclass = IsNull(mpp_licenseClass,''),  -- does not seem to have labelfile entry
  empsupervisor = IsNull(mpp_teamleader,''),  -- is varchar(6) must be label
  empsupervisorname = IsNull(ltl.name,''),
  empcountry = IsNull(mpp_country,''),
  empctynmstct = city.cty_nmstct,
  empmaritalstatus = '',
  empgender = '',
  empworkstate = '  ',
  empoccupation = 'Driver'
From manpowerprofile left outer join labelfile l on (mpp_terminal = l.abbr and l.labeldefinition = 'Terminal')
	left outer join labelfile ltl on (mpp_teamleader = ltl.abbr and ltl.labeldefinition = 'TeamLeader') 
	left outer join city on mpp_city  = city.cty_code
Where mpp_id like @emp+'%'  
  and (@v_date <= IsNull(mpp_terminationdt,'12-31-2049 23:59')
  or mpp_terminationdt < mpp_hiredate) --pts38118 os  
	--PTS 42816 JJF 20080527
	--PTS 53255 JJF 20101130
	--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
	--	OR @rowsecurity <> 'Y')
	AND	(	(@rowsecurity <> 'Y')
		OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
	)
	--END PTS 53255 JJF 20101130
	--END PTS 42816 JJF 20080527

Union All

Select emptype = 'E',
  empid = ee_id,
  empname = IsNull(ee_firstname,'')+' '+IsNull(ee_middleinit,'')+' '+IsNull(ee_lastname,''),
  empterminal = IsNull(ee_terminal,'UNK'),
  empterminalname = IsNull(lt.name,IsNull(ee_terminal,'UNKNOWN')),
  empaddress1 = IsNull(ee_address1,''),
  empAddress2 = IsNull(ee_address2,''),
  empcitynmbr =  IsNull(ee_city,0),
  empcityname =  IsNull(cty_name,''),
  empstate = Case IsNull(ee_state,'') When 'XX' Then '' Else isNull(ee_state,'') End,
  empzip = IsNull(ee_zip,IsNull(cty_zip,'')),
  emphomephone = IsNull(ee_homephone,''),
  empworkphone = IsNull(ee_workphone,''),
  empdependents = IsNull(ee_nbrdependents,0),
  empmanagementlevel = Isnull(ee_managementlevel,''),
  empemername = IsNull(ee_emername,''),
  empemerphone = IsNull(ee_emerphone,''),
  empwoklocation = IsNull(ee_worklocation ,'UNK'),
  empworklocationname = IsNull(lw.name,IsNull(ee_worklocation,'UNKNOWN')),
  empssn = IsNull(ee_ssn,''),
  emphiredate = ee_hiredate,
  empbirthdate = ee_DateofBirth,
  emplicense = IsNull(ee_licensenumber,''),
  emplicensestate = IsNull(ee_licensestate,''),
  emplicenseclass = 'Own',
  empsupervisor= IsNull(ee_SupervisorID,'UNKNOWN'),
  empsupervisorname =(Select IsNull(ee_firstname+' ','')+IsNull(ee_lastname,'') From employeeprofile e2 Where e2.ee_id = employeeprofile.ee_supervisorID),
  empcountry = IsNull(ee_country,''),
  empctynmstct = IsNull(ee_ctynmstct,'UNKNOWN'),
  empmaritalstatus = Isnull(ee_maritalstatus,''),
  empgender = isnull(ee_gender,''),
  empworkstate = IsNull(ee_workstate,''),
  empoccupation = IsNull(ee_occupation,'')
From employeeprofile left outer join labelfile lt on (ee_terminal = lt.abbr and lt.labeldefinition = 'Terminal') 
	left outer join labelfile lw on (ee_worklocation = lw.abbr and lw.labeldefinition = 'WorkLocation')
	left outer join city on ee_city = cty_code 
Where ee_id like @emp+'%' 
and IsNull(ee_active,'Y') = 'Y'
and (@v_date <= IsNull(ee_terminationdt,'12-31-2049 23:59') 
or ee_terminationdt < ee_hiredate) --pts38118 os

-- eliminate one of two UNKNOWN employees, one from manpower, one from employee
If  (Select Count(*) From @emp_table where empid = 'UNKNOWN' ) >= 2
   Delete From @emp_table where empid = 'UNKNOWN' and emptype = 'D'
   

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if exists ( SELECT empid FROM @emp_table)
   SELECT emptype,
     empID,
     empname,
     empterminal,
     empterminalname ,
     empaddress1 ,
     empaddress2,
     empcitynbr ,
     empcityname ,
     empstate ,
     empzip ,
     empHomePhone,
     empworkphone,
     empdependents,
     empmanagementlevel,
     empemername,
     empemerphone ,
     empworklocation,
     empworklocationame,
     empssn,
     emphiredate,
     empbirthdate,
     emplicense,
     emplicensestate,
     emplicenseclass,
     empsupervisor,
     empsupervisorname ,
     empcountry,
     empctynmstct,
     empmaritalstatus,
     empgender,
     empworkstate,
     empoccupation
   FROM @emp_table
   ORDER BY empid 
else 
   SELECT emptype = 'E',
     emp_id = ee_ID,
     empname = IsNull(ee_firstname,'')+' '+IsNull(ee_middleinit,'')+' '+IsNull(ee_lastname,''),
     empterminal = IsNull(ee_terminal,'UNK'),
     empterminalname = '',
     empaddress1 = IsNull(ee_address1,''),
     empAddress2 = IsNull(ee_address2,''),
     empcitynmbr =  IsNull(ee_city,0),
     empcityname =  '',
     empstate = '',
     empzip = IsNull(ee_zip,''),
     emphomephone = IsNull(ee_homephone,''),
     empworkphone = IsNull(ee_workphone,''),
     empdependents = IsNull(ee_nbrdependents,0),
     empmanagementlevel = Isnull(ee_managementlevel,''),
     empemername = IsNull(ee_emername,''),
     empemerphone = IsNull(ee_emerphone,'') ,
     empworklocation = IsNull(ee_worklocation,'UNK'),
     empworklocationame = '',
     empssn = IsNull(ee_ssn,''),
     emphiredate = ee_hiredate,
     empbirthdate = ee_dateofbirth,
     emplicense = IsNull(ee_licensenumber,''),
     emplicensestate = IsNull(ee_licensestate,''),
     emplicenseclass = '',
     empsupervisor = '',
     empsupervisorname = '',
     empcountry = '',
     empctynmstct = 'UNKNOWN',
     empmaritalstatus = '',
     empgender = '',
     empworkstate = '',
     empoccupation = ''
   FROM employeeprofile 
   WHERE ee_ID = 'UNKNOWN' 

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadactiveempid_sp] TO [public]
GO
