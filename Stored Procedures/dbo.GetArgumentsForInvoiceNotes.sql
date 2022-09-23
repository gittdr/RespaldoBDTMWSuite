SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetArgumentsForInvoiceNotes] (@p_ordhdrnumber int)
As
/* MODIFICSTION LOG
  9/30/10 Created DPETE 9/30/10 For Carter who wants to access pop notes in splti billing whihc has almost none of the notes arguments information
  10/12/10 need oto add comma sep list of all stop companies
*/


Declare @delivery_lghnumber int,@MovNumber int
declare @Driver1 varchar(8), @driver2 varchar(8), @tractor varchar(8), @trailer1 varchar(13)
declare @trailer2 varchar(13), @carrier varchar(8), @shipper varchar(8), @consignee varchar(8)
declare @billto varchar(8), @invoicenumber varchar(13)
declare @tstops table (ord_hdrnumber int,stp_number int,mov_number int)
declare @commodities varchar(255)
declare @commoditytable table (cmd_code varchar(8))
declare @ordnumber varchar(12)
declare @stopcompanies varchar(2000)

select @stopcompanies = ''

select @stopcompanies = @stopcompanies + cmp_id + '^'
from orderheader
join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber
where orderheader.ord_hdrnumber = @p_ordhdrnumber
and stp_type in ('PUP','DRP')
and stops.cmp_id <> orderheader.ord_shipper
and stops.cmp_id <> orderheader.ord_consignee
and stops.cmp_id <> orderheader.ord_billto

select @ordnumber = ord_number from orderheader where ord_hdrnumber = @p_ordhdrnumber

insert into @commoditytable
select Distinct freightdetail.cmd_code
from stops
join freightdetail on stops.stp_number = freightdetail.stp_number
where stops.ord_hdrnumber =  @p_ordhdrnumber
and stp_type = 'DRP'

select @commodities = ''
select @commodities = @commodities + cmd_code + '^'
from @commoditytable


insert into @tstops
select  top 1 ord_hdrnumber,stp_number,mov_number
from stops 
where  ord_hdrnumber = @p_ordhdrnumber and stp_type = 'DRP' 
order by stp_arrivaldate desc

select  @invoicenumber  = 
(select top 1 ivh_invoicenumber from invoiceheader where ord_hdrnumber = @p_ordhdrnumber order by ivh_hdrnumber asc)

select evt_driver1
,evt_driver2
,evt_tractor
,evt_trailer1
,evt_trailer2
,evt_carrier
,ord_billto
,ord_shipper
,ord_consignee
,tstops.mov_number
,isnull(@invoicenumber,'') ivh_invoicenumber
,@commodities commodities
,@ordnumber
,@stopcompanies
from orderheader
join @tstops tstops on orderheader.ord_hdrnumber = tstops.ord_hdrnumber
join event on tstops.stp_number = event.stp_number and event.evt_sequence = 1
where orderheader.ord_hdrnumber = @p_ordhdrnumber
  
  
GO
GRANT EXECUTE ON  [dbo].[GetArgumentsForInvoiceNotes] TO [public]
GO
