CREATE TABLE [dbo].[log_driverlogs]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[log_date] [datetime] NOT NULL,
[total_miles] [smallint] NOT NULL,
[log] [char] (96) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[off_duty_hrs] [float] NOT NULL,
[sleeper_berth_hrs] [float] NOT NULL,
[driving_hrs] [float] NOT NULL,
[on_duty_hrs] [float] NOT NULL,
[processed_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rule_reset_indc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rule_reset_date] [datetime] NULL,
[rule_est_reset_date] [datetime] NULL,
[eleven_hr_rule] [float] NULL,
[fourteen_hr_rule] [float] NULL,
[sixty_seventy_hr_rule] [float] NULL,
[last_avail_hrs_recalc] [datetime] NULL,
[log_driverlog_ID] [int] NOT NULL IDENTITY(1, 1),
[skip_trigger] [bit] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__log_drive__INS_T__5B2E3B84] DEFAULT (getdate()),
[DW_TIMESTAMP] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iudt_log_driverlogs] ON [dbo].[log_driverlogs]
FOR INSERT , UPDATE , DELETE
AS
SET NOCOUNT ON; -- 06/25/2007 MDH PTS: 38085: Added 
/*
This proc checks to see if the most recent change to the table breaks
a 2 day or 3 day hours of service rule.  Consider an update of a row
from the 15th of the month. At risk are these 2/3 day periods:

14-15, 15-16
13-14-15, 14-15-16, or 15-16-17

Our calculation table will always look only back in time so we'll
be checking the 15th and 16th on the 2 day and the 15th, 16th, 
and 17th on the 3 day.

*/

DECLARE @log_nb TABLE (
  mpp_id          VARCHAR(8)
, log_date        DATETIME
, TodayHrs        FLOAT
, YesterdayHrs    FLOAT
, TwoDaysAgoHrs   FLOAT
, PriorHrs        FLOAT
, rule_reset_indc CHAR(1));

DECLARE 
  @mpp_id               VARCHAR(8) = ''
, @inserted_count       INT
, @deleted_count        INT
, @log_date             DATETIME
, @msg                  VARCHAR(400)
, @DriverLogHourRestart FLOAT;

--vmj1+	PTS 20995	1/12/2004	Apply "reasonability check" on the rule_reset_indc..
SELECT @inserted_count = COUNT(*) FROM inserted;
SELECT @deleted_count = COUNT(*) FROM deleted;


--The 34-hour reset checks will not be run if multiple rows have been updated by a single SQL statement.
IF @inserted_count + @deleted_count = 1
     OR--If this is an update, checks will not be run unless 1 of the 3 key columns has been updated.
   @inserted_count = 1 AND @deleted_count = 1 AND UPDATE(driving_hrs)
     OR
   @inserted_count = 1 AND @deleted_count = 1 AND UPDATE(on_duty_hrs)
     OR
   @inserted_count = 1 AND @deleted_count = 1 AND UPDATE(rule_reset_indc)
BEGIN
  --Select a "neighborhood" of driver logs around the updated row containing 2 days before
  --and after the log_date of the updated row..

  --PTS 50612 JJF 20101025
  SELECT 
    @DriverLogHourRestart = COALESCE(TRY_CONVERT(FLOAT, gi_integer1), 0)
  FROM 
    dbo.generalinfo
  WHERE
    gi_name = 'DriverLogHourRestart';
  --END PTS 50612 JJF 20101025


  SELECT 
    @mpp_id = COALESCE(i.mpp_id, d.mpp_id)
  , @log_date = DATEADD(dd, DATEDIFF(dd, 0, COALESCE(i.log_date, d.log_date)), 0)
  FROM 
    inserted i
      FULL OUTER JOIN
    deleted d ON i.mpp_id = d.mpp_id AND i.log_date = d.log_date;

  INSERT @log_nb(
    mpp_id
  , log_date
  , TodayHrs
  , YesterdayHrs
  , TwoDaysAgoHrs
  , rule_reset_indc)
  SELECT
    mpp_id
  , log_date
  , driving_hrs + on_duty_hrs TodayHrs
  , COALESCE(LAG(driving_hrs + on_duty_hrs, 1) OVER (ORDER BY log_date), 0) YesterdayHrs
  , COALESCE(LAG(driving_hrs + on_duty_hrs, 2) OVER (ORDER BY log_date), 0) TwoDaysAgoHrs
  , rule_reset_indc
  FROM
    dbo.log_driverlogs
  WHERE 
    mpp_id = @mpp_id
      AND
    log_date BETWEEN DATEADD(day, -2, @log_date) AND DATEADD(day, 2, @log_date);

  --Now check the whole neighborhood for any occurrences where rule_reset_indc = 'Y'..
  --See if the Reset is valid, based on the 2-day scenario..
  IF EXISTS (SELECT 
               1 
             FROM 
               @log_nb 
             WHERE 
               rule_reset_indc = 'Y' 
                 AND  --From the comments above, this is the 15th and 16th
               log_date BETWEEN @log_date AND DATEADD(day, 1, @log_date)
                 AND 
               TodayHrs + YesterdayHrs + @DriverLogHourRestart > 48
                 AND
               TwoDaysAgoHrs > 0)
  BEGIN
    --The prior day must have 0.00 hours for the 3-day scenario to be valid..
    SELECT
      @msg = 'Based on the hours entered '+CONVERT( VARCHAR(10) , log_date - 1 , 101)+' to '+CONVERT(VARCHAR(10) , log_date , 101)+', it is not possible for the driver to have taken '+CONVERT(VARCHAR(3) , @DriverLogHourRestart)+' consecutive hours of rest.  Changes made have been rolled back.'
    FROM 
      @log_nb 
    WHERE 
      rule_reset_indc = 'Y' 
        AND  --From the comments above, this is the 15th and 16th
      log_date BETWEEN @log_date AND DATEADD(day, 1, @log_date)
        AND 
      TodayHrs + YesterdayHrs + @DriverLogHourRestart > 48
        AND
      TwoDaysAgoHrs > 0;

    RAISERROR(@msg , 16 , 1);
    ROLLBACK TRANSACTION;
    RETURN;
  END;--2 day rule
  
  IF EXISTS (SELECT 
               1 
             FROM 
               @log_nb 
             WHERE 
               rule_reset_indc = 'Y' 
                 AND  --From the comments above, this will include the 15th, 16th, and 17th
               log_date >= @log_date 
                 AND 
               TodayHrs + YesterdayHrs + TwoDaysAgoHrs > 38)
  BEGIN
    SELECT 
      @msg = 'Based on the hours entered '+CONVERT( VARCHAR(10) , log_date - 2 , 101) +
             ' to ' + CONVERT(VARCHAR(10) , log_date , 101) + ', it is not possible for the driver to have taken ' + 
             CONVERT(VARCHAR(3) , @DriverLogHourRestart) + ' consecutive hours of rest.  Changes made have been rolled back.'
    FROM 
      @log_nb 
    WHERE 
      rule_reset_indc = 'Y' 
        AND  --From the comments above, this will include the 15th, 16th, and 17th
      log_date >= @log_date 
        AND 
      TodayHrs + YesterdayHrs + TwoDaysAgoHrs > 38;

    RAISERROR(@msg , 16 , 1);
    ROLLBACK TRANSACTION;
    RETURN;
  END;--3 day rule
END;




DECLARE MPPCURSOR CURSOR LOCAL FAST_FORWARD FOR
SELECT DISTINCT 
  mpp_id 
FROM  
  (SELECT 
    mpp_id
  FROM 
    INSERTED
  UNION ALL
  SELECT 
    mpp_id
  FROM 
    DELETED) x

OPEN MPPCURSOR
FETCH NEXT FROM MPPCURSOR INTO @mpp_id

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC update_loghours @mpp_id;
  FETCH NEXT FROM MPPCURSOR INTO @mpp_id
END;

CLOSE MPPCURSOR
DEALLOCATE MPPCURSOR


GO
CREATE NONCLUSTERED INDEX [log_driverlogs_INS_TIMESTAMP] ON [dbo].[log_driverlogs] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [driver_logs_ix] ON [dbo].[log_driverlogs] ([mpp_id], [log_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [log_drvlog_flagempid] ON [dbo].[log_driverlogs] ([processed_flag], [mpp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[log_driverlogs] TO [public]
GO
GRANT INSERT ON  [dbo].[log_driverlogs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[log_driverlogs] TO [public]
GO
GRANT SELECT ON  [dbo].[log_driverlogs] TO [public]
GO
GRANT UPDATE ON  [dbo].[log_driverlogs] TO [public]
GO
