SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[FleetConneXFreightView]
AS

/*******************************************************************************************************************  
  Object Description:
  This view should be used to populate the freight grid on the Mobile Connect Load Details page.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  05/11/2016   Chase Plante     PTS:102205  Updated to conform to DBA standards
  11/18/2016   Brad Biehl       WE-203359   Renamed MobileConnet to FleetConneX
********************************************************************************************************************/

     SELECT O.mov_number MoveNumber,
            O.ord_hdrnumber OrderNumber,
            F.fgt_number FreightNumber,
            F.cmd_code CommodityCode,
            C.cmd_name CommodityName,
            T.cmp_tank_id TankId,
            T.TankTranslation TankTranslation,
            ISNULL(F.fgt_volume, 0) GrossVolume,
            ISNULL(F.fgt_volume2, 0) NetVolume,
            ISNULL(F.fgt_weight, 0) Weight,
            ISNULL(F.fgt_count, 0) Count,
            F.fgt_parentcmd_fgt_number DeliveryRecord
     FROM orderheader O
          INNER JOIN stops S ON O.ord_hdrnumber = S.ord_hdrnumber
          INNER JOIN freightdetail F ON S.stp_number = F.stp_number
          INNER JOIN commodity C ON F.cmd_code = C.cmd_code
          LEFT OUTER JOIN freight_by_compartment AS FBC ON f.fgt_number = fbc.fgt_number
          LEFT OUTER JOIN company_tankdetail T ON S.cmp_id = T.cmp_id
                                                  AND FBC.fbc_tank_nbr = T.forecast_bucket
     WHERE S.stp_type = 'PUP';
GO
GRANT SELECT ON  [dbo].[FleetConneXFreightView] TO [public]
GO
