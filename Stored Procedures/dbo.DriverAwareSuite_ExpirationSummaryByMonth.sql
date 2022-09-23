SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE          Proc [dbo].[DriverAwareSuite_ExpirationSummaryByMonth]
	(
	@LowDt 	datetime='10/1/2002',
	@HighDt datetime='12/22/2002',
	@DriverID varchar(200)=''
	)
AS

Select  top 5000
	ExpirationName=IsNull((Select labelfile.name from labelfile (NOLOCK) where labeldefinition = 'DrvExp' and labelfile.abbr = exp_code),exp_code),
	cast(datediff(mi,exp_expirationdate,exp_compldate) as float)/cast(60 as float) as Hours,
	exp_key as ExpKey
	
--into    #TempExpiratons
From    expiration (NOLOCK)
Where   --exp_id = @DriverID 
	--And
	exp_expirationdate >= @LowDt And exp_expirationdate < @HighDt
	And
	exp_completed = 'Y'
	And
	exp_idtype = 'DRV'
--Group by exp_code






GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_ExpirationSummaryByMonth] TO [public]
GO
