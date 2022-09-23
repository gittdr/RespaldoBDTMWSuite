SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO






CREATE   Procedure [dbo].[DriverAwareSuite_DriverScoreCard] (@BeginDate datetime=NULL,
						  @EndDate datetime = NULL,
						  @DriverID varchar(255) = 'BETTV'
						  )
As

Set NoCount On


If @BeginDate Is Null or @BeginDate <= '1900-01-01'
Begin
     Set @BeginDate = getdate() -90
End 

If @EndDate Is Null or @EndDate <= '1900-01-01'
Begin
      Set @EndDate = IsNull((select Case When getdate() > mpp_terminationdt Or mpp_terminationdt >= '12/31/2049' Then getdate() else mpp_terminationdt End from manpowerprofile where mpp_id = @DriverID),getdate())
End


	
--Back the begin date to previous starting week
select @BeginDate = Case When datepart(dw,@begindate) = 1 Then
				@begindate
			 When datepart(dw,@begindate) = 2 Then
				@begindate - 1
			 When datepart(dw,@begindate) = 3 Then
				@begindate - 2
			  When datepart(dw,@begindate) = 4 Then
				@begindate - 3
			  When datepart(dw,@begindate) = 5 Then
				@begindate - 4
			  When datepart(dw,@begindate) = 6 Then
				@begindate - 5
			  When datepart(dw,@begindate) = 7 Then
				@begindate - 6
		    End

Create Table #Weeks
	(MonthAndWeek varchar(255),
	 Begin_Date datetime,
	 End_Date datetime,
	 
	)


Create Table #ScoreCardReports

	(ReportName varchar(255),
	 ReportCategory varchar(255),
	 SortOrder int
	)


Insert into #ScoreCardReports
Select 'Total Miles','Miles And Pay',1
Union
Select 'Empty Miles','Miles And Pay',2
Union
Select 'Loads (Dispatches)','Miles And Pay',3
Union
Select 'Gross Pay','Miles And Pay',4
Union
Select 'Pay Details','Miles And Pay',5
Union
Select 'Service Exceptions','Performance',6
Union
Select 'Service Exceptions Affecting OnTime','Performance',7
Union
Select 'Preventable Accidents','Safety',8
Union
Select 'Non-Preventable Accidents','Safety',9
Union
Select 'Vehicle Incidents','Safety',10
Union
Select 'Injuries','Safety',11
Union
Select 'Driver Responsible Spills','Safety',12


While @BeginDate < @EndDate
Begin
	Insert into #Weeks (MonthAndWeek,Begin_Date,End_Date)
	Select cast(DatePart(mm,@begindate) as varchar(20)) + '/' + cast(DatePart(day,@begindate) as varchar(20)) + '/' + cast(DatePart(year,@begindate) as varchar(20)) + '/', 
	       @BeginDate,
	       @BeginDate+7


	Set @BeginDate = DateAdd(week,1,@BeginDate)
End	

select *

into   #LastThirteenWeeks
from   #Weeks
Where  End_Date > DateAdd(week,-12,@EndDate)

/*
DECLARE	@t TABLE(
	begindate 							DATETIME,
	enddate 							DATETIME,
	Driver_ID 							VARCHAR(20),
	Driver_Name 						VARCHAR(100),
	Hire_Date 							DATETIME
		)

INSERT INTO @t
	SELECT	mpp_hiredate as begin_date,
		mpp_terminationdt as end_date
		mpp_id,
		mpp_lastfirst,
		mpp_hiredate
	  FROM	#Weeks,
			manpowerprofile (NOLOCK) mpp,
			city (NOLOCK)
	 WHERE	mpp.mpp_id = @DriverID AND
		mpp.mpp_city = city.cty_code
*/

Create Table #ScoreCardType (Type varchar(255),Value float,MonthAndWeek varchar(50))


Insert into #ScoreCardType 
select 'Total Miles', SUM(ISNULL(s.stp_lgh_mileage, 0)),MonthAndWeek
		FROM stops s WITH (NOLOCK), assetassignment a WITH (NOLOCK),#Weeks
			
		WHERE a.asgn_enddate>= Begin_Date
					and a.asgn_enddate < End_Date
					and a.asgn_type = 'DRV'
					and (@DriverID=a.asgn_id) 
					and a.lgh_number=s.lgh_number
Group By MonthAndWeek



Insert into #ScoreCardType 
select 'Loaded Miles', 
 SUM(ISNULL(s.stp_lgh_mileage, 0)),MonthAndWeek
		FROM stops s WITH (NOLOCK), assetassignment a WITH (NOLOCK),#Weeks
			
		WHERE a.asgn_enddate>= Begin_Date
					and a.asgn_enddate < End_Date
					and a.asgn_type = 'DRV'
					and (@DriverID=a.asgn_id) 
					and a.lgh_number=s.lgh_number
					and s.stp_loadstatus = 'LD'
Group By MonthAndWeek					


Insert into #ScoreCardType 
select 'Empty Miles', SUM(ISNULL(s.stp_lgh_mileage, 0)),MonthAndWeek
		FROM stops s WITH (NOLOCK), assetassignment a WITH (NOLOCK),#Weeks
			
		WHERE a.asgn_enddate>= Begin_Date
					and a.asgn_enddate < End_Date
					and a.asgn_type = 'DRV'
					and (@DriverID=a.asgn_id) 
					and a.lgh_number=s.lgh_number
					and s.stp_loadstatus <> 'LD'
Group By MonthAndWeek					


Insert into #ScoreCardType 
select 'Loads (Dispatches)', cast(count(ISNULL(a.lgh_number, 0)) as float),MonthAndWeek
		FROM assetassignment a WITH (NOLOCK),#Weeks
			
		WHERE a.asgn_enddate>= Begin_Date
					and a.asgn_enddate < End_Date
					and a.asgn_type = 'DRV'
					and (@DriverID=a.asgn_id) 
Group By MonthAndWeek

Insert into #ScoreCardType 
select 'Gross Pay', SUM(ISNULL(pd.pyd_amount, 0)),MonthAndWeek
		FROM paydetail pd (NOLOCK),#Weeks
			
		WHERE pyh_payperiod>=Begin_Date
					and pyh_payperiod<End_Date
					and @DriverID=asgn_id
					and asgn_type='DRV'
					and pyd_pretax = 'Y'
				
Group By MonthAndWeek


Insert into #ScoreCardType 
select 'Pay Details', count(ISNULL(pd.pyd_amount, 0)),MonthAndWeek
		FROM paydetail pd (NOLOCK),#Weeks
			
		WHERE pyh_payperiod>=Begin_Date
					and pyh_payperiod<End_Date
					and @DriverID=asgn_id
					and asgn_type='DRV'
					and pyd_pretax = 'Y'
Group By MonthAndWeek

Insert into #ScoreCardType 
select 'Bonus Impact Service Exceptions', 
COUNT (se.sxn_stp_number),MonthAndWeek
	FROM 	Serviceexception se WITH (NOLOCK),#Weeks
			WHERE se.sxn_createddate >= Begin_Date and se.sxn_createddate < End_Date
				AND se.sxn_asgn_type='DRV'		
				And se.sxn_asgn_id=@DriverID
				And se.sxn_delete_flag='n'
				and se.sxn_affectsPay='Y'
Group By MonthAndWeek

Insert into #ScoreCardType 
select 'Service Exceptions',  COUNT (se.sxn_stp_number),MonthAndWeek
	FROM 	Serviceexception se WITH (NOLOCK),#Weeks
			WHERE se.sxn_createddate >= Begin_Date and se.sxn_createddate < End_Date
				AND se.sxn_asgn_type='DRV'		
				And se.sxn_asgn_id=@DriverID
				And se.sxn_delete_flag='n'
Group By MonthAndWeek
				

Insert into #ScoreCardType 
select 'Service Exceptions Affecting OnTime',
COUNT (se.sxn_stp_number),MonthAndWeek
	FROM 	Serviceexception se WITH (NOLOCK),#Weeks
			WHERE se.sxn_createddate >= Begin_Date and se.sxn_createddate < End_Date
				AND se.sxn_asgn_type='DRV'		
				And se.sxn_asgn_id=@DriverID
				And se.sxn_delete_flag='n'
				and se.sxn_late in ('P','B','D')
Group By MonthAndWeek



Insert into #ScoreCardType 
select 'Preventable Accidents', COUNT (*),MonthAndWeek
	FROM 	DriverAccident a WITH (NOLOCK),#Weeks
			WHERE a.dra_accidentdate >= Begin_Date and a.dra_accidentdate < End_Date
				AND A.dra_preventable = 'Y'
				and @DriverID= mpp_id
Group By MonthAndWeek

Insert into #ScoreCardType 
select 'Non Preventable Accidents', COUNT (*),MonthAndWeek
	FROM 	DriverAccident a WITH (NOLOCK),#Weeks
			WHERE a.dra_accidentdate >= Begin_Date and a.dra_accidentdate < End_Date
				AND A.dra_preventable = 'N'
				and @DriverID= mpp_id
Group By MonthAndWeek

Insert into #ScoreCardType 
select 'Vehicle Incidents',COUNT (*),MonthAndWeek
	FROM 	DriverAccident  a WITH (NOLOCK),#Weeks
			WHERE a.dra_accidentdate >= Begin_Date and a.dra_accidentdate < End_Date
				--AND a.losstypedescription='Vehicle Incident'
				and @DriverID= mpp_id
Group By MonthAndWeek



Select ReportCategory,
       ScoreCardReportsAndWeeks.MonthAndWeek,
       --Begin_Date,
       --End_Date,
       ReportName,
       Value

From

#scorecardtype

Right Join

(
select *

from  #ScoreCardReports,#weeks-- #ScoreCardReportsAndCategories
		 
) as ScoreCardReportsAndWeeks On ScoreCardReportsAndWeeks.MonthAndWeek = #scorecardtype.MonthAndWeek
				 And
				 ScoreCardReportsAndWeeks.ReportName = #scorecardtype.type
                       
Order By ReportCategory,SortOrder,Begin_Date
		  
select manpowerprofile.mpp_id as DriverID,
       manpowerprofile.mpp_lastfirst as DriverName,
       manpowerprofile.mpp_hiredate as HireDate,
       manpowerprofile.mpp_teamleader as TeamLeader,
       manpowerprofile.mpp_type1 as DriverType1,
       manpowerprofile.mpp_type2 as DriverType2,

       manpowerprofile.mpp_type3 as DriverType3,
       mpp_tractornumber as Tractor,
       mpp_terminal as Terminal,
       mpp_domicile as Domicile,
       NextLicenseExpirationDate = (SELECT MAX(exp_expirationdate) FROM expiration WHERE exp_id = @driverid AND exp_idtype = 'DRV' AND exp_code = 'LIC' AND exp_expirationdate > '1/1/2004'),
       NextPhysicalDate = (SELECT MAX(exp_expirationdate) FROM expiration WHERE exp_id = @driverid AND exp_idtype = 'DRV' AND exp_code = 'PHYS' AND  exp_expirationdate > '1/1/2004')


from   manpowerprofile (NOLOCK)
Where  mpp_id = @DriverID


select * from #LastThirteenWeeks



Select ReportCategory,
       ScoreCardReportsAndWeeks.MonthAndWeek,
       --Begin_Date,
       --End_Date,
       ReportName,
       Value

From

#scorecardtype

Right Join

(
select *

from  #ScoreCardReports,#LastThirteenWeeks-- #ScoreCardReportsAndCategories
		 
) as ScoreCardReportsAndWeeks On ScoreCardReportsAndWeeks.MonthAndWeek = #scorecardtype.MonthAndWeek
				 And
				 ScoreCardReportsAndWeeks.ReportName = #scorecardtype.type
                       
Order By ReportCategory,SortOrder,Begin_Date
		  
select manpowerprofile.mpp_id as DriverID,
       manpowerprofile.mpp_lastfirst as DriverName,
       manpowerprofile.mpp_hiredate as HireDate,
       manpowerprofile.mpp_teamleader as TeamLeader,
       manpowerprofile.mpp_type1 as DriverType1,
       manpowerprofile.mpp_type2 as DriverType2,
       manpowerprofile.mpp_type3 as DriverType3,
       mpp_tractornumber as Tractor,
       mpp_terminal as Terminal,
       mpp_domicile as Domicile,
       NextLicenseExpirationDate = (SELECT MAX(exp_expirationdate) FROM expiration WHERE exp_id = @driverid AND exp_idtype = 'DRV' AND exp_code = 'LIC' AND exp_expirationdate > '1/1/2004'),
       NextPhysicalDate = (SELECT MAX(exp_expirationdate) FROM expiration WHERE exp_id = @driverid AND exp_idtype = 'DRV' AND exp_code = 'PHYS' AND  exp_expirationdate > '1/1/2004')


from   manpowerprofile (NOLOCK)
Where  mpp_id = @DriverID






GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_DriverScoreCard] TO [public]
GO
