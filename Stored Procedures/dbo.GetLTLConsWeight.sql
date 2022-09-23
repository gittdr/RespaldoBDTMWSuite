SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[GetLTLConsWeight]  (@p_ordhdrnumber int, @p_consignee varchar(8),@p_totalweight decimal(9,1) OUTPUT)
as
/*
 * Assumptions. Rate by detail (consignee is delivery location)
 *    All orders have only one delivery location
 *
 * Set ouptut variable equal to the total weight delivered to a single location for this customer 
 * on this move (across all commodities)
 *
 * PTS44417 DPETE created
 * PTS 49619 DPETE wants LTL weight on invoice to oveeride wgt ont freight record
 *    assumes adjustment is to the ivd_wgt field not the ivd_quantity
*/

declare @mov int,@billto varchar(8),@consignee varchar(8)

declare @invoices table (ord_hdrnumber int,ivh_hdrnumber int null)
declare @invoicefgt table(fgt_number int, ivd_wgt float)

select @billto = ord_billto,@mov = mov_number ,@consignee = ord_consignee
from orderheader 
where ord_hdrnumber = @p_ordhdrnumber
/* table of other existing invoices for these orders */
/*  assumes invoices are never split */
insert into @invoices
select ord_hdrnumber,max(ivh_hdrnumber) from invoiceheader 
where mov_number = @mov 
and ivh_billto = @billto
and ivh_definition in ('LH','RBIL')


group by ord_hdrnumber

/*  table of weights fron the last invoice for the order */
Insert into @invoicefgt
select fgt_number, ivd_wgt
from @invoices invoices
join invoicedetail on invoices.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
where fgt_number > 0



select  @p_totalweight = sum(case isnull(invfgt.ivd_wgt,-1) 
    when -1 then isnull(fgt_weight,0)
    else invfgt.ivd_wgt
    end) 
from orderheader
join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber  
join freightdetail on stops.stp_number = freightdetail.stp_number 
left outer join @invoicefgt invfgt on freightdetail.fgt_number = invfgt.fgt_number
where orderheader.mov_number = @mov 
and ord_billto = @billto
and ord_consignee = @consignee
and stp_type = 'DRP'

GO
GRANT EXECUTE ON  [dbo].[GetLTLConsWeight] TO [public]
GO
