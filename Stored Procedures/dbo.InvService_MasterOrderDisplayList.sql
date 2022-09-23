SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[InvService_MasterOrderDisplayList] @cmp_id varchar(8)
as

declare @ord table(ord_hdrnumber int NOT NULL,
		ord_number varchar(12) not null,
		ord_billto varchar(8) not null, 
		ord_shipper varchar(8) not null)

insert @ord
select orderheader.ord_hdrnumber, ord_number, ord_billto, ord_shipper
from orderheader 
where ord_consignee = @cmp_id and ord_status = 'MST'


select ord.ord_hdrnumber, ord.ord_number, ord.ord_billto, ord.ord_shipper, isnull(f1.cmd_Code,'UNK') + isnull(', '+f2.cmd_Code,'')  + isnull(', '+f3.cmd_Code,'') + isnull(', '+f4.cmd_Code,'')  as commodities
from @ord as ord join stops on ord.ord_hdrnumber = stops.ord_hdrnumber   
				left outer join freightdetail as f1 on f1.stp_number = stops.stp_number and f1.fgt_sequence = 1 
				left outer join freightdetail as f2 on f2.stp_number = stops.stp_number and f2.fgt_sequence = 2 
                left outer join freightdetail as f3 on f3.stp_number = stops.stp_number and f3.fgt_sequence = 3 
                left outer join freightdetail as f4 on f4.stp_number = stops.stp_number and f4.fgt_sequence = 4 
where stops.stp_event = 'LUL' and stops.cmp_id = @cmp_id
GO
GRANT EXECUTE ON  [dbo].[InvService_MasterOrderDisplayList] TO [public]
GO
