SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[trailercheckcall_view]
AS

	SELECT
		c.ckc_number, 
		c.ckc_asgnid, 
		c.ckc_asgntype, 
		c.ckc_date,
		lg.lgh_number AS 'Leg_Header_Nbr',
		c.ckc_status,
		c.ckc_event,
		c.ckc_city,
		c.ckc_comment,
		c.ckc_updatedby,
		c.ckc_updatedon,
		c.ckc_latseconds,
		c.ckc_longseconds,
		c.ckc_tractor,
		c.ckc_extsensoralarm,
		c.ckc_vehicleignition,
		c.ckc_milesfrom,
		c.ckc_directionfrom,
		c.ckc_validity,
		c.ckc_mtavailable,
		c.ckc_minutes,
		c.ckc_mileage,
		c.ckc_home,
		c.ckc_cityname,
		c.ckc_state,
		c.ckc_zip,
		c.ckc_commentlarge,
		c.ckc_minutes_to_final,
		c.ckc_miles_to_final,
		c.ckc_odometer,
		c.ckc_ExtraData01 AS 'TransactionID',
		c.ckc_ExtraData02 AS 'UnitAddress',
		c.ckc_ExtraData03 AS 'PositionInfo',
		c.ckc_ExtraData04 AS 'ConnectionStatus',
		c.ckc_ExtraData05 AS 'DoorSensorState',
		c.ckc_ExtraData06 AS 'CargoSensorState',
		c.ckc_ExtraData07 AS 'T2BatteryStatus',
		c.ckc_ExtraData08 AS 'PowerState',
		c.ckc_ExtraData09 AS 'AuxSensorState',
		c.ckc_ExtraData10 AS 'ReeferAlarms',
		c.ckc_ExtraData11 AS 'ReeferStatus',
		c.ckc_ExtraData12 AS 'ReeferPower',
		c.ckc_ExtraData13 AS 'MobileHealthStatus',
		c.ckc_ExtraData14 AS 'TethReeferAttention',
		c.ckc_ExtraData15 AS 'TethReeferStatus',
		c.ckc_ExtraData16 AS 'TethReeferSettings',
		c.ckc_ExtraData17 AS 'ProximityInfo',
		c.ckc_ExtraData18 AS 'TripInfo',
		c.ckc_ExtraData19 AS 'OtherEquipmentInfo',
		c.ckc_ExtraData20 AS 'AdditionalInfo',
		c.TripStatus,
		c.ckc_odometer2,
		c.ckc_speed,
		c.ckc_speed2,
		c.ckc_heading,
		c.ckc_gps_type,
		c.ckc_gps_miles,
		c.ckc_fuel_meter,
		c.ckc_idle_meter,
		c.ckc_AssociatedMsgSN
	FROM      
		dbo.checkcall AS c  (NOLOCK)
		LEFT JOIN dbo.legheader AS lg (NOLOCK)
			ON
				c.ckc_asgnid IN (lg.lgh_primary_trailer, lg.lgh_primary_pup, lg.lgh_trailer3, lg.lgh_trailer4)
				AND               
				c.ckc_date BETWEEN lg.lgh_startdate AND lg.lgh_enddate
	WHERE
		c.ckc_asgntype = 'TRL'
GO
