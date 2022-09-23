SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 CREATE VIEW [dbo].[CarrierHubNotAwardedLoadsView]
 AS 
SELECT	DISTINCT CA.ca_description 'Description',CA.ca_id 'Auction ID',CA.ord_hdrnumber 'OrderNumber',CA.ca_type 'Type',CA.ca_auction_amount 'Auction Amount',CB.cb_sent_expires 'Auction Expires', 
		(SELECT TOP 1 ISNULL(cb_reply_amount,0) FROM carrierbids WHERE cb_reply_amount >0 and ca_id=CA.ca_id order by cb_reply_amount asc) 'Current Lowest'
		,(SELECT COUNT(cb_reply_amount) FROM carrierbids WHERE ca_id=CA.ca_id and cb_reply_amount > 0) 'Bids' 
		,LH.lgh_startcty_nmstct 'Start City',LH.lgh_endcty_nmstct 'End City' ,LH.lgh_rstartdate 'Start Date',LH.lgh_renddate 'End Date',CA.lgh_number 'LegNumber',
        LH.lgh_outstatus 'LegStatus',
        cb_award_datetime 'AwardedDate',
        CB.car_id 'Carrier ID'
FROM	LegHeader LH INNER JOIN
		carrierauctions CA ON LH.lgh_number = CA.lgh_number INNER JOIN 
		carrierbids CB ON CA.ca_id = CB.ca_id
WHERE	ISNULL(CB.cb_award_status,'') in ('REJECT','RSPN','NRSPNS') AND CA.ca_type IN ('TAKEIT', 'RESRV', 'RFB')
GO
GRANT DELETE ON  [dbo].[CarrierHubNotAwardedLoadsView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubNotAwardedLoadsView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubNotAwardedLoadsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubNotAwardedLoadsView] TO [public]
GO
