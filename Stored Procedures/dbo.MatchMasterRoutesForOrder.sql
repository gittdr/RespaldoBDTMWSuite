SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[MatchMasterRoutesForOrder] (@orderHeaderNumber integer) as create table #temp (ordernumber varchar(12), orderheadernumber integer, movenumber integer, routeid varchar(15) ) insert into #temp (ordernumber, orderheadernumber, movenumber, routeid) select oh1.ord_number, oh1.ord_hdrnumber, oh1.mov_number, oh1.ord_route from orderheader oh1 join orderheader oh2 on (oh1.ord_company = oh2.ord_company and oh1.ord_shipper = oh2.ord_shipper and oh1.ord_consignee = oh2.ord_consignee and oh1.ord_revtype4 = oh2.ord_revtype4 and oh1.trl_type1 = oh2.trl_type1 and oh1.cmd_code = oh2.cmd_code) where oh2.ord_hdrnumber = @orderHeaderNumber and oh1.ord_status = 'MST' select ordernumber, orderheadernumber, movenumber, routeid from #temp 
GO
GRANT EXECUTE ON  [dbo].[MatchMasterRoutesForOrder] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MatchMasterRoutesForOrder] TO [public]
GO
