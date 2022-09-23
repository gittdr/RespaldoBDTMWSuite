SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[revenue_tracker_list] (@p_ordnumber varchar(13),@p_invoicenumber varchar(13),@p_fromdate datetime,@p_todate datetime )
AS


/* to retrieve revenue_tracker data for an order or an invoice or for a date/time range


Created 6/4/10 DPETE PTS51844
6/28/10 DPETE 51844 changes add additiona fields
01/21/11 DPETE Add rvt_billmiels and rvt_billemptymiles to return set  55494 (subset of 55393)

*/
declare @ord_hdrnumber int,@ivh_hdrnumber int,@bookedname varchar(30),@Rev1Name varchar(30),@Rev2Name varchar(30),@Rev3Name varchar(30),@Rev4Name varchar(30)
declare @trakbranch char(1) 
select @trakbranch = left(gi_string1,1)from generalinfo where gi_name = 'trackbranch'
if @trakbranch = 'Y'
  select @bookedname = max(userlabelname) from labelfile where labeldefinition = 'branch'
else
  select @bookedname = max(userlabelname) from labelfile where labeldefinition = 'BookedRevType1' and abbr = 'UNK'
select @Rev1Name = max(userlabelname) from labelfile where labeldefinition = 'RevType1' and abbr = 'UNK'
select @Rev2Name = max(userlabelname) from labelfile where labeldefinition = 'RevType2' and abbr = 'UNK'
select @Rev3Name = max(userlabelname) from labelfile where labeldefinition = 'RevType3' and abbr = 'UNK'
select @Rev4Name = max(userlabelname) from labelfile where labeldefinition = 'RevType4' and abbr = 'UNK'


If @p_ordnumber > '' select @ord_hdrnumber = ord_hdrnumber from orderheader where ord_number = @p_ordnumber
select @ord_hdrnumber = isnull(@ord_hdrnumber,0)
if @p_invoicenumber  > '' select @ivh_hdrnumber = ivh_hdrnumber  --,@ord_hdrnumber = ord_hdrnumber  
from invoiceheader where ivh_invoicenumber = @p_invoicenumber 
select @ivh_hdrnumber = isnull(@ivh_hdrnumber,0)

/* **** SEARCH BY DATE ONLY ***** */
If (@p_fromdate > '19500101 00:00' or @p_todate < '20491231 23:59') and @ord_hdrnumber = 0 and @ivh_hdrnumber = 0
  Select  
  ord_number = isnull(ord.ord_number,'') 
  ,ivh_invoicenumber = isnull(ivh.ivh_invoicenumber,'')
  ,rvt.ivh_definition
  ,rvt_date
  ,rvt_amount
  ,rvt.tar_number
  ,rvt.cur_code
  ,rvt_IsBackout
  ,trackstatus = 
    case rvt.ivh_hdrnumber 
    when 0 then case rvt.ord_status when '???' then '' else rvt.ord_status end
    else case rvt.ivh_invoicestatus when '???' then '' else rvt.ivh_invoicestatus end
    end
  ,rvt_updatedby
  ,rvt_updatesource
  ,ord_booked_revtype1
  ,ord_revtype1
  ,ord_revtype2
  ,ord_revtype3
  ,ord_revtype4
  ,ord_booked_revtype1_t = @bookedname
  ,RevType1_t = @Rev1Name 
  ,RevType2_t = @Rev2Name 
  ,RevType3_t = @Rev3Name 
  ,RevType4_t = @Rev4Name
  ,rvt_appname
  ,rvt_quantity
  ,ivd_number
  ,rvt_rateby 
  ,isnull(rvt_billmiles,0.0) rvt_billmiles
  ,ISNULL(rvt_billemptymiles,0.0) rvt_bilemptymiles
  
  From revenue_tracker rvt  with (NOLOCK)
  left outer join orderheader ord on rvt.ord_hdrnumber = ord.ord_hdrnumber
  left outer join invoiceheader ivh on rvt.ivh_hdrnumber = ivh.ivh_hdrnumber
  where rvt.rvt_date between @p_fromdate and @p_todate 
  order by rvt_id

/* **** SEARCH BY DATE and order ***** */
If (@p_fromdate > '19500101 00:00' or @p_todate < '20491231 23:59') and @ord_hdrnumber > 0 and @ivh_hdrnumber = 0
  Select  
  ord_number = isnull(ord.ord_number,'')
  ,ivh_invoicenumber = isnull(ivh.ivh_invoicenumber,'')
  ,rvt.ivh_definition
  ,rvt_date
  ,rvt_amount
  ,rvt.tar_number
  ,rvt.cur_code
  ,rvt_IsBackout
  ,status = 
    case rvt.ivh_hdrnumber 
    when 0 then case rvt.ord_status when '???' then '' else rvt.ord_status end
    else case rvt.ivh_invoicestatus when '???' then '' else rvt.ivh_invoicestatus end
    end
  ,rvt_updatedby
  ,rvt_updatesource
  ,ord_booked_revtype1
  ,ord_revtype1
  ,ord_revtype2
  ,ord_revtype3
  ,ord_revtype4
  ,ord_booked_revtype1_t = @bookedname
  ,RevType1_t = @Rev1Name 
  ,RevType2_t = @Rev2Name 
  ,RevType3_t = @Rev3Name 
  ,RevType4_t = @Rev4Name 
  ,rvt_appname
  ,rvt_quantity
  ,ivd_number
  ,rvt_rateby
  ,isnull(rvt_billmiles,0.0) rvt_billmiles
  ,ISNULL(rvt_billemptymiles,0.0) rvt_bilemptymiles
  
  From revenue_tracker rvt  with (NOLOCK)
  left outer join orderheader ord on rvt.ord_hdrnumber = ord.ord_hdrnumber
  left outer join invoiceheader ivh on rvt.ivh_hdrnumber = ivh.ivh_hdrnumber
  where rvt.rvt_date between @p_fromdate and @p_todate
  and rvt.ord_hdrnumber = @ord_hdrnumber
  order by rvt_id
/* **** SEARCH BY DATE AND INVOICE ***** */
If (@p_fromdate > '19500101 00:00' or @p_todate < '20491231 23:59') and @ord_hdrnumber = 0 and @ivh_hdrnumber > 0
  Select  
  ord_number = isnull(ord.ord_number,'')
  ,ivh_invoicenumber = isnull(ivh.ivh_invoicenumber,'')
  ,rvt.ivh_definition
  ,rvt_date
  ,rvt_amount
  ,rvt.tar_number
  ,rvt.cur_code
  ,rvt_IsBackout
  ,status = 
    case rvt.ivh_hdrnumber 
    when 0 then case rvt.ord_status when '???' then '' else rvt.ord_status end
    else case rvt.ivh_invoicestatus when '???' then '' else rvt.ivh_invoicestatus end
    end
  ,rvt_updatedby
  ,rvt_updatesource
  ,ord_booked_revtype1
  ,ord_revtype1
  ,ord_revtype2
  ,ord_revtype3
  ,ord_revtype4
  ,ord_booked_revtype1_t = @bookedname
  ,RevType1_t = @Rev1Name 
  ,RevType2_t = @Rev2Name 
  ,RevType3_t = @Rev3Name 
  ,RevType4_t = @Rev4Name
  ,rvt_appname
  ,rvt_quantity
  ,ivd_number
  ,rvt_rateby 
  ,isnull(rvt_billmiles,0.0) rvt_billmiles
  ,ISNULL(rvt_billemptymiles,0.0) rvt_bilemptymiles
 
  From revenue_tracker rvt  with (NOLOCK)
  left outer join orderheader ord on rvt.ord_hdrnumber = ord.ord_hdrnumber
  left outer join invoiceheader ivh on rvt.ivh_hdrnumber = ivh.ivh_hdrnumber
  where rvt.rvt_date between @p_fromdate and @p_todate
  and rvt.ivh_hdrnumber = @ivh_hdrnumber
  order by rvt_id
/* **** SEARCH BY ORDER ONLY ***** */
If @p_fromdate = '19500101 00:00' and @p_todate = '20491231 23:59' and @ord_hdrnumber > 0 and @ivh_hdrnumber = 0
  Select  
  ord_number = isnull(ord.ord_number,'')
  ,ivh_invoicenumber = isnull(ivh.ivh_invoicenumber,'')
  ,rvt.ivh_definition
  ,rvt_date
  ,rvt_amount
  ,rvt.tar_number
  ,rvt.cur_code
  ,rvt_IsBackout
  ,status = 
    case rvt.ivh_hdrnumber 
    when 0 then case rvt.ord_status when '???' then '' else rvt.ord_status end
    else case rvt.ivh_invoicestatus when '???' then '' else rvt.ivh_invoicestatus end
    end
  ,rvt_updatedby
  ,rvt_updatesource
  ,ord_booked_revtype1
  ,ord_revtype1
  ,ord_revtype2
  ,ord_revtype3
  ,ord_revtype4
  ,ord_booked_revtype1_t = @bookedname
  ,RevType1_t = @Rev1Name 
  ,RevType2_t = @Rev2Name 
  ,RevType3_t = @Rev3Name 
  ,RevType4_t = @Rev4Name
  ,rvt_appname
  ,rvt_quantity
  ,ivd_number
  ,rvt_rateby
  ,ISNULL(rvt_billmiles,0.0) rvt_billmiles
  ,ISNULL(rvt_billemptymiles,0.0) rvt_bilemptymiles
  
  From revenue_tracker rvt  with (NOLOCK)
  left outer join orderheader ord on rvt.ord_hdrnumber = ord.ord_hdrnumber
  left outer join invoiceheader ivh on rvt.ivh_hdrnumber = ivh.ivh_hdrnumber
  where rvt.ord_hdrnumber = @ord_hdrnumber
  order by rvt_id
/* **** SEARCH BY INVOICE ONLY ***** */
If @p_fromdate = '19500101 00:00' and @p_todate = '20491231 23:59' and @ord_hdrnumber = 0 and @ivh_hdrnumber > 0
  Select  
  ord_number = isnull(ord.ord_number,'')
  ,ivh_invoicenumber = isnull(ivh.ivh_invoicenumber,'')
  ,rvt.ivh_definition
  ,rvt_date
  ,rvt_amount
  ,rvt.tar_number
  ,rvt.cur_code
  ,rvt_IsBackout
  ,status = 
    case rvt.ivh_hdrnumber 
    when 0 then case rvt.ord_status when '???' then '' else rvt.ord_status end
    else case rvt.ivh_invoicestatus when '???' then '' else rvt.ivh_invoicestatus end
    end
  ,rvt_updatedby
  ,rvt_updatesource
  ,ord_booked_revtype1
  ,ord_revtype1
  ,ord_revtype2
  ,ord_revtype3
  ,ord_revtype4
  ,ord_booked_revtype1_t = @bookedname
  ,RevType1_t = @Rev1Name 
  ,RevType2_t = @Rev2Name 
  ,RevType3_t = @Rev3Name 
  ,RevType4_t = @Rev4Name 
  ,rvt_appname
  ,rvt_quantity
  ,ivd_number
  ,rvt_rateby
  ,ISNULL(rvt_billmiles,0.0) rvt_billmiles
  ,ISNULL(rvt_billemptymiles,0.0) rvt_bilemptymiles

  From revenue_tracker rvt  with (NOLOCK)
  left outer join orderheader ord on rvt.ord_hdrnumber = ord.ord_hdrnumber
  left outer join invoiceheader ivh on rvt.ivh_hdrnumber = ivh.ivh_hdrnumber
  where rvt.ivh_hdrnumber = @ivh_hdrnumber
  order by rvt_id
If  @p_fromdate = '19500101 00:00' and @p_todate = '20491231 23:59' and @ord_hdrnumber = 0 and @ivh_hdrnumber = 0
  Select  
  ord_number = ''
  ,ivh_invoicenumber = ''
  ,rvt.ivh_definition
  ,rvt_date
  ,rvt_amount
  ,rvt.tar_number
  ,rvt.cur_code
  ,rvt_IsBackout
  ,status = 
    case rvt.ivh_hdrnumber 
    when 0 then case rvt.ord_status when '???' then '' else rvt.ord_status end
    else case rvt.ivh_invoicestatus when '???' then '' else rvt.ivh_invoicestatus end
    end
  ,rvt_updatedby
  ,rvt_updatesource
  ,ord_booked_revtype1 = ''
  ,ord_revtype1 = ''
  ,ord_revtype2 = ''
  ,ord_revtype3 = ''
  ,ord_revtype4 = ''
  ,ord_booked_revtype1_t = @bookedname
  ,RevType1_t = @Rev1Name 
  ,RevType2_t = @Rev2Name 
  ,RevType3_t = @Rev3Name 
  ,RevType4_t = @Rev4Name
  ,rvt_appname
  ,rvt_quantity
  ,ivd_number
  ,rvt_rateby
  ,ISNULL(rvt_billmiles,0.0) rvt_billmiles
  ,ISNULL(rvt_billemptymiles,0.0) rvt_bilemptymiles 
 
  From revenue_tracker rvt  with (NOLOCK)
  where 0 = 1

GO
GRANT EXECUTE ON  [dbo].[revenue_tracker_list] TO [public]
GO
