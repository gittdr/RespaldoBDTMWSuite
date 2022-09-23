SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  This view should be used as a basis for creating new views that access the MobileComm data stored in TMWSuite
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  05/05/2016   Mark Fielder     PTS:101987  Initial Release
  10/1/2016	   Mark Fielder		WE-202342   Use new created date column
  10/20/2016   Mark Fielder     WE-202798   remove switchoffset (m.CreatedDate, '+00:00')
  11/18/2016   Brad Biehl       WE-203359   Renamed MobileConnet to FleetConneX
********************************************************************************************************************/

CREATE VIEW [dbo].[FleetConneXMessageBaseView]
AS
	SELECT m.ParentMessageId
	  , m.MessageId
	  , m.DirectionId
	  , CASE WHEN IsNumeric(def.ExternalId) = 0 THEN 'Internal' ELSE 'Vendor' END AS [MessageType]
	  , m.ExternalId MessageExternalId
	  , def.ExternalId DefinitionExternalId
	  , trc.trc_number AS Tractor
	  , drv.mpp_id AS Driver
	  , lgh.lgh_number
	  , m.MessageText
	  , m.CreatedDate AS CreateDate
	  , m.ErrorMessages

	FROM 
	  MobileCommMessage AS m
	  LEFT OUTER JOIN MobileCommMessageLinkTractor AS trc ON trc.MessageId = m.MessageId
	  LEFT OUTER JOIN MobileCommMessageLinkDriver AS drv ON drv.MessageId = m.MessageId
		AND drv.mpp_id <> 'UNKNOWN'
	  LEFT OUTER JOIN MobileCommMessageLinkLegHeader AS lgh ON lgh.MessageId = m.MessageId
	  INNER JOIN MobileCommMessageDefinition AS def ON def.MessageDefinitionId = m.MessageDefinitionId
GO
GRANT SELECT ON  [dbo].[FleetConneXMessageBaseView] TO [public]
GO
