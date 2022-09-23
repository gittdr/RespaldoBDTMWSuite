SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[DriverSeatAssignedTripsView]
as
SELECT /*Required Columns*/
	   lgh_number, 
	   lgh_startdate, 
	   lgh_enddate, 
	   ISNULL(startCity.cty_latitude,0)  startLatitude,
	   ISNULL(startCity.cty_longitude,0) startLongitude,
	   ISNULL(endCity.cty_latitude,0) endLatitude, 
	   ISNULL(endCity.cty_longitude,0) endLongitude, 
	   mov_number,
	   lgh_tractor, 
	   lgh_driver1,
	   /*End Required Columns*/
   	   lgh_schdtearliest, 
	   lgh_schdtlatest, 
	   cmd_code, 
	   fgt_description, 
	   lgh_startcty_nmstct, 
	   lgh_endcty_nmstct, 
	   ord_totalweight, 
	   ord_stopcount, 
	   ord_totalmiles, 
	   lgh_outstatus,
	   lgh_drv_tndr_status
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
	AND lgh_outstatus != 'AVL'
GO
GRANT INSERT ON  [dbo].[DriverSeatAssignedTripsView] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverSeatAssignedTripsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverSeatAssignedTripsView] TO [public]
GO
