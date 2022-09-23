SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  This view is a copy of vSSRSRB_RevVsPay. It is needed for the Driver Management tab on Driver Profile in TMW
  Operations. Since there is no guarantee that all clients will have vSSRSRB_RevVsPay, this copy was made so that
  all clients will have this view.

  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ----------------------------------------
  05/09/2017   Cory Sellers     NSUITE-201262  Initial Release
  07/17/2017   Mike Luoma       NSUITE-201825  Optimization
  08/07/2017   Todd Hykes		NSUITE-201825  Optimization
  
********************************************************************************************************************/

CREATE VIEW [dbo].[vDRVMgmt_SSRSRB_RevVsPay]
AS
WITH StopMiles AS (
  SELECT 
    lgh_number
  , SUM(CASE WHEN stp_loadstatus =  'LD' THEN COALESCE(stp_lgh_mileage, 0) ELSE 0 END) AS LoadedMiles
  , SUM(CASE WHEN stp_loadstatus != 'LD' THEN COALESCE(stp_lgh_mileage, 0) ELSE 0 END) AS EmptyMiles
  , SUM(COALESCE(stp_lgh_mileage, 0)) AS AllMiles
  , SUM(COALESCE(stp_ord_mileage, 0)) AS BilledMiles
  FROM
    dbo.stops
  GROUP BY 
    lgh_number)

SELECT 
  CAST([Bill Date] AS DATE) AS           [Bill Date Only]
, [Bill To Name] = company.cmp_name
, CAST([Order Delivery Date] AS DATE) AS [Delivery Date Only]
, [Driver1 ID]
, [EmptyMiles] as [Empty Miles]
, [Freight Description]
, [Leg Number]
, [LoadedMiles]	As [Loaded Miles]
, [Order Header Number]	
, Revenue
, CASE
    WHEN NumberOfSplitsOnMove = 0 THEN 0
    ELSE Revenue / NumberOfSplitsOnMove
  END AS [Revenue Per Load]
, CASE
    WHEN LoadedMiles = 0 THEN 0
    ELSE Revenue / LoadedMiles
  END AS                                                                RevenuePerLoadedMile
, CASE
    WHEN TotalMiles = 0 THEN 0
    ELSE Revenue / TotalMiles 
  END AS                                                                RevenuePerTravelMile
, [Segment End City]
, [Segment End Date Only]
, [Segment Start City]
, [TotalMiles] as [Total Miles]
, [Trip Hours]
, 0 as [NET]
, 0 as [Pay]
FROM
  (
  SELECT 
    [Bill Date] =
    (
    SELECT 
      MIN(ivh_billdate)
    FROM 
      dbo.invoiceheader I WITH (NOLOCK)
    WHERE
      I.ord_hdrnumber = lgh.ord_hdrnumber
      AND
      lgh.ord_hdrnumber > 0
  )
  , [Bill To ID] = COALESCE((
                            SELECT 
                               MIN(ivh_billto)
                             FROM 
                               invoiceheader I WITH (NOLOCK)
                             WHERE
                               I.ord_hdrnumber = lgh.ord_hdrnumber
                               AND
                               lgh.ord_hdrnumber > 0
                            ), ord.ord_billto , '')
  , lgh_driver1 AS                                              [Driver1 ID]
  , COALESCE(StopMiles.EmptyMiles, 0) AS EmptyMiles
  , fgt_description AS                                          [Freight Description]
  , lgh.lgh_number AS                                               [Leg Number]
  , COALESCE(StopMiles.LoadedMiles, 0) AS LoadedMiles
  , NumberOfSplitsOnMove =
    (
    SELECT 
      COUNT(DISTINCT L2.lgh_number)
    FROM 
      dbo.legheader L2 WITH (NOLOCK)
    WHERE
      L2.Mov_number = lgh.Mov_number
  )
  , city.cty_name AS [Order Dest City]
  , COALESCE(ord.ord_completiondate , lgh_enddate) AS         [Order Delivery Date] --'Order Delivery Date' 	
  , lgh.ord_hdrnumber AS                                        [Order Header Number]
  , COALESCE(ord.ord_company , '') AS                         [Ordered By ID] --'Ordered By ID'							
  , Revenue = CONVERT(MONEY , COALESCE(dbo.udf_DRVMgmt_allocatedTotOrdRevByMiles(lgh.lgh_number) , 0.00))
  , lgh_endcty_nmstct AS                                        [Segment End City]
  , CAST(lgh_EndDate AS DATE) AS [Segment End Date Only]
  , lgh_startcty_nmstct AS                                      [Segment Start City]
  , COALESCE(StopMiles.BilledMiles, 0) AS [TotalBilled Miles]
  , COALESCE(StopMiles.AllMiles, 0) AS TotalMiles
  , CAST(lgh_enddate - lgh_startdate AS FLOAT) * 24 AS        [Trip Hours]
  FROM 
    dbo.legheader lgh
      INNER JOIN
    StopMiles /*CTE from above*/ ON lgh.lgh_number = StopMiles.lgh_number
      LEFT JOIN
    dbo.orderheader ord WITH (NOLOCK) ON ord.ord_hdrnumber = lgh.ord_hdrnumber AND lgh.ord_hdrnumber > 0
      LEFT JOIN
    dbo.city ON ord.ord_destCity = city.cty_code
      LEFT JOIN
    dbo.company origincmp WITH (NOLOCK) ON lgh.cmp_id_start = origincmp.cmp_id AND lgh.ord_hdrnumber > 0
  WHERE
    lgh.lgh_startdate >= GETDATE() - 30
) AS TripSegment
    LEFT OUTER JOIN 
  dbo.company ON TripSegment.[Bill To ID] = company.cmp_id;

GO
GRANT SELECT ON  [dbo].[vDRVMgmt_SSRSRB_RevVsPay] TO [public]
GO
