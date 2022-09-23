SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[FleetConneXWorkSheetView]
AS

/*******************************************************************************************************************  
  Object Description:
  This view should be used as a default and basis for creating new views that are used to populate the FleetConneXWorksheet
  configured grid.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  05/11/2016   Chase Plante     PTS:102205  Updated to conform to DBA standards
  10/1/2016	   Mark Fielder		WE-202342   Use new created date column
  10/20/2016   Mark Fielder     WE-202798   remove switchoffset (m.CreatedDate, '+00:00')
  11/18/2016   Brad Biehl       WE-203359   Renamed MobileConnet to FleetConneX
********************************************************************************************************************/

     SELECT m.ParentMessageId,
            m.MessageId AS MessageID,
            lgh.lgh_number AS LegNumber,
            m.DirectionId AS DirectionId,
            m.ExternalId AS ExternalMessageId,
            CASE
                WHEN ISNUMERIC(def.ExternalId) = 0
                THEN 'Internal'
                ELSE 'Vendor'
            END AS ExternalType,
            def.ExternalId AS ExternalDefinitionId,
            trc.trc_number AS Tractor,
            drv.mpp_id AS Driver,
            m.MessageText as Message,
            m.CreatedDate AS CreateDate
     FROM MobileCommMessage AS m
          INNER JOIN MobileCommMessageDefinition AS def ON def.MessageDefinitionId = m.MessageDefinitionId
          LEFT OUTER JOIN MobileCommMessageLinkTractor AS trc ON trc.MessageId = m.MessageId
          LEFT OUTER JOIN MobileCommMessageLinkDriver AS drv ON drv.MessageId = m.MessageId
                                                                AND drv.mpp_id <> 'UNKNOWN'
          LEFT OUTER JOIN MobileCommMessageLinkLegHeader AS lgh ON lgh.MessageId = m.MessageId
     WHERE m.ParentMessageId IS NULL;
GO
GRANT SELECT ON  [dbo].[FleetConneXWorkSheetView] TO [public]
GO
