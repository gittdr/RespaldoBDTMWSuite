SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	VIEW [dbo].[CarrierHubCrudeTicketReadingsView] AS
SELECT  MoveNumber=O.mov_number, LegNumber=S.lgh_number, OrderNumber=O.ord_hdrnumber, FreightNumber=F.fgt_number
		, StopNumber=S.stp_number, Carrier = L.lgh_carrier, ShipperId=S.cmp_id, ShipperName=S.cmp_name, CommodityCode=F.cmd_code, CommodityName=C.cmd_name
		, TankId=T.cmp_tank_id, T.TankTranslation, GrossVolume= ISNULL(F.fgt_volume,0), NetVolume = ISNULL(F.fgt_volume2,0)
		, [Weight] = ISNULL(F.fgt_weight,0), [Count] = ISNULL(F.fgt_count,0)
FROM	orderheader O INNER JOIN
		stops S ON O.ord_hdrnumber = S.ord_hdrnumber INNER JOIN
		legheader L ON L.lgh_number = S.lgh_number INNER JOIN
		freightdetail F ON S.stp_number = F.stp_number INNER JOIN
		commodity C ON F.cmd_code = C.cmd_code LEFT OUTER JOIN 
		freight_by_compartment AS FBC ON f.fgt_number = fbc.fgt_number LEFT OUTER JOIN
		company_tankdetail T ON S.cmp_id = T.cmp_id AND  FBC.fbc_tank_nbr = T.forecast_bucket
WHERE	S.stp_type = 'PUP'
GO
GRANT SELECT ON  [dbo].[CarrierHubCrudeTicketReadingsView] TO [public]
GO
