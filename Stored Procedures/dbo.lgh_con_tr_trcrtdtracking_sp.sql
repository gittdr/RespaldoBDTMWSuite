SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[lgh_con_tr_trcrtdtracking_sp](
@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
)
AS

BEGIN
DECLARE @updated INT = 0
	,@trcchanged CHAR = 'N'
	,@typevalue VARCHAR(12)
	,@rtdid INT
	,@trcid VARCHAR(13)
	,@oo_trc VARCHAR(10)
	,@deltrc VARCHAR(8)
	,@insertrc VARCHAR(8)
	,@istartdate DATETIME
	,@PriorLghDate DATETIME
	,@RTD_lghtype VARCHAR(10)
	,@RTD_value VARCHAR(12)
	,@RTD_ignore VARCHAR(12)
	,@RTD_startdate DATETIME


SELECT @RTD_lghtype = gi_string1
	,@RTD_value = gi_string2
	,@RTD_ignore = gi_string3
	,@RTD_startdate = ISNULL(gi_date1, '1950-01-01')
FROM dbo.generalinfo
WHERE gi_name = 'TRCRTDTracking'

  /*
  *  PTS 43872 - Get the GI settings for the RTD Functionality.
  *    gi_String1 = value will indicate which lgh_type field to use (1-4)
  *    gi_string2 = the abbr code from the Labelfile that indicates a trip ENDS a RTD.
  *    gi_string3 = the abbr code from the Labelfile that indicates that Leg should be EXCLUDED from ALL RTDs.
  *    gi_date1 = The lgh_startdate to start using the RTD logic.  Legheaders with an lgh_startdate prior to this date will not be included.
  */

  SELECT @insertrc = lgh_tractor FROM @inserted;
  SELECT @deltrc = lgh_tractor FROM @deleted;
																						
  IF @deltrc <> @insertrc AND (SELECT COALESCE(legheader.lgh_rtd_id,0) FROM dbo.legheader JOIN @deleted d ON legheader.lgh_number = d.lgh_number) > 0
  BEGIN

    UPDATE 
      dbo.legheader 
    SET 
      lgh_rtd_id = 0
    FROM 
      @deleted d
    WHERE 
      legheader.lgh_number = d.lgh_number;
          
  END;

  -- Check to verify that the required field was updated, the required value was entered, and that the value actually changed.
  IF @RTD_lghtype = 'lgh_type1' AND EXISTS (SELECT 1 FROM @inserted i JOIN @deleted d ON i.lgh_number = d.lgh_number AND COALESCE(d.lgh_type1,'ZZZ') <> COALESCE(i.lgh_type1,'ZZZ'))
  BEGIN
    SET @updated = 1;
    SELECT @typevalue = lgh_type1 FROM @inserted;
  END;
  IF @RTD_lghtype = 'lgh_type2' AND EXISTS (SELECT 1 FROM @inserted i JOIN @deleted d ON i.lgh_number = d.lgh_number AND COALESCE(d.lgh_type2,'ZZZ') <> COALESCE(i.lgh_type2,'ZZZ'))
  BEGIN
    SET @updated = 1;
    SELECT @typevalue = lgh_type2 FROM @inserted;
  END;
  IF @RTD_lghtype = 'lgh_type3' AND EXISTS (SELECT 1 FROM @inserted i JOIN @deleted d ON i.lgh_number = d.lgh_number AND COALESCE(d.lgh_type3,'ZZZ') <> COALESCE(i.lgh_type3,'ZZZ'))
  BEGIN
    SET @updated = 1;
    SELECT @typevalue = lgh_type3 FROM @inserted;
  END;
  IF @RTD_lghtype = 'lgh_type4' AND EXISTS (SELECT 1 FROM @inserted i JOIN @deleted d ON i.lgh_number = d.lgh_number AND COALESCE(d.lgh_type4,'ZZZ') <> COALESCE(i.lgh_type4,'ZZZ'))
  BEGIN
    SET @updated = 1;
    SELECT @typevalue = lgh_type4 FROM @inserted;
  END;

  IF EXISTS (SELECT 1 FROM @inserted i JOIN @deleted d ON i.lgh_number = d.lgh_number WHERE d.lgh_outstatus = 'CMP' and COALESCE(d.lgh_outstatus,'') <> COALESCE(i.lgh_outstatus,'') )
  BEGIN
    SET @updated = 1;
    SELECT @typevalue = MAX(i.lgh_type4) FROM @inserted i JOIN @deleted d ON i.lgh_number = d.lgh_number WHERE d.lgh_outstatus = 'CMP';
  END;
    
  -- Look for a modified tractor on the Legheader record.
  IF EXISTS (SELECT 1 FROM @inserted i JOIN @deleted d ON i.lgh_number = d.lgh_number AND d.lgh_tractor <> i.lgh_tractor AND i.lgh_tractor <> 'UNKNOWN')
  BEGIN
    SET @updated = 1;
    SELECT @typevalue = lgh_type4 FROM @inserted;
  END;
																								
  -- Get the Tractor Id and accounting type for the Tractor to verify that it's an Owner/Operator.
  SELECT @trcid = lgh_tractor FROM @inserted;
  SELECT @oo_trc = COALESCE((SELECT trc_actg_type FROM dbo.tractorprofile trc WHERE trc.trc_number = @trcid AND trc_actg_type = 'A'),'N');

  -- Verify that the Tractor for the trip was an Owner Operator and that lgh_type value indicates a new RTD is starting
  IF (@updated = 1) AND (@oo_trc = 'A') AND (@typevalue = @RTD_value) AND (@trcid IS NOT NULL )
  BEGIN   

    SELECT @istartdate = lgh_startdate FROM @inserted;

    -- Find the last leg prior to the current 'Begin' leg that does NOT 
    --  have an RTD AND has the 'Begin' lgh_type value set.
    SELECT 
      @PriorLghDate = MAX(COALESCE(legheader.lgh_startdate, @RTD_startdate))
    FROM 
      dbo.legheader  
    WHERE 
      legheader.lgh_tractor = @trcid
        AND 
      legheader.lgh_startdate < @istartdate
        AND 
      legheader.lgh_outstatus = 'CMP'
        AND 
      CASE @RTD_lghtype
        WHEN 'lgh_type1' THEN legheader.lgh_type1 
        WHEN 'lgh_type2' THEN legheader.lgh_type2 
        WHEN 'lgh_type3' THEN legheader.lgh_type3
        WHEN 'lgh_type4' THEN legheader.lgh_type4
      END = @RTD_value
        AND 
      COALESCE(legheader.lgh_rtd_id,0) = 0
        AND 
      legheader.lgh_startdate > @RTD_startdate;
                    
    IF NOT EXISTS (SELECT 
                     1 
                   FROM 
                     dbo.legheader
                   WHERE 
                     legheader.lgh_tractor = @trcid
                       AND 
                     legheader.lgh_startdate < @istartdate
                       AND 
                     legheader.lgh_outstatus <> 'CMP'
                       AND 
                     CASE @RTD_lghtype
                       WHEN 'lgh_type1' THEN legheader.lgh_type1 
                       WHEN 'lgh_type2' THEN legheader.lgh_type2 
                       WHEN 'lgh_type3' THEN legheader.lgh_type3
                       WHEN 'lgh_type4' THEN legheader.lgh_type4
                     END <> @RTD_ignore
                       AND 
                     COALESCE(legheader.lgh_rtd_id,0) = 0
                       AND 
                     legheader.lgh_startdate >= @PriorLghDate)
          
    BEGIN

      -- Create the RTD Record
      INSERT dbo.tractor_rtd (
        rtd_trcid) 
      VALUES (
        @trcid);
            
      -- Get the Identity key for the new tractor_rtd record
      SET @rtdid = SCOPE_IDENTITY();

      IF @@error = 0 
      BEGIN

        -- Update any prior trips that should belong to this RTD.
        UPDATE 
          dbo.legheader
        SET 
          lgh_rtd_id = @rtdid
        FROM 
          @inserted i
        WHERE 
          legheader.lgh_tractor = @trcid
            AND 
          legheader.lgh_startdate < @istartdate
            AND 
          legheader.lgh_outstatus = 'CMP'
            AND 
          COALESCE(legheader.lgh_rtd_id,0) = 0
            AND 
          legheader.lgh_startdate > @RTD_startdate
            AND
          legheader.lgh_startdate >= COALESCE(@PriorLghDate,'1950-01-01')
            AND 
          CASE @RTD_lghtype
            WHEN 'lgh_type1' THEN legheader.lgh_type1 
            WHEN 'lgh_type2' THEN legheader.lgh_type2 
            WHEN 'lgh_type3' THEN legheader.lgh_type3
            WHEN 'lgh_type4' THEN legheader.lgh_type4
          END <> @RTD_ignore;
                
        IF @@error <> 0 
        BEGIN
        --------------------------------------potential mendoza line--------------------------------------
          RAISERROR ('Error setting RTD ID: %i on Legheader(s) record for Tractor: %s', 16, 1, @rtdid, @trcid);
          --RETURN;
        END;
      END;
      ELSE
      BEGIN
      --------------------------------------potential mendoza line--------------------------------------
        RAISERROR ('Error inserting new RTD record for Tractor: %s', 16, 1, @trcid);
        --RETURN;
      END;
    END;
  END;
END;
-- End 43872

GO
GRANT EXECUTE ON  [dbo].[lgh_con_tr_trcrtdtracking_sp] TO [public]
GO
