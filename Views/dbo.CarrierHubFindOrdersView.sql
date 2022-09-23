SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[CarrierHubFindOrdersView]
AS
SELECT     L.abbr AS Edi204Status, leg.lgh_number, leg.ord_hdrnumber, RTRIM(ord.ord_number) 
                      + CASE WHEN isnull(lgh_split_flag, 'N') = 'N' THEN '' ELSE '-' + lgh_split_flag END AS ord_number, leg.lgh_startdate AS StartDate, leg.lgh_enddate AS EndDate, 
                      leg.lgh_outstatus AS DispStatus, leg.lgh_miles AS Mileage, startcompany.cmp_id AS PickupId, startcompany.cmp_name AS PickupName, 
                      startcity.cty_name AS PickupCity, leg.lgh_startstate AS PickupState, LegStartStop.stp_arrivaldate AS PickupArrival, 
                      LegStartStop.stp_departuredate AS PickupDeparture, endcompany.cmp_id AS ConsigneeId, endcompany.cmp_name AS ConsigneeName, 
                      endcity.cty_name AS ConsigneeCity, endcompany.cmp_state AS ConsigneeState, LegFinalStop.stp_arrivaldate AS DropArrival, 
                      LegFinalStop.stp_departuredate AS DropDeparture, S.OrdCnt, S.PupCnt, S.DrpCnt, ord.ord_totalvolume AS TotalVol, ord.ord_totalweight AS TotalWeight, 
                      leg.lgh_primary_trailer AS Trailer, leg.lgh_carrier AS Carrier, dbo.tmw_legstopslate_fn(leg.lgh_number) AS [Late Stops]
FROM         dbo.legheader_active AS leg INNER JOIN
                      dbo.city AS startcity ON leg.lgh_startcty_nmstct = startcity.cty_nmstct INNER JOIN
                      dbo.orderheader AS ord ON leg.ord_hdrnumber = ord.ord_hdrnumber INNER JOIN
                      dbo.company AS startcompany ON leg.cmp_id_start = startcompany.cmp_id INNER JOIN
                      dbo.company AS endcompany ON endcompany.cmp_id = leg.cmp_id_end INNER JOIN
                      dbo.city AS endcity ON endcity.cty_code = leg.lgh_endcity INNER JOIN
                      dbo.stops AS LegStartStop ON LegStartStop.stp_number = leg.stp_number_start INNER JOIN
                      dbo.stops AS LegFinalStop ON LegFinalStop.stp_number = leg.stp_number_end INNER JOIN
                      dbo.trailerprofile ON dbo.trailerprofile.trl_id = leg.lgh_primary_trailer INNER JOIN
                          (SELECT     lgh_number, SUM(CASE WHEN ord_hdrnumber <> 0 THEN 1 ELSE 0 END) AS OrdCnt, SUM(CASE WHEN stp_type = 'PUP' THEN 1 ELSE 0 END) 
                                                   AS PupCnt, SUM(CASE WHEN stp_type = 'DRP' THEN 1 ELSE 0 END) AS DrpCnt
                            FROM          dbo.stops
                            GROUP BY lgh_number) AS S ON S.lgh_number = leg.lgh_number LEFT OUTER JOIN                      
                              dbo.labelfile L ON leg.lgh_204status = L.name AND L.labeldefinition = 'Lgh204Status'                         
                         

-- set permissions on CarrierHubFindOrdersView
GO
GRANT DELETE ON  [dbo].[CarrierHubFindOrdersView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubFindOrdersView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubFindOrdersView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubFindOrdersView] TO [public]
GO
