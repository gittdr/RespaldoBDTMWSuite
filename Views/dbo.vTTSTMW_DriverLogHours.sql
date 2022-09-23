SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO









CREATE       view [dbo].[vTTSTMW_DriverLogHours]

As

SELECT    log_date as 'Log Date',
	  total_miles as [Total Miles],  
          [log] as [Log], 
          off_duty_hrs as [Off Duty Hours], 
          sleeper_berth_hrs as [Sleeper Berth Hours], 
          driving_hrs as [Driver Hours], 
          on_duty_hrs as [On Duty Hours], 
          processed_flag as [Processed Flag],
	  --(select sum(driving_hrs + on_duty_hrs) from log_driverlogs b where loglog_driverlogs.mpp_id = b.mpp_id),
	  

	  convert(int,(Substring([Service Rule],charindex('/',[Service Rule])+1,5))) - 
          (select sum(b.driving_hrs + b.on_duty_hrs) from log_driverlogs b where log_driverlogs.mpp_id = b.mpp_id and b.log_date >= (log_driverlogs.log_date - ((convert(int,(Left([Service Rule],charindex('/',[Service Rule],1)-1))))-1)) and b.log_date <= log_driverlogs.log_date) as [Available Hours],
	  vTTSTMW_DriverProfile.*

FROM      dbo.log_driverlogs (NOLOCK) Inner Join vTTSTMW_DriverProfile (NOLOCK) On log_driverlogs.mpp_id = vTTSTMW_DriverProfile.[Driver ID]








GO
GRANT SELECT ON  [dbo].[vTTSTMW_DriverLogHours] TO [public]
GO
