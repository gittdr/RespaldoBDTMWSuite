SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[FleetConneXStopsView]
AS

/*******************************************************************************************************************  
  Object Description:
  This view should be used to populate stops grid on the Mobile Connect Load Details page.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  05/11/2016   Chase Plante     PTS:102205  Updated to conform to DBA standards
  08/01/2016   Chase Plante	    WE-100042   Added event to the stop group by in order to fix consolidation bug
  11/18/2016   Brad Biehl       WE-203359   Renamed MobileConnet to FleetConneX
********************************************************************************************************************/

     WITH StopGroup
          AS (SELECT A.mov_number,
                     B.stp_number [MinStpNumber],
                     C.stp_number [MaxStpNumber]
              FROM
              (
                  SELECT mov_number,
                         cmp_id,
                         MinSeq = MIN(stp_mfh_sequence),
                         MaxSeq = MAX(stp_mfh_sequence)
                  FROM stops
                  GROUP BY mov_number,
                           cmp_id,
                           stp_event
              ) A
              INNER JOIN stops B ON A.mov_number = B.mov_number
              INNER JOIN stops C ON A.mov_number = C.mov_number
              WHERE A.MinSeq = B.stp_mfh_sequence
                    AND A.MaxSeq = C.stp_mfh_sequence)
          SELECT s1.mov_number MoveNumber,
                 l.lgh_carrier Carrier,
                 o.ord_number OrderNumber,
                 l.ord_hdrnumber OrderHeaderNumber,
                 s1.stp_number StopNumber,
                 RTRIM(LTRIM(s1.cmp_id)) CompanyId,
                 RTRIM(LTRIM(c.cmp_altid)) CompanyAltId,
                 RTRIM(LTRIM(c.cmp_name)) CompanyName,
                 RTRIM(LTRIM(cty.cty_nmstct)) City,
                 s1.stp_event Event,
                 e1.evt_earlydate EarliestDate,
                 e2.evt_latedate LatestDate,
                 e1.evt_startdate ArrivalDate,
                 CASE
                     WHEN s1.stp_status = 'DNE'
                     THEN 'Y'
                     ELSE 'N'
                 END Arrived,
                 e2.evt_enddate DepartureDate,
                 CASE
                     WHEN s1.stp_departure_status = 'DNE'
                     THEN 'Y'
                     ELSE 'N'
                 END Departed,
                 e2.evt_hubmiles HubMiles
          FROM StopGroup
               INNER JOIN stops AS s1 ON s1.stp_number = StopGroup.MinStpNumber
               INNER JOIN event AS e1 ON e1.stp_number = StopGroup.MinStpNumber
               INNER JOIN stops AS s2 ON s2.stp_number = StopGroup.MaxStpNumber
               INNER JOIN event AS e2 ON e2.stp_number = StopGroup.MinStpNumber
               INNER JOIN company AS c ON c.cmp_id = s1.cmp_id
               INNER JOIN city AS cty ON cty.cty_code = s1.stp_city
               INNER JOIN legheader AS l ON l.lgh_number = s1.lgh_number
               INNER JOIN orderheader AS o ON o.ord_hdrnumber = l.ord_hdrnumber
          WHERE e1.evt_sequence = 1
                AND e2.evt_sequence = 1;
GO
GRANT SELECT ON  [dbo].[FleetConneXStopsView] TO [public]
GO
