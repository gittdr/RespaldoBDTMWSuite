SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_stops_between_legs_sp]
	@to_lgh_number INT      , 
	@asset_type VARCHAR(6)    
AS

DECLARE @asgn_type VARCHAR(6)

DECLARE @leg TABLE ( 
	asset_id           VARCHAR(13)   , 
	asset_type         VARCHAR(6)    , 
	from_lgh_number    INT           , 
	from_lgh_startdate DATETIME      , 
	from_lgh_enddate   DATETIME      , 
	from_stp_number    INT           , 
	from_cmp_id        VARCHAR(8)    , 
	from_city          INT           , 
	from_zip           VARCHAR(10)   , 
	to_lgh_number      INT           , 
	to_lgh_startdate   DATETIME      , 
	to_lgh_enddate     DATETIME      , 
	to_stp_number      INT           , 
	to_cmp_id          VARCHAR(8)    , 
	to_city            INT           , 
	to_zip             VARCHAR(10)   , 
	miles_between      DECIMAL(2)     
) 

-- Check asset type argument and translate into assetassignment asgn_type code
SET @asset_type = 
CASE WHEN @asset_type IN ( 'TRC', 'DRV1', 'DRV1', 'TRL1', 'TRL2' ) 
     THEN @asset_type 
     ELSE 'TRC' 
END 
SET @asgn_type = LEFT( @asset_type, 3 )

-- Get stop info for passed leg
--  * Use assetassignment to generically handle any asset type 
INSERT @leg ( 
	asset_type, asset_id, to_lgh_number, to_lgh_startdate, to_lgh_enddate, 
	to_stp_number, to_cmp_id, to_city, to_zip 
) 
SELECT @asset_type    asset_type       , 
       asgn_id        asset_id         , 
       a.lgh_number   to_lgh_number    , 
       a.asgn_date    to_lgh_startdate , 
       a.asgn_enddate to_lgh_enddate   , 
       s.stp_number   to_stp_number    , 
       s.cmp_id       to_cmp_id        , 
       s.stp_city     to_city          , 
       s.stp_zipcode  to_zip             
  FROM assetassignment a 
       JOIN event e ON a.evt_number = e.evt_number 
       JOIN stops s ON e.stp_number = s.stp_number 
 WHERE e.evt_sequence = 1 AND 
       a.asgn_type = @asgn_type AND 
       a.asgn_id = 
       CASE @asset_type 
            WHEN 'DRV1' THEN evt_driver1 
            WHEN 'DRV2' THEN evt_driver2 
            WHEN 'TRC'  THEN evt_tractor 
            WHEN 'TRL1' THEN evt_trailer1 
            WHEN 'TRL2' THEN evt_trailer2 
       END AND 
       a.lgh_number = @to_lgh_number 

-- Find previous leg (uses dk_assetassignment_assetenddate added w/ this pts)
UPDATE @leg 
   SET from_lgh_number = ( 
       	SELECT TOP 1 a.lgh_number 
       	  FROM assetassignment a 
       	 WHERE a.asgn_type = @asgn_type AND 
       	       a.asgn_id = leg.asset_id AND 
       	       a.lgh_number <> leg.to_lgh_number AND 
       	       a.asgn_enddate IN ( 
       	       	SELECT MAX( asgn_enddate ) 
       	       	  FROM assetassignment a 
       	       	 WHERE a.asgn_type = @asgn_type AND 
       	       	       a.asgn_id = leg.asset_id AND 
       	       	       a.lgh_number <> leg.to_lgh_number AND 
       	       	       a.asgn_enddate <= leg.to_lgh_startdate 
       	       ) 
       	ORDER BY a.asgn_date, a.lgh_number 
       	) 
  FROM @leg leg 

-- Get stop info for previous leg
UPDATE @leg 
   SET from_stp_number    = l.stp_number_end , 
       from_lgh_startdate = l.lgh_startdate  , 
       from_lgh_enddate   = l.lgh_enddate    , 
       from_cmp_id        = s.cmp_id         , 
       from_city          = s.stp_city       , 
       from_zip           = s.stp_zipcode      
  FROM @leg leg 
       JOIN legheader l ON leg.from_lgh_number = l.lgh_number 
       JOIN stops s ON l.stp_number_end = s.stp_number 

SELECT * FROM @leg 

GO
GRANT EXECUTE ON  [dbo].[d_da_stops_between_legs_sp] TO [public]
GO
