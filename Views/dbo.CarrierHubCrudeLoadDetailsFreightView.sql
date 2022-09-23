SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	VIEW [dbo].[CarrierHubCrudeLoadDetailsFreightView] AS
SELECT  [Move Number]=O.mov_number, [Order Number]=O.ord_hdrnumber,	[Freight Number]=F.fgt_number,CommodityCode=F.cmd_code, CommodityName=C.cmd_name
		, TankId=T.cmp_tank_id, T.TankTranslation, GrossVolume= ISNULL(F.fgt_volume,0), NetVolume = ISNULL(F.fgt_volume2,0)
		, [Weight] = ISNULL(F.fgt_weight,0), [Count] = ISNULL(F.fgt_count,0), [Delivery Record] = F.fgt_parentcmd_fgt_number
		, [IsMissingReadings] = CASE WHEN ISNULL(R.cmp_id,'Y') = 'Y' THEN 'Y' ELSE 'N' END
		, [IsMissingPaperwork] = CASE WHEN ISNULL(P.Received,'Yes') = 'No' THEN 'Y' ELSE 'N' END
FROM	orderheader O INNER JOIN
		stops S ON O.ord_hdrnumber = S.ord_hdrnumber INNER JOIN
		freightdetail F ON S.stp_number = F.stp_number INNER JOIN
		commodity C ON F.cmd_code = C.cmd_code LEFT OUTER JOIN 
		freight_by_compartment AS FBC ON f.fgt_number = fbc.fgt_number LEFT OUTER JOIN
		company_tankdetail T ON S.cmp_id = T.cmp_id AND FBC.fbc_tank_nbr = T.forecast_bucket LEFT OUTER JOIN
		CarrierHubPaperworkRequirementsView P ON S.lgh_number = P.LegNumber AND S.ord_hdrnumber = P.OrderNumber LEFT OUTER JOIN
		OilFieldReadings R ON F.fgt_number = R.fgt_number
WHERE	S.stp_type = 'PUP'
GO
GRANT SELECT ON  [dbo].[CarrierHubCrudeLoadDetailsFreightView] TO [public]
GO
