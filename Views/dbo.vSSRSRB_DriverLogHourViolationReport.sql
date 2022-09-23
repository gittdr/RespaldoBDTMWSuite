SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE       view [dbo].[vSSRSRB_DriverLogHourViolationReport]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_DriverLogHourViolationReport
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/
Select    TempDriverViolationReport.*
	  
From

(

SELECT    
		log_date as 'Log Date',
		total_miles as [Total Miles],  
		[log] as [Log], 
		off_duty_hrs as [Off Duty Hours], 
		sleeper_berth_hrs as [Sleeper Berth Hours], 
		driving_hrs as [Driver Hours], 
		on_duty_hrs as [On Duty Hours],
		processed_flag as [Processed Flag],
		convert(int,(Substring([Service Rule],charindex('/',[Service Rule])+1,5))) as ServiceRuleHours,
		Case When (select sum(b.driving_hrs + b.on_duty_hrs) from log_driverlogs b where log_driverlogs.mpp_id = b.mpp_id and b.log_date >= (log_driverlogs.log_date - ((convert(int,(Left([Service Rule],charindex('/',[Service Rule],1)-1))))-1)) and b.log_date <= log_driverlogs.log_date) > convert(int,(Substring([Service Rule],charindex('/',[Service Rule])+1,5))) Then
		'Yes'
		Else
		'No'
		End As [Violated Service Rule],

	  vSSRSRB_DriverProfile.*

FROM      dbo.log_driverlogs WITH (NOLOCK) Inner Join vSSRSRB_DriverProfile WITH (NOLOCK) On log_driverlogs.mpp_id = vSSRSRB_DriverProfile.[Driver ID]

) as TempDriverViolationReport

where     [Violated Service Rule] = 'Yes'


GO
GRANT DELETE ON  [dbo].[vSSRSRB_DriverLogHourViolationReport] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_DriverLogHourViolationReport] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_DriverLogHourViolationReport] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverLogHourViolationReport] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_DriverLogHourViolationReport] TO [public]
GO
