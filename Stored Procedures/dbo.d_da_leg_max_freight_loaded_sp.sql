SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_leg_max_freight_loaded_sp] 
	@lgh_number INTEGER 
AS

DECLARE @stpfgtconv TABLE ( 
	kgs_weight            DECIMAL(12,4) , 
	ldm_loadingmeters     DECIMAL(10,2) , 
	stp_number            INTEGER       , 
	stp_mfh_sequence      INTEGER       , 
	fgt_sequence          INTEGER       , 
	mov_number            INTEGER       , 
	stp_type              VARCHAR(6)    , 
	stp_event             CHAR(6)       , 
	fgt_weight            DECIMAL(12,4) , 
	fgt_weightunit        VARCHAR(6)    , 
	fgt_loadingmeters     DECIMAL(10,2) , 
	fgt_loadingmetersunit VARCHAR(6)    , 
	kgs_unc_factor        FLOAT         , 
	ldm_unc_factor        FLOAT           
) 
INSERT @stpfgtconv 
SELECT CASE WHEN ISNULL( f.fgt_weightunit, 'KGS' ) = 'KGS' OR ISNULL( u_kgs.unc_factor, 0 ) = 0 
            THEN f.fgt_weight 
            ELSE CONVERT( DECIMAL(12,4), f.fgt_weight * u_kgs.unc_factor ) END kgs_weight , 
       CASE WHEN ISNULL( f.fgt_loadingmetersunit, 'LDM' ) = 'LDM' OR ISNULL( u_ldm.unc_factor, 0 ) = 0
            THEN f.fgt_loadingmeters 
            ELSE CONVERT( DECIMAL(10,4), f.fgt_loadingmeters * u_ldm.unc_factor ) END ldm_loadingmeters , 
       s.stp_number , 
       s.stp_mfh_sequence , 
       f.fgt_sequence , 
       s.mov_number , 
       s.stp_type , 
       s.stp_event , 
       f.fgt_weight , 
       f.fgt_weightunit , 
       f.fgt_loadingmeters , 
       f.fgt_loadingmetersunit , 
       u_kgs.unc_factor kgs_unc_factor , 
       u_ldm.unc_factor ldm_unc_factor 
  FROM legheader l 
       JOIN stops s ON l.mov_number = s.mov_number 
       JOIN freightdetail f ON s.stp_number = f.stp_number 
       LEFT JOIN unitconversion u_kgs ON 
            f.fgt_weightunit = u_kgs.unc_from AND 
            u_kgs.unc_to = 'KGS' AND 
            u_kgs.unc_convflag = 'Q' 
       LEFT JOIN unitconversion u_ldm ON 
            f.fgt_loadingmetersunit = u_ldm.unc_from AND 
            u_ldm.unc_to = 'LDM' AND 
            u_ldm.unc_convflag = 'Q' 
 WHERE l.lgh_number = @lgh_number AND 
       ( stp_type IN ( 'PUP', 'DRP' ) OR stp_event IN ( 'XDL', 'XDU' ) ) 

-- Build a table with the running sum of freight quantities across the trip segment's whole move.
-- This is a freight level table that shows the total quantity loaded on a trip's trailers at each freight row.
DECLARE @fgtcurrent TABLE ( 
	lgh_number            INTEGER       , 
	cur_weight            DECIMAL(12,4) , 
	cur_loadingmeters     DECIMAL(10,2)   
) 
INSERT @fgtcurrent 
SELECT s.lgh_number, 
       ( SELECT SUM( CASE WHEN sfc.stp_type = 'PUP' OR sfc.stp_event = 'XDL' THEN + sfc.kgs_weight 
                          WHEN sfc.stp_type = 'DRP' OR sfc.stp_event = 'XDU' THEN - sfc.kgs_weight 
                          ELSE 0 END ) 
           FROM @stpfgtconv sfc 
          WHERE sfc.mov_number = s.mov_number AND 
                ( ( sfc.stp_mfh_sequence < s.stp_mfh_sequence ) OR 
                  ( sfc.stp_mfh_sequence = s.stp_mfh_sequence AND sfc.fgt_sequence <= f.fgt_sequence ) 
                ) 
       ) cur_weight , 
       ( SELECT SUM( CASE WHEN sfc.stp_type = 'PUP' OR sfc.stp_event = 'XDL' THEN + sfc.fgt_loadingmeters 
                          WHEN sfc.stp_type = 'DRP' OR sfc.stp_event = 'XDU' THEN - sfc.fgt_loadingmeters 
                          ELSE 0 END ) 
           FROM @stpfgtconv sfc 
          WHERE sfc.mov_number = s.mov_number AND 
                ( ( sfc.stp_mfh_sequence < s.stp_mfh_sequence ) OR 
                  ( sfc.stp_mfh_sequence = s.stp_mfh_sequence AND sfc.fgt_sequence <= f.fgt_sequence ) 
                ) 
       ) cur_loadingmeters 
  FROM legheader l 
       JOIN stops s ON l.mov_number = s.mov_number 
       JOIN freightdetail f ON s.stp_number = f.stp_number 
 WHERE l.lgh_number = @lgh_number 
 ORDER BY s.stp_mfh_sequence, f.fgt_sequence 

SELECT MAX( cur_weight ) max_weight , 
       MAX( cur_loadingmeters ) max_loadingmeters 
  FROM @fgtcurrent 
 WHERE lgh_number = @lgh_number 

--select * from @stpfgtconv order by stp_mfh_sequence , fgt_sequence 
--select * from @fgtcurrent 

GO
GRANT EXECUTE ON  [dbo].[d_da_leg_max_freight_loaded_sp] TO [public]
GO
