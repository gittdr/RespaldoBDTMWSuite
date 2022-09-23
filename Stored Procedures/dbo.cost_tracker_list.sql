SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[cost_tracker_list] (@p_ordnumber varchar(13),@p_invoicenumber varchar(13),@p_fromdate datetime,@p_todate datetime )
AS


/* to retrieve cost_tracker data for an order or an invoice or for a date/time range
Created 6/4/10 DPETE PTS51844
Stolen for cost_tracker use MRH PTS55570
*/

declare @ord_hdrnumber int, @ivh_hdrnumber int

If @p_ordnumber > '' select @ord_hdrnumber = ord_hdrnumber from orderheader where ord_number = @p_ordnumber
select @ord_hdrnumber = isnull(@ord_hdrnumber,0)
if @p_invoicenumber  > '' select @ivh_hdrnumber = ivh_hdrnumber
from invoiceheader where ivh_invoicenumber = @p_invoicenumber 
select @ivh_hdrnumber = isnull(@ivh_hdrnumber,0)

/* **** SEARCH BY DATE ONLY ***** */
If (@p_fromdate > '19500101 00:00' or @p_todate < '20491231 23:59') and @ord_hdrnumber = 0 and @ivh_hdrnumber = 0
	SELECT [ct_id]
	  ,[pyd_number]
	  ,[pyh_number]
	  ,[ord_hdrnumber]
	  ,[lgh_number]
	  ,[ct_date]
	  ,[pyt_itemcode]
	  ,[ct_amount]
	  ,[tar_number]
	  ,[ord_status]
	  ,[asgn_type]
	  ,[asgn_id]
	  ,[pyd_status]
	  ,[pyh_status]
	  ,[ct_quantity]
	  ,[ct_isbackout]
	  ,[ct_updatedby]
	  ,[ct_updatesource]
	From cost_tracker with (NOLOCK)
	where ct_date between @p_fromdate and @p_todate 
	order by ct_id

/* **** SEARCH BY DATE and order ***** */
If (@p_fromdate > '19500101 00:00' or @p_todate < '20491231 23:59') and @ord_hdrnumber > 0 and @ivh_hdrnumber = 0
	SELECT [ct_id]
	  ,[pyd_number]
	  ,[pyh_number]
	  ,[ord_hdrnumber]
	  ,[lgh_number]
	  ,[ct_date]
	  ,[pyt_itemcode]
	  ,[ct_amount]
	  ,[tar_number]
	  ,[ord_status]
	  ,[asgn_type]
	  ,[asgn_id]
	  ,[pyd_status]
	  ,[pyh_status]
	  ,[ct_quantity]
	  ,[ct_isbackout]
	  ,[ct_updatedby]
	  ,[ct_updatesource]
	From cost_tracker with (NOLOCK)
  where ct_date between @p_fromdate and @p_todate
  and ord_hdrnumber = @ord_hdrnumber
  order by ct_id
  
/* **** SEARCH BY DATE AND INVOICE ***** */
If (@p_fromdate > '19500101 00:00' or @p_todate < '20491231 23:59') and @ord_hdrnumber = 0 and @ivh_hdrnumber > 0
	SELECT [ct_id]
	  ,[pyd_number]
	  ,[pyh_number]
	  ,[ord_hdrnumber]
	  ,[lgh_number]
	  ,[ct_date]
	  ,[pyt_itemcode]
	  ,[ct_amount]
	  ,[tar_number]
	  ,[ord_status]
	  ,[asgn_type]
	  ,[asgn_id]
	  ,[pyd_status]
	  ,[pyh_status]
	  ,[ct_quantity]
	  ,[ct_isbackout]
	  ,[ct_updatedby]
	  ,[ct_updatesource]
	From cost_tracker with (NOLOCK)
  where ct_date between @p_fromdate and @p_todate
  and ord_hdrnumber = (select ord_hdrnumber from invoiceheader where ivh_hdrnumber = @ivh_hdrnumber)
  order by ct_id
  
/* **** SEARCH BY ORDER ONLY ***** */
If @p_fromdate = '19500101 00:00' and @p_todate = '20491231 23:59' and @ord_hdrnumber > 0 and @ivh_hdrnumber = 0
	SELECT [ct_id]
	  ,[pyd_number]
	  ,[pyh_number]
	  ,[ord_hdrnumber]
	  ,[lgh_number]
	  ,[ct_date]
	  ,[pyt_itemcode]
	  ,[ct_amount]
	  ,[tar_number]
	  ,[ord_status]
	  ,[asgn_type]
	  ,[asgn_id]
	  ,[pyd_status]
	  ,[pyh_status]
	  ,[ct_quantity]
	  ,[ct_isbackout]
	  ,[ct_updatedby]
	  ,[ct_updatesource]
	From cost_tracker with (NOLOCK)
  where ord_hdrnumber = @ord_hdrnumber
  order by ct_id


/* **** SEARCH BY INVOICE ONLY ***** */
If @p_fromdate = '19500101 00:00' and @p_todate = '20491231 23:59' and @ord_hdrnumber = 0 and @ivh_hdrnumber > 0
	SELECT [ct_id]
	  ,[pyd_number]
	  ,[pyh_number]
	  ,[ord_hdrnumber]
	  ,[lgh_number]
	  ,[ct_date]
	  ,[pyt_itemcode]
	  ,[ct_amount]
	  ,[tar_number]
	  ,[ord_status]
	  ,[asgn_type]
	  ,[asgn_id]
	  ,[pyd_status]
	  ,[pyh_status]
	  ,[ct_quantity]
	  ,[ct_isbackout]
	  ,[ct_updatedby]
	  ,[ct_updatesource]
	From cost_tracker with (NOLOCK)
  where ord_hdrnumber = (select ord_hdrnumber from invoiceheader where ivh_hdrnumber = @ivh_hdrnumber)
  order by ct_id

-- SELECT ALL  
If  @p_fromdate = '19500101 00:00' and @p_todate = '20491231 23:59' and @ord_hdrnumber = 0 and @ivh_hdrnumber = 0
	SELECT [ct_id]
	  ,[pyd_number]
	  ,[pyh_number]
	  ,[ord_hdrnumber]
	  ,[lgh_number]
	  ,[ct_date]
	  ,[pyt_itemcode]
	  ,[ct_amount]
	  ,[tar_number]
	  ,[ord_status]
	  ,[asgn_type]
	  ,[asgn_id]
	  ,[pyd_status]
	  ,[pyh_status]
	  ,[ct_quantity]
	  ,[ct_isbackout]
	  ,[ct_updatedby]
	  ,[ct_updatesource]
	From cost_tracker with (NOLOCK)
  where 0 = 1
  order by ct_id

GO
GRANT EXECUTE ON  [dbo].[cost_tracker_list] TO [public]
GO
