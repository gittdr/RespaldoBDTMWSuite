SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[lgh_cons_tr_FPrintTBranch_sp] (
   @inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			          Handle logic for FingerprintAudit & TRACKBRANCH GI setttings that are used in ut_legheader_consolidated.
********************************************************************************************************************/
DECLARE @lgh_dispatchdate BIT = 0
	,@lgh_outstatus BIT = 0
	,@lgh_tractor BIT = 0
	,@lgh_booked_revtype1 BIT = 0
	,@lgh_booked_revtype1_label VARCHAR(20)
  ,@lgh_other_status1 BIT = 0
  ,@lgh_other_status2 BIT = 0;

SELECT @lgh_booked_revtype1_label = ISNULL(userlabelname, 'branch')
FROM generalinfo g
INNER JOIN labelfile l ON g.gi_string3 = l.labeldefinition
WHERE g.gi_name = 'TRACKBRANCH';


WITH CTE AS(
SELECT  
    CASE  WHEN COALESCE(i.lgh_dispatchdate,'2049-12-19 01:23:45.000') <> COALESCE(d.lgh_dispatchdate,'2049-12-19 01:23:45.000') THEN 1 ELSE 0 END AS lgh_dispatchdate_update
  , CASE  WHEN COALESCE(i.lgh_outstatus,'null') <> COALESCE(d.lgh_outstatus,'null') THEN 1 ELSE 0 END AS lgh_outstatus_update
  , CASE  WHEN COALESCE(i.lgh_tractor,'null') <> COALESCE(d.lgh_tractor,'null') THEN 1 ELSE 0 END AS lgh_tractor_update
  , CASE  WHEN COALESCE(i.lgh_booked_revtype1,'null') <> COALESCE(d.lgh_booked_revtype1,'null') THEN 1 ELSE 0 END AS lgh_booked_revtype1_update
  , CASE  WHEN COALESCE(i.lgh_other_status1,'null') <> COALESCE(d.lgh_other_status1,'null') THEN 1 ELSE 0 END AS lgh_other_status1_update
  , CASE  WHEN COALESCE(i.lgh_other_status2,'null') <> COALESCE(d.lgh_other_status2,'null') THEN 1 ELSE 0 END AS lgh_other_status2_update
FROM @deleted d
INNER JOIN @inserted i ON d.ord_hdrnumber = i.ord_hdrnumber
)
SELECT @lgh_dispatchdate = lgh_dispatchdate_update
	,@lgh_outstatus = lgh_outstatus_update
	,@lgh_tractor = lgh_tractor_update
	,@lgh_booked_revtype1 = lgh_booked_revtype1_update
  ,@lgh_other_status1 = lgh_other_status1_update
  ,@lgh_other_status2 = lgh_other_status2_update
FROM CTE;


BEGIN
	IF @lgh_dispatchdate = 1
	BEGIN
		INSERT dbo.dispaudit (
			ord_hdrnumber
			,lgh_number
			,updated_by
			,updated_dt
			,old_dispatch_dt
			,new_dispatch_dt
			)
		SELECT stops.ord_hdrnumber
			,i.stp_number_start
			,SUSER_NAME()
			,GETDATE()
			,d.lgh_dispatchdate
			,i.lgh_dispatchdate
		FROM @deleted d
		INNER JOIN @inserted i ON i.lgh_number = d.lgh_number
			AND i.lgh_dispatchdate <> d.lgh_dispatchdate
		LEFT JOIN dbo.stops ON COALESCE(i.stp_number_start,-1) = COALESCE(stops.stp_number,-1);
	END;--IF UPDATE(lgh_dispatchdate)

	IF @lgh_outstatus = 1
	BEGIN
		INSERT dbo.expedite_audit (
			ord_hdrnumber
			,updated_by
			,updated_dt
			,activity
			)
		SELECT stops.ord_hdrnumber
			,UPPER(SUSER_NAME())
			,GETDATE()
			,'COMPLETE'
		FROM @inserted i
		INNER JOIN @deleted d ON i.lgh_number = d.lgh_number
		INNER JOIN dbo.stops ON i.stp_number_start = stops.stp_number
		WHERE i.lgh_outstatus = 'CMP'
			AND ISNULL(d.lgh_outstatus, 'XXX') <> 'CMP'
			AND stops.ord_hdrnumber <> 0;
	END;--IF UPDATE(lgh_outstatus)

	--PTS 73750   
	--added gi_string4 check here. If not also set to Y, this additional audit will not take place
	IF @lgh_tractor = 1
	BEGIN
		INSERT dbo.expedite_audit (
			ord_hdrnumber
			,updated_by
			,updated_dt
			,activity
			)
		SELECT stops.ord_hdrnumber
			,SUSER_NAME()
			,GETDATE()
			,'DB' + i.lgh_tractor
		FROM @inserted i
		INNER JOIN @deleted d ON i.lgh_number = d.lgh_number
		INNER JOIN dbo.stops ON i.stp_number_start = stops.stp_number
		WHERE COALESCE(i.lgh_tractor,'') <> 'UNKNOWN'
			AND COALESCE(i.lgh_tractor,'') <> d.lgh_tractor;

		INSERT dbo.expedite_audit (
			ord_hdrnumber
			,updated_by
			,updated_dt
			,activity
			)
		SELECT stops.ord_hdrnumber
			,SUSER_NAME()
			,GETDATE()
			,'UB' + d.lgh_tractor
		FROM @inserted i
		INNER JOIN @deleted d ON i.lgh_number = d.lgh_number
		INNER JOIN dbo.stops ON i.stp_number_start = stops.stp_number
		WHERE COALESCE(i.lgh_tractor,'') = 'UNKNOWN'
			AND COALESCE(d.lgh_tractor,'') <> 'UNKNOWN';
	END;--IF UPDATE(lgh_tractor)

	-- JET - 7/29/2009
	IF @lgh_booked_revtype1 = 1
	BEGIN
		INSERT dbo.expedite_audit (
			ord_hdrnumber
			,updated_by
			,updated_dt
			,activity
			,mov_number
			,lgh_number
			,join_to_table_name
			,key_value
			,update_note
			)
		SELECT ISNULL(i.ord_hdrnumber, 0)
			,SUSER_NAME()
			,GETDATE()
			,LEFT(@lgh_booked_revtype1_label + ' Changed', 20)
			,i.mov_number
			,i.lgh_number
			,'legheader'
			,i.lgh_number
			,@lgh_booked_revtype1_label + ':' + LTRIM(RTRIM(ISNULL(d.lgh_booked_revtype1, 'UNKNOWN'))) + ' -> ' + ISNULL(i.lgh_booked_revtype1, 'UNKNOWN')
		FROM @inserted i
		INNER JOIN @deleted d ON d.lgh_number = i.lgh_number
		WHERE ISNULL(d.lgh_booked_revtype1, 'UNKNOWN') <> ISNULL(i.lgh_booked_revtype1, 'UNKNOWN');

	END;--IF UPDATE(lgh_booked_revtype1)


  -- GKOPP PTS 66059
  IF @lgh_other_status1 = 1
  BEGIN
    INSERT dbo.expedite_audit (
      lgh_number
    , ord_hdrnumber
    , updated_by
    , updated_dt
    , activity
    , update_note)
    SELECT 
      i.lgh_number
    , i.ord_hdrnumber
    , SUSER_NAME()
    , GETDATE()
    , 'lgh_other_status1'
    , 'New Value: ' + ISNULL(i.lgh_other_status1, 'NULL') + ';Previous Value: ' + ISNULL(d.lgh_other_status1, 'NULL')
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number
    WHERE  
      COALESCE(i.lgh_other_status1,'NULL') <> COALESCE(d.lgh_other_status1 ,'NULL')
  END;--IF UPDATE(lgh_other_status1)

  IF @lgh_other_status2 = 1
  BEGIN
    INSERT dbo.expedite_audit (
      lgh_number
    , ord_hdrnumber
    , updated_by
    , updated_dt
    , activity
    , update_note)
    SELECT 
      i.lgh_number
    , i.ord_hdrnumber
    , SUSER_NAME()
    , GETDATE()
    , 'lgh_other_status2'
    , 'New Value: ' + ISNULL(i.lgh_other_status2, 'NULL') + ';Previous Value: ' + ISNULL(d.lgh_other_status2, 'NULL')
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number
    WHERE  
      COALESCE(i.lgh_other_status2,'NULL') <> COALESCE(d.lgh_other_status2 ,'NULL')
  END;--IF UPDATE(lgh_other_status2)

END;--IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'FingerprintAudit' AND LEFTgi_string1 = 'Y')
GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_FPrintTBranch_sp] TO [public]
GO
