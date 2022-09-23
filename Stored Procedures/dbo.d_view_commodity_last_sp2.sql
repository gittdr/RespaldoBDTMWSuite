SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_view_commodity_last_sp2] (@stringparm VARCHAR(13), @numberparm INT, @retrieveby CHAR(3))
AS
/*

DPETE 27846 installing performance enhancement found by Keith

*/

DECLARE @lastleg  INT, 
        @lastleg2 INT, 
        @lastleg3 INT, 
        @fgtcomp  INT,
        @trl1     VARCHAR(13), 
        @trl1wash CHAR(1), 
        @trl2     VARCHAR(13), 
        @trl2wash CHAR(1), 
        @trc      VARCHAR(8), 
        @compart  INT, 
        @stpnum   INT, 
        @maxdate  DATETIME, 
        @exists   INT 

CREATE TABLE #freight(
	ord_hdrnumber		INTEGER			NULL,
	evt_enddate			DATETIME		NULL, 
	cmd_code			VARCHAR(8)		NULL, 
	cmd_name			VARCHAR(60)		NULL, 
	fgt_weight			FLOAT			NULL, 
	fgt_weightunit		VARCHAR(6)		NULL, 
	fgt_count			DECIMAL(10,2)	NULL, 
	fgt_countunit		VARCHAR(6)		NULL, 
	fgt_volume			FLOAT			NULL, 
	fgt_volumeunit		VARCHAR(6)		NULL, 
	fgt_quantity		FLOAT			NULL, 
	fgt_unit			VARCHAR(6)		NULL, 
	scm_subcode			VARCHAR(8)		NULL, 
	fbc_compartm_number	INTEGER			NULL,
	trailer				VARCHAR(13)		NULL,
	wash_status			CHAR(1)			NULL, 
	fbc_compartm_from 	VARCHAR(4)		NULL)

SET @lastleg3 = 0
IF @retrieveby = 'LEG'
   --IF @numberparm <> 0
   IF @numberparm > 0
   BEGIN
      SELECT @trc = lgh_tractor,
			 @trl1 = lgh_primary_trailer,
			 @trl2 = lgh_primary_pup
        FROM legheader 
       WHERE lgh_number = @numberparm
      
      IF ISNULL(@trc, 'UNKNOWN') <> 'UNKNOWN'
         SELECT @lastleg3 = lgh.lgh_number 
           FROM legheader_active lgh, tractorprofile tp
          WHERE lgh.lgh_tractor = @trc 
            AND tp.trc_number = lgh.lgh_tractor 
            AND lgh.lgh_startdate = (SELECT MAX(lgh_startdate) 
									   FROM legheader_active
									  WHERE lgh_tractor = @trc 
										AND lgh_outstatus IN ('STD', 'CMP')) 
            AND tp.trc_require_drvtrl IN (0, 1, 4, 5) 
      
      IF ISNULL(@trl1, 'UNKNOWN') <> 'UNKNOWN'
         SELECT @lastleg = lgh_number 
           FROM assetassignment
          WHERE asgn_id = @trl1 
			AND	asgn_type = 'TRL'
            AND asgn_date = (SELECT MAX(aa.asgn_date) 
							   FROM assetassignment aa, legheader lgh
							  WHERE aa.asgn_id = @trl1
								AND aa.asgn_type = 'TRL'
								AND aa.asgn_status IN ('STD', 'CMP')
								AND (lgh.lgh_primary_trailer = @trl1 
                                 OR lgh_primary_pup = @trl1) 
								AND aa.lgh_number = lgh.lgh_number)

      IF ISNULL(@trl2, 'UNKNOWN') <> 'UNKNOWN'
         SELECT @lastleg2 = lgh_number 
           FROM assetassignment
          WHERE asgn_id = @trl2 
			AND	asgn_type = 'TRL'
            AND asgn_date = (SELECT MAX(aa.asgn_date) 
							   FROM assetassignment aa, legheader lgh
							  WHERE aa.asgn_id = @trl2
								AND aa.asgn_type = 'TRL'
								AND aa.asgn_status IN ('STD', 'CMP')
								AND (lgh.lgh_primary_trailer = @trl2 
                                 OR lgh.lgh_primary_pup = @trl2)
								AND aa.lgh_number = lgh.lgh_number)
   END
ELSE
   IF @stringparm <> 'UNKNOWN'
      SET @retrieveby = 'TRL'

IF @retrieveby = 'TRL'
BEGIN
   SET @lastleg2 = 0
   
   IF @stringparm <> 'UNKNOWN'
      SELECT @lastleg = lgh_number 
        FROM assetassignment 
       WHERE asgn_id = @stringparm 
		 AND asgn_type = 'TRL'
         AND asgn_date = (SELECT MAX(aa.asgn_date) 
                            FROM assetassignment aa, legheader lgh 
                           WHERE aa.asgn_id = @stringparm 
							 AND aa.asgn_type = 'TRL' 
                             AND aa.asgn_status IN ('STD', 'CMP')
							 AND (lgh.lgh_primary_trailer = @stringparm 
                              OR lgh.lgh_primary_pup = @stringparm) 
							 and aa.lgh_number = lgh.lgh_number)			
   ELSE
       SET @lastleg = 0
END

SELECT @EXISTS = COUNT(*) 
  FROM sysobjects 
 WHERE name = 'freight_by_compartment'

IF @EXISTS > 0
   SELECT @fgtcomp = COUNT(evt_number) 
     FROM event, 
          freight_by_compartment
    WHERE event.ord_hdrnumber IN (SELECT DISTINCT ord_hdrnumber 
                                    FROM stops 
                                   WHERE lgh_number IN (@lastleg, @lastleg2, @lastleg3) 
                                     AND lgh_number <> 0 
                                     AND ord_hdrnumber <> 0) 
      AND event.stp_number = freight_by_compartment.stp_number 
ELSE
   SET @fgtcomp = 0

SET @trl1wash = 'N'
SET @trl2wash = 'N'

IF ISNULL(@trl1, 'UNKNOWN') <> 'UNKNOWN' 
   SELECT @trl1wash = trl_wash_status 
     FROM trailerprofile 
    WHERE trl_id = @trl1 
IF ISNULL(@trl2, 'UNKNOWN') <> 'UNKNOWN' 
   SELECT @trl2wash = trl_wash_status 
     FROM trailerprofile 
    WHERE trl_id = @trl2 
IF @retrieveby = 'TRL' 
   SELECT @trl1wash = trl_wash_status 
     FROM trailerprofile 
    WHERE trl_id = @stringparm 

IF @fgtcomp > 0
BEGIN
	INSERT INTO #freight
	    SELECT DISTINCT event.ord_hdrnumber, event.evt_enddate, commodity.cmd_code, commodity.cmd_name, 
	           freight_by_compartment.fbc_weight, freightdetail.fgt_weightunit, freightdetail.fgt_count, freightdetail.fgt_countunit, 
	           freight_by_compartment.fbc_volume, freightdetail.fgt_volumeunit, freightdetail.fgt_quantity, freightdetail.fgt_unit, 
	           freight_by_compartment.scm_subcode, freight_by_compartment.fbc_compartm_number, 
	           CASE WHEN @retrieveby = 'TRL' THEN @stringparm 
	                WHEN fbc_compartm_from = 'LEAD' THEN event.evt_trailer1 
	                WHEN fbc_compartm_from = 'PUP' THEN event.evt_trailer2 
	                ELSE '' END trailer, 
	           CASE WHEN @retrieveby = 'TRL' THEN @trl1wash 
	                WHEN fbc_compartm_from = 'LEAD' THEN @trl1wash  
	                WHEN fbc_compartm_from = 'PUP' THEN @trl2wash 
	                ELSE '' END wash_status, 
	           freight_by_compartment.fbc_compartm_from 
	      FROM event, 
	           freight_by_compartment, 
	           freightdetail, 
	           commodity
	     WHERE freight_by_compartment.mov_number IN (SELECT DISTINCT mov_number 
	                                                   FROM legheader  
	                                                 WHERE lgh_number IN (@lastleg, @lastleg2, @lastleg3)) 
	       AND event.stp_number = freight_by_compartment.stp_number 
	       AND event.evt_pu_dr = 'DRP' 
	       AND freightdetail.fgt_number = freight_by_compartment.fgt_number 
	       AND commodity.cmd_code = freight_by_compartment.cmd_code 

    INSERT INTO #freight (evt_enddate, cmd_code, cmd_name, 
                fgt_weight, fgt_volume, scm_subcode, fbc_compartm_number, 
                trailer, wash_status, fbc_compartm_from)
         SELECT DISTINCT lgh_enddate, freight_by_compartment.cmd_code, 'UNKNOWN', 
                freight_by_compartment.fbc_weight, freight_by_compartment.fbc_volume, 
                freight_by_compartment.scm_subcode, freight_by_compartment.fbc_compartm_number, 
                CASE WHEN @retrieveby = 'TRL' THEN @stringparm 
                     WHEN fbc_compartm_from = 'LEAD' THEN @trl1 
                     WHEN fbc_compartm_from = 'PUP' THEN @trl2  
                     ELSE '' END, 'N', freight_by_compartment.fbc_compartm_from 
      FROM freight_by_compartment, legheader  
     WHERE legheader.lgh_number IN (@lastleg, @lastleg2, @lastleg3) 
       AND freight_by_compartment.mov_number = legheader.mov_number
       AND freight_by_compartment.stp_number = 0
       AND freight_by_compartment.fgt_number = 0

    
    SELECT @compart = MIN(fbc_compartm_number) 
      FROM #freight 
     WHERE trailer = @trl1 
       AND fgt_weight = 0
    WHILE @compart > 0 
    BEGIN
         SELECT @maxdate = MAX(evt_startdate) 
           FROM event, freight_by_compartment 
          WHERE event.stp_number = freight_by_compartment.stp_number 
            AND evt_trailer1 = @trl1 
            AND evt_status = 'DNE' 
            AND evt_pu_dr = 'DRP'
            AND fbc_compartm_number = @compart 
            AND fbc_weight > 0
         
         SELECT @stpnum = MAX(event.stp_number) 
           FROM event, freight_by_compartment 
          WHERE event.stp_number = freight_by_compartment.stp_number 
            AND evt_trailer1 = @trl1 
            AND evt_status = 'DNE' 
            AND evt_pu_dr = 'DRP'
            AND evt_startdate = @maxdate
            AND fbc_compartm_number = @compart 
            AND fbc_weight > 0
         
         UPDATE #freight 
            SET ord_hdrnumber =  event.ord_hdrnumber, 
                evt_enddate = event.evt_enddate, 
                cmd_code = commodity.cmd_code, 
                cmd_name = commodity.cmd_name, 
                fgt_weight = freight_by_compartment.fbc_weight, 
                fgt_weightunit = freightdetail.fgt_weightunit, 
                fgt_count = freightdetail.fgt_count, 
                fgt_countunit = freightdetail.fgt_countunit, 
                fgt_volume = freight_by_compartment.fbc_volume, 
                fgt_volumeunit = freightdetail.fgt_volumeunit, 
                fgt_quantity = freightdetail.fgt_quantity, 
                fgt_unit = CASE freightdetail.fgt_unit WHEN NULL THEN 'UNKNOWN' WHEN '' THEN 'UNKNOWN' ELSE freightdetail.fgt_unit END,  
                scm_subcode = freight_by_compartment.scm_subcode, 
                fbc_compartm_from = freight_by_compartment.fbc_compartm_from 
           FROM event, freightdetail, freight_by_compartment, commodity 
          WHERE freight_by_compartment.fbc_compartm_number = @compart 
            AND #freight.fbc_compartm_number = freight_by_compartment.fbc_compartm_number
            AND #freight.trailer = @trl1 
            AND event.stp_number = @stpnum 
            AND event.stp_number = freight_by_compartment.stp_number 
            AND freight_by_compartment.cmd_code = commodity.cmd_code 
            AND freightdetail.fgt_number = freight_by_compartment.fgt_number
         
         SELECT @compart = MIN(fbc_compartm_number) 
           FROM #freight 
          WHERE trailer = @trl1 
            AND fgt_weight = 0 
            AND fbc_compartm_number > @compart
    END

    SELECT @compart = MIN(fbc_compartm_number) 
      FROM #freight 
     WHERE trailer = @trl2 
       AND fgt_weight = 0
    WHILE @compart > 0 
    BEGIN
         SELECT @maxdate = MAX(evt_startdate) 
           FROM event, freight_by_compartment 
          WHERE event.stp_number = freight_by_compartment.stp_number 
            AND evt_trailer2 = @trl2 
            AND evt_status = 'DNE' 
            AND evt_pu_dr = 'DRP'
            AND fbc_compartm_number = @compart 
            AND fbc_weight > 0
         
         SELECT @stpnum = MAX(event.stp_number) 
           FROM event, freight_by_compartment 
          WHERE event.stp_number = freight_by_compartment.stp_number 
            AND evt_trailer2 = @trl2 
            AND evt_status = 'DNE' 
            AND evt_pu_dr = 'DRP'
            AND evt_startdate = @maxdate
            AND fbc_compartm_number = @compart 
            AND fbc_weight > 0
         
         UPDATE #freight 
            SET ord_hdrnumber =  event.ord_hdrnumber, 
                evt_enddate = event.evt_enddate, 
                cmd_code = commodity.cmd_code, 
                cmd_name = commodity.cmd_name, 
                fgt_weight = freight_by_compartment.fbc_weight, 
                fgt_weightunit = freightdetail.fgt_weightunit, 
                fgt_count = freightdetail.fgt_count, 
                fgt_countunit = freightdetail.fgt_countunit, 
                fgt_volume = freight_by_compartment.fbc_volume, 
                fgt_volumeunit = freightdetail.fgt_volumeunit, 
                fgt_quantity = freightdetail.fgt_quantity, 
                fgt_unit = CASE freightdetail.fgt_unit WHEN NULL THEN 'UNKNOWN' WHEN '' THEN 'UNKNOWN' ELSE freightdetail.fgt_unit END,  
                scm_subcode = freight_by_compartment.scm_subcode, 
                fbc_compartm_from = freight_by_compartment.fbc_compartm_from 
           FROM event, freightdetail, freight_by_compartment, commodity 
          WHERE freight_by_compartment.fbc_compartm_number = @compart 
            AND #freight.fbc_compartm_number = freight_by_compartment.fbc_compartm_number
            AND #freight.trailer = @trl2 
            AND event.stp_number = @stpnum 
            AND event.stp_number = freight_by_compartment.stp_number 
            AND freight_by_compartment.cmd_code = commodity.cmd_code 
            AND freightdetail.fgt_number = freight_by_compartment.fgt_number
         
         SELECT @compart = MIN(fbc_compartm_number) 
           FROM #freight 
          WHERE trailer = @trl2 
            AND fgt_weight = 0 
            AND fbc_compartm_number > @compart
    END
    
    SELECT DISTINCT ord_hdrnumber, evt_enddate, cmd_code, cmd_name, 
           CASE fgt_weight WHEN 0 THEN NULL ELSE fgt_weight END fbc_weight, 
           CASE fgt_weight WHEN 0 THEN NULL ELSE fgt_weightunit END fgt_weightunit, 
           CASE fgt_count WHEN 0 THEN NULL ELSE fgt_count END fgt_count, 
           CASE fgt_count WHEN 0 THEN NULL ELSE fgt_countunit END fgt_countunit, 
           CASE fgt_volume WHEN 0 THEN NULL ELSE fgt_volume END fbc_volume, 
           CASE fgt_volume WHEN 0 THEN NULL ELSE fgt_volumeunit END fgt_volumeunit, 
           CASE fgt_quantity WHEN 0 THEN NULL ELSE fgt_quantity END fgt_quantity, 
           CASE fgt_quantity WHEN 0 THEN NULL ELSE fgt_unit END fgt_unit, 
           scm_subcode, fbc_compartm_number, trailer, wash_status, fbc_compartm_from 
      FROM #freight 
    DROP TABLE #freight
END
ELSE
BEGIN
	INSERT INTO #freight
	    SELECT DISTINCT event.ord_hdrnumber, event.evt_enddate, commodity.cmd_code, commodity.cmd_name, 
	           freightdetail.fgt_weight, freightdetail.fgt_weightunit, freightdetail.fgt_count, freightdetail.fgt_countunit, 
	           freightdetail.fgt_volume, freightdetail.fgt_volumeunit, freightdetail.fgt_quantity, freightdetail.fgt_unit, 
	           CONVERT(VARCHAR(8), '') scm_subcode, CONVERT(INT, NULL) fbc_compartm_number, 
	           CASE WHEN @retrieveby = 'TRL' THEN @stringparm 
	                WHEN stops.lgh_number = @lastleg THEN event.evt_trailer1 
	                WHEN stops.lgh_number = @lastleg2 THEN event.evt_trailer2 
	                WHEN stops.lgh_number = @lastleg3 THEN event.evt_tractor 
	                ELSE '' END trailer, 
	           CASE WHEN @retrieveby = 'TRL' THEN @trl1wash 
	                WHEN stops.lgh_number = @lastleg THEN @trl1wash  
	                WHEN stops.lgh_number = @lastleg2 THEN @trl2wash 
	                ELSE '' END wash_status, 
	           CONVERT(VARCHAR(4), '') fbc_compartm_from 
	      FROM event, 
	           freightdetail,
	           commodity, 
	           stops 
	     WHERE stops.mov_number IN (SELECT DISTINCT mov_number 
	                                  FROM legheader 
	                                 WHERE lgh_number IN (@lastleg, @lastleg2, @lastleg3))
	       AND stops.stp_number = event.stp_number 
	       AND event.evt_pu_dr = 'DRP' 
	       AND event.stp_number = freightdetail.stp_number 
	       AND freightdetail.cmd_code = commodity.cmd_code 
   
    SELECT DISTINCT ord_hdrnumber, evt_enddate, cmd_code, cmd_name, 
           CASE fgt_weight WHEN 0 THEN NULL ELSE fgt_weight END fbc_weight, 
           CASE fgt_weight WHEN 0 THEN NULL ELSE fgt_weightunit END fgt_weightunit, 
           CASE fgt_count WHEN 0 THEN NULL ELSE fgt_count END fgt_count, 
           CASE fgt_count WHEN 0 THEN NULL ELSE fgt_countunit END fgt_countunit, 
           CASE fgt_volume WHEN 0 THEN NULL ELSE fgt_volume END fbc_volume, 
           CASE fgt_volume WHEN 0 THEN NULL ELSE fgt_volumeunit END fgt_volumeunit, 
           CASE fgt_quantity WHEN 0 THEN NULL ELSE fgt_quantity END fgt_quantity, 
           CASE fgt_quantity WHEN 0 THEN NULL ELSE fgt_unit END fgt_unit, 
           scm_subcode, fbc_compartm_number, trailer, wash_status, fbc_compartm_from 
      FROM #freight
END
GO
GRANT EXECUTE ON  [dbo].[d_view_commodity_last_sp2] TO [public]
GO
