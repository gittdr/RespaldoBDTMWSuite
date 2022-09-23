SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[CarrierHubBiddingLoadsView]
as
select 'TMWWF_CarrierHub_BIDDING' AS 'TMWWF_CarrierHub_BIDDING',
            ca.ca_description 'Description', 
   ca.ca_id 'Auction ID', 
   ca.ord_hdrnumber 'OrderHeaderNumber', 
            ca.ca_type 'Type', 
   ca.ca_auction_amount 'Auction Amount', 
   ca.ca_end_date 'Auction Expires', 
            (select top 1 isnull(cb_reply_amount,0) from carrierbids where cb_reply_amount >0 and ca_id=ca.ca_id order by cb_reply_amount asc) 'Current Lowest', 
            (select count(cb_reply_amount) from carrierbids where ca_id=ca.ca_id and cb_reply_amount > 0) 'Bids', 
   leg.lgh_startcty_nmstct 'Start City', 
            leg.lgh_endcty_nmstct 'End City', 
   leg.lgh_rstartdate 'Start Date', 
   leg.lgh_renddate 'End Date', 
   leg.lgh_outstatus 'Leg Out Status',
   ca.lgh_number 'LegNumber',
   car_id 'CarrierID' ,
   ca.ca_status 'Auction Status',
   cb.cb_sent_status 'Sent Status',
   cb.cb_reply_status 'Reply Status',
   cb.cb_award_status 'Award Status',
   cb.cb_duplicate 'Duplicate',
   cb_reply_amount 'Reply Amount'
           from LegHeader leg 

            inner join carrierauctions ca on ca.lgh_number = leg.lgh_number 
            inner join carrierbids cb on cb.ca_id = ca.ca_id
GO
GRANT DELETE ON  [dbo].[CarrierHubBiddingLoadsView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubBiddingLoadsView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubBiddingLoadsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubBiddingLoadsView] TO [public]
GO
