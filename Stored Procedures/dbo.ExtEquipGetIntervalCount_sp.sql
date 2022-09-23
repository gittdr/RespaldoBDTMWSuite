SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ExtEquipGetIntervalCount_sp] (
				@car_id varchar(8), 
				@IntervalCount	int			OUT,
				@IntervalMax	int			OUT,
				@warnlevel		varchar(6)	OUT
			)
AS

--PTS 49503 JJF 20091019
IF @car_id = 'UNKNOWN' BEGIN
	SELECT @IntervalCount = 0
	SELECT @IntervalMax = 0
	SELECT @warnlevel = 'NONE'
END
ELSE BEGIN
--END PTS 49503 JJF 20091019
	SELECT	@IntervalCount = count(*)
	FROM	(	

				SELECT	ete_id,
						ete_carrierid,
						ete_availabledate,
						datediff(hour, ete.ete_availabledate, getdate()) as hoursback,
						CASE isnull(car_extequip_interval_hours, 0)
							WHEN 0 THEN 
								(	SELECT	isnull(convert(int, gi_string1), 0)
									FROM	generalinfo 
									WHERE	gi_name = 'ExternalEquipIntervalHours'
								)
								
							ELSE
								 car_extequip_interval_hours 
							END as extequip_interval_hours--,
				FROM	external_equipment ete 
						inner join carrier car on ete.ete_carrierid = car.car_id
				WHERE	ete_carrierid = @car_id
			) hoursback
	WHERE	hoursback <= extequip_interval_hours

	SELECT @IntervalMax = CASE isnull(car_extequip_interval_maxcount, 0)
							WHEN 0 THEN
								(	SELECT	isnull(convert(int, gi_string1), 0)
									FROM	generalinfo 
									WHERE	gi_name = 'ExternalEquipIntervalMaxCount'
								)
							ELSE
								car_extequip_interval_maxcount
							END, 
			@warnlevel = CASE isnull(car_extequip_interval_warnlevel, 'DEF')
							WHEN 'DEF' THEN
								(	SELECT	isnull(gi_string1, 'NONE')
									FROM	generalinfo 
									WHERE	gi_name = 'ExternalEquipIntervalWarnLevel'
								)
							ELSE
								car_extequip_interval_warnlevel
							END 
	FROM	carrier car 
	WHERE	car.car_id = @car_id
--PTS 49503 JJF 20091019
END
--END PTS 49503 JJF 20091019

GO
GRANT EXECUTE ON  [dbo].[ExtEquipGetIntervalCount_sp] TO [public]
GO
