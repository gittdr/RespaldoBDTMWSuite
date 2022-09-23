SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[FleetConneXCheckCallsView]
AS

/*******************************************************************************************************************  
  Object Description:
  This view should be used to populate the check calls grid on the Mobile Connect Worksheet page.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  06/08/2017   Laura Hanna		WE-207279	Adding decimal columns for Lat/Long
  05/11/2016   Chase Plante     PTS:102205  Updated to conform to DBA standards
  10/1/2016	   Mark Fielder		WE-202342   Use new created date column
  11/18/2016   Brad Biehl       WE-203359   Renamed MobileConnet to FleetConneX
********************************************************************************************************************/

     SELECT m.MessageId AS MessageId,
            c.ckc_number AS CheckCallNumber,
            cast ((c.ckc_latseconds / 3600) as DECIMAL (9, 6)) AS LatDecimal,
            cast ((c.ckc_longseconds / -3600) as DECIMAL (9, 6)) AS LongDecimal,
			c.ckc_latseconds AS Latitude,
            c.ckc_longseconds AS Longitude,
            c.ckc_status AS Status,
            c.ckc_asgntype AS AssignmentType,
            c.ckc_asgnid AS AssignmentId,
            c.ckc_date AS Date,
            c.ckc_event AS Event,
            c.ckc_comment AS Comment,
            c.ckc_lghnumber AS LegNumber,
            c.ckc_tractor AS Tractor,
            'TruckGreen' AS Icon -- TruckWhite, TruckAqua, TruckBlack, TruckBlue, TruckBrown, TruckGray, TruckOrange, TruckPink, TruckPurple, TruckRed, TruckYellow
     FROM dbo.checkcall AS c
          INNER JOIN dbo.MobileCommMessageLinkTractor AS mTrc ON c.ckc_tractor = mTrc.trc_number
          INNER JOIN dbo.MobileCommMessage AS m ON m.MessageId = mTrc.MessageId
     WHERE c.ckc_updatedon >= DATEADD(HOUR, -6, m.CreatedDate)
           AND c.ckc_updatedon <= DATEADD(HOUR, 6, m.CreatedDate)
GO
GRANT SELECT ON  [dbo].[FleetConneXCheckCallsView] TO [public]
GO
