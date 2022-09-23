SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetTractorsWithinAirMilesRadius] (@latSeconds INT, @longSeconds INT, @radius INT, @trc_type1 VARCHAR(12), @trc_type2 VARCHAR(12),
												@trc_type3 VARCHAR(12), @trc_type4 VARCHAR(12), @trc_company VARCHAR(12), @trc_division VARCHAR(12),
												@trc_fleet VARCHAR(12), @trc_terminal VARCHAR(12), @include_active_only VARCHAR(1), 
												@include_retired VARCHAR(1), @avl_start_date DATETIME, @avl_end_date DATETIME)
												
AS

BEGIN

	DECLARE @labelCodeLimit  INT
	
	SELECT @labelCodeLimit =
	CASE WHEN @include_active_only = 'Y'
		THEN 200
		ELSE 10000
	END

	SELECT trc_number,
			trc_driver,
			trc_status, 
			ROUND(dbo.fnc_AirMilesBetweenLatLongSeconds(@latSeconds, trc_gps_latitude, @longSeconds, trc_gps_longitude), 2) AS Distance, 
			trc_type1,
			trc_type2,
			trc_type3, 
			trc_type4, 
			trc_company, 
			trc_fleet, 
			trc_terminal, 
			trc_division, 
			trc_gps_date, 
			trc_avl_cmp_id, 
			trc_avl_city,
			trc_avl_date
	FROM tractorprofile
	WHERE (trc_gps_latitude > 0 AND trc_gps_longitude > 0) 
		AND dbo.fnc_AirMilesBetweenLatLongSeconds(@latSeconds, trc_gps_latitude, @longSeconds, trc_gps_longitude) < @radius
		
		AND trc_type1 =	CASE WHEN ISNULL(@trc_type1, 'UNK') <> 'UNK' THEN @trc_type1 ELSE trc_type1	END 
		AND trc_type2 =	CASE WHEN ISNULL(@trc_type2, 'UNK') <> 'UNK' THEN @trc_type2 ELSE trc_type2	END 
		AND trc_type3 =	CASE WHEN ISNULL(@trc_type3, 'UNK') <> 'UNK' THEN @trc_type3 ELSE trc_type3	END 
		AND trc_type4 =	CASE WHEN ISNULL(@trc_type4, 'UNK') <> 'UNK' THEN @trc_type4 ELSE trc_type4	END
		
		AND trc_company = CASE WHEN ISNULL(@trc_company, 'UNK') <> 'UNK' THEN @trc_company ELSE trc_company	END
		AND trc_division = CASE WHEN ISNULL(@trc_division, 'UNK') <> 'UNK' THEN @trc_division ELSE trc_division	END
		AND trc_fleet =	CASE WHEN ISNULL(@trc_fleet, 'UNK') <> 'UNK' THEN @trc_fleet ELSE trc_fleet	END
		AND trc_terminal = CASE WHEN ISNULL(@trc_terminal, 'UNK') <> 'UNK' THEN @trc_terminal ELSE trc_terminal END

		AND trc_status in (select abbr from labelfile where labeldefinition = 'TrcStatus' AND code < @labelCodeLimit)
		AND trc_retiredate > CASE WHEN ISNULL(@include_retired, 'N') = 'N' THEN GETDATE() ELSE '1/1/1950' END
		AND (trc_avl_date >= @avl_start_date AND trc_avl_date <= @avl_end_date)
END

GO
GRANT EXECUTE ON  [dbo].[GetTractorsWithinAirMilesRadius] TO [public]
GO
