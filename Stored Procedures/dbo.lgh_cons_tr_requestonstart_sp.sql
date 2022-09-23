SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_requestonstart_sp] (
	@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for ProcessFuelReqOnStart,CreateNewRequestOnStart GI setttings that are used in ut_legheader_consolidated.
********************************************************************************************************************/

BEGIN
	DECLARE @lgh_number INT
		,@gf_request INT
		,@trc_fuellevel INT
		,@geofuel_reqid INT
		,@geofuel_gal_override INT
		,@geofuel_fuel_level INT
		,@CreateNewRequestOnStart VARCHAR(30)
		,@CreateNewRequstProc VARCHAR(30)
	

	SELECT @CreateNewRequestOnStart = LEFT(COALESCE(gi_string1, 'N'), 1)
		,@CreateNewRequstProc = RTRIM(COALESCE(NULLIF(gi_string2, ''), 'create_fueloptrequest_sp'))
	FROM generalinfo
	WHERE gi_name = 'CreateNewRequestOnStart'

	DECLARE LegCursor CURSOR LOCAL FAST_FORWARD
	FOR
	SELECT i.lgh_number
		,MAX(g.gf_requestid)
	FROM @inserted i
	LEFT JOIN @deleted d ON i.lgh_number = d.lgh_number
	LEFT JOIN dbo.geofuelrequest g ON i.lgh_number = g.gf_lgh_number
		AND g.gf_status = 'HOLD'
		AND g.gf_process_override = 0
	CROSS JOIN (SELECT TOP 1 gi_string2 FROM dbo.generalinfo WHERE gi_name = 'ProcessFuelReqOnStart') gi
	WHERE i.lgh_outstatus <> COALESCE(d.lgh_outstatus, 'AVL')
		AND CHARINDEX(',' + i.lgh_outstatus + ',', ',' + COALESCE(gi.gi_string2, 'STD,CMP') + ',') > 0
	GROUP BY i.lgh_number;

	OPEN LegCursor

	FETCH NEXT
	FROM LegCursor
	INTO @lgh_number
		,@gf_request

	WHILE @@FETCH_STATUS = 0
	BEGIN
		/* PTS 35205 - Check for the new 'gf_process_override' field. Do NOT update if this is checked.  */
		IF @gf_request IS NOT NULL --There is an existing row to update
		BEGIN
			SELECT TOP 1 @trc_fuellevel = CASE 
					WHEN gf_tank_gal_override = 1
						THEN gf_tank_gals
					ELSE NULL
					END
			FROM dbo.geofuelrequest g
			WHERE gf_requestid = @gf_request

			IF @trc_fuellevel IS NULL
			BEGIN
				SELECT TOP 1 @trc_fuellevel = trc_gal_in_tank
				FROM dbo.tractorprofile
				INNER JOIN dbo.geofuelrequest g ON g.gf_tractor = tractorprofile.trc_number
				WHERE g.gf_status = 'HOLD'
					AND g.gf_lgh_number = @lgh_number
				ORDER BY gf_requestid DESC;
			END;

			SELECT TOP 1 @geofuel_reqid = g.gf_requestid
				,@geofuel_gal_override = g.gf_tank_gal_override
				,@geofuel_fuel_level = g.gf_tank_gals
			FROM dbo.geofuelrequest g
			WHERE g.gf_status = 'HOLD'
				AND g.gf_lgh_number = @lgh_number
			ORDER BY g.gf_requestid DESC;

			-- If there is an manually entered fuel level, do NOT use the value from the Tractorprofile.
			IF @geofuel_gal_override = 1
				SET @trc_fuellevel = @geofuel_fuel_level;

			UPDATE dbo.GeoFuelRequest
			SET gf_status = 'RUN'
				,gf_tank_gals = @trc_fuellevel
			FROM dbo.geofuelrequest g
			WHERE g.gf_status = 'HOLD'
				AND g.gf_requestid = @geofuel_reqid
				AND g.gf_lgh_number = @lgh_number;
		END;
		ELSE
		BEGIN
			-- If a request record is not found, create one.
			IF @CreateNewRequestOnStart = 'Y'
			BEGIN
				EXEC @CreateNewRequstProc @lgh_number;
			END;--IF @CreateNewRequestOnStart = 'Y'
		END;

			FETCH NEXT
	FROM LegCursor
	INTO @lgh_number
		,@gf_request
	END;

	CLOSE LegCursor;
	DEALLOCATE LegCursor;
END;-- EXISTS(SELECT TOP 1 1 FRom @GIKEY WHERE gi_name = 'ProcessFuelReqOnStart' AND ISNULL(LEFTgi_string1,'N') = 'Y')     AND   UPDATE(lgh_outstatus)
GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_requestonstart_sp] TO [public]
GO
