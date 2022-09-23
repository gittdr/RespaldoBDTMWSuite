SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [dbo].[CarrierHubTripsPayView]
AS
SELECT 
l.ord_hdrnumber 'OrderHeaderNumber',
	l.lgh_number 'Trip', 
	l.lgh_startcty_nmstct 'Origin', 
	l.lgh_startdate 'Start Date', 
	l.lgh_endcty_nmstct 'Destination', 
	l.lgh_enddate 'End Date', 
	CAST(ROUND(SUM(p.pyd_amount),2) AS DECIMAL(9,2)) 'Total Pay',
	p.asgn_id 'Carrier'
FROM paydetail p 
	INNER JOIN legheader l ON p.lgh_number = l.lgh_number
WHERE p.pyd_status = 'HLD' AND p.asgn_type = 'CAR'
GROUP BY l.ord_hdrnumber, l.lgh_number, l.lgh_startcty_nmstct,l.lgh_endcty_nmstct, l.lgh_startdate, l.lgh_enddate, p.asgn_id
GO
GRANT DELETE ON  [dbo].[CarrierHubTripsPayView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubTripsPayView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubTripsPayView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubTripsPayView] TO [public]
GO
