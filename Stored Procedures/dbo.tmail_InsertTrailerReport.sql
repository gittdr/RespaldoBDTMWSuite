SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_InsertTrailerReport]
		@trl_id										VARCHAR(13),
		@tch_dttm									DATETIME,
		@tch_rcvd									DATETIME,
		@acm_system									VARCHAR(6),
		@tch_batteryalert							CHAR(1),
		@tch_fuelalert								CHAR(1),
		@tch_pmalert								CHAR(1),
		@tch_temp1alert								CHAR(1),
		@tch_temp2alert								CHAR(1),
		@tch_temp3alert								CHAR(1),
		@tch_temp4alert								CHAR(1),
		@tch_temp5alert								CHAR(1),
		@tch_ambient								FLOAT,
		@tch_discharge								FLOAT,
		@tch_cmpt1_return							FLOAT,
		@tch_cmpt1_setpoint							FLOAT,
		@tch_cmpt1_state							VARCHAR(6),
		@tch_cmpt2_return							FLOAT,
		@tch_cmpt2_setpoint							FLOAT,
		@tch_cmpt2_state							VARCHAR(6),
		@tch_cmpt3_return							FLOAT,
		@tch_cmpt3_setpoint							FLOAT,
		@tch_cmpt3_state							VARCHAR(6),
		@tch_cmpt4_return							FLOAT,
		@tch_cmpt4_setpoint							FLOAT,
		@tch_cmpt4_state							VARCHAR(6),
		@tch_cmpt5_return							FLOAT,
		@tch_cmpt5_setpoint							FLOAT,
		@tch_cmpt5_state							VARCHAR(6),
		@tch_auxtemp1								FLOAT,
		@tch_auxtemp2								FLOAT,
		@tch_auxtemp3								FLOAT,
		@tch_auxtemp4								FLOAT,
		@tch_auxtemp5								FLOAT,
		@tch_door1									CHAR(1),
		@tch_door1b									CHAR(1),
		@tch_door2									CHAR(1),
		@tch_door3									CHAR(1),
		@tch_door4									CHAR(1),
		@tch_door5									CHAR(1),
		@tch_hook									VARCHAR(6),
		@tch_hooktractor							VARCHAR(8),
		@tch_airbrake								CHAR(1),
		@tch_intelliset								VARCHAR(20),
		@tch_alarmsummary							VARCHAR(6),
		@tch_reefermode								VARCHAR(6),
		@tch_power									CHAR(1),
		@tch_servicestate							VARCHAR(6),
		@tch_standbystatus							VARCHAR(6),
		@tch_standbyhours							INT,
		@tch_switchonhours							INT,
		@tch_triggerevent							VARCHAR(MAX),
		@tch_afax									VARCHAR(6),
		@tch_voltage								FLOAT,
		@tch_controlprobe							CHAR(1),
		@tch_enginehrs								INT,
		@tch_fuel									FLOAT,
		@tch_pmhour									INT,
		@ckc_number									INT,
		@tch_loadedstatus							VARCHAR(12),
		@tch_landmarkcity							VARCHAR(50),
		@tch_landmarkstate							VARCHAR(3),
		@tch_landmarkname							VARCHAR(220),
		@tch_motionstatus							VARCHAR(12),
		@tch_dwellstatus							VARCHAR(12),
		@tch_motionsummary							VARCHAR(MAX),
		@alarm_description							VARCHAR(MAX),
		@tch_assettype								VARCHAR(12), 
		@tch_consumingexternalpower 				BIT, 
		@tch_powersource							VARCHAR(12), 
		@tch_reefer_remote_temperature_sensor1 		FLOAT,
		@tch_reefer_remote_temperature_sensor2 		FLOAT, 
		@tch_reefer_remote_temperature_sensor3 		FLOAT, 
		@tch_supply_air_temperature_zone1 			FLOAT,
		@tch_supply_air_temperature_zone2 			FLOAT, 
		@tch_supply_air_temperature_zone3 			FLOAT, 
		@tch_remote_switch1_open					BIT,
		@tch_remote_switch2_open					BIT, 
		@tch_zone1_load_status						VARCHAR(12), 
		@tch_zone2_load_status						VARCHAR(12), 
		@tch_zone3_load_status						VARCHAR(12)

AS


/**
 * 
 * NAME:
 * dbo.tmail_InsertTrailerReport
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Inserts trailer status reports into the TrailerAlarmDetail and TrailerCommHistory table
 *
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * none.
 *
 * 
 * REVISION HISTORY:
 * 11/03/2014 – PTS79455 - Abdullah Binghunaiem – Initial Creation
 * 03/19/2015 - PTS79455 - Abdullah Binghunaiem - Added extra columns
 *
 **/

SET NOCOUNT ON

DECLARE 
	@tch_id int

BEGIN

	INSERT INTO [dbo].[trailercommhistory] (
		trl_id,
		tch_dttm,
		tch_rcvd,
		acm_system,
		tch_batteryalert,
		tch_fuelalert,
		tch_pmalert,
		tch_temp1alert,
		tch_temp2alert,
		tch_temp3alert,
		tch_temp4alert,
		tch_temp5alert,
		tch_ambient,
		tch_discharge,
		tch_cmpt1_return,
		tch_cmpt1_setpoint,
		tch_cmpt1_state,
		tch_cmpt2_return,
		tch_cmpt2_setpoint,
		tch_cmpt2_state,
		tch_cmpt3_return,
		tch_cmpt3_setpoint,
		tch_cmpt3_state,
		tch_cmpt4_return,
		tch_cmpt4_setpoint,
		tch_cmpt4_state,
		tch_cmpt5_return,
		tch_cmpt5_setpoint,
		tch_cmpt5_state,
		tch_auxtemp1,
		tch_auxtemp2,
		tch_auxtemp3,
		tch_auxtemp4,
		tch_auxtemp5,
		tch_door1,
		tch_door1b,
		tch_door2,
		tch_door3,
		tch_door4,
		tch_door5,
		tch_hook,
		tch_hooktractor,
		tch_airbrake,
		tch_intelliset,
		tch_alarmsummary,
		tch_reefermode,
		tch_power,
		tch_servicestate,
		tch_standbystatus,
		tch_standbyhours,
		tch_switchonhours,
		tch_triggerevent,
		tch_afax,
		tch_voltage,
		tch_controlprobe,
		tch_enginehrs,
		tch_fuel,
		tch_pmhour,
		ckc_number,
		tch_loadedstatus,
		tch_landmarkcity,
		tch_landmarkstate,
		tch_landmarkname,
		tch_motionstatus,
		tch_dwellstatus,
		tch_assettype, 
		tch_consumingexternalpower, 
		tch_powersource, 
		tch_reefer_remote_temperature_sensor1,
		tch_reefer_remote_temperature_sensor2, 
		tch_reefer_remote_temperature_sensor3, 
		tch_supply_air_temperature_zone1,
		tch_supply_air_temperature_zone2, 
		tch_supply_air_temperature_zone3, 
		tch_remote_switch1_open,
		tch_remote_switch2_open, 
		tch_zone1_load_status, 
		tch_zone2_load_status, 
		tch_zone3_load_status)
	VALUES (
		@trl_id,
		@tch_dttm,
		@tch_rcvd,
		@acm_system,
		@tch_batteryalert,
		@tch_fuelalert,
		@tch_pmalert,
		@tch_temp1alert,
		@tch_temp2alert,
		@tch_temp3alert,
		@tch_temp4alert,
		@tch_temp5alert,
		@tch_ambient,
		@tch_discharge,
		@tch_cmpt1_return,
		@tch_cmpt1_setpoint,
		@tch_cmpt1_state,
		@tch_cmpt2_return,
		@tch_cmpt2_setpoint,
		@tch_cmpt2_state,
		@tch_cmpt3_return,
		@tch_cmpt3_setpoint,
		@tch_cmpt3_state,
		@tch_cmpt4_return,
		@tch_cmpt4_setpoint,
		@tch_cmpt4_state,
		@tch_cmpt5_return,
		@tch_cmpt5_setpoint,
		@tch_cmpt5_state,
		@tch_auxtemp1,
		@tch_auxtemp2,
		@tch_auxtemp3,
		@tch_auxtemp4,
		@tch_auxtemp5,
		@tch_door1,
		@tch_door1b,
		@tch_door2,
		@tch_door3,
		@tch_door4,
		@tch_door5,
		@tch_hook,
		@tch_hooktractor,
		@tch_airbrake,
		@tch_intelliset,
		@tch_alarmsummary,
		@tch_reefermode,
		@tch_power,
		@tch_servicestate,
		@tch_standbystatus,
		@tch_standbyhours,
		@tch_switchonhours,
		@tch_triggerevent,
		@tch_afax,
		@tch_voltage,
		@tch_controlprobe,
		@tch_enginehrs,
		@tch_fuel,
		@tch_pmhour,
		@ckc_number,
		@tch_loadedstatus,
		@tch_landmarkcity,
		@tch_landmarkstate,
		@tch_landmarkname,
		@tch_motionstatus,
		@tch_dwellstatus,
		@tch_assettype, 
		@tch_consumingexternalpower, 
		@tch_powersource, 
		@tch_reefer_remote_temperature_sensor1,
		@tch_reefer_remote_temperature_sensor2, 
		@tch_reefer_remote_temperature_sensor3, 
		@tch_supply_air_temperature_zone1,
		@tch_supply_air_temperature_zone2, 
		@tch_supply_air_temperature_zone3, 
		@tch_remote_switch1_open,
		@tch_remote_switch2_open, 
		@tch_zone1_load_status, 
		@tch_zone2_load_status, 
		@tch_zone3_load_status)
END

SELECT @tch_id = SCOPE_IDENTITY();

/************************************************************************************
 Add the alarm details
*************************************************************************************/

IF @trl_id IS NULL OR @alarm_description = ''
BEGIN
	RETURN
END

-- Insert the alarm details
INSERT INTO [dbo].[traileralarmdetail]
           (tch_id
           ,tad_text
           ,tadr_id)
     VALUES
           (@tch_id
           ,@alarm_description
           ,NULL
           )
GO
GRANT EXECUTE ON  [dbo].[tmail_InsertTrailerReport] TO [public]
GO
