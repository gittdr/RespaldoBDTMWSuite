SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_sortclosest_sp] 
	@lgh_number INT 
AS

DECLARE @lgh TABLE ( 
	legheader_lgh_number   INT           NULL , 
	orderheader_ord_number CHAR(12)      NULL , 
	bookedby               CHAR(20)      NULL , 
	event_evt_tractor      VARCHAR(8)    NULL , 
	d_cmpid                VARCHAR(8)    NULL , 
	d_city                 INT           NULL , 
	d_ctyname              VARCHAR(25)   NULL , 
	dest_cmp_lat           DECIMAL(14,6) NULL , 
	dest_cmp_long          DECIMAL(14,6) NULL , 
	dest_cty_lat           DECIMAL(14,6) NULL , --PTS92864
	dest_cty_long          DECIMAL(14,6) NULL , 
	l_cmpid                VARCHAR(8)    NULL , 
	l_ctycode              INT           NULL , 
	l_ctyname              VARCHAR(30)   NULL , 
	legheader_mov_number   INT           NULL   
) 

DECLARE @UseShowAsShipperConsignee CHAR(1), @citylatlongunits char (1)

select @citylatlongunits = Left (LTrim (ISNull (gi_string1, 'N')), 1) from generalinfo where gi_name = 'CityLatLongUnits'

SELECT @UseShowAsShipperConsignee = ISNULL( LEFT( UPPER( gi_string1 ), 1 ), 'N' ) 
  FROM generalinfo 
 WHERE gi_name = 'UseShowAsShipperConsignee' 

INSERT @lgh ( 
       legheader_lgh_number, orderheader_ord_number, bookedby, event_evt_tractor, d_cmpid, d_city, 
       d_ctyname, dest_cmp_lat, dest_cmp_long, dest_cty_lat, dest_cty_long, l_cmpid, l_ctycode , 
       legheader_mov_number 
       ) 
SELECT l.lgh_number                               legheader_lgh_number   ,   
       CONVERT( VARCHAR(22), o.ord_hdrnumber )    orderheader_ord_number , -- planning worksheet sort uses this as ord_hdrnumber in string  
       ISNULL( o.ord_bookedby, '' )               bookedby               ,   
       l.lgh_tractor                              event_evt_tractor      , -- client overrides this by whatever asset type is being sorted  
       -- Destination Location Info
       c.cmp_id            d_cmpid                , 
       l.lgh_endcity       d_city                 , 
       l.lgh_endcty_nmstct d_ctyname              , 
       ROUND( ISNULL( c.cmp_latseconds, 0.0000 ) / 3600.000, 6 ) dest_cmp_lat , 
       ROUND( ISNULL( c.cmp_longseconds, 0.0000 ) / 3600.000, 6 ) dest_cmp_long , 
       case @citylatlongunits when 'S' then ISNULL( t.cty_latitude/3600.0, 0.0000 ) else ISNULL( t.cty_latitude, 0.0000 ) end dest_cty_lat , 
       case @citylatlongunits when 'S' then ISNULL( t.cty_longitude/3600.0, 0.0000 ) else ISNULL( t.cty_longitude, 0.0000 ) end dest_cty_long , 
       ( CASE WHEN @UseShowAsShipperConsignee = 'Y' 
         AND o.ord_destpoint <> o.ord_showcons AND o.ord_showcons <> 'UNKNOWN' AND o.ord_showcons IS NOT NULL 
         THEN o.ord_showcons 
         ELSE o.ord_destpoint END 
       ) l_cmpid , 
       ( CASE WHEN @UseShowAsShipperConsignee = 'Y' 
         AND o.ord_destpoint <> o.ord_showcons AND o.ord_showcons <> 'UNKNOWN' AND o.ord_showcons IS NOT NULL 
         THEN ( SELECT cmp_city FROM company WHERE cmp_id = ord_showcons ) 
         ELSE o.ord_destcity END 
       ) l_ctycode , 
       l.mov_number 
  FROM legheader_active l 
       LEFT OUTER JOIN orderheader o ON l.ord_hdrnumber = o.ord_hdrnumber AND o.ord_hdrnumber <> 0   
       JOIN company c ON l.cmp_id_end = c.cmp_id   
       JOIN city t ON l.lgh_endcity = t.cty_code   
 WHERE l.lgh_number = @lgh_number 

-- Update last loaded city
UPDATE @lgh 
   SET l_ctyname = city_l.cty_nmstct 
  FROM @lgh l 
       LEFT JOIN city city_l ON l.l_ctycode  = city_l.cty_code

SELECT * FROM @lgh 

GO
GRANT EXECUTE ON  [dbo].[d_da_sortclosest_sp] TO [public]
GO
