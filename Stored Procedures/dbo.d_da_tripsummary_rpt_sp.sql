SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_tripsummary_rpt_sp] 
   @LGH_NUMBER INT
AS

DECLARE @trip TABLE ( 
/* 01 */   ord_hdrnumber        INT            , 
/* 02 */   lgh_number           INT            , 
/* 03 */   stp_number           INT            , 
/* 04 */   stp_mfh_sequence     INT            , 
/* 05 */   stp_event            CHAR(6)        , 
/* 06 */   stp_status           VARCHAR(6)     , 
/* 07 */   cmp_id               VARCHAR(8)     , 
/* 08 */   cmp_name             VARCHAR(30)    , 
/* 09 */   cty_name             VARCHAR(18)    , 
/* 10 */   stp_state            VARCHAR(6)     , 
/* 11 */   stp_zipcode          VARCHAR(10)    , 
/* 12 */   evt_trailer1         VARCHAR(13)    , 
/* 13 */   stp_comment          VARCHAR(254)   , 
/* 14 */   stp_departure_status VARCHAR(6)     , 
/* 15 */   stp_schdtearliest    DATETIME       , 
/* 16 */   stp_schdtlatest      DATETIME       , 
/* 17 */   stp_arrivaldate      DATETIME       , 
/* 18 */   stp_departuredate    DATETIME       , 
/* 19 */   ord_number           INT            , 
/* 20 */   TotalCharges         FLOAT          , 
/* 21 */   ord_refnum           VARCHAR(30)    , 
/* 22 */   loaded_miles         INT            , 
/* 23 */   empty_miles          INT            , 
/* 24 */   lgh_fgt_description  VARCHAR(60)    , 
/* 25 */   ord_remark           VARCHAR(254)   , 
/* 26 */   stp_ord_hdrnumber    INT            , 
/* 27 */   fgt_description      VARCHAR(30)    , 
/* 28 */   fgt_volume           FLOAT          , 
/* 29 */   fgt_volumeunit       VARCHAR(6)     , 
/* 30 */   fgt_weight           FLOAT          , 
/* 31 */   fgt_weightunit       VARCHAR(6)     , 
/* 32 */   fgt_count            DECIMAL(10,2)  , 
/* 33 */   fgt_countunit        VARCHAR(6)     , 
/* 34 */   fgt_sequence         INT              
) 

INSERT @trip 
   SELECT l.ord_hdrnumber , 
          l.lgh_number , 
          s.stp_number , 
          s.stp_mfh_sequence , 
          s.stp_event , 
          s.stp_status , 
          s.cmp_id , 
          s.cmp_name , 
          c.cty_name , 
          s.stp_state , 
          s.stp_zipcode , 
          e.evt_trailer1 , 
          s.stp_comment , 
          s.stp_departure_status , 
          s.stp_schdtearliest , 
          s.stp_schdtlatest , 
          s.stp_arrivaldate , 
          s.stp_departuredate , 
          CASE o.ord_hdrnumber WHEN 0 THEN 'Empty Move' ELSE o.ord_number END ord_number , 
          ( SELECT SUM( ord_totalcharge ) FROM orderheader WHERE orderheader.mov_number = l.mov_number ) TotalCharges , 
          CASE WHEN o.ord_refnum > '' THEN o.ord_refnum ELSE '' END ord_refnum , 
          ISNULL( ( SELECT SUM( ISNULL( stp_lgh_mileage, 0 ) )   
                     FROM stops 
                    WHERE stp_loadstatus = 'LD' AND 
                          lgh_number = l.lgh_number ) 
          , 0 ) loaded_miles , 
          ISNULL( ( SELECT SUM( ISNULL( stp_lgh_mileage, 0 ) ) 
                      FROM stops 
                     WHERE ISNULL( stp_loadstatus, '' ) <> 'LD' AND 
                           lgh_number = l.lgh_number ) 
          , 0 ) empty_miles , 
          l.fgt_description lgh_fgt_description , 
          o.ord_remark ,  
          s.ord_hdrnumber stp_ord_hdrnumber , 
          f.fgt_description , 
          f.fgt_volume , 
          f.fgt_volumeunit , 
          f.fgt_weight , 
          f.fgt_weightunit , 
          f.fgt_count , 
          f.fgt_countunit , 
          f.fgt_sequence 
     FROM legheader l   
          LEFT OUTER JOIN orderheader o ON l.ord_hdrnumber = o.ord_hdrnumber   
          JOIN stops s ON s.lgh_number = l.lgh_number   
          JOIN city c ON s.stp_city = c.cty_code   
          JOIN event e ON s.stp_number = e.stp_number AND e.evt_sequence = 1   
          JOIN freightdetail f ON f.stp_number = s.stp_number   
    WHERE l.lgh_number = @lgh_number   
 ORDER BY s.stp_mfh_sequence , 
          f.fgt_sequence 

UPDATE @trip 
   SET ord_refnum = 'N/A' 
 WHERE ord_refnum IS NULL OR 
       RTRIM( ord_refnum ) = '' 

-- Set the following to NULL so auto-size and slide up work in the datawindow display

UPDATE @trip 
   SET ord_remark = NULL 
 WHERE ord_remark IS NULL OR 
       RTRIM( ord_remark ) = '' 

UPDATE @trip 
   SET lgh_fgt_description = NULL 
 WHERE lgh_fgt_description = 'UNKNOWN' OR 
       lgh_fgt_description IS NULL OR 
       RTRIM( lgh_fgt_description ) = '' 

UPDATE @trip 
   SET fgt_description = NULL 
 WHERE ISNULL( stp_ord_hdrnumber, 0 ) = 0 

UPDATE @trip 
   SET ord_hdrnumber        = NULL , 
       lgh_number           = NULL , 
       ord_number           = NULL , 
       TotalCharges         = NULL , 
       ord_refnum           = NULL , 
       loaded_miles         = NULL , 
       empty_miles          = NULL , 
       lgh_fgt_description  = NULL , 
       ord_remark           = NULL   
 WHERE stp_mfh_sequence > ( SELECT MIN( stp_mfh_sequence ) FROM @trip ) -- use MIN() for split trips

UPDATE @trip 
   SET stp_event            = NULL , 
       stp_status           = NULL , 
       stp_departure_status = NULL , 
       stp_schdtearliest    = NULL , 
       stp_schdtlatest      = NULL , 
       stp_arrivaldate      = NULL , 
       stp_departuredate    = NULL , 
       cmp_id               = NULL , 
       cmp_name             = NULL , 
       cty_name             = NULL , 
       stp_state            = NULL , 
       stp_zipcode          = NULL , 
       evt_trailer1         = NULL , 
       stp_comment          = NULL   
 WHERE fgt_sequence > 1 

SELECT * FROM @trip

GO
GRANT EXECUTE ON  [dbo].[d_da_tripsummary_rpt_sp] TO [public]
GO
