SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[FindQualifiedAssets_sp]
(
	@lgh INTEGER, 
	@shiftDate DATETIME = NULL, 
	@drivers VARCHAR(MAX) = NULL, 
	@tractors VARCHAR(MAX) = NULL, 
	@trailers VARCHAR(MAX) = NULL
)
AS
SET NOCOUNT ON

DECLARE @SourceDrivers TABLE(id VARCHAR(100))
DECLARE @SourceTractors TABLE(id VARCHAR(100))
DECLARE @SourceTrailers TABLE(id VARCHAR(100))

DECLARE	@mov			INTEGER,
		@startdt		DATETIME,
		@enddt			DATETIME,
		@PickupCmpID	VARCHAR(255)
		
DECLARE	@DriverLdrq TABLE(
			lrq_type		VARCHAR(6),
			lrq_quantity	INTEGER,
			lrq_not			CHAR(1))

DECLARE	@TractorLdrq TABLE(
			lrq_type		VARCHAR(6),
			lrq_quantity	INTEGER,
			lrq_not			CHAR(1))

DECLARE	@TrailerLdrq TABLE(
			lrq_type		VARCHAR(6),
			lrq_quantity	INTEGER,
			lrq_not			CHAR(1))
			
DECLARE	@QualifiedDrivers TABLE(
			mpp_id	VARCHAR(8),
			airmiles FLOAT)
			
DECLARE	@QualifiedTractors TABLE(
			trc_number	VARCHAR(8),
			airmiles FLOAT)
			
DECLARE	@QualifiedTrailers TABLE(
			trl_id	VARCHAR(13),
			airmiles FLOAT)
	
DECLARE @QualifiedCombos TABLE(
			ID			VARCHAR(255),
			tractor		VARCHAR(8),
			driver		VARCHAR(8),
			trailer1	VARCHAR(13),
			trailer2	VARCHAR(13),
			airmiles FLOAT)	

IF @drivers IS NOT NULL
	INSERT INTO @SourceDrivers (id) SELECT value FROM CSVStringsToTable_fn(@drivers)  

IF @tractors IS NOT NULL
	INSERT INTO @SourceTractors (id) SELECT value FROM CSVStringsToTable_fn(@tractors)  

IF @trailers IS NOT NULL
	INSERT INTO @SourceTrailers (id) SELECT value FROM CSVStringsToTable_fn(@trailers)  

SELECT	@mov = mov_number, 
		@startdt = lgh_startdate, 
		@enddt = lgh_enddate
  FROM	legheader
 WHERE	lgh_number = @lgh

  SELECT 	TOP 1 @pickupCmpID = cmp_id
    FROM	stops
   WHERE	lgh_number = @lgh
     AND	ord_hdrnumber >0
ORDER BY	stp_mfh_sequence ASC

INSERT INTO @DriverLdrq
	SELECT	lrq_type, lrq_quantity, lrq_not
	  FROM	loadrequirement
	 WHERE	mov_number = @mov
	   AND	lrq_equip_type = 'DRV'  
	   AND	lrq_manditory = 'Y'
	   AND	lrq_default <> 'X'
	   AND	(cmp_id = 'UNKNOWN' OR EXISTS(SELECT * FROM stops WHERE cmp_id = loadrequirement.cmp_id)) 
	   AND	(def_id_type = 'BOTH' OR EXISTS(SELECT * FROM stops WHERE stp_type = loadrequirement.def_id_type))

INSERT INTO @TractorLdrq
	SELECT	lrq_type, lrq_quantity, lrq_not
	  FROM	loadrequirement
	 WHERE	mov_number = @mov
	   AND	lrq_equip_type = 'TRC'  
	   AND	lrq_manditory = 'Y'
	   AND	lrq_default <> 'X'
	   AND	(cmp_id = 'UNKNOWN' OR EXISTS(SELECT * FROM stops WHERE cmp_id = loadrequirement.cmp_id)) 
	   AND	(def_id_type = 'BOTH' OR EXISTS(SELECT * FROM stops WHERE stp_type = loadrequirement.def_id_type))   

INSERT INTO @TrailerLdrq
	SELECT	lrq_type, lrq_quantity, lrq_not
	  FROM	loadrequirement
	 WHERE	mov_number = @mov
	   AND	lrq_equip_type = 'TRL'  
	   AND	lrq_manditory = 'Y'
	   AND	lrq_default <> 'X'
	   AND	(cmp_id = 'UNKNOWN' OR EXISTS(SELECT * FROM stops WHERE cmp_id = loadrequirement.cmp_id)) 
	   AND	(def_id_type = 'BOTH' OR EXISTS(SELECT * FROM stops WHERE stp_type = loadrequirement.def_id_type))
	
INSERT INTO @QualifiedDrivers
	SELECT	mpp.mpp_id,
			dbo.fnc_AirMilesBetweenCompanies(mpp.mpp_avl_cmp_id, @pickupCmpID)
	  FROM	manpowerprofile mpp
	 WHERE	mpp.mpp_id <> 'UNKNOWN'
	   AND	(SELECT COUNT(*)
	 		   FROM driverqualifications dq
	 					INNER JOIN @DriverLdrq dlrq ON dlrq.lrq_type = dq.drq_type AND dlrq.lrq_not = 'Y' AND ISNULL(dlrq.lrq_quantity, 1) <= ISNULL(dq.drq_quantity, 1)
			  WHERE dq.drq_driver = mpp.mpp_id
			    AND	ISNULL(dq.drq_expire_date, '2049-12-31 23:59:59') >= @enddt
			    AND ISNULL(dq.drq_date, '1950-01-01 00:00:00') <= @startdt) = (SELECT COUNT(*) FROM @DriverLdrq WHERE lrq_not = 'Y')
	   AND	(SELECT COUNT(*)
	 		   FROM driverqualifications dq
	 					INNER JOIN @DriverLdrq dlrq ON dlrq.lrq_type = dq.drq_type AND dlrq.lrq_not = 'N'
			  WHERE dq.drq_driver = mpp.mpp_id
			    AND	ISNULL(dq.drq_expire_date, '2049-12-31 23:59:59') >= @enddt
			    AND ISNULL(dq.drq_date, '1950-01-01 00:00:00') <= @startdt) = 0
			    
IF @drivers IS NOT NULL
	DELETE FROM @QualifiedDrivers WHERE mpp_id NOT IN (SELECT id FROM @SourceDrivers)
			    
INSERT INTO @QualifiedTractors
	SELECT	trc.trc_number,
			dbo.fnc_AirMilesBetweenCompanies(trc.trc_avl_cmp_id, @pickupCmpID)
	  FROM	tractorprofile trc
	 WHERE	trc_number <> 'UNKNOWN'
	   AND	(SELECT COUNT(*)
	 		   FROM tractoraccesories ta
	 					INNER JOIN @TractorLdrq tlrq ON tlrq.lrq_type = ta.tca_type AND tlrq.lrq_not = 'Y' AND ISNULL(tlrq.lrq_quantity, 1) <= ISNULL(ta.tca_quantitiy, 1)
			  WHERE ta.tca_tractor = trc.trc_number
			    AND	ISNULL(ta.tca_expire_date, '2049-12-31 23:59:59') >= @enddt
			    AND ISNULL(ta.tca_dateaquired, '1950-01-01 00:00:00') <= @startdt) = (SELECT COUNT(*) FROM @TractorLdrq WHERE lrq_not = 'Y')
	   AND	(SELECT COUNT(*)
	 		   FROM tractoraccesories ta
	 					INNER JOIN @TractorLdrq tlrq ON tlrq.lrq_type = ta.tca_type AND tlrq.lrq_not = 'N'
			  WHERE ta.tca_tractor = trc.trc_number
			    AND	ISNULL(ta.tca_expire_date, '2049-12-31 23:59:59') >= @enddt
			    AND ISNULL(ta.tca_dateaquired, '1950-01-01 00:00:00') <= @startdt) = 0

IF @tractors IS NOT NULL
	DELETE FROM @QualifiedTractors WHERE trc_number NOT IN (SELECT id FROM @SourceTractors)
	
INSERT INTO @QualifiedTrailers
	SELECT	trl.trl_id,
			dbo.fnc_AirMilesBetweenCompanies(trl.trl_avail_cmp_id, @pickupCmpID)
	  FROM	trailerprofile trl
	 WHERE	trl_id <> 'UNKNOWN'
	   AND	(SELECT COUNT(*)
	 		   FROM trlaccessories ta
	 					INNER JOIN @TrailerLdrq tlrq ON tlrq.lrq_type = ta.ta_type AND tlrq.lrq_not = 'Y' AND ISNULL(tlrq.lrq_quantity, 1) <= ISNULL(ta.ta_quantity, 1)
			  WHERE ta.ta_trailer = trl.trl_id
			    AND	ISNULL(ta.ta_expire_date, '2049-12-31 23:59:59') >= @enddt
			    AND ISNULL(ta.ta_dateacquired, '1950-01-01 00:00:00') <= @startdt) = (SELECT COUNT(*) FROM @TrailerLdrq WHERE lrq_not = 'Y')
	   AND	(SELECT COUNT(*)
	 		   FROM trlaccessories ta
	 					INNER JOIN @TrailerLdrq tlrq ON tlrq.lrq_type = ta.ta_type AND tlrq.lrq_not = 'N'
			  WHERE ta.ta_trailer = trl.trl_id
			    AND	ISNULL(ta.ta_expire_date, '2049-12-31 23:59:59') >= @enddt
			    AND ISNULL(ta.ta_dateacquired, '1950-01-01 00:00:00') <= @startdt) = 0
			 
IF @trailers IS NOT NULL
	DELETE FROM @QualifiedTrailers WHERE trl_id NOT IN (SELECT id FROM @SourceTrailers)
				    
INSERT INTO @QualifiedCombos
	SELECT	trc.trc_number + '|' + drv.mpp_id + '|' + ISNULL(trl1.trl_id, 'UNKNOWN') + '|' + ISNULL(trl2.trl_id, 'UNKNOWN'),
			trc.trc_number,
			drv.mpp_id,
			ISNULL(trl1.trl_id, 'UNKNOWN'),
			ISNULL(trl2.trl_id, 'UNKNOWN'),
			dbo.fnc_AirMilesBetweenCompanies(drv.mpp_avl_cmp_id, @pickupCmpID)
	  FROM	tractorprofile trc
				INNER JOIN manpowerprofile drv ON drv.mpp_id = trc.trc_driver
				INNER JOIN trailerprofile trl1 ON trl1.trl_id = trc.trc_trailer1
				INNER JOIN trailerprofile trl2 ON trl2.trl_id = ISNULL(trc.trc_trailer2, 'UNKNOWN')
	 WHERE	trc.trc_number IN (SELECT trc_number FROM @QualifiedTractors)
	   AND	drv.mpp_id IN (SELECT mpp_id FROM @QualifiedDrivers)
	   AND	trl1.trl_id IN (SELECT trl_id FROM @QualifiedTrailers)
	   AND	(trl2.trl_id IN (SELECT trl_id FROM @QualifiedTrailers) OR ISNULL(trc.trc_trailer2, 'UNKNOWN') = 'UNKNOWN')

SELECT	DISTINCT * 
  FROM	@QualifiedCombos
  
SELECT	DISTINCT *
  FROM	@QualifiedTractors qt
 WHERE	NOT EXISTS(SELECT * FROM @QualifiedCombos WHERE tractor = qt.trc_number)  
 
SELECT	DISTINCT *
  FROM	@QualifiedDrivers qd
 WHERE	NOT EXISTS(SELECT * FROM @QualifiedCombos WHERE driver = qd.mpp_id)  

SELECT	DISTINCT *
  FROM	@QualifiedTrailers qt
 WHERE	NOT EXISTS(SELECT * FROM @QualifiedCombos WHERE trailer1 = qt.trl_id OR (trailer2 = qt.trl_id AND trailer2 <> 'UNKNOWN')) 

GO
GRANT EXECUTE ON  [dbo].[FindQualifiedAssets_sp] TO [public]
GO
