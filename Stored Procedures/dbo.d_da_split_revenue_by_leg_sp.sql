SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_split_revenue_by_leg_sp] ( @lgh_number INTEGER ) 
AS

DECLARE @ord INTEGER , 
        @mov_number INTEGER , 
        @gi_string1 VARCHAR(60) , 
        @DistCostRate MONEY , 
        @HourlyCostRate MONEY 

DECLARE @orders TABLE ( 
	ord_hdrnumber               INTEGER       NULL , 
	ord_totalcharge             MONEY         NULL , 
	ord_currency                VARCHAR(6)    NULL , 
	ord_currencydate            DATETIME      NULL , 
	first_stop                  INTEGER       NULL , 
	last_stop                   INTEGER       NULL , 
	lgh_miles                   INTEGER       NULL , 
	total_lgh_miles             INTEGER       NULL , 
	pct_lgh_miles               DECIMAL(19,6) NULL , 
	split_ord_totalcharge_miles MONEY         NULL , 
	lgh_startdate               DATETIME      NULL , 
	lgh_enddate                 DATETIME      NULL , 
	trc_distancecost_rate       MONEY         NULL , 
	trc_costperhour             MONEY         NULL , 
	trip_hours                  DECIMAL(13,4) NULL , 
	distance_cost               MONEY         NULL , 
	time_cost                   MONEY         NULL , 
	tractor_cost                MONEY         NULL , 
	avg_trc_distancecost_rate   MONEY         NULL , 
	avg_trc_costperhour         MONEY         NULL , 
	total_trip_hours            DECIMAL(13,4) NULL , 
	total_distance_cost         MONEY         NULL , 
	total_time_cost             MONEY         NULL , 
	total_tractor_cost          MONEY         NULL , 
	pct_tractor_cost            DECIMAL(19,6) NULL , 
	split_ord_totalcharge_cost  MONEY         NULL   
) 
DECLARE @ordmoves TABLE ( 
	ord_hdrnumber INTEGER NULL , 
	mov_number    INTEGER NULL , 
	first_stop    INTEGER NULL ,
	last_stop     INTEGER NULL  
) 
DECLARE @ordlegs TABLE ( 
	ord_hdrnumber         INTEGER       NULL , 
	lgh_number            INTEGER       NULL , 
	lgh_miles             INTEGER       NULL , 
	lgh_tractor           VARCHAR(8)    NULL , 
	trip_hours            DECIMAL(13,4) NULL , 
	trc_distancecost_rate MONEY         NULL , 
	trc_costperhour       MONEY         NULL , 
	distance_cost         MONEY         NULL , 
	time_cost             MONEY         NULL , 
	lgh_startdate         DATETIME      NULL , 
	lgh_enddate           DATETIME      NULL   
) 

SET NOCOUNT ON

-- =====================================================================================================
-- First, determine the orders passing through this leg (i.e., have a pickup before or within and drop 
-- after or within this leg).  Then, get all legs (both within and outside this move) these orders pass 
-- through.
-- ( Important: "pass through" means the leg does not actually need to have an order stop explicity 
--   assigned to it.  It means freight for an order is carried over a leg. )
-- =====================================================================================================

-- Get the move number on this leg
SELECT @mov_number = mov_number FROM legheader WHERE lgh_number = @lgh_number 

-- Get the default tractor distance cost
SELECT @gi_string1 = gi_string1 FROM generalinfo WHERE gi_name = 'DefTrcDistCostRate'
SELECT @DistCostRate = CASE ISNUMERIC( @gi_string1 ) WHEN 1 THEN CAST( @gi_string1 AS MONEY ) ELSE 0.95 END 

-- Get the default tractor hourly cost
SELECT @gi_string1 = gi_string1 FROM generalinfo WHERE gi_name = 'DefTrcDistCostPerHour'
SELECT @HourlyCostRate = CASE ISNUMERIC( @gi_string1 ) WHEN 1 THEN CAST( @gi_string1 AS MONEY ) ELSE 40.0 END 

-- Get all orders on move, determine fist and last stop for each order
INSERT @orders ( ord_hdrnumber, ord_totalcharge, ord_currency, ord_currencydate, first_stop, last_stop ) 
SELECT o.ord_hdrnumber, o.ord_totalcharge, o.ord_currency, o.ord_currencydate, s.first_stop, s.last_stop 
  FROM orderheader o 
       JOIN ( 
       	SELECT ord_hdrnumber, MIN( stp_mfh_sequence ) first_stop, MAX( stp_mfh_sequence ) last_stop 
       	  FROM stops 
       	 WHERE mov_number = @mov_number 
       	GROUP BY ord_hdrnumber 
       ) s ON o.ord_hdrnumber = s.ord_hdrnumber 

-- Restrict orders to only those orders passing through this leg 
-- ...remove orders whose first pickup or last drop occurs before or after this leg
DELETE @orders 
  FROM @orders o 
       CROSS JOIN ( 
       	SELECT l.lgh_number, MIN( s.stp_mfh_sequence ) first_stop, MAX( s.stp_mfh_sequence ) last_stop
       	  FROM legheader l 
       	       JOIN stops s ON s.lgh_number = l.lgh_number 
       	 WHERE l.lgh_number = @lgh_number 
       	GROUP BY l.lgh_number 
       ) l -- 1st and last stops for this leg
 WHERE o.first_stop > l.last_stop OR o.last_stop < l.first_stop 

-- Get all moves each of these orders exists on, determine their first and last stops
INSERT @ordmoves ( ord_hdrnumber, mov_number, first_stop, last_stop ) 
SELECT o.ord_hdrnumber, s.mov_number, MIN( s.stp_mfh_sequence ) first_stop, MAX( s.stp_mfh_sequence ) last_stop 
  FROM stops s 
       JOIN @orders o ON s.ord_hdrnumber = o.ord_hdrnumber 
GROUP BY s.mov_number, o.ord_hdrnumber 

-- Get all legs each of these orders passes through
INSERT @ordlegs ( ord_hdrnumber, lgh_number ) 
SELECT m.ord_hdrnumber, s.lgh_number 
  FROM @ordmoves m 
       JOIN stops s ON m.mov_number = s.mov_number 
 WHERE s.stp_mfh_sequence >= m.first_stop AND s.stp_mfh_sequence <= m.last_stop 
GROUP BY s.lgh_number, m.ord_hdrnumber 

-- =====================================================================================================
-- Calculate the order revenue to be allocated to this leg. 
-- =====================================================================================================

-- Two methods: 
-- (1) Distance based - Allocate based on the ratio of trip miles on this leg to the sum of all trip 
-- miles on all legs each order passes through. 
-- (2) Cost based - (Vanderwal Method) Estimate the cost of this leg using the tractor profile distance 
-- and hourly cost rates.  Use the trip miles for the distance cost rate, and the time between the 
-- trip's start and end dates for the hourly cost rate.  The sum of these is the cost estimate for this 
-- leg.  Do the same for all the legs each order passing through this leg passes through.  Allocate 
-- based on the ratio this trip's cost to the sum of all these trip's costs.

-- Get leg level revenue split info 
-- ... from legheader
UPDATE @ordlegs 
   SET lgh_miles     = l.lgh_miles , 
       lgh_startdate = l.lgh_startdate , 
       lgh_enddate   = l.lgh_enddate , 
       lgh_tractor   = l.lgh_tractor , 
       trip_hours    = CAST( DATEDIFF( SECOND, l.lgh_startdate, l.lgh_enddate ) AS DECIMAL(13,4) ) / 3600 
  FROM @ordlegs o 
       JOIN legheader l ON o.lgh_number = l.lgh_number 
-- ... from tractor profile
UPDATE @ordlegs 
   SET trc_distancecost_rate = CASE ISNULL( t.trc_distancecost_rate, 0 ) WHEN 0 THEN @DistCostRate    ELSE t.trc_distancecost_rate END , 
       trc_costperhour       = CASE ISNULL( t.trc_costperhour      , 0 ) WHEN 0 THEN @HourlyCostRate  ELSE t.trc_costperhour       END   
  FROM @ordlegs o 
       JOIN tractorprofile t ON o.lgh_tractor = t.trc_number 
UPDATE @ordlegs 
   SET distance_cost = trc_distancecost_rate * lgh_miles  , 
       time_cost     = trc_costperhour       * trip_hours   

-- Set order level revenue split info
-- ... for this leg only
UPDATE @orders 
   SET lgh_miles             = l.lgh_miles , 
       lgh_startdate         = l.lgh_startdate , 
       lgh_enddate           = l.lgh_enddate , 
       trc_distancecost_rate = l.trc_distancecost_rate , 
       trc_costperhour       = l.trc_costperhour , 
       trip_hours            = l.trip_hours , 
       distance_cost         = l.distance_cost , 
       time_cost             = l.time_cost , 
       tractor_cost          = l.distance_cost + l.time_cost 
  FROM @orders o 
       JOIN @ordlegs l ON o.ord_hdrnumber = l.ord_hdrnumber 
 WHERE l.lgh_number = @lgh_number 
-- ... for all legs of the orders
UPDATE @orders 
   SET total_lgh_miles           = l.sum_lgh_miles , 
       avg_trc_distancecost_rate = l.avg_trc_distancecost_rate , 
       avg_trc_costperhour       = l.avg_trc_costperhour , 
       total_trip_hours          = l.sum_trip_hours , 
       total_distance_cost       = l.sum_distance_cost , 
       total_time_cost           = l.sum_time_cost , 
       total_tractor_cost        = l.sum_distance_cost + sum_time_cost 
  FROM @orders o 
       JOIN ( 
       	SELECT ord_hdrnumber , 
       	       SUM( lgh_miles             ) sum_lgh_miles , 
       	       AVG( trc_distancecost_rate ) avg_trc_distancecost_rate , 
       	       AVG( trc_costperhour       ) avg_trc_costperhour , 
       	       SUM( trip_hours            ) sum_trip_hours , 
       	       SUM( distance_cost         ) sum_distance_cost , 
       	       SUM( time_cost             ) sum_time_cost 
       	  FROM @ordlegs 
       	GROUP BY ord_hdrnumber 
       ) l ON o.ord_hdrnumber = l.ord_hdrnumber 

-- Calculate percent allocations (by mile and by cost estimation) and final order split amounts
UPDATE @orders 
   SET pct_lgh_miles = CASE WHEN total_lgh_miles > 0 THEN CAST( lgh_miles AS DECIMAL(13,2) ) / CAST( total_lgh_miles AS DECIMAL(13,2) ) ELSE 1.0 END , 
       pct_tractor_cost = CASE WHEN total_tractor_cost > 0 THEN tractor_cost / total_tractor_cost ELSE 1.0 END 
-- SET pct_lgh_miles = CAST( lgh_miles AS DECIMAL(13,2) ) / CAST( total_lgh_miles AS DECIMAL(13,2) ) , 
--     pct_tractor_cost = tractor_cost / total_tractor_cost 
  FROM @orders o 
UPDATE @orders 
   SET split_ord_totalcharge_miles = ord_totalcharge * pct_lgh_miles , 
       split_ord_totalcharge_cost = ord_totalcharge * pct_tractor_cost 
  FROM @orders o 

SET NOCOUNT ON

SELECT @lgh_number lgh_number      , 
       ord_hdrnumber               , 
       ord_totalcharge             , 
       split_ord_totalcharge_miles , 
       split_ord_totalcharge_cost  , 
       ord_currency                , 
       ord_currencydate            , 
       lgh_miles                   , 
       total_lgh_miles             , 
       pct_lgh_miles               , 
       lgh_startdate               , 
       lgh_enddate                 , 
       trc_distancecost_rate       , 
       trc_costperhour             , 
       trip_hours                  , 
       distance_cost               , 
       time_cost                   , 
       tractor_cost                , 
       avg_trc_distancecost_rate   , 
       avg_trc_costperhour         , 
       total_trip_hours            , 
       total_distance_cost         , 
       total_time_cost             , 
       total_tractor_cost          , 
       pct_tractor_cost              
  FROM @orders 

GO
GRANT EXECUTE ON  [dbo].[d_da_split_revenue_by_leg_sp] TO [public]
GO
