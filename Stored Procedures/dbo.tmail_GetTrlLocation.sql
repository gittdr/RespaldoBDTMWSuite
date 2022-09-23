SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[tmail_GetTrlLocation] (@TrlToFind varchar(13), @ExcludeLgh int, @BeforeDate datetime)

AS

SET NOCOUNT ON 

DECLARE @LGH int, @Seq int, @Stp_ArrivalDate DATETIME 

SELECT @LGH = ISNULL(MAX(ISNULL(lgh_number, -1)), -1)
     FROM assetassignment (NOLOCK)
     WHERE assetassignment.asgn_type = 'TRL'
         AND assetassignment.asgn_id = @TrlToFind
         AND assetassignment.asgn_status IN ('CMP', 'STD')
         AND assetassignment.lgh_number <>  @ExcludeLgh
         AND assetassignment.asgn_date = (SELECT MAX(asgn_date)
                     FROM assetassignment
                     WHERE assetassignment.asgn_type = 'TRL'
                         AND assetassignment.asgn_id = @TrlToFind
                         AND assetassignment.asgn_status IN ('CMP','STD')
                         AND assetassignment.lgh_number <>  @ExcludeLgh
                         AND assetassignment.asgn_date <= @BeforeDate)

SELECT @Seq = ISNULL(MAX(ISNULL(s.stp_mfh_sequence, -1)), -1)
	FROM stops s (NOLOCK), event (NOLOCK)
	WHERE s.lgh_number =  @LGH
	AND 
		((event.evt_trailer1 = @TrlToFind 
			OR event.evt_trailer2 = @TrlToFind)
		AND s.stp_status = 'DNE'
		and s.stp_number = event.stp_number)

IF EXISTS (SELECT * 
			FROM stops (NOLOCK) 
			WHERE lgh_number = @LGH and stp_mfh_sequence = @Seq+1 and stp_event = 'CTR')
	SELECT @Seq = @Seq + 1

SET @Stp_ArrivalDate = (SELECT Stp_ArrivalDate FROM dbo.stops WHERE lgh_number =  @LGH AND stp_mfh_sequence = @Seq)  
  
IF EXISTS (SELECT TOP 1 MAX(exp_expirationdate) AS max_exp_expirationdate, exp_idtype, exp_id, exp_code, exp_completed  
 FROM dbo.expiration   
 WHERE exp_idtype = 'TRL' AND exp_id =@TrlToFind  
  AND exp_code = 'INS' AND exp_completed = 'Y'   
  AND exp_expirationdate between @Stp_ArrivalDate AND @BeforeDate  
 GROUP BY exp_idtype, exp_id, exp_code, exp_completed)  
BEGIN  
  
 SELECT e1.exp_routeto, e1.exp_city  
 FROM dbo.expiration e1  
 INNER JOIN  
 (  
  SELECT TOP 1 MAX(exp_expirationdate) AS max_exp_expirationdate, exp_idtype, exp_id, exp_code, exp_completed  
  FROM dbo.expiration   
  WHERE exp_idtype = 'TRL' AND exp_id = @TrlToFind  
   AND exp_code = 'INS' AND exp_completed = 'Y'   
   AND exp_expirationdate between @Stp_ArrivalDate AND @BeforeDate  
  GROUP BY exp_idtype, exp_id, exp_code, exp_completed   
 ) e2 ON e1.exp_expirationdate = e2.max_exp_expirationdate AND e1.exp_idtype = e2.exp_idtype  
  AND e1.exp_id = e2.exp_id AND e1.exp_code = e2.exp_code  
  AND e1.exp_completed = e2.exp_completed  
END  
  
ELSE  
BEGIN  
 SELECT cmp_id,stp_city  
 FROM stops  
 WHERE lgh_number =  @LGH  
  AND stp_mfh_sequence = @Seq  
END   

GO
GRANT EXECUTE ON  [dbo].[tmail_GetTrlLocation] TO [public]
GO
