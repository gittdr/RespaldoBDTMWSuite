SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_lgh_stops_sp] 
	@lgh_number INTEGER 
AS 

DECLARE @stopfreight TABLE ( 
	mov_number                  INTEGER        NULL , 
	lgh_number                  INTEGER        NULL , 
	stp_number                  INTEGER        NULL , 
	stp_mfh_sequence            INTEGER        NULL , 
	converted_weight            DECIMAL(12,4)  NULL , 
	converted_loadingmeters     DECIMAL(10,2)  NULL , 
	loaded_qty_factor           INTEGER        NULL   
) 

-- Get freight level data for the whole movement (includes all other trip segments)
--  * Converts unit of measure.
--  * Determines whether freight qty is adding or removing freight for each stop on then move, which is 
--    used below to get the running total freight qty loaded at each stop.
INSERT @stopfreight 
SELECT s.mov_number , 
       s.lgh_number , -- can be other segment numbers
       s.stp_number , 
       s.stp_mfh_sequence , 
       
       -------------------------------------------------------------------------------------------------
       -- converted_weight (unit measure: KGS)
       CASE WHEN ISNULL( f.fgt_weightunit, 'KGS' ) = 'KGS' OR ISNULL( u_kgs.unc_factor, 0 ) = 0 
            THEN f.fgt_weight 
            ELSE CONVERT( DECIMAL(12,4), f.fgt_weight * u_kgs.unc_factor ) 
       END converted_weight , 
       
       -------------------------------------------------------------------------------------------------
       -- converted_loadingmeters (unit measure: LDM)
       CASE WHEN ISNULL( f.fgt_loadingmetersunit, 'LDM' ) = 'LDM' OR ISNULL( u_ldm.unc_factor, 0 ) = 0 
            THEN f.fgt_loadingmeters 
            ELSE CONVERT( DECIMAL(12,4), f.fgt_loadingmeters * u_ldm.unc_factor ) 
       END converted_loadingmeters , 
       
       -------------------------------------------------------------------------------------------------
       -- loaded_qty_factor
       CASE WHEN s.stp_type = 'PUP' OR s.stp_event = 'XDL' THEN + 1 
            WHEN s.stp_type = 'DRP' OR s.stp_event = 'XDU' THEN - 1 
            ELSE 0 
       END loaded_qty_factor 
  FROM stops s 
       JOIN freightdetail f ON s.stp_number = f.stp_number 
       JOIN legheader l ON s.mov_number = l.mov_number -- gets all stops on move, needed for loaded qtys calculation below (eliminate duplicate stops for split trips in where clause)
       LEFT JOIN unitconversion u_kgs ON 
            f.fgt_weightunit = u_kgs.unc_from AND 
            u_kgs.unc_to = 'KGS' AND 
            u_kgs.unc_convflag = 'Q' 
       LEFT JOIN unitconversion u_ldm ON 
            f.fgt_loadingmetersunit = u_ldm.unc_from AND 
            u_ldm.unc_to = 'LDM' AND 
            u_ldm.unc_convflag = 'Q' 
 WHERE l.lgh_number = @lgh_number 

-- Return results : Calculate Loaded Qtys, Sum Up Freight Qtys to Stop Level
  SELECT s.lgh_number , 
         s.ord_hdrnumber , 
         s.stp_number , 
         s.stp_event , 
         s.stp_arrivaldate , 
         s.stp_status , 
         s.stp_departuredate , 
         e.evt_driver1 , 
         e.evt_tractor , 
         e.evt_trailer1 , 
         e.evt_trailer2 , 
         ec.name event_name , 
         s.stp_mfh_sequence , 
         c.cmp_id , 
         c.cmp_name , 
         s.stp_city , 
         s.stp_zipcode , 
         t.cty_nmstct , 
         ( SELECT SUM( sf.converted_weight * sf.loaded_qty_factor ) 
             FROM @stopfreight sf 
            WHERE s.stp_number = sf.stp_number 
         ) converted_weight , 
         CASE s1.stp_loadstatus 
            WHEN 'BT' THEN 0.0 -- if bobtail then no trailer and no qty loaded
            ELSE -- sum up qty changes for each stop and all its previous stops on move
                 ( SELECT SUM( sf.converted_weight * sf.loaded_qty_factor ) 
                     FROM @stopfreight sf 
                    WHERE sf.stp_mfh_sequence <= s.stp_mfh_sequence ) 
         END loaded_weight , 
         ( SELECT SUM( converted_loadingmeters * sf.loaded_qty_factor ) 
             FROM @stopfreight sf 
            WHERE s.stp_number = sf.stp_number 
         ) converted_loadingmeters , 
         CASE s1.stp_loadstatus 
            WHEN 'BT' THEN 0.0 -- if bobtail then no trailer and no qty loaded
            ELSE ( SELECT SUM( sf.converted_loadingmeters * sf.loaded_qty_factor ) 
                     FROM @stopfreight sf 
                    WHERE sf.stp_mfh_sequence <= s.stp_mfh_sequence ) 
         END loaded_loadingmeters , 
         t1.trl_capacity_wgt trl1_capacity_wgt , 
         t1.trl_capacity_ldm trl1_capacity_ldm , 
         t2.trl_capacity_wgt trl2_capacity_wgt , 
         t2.trl_capacity_ldm trl2_capacity_ldm   
    FROM stops s 
         JOIN event          e  ON s.stp_number = e.stp_number 
         JOIN company        c  ON s.cmp_id = c.cmp_id 
         JOIN city           t  ON s.stp_city = t.cty_code 
         JOIN trailerprofile t1 ON e.evt_trailer1 = t1.trl_id 
         JOIN trailerprofile t2 ON e.evt_trailer2 = t2.trl_id 
         JOIN eventcodetable ec ON e.evt_eventcode = ec.abbr 
         LEFT JOIN stops s1     ON s.lgh_number = s1.lgh_number AND s.stp_mfh_sequence = s1.stp_mfh_sequence - 1 
         -- need stp_loadstatus on next stop (for mileage, which goes stop 2,3,n and ignore the 1st stop - but loaded qty here goes 1,2,3,n-1 and ignores the last stop)
   WHERE e.evt_sequence = 1 AND 
         s.lgh_number = @lgh_number 
ORDER BY s.stp_mfh_sequence 
GO
GRANT EXECUTE ON  [dbo].[d_da_lgh_stops_sp] TO [public]
GO
