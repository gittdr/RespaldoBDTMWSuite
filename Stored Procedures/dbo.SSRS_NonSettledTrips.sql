SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create proc [dbo].[SSRS_NonSettledTrips]

(@DaysBack int,
 @Company varchar(6))

as

select
 assetassignment.lgh_number 'Leg#',
 assetassignment.mov_number 'Move#',
 asgn_type 'AsgnType',
 asgn_id 'AsgnID',
 ISNULL((select mpp_firstname from manpowerprofile  with(nolock) where mpp_id = asgn_id), ' ') as 'First Name',
 ISNULL((select mpp_lastname from manpowerprofile with(nolock)  where mpp_id = asgn_id), ' ') as 'Last Name',
  actg_type 'AcctType',
  (select name from labelfile where labeldefinition = 'ActgType' and abbr = actg_type) as 'Acct Type',
 asgn_date 'AsgnStartDate',
 asgn_enddate 'AsgnEndDate',
 datediff(dd,asgn_enddate,Getdate()) 'DaysSinceCMP',
 ISNULL((select car_name from carrier where car_id = asgn_id), ' ') as 'Carrier Name'
from assetassignment  with(nolock) 
inner join legheader lh  with(nolock)  on lh.lgh_number = assetassignment.lgh_number 
where asgn_status = 'CMP'
and actg_type <> 'N'
and pyd_status = 'NPD'
and datediff(dd,asgn_enddate,Getdate()) > @DaysBack
and asgn_enddate <= GetDate()
and lgh_class1 = @Company
order by asgn_enddate




GO
GRANT EXECUTE ON  [dbo].[SSRS_NonSettledTrips] TO [public]
GO
