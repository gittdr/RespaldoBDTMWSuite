SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[CarrierHubFuelLoadDetailsCommodityView]
AS

/*******************************************************************************************************************  
  Object Description:
  This view provides the freight/commodity details needed for the Fuel Load Details page

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  10/11/2016   Chip Ciminero    WE-202583   Created
*******************************************************************************************************************/

SELECT  DISTINCT [Move Number]=O.mov_number, [Order Number]=O.ord_hdrnumber, [Stop Number] = F.stp_number, [StopType] = S.stp_type, [Freight Number]=F.fgt_number,CommodityCode=F.cmd_code, CommodityName=C.cmd_name
		, GrossVolume= COALESCE(F.fgt_volume,0), NetVolume = COALESCE(F.fgt_volume2,0)
		, [Weight] = COALESCE(F.fgt_weight,0), [Count] = COALESCE(F.fgt_count,0), [Delivery Record] = COALESCE(F.fgt_parentcmd_fgt_number,0)
		, [IsMissingPaperwork] = CASE WHEN COALESCE(P.Received,'Yes') = 'No' THEN 'Y' ELSE 'N' END
		, [CountUnit] = F.fgt_countunit, [WeightUnit] = F.fgt_weightunit, [GrossVolumeUnit] = F.fgt_volumeunit, [NetVolumeUnit] = F.fgt_volume2unit
		, [BillToId] = O.ord_billto, [ShipperId] = COALESCE(SF2.fgt_shipper, F.fgt_shipper), [AccountOfId] = COALESCE(COALESCE(SF2.fgt_accountof, F.fgt_accountof),'')
		, [SupplierId] = COALESCE(COALESCE(SF2.fgt_supplier, F.fgt_supplier),''), [ConsigneeId] = COALESCE(SF1.cmp_id,S.cmp_id)
		, [ParentFreightNumber] = COALESCE(F.fgt_parentcmd_fgt_number,0), [ParentStopNumber] = COALESCE(SF1.stp_number,0)
FROM	orderheader O INNER JOIN
		stops S ON O.ord_hdrnumber = S.ord_hdrnumber INNER JOIN
		freightdetail F ON S.stp_number = F.stp_number INNER JOIN
		commodity C ON F.cmd_code = C.cmd_code LEFT OUTER JOIN 
		CarrierHubPaperworkRequirementsView P ON S.lgh_number = P.LegNumber AND S.ord_hdrnumber = P.OrderNumber LEFT OUTER JOIN
		(
		SELECT  F1.fgt_number, F1.stp_number, S1.cmp_id 
		FROM	freightdetail F1 INNER JOIN
				stops S1 ON F1.stp_number = S1.stp_number
		) SF1 ON F.fgt_parentcmd_fgt_number = SF1.fgt_number LEFT OUTER JOIN
		(
		SELECT  F2.fgt_parentcmd_fgt_number [fgt_number], F2.stp_number, S2.cmp_id, F2.fgt_shipper, F2.fgt_accountof, F2.fgt_supplier
		FROM	freightdetail F2 INNER JOIN
				stops S2 ON F2.stp_number = S2.stp_number
		) SF2 ON F.fgt_number = SF2.fgt_number
GO
GRANT DELETE ON  [dbo].[CarrierHubFuelLoadDetailsCommodityView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubFuelLoadDetailsCommodityView] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierHubFuelLoadDetailsCommodityView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubFuelLoadDetailsCommodityView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubFuelLoadDetailsCommodityView] TO [public]
GO
