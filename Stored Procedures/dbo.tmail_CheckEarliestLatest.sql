SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_CheckEarliestLatest] (@ord_hdrnumber int, @stp_number int, @DEFAULT_CMP_SLACK_TIME int)

AS
	-- @ord_hdrnumber parameter is ignored and is present only for backward compatibility.
SET NOCOUNT ON 

  DECLARE @ord_billto VARCHAR(25)-- PTS 61189 change cmp_id fields to 25 length
  DECLARE @companyToUse VARCHAR(25)-- PTS 61189 change cmp_id fields to 25 length
  DECLARE @stp_schdtearliest datetime, @stp_schdtlatest datetime, @cmp_slack_time int, @cmp_slacktime_late int
  DECLARE @GENESIS datetime, @APOCALYPSE datetime

  SELECT @GENESIS = CONVERT(datetime, '19500101'), @APOCALYPSE = CONVERT(datetime, '20491231')    
  SELECT @ord_hdrnumber = 0

  -- First get earliest and latest times and orderheadernumber from the stop.
  SELECT @stp_schdtearliest = ISNULL(stp_schdtearliest, @GENESIS), @stp_schdtlatest = ISNULL(stp_schdtlatest, @APOCALYPSE), @ord_hdrnumber = ISNULL(ord_hdrnumber, 0) 
  FROM stops (NOLOCK)
  WHERE stp_number = @stp_number

  IF @ord_hdrnumber = 0
    BEGIN
    SELECT @GENESIS AS stp_schdtearliest, @APOCALYPSE AS stp_schdtlatest, @DEFAULT_CMP_SLACK_TIME AS cmp_slack_time, @DEFAULT_CMP_SLACK_TIME AS cmp_slacktime_late
    RETURN
    END

  SELECT @ord_billto = ''
  SELECT @ord_billto = ord_billto FROM orderheader WHERE ord_hdrnumber = @ord_hdrnumber

  -- First check the parent of the bill-to.
  -- Then, check the bill-to
  -- Then, use the setting in TotalMail
  SELECT @CompanyToUse = CASE WHEN (cmp_parent = 'Y') THEN   
                           CASE WHEN (cmp_mastercompany IS NULL OR cmp_mastercompany = 'UNKNOWN') THEN 
                             cmp_id 
                           ELSE 
                             cmp_mastercompany  
                           END
                         ELSE 
                           cmp_id 
                         END
  FROM company (NOLOCK)
  WHERE cmp_id = @ord_billto

  -- Determine slack time.  
  --   cmp_slack_time will determine how early a stop can be.
  --   cmp_slacktime_late will determine how late a stop can be.
  --   if cmp_slacktime_late is NULL, then cmp_slacktime will also specify how late a stop can be.
  SELECT @cmp_slack_time = cmp_slack_time, @cmp_slacktime_late = ISNULL(cmp_slacktime_late, cmp_slack_time)  
  FROM company (NOLOCK)
  WHERE cmp_id = @CompanyToUse
  
  IF (@cmp_slack_time IS NULL)   -- Now use the bill-to since no values were found in parent of bill-to.
    SELECT @cmp_slack_time = ISNULL(cmp_slack_time, @DEFAULT_CMP_SLACK_TIME), 
           @cmp_slacktime_late = CASE WHEN @cmp_slacktime_late IS NULL THEN ISNULL(cmp_slacktime_late, ISNULL(cmp_slack_time, @DEFAULT_CMP_SLACK_TIME)) 
                                      ELSE @cmp_slacktime_late 
                                 END
    FROM company (NOLOCK)
    WHERE cmp_id = @ord_billto

  SELECT @stp_schdtearliest AS stp_schdtearliest, @stp_schdtlatest AS stp_schdtlatest, @cmp_slack_time AS cmp_slack_time, @cmp_slacktime_late AS cmp_slacktime_late
GO
GRANT EXECUTE ON  [dbo].[tmail_CheckEarliestLatest] TO [public]
GO
