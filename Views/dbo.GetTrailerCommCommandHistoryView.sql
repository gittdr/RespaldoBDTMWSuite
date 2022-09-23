SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[GetTrailerCommCommandHistoryView] AS

SELECT checkcall.ckc_date AS Date, checkcall.ckc_number AS CheckCall, checkcall.ckc_latseconds AS Lat, checkcall.ckc_longseconds AS Long,
	   checkcall.ckc_Asgnid AS AssignID, NULL AS Command, dbo.GetTrailerAlarms(trailercommhistory.tch_id, 0) AS Alarm, 
	   orderheader.ord_number AS OrderNumber, orderheader.cmd_code AS Commodity, orderheader.ord_description AS Description, 
	   orderheader.ord_originpoint AS Origin, orderheader.ord_destpoint AS Destination, NULL as CommandStatus,
	   -- PTS 74955 - 04.07.2015 - AB: Added extra columns from trailercommhistory
	   -- PTS 74955 Start
	   trailercommhistory.tch_id As tch_id,trailercommhistory.trl_id As trl_id,trailercommhistory.tch_dttm As tch_dttm,
	   trailercommhistory.tch_rcvd As tch_rcvd,trailercommhistory.acm_system As acm_system,trailercommhistory.tch_batteryalert As tch_batteryalert,
	   trailercommhistory.tch_fuelalert As tch_fuelalert,trailercommhistory.tch_pmalert As tch_pmalert,trailercommhistory.tch_temp1alert As tch_temp1alert,
	   trailercommhistory.tch_temp2alert As tch_temp2alert,trailercommhistory.tch_temp3alert As tch_temp3alert,trailercommhistory.tch_temp4alert As tch_temp4alert,
	   trailercommhistory.tch_temp5alert As tch_temp5alert,trailercommhistory.tch_ambient As tch_ambient,trailercommhistory.tch_discharge As tch_discharge,
	   trailercommhistory.tch_cmpt1_return As tch_cmpt1_return,trailercommhistory.tch_cmpt1_setpoint As tch_cmpt1_setpoint,trailercommhistory.tch_cmpt1_state As tch_cmpt1_state,
	   trailercommhistory.tch_cmpt2_return As tch_cmpt2_return,trailercommhistory.tch_cmpt2_setpoint As tch_cmpt2_setpoint,trailercommhistory.tch_cmpt2_state As tch_cmpt2_state,
	   trailercommhistory.tch_cmpt3_return As tch_cmpt3_return,trailercommhistory.tch_cmpt3_setpoint As tch_cmpt3_setpoint,trailercommhistory.tch_cmpt3_state As tch_cmpt3_state,
	   trailercommhistory.tch_cmpt4_return As tch_cmpt4_return,trailercommhistory.tch_cmpt4_setpoint As tch_cmpt4_setpoint,trailercommhistory.tch_cmpt4_state As tch_cmpt4_state,
	   trailercommhistory.tch_cmpt5_return As tch_cmpt5_return,trailercommhistory.tch_cmpt5_setpoint As tch_cmpt5_setpoint,trailercommhistory.tch_cmpt5_state As tch_cmpt5_state,
	   trailercommhistory.tch_auxtemp1 As tch_auxtemp1,trailercommhistory.tch_auxtemp2 As tch_auxtemp2,trailercommhistory.tch_auxtemp3 As tch_auxtemp3,trailercommhistory.tch_auxtemp4 As tch_auxtemp4,
	   trailercommhistory.tch_auxtemp5 As tch_auxtemp5,trailercommhistory.tch_door1 As tch_door1,trailercommhistory.tch_door1b As tch_door1b,trailercommhistory.tch_door2 As tch_door2,
	   trailercommhistory.tch_door3 As tch_door3,trailercommhistory.tch_door4 As tch_door4,trailercommhistory.tch_door5 As tch_door5,trailercommhistory.tch_hook As tch_hook,
	   trailercommhistory.tch_hooktractor As tch_hooktractor,trailercommhistory.tch_airbrake As tch_airbrake,trailercommhistory.tch_intelliset As tch_intelliset,
	   trailercommhistory.tch_alarmsummary As tch_alarmsummary,trailercommhistory.tch_reefermode As tch_reefermode,trailercommhistory.tch_power As tch_power,
	   trailercommhistory.tch_servicestate As tch_servicestate,trailercommhistory.tch_standbystatus As tch_standbystatus,trailercommhistory.tch_standbyhours As tch_standbyhours,
	   trailercommhistory.tch_switchonhours As tch_switchonhours,trailercommhistory.tch_triggerevent As tch_triggerevent,trailercommhistory.tch_afax As tch_afax,
	   trailercommhistory.tch_voltage As tch_voltage,trailercommhistory.tch_controlprobe As tch_controlprobe,trailercommhistory.tch_enginehrs As tch_enginehrs,
	   trailercommhistory.tch_fuel As tch_fuel,trailercommhistory.tch_pmhour As tch_pmhour,trailercommhistory.ckc_number As ckc_number,trailercommhistory.tch_rpttype As tch_rpttype,
	   trailercommhistory.tch_loadedstatus As tch_loadedstatus,trailercommhistory.tch_landmarkcity As tch_landmarkcity,trailercommhistory.tch_landmarkstate As tch_landmarkstate,
	   trailercommhistory.tch_landmarkname As tch_landmarkname,trailercommhistory.tch_motionstatus As tch_motionstatus,trailercommhistory.tch_dwellstatus As tch_dwellstatus,
	   trailercommhistory.tch_motionsummary As tch_motionsummary,trailercommhistory.tch_assettype As tch_assettype,trailercommhistory.tch_consumingexternalpower As tch_consumingexternalpower,
	   trailercommhistory.tch_powersource As tch_powersource,trailercommhistory.tch_reefer_remote_temperature_sensor1 As tch_reefer_remote_temperature_sensor1,
	   trailercommhistory.tch_reefer_remote_temperature_sensor2 As tch_reefer_remote_temperature_sensor2,trailercommhistory.tch_reefer_remote_temperature_sensor3 As tch_reefer_remote_temperature_sensor3,
	   trailercommhistory.tch_supply_air_temperature_zone1 As tch_supply_air_temperature_zone1,trailercommhistory.tch_supply_air_temperature_zone2 As tch_supply_air_temperature_zone2,
	   trailercommhistory.tch_supply_air_temperature_zone3 As tch_supply_air_temperature_zone3,trailercommhistory.tch_remote_switch1_open As tch_remote_switch1_open,
	   trailercommhistory.tch_remote_switch2_open As tch_remote_switch2_open,trailercommhistory.tch_zone1_load_status As tch_zone1_load_status,trailercommhistory.tch_zone2_load_status As tch_zone2_load_status,
	   trailercommhistory.tch_zone3_load_status As tch_zone3_load_status
	   -- PTS 74955 End
	FROM checkcall
		LEFT OUTER JOIN orderheader ON ord_hdrnumber = dbo.GetOrdHdrForASsetAndDate(checkcall.ckc_Asgntype, checkcall.ckc_Asgnid, checkcall.ckc_date) 
		LEFT OUTER JOIN trailercommhistory ON checkcall.ckc_number = trailercommhistory.ckc_number

	UNION 
	
SELECT trailercommands.trlc_createdate AS Date, NULL AS CheckCall, NULL AS Lat, NULL AS Long, trl_id AS AssignID, dbo.DescribeTrailerCommand(trailercommands.trlc_id) AS Command, 
	   NULL AS Alarm, orderheader.ord_number as OrderNumber, orderheader.cmd_code as Commodity, 
	   orderheader.ord_description as Description, orderheader.ord_originpoint as Origin, orderheader.ord_destpoint as Destination, trailercommands.trlc_status as CommandStatus,
	   -- PTS 74955 - 04.07.2015 - AB: Added extra columns from trailercommhistory
	   -- PTS 74955 Start
	   NULL As tch_id,NULL As trl_id,NULL As tch_dttm,NULL As tch_rcvd,NULL As acm_system,NULL As tch_batteryalert,NULL As tch_fuelalert,NULL As tch_pmalert,NULL As tch_temp1alert,
	   NULL As tch_temp2alert,NULL As tch_temp3alert,NULL As tch_temp4alert,NULL As tch_temp5alert,NULL As tch_ambient,NULL As tch_discharge,NULL As tch_cmpt1_return,NULL As tch_cmpt1_setpoint,
	   NULL As tch_cmpt1_state,NULL As tch_cmpt2_return,NULL As tch_cmpt2_setpoint,NULL As tch_cmpt2_state,NULL As tch_cmpt3_return,NULL As tch_cmpt3_setpoint,NULL As tch_cmpt3_state,
	   NULL As tch_cmpt4_return,NULL As tch_cmpt4_setpoint,NULL As tch_cmpt4_state,NULL As tch_cmpt5_return,NULL As tch_cmpt5_setpoint,NULL As tch_cmpt5_state,NULL As tch_auxtemp1,
	   NULL As tch_auxtemp2,NULL As tch_auxtemp3,NULL As tch_auxtemp4,NULL As tch_auxtemp5,NULL As tch_door1,NULL As tch_door1b,NULL As tch_door2,NULL As tch_door3,NULL As tch_door4,
	   NULL As tch_door5,NULL As tch_hook,NULL As tch_hooktractor,NULL As tch_airbrake,NULL As tch_intelliset,NULL As tch_alarmsummary,NULL As tch_reefermode,NULL As tch_power,
	   NULL As tch_servicestate,NULL As tch_standbystatus,NULL As tch_standbyhours,NULL As tch_switchonhours,NULL As tch_triggerevent,NULL As tch_afax,NULL As tch_voltage,
	   NULL As tch_controlprobe,NULL As tch_enginehrs,NULL As tch_fuel,NULL As tch_pmhour,NULL As ckc_number,NULL As tch_rpttype,NULL As tch_loadedstatus,NULL As tch_landmarkcity,
	   NULL As tch_landmarkstate,NULL As tch_landmarkname,NULL As tch_motionstatus,NULL As tch_dwellstatus,NULL As tch_motionsummary,NULL As tch_assettype,NULL As tch_consumingexternalpower,
	   NULL As tch_powersource,NULL As tch_reefer_remote_temperature_sensor1,NULL As tch_reefer_remote_temperature_sensor2,NULL As tch_reefer_remote_temperature_sensor3,NULL As tch_supply_air_temperature_zone1,
	   NULL As tch_supply_air_temperature_zone2,NULL As tch_supply_air_temperature_zone3,NULL As tch_remote_switch1_open,NULL As tch_remote_switch2_open,NULL As tch_zone1_load_status,NULL As tch_zone2_load_status,NULL As tch_zone3_load_status
	   -- PTS 74955 End
	FROM trailercommands
	   LEFT OUTER JOIN orderheader ON ord_hdrnumber = dbo.GetOrdHdrForAssetAndDate('TRL', trl_id, trlc_createdate)
GO
GRANT DELETE ON  [dbo].[GetTrailerCommCommandHistoryView] TO [public]
GO
GRANT INSERT ON  [dbo].[GetTrailerCommCommandHistoryView] TO [public]
GO
GRANT SELECT ON  [dbo].[GetTrailerCommCommandHistoryView] TO [public]
GO
GRANT UPDATE ON  [dbo].[GetTrailerCommCommandHistoryView] TO [public]
GO
