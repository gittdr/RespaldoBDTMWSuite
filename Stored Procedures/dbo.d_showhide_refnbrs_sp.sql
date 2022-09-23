SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_showhide_refnbrs_sp] ( @lgh_number INTEGER ) 
AS 

DECLARE @refs TABLE ( 
	ord_hdrnumber       INTEGER      , 
	ref_typedesc        VARCHAR(20)  , 
	ref_type            VARCHAR(6)   , 
	ref_number          VARCHAR(30)  , 
	stp_event           VARCHAR(6)   , 
	cmp_id              VARCHAR(8)   , 
	stp_city            INTEGER      , 
	cty_nmstct          VARCHAR(30)  , 
	cmd_code            VARCHAR(8)   , 
	fgt_description     VARCHAR(60)  , 
	ord_number          VARCHAR(12)  , 
	ord_billto          VARCHAR(8)   , 
	lgh_number          INTEGER      , 
	stp_number          INTEGER      , 
	fgt_number          INTEGER      , 
	ord_seq             INTEGER      , 
	leg_seq             INTEGER      , 
	stp_seq             INTEGER      , 
	stp_mfh_sequence    INTEGER      , 
	stp_sequence        INTEGER      , 
	stp_nonord_sequence INTEGER      , 
	stp_xdoc_sequence   INTEGER      , 
	fgt_sequence        INTEGER      , 
	ref_sequence        INTEGER      , 
	ref_table           VARCHAR(18)  , 
	ref_description     VARCHAR(255)   
) 

DECLARE @stops TABLE ( 
	stp_number          INTEGER    , 
	ord_hdrnumber       INTEGER    , 
	lgh_number          INTEGER    , 
	stp_mfh_sequence    INTEGER    , 
	stp_sequence        INTEGER    , 
	stp_nonord_sequence INTEGER    , 
	stp_xdoc_sequence   INTEGER    , 
	stp_event           VARCHAR(6) , 
	cmp_id              VARCHAR(8) , 
	stp_city            INTEGER      
) 

DECLARE @orders TABLE ( 
	ord_hdrnumber INTEGER     , 
	first_stop    INTEGER     , 
	ord_number    VARCHAR(12) , 
	ord_billto    VARCHAR(8)   
) 

DECLARE @leg TABLE ( 
	lgh_number INTEGER , 
	first_stop INTEGER , 
	last_stop  INTEGER   
) 

-- ===============================================================================================================
-- Get trip data

-- Stops - GET ALL STOPS ON MOVE, get all stop table info
INSERT @stops ( stp_number , ord_hdrnumber , lgh_number , stp_mfh_sequence , stp_sequence , stp_event , cmp_id , 
stp_city 
) 
SELECT s.stp_number , 
       s.ord_hdrnumber , 
       s.lgh_number , 
       s.stp_mfh_sequence , 
       s.stp_sequence , 
       s.stp_event , 
       s.cmp_id , 
       s.stp_city 
  FROM stops s 
       JOIN legheader l ON s.mov_number = l.mov_number 
 WHERE l.lgh_number = @lgh_number 

-- Leg - determine first and last stops
INSERT @leg ( lgh_number , first_stop , last_stop 
) 
SELECT lgh_number , 
       MIN( stp_mfh_sequence ) , 
       MAX( stp_mfh_sequence ) 
  FROM @stops 
 WHERE lgh_number = @lgh_number 
GROUP BY lgh_number 

-- Orders - get only orders whose freight passes through the leg (i.e. have a PU before last leg stop or a DRP after the first leg stop)
INSERT @orders ( ord_hdrnumber , first_stop , ord_number , ord_billto 
) 
SELECT movords.ord_hdrnumber , 
       movords.first_stop , 
       RTRIM( o.ord_number ) , 
       o.ord_billto 
  FROM @leg l 
       CROSS JOIN ( 
       	SELECT ord_hdrnumber , 
       	       MIN( stp_mfh_sequence ) first_stop , 
       	       MAX( stp_mfh_sequence ) last_stop 
       	  FROM @stops 
       	 WHERE ord_hdrnumber > 0 
       	GROUP BY ord_hdrnumber 
       ) movords 
       JOIN orderheader o ON movords.ord_hdrnumber = o.ord_hdrnumber 
 WHERE l.last_stop >= movords.first_stop AND 
       l.first_stop <= movords.last_stop 

-- Set the stop sequence for non-order stops - skip order-based stops, start counting at 1st stop on seg - 1st non-order stop on seg is 1, 
-- 2nd non-order stop on seq is 2, 3rd is 3, etc.
UPDATE @stops 
   SET stp_nonord_sequence = ( 
       	SELECT COUNT( * ) 
       	  FROM @stops s1 
       	       JOIN @leg l ON s1.lgh_number = l.lgh_number 
       	 WHERE s1.stp_mfh_sequence <= s.stp_mfh_sequence AND 
       	       ISNULL( s1.ord_hdrnumber, 0 ) <= 0 
       	) 
  FROM @stops s 
 WHERE ISNULL( s.ord_hdrnumber, 0 ) <= 0 

-- Determine the sequence of crossdock stops within each order.  Sort these after the regular order-based stops.
UPDATE @stops 
   SET stp_xdoc_sequence = ( 
       	SELECT COUNT( * ) 
       	  FROM @stops s1 
       	       JOIN @leg l ON s1.lgh_number = l.lgh_number 
       	       JOIN @orders o ON s1.ord_hdrnumber = o.ord_hdrnumber 
       	 WHERE s1.stp_mfh_sequence <= s.stp_mfh_sequence AND 
       	       stp_event IN ( 'XDU' , 'XDL' ) 
       	) , 
       stp_sequence = l.last_stop + 1 
  FROM @stops s 
       JOIN @leg l ON s.lgh_number = s.lgh_number 
 WHERE stp_event IN ( 'XDU' , 'XDL' ) 

-- select * from @stops 
-- select * from @orders
-- select * from @leg


-- ===============================================================================================================
-- Get reference number data

-- Stop Reference Numbers - restrict to this leg
INSERT @refs ( ref_table , ref_type , ref_number , ref_sequence ,  stp_number , ord_hdrnumber , lgh_number , cty_nmstct 
) 
SELECT r.ref_table , 
       r.ref_type , 
       r.ref_number , 
       r.ref_sequence , 
       s.stp_number , 
       s.ord_hdrnumber , 
       s.lgh_number , 
       c.cty_nmstct 
  FROM referencenumber r 
       JOIN @stops s ON r.ref_tablekey = s.stp_number AND r.ref_table = 'stops' 
       LEFT OUTER JOIN city c ON s.stp_city = c.cty_code 
 WHERE s.lgh_number = @lgh_number

-- Freight Reference Numbers, get all freightdetail table info
INSERT @refs ( ref_table , ref_type , ref_number , ref_sequence , fgt_sequence , cmd_code , fgt_description , 
fgt_number , stp_number , ord_hdrnumber , lgh_number 
) 
SELECT r.ref_table , 
       r.ref_type , 
       r.ref_number , 
       r.ref_sequence , 
       f.fgt_sequence , 
       f.cmd_code , 
       f.fgt_description , 
       f.fgt_number , 
       f.stp_number , 
       s.ord_hdrnumber , 
       s.lgh_number 
  FROM referencenumber r 
       JOIN freightdetail f ON r.ref_tablekey = f.fgt_number AND r.ref_table = 'freightdetail' 
       JOIN @stops s ON s.stp_number = f.stp_number 
 WHERE s.lgh_number = @lgh_number

-- Order Reference Numbers
INSERT @refs ( ref_table , ref_type , ref_number , ref_sequence , ord_hdrnumber 
) 
SELECT r.ref_table , 
       r.ref_type , 
       r.ref_number , 
       r.ref_sequence , 
       o.ord_hdrnumber 
  FROM referencenumber r 
       JOIN @orders o ON r.ref_tablekey = o.ord_hdrnumber AND r.ref_table = 'orderheader' 

-- Leg Reference Numbers
INSERT @refs ( ref_table , ref_type , ref_number , ref_sequence , lgh_number 
) 
SELECT r.ref_table , 
       r.ref_type , 
       r.ref_number , 
       r.ref_sequence , 
       l.lgh_number 
  FROM referencenumber r 
       JOIN @leg l ON r.ref_tablekey = l.lgh_number AND r.ref_table = 'legheader' 

-- ===============================================================================================================

-- Set order, leg, and stop sequences.  Set ref type label name.  Set ref number descriptons, include indents.
UPDATE @refs 
   SET ord_seq             = ISNULL( 
                             o.first_stop    , -- sort orders on fist appearence on mov
                             l.last_stop + 1   -- non-order refs are null, set to after last stop on leg to sort these below order based refs
                             ) , 
       leg_seq             = ISNULL( 
                             l.first_stop , -- sort legs on (first) appearence on mov (if ever adding multiple legs to this proc)
                             0              -- orderheader refs are null, set these to 0 to sort on top of stops
                             ) , 
       stp_seq             = CASE WHEN r.ord_hdrnumber > 0 
                                  THEN ISNULL( s.stp_sequence, 0 ) -- orderheader and legheader refs are null, set these to 0 to sort on top of stops
                                       + ISNULL( s.stp_xdoc_sequence, 0 ) -- sort xdoc stops after regular stops; non-xdoc refs are null, 0 to ignore
                                  ELSE ISNULL( s.stp_nonord_sequence, 0 ) -- legheader refs are null, set these to 0 to sort on top of stops
                             END , 
       ref_typedesc        = ISNULL( 
                             b.name , 
                             r.ref_type 
                             ) , 
       ref_description     = CASE ref_table 
                             WHEN 'orderheader'   THEN 'Order ' + ISNULL( o.ord_number , '' ) 
                             WHEN 'stops'         THEN '   Stop ' + ISNULL( sdesc.disp_nbr, '' ) + ' ' + s.stp_event + ' ' + r.cty_nmstct 
                                                                  + CASE WHEN s.cmp_id <> 'UNKNOWN' AND RTRIM( s.cmp_id ) <> '' 
                                                                  THEN '  (Cmp: ' + s.cmp_id + ')' ELSE '' END 
                             WHEN 'freightdetail' THEN '       Fgt ' + ISNULL( CONVERT( VARCHAR(22), r.fgt_sequence ) , '' ) 
                                                                     + ' on Stop ' + ISNULL( sdesc.disp_nbr , '' ) 
                                                                     + CASE WHEN ( r.cmd_code <> 'UNKNOWN' AND RTRIM( r.cmd_code ) <> '' ) 
                                                                     OR ( RTRIM( r.fgt_description ) <> '' ) THEN 
                                                                     '  (Cmd: ' + ISNULL( r.fgt_description , '' ) + ')' ELSE '' END 
                             WHEN 'legheader'     THEN 'Segment ' + ISNULL( CONVERT( VARCHAR(22), r.lgh_number ) , '' ) 
                             ELSE '' 
                             END , 
       ord_number          = o.ord_number , -- Need OrdNum and BillTo on all order-based rows so they're available in DW group header band
       ord_billto          = o.ord_billto , 
       stp_mfh_sequence    = s.stp_mfh_sequence , 
       stp_sequence        = s.stp_sequence , 
       stp_nonord_sequence = s.stp_nonord_sequence , 
       stp_xdoc_sequence   = s.stp_xdoc_sequence 
  FROM @refs r 
       LEFT OUTER JOIN @stops    s ON r.stp_number    = s.stp_number 
       LEFT OUTER JOIN @orders   o ON r.ord_hdrnumber = o.ord_hdrnumber 
       LEFT OUTER JOIN @leg      l ON r.lgh_number    = l.lgh_number 
       LEFT OUTER JOIN labelfile b ON r.ref_type      = b.abbr AND b.labeldefinition = 'ReferenceNumbers' 
       -- use subquery for the displayed stop number in desc because it's used twice above
       LEFT OUTER JOIN ( 
       	SELECT stp_number , 
       	       CASE WHEN stp_xdoc_sequence > 0 THEN 'X-' ELSE '' END -- 'X' label for xdoc stop refs - xdoc seq only positive for xdoc stops
       	       + ISNULL( 
       	       	CONVERT( VARCHAR(22), 
       	       		CASE WHEN ord_hdrnumber > 0 
       	       			-- order based stop refs 
       	       			THEN ISNULL( 
       	       				stp_xdoc_sequence ,    -- not null only for xdoc stop refs
       	       				stp_sequence           -- non-xdoc stop refs
       	       			) 
       	       			-- non-order based stop refs
       	       			ELSE stp_nonord_sequence -- non-order stop refs
       	       		END 
       	       	) 
       	       	, '' 
       	       ) disp_nbr 
       	  FROM @stops 
       ) sdesc ON s.stp_number = sdesc.stp_number 

-- ===============================================================================================================
-- Return result

-- Order based view (groups by order, puts non-order refs at bottom)
  SELECT ref_table           , 
         ref_description     , 
         ref_typedesc        , 
         ref_type            , 
         ref_number          , 
         ord_hdrnumber       , 
         lgh_number          , 
         stp_number          , 
         fgt_number          , 
         ord_seq             , 
         leg_seq             ,
         stp_seq             , 
         fgt_sequence        , 
         ref_sequence        , 
         stp_mfh_sequence    , 
         stp_sequence        , 
         stp_nonord_sequence , 
         stp_xdoc_sequence   , 
         stp_event           , 
         cmp_id              , 
         stp_city            , 
         cty_nmstct          , 
         cmd_code            , 
         fgt_description     , 
         ord_number          , 
         ord_billto            
    FROM @refs 
ORDER BY ord_seq , 
         leg_seq , 
         stp_seq , 
         fgt_sequence , 
         ref_sequence

GO
GRANT EXECUTE ON  [dbo].[d_showhide_refnbrs_sp] TO [public]
GO
