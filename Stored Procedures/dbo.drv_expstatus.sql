SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************************************************
 ** NAME: drv_expstatus
 **
 ** Parameters: 
 **    @drvid VARCHAR(8) - Driver ID for which status should be set.
 **    @debug INTEGER    - Optional defaults to 0, when zero updates are performed, when anything else select statement with changes instead of update.
 **
 ** General Info Settings
 **    ExpTimeBuffer 
 **        Number of minutes (+ or -) that are added to the current time when looking for active expirations
 **    DRVExpLogic
 **        When Set to Y completed expirations must have a location to be used for available cmp_id and available city
 **        When set to N completed expirations can have no location and will set available cmp_id and avalable city to UNKOWN
 **          
 **    DrvTrcProt
 **       When set to BOTH or DRV
 **         - will not write to the mpp_tractor field
 **       When set to anything else
 **         - will write the tractor from current assignment to mpp_tractor field
 **
 ** Revisions History:
 **   INT-106018 - RJE 03/31/2017 - Rewrote procedure for performance
 **
 *******************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[drv_expstatus]
(
  @drvid  VARCHAR(8),
  @debug  INTEGER = 0
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @ExpTimeBuffer        INTEGER,
        @v_newDRVLogic        CHAR(1),
        @DrvTrcProt           VARCHAR(10),
        @comparedate          DATETIME,
        @lgh                  INTEGER,
        @avlstat              VARCHAR(6),
        @avlcmp               VARCHAR(8),
        @avlcity              INTEGER,
        @avldate              DATETIME,
        @drvtrc               VARCHAR(8),
        @expcode              INTEGER,
        @expavldate           DATETIME,
        @expdate              DATETIME,
        @expavlcmp            VARCHAR(8),
        @expavlcity           INTEGER,
        @expstat              VARCHAR(6),
        @prior_event          VARCHAR(6), 
        @prior_cmp_id         VARCHAR(8),
	      @prior_city           INTEGER,
	      @prior_state          VARCHAR(6),
	      @prior_region1        VARCHAR(6),
	      @prior_region2        VARCHAR(6),
	      @prior_region3        VARCHAR(6),
	      @prior_region4        VARCHAR(6),
	      @prior_cmp_othertype1 VARCHAR(6),
        @next_event           VARCHAR(6), 
        @next_cmp_id          VARCHAR(8),
	      @next_city            INTEGER,
	      @next_state           VARCHAR(6),
	      @next_region1         VARCHAR(6),
	      @next_region2         VARCHAR(6),
	      @next_region3         VARCHAR(6),
	      @next_region4         VARCHAR(6),
	      @next_cmp_othertype1  VARCHAR(6),
        @plnlgh               INTEGER,
        @plndate              DATETIME, 
        @plncmp               VARCHAR(8),
        @plncity              INTEGER,
        @StdCmpCodes          TMWTable_char6,
        @PlnDspCodes          TMWTable_char6

IF COALESCE(@drvid, 'UNKNOWN') = 'UNKNOWN' RETURN

SELECT  @ExpTimeBuffer = CASE WHEN gi_name = 'ExpTimeBuffer' THEN COALESCE(gi_integer1, 0) ELSE @ExpTimeBuffer END,
        @v_newDRVLogic = CASE WHEN gi_name = 'DRVExpLogic' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @v_newDRVLogic END,
        @DrvTrcProt = CASE WHEN gi_name = 'DrvTrcProt' THEN COALESCE(gi_string1, 'NONE') ELSE @DrvTrcProt END
  FROM  generalinfo
 WHERE  gi_name IN ('ExpTimeBuffer', 'DRVExpLogic', 'DrvTrcProt')

SELECT  @comparedate = DATEADD(MINUTE, COALESCE(@ExpTimeBuffer, 0), GETDATE()),
        @v_newDRVLogic = COALESCE(@v_newDRVLogic, 'N'),
        @DrvTrcProt = COALESCE(@DrvTrcProt, 'NONE')

-- Find latest active expiration with priority given to expiration with code = 900 (Termination)
SELECT  @expcode = Active.ExpirationCode,
        @expavldate = Active.ExpirationEndDate,
        @expdate = Active.ExpirationStartDate,
        @expavlcmp = Active.ExpirationCompany,
        @expavlcity = Active.ExpirationCity,
        @expstat = Active.ExpirationStatus
  FROM  dbo.Expstatus_GetActiveExpiration_fn('DRV', @drvid, @comparedate, 200, 'DrvExp', 'DrvStatus') Active
	
SELECT @expcode = COALESCE(@expcode, 0)

-- Termination (code = 900) takes precedence over everything else
IF @expcode = 900
BEGIN
  IF @debug = 0
    UPDATE  manpowerprofile
       SET  mpp_avl_status = @expstat,
            mpp_status = @expstat,
            mpp_avl_date = @expavldate,
            mpp_terminationdt = @expdate
     WHERE  mpp_id = @drvid
       AND  (COALESCE(mpp_avl_status, '-98765') <> COALESCE(@expstat, '-98765')
        OR   COALESCE(mpp_status, '-98765') <> COALESCE(@expstat, '-98765')
        OR   COALESCE(mpp_avl_date, CONVERT(DATETIME, 0)) <> COALESCE(@expavldate, CONVERT(DATETIME, 0))
        OR   COALESCE(mpp_terminationdt, CONVERT(DATETIME, 0)) <> COALESCE(@expdate, CONVERT(DATETIME, 0)))
  ELSE
  SELECT  mpp_id,
          mpp_tractornumber,
          @expstat mpp_avl_status,
			    @expstat mpp_status,
			    @expavldate mpp_avl_date,
			    mpp_avl_cmp_id,
			    mpp_avl_city,
			    @expavldate mpp_terminationdt,
			    mpp_pln_date,	
			    mpp_pln_cmp_id,
			    mpp_pln_city,
			    mpp_pln_lgh,   
			    mpp_avl_lgh,
			    mpp_next_event,
			    mpp_next_cmp_id,
			    mpp_next_city,
			    mpp_next_state,
			    mpp_next_region1,
			    mpp_next_region2,
			    mpp_next_region3,
			    mpp_next_region4,
			    mpp_next_cmp_othertype1,	
			    mpp_prior_event,
			    mpp_prior_cmp_id,
			    mpp_prior_city,
			    mpp_prior_state,
			    mpp_prior_region1,
			    mpp_prior_region2,
			    mpp_prior_region3,
			    mpp_prior_region4,
			    mpp_prior_cmp_othertype1
    FROM  manpowerprofile
   WHERE  mpp_id = @drvid

  RETURN
END

-- Find current activity (latest started or completed leg)
INSERT  @StdCmpCodes
  SELECT  LEFT(value, 6) FROM dbo.CSVStringsToTable_fn('CMP,STD')

SELECT  @lgh = Activity.lgh_number,
        @avlstat = CASE WHEN Activity.Status = 'STD' THEN 'USE' ELSE 'AVL' END,
        @avlcmp = Activity.AvailableCompany,
        @avlcity = Activity.AvailableCity,
        @avldate = Activity.AvailableDate,
        @drvtrc = Activity.Tractor,
        @prior_event = Activity.PriorEvent,
        @prior_cmp_id = Activity.PriorCompany,
        @prior_city = Activity.PriorCity,
        @prior_state = Activity.PriorState,
        @prior_region1 = Activity.PriorRegion1,
        @prior_region2 = Activity.PriorRegion2,
        @prior_region3 = Activity.PriorRegion3,
        @prior_region4 = Activity.PriorRegion4,
        @prior_cmp_othertype1 = Activity.PriorCompanyOthertype1,
        @next_event = Activity.NextEvent,
        @next_cmp_id = Activity.NextCompany,
        @next_city = Activity.NextCity,
        @next_state = Activity.NextState,
        @next_region1 = Activity.NextRegion1,
        @next_region2 = Activity.NextRegion2,
        @next_region3 = Activity.NextRegion3,
        @next_region4 = Activity.NextRegion4,
        @next_cmp_othertype1 = Activity.NextCompanyOthertype1
  FROM  dbo.DrvExpStatus_GetActivity_fn(@drvid, @StdCmpCodes) AS Activity
  
-- Find latest planned leg
INSERT  @PlnDspCodes
  SELECT  LEFT(value, 6) FROM dbo.CSVStringsToTable_fn('PLN,DSP')

SELECT  @plnlgh = Planned.lgh_number, 
        @plndate = Planned.AvailableDate,
        @plncmp = Planned.AvailableCompany,
        @plncity = Planned.AvailableCity
  FROM  dbo.DrvExpStatus_GetActivity_fn(@drvid, @PlnDspCodes) Planned

-- No active expiration, get last completed expiration
IF @expcode = 0
  IF @v_newDRVLogic = 'Y'
    SELECT TOP 1
            @expcode = Completed.ExpirationCode,
            @expavldate = Completed.ExpirationEndDate,
            @expdate = Completed.ExpirationStartDate,
            @expavlcmp = Completed.ExpirationCompany,
            @expavlcity = Completed.ExpirationCity,
            @expstat = Completed.ExpirationStatus
      FROM  Expstatus_GetCompletedExpirationNew_fn('DRV', @drvid, @comparedate, 200, 'DrvExp') Completed 
  ELSE
    SELECT TOP 1
            @expcode = Completed.ExpirationCode,
            @expavldate = Completed.ExpirationEndDate,
            @expdate = Completed.ExpirationStartDate,
            @expavlcmp = Completed.ExpirationCompany,
            @expavlcity = Completed.ExpirationCity,
            @expstat = Completed.ExpirationStatus
      FROM  Expstatus_GetCompletedExpiration_fn('DRV', @drvid, @comparedate, 200, 'DrvExp') Completed 

SELECT  @lgh = COALESCE(@lgh, 0), 
        @expcode = COALESCE(@expcode, 0)

IF @lgh > 0 AND @expcode > 0 -- have trip and expiration
BEGIN
  IF @avlstat <> 'USE' AND (@expavldate >= @avldate OR @expstat <> 'AVL') -- no started trip and expiration occurred after last trip
  BEGIN
    SELECT  @avlstat = @expstat,
			      @avldate = @expavldate,
			      @avlcmp = @expavlcmp,
			      @avlcity = @expavlcity
  END
END
ELSE IF @expcode > 0 -- have expiration only 
	SELECT  @avlstat = @expstat,
		      @avldate = @expavldate,
		      @avlcmp = @expavlcmp,
		      @avlcity = @expavlcity
ELSE IF @expcode = 0 AND @lgh = 0 -- have neither a trip or expiration
  SELECT  @avlstat = 'AVL',
		      @avldate = '19500101',
		      @avlcmp = 'UNKNOWN',
		      @avlcity = 0

IF @avlstat = 'AVL' AND @plnlgh > 0
BEGIN
  SELECT  @avlstat = 'PLN'
END

IF @debug = 0
  UPDATE  manpowerprofile
     SET  mpp_tractornumber = CASE WHEN @DrvTrcProt IN ('NONE', 'TRC') THEN 
                                     CASE
                                       WHEN COALESCE(@drvtrc, 'UNKNOWN') = 'UNKNOWN' THEN mpp_tractornumber
                                       ELSE @drvtrc
                                     END
                                   ELSE mpp_tractornumber 
                              END,
          mpp_avl_status= @avlstat,
			    mpp_status = @avlstat,
			    mpp_avl_date = @avldate,
			    mpp_avl_cmp_id = @avlcmp,
			    mpp_avl_city = @avlcity,
			    mpp_terminationdt = CONVERT(DATETIME, '20491231 23:59'),
			    mpp_pln_date = @plndate,	
			    mpp_pln_cmp_id = @plncmp,
			    mpp_pln_city = @plncity,
			    mpp_pln_lgh = @lgh,   
			    mpp_avl_lgh = @plnlgh,
			    mpp_next_event = COALESCE(@next_event,'UNK'),
			    mpp_next_cmp_id = COALESCE(@next_cmp_id,'UNKNOWN'),
			    mpp_next_city = COALESCE(@next_city,0),
			    mpp_next_state = COALESCE(@next_state,'XX'),
			    mpp_next_region1 = COALESCE(@next_region1,'UNK'),
			    mpp_next_region2 = COALESCE(@next_region2,'UNK'),
			    mpp_next_region3 = COALESCE(@next_region3,'UNK'),
			    mpp_next_region4 = COALESCE(@next_region4,'UNK'),
			    mpp_next_cmp_othertype1 = COALESCE (@next_cmp_othertype1, 'UNK'),	
			    mpp_prior_event = COALESCE(@prior_event,'UNK'),
			    mpp_prior_cmp_id = COALESCE(@prior_cmp_id,'UNKNOWN'),
			    mpp_prior_city = COALESCE(@prior_city,0),
			    mpp_prior_state = COALESCE(@prior_state,'XX'),
			    mpp_prior_region1 = COALESCE(@prior_region1,'UNK'),
			    mpp_prior_region2 = COALESCE(@prior_region2,'UNK'),
			    mpp_prior_region3 = COALESCE(@prior_region3,'UNK'),
			    mpp_prior_region4 = COALESCE(@prior_region4,'UNK'),
			    mpp_prior_cmp_othertype1 = COALESCE (@prior_cmp_othertype1, 'UNK')
   WHERE  mpp_id = @drvid
     AND  ((COALESCE(mpp_tractornumber, '-9876543') <> COALESCE(CASE WHEN @DrvTrcProt IN ('NONE', 'TRC') THEN 
                                                                  CASE
                                                                    WHEN COALESCE(@drvtrc, 'UNKNOWN') = 'UNKNOWN' THEN mpp_tractornumber
                                                                    ELSE @drvtrc
                                                                  END
                                                                ELSE mpp_tractornumber 
                                                           END, '-9876543')
      OR   COALESCE(mpp_avl_status, '-98765') <> COALESCE(@avlstat, '-98765')
      OR   COALESCE(mpp_status, '-98765') <> COALESCE(@avlstat, '-98765'))
			OR	 COALESCE(mpp_avl_date, CONVERT(DATETIME, 0))	<> COALESCE(@avldate, CONVERT(DATETIME, 0))
			OR	 COALESCE(mpp_avl_cmp_id, '-98765') <> COALESCE(@avlcmp, '-98765')
			OR	 COALESCE(mpp_avl_city, -987654) <> COALESCE(@avlcity, -987654)
			OR	 COALESCE(mpp_terminationdt, CONVERT(DATETIME, 0)) <> CONVERT(DATETIME, '20491231 23:59')
			OR	 COALESCE(mpp_pln_date, CONVERT(DATETIME, 0)) <> COALESCE(@plndate, CONVERT(DATETIME, 0))
			OR	 COALESCE(mpp_pln_cmp_id,	'-98765') <> COALESCE(@plncmp, '-98765')
			OR	 COALESCE(mpp_pln_city, -987654) <> COALESCE(@plncity,	-987654)
			OR	 COALESCE(mpp_pln_lgh, 		-987654) <> COALESCE(@lgh,	-987654)
			OR	 COALESCE(mpp_avl_lgh, 		-987654) <> COALESCE(@plnlgh,	-987654)
 			OR	 COALESCE(mpp_next_event, 	'-98765') <> COALESCE(@next_event, 'UNK')
 			OR	 COALESCE(mpp_next_cmp_id, 	'-98765') <> COALESCE(@next_cmp_id,	'UNKNOWN')
			OR	 COALESCE(mpp_next_city, 		-987654) 	<> COALESCE(@next_city,	0)
			OR	 COALESCE(mpp_next_state, 	'-98765') <> COALESCE(@next_state, 'XX')
			OR	 COALESCE(mpp_next_region1, 	'-98765') <> COALESCE(@next_region1, 'UNK')
			OR	 COALESCE(mpp_next_region2, 	'-98765') <> COALESCE(@next_region2, 'UNK')
			OR	 COALESCE(mpp_next_region3, 	'-98765') <> COALESCE(@next_region3, 'UNK')
			OR	 COALESCE(mpp_next_region4, 	'-98765') <> COALESCE(@next_region4, 'UNK')
			OR	 COALESCE(mpp_next_cmp_othertype1, '-98765') <> COALESCE(@next_cmp_othertype1, 'UNK')
			OR	 COALESCE(mpp_prior_event,  	'-98765') <> COALESCE(@prior_event,	'UNK')
			OR	 COALESCE(mpp_prior_cmp_id, 	'-98765') <> COALESCE(@prior_cmp_id, 'UNKNOWN')
			OR	 COALESCE(mpp_prior_city,   	-987654) 	<> COALESCE(@prior_city, 0)
			OR	 COALESCE(mpp_prior_state,  	'-98765') <> COALESCE(@prior_state,	'XX')
			OR	 COALESCE(mpp_prior_region1, 	'-98765') <> COALESCE(@prior_region1,	'UNK')
			OR	 COALESCE(mpp_prior_region2, 	'-98765') <> COALESCE(@prior_region2,	'UNK')
			OR	 COALESCE(mpp_prior_region3, 	'-98765') <> COALESCE(@prior_region3,	'UNK')
			OR	 COALESCE(mpp_prior_region4, 	'-98765') <> COALESCE(@prior_region4,	'UNK')
			OR	 COALESCE(mpp_prior_cmp_othertype1, '-98765') <> COALESCE(@prior_cmp_othertype1,'UNK'))

ELSE
  SELECT  mpp_id,
          CASE WHEN @DrvTrcProt IN ('NONE', 'TRC') THEN 
                  CASE
                    WHEN COALESCE(@drvtrc, 'UNKNOWN') = 'UNKNOWN' THEN mpp_tractornumber
                    ELSE @drvtrc
                  END
                ELSE mpp_tractornumber 
          END mpp_tractornumber,
          @avlstat mpp_avl_status,
			    @avlstat mpp_status,
			    @avldate mpp_avl_date,
			    @avlcmp mpp_avl_cmp_id,
			    @avlcity mpp_avl_city,
			    '20491231 23:59' mpp_terminationdt,
			    @plndate mpp_pln_date,	
			    @plncmp mpp_pln_cmp_id,
			    @plncity mpp_pln_city,
			    @lgh mpp_pln_lgh,   
			    @plnlgh mpp_avl_lgh,
			    COALESCE(@next_event,'UNK') mpp_next_event,
			    COALESCE(@next_cmp_id,'UNKNOWN') mpp_next_cmp_id,
			    COALESCE(@next_city,0) mpp_next_city,
			    COALESCE(@next_state,'XX') mpp_next_state,
			    COALESCE(@next_region1,'UNK') mpp_next_region1,
			    COALESCE(@next_region2,'UNK') mpp_next_region2,
			    COALESCE(@next_region3,'UNK') mpp_next_region3,
			    COALESCE(@next_region4,'UNK') mpp_next_region4,
			    COALESCE (@next_cmp_othertype1, 'UNK') mpp_next_cmp_othertype1,	
			    COALESCE(@prior_event,'UNK') mpp_prior_event,
			    COALESCE(@prior_cmp_id,'UNKNOWN') mpp_prior_cmp_id,
			    COALESCE(@prior_city,0) mpp_prior_city,
			    COALESCE(@prior_state,'XX') mpp_prior_state,
			    COALESCE(@prior_region1,'UNK') mpp_prior_region1,
			    COALESCE(@prior_region2,'UNK') mpp_prior_region2,
			    COALESCE(@prior_region3,'UNK') mpp_prior_region3,
			    COALESCE(@prior_region4,'UNK') mpp_prior_region4,
			    COALESCE (@prior_cmp_othertype1, 'UNK') mpp_prior_cmp_othertype1
    FROM  manpowerprofile
   WHERE  mpp_id = @drvid
GO
GRANT EXECUTE ON  [dbo].[drv_expstatus] TO [public]
GO
