SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[DriverSeatAvailableTripsView]
as
SELECT /*Required Columns*/
	   lgh_number, 
	   lgh_startdate, 
	   lgh_enddate, 
	   ISNULL(startCity.cty_latitude,0) startLatitude, 
	   ISNULL(startCity.cty_longitude,0) startLongitude,
	   ISNULL(endCity.cty_latitude,0) endLatitude, 
	   ISNULL(endCity.cty_longitude,0) endLongitude, 
	   mov_number,
  	   lgh_tractor, 
	   lgh_driver1,
	   /*End Required Columns*/

   	   lgh_schdtearliest as 'Schedule Earliest Date', 
	   lgh_schdtlatest as 'Schedule Latest Date', 
	   cmd_code as 'Item Code', 
	   fgt_description as 'Fright Description', 
	   lgh_startcty_nmstct as 'Start City', 
	   lgh_endcty_nmstct as 'End City', 
	   ord_totalweight as 'Total Weight', 
	   ord_stopcount as 'Stop Count', 
	   ord_totalmiles as 'Total Miles', 
	   lgh_outstatus
	   ,  	   (SELECT STUFF((SELECT ',' + convert(varchar(20), ord_number )
                        FROM orderHeader oh 
  					  WHERE oh.ord_hdrnumber = la.ord_hdrnumber 
                             FOR XML PATH('')), 
                            1, 1, '')) OrderNumbers
  FROM legheader_active la 
LEFT JOIN city startCity on startCity.cty_code=la.lgh_startcity 
LEFT JOIN city endCity on endCity.cty_code= la.lgh_endcity 
  WHERE startCity.cty_latitude IS NOT NULL 
    AND startCity.cty_longitude IS NOT NULL 
	AND endCity.cty_latitude IS NOT NULL 
	AND endCity.cty_longitude IS NOT NULL
	AND lgh_outstatus = 'AVL'
GO
GRANT INSERT ON  [dbo].[DriverSeatAvailableTripsView] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverSeatAvailableTripsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverSeatAvailableTripsView] TO [public]
GO
