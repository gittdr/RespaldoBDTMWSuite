SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/**
 * 
 * REVISION HISTORY:
 * 07/19/2005.01 - BYoung - Removing CMP orders from the Result Set
 *	I changed the line.. 
 * 				From: 	orderheader.ord_status in ('AVL', 'PLN', 'STD', 'DSP', 'CMP') AND
 *				To: 	orderheader.ord_status in ('AVL', 'PLN', 'STD', 'DSP') AND
 * 1/2/06 DSK added ord_number and made the start date = to the origianlly planned start date
 **/

CREATE procedure [dbo].[moves_by_route_sp](@route varchar(30))  
as  

DECLARE	@startdate	DATETIME,
	@enddate	DATETIME

SELECT @startdate = DATEADD(dd, DATEPART(dy, GETDATE())-7, CAST(STR(DATEPART(yy, GETDATE()), 4) + '0101' AS DATETIME))
SELECT @enddate = DATEADD(dd, 14, @startdate)

SELECT 	legheader.mov_number, 
	lgh_startdate = (SELECT min(stp_schdtearliest) FROM stops WHERE stops.mov_number = legheader.mov_number AND stops.stp_sequence = 1), -- 31137
	cmp_id_start, 
	cmp_o.cmp_name orig_cmp_name, 
	cty_o.cty_nmstct orig_city,
	lgh_enddate, 
	cmp_id_end, 
	cmp_d.cmp_name dest_cmp_name, 
	cty_d.cty_nmstct dest_city, 
	lgh_driver1, 
	lgh_driver2,   
	lgh_tractor, 
	lgh_primary_trailer,
	ord_number -- 31137
FROM 	legheader, company cmp_o, company cmp_d, city cty_o, city cty_d, orderheader
WHERE 	lgh_number in (select lgh_number
                       from legheader
                      where mov_number in (select distinct orderheader.mov_number 
  					   from orderheader 
 				  	   where ord_route = @route)) and
       	legheader.cmp_id_start = cmp_o.cmp_id AND
       	legheader.cmp_id_end = cmp_d.cmp_id AND
       	legheader.lgh_startcity = cty_o.cty_code AND
       	legheader.lgh_endcity = cty_d.cty_code AND
	orderheader.mov_number = legheader.mov_number AND
	--orderheader.ord_status in ('AVL', 'PLN', 'STD', 'DSP', 'CMP') AND
	orderheader.ord_status in ('AVL', 'PLN', 'STD', 'DSP') AND
 	orderheader.ord_startdate >= @startdate AND
 	orderheader.ord_startdate < @enddate

GO
GRANT EXECUTE ON  [dbo].[moves_by_route_sp] TO [public]
GO
