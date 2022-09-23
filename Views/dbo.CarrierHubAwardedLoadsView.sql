SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 CREATE VIEW [dbo].[CarrierHubAwardedLoadsView]
 AS 
 SELECT DISTINCT C.car_name 'Carrier Name', C.car_id 'Carrier ID',CA.ca_description 'Description'
		,CA.ca_id 'Auction ID',CA.ord_hdrnumber 'OrderNumber', 
        CA.ca_type 'Type',CA.ca_auction_amount 'Auction Amount',CB.cb_sent_expires 'Auction Expires', 
        (SELECT TOP 1 ISNULL(cb_reply_amount,0) FROM carrierbids WHERE cb_reply_amount >0 and ca_id=CA.ca_id ORDER BY cb_reply_amount ASC) 'Current Lowest', 
        (SELECT COUNT(cb_reply_amount) FROM carrierbids WHERE ca_id=CA.ca_id) 'Bids',LH.lgh_startcty_nmstct 'Start City', 
        LH.lgh_endcty_nmstct 'End City' ,LH.lgh_rstartdate 'Start Date',LH.lgh_renddate 'End Date', 
        CA.lgh_number 'LegNumber',
        LH.lgh_outstatus 'LegStatus',
        cb_award_datetime 'AwardedDate'
FROM	LegHeader LH INNER JOIN
		carrierauctions CA ON LH.lgh_number = CA.lgh_number INNER JOIN
		carrierbids CB ON CA.ca_id = CB.ca_id INNER JOIN
		carrier C ON C.car_id = CB.car_id
WHERE	ISNULL(CB.cb_award_status,'') in ('ACCEPT') AND CA.ca_type IN ('TAKEIT', 'RESRV', 'RFB')
GO
GRANT DELETE ON  [dbo].[CarrierHubAwardedLoadsView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubAwardedLoadsView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubAwardedLoadsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubAwardedLoadsView] TO [public]
GO
