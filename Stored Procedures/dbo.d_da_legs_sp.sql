SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_legs_sp] 
	@start_date DATETIME , 
	@end_date DATETIME , 
	@lgh_number INT 
AS

DECLARE @legs TABLE ( 
	lgh_number INT 
) 

IF @lgh_number = -1 
	INSERT @legs 
	SELECT lgh_number 
	  FROM legheader 
	 WHERE lgh_outstatus IN ( 'PLN', 'STD', 'CMP', 'DSP' ) AND 
	       ( lgh_driver1 <> 'UNKNOWN'OR lgh_tractor <> 'UNKNOWN' ) AND 
	       lgh_startdate < DATEADD( Day, 1, @end_date ) AND 
	       lgh_enddate > @start_date 
ELSE
	INSERT @legs 
	SELECT lgh_number 
	  FROM legheader 
	 WHERE lgh_number = @lgh_number 

SELECT l.lgh_number , 
       l.lgh_driver1 , 
       l.lgh_tractor , 
       l.lgh_startdate , 
       l.lgh_enddate , 
       l.lgh_outstatus , 
       l.mov_number ,
       l.lgh_startcty_nmstct origin, 
       l.lgh_endcty_nmstct destination , 
       ( SELECT COUNT( DISTINCT stops.ord_hdrnumber ) 
           FROM stops 
          WHERE stops.lgh_number = l.lgh_number AND 
                stops.ord_hdrnumber > 0 
       ) ord_count , 
       o.ord_billto , 
       l.lgh_comment , 
       l.lgh_carrier , 
       l.lgh_primary_trailer lgh_trailer1 , 
       l.lgh_primary_pup     lgh_trailer2 , 
       l.lgh_tm_status , 
       t1.trl_capacity_wgt trl1_capacity_wgt , 
       t1.trl_capacity_ldm trl1_capacity_ldm , 
       t2.trl_capacity_wgt trl2_capacity_wgt , 
       t2.trl_capacity_ldm trl2_capacity_ldm , 
       l.ord_hdrnumber , 
       o.ord_number 
  FROM legheader l 
       JOIN @legs t ON l.lgh_number = t.lgh_number 
       LEFT JOIN orderheader o ON l.ord_hdrnumber = o.ord_hdrnumber 
       LEFT JOIN trailerprofile t1 ON lgh_primary_trailer = t1.trl_number 
       LEFT JOIN trailerprofile t2 ON lgh_primary_pup = t2.trl_number 
 ORDER BY lgh_driver1, lgh_startdate

GO
GRANT EXECUTE ON  [dbo].[d_da_legs_sp] TO [public]
GO
