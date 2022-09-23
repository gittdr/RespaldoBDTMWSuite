SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[CurrentTrailerCommHistoryView]     
AS      
/*******************************************************************************************************************
  Revision History:
  Date         Name             Label/PTS        Description
  -----------  ---------------  -------------    ----------------------------------------------------------
  12/06/2017   MBR				NSUITE-202138    Retrieves most current trailer tracking data by trailer id
********************************************************************************************************************/
SELECT tcm.tch_id
		 , tcm.trl_id
		 , tcm.tch_dttm
		 , tcm.tch_rcvd
		 , tcm.tch_power
		 , tcm.tch_door1
		 , tcm.tch_door2
		 , tcm.tch_door3
		 , tcm.tch_auxtemp1
		 , tcm.tch_auxtemp2
		 , tcm.tch_auxtemp3
		 , tcm.tch_auxtemp4
		 , tcm.tch_auxtemp5
		 , tcm.tch_cmpt1_setpoint
		 , tcm.tch_cmpt2_setpoint
		 , tcm.tch_cmpt3_setpoint
		 , tcm.tch_cmpt1_return
		 , tcm.tch_cmpt2_return
		 , tcm.tch_cmpt3_return
		 , tcm.tch_supply_air_temperature_zone1
		 , tcm.tch_supply_air_temperature_zone2
		 , tcm.tch_supply_air_temperature_zone3
		 , tcm.tch_enginehrs
		 , tcm.tch_cmpt1_state
		 , tcm.tch_cmpt2_state
		 , tcm.tch_cmpt3_state
		 , tcm.tch_alarmsummary
		 , tcm.tch_triggerevent
		 , tcm.tch_fuel
		 , tcm.tch_reefermode
		 , tcm.tch_ambient
		 , tcm.tch_powersource
		 , tcm.tch_motionstatus
		 , tcm.tch_voltage
		 , tcm.tch_landmarkcity
		 , tcm.tch_landmarkstate

FROM (
SELECT tch.tch_id
		 , tch.trl_id
		 , tch.tch_dttm
		 , tch.tch_rcvd
		 , tch.tch_power
		 , tch.tch_door1
		 , tch.tch_door2
		 , tch.tch_door3
		 , tch.tch_auxtemp1
		 , tch.tch_auxtemp2
		 , tch.tch_auxtemp3
		 , tch.tch_auxtemp4
		 , tch.tch_auxtemp5
		 , tch.tch_cmpt1_setpoint
		 , tch.tch_cmpt2_setpoint
		 , tch.tch_cmpt3_setpoint
		 , tch.tch_cmpt1_return
		 , tch.tch_cmpt2_return
		 , tch.tch_cmpt3_return
		 , tch.tch_supply_air_temperature_zone1
		 , tch.tch_supply_air_temperature_zone2
		 , tch.tch_supply_air_temperature_zone3
		 , tch.tch_enginehrs
		 , tch.tch_cmpt1_state
		 , tch.tch_cmpt2_state
		 , tch.tch_cmpt3_state
		 , tch.tch_alarmsummary
		 , tch.tch_triggerevent
		 , tch.tch_fuel
		 , tch.tch_reefermode
		 , tch.tch_ambient
		 , tch.tch_powersource
		 , tch.tch_motionstatus
		 , tch.tch_voltage
		 , tch.tch_landmarkcity
		 , tch.tch_landmarkstate
		 , ROW_NUMBER() OVER (PARTITION BY trl_id ORDER BY tch_dttm DESC) AS theRowNum
FROM TrailerCommHistory tch) AS tcm
WHERE tcm.theRowNum = 1;	
GO
GRANT SELECT ON  [dbo].[CurrentTrailerCommHistoryView] TO [public]
GO
