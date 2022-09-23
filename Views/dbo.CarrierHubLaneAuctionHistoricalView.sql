SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[CarrierHubLaneAuctionHistoricalView]
as
select 'TMWWF_CarrierHub_LANEAUCTION_HISTORICAL' AS 'TMWWF_CarrierHub_LANEAUCTION_HISTORICAL',
ca.ca_description 'Description', 
ca.ca_id 'Auction ID', 
cb.cb_sent_expires 'Auction Expires', 
cb.cb_reply_status 'My Bid Status',
cb.cb_award_status 'My Award Status',
CONVERT(decimal(12,2), cb.cb_reply_amount) 'My Bid',
(SELECT ISNULL(MIN(sch_copy_frequency), 'N/A') FROM schedule_table WHERE schedule_table.ord_hdrnumber = oh.ord_hdrnumber and schedule_table.sch_expires_on >= GETDATE()) 'Lane Schedule',
CONVERT(decimal(12,2), (select top 1 isnull(cb_reply_amount,0) from carrierbids where cb_reply_amount >0  and cb_reply_status <> 'DECLND' and carrierbids.ca_id = ca.ca_id order by cb_reply_amount asc), 0) 'Current Lowest', 
( select count(cb_reply_amount) from carrierbids where ca_id = ca.ca_id and cb_reply_amount > 0 and cb_reply_status <> 'DECLND') 'Bids Count', 
cf.cty_name 'Start City',
cf.cty_state 'Start State',
cl.cty_name 'End City',
cl.cty_state 'End State',
ca.ca_status 'Status', 
cb.car_id 'Carrier',
ca.ca_type 'Type', 
ca.ord_hdrnumber 'Order Number', 
ca.lgh_number 'Leg Number',
oh.ord_status 'ord_status'

from carrierauctions ca
	join carrierbids cb on cb.ca_id = ca.ca_id 
	join orderheader oh on ca.ord_hdrnumber = oh.ord_hdrnumber
	join stops sf on oh.ord_hdrnumber = sf.ord_hdrnumber and sf.stp_mfh_sequence = 1
	join city cf on cf.cty_code = sf.stp_city
	join stops sl on oh.ord_hdrnumber = sl.ord_hdrnumber and sl.stp_mfh_sequence = oh.ord_stopcount
	join city cl on cl.cty_code = sl.stp_city

GO
GRANT DELETE ON  [dbo].[CarrierHubLaneAuctionHistoricalView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubLaneAuctionHistoricalView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubLaneAuctionHistoricalView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubLaneAuctionHistoricalView] TO [public]
GO
