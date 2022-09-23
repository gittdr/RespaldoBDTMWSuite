SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE         Proc [dbo].[DriverAwareSuite_ExpirationSummary]
	(
	
	@Year varchar(10)='2003',
	@Month int = 1,
	@DriverID varchar(200)=''
	)
AS

Set NoCount On

Declare @LowDtYear datetime
Declare @HighDtYear datetime
Declare @LowDt datetime
Declare @HighDt datetime

	
Set @LowDtYear = cast('1/1/' + @Year as datetime)
Set @HighDtYear = DateAdd(year,1,@LowDtYear) 
		

Set @LowDt = cast(cast(@Month as varchar(50)) + '/1/' + @Year as datetime)
Set @HighDt = DateAdd(Month,1,@LowDt)

Select 
	ExpirationName=IsNull((Select labelfile.name from labelfile (NOLOCK) where labeldefinition = 'DrvExp' and labelfile.abbr = exp_code),exp_code),
	cast(sum(cast(datediff(mi,exp_expirationdate,exp_compldate) as float)/cast(60 as float)) as decimal(15,2)) as MTDHours,
	count(exp_key) MTDCount,
	0 as YTDHours,
	0 as YTDCount
	
into    #TempMonth
From    expiration (NOLOCK)
Where   exp_id = @DriverID 
	And
	exp_expirationdate >= @LowDt And exp_expirationdate < @HighDt
	And
	exp_completed = 'Y'
	And
	exp_idtype = 'DRV'
Group by exp_code

Select 
	ExpirationName=IsNull((Select labelfile.name from labelfile (NOLOCK) where labeldefinition = 'DrvExp' and labelfile.abbr = exp_code),exp_code),
	cast(0 as decimal(15,2)) as MTDHours,
	cast(0 as int) as MTDCount,
	cast(sum(cast(datediff(mi,exp_expirationdate,exp_compldate) as float)/cast(60 as float)) as decimal(15,2)) as YTDHours,
	count(exp_key) YTDCount
into    #TempResults
From    expiration (NOLOCK)
Where   exp_id = @DriverID 
	And
	exp_expirationdate >= @LowDtYear And exp_expirationdate < @HighDtYear
	And
	exp_completed = 'Y'
	And
	exp_idtype = 'DRV'
Group by exp_code

--select #TempMonth.MTDCount from #TempMonth,#TempResults where #TempResults.ExpirationName = #TempMonth.ExpirationName

update #TempResults
Set MTDCount = IsNull((select MTDCount from #TempMonth where #TempResults.ExpirationName = #TempMonth.ExpirationName),0),
    MTDHours = IsNull((select MTDHours from #TempMonth where #TempResults.ExpirationName = #TempMonth.ExpirationName),0)

Select * from #TempResults









GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_ExpirationSummary] TO [public]
GO
