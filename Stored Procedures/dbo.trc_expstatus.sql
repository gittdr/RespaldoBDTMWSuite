SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



/*******************************************************************************************************************************************************
 ** NAME: drv_expstatus DEBUG
 **AUTOR: EMILIO OLVERA
 **VERSION 2.5
 **FECHA 9 AGOSTO 2019
 ** DESCRIPCION: SP que debugea el sp trc_expstatus en orden de entender los cambios de status por expiraciones y/o estado de ordenes asingadas.

 **Sentencia de prueba:

 exec trc_expstatus '1538',1
 
 *******************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[trc_expstatus] 
(
  @trcid  VARCHAR(8),
  @debug  INTEGER = 0
)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @ExpTimeBuffer              INTEGER,
        @EDOWU                      VARCHAR(254),
        @EDOWU_condition_met        CHAR(1),
        @TrcProfileUpdateNonDispExp CHAR(1),
        @TrpUpdTrcHub               CHAR(1),
        @NewTrcExpLogic             CHAR(1),
        @ChkCllGPSUpd               CHAR(1),
        @DrvTrcProt                 VARCHAR(6),
        @comparedate                DATETIME,
        @expcode                    INTEGER,
        @expavldate                 DATETIME,
        @expdate                    DATETIME,
        @expavlcmp                  VARCHAR(8),
        @expavlcity                 INTEGER,
        @expstat                    VARCHAR(6),
        @expabbr                    VARCHAR(6),
        @lgh                        INTEGER,
        @avlstat                    VARCHAR(6),
        @avldate                    DATETIME,
        @avlcmp                     VARCHAR(8),
        @avlcity                    INTEGER,
        @driver1                    VARCHAR(8),
        @driver2                    VARCHAR(8),
        @trailer1                   VARCHAR(13),
        @trailer2                   VARCHAR(13),
        @currenthubreading          INTEGER,
        @prior_event                VARCHAR(6), 
        @prior_cmp_id               VARCHAR(8),
	      @prior_city                 INTEGER,
	      @prior_state                VARCHAR(6),
	      @prior_region1              VARCHAR(6),
	      @prior_region2              VARCHAR(6),
	      @prior_region3              VARCHAR(6),
	      @prior_region4              VARCHAR(6),
	      @prior_cmp_othertype1       VARCHAR(6),
        @next_event                 VARCHAR(6), 
        @next_cmp_id                VARCHAR(8),
	      @next_city                  INTEGER,
	      @next_state                 VARCHAR(6),
	      @next_region1               VARCHAR(6),
	      @next_region2               VARCHAR(6),
	      @next_region3               VARCHAR(6),
	      @next_region4               VARCHAR(6),
	      @next_cmp_othertype1        VARCHAR(6),
        @plnlgh                     INTEGER,
        @plndate                    DATETIME,
        @plncmp                     VARCHAR(8),
        @plncity                    INTEGER,
        @evt                        VARCHAR(6),
        @StdCmpCodes                TMWTable_char6,
        @PlnDspCodes                TMWTable_char6,
        @UseProfileAssets           CHAR(1)

IF @trcid = 'UNKNOWN'
  RETURN

SELECT  @ExpTimeBuffer = CASE WHEN gi_name = 'ExpTimeBuffer' THEN COALESCE(gi_integer1, 0) ELSE @ExpTimeBuffer END,
        @EDOWU = CASE WHEN gi_name = 'ExpDontOverwriteWithUnknown' THEN gi_string1 ELSE @EDOWU END,
        @TrcProfileUpdateNonDispExp = CASE WHEN gi_name = 'TrcProfileUpdateNonDispExp' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @TrcProfileUpdateNonDispExp END,
        @TrpUpdTrcHub = CASE WHEN gi_name = 'TrpUpdTrcHub' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @TrpUpdTrcHub END,
        @NewTrcExpLogic = CASE WHEN gi_name = 'TrcExpLogic' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @NewTrcExpLogic END,
        @ChkCllGPSUpd = CASE WHEN gi_name = 'ChkCllGPSUpd' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @ChkCllGPSUpd END,
        @DrvTrcProt = CASE WHEN gi_name = 'DrvTrcProt' THEN COALESCE(gi_string1, 'NONE') ELSE @DrvTrcProt END
  FROM  generalinfo
 WHERE  gi_name IN ('ExpDontOverwriteWithUnknown', 'TrcProfileUpdateNonDispExp', 'ExpTimeBuffer', 'TrpUpdTrcHub', 'TrcExpLogic', 'ChkCllGPSUpd', 'DrvTrcProt')


 --emolvera changed exptime buffer to consider not closed on time expirations

 SELECT @comparedate = DATEADD(MINUTE, COALESCE(1000, 0), GETDATE()),
        @EDOWU = ',' + @EDOWU + ',',
        @EDOWU_condition_met = 'N',
        @TrcProfileUpdateNonDispExp = COALESCE(@TrcProfileUpdateNonDispExp, 'N'),
        @TrpUpdTrcHub = COALESCE(@TrpUpdTrcHub, 'N'),
        @NewTrcExpLogic = COALESCE(@NewTrcExpLogic, 'N'),
        @ChkCllGPSUpd = COALESCE(@ChkCllGPSUpd, 'N'),
        @DrvTrcProt = COALESCE(@DrvTrcProt, 'N'),
        @UseProfileAssets = 'N'

-- Find latest active expiration with priority given to expiration with code = 900 (Termination)
SELECT TOP 1 
        @expcode = Active.ExpirationCode,
        @expavldate = Active.ExpirationEndDate,
        @expdate = Active.ExpirationStartDate,
        @expavlcmp = Active.ExpirationCompany,
        @expavlcity = Active.ExpirationCity,
        @expstat = Active.ExpirationStatus
	FROM  dbo.Expstatus_GetActiveExpiration_fn('TRC', @trcid, @comparedate, CASE WHEN @TrcProfileUpdateNonDispExp = 'Y' THEN 0 ELSE 200 END, 'TrcExp', 'TrcStatus') Active

SELECT  @expcode = COALESCE(@expcode, 0)



IF @expcode = 900
BEGIN
  IF @debug = 0 
    UPDATE  tractorprofile
       SET  trc_avl_status = @expstat,
            trc_status = @expstat,
            trc_avl_date = @expavldate,
            trc_retiredate = @expdate
     WHERE  trc_number = @trcid 
       AND  (COALESCE(trc_avl_status, '-98765') <> COALESCE(@expstat, '-98765')
        OR   COALESCE(trc_status, '-98765') <> COALESCE(@expstat, '-98765')
        OR   COALESCE(trc_avl_date, CONVERT(DATETIME, 0)) <> COALESCE(@expavldate, CONVERT(DATETIME, 0))
        OR   COALESCE(trc_retiredate, CONVERT(DATETIME, 0)) <> COALESCE(@expdate, CONVERT(DATETIME, 0)))
  ELSE


    SELECT  trc_number,
            @expstat trc_avl_status,
			@expstat trc_status,
			@expavldate trc_avl_date,
			@expavldate trc_retiredate,
            trc_avl_cmp_id,
            trc_avl_city,
			trc_pln_date,	
			trc_pln_cmp_id,
			trc_pln_city,
			trc_pln_lgh,   
			trc_avl_lgh,
            trc_trailer1,
            trc_trailer2,
			trc_next_event,
			trc_next_cmp_id,
			trc_next_city,
			trc_next_state,
			trc_next_region1,
			trc_next_region2,
			trc_next_region3,
			trc_next_region4,
			trc_next_cmp_othertype1,	
			trc_prior_event,
			trc_prior_cmp_id,
			trc_prior_city,
			trc_prior_state,
			trc_prior_region1,
			trc_prior_region2,
			trc_prior_region3,
			trc_prior_region4,
			trc_prior_cmp_othertype1
      FROM  tractorprofile
     WHERE  trc_number = @trcid
  RETURN
END

-- Find current activity (latest started or completed leg)
INSERT  @StdCmpCodes
  SELECT  LEFT(value, 6) FROM dbo.CSVStringsToTable_fn('CMP,STD')

SELECT  @lgh = Activity.lgh_number,
        @avlstat = CASE WHEN Activity.Status = 'STD' THEN 'USE' ELSE 'AVL' END,
        @avldate = Activity.AvailableDate,
        @avlcmp = Activity.AvailableCompany,
        @avlcity = Activity.AvailableCity,
        @driver1 = Activity.Driver1,
        @driver2 = Activity.Driver2,
        @currenthubreading = Activity.CurrentHubMiles,
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
        @next_cmp_othertype1 = Activity.NextCompanyOthertype1,
				@trailer1 = Activity.Trailer1,
				@trailer2 = Activity.Trailer2    
  FROM  dbo.TrcExpstatus_GetActivity_fn(@trcid, @StdCmpCodes) Activity


-- Find planned activity (latest planned or dispatched leg)
INSERT  @PlnDspCodes
  SELECT  LEFT(value, 6) FROM dbo.CSVStringsToTable_fn('PLN,DSP')

SELECT  @plnlgh = Planned.lgh_number,
        @plndate = Planned.AvailableDate,
        @plncmp = Planned.AvailableCompany,
        @plncity = Planned.AvailableCity
  FROM  TrcExpstatus_GetActivity_fn(@trcid, @PlnDspCodes) Planned




	IF @expcode = 0




		  IF @NewTrcExpLogic = 'Y' 
           begin

			SELECT  @expcode = Completed.ExpirationCode,
					@expavldate = Completed.ExpirationEndDate,
					@expdate = Completed.ExpirationStartDate,
					@expavlcmp = Completed.ExpirationCompany,
					@expavlcity = Completed.ExpirationCity,
					@expstat = Completed.ExpirationStatus
			  FROM  Expstatus_GetCompletedExpirationNew_fn('TRC', @trcid, @comparedate, CASE WHEN @TrcProfileUpdateNonDispExp = 'Y' THEN 0 ELSE 200 END, 'TrcExp') Completed
		   end

	
		  ELSE
		  begin

			SELECT  @expcode = Completed.ExpirationCode,
					@expavldate = Completed.ExpirationEndDate,
					@expdate = Completed.ExpirationStartDate,
					@expavlcmp = Completed.ExpirationCompany,
					@expavlcity = Completed.ExpirationCity,
					@expstat = Completed.ExpirationStatus
			  FROM  Expstatus_GetCompletedExpiration_fn('TRC', @trcid, @comparedate, CASE WHEN @TrcProfileUpdateNonDispExp = 'Y' THEN 0 ELSE 200 END, 'TrcExp') Completed
		  end



SELECT @expcode = COALESCE(@expcode, 0), @lgh = COALESCE(@lgh,0)




-- Have both trip and expiration
IF @lgh > 0 AND @expcode > 0
BEGIN



  IF @avlstat <> 'USE' 
  BEGIN



    IF (@expavldate >= @avldate OR @expstat <> 'AVL') OR @evt = 'INSERV'
    BEGIN
      SELECT  @avlstat = @expstat,
			        @avldate = @expavldate,
			        @avlcmp = @expavlcmp,
			        @avlcity = @expavlcity      
      IF CHARINDEX(',' + RTRIM(@expabbr) + ',', @EDOWU) > 1 AND (COALESCE(@expavlcmp, 'UNKNOWN') = 'UNKNOWN' AND COALESCE(@expavlcity, 0) = 0)
      BEGIN
        SET @EDOWU_condition_met = 'Y'
      END
    END
  END
END

-- Have only on inservice move
ELSE IF @lgh> 0 AND @evt = 'INSERV'
BEGIN

  SET @UseProfileAssets = 'Y'
END
-- Have active expiration only
ELSE IF @expcode > 0
BEGIN

	SELECT  @avlstat = @expstat,
		      @avldate = @expavldate,
		      @avlcmp = @expavlcmp,
		      @avlcity = @expavlcity
END
-- Have neither a trip or expiration
ELSE IF @expcode = 0 AND @lgh = 0
BEGIN

  SELECT  @avlstat = 'AVL',
		      @avldate = '19500101',
		      @avlcmp = 'UNKNOWN',
		      @avlcity = 0,
          @UseProfileAssets = 'Y'
END


--THIS PIECE OF CODE HAS NO SENSE WHY SET A UNIT AS PLN WHEN IT SHOUL BE AVL.... BY EMOLVERA 16 JUL 2019 EMOLVERA DISABLED IT --

/*
IF @plncity IS NULL
	SELECT	@plndate = @avldate,
			@plncmp = @avlcmp,
			@plncity = @avlcity,
            @plnlgh = @lgh
*/



-- If there is planned trip and status is AVL make status PLN
IF @avlstat = 'AVL' AND @plnlgh > 0
BEGIN

  SELECT  @avlstat = 'PLN'
END

IF @debug = 0
BEGIN


  UPDATE  tractorprofile 	
     SET  trc_avl_status = @avlstat,
          trc_status = @avlstat,
			    trc_avl_date = @avldate,
			    trc_retiredate = '20491231 23:59',
			    trc_avl_cmp_id = CASE
					                   WHEN @EDOWU_condition_met = 'Y' THEN trc_avl_cmp_id
                             WHEN @ChkCllGPSUpd = 'Y' AND trc_gps_date > @avldate AND trc_avl_city > 0 THEN trc_avl_cmp_id
					                   ELSE @avlcmp 
                           END,
			    trc_avl_city = CASE
					                 WHEN @EDOWU_condition_met = 'Y' THEN trc_avl_city
                           WHEN @ChkCllGPSUpd = 'Y' AND trc_gps_date > @avldate AND trc_avl_city > 0 THEN trc_avl_city
					                 ELSE @avlcity 
                         END,
			    trc_driver = CASE
                         WHEN @DrvTrcProt <> 'NONE' AND @DrvTrcProt <> 'DRV' THEN trc_driver
                         WHEN @UseProfileAssets = 'Y' THEN trc_driver
                         ELSE @driver1
                       END,
			    trc_driver2 = CASE 
                          WHEN @DrvTrcProt <> 'NONE' AND @DrvTrcProt <> 'DRV' THEN trc_driver2
                          WHEN @UseProfileAssets = 'Y' THEN trc_driver2
                          ELSE @driver2
                        END,
			    trc_trailer1 = CASE 
                           WHEN @UseProfileAssets = 'Y' THEN trc_trailer1
                           ELSE @trailer1
                         END,
			    trc_trailer2 = CASE
                           WHEN @UseProfileAssets = 'Y' THEN trc_trailer2
                           ELSE @trailer2
                         END,
			    trc_pln_date = @plndate,	
			    trc_pln_cmp_id = @plncmp,
			    trc_pln_city = @plncity,
			    trc_pln_lgh = @lgh,   
			    trc_avl_lgh = @plnlgh,
			    trc_next_event = COALESCE(@next_event,'UNK'),
			    trc_next_cmp_id = COALESCE(@next_cmp_id,'UNKNOWN'),
			    trc_next_city = COALESCE(@next_city,0),
			    trc_next_state = COALESCE(@next_state,'XX'),
			    trc_next_region1 = COALESCE(@next_region1,'UNK'),
			    trc_next_region2 = COALESCE(@next_region2,'UNK'),
			    trc_next_region3 = COALESCE(@next_region3,'UNK'),
			    trc_next_region4 = COALESCE(@next_region4,'UNK'),
			    trc_next_cmp_othertype1 = COALESCE(@next_cmp_othertype1,'UNK'),	
			    trc_prior_event = COALESCE(@prior_event,'UNK'),
			    trc_prior_cmp_id = COALESCE(@prior_cmp_id,'UNKNOWN'),
			    trc_prior_city = COALESCE(@prior_city,0),
			    trc_prior_state = COALESCE(@prior_state,'XX'),
			    trc_prior_region1 = COALESCE(@prior_region1,'UNK'),
			    trc_prior_region2 = COALESCE(@prior_region2,'UNK'),
			    trc_prior_region3 = COALESCE(@prior_region3,'UNK'),
			    trc_prior_region4 = COALESCE(@prior_region4,'UNK'),
			    trc_prior_cmp_othertype1 = COALESCE(@prior_cmp_othertype1,'UNK'),
          trc_currenthub = CASE
                             WHEN @TrpUpdTrcHub = 'Y' AND (trc_currenthub IS NULL OR trc_currenthub < @currenthubreading) THEN @currenthubreading
                             ELSE trc_currenthub
                           END
   WHERE  trc_number = @trcid 
     AND	(COALESCE(trc_avl_status,	'-98765') <> COALESCE(@avlstat,	'-98765')
	    OR	 COALESCE(trc_status,	'-98765') <> COALESCE(@avlstat,	'-98765')
      OR	 COALESCE(trc_avl_date,	CONVERT(DATETIME, 0))	<> COALESCE(@avldate,	CONVERT(DATETIME, 0)) 
      OR	 COALESCE(trc_retiredate,	CONVERT(DATETIME, 0))	<> '20491231 23:59'
      OR   COALESCE(trc_avl_cmp_id,	'-9876543')	<> CASE
					                                           WHEN @EDOWU_condition_met = 'Y' THEN COALESCE(trc_avl_cmp_id,	'-9876543')
                                                     WHEN @ChkCllGPSUpd = 'Y' AND trc_gps_date > @avldate AND trc_avl_city > 0 THEN COALESCE(trc_avl_cmp_id,	'-9876543')
                        					                   ELSE COALESCE(@avlcmp, '-9876543') 
                                                   END
      OR   COALESCE(trc_avl_city,	-987654) <> CASE
					                                      WHEN @EDOWU_condition_met = 'Y' THEN COALESCE(trc_avl_city,	-987654)
                                                WHEN @ChkCllGPSUpd = 'Y' AND trc_gps_date > @avldate AND trc_avl_city > 0 THEN COALESCE(trc_avl_city,	-987654)
					                                      ELSE COALESCE(@avlcity, -987654) 	
                                              END
      OR   COALESCE(trc_driver,	'-9876543')	<> CASE
                                                 WHEN @DrvTrcProt <> 'NONE' AND @DrvTrcProt <> 'DRV' THEN COALESCE(trc_driver,	'-9876543')
                                                 WHEN @UseProfileAssets = 'Y' THEN COALESCE(trc_driver,	'-9876543')
                                                 ELSE COALESCE(@driver1,	'-9876543') 
                                               END
      OR   COALESCE(trc_driver2, '-9876543') <> CASE
                                                  WHEN @DrvTrcProt <> 'NONE' AND @DrvTrcProt <> 'DRV' THEN COALESCE(trc_driver2,	'-9876543')
                                                  WHEN @UseProfileAssets = 'Y' THEN COALESCE(trc_driver2,	'-9876543')
                                                  ELSE COALESCE(@driver2,	'-9876543') 
                                                END
      OR   COALESCE(trc_trailer1, '-9876543') <> CASE 
                                                   WHEN @UseProfileAssets = 'Y' THEN COALESCE(trc_trailer1, '-9876543')
                                                   ELSE COALESCE(@trailer1, '-9876543')
                                                 END
		  OR	 COALESCE(trc_trailer2, '-9876543') <> CASE 
                                                   WHEN @UseProfileAssets = 'Y' THEN COALESCE(trc_trailer2, '-9876543')
                                                   ELSE COALESCE(@trailer2, '-9876543')
                                                 END
		  OR	 COALESCE(trc_pln_date, CONVERT(DATETIME, 0))	<> COALESCE(@plndate,	CONVERT(DATETIME, 0))	
		  OR	 COALESCE(trc_pln_cmp_id, '-9876543') <> COALESCE(@plncmp, '-9876543')
		  OR	 COALESCE(trc_pln_city, -987654) <> COALESCE(@plncity, -987654)
		  OR	 COALESCE(trc_pln_lgh, -987654) <> COALESCE(@lgh,	-987654)
		  OR	 COALESCE(trc_avl_lgh, -987654) <> COALESCE(@plnlgh, -987654)
		  OR	 COALESCE(trc_next_event, '-98765') <> COALESCE(@next_event,	'UNK')
		  OR   COALESCE(trc_next_cmp_id,	'-9876543') <> COALESCE(@next_cmp_id,	'UNKNOWN')
		  OR   COALESCE(trc_next_city, -987654) <> COALESCE(@next_city,	0)
		  OR	 COALESCE(trc_next_state, '-98765') <> COALESCE(@next_state, 'XX')
		  OR	 COALESCE(trc_next_region1, '-98765') <> COALESCE(@next_region1, 'UNK')
		  OR	 COALESCE(trc_next_region2, '-98765') <> COALESCE(@next_region2, 'UNK')
		  OR	 COALESCE(trc_next_region3, '-98765') <> COALESCE(@next_region3, 'UNK')
		  OR	 COALESCE(trc_next_region4, '-98765') <> COALESCE(@next_region4, 'UNK')
      OR	 COALESCE(trc_next_cmp_othertype1, '-98765')	<> COALESCE(@next_cmp_othertype1,'UNK')
		  OR	 COALESCE(trc_prior_event, '-98765') <> COALESCE(@prior_event, 'UNK')
		  OR	 COALESCE(trc_prior_cmp_id, '-9876543') <> COALESCE(@prior_cmp_id, 'UNKNOWN')
		  OR	 COALESCE(trc_prior_city, -987654) <> COALESCE(@prior_city,	0)
		  OR	 COALESCE(trc_prior_state, '-98765') <> COALESCE(@prior_state,	'XX')
		  OR	 COALESCE(trc_prior_region1, '-98765') <> COALESCE(@prior_region1,	'UNK')
		  OR	 COALESCE(trc_prior_region2, '-98765') <> COALESCE(@prior_region2,	'UNK')
		  OR	 COALESCE(trc_prior_region3, '-98765') <> COALESCE(@prior_region3,	'UNK')
		  OR	 COALESCE(trc_prior_region4, '-98765') <> COALESCE(@prior_region4,	'UNK')
		  OR	 COALESCE(trc_prior_cmp_othertype1, '-98765') <> COALESCE(@prior_cmp_othertype1,'UNK')
      OR   COALESCE(trc_currenthub, 0) <> CASE
                                            WHEN @TrpUpdTrcHub = 'Y' AND (trc_currenthub IS NULL OR trc_currenthub < @currenthubreading) THEN COALESCE(@currenthubreading, 0)
                                            ELSE COALESCE(trc_currenthub, 0)
                                          END )
END
ELSE
BEGIN
---DEBUG MODE ON-------------------------------------------------------------------------------------------------------------------------

  SELECT  trc_avl_status = @avlstat,
          trc_status = @avlstat,
			    trc_avl_date = @avldate,
			    trc_retiredate = '20491231 23:59',
          trc_avl_lgh = @plnlgh,
			    trc_avl_cmp_id = CASE
					                   WHEN @EDOWU_condition_met = 'Y' THEN trc_avl_cmp_id
                             WHEN @ChkCllGPSUpd = 'Y' AND trc_gps_date > @avldate AND trc_avl_city > 0 THEN trc_avl_cmp_id
					                   ELSE @avlcmp 
                           END,
			    trc_avl_city = CASE
					                 WHEN @EDOWU_condition_met = 'Y' THEN trc_avl_city
                           WHEN @ChkCllGPSUpd = 'Y' AND trc_gps_date > @avldate AND trc_avl_city > 0 THEN trc_avl_city
					                 ELSE @avlcity 
                         END,
			    trc_driver = CASE
                         WHEN @DrvTrcProt <> 'NONE' AND @DrvTrcProt <> 'DRV' THEN trc_driver
                         WHEN @UseProfileAssets = 'Y' THEN trc_driver
                         ELSE @driver1
                       END,
			    trc_driver2 = CASE 
                          WHEN @DrvTrcProt <> 'NONE' AND @DrvTrcProt <> 'DRV' THEN trc_driver2
                          WHEN @UseProfileAssets = 'Y' THEN trc_driver2
                          ELSE @driver2
                        END,
			    trc_trailer1 = CASE 
                           WHEN @UseProfileAssets = 'Y' THEN trc_trailer1
                           ELSE @trailer1
                         END,
			    trc_trailer2 = CASE
                           WHEN @UseProfileAssets = 'Y' THEN trc_trailer2
                           ELSE @trailer2
                         END,
			    trc_pln_date = @plndate,	
			    trc_pln_cmp_id = @plncmp,
			    trc_pln_city = @plncity,
			    trc_pln_lgh = @lgh,   
			    trc_avl_lgh = @plnlgh,
			    trc_next_event = COALESCE(@next_event,'UNK'),
			    trc_next_cmp_id = COALESCE(@next_cmp_id,'UNKNOWN'),
			    trc_next_city = COALESCE(@next_city,0),
			    trc_next_state = COALESCE(@next_state,'XX'),
			    trc_next_region1 = COALESCE(@next_region1,'UNK'),
			    trc_next_region2 = COALESCE(@next_region2,'UNK'),
			    trc_next_region3 = COALESCE(@next_region3,'UNK'),
			    trc_next_region4 = COALESCE(@next_region4,'UNK'),
			    trc_next_cmp_othertype1 = COALESCE(@next_cmp_othertype1,'UNK'),	
			    trc_prior_event = COALESCE(@prior_event,'UNK'),
			    trc_prior_cmp_id = COALESCE(@prior_cmp_id,'UNKNOWN'),
			    trc_prior_city = COALESCE(@prior_city,0),
			    trc_prior_state = COALESCE(@prior_state,'XX'),
			    trc_prior_region1 = COALESCE(@prior_region1,'UNK'),
			    trc_prior_region2 = COALESCE(@prior_region2,'UNK'),
			    trc_prior_region3 = COALESCE(@prior_region3,'UNK'),
			    trc_prior_region4 = COALESCE(@prior_region4,'UNK'),
			    trc_prior_cmp_othertype1 = COALESCE(@prior_cmp_othertype1,'UNK'),
          trc_currenthub = CASE
                             WHEN @TrpUpdTrcHub = 'Y' AND (trc_currenthub IS NULL OR trc_currenthub < @currenthubreading) THEN @currenthubreading
                             ELSE trc_currenthub
                           END
    FROM  tractorprofile
   WHERE  trc_number = @trcid 
END

UPDATE  trailerprofile
   SET  trl_pupid = COALESCE(@trailer2, 'UNKNOWN')
 WHERE  trl_id = @trailer1
   AND  COALESCE(trl_pupid, '9876543210') <> COALESCE(@trailer2, 'UNKNOWN')

GO
GRANT EXECUTE ON  [dbo].[trc_expstatus] TO [public]
GO
