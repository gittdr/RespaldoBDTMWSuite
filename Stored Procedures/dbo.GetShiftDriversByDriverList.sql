SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[GetShiftDriversByDriverList] (@driverTable as TablVarDriverListType READONLY)  
AS  
BEGIN  

	--select * from @tableVar
	select mpp.mpp_id, mpp.mpp_lastfirst, isnull(mpp.sth_id, 0), mpp.sth_startdate, mpp.mpp_terminal, mpp.mpp_fleet, ss_date, mpp.mpp_athome_terminal, 
	mpp_default_shiftstart, mpp_default_shiftend, ss.trc_number, ss.trl_id, ss.car_id, ss.trl_id_2, mpp.mpp_ssn, mpp.mpp_misc1, 
	mpp.mpp_misc2, mpp.mpp_misc3, mpp.mpp_misc4, mpp_default_shiftpriority 
	from manpowerprofile as mpp
	left join shiftschedules as ss on mpp.mpp_id = ss.mpp_id  and ss_date = (select max(ss.ss_date) from shiftschedules as ss 
	where ss.mpp_id = mpp.mpp_id and trc_number is not null and trc_number <> 'UNKNOWN' and trc_number <> '') 
	INNER JOIN @driverTable as drvs ON drvs.DriverId = mpp.mpp_id 
END  
GO
GRANT EXECUTE ON  [dbo].[GetShiftDriversByDriverList] TO [public]
GO
