SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_tripchange_sp] (
@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for tripchange generalinfo setting
********************************************************************************************************************/
IF EXISTS (
		SELECT 1
		FROM @inserted i
		INNER JOIN @deleted d ON i.lgh_number = d.lgh_number
		INNER JOIN orderheader o ON i.mov_number = o.mov_number
		WHERE (
				d.lgh_carrier <> i.lgh_carrier
				OR d.lgh_outstatus <> i.lgh_outstatus
				)
			AND o.ord_reftype = 'EDICT#'
			AND i.lgh_outstatus = 'DSP'
			AND i.lgh_carrier <> 'UNKNOWN'
		)
BEGIN
	IF EXISTS (
			SELECT 1
			FROM @inserted i
			INNER JOIN @deleted d ON i.lgh_number = d.lgh_number
			WHERE i.lgh_carrier <> d.lgh_carrier
			) --UPDATE(lgh_carrier)
		AND EXISTS (
			SELECT 1
			FROM dbo.generalinfo
			WHERE gi_name = 'tripchange'
				AND gi_string1 = 'legheader'
				AND gi_string2 = 'lgh_carrier'
			)
	BEGIN
		INSERT dbo.tripchange (
			mov_number
			,lgh_number
			,tablechanged
			,changetype
			,changevalue
			,last_updatedby
			,last_updatedate
			)
		SELECT i.mov_number
			,i.lgh_number
			,'legheader'
			,'carrier'
			,lgh_carrier
			,SUSER_NAME()
			,GETDATE()
		FROM @inserted i
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.tripchange
				WHERE tripchange.mov_number = i.mov_number
					AND tripchange.lgh_number = i.lgh_number
					AND tripchange.tablechanged = 'legheader'
					AND tripchange.changetype = 'carrier'
					AND tripchange.changevalue = i.lgh_carrier
					AND tripchange.last_updatedby = USER
				);
	END;--UPDATE(lgh_carrier) and tripchange GI

	IF EXISTS (
			SELECT 1
			FROM @inserted i
			INNER JOIN @deleted d ON i.lgh_number = d.lgh_number
			WHERE i.lgh_outstatus <> d.lgh_outstatus
			) --UPDATE(lgh_outstatus)
		AND EXISTS (
			SELECT 1
			FROM generalinfo
			WHERE gi_name = 'tripchange'
				AND gi_string1 = 'legheader'
				AND gi_string2 = 'lgh_outstatus'
			)
	BEGIN
		INSERT dbo.tripchange (
			mov_number
			,lgh_number
			,tablechanged
			,changetype
			,changevalue
			,last_updatedby
			,last_updatedate
			)
		SELECT i.mov_number
			,i.lgh_number
			,'legheader'
			,'carrier'
			,i.lgh_carrier
			,SUSER_NAME()
			,GETDATE()
		FROM @inserted i
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.tripchange
				WHERE tripchange.mov_number = i.mov_number
					AND tripchange.lgh_number = i.lgh_number
					AND tripchange.tablechanged = 'legheader'
					AND tripchange.changetype = 'carrier'
					AND tripchange.changevalue = i.lgh_carrier
					AND tripchange.last_updatedby = USER
				);
	END;--UPDATE(lgh_outstatus) and tripchange GI
END;--at least one valid input in the inserted/deleted tables
GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_tripchange_sp] TO [public]
GO
