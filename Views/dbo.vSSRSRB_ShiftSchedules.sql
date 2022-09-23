SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     View [dbo].[vSSRSRB_ShiftSchedules]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_ShiftSchedules
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Safety incidents
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_ShiftSchedules


**************************************************************************
 * RETURNS:
 * Recordset 
 *
 * RESULT SETS:
 * ShiftSchedules View For Fuel Customers only
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 10/24/2014 - Created View
 **/
SELECT [ss_id] as 'ScheduleID'
      ,[trc_number] as 'Tractor'
      ,[mpp_id] as 'DriverID'
      ,[trl_id] as 'TrailerID'
      ,[ss_shift] as 'Shift'
      ,[ss_shiftstatus] as'ShiftStatus'
      ,[ss_date] as 'Shift Date'
	  , (Cast(Floor(Cast([ss_date] as float))as smalldatetime)) as [Shift Date Only]
      ,[ss_starttime] as 'Shift Start Time'
      ,[ss_endtime] as 'Shift End Time'
      ,[ss_terminal] as 'Terminal'
      ,[ss_fleet] as 'Fleet'
      ,[ss_comment] as 'Shift Comments'
      ,[ss_lastupdateby] as 'Last Updated By'
      ,[ss_lastupdatedate] as 'Last Updated Date'
      ,' ' --[trl2_id] 
	  as 'Trailer2'
      ,[car_id] as 'CarID'
      ,[ss_logindate] as 'Login Date'
      ,[ss_logoutdate] as 'Logout Date'
      ,[trl_id_2] as 'TRLID2'
      ,[ss_hometerminal] as 'Home Terminal'
      ,[ss_startcompany] as 'Start Company'
      ,[ss_shiftpriority] as 'Shift Priority'
      ,[ss_timestamp] as 'Timestamp'
      ,' '--[ss_ReturnEMTMode] 
	  as 'Return EMT Mode'
  FROM [dbo].[ShiftSchedules]
GO
GRANT DELETE ON  [dbo].[vSSRSRB_ShiftSchedules] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_ShiftSchedules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_ShiftSchedules] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_ShiftSchedules] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_ShiftSchedules] TO [public]
GO
