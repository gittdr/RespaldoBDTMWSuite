SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE       Proc [dbo].[DriverAwareSuite_OnOffCount]
	(
	@StartDate 		datetime,
	@EndDate 		datetime,
	@OnlyDriverTypes1 	varchar(255) ='',
	@OnlyDriverTypes2 	varchar(255) ='',
	@OnlyDriverTypes3 	varchar(255)='',
	@OnlyDriverTypes4 	varchar(255)='',
	@OnlyDriverTeamLeaders 	varchar(255)='',
	@OnlyDriverTerminals 	varchar(255)='',
	@OnlyDriverIDs	  	varchar(4000)=''
	)
AS

Set NoCount On

	Set @OnlyDriverTypes1= ',' + ISNULL(rtrim(@OnlyDriverTypes1),'') + ','
	Set @OnlyDriverTypes2= ',' + ISNULL(rtrim(@OnlyDriverTypes2),'') + ','
	Set @OnlyDriverTypes3= ',' + ISNULL(rtrim(@OnlyDriverTypes3),'') + ','
	Set @OnlyDriverTypes4= ',' + ISNULL(rtrim(@OnlyDriverTypes4),'') + ','


	Set @OnlyDriverTeamLeaders= ',' + ISNULL(rtrim(@OnlyDriverTeamLeaders),'') + ','
	Set @OnlyDriverTerminals= ',' + ISNULL(rtrim(@OnlyDriverTerminals),'') + ','

	

	
	Set @OnlyDriverIDs = ',' + ISNULL(rtrim(@OnlyDriverIDs),'') + ','

	Create Table #TempDates (d datetime)


	declare @d datetime
	select @d = @StartDate
	WHILE @d <= @EndDate
	BEGIN
		INSERT INTO #TempDates VALUES (@d)
		SELECT @d = DATEADD(day, 1, @d)
	END 


	--Select @OnlyDriverTypes1

Select  cast(IsNull(Working_Unit_Today,cast(0 as float)) as float) as TimeOn,
	Case When IsNull(cast(Working_Unit_Today as float),0) > 0 Then cast(0 as float) Else cast(1 as float) End as TimeOff,
	(Cast(Floor(Cast([Report_Date] as float))as smalldatetime)) as Report_Date
Into    #TempDriverTimeOnOff
from 	Working_Units_History,
	ManpowerProfile m (NOLOCK)
where   Report_Date between @StartDate and @EndDate
	And mpp_id = Driver_ID
	AND (@OnlyDriverTypes1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDriverTypes1) >0)
	AND (@OnlyDriverTypes2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDriverTypes2) >0)
	AND (@OnlyDriverTypes3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDriverTypes3) >0)
	AND (@OnlyDriverTypes4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDriverTypes4) >0)
	AND (@OnlyDriverTeamLeaders =',,' or CHARINDEX(',' + mpp_teamleader + ',', @OnlyDriverTeamLeaders) >0)
	AND (@OnlyDriverTerminals =',,' or CHARINDEX(',' + mpp_terminal + ',', @OnlyDriverTypes4) >0)
	AND (@OnlyDriverIDs =',,' or CHARINDEX(',' + mpp_id + ',', @OnlyDriverIDs) >0)


Select d as Report_Date,
       Sum(IsNull(TimeOn,0)) as TimeOn,
       Sum(IsNull(TimeOff,0)) as TimeOff
       

From   #TempDates Left Join #TempDriverTimeOnOff On d = Report_Date
Group By Report_Date,d
Order By d






GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_OnOffCount] TO [public]
GO
