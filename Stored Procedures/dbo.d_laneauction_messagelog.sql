SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create PROC [dbo].[d_laneauction_messagelog] @batch_or_order_nbr int , @batch_or_order char(1)
		
AS 
/**  Proc Created for PTS 46628
 *	 Pulls log file entries back for the 
	 d_laneauction_messagelog dwo on the 
	 summary tab of the lane auction window 
	 w_lane_auction_bid_manager
 *
 **/

IF @batch_or_order = 'B' 
begin 
SELECT	 lam_batch_nbr,   
         lam_transaction_type,   
         lam_item,   
         lam_itemkey,   
         lam_IWE,   
         lam_item_msg,   
         lam_user_id,   
         lam_create_date,   
         lam_identity,   
         ord_number,   
         ord_hdrnumber,   
         mov_number,   
         ca_id,
		 tariffkeybid_tar_number,
		 tariffkey_tar_number
FROM     laneauction_messagelog  
WHERE    lam_batch_nbr = @batch_or_order_nbr
end 

IF @batch_or_order = 'O' 
begin 
SELECT	 lam_batch_nbr,   
         lam_transaction_type,   
         lam_item,   
         lam_itemkey,   
         lam_IWE,   
         lam_item_msg,   
         lam_user_id,   
         lam_create_date,   
         lam_identity,   
         ord_number,   
         ord_hdrnumber,   
         mov_number,   
         ca_id,
		 tariffkeybid_tar_number,
		 tariffkey_tar_number
FROM     laneauction_messagelog  
WHERE    ord_hdrnumber = @batch_or_order_nbr
end 



GO
GRANT EXECUTE ON  [dbo].[d_laneauction_messagelog] TO [public]
GO
