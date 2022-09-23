SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[HVLIDriverManagementHeaderView]
AS

select 
      /* The following columns MUST be present in view. Column names must be identical and are case-sensitive */
       mpp.mpp_id 'DriverId'
	  /* END required fields */
	 , mpp.mpp_lastname + ',' + left(mpp.mpp_firstname,2) 'DriverName'
	 , MAX(lgh.lgh_outstatus) 'TripStatus' /*TODO: logic to get single trip status */
     , SUBSTRING(convert(varchar(20), mpp.mpp_currentphone), 1, 3) + '-' + 
	   SUBSTRING(convert(varchar(20), mpp.mpp_currentphone), 4, 3) + '-' + 
	   SUBSTRING(convert(varchar(20), mpp.mpp_currentphone), 7, 4) 'DriverPhone'
     , isnull(mpp.mpp_dailyhrsest, 0) 'DailyHours'
	 , isnull(mpp.mpp_weeklyhrsest, 0) 'WeeklyHours'
     , ckc.ckc_comment 'MobileMessageStatus'	 
     
  FROM manpowerprofile mpp
  INNER JOIN legheader lgh (NOLOCK) on mpp.mpp_id = lgh.lgh_driver1
  left join orderheader ord (NOLOCK) on ord.mov_number=lgh.mov_number
  LEFT JOIN checkcall ckc (NOLOCK) on ckc.ckc_number= (select top 1 ckc2.ckc_number
												from checkcall ckc2 
											   where ckc2.ckc_asgnid=lgh.lgh_tractor
	 											 and ckc2.ckc_lghnumber=lgh.lgh_number 
											   order by ckc2.ckc_date desc)
  WHERE ((mpp.mpp_status <> 'OUT' and mpp.mpp_id <> 'UNKNOWN')) 
    AND lgh_outstatus <> 'CMP' 
	And ord_startdate between DATEADD(hour,-18,getDate()) and DATEADD(hour,18,getDate())

GROUP BY mpp.mpp_id
       , mpp.mpp_lastname + ',' + left(mpp.mpp_firstname,2)
	   , mpp_currentphone
	   , mpp.mpp_dailyhrsest
	   , mpp_weeklyhrsest
	   , ckc.ckc_comment
GO
GRANT INSERT ON  [dbo].[HVLIDriverManagementHeaderView] TO [public]
GO
GRANT SELECT ON  [dbo].[HVLIDriverManagementHeaderView] TO [public]
GO
GRANT UPDATE ON  [dbo].[HVLIDriverManagementHeaderView] TO [public]
GO
