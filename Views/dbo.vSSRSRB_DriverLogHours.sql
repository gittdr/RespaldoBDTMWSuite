SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vSSRSRB_DriverLogHours]

 

As

 /**
 *
 * NAME:
 * dbo.[vSSRSRB_DriverLogHours]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Driver Log Hours view
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_DriverLogHours]


**************************************************************************
 * RETURNS:
 * Resultset
 *
 * RESULT SETS:
 * DDriver Log hours table
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created view for SSRS
 **/

SELECT    log_date as 'Log Date',
		(Cast(Floor(Cast(log_date as float))as smalldatetime)) AS [Log Date Only],
			total_miles as [Total Miles],  
			[log] as [Log], 
			off_duty_hrs as [Off Duty Hours], 
			sleeper_berth_hrs as [Sleeper Berth Hours], 
			driving_hrs as [Driver Hours], 
			on_duty_hrs as [On Duty Hours], 
			processed_flag as [Processed Flag],
			convert(int,(Substring([Service Rule],charindex('/',[Service Rule])+1,5))) - 
			(select sum(b.driving_hrs + b.on_duty_hrs) 
			from log_driverlogs b WITH (NOLOCK) 
			where log_driverlogs.mpp_id = b.mpp_id 
			and b.log_date >= 
			(log_driverlogs.log_date - ((convert(int,(Left([Service Rule],charindex('/',[Service Rule],1)-1))))-1)) 
			and b.log_date <= log_driverlogs.log_date) as [Available Hours],
			[Available Hours FromLastReset] =  
			Case When IsNull(rule_reset_indc,'') = 'Y' Then  --If Reset Flag is True Then 
			convert(int,(Substring([Service Rule],charindex('/',[Service Rule])+1,5))) - (IsNull(driving_hrs,0) + IsNull(on_duty_hrs,0) )
			Else
			case when 
			isnull((select max(c.log_date) 
				from log_driverlogs c WITH (NOLOCK) 
				where c.mpp_id = log_driverlogs.mpp_id 
				and c.log_date < log_driverlogs.log_date 
				and c.rule_reset_indc = 'Y'),'1/1/1950') < 
				DateAdd(hour,-convert(int,(Substring([Service Rule],charindex('/',[Service Rule])+1,5))),log_driverlogs.log_date)
				then
			    convert(int,(Substring([Service Rule],charindex('/',[Service Rule])+1,5))) - 
               (select sum(b.driving_hrs + b.on_duty_hrs) from log_driverlogs b WITH (NOLOCK) 
               where log_driverlogs.mpp_id = b.mpp_id 
               and b.log_date >= (log_driverlogs.log_date - 
               ((convert(int,(Left([Service Rule],charindex('/',[Service Rule],1)-1))))-1)) and b.log_date <= log_driverlogs.log_date) 
				Else
				convert(int,(Substring([Service Rule],charindex('/',[Service Rule])+1,5))) -  
				(select sum(b.driving_hrs + b.on_duty_hrs) from log_driverlogs b WITH (NOLOCK) 
				where log_driverlogs.mpp_id = b.mpp_id and b.log_date >= (select max(c.log_date) 
				from log_driverlogs c WITH (NOLOCK) where c.mpp_id = log_driverlogs.mpp_id and c.log_date 
				< log_driverlogs.log_date and c.rule_reset_indc = 'Y') and b.log_date <= log_driverlogs.log_date)
				End

			End,
			vSSRSRB_DriverProfile.*	
FROM      dbo.log_driverlogs WITH (NOLOCK) 
Inner Join vSSRSRB_DriverProfile WITH (NOLOCK) On log_driverlogs.mpp_id = vSSRSRB_DriverProfile.[Driver ID]


GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverLogHours] TO [public]
GO
