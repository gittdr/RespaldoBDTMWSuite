SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[d_reftriplist_sp] @ordhdr int
As
/*
   MODIFICATION LOG
*DPETE PTS14202 created to return a list of trip information for editing all order refs in invoicing (found QDI slashes in city nmstct are sometimes backwards)
*5/21/07 JG PTS37616, add ord_hdrnumber > 0 to improve performance
* 12/6/08 PTS 43837 DPETE allow invoicing by mov
 * 1/17/09 DPETE PTS44417 invoice by move/consignee 'CON'
*/

declare @billto varchar(8),@mov int,@invoiceby varchar(3),@ordnum varchar(12)
declare @ords table (ord_hdrnumber int null,ord_number varchar(12) null, ordseq int identity)
declare @consignee varchar(8)

select @billto = ord_billto,@mov = mov_number ,@invoiceby = isnull(cmp_invoiceby,'ORD'),@ordnum = ord_number
,@consignee = ord_consignee
from orderheader join company on ord_billto = cmp_id
where ord_hdrnumber = @ordhdr

If @invoiceby = 'ORD'
  insert into @ords (ord_hdrnumber,ord_number) select @ordhdr,@ordnum
If @invoiceby = 'MOV'
  insert into @ords (ord_hdrnumber,ord_number) 
  select ord_hdrnumber,ord_number
  from orderheader where mov_number = @mov
  and ord_billto = @billto
  order by ord_number
If @invoiceby = 'CON'
  insert into @ords (ord_hdrnumber,ord_number) 
  select ord_hdrnumber,ord_number
  from orderheader where mov_number = @mov
  and ord_billto = @billto
  and ord_consignee = @consignee
  order by ord_number

Select s.stp_number,stp_sequence = stp_sequence ,stp_seq = (ords.ordseq * 100000) +(stp_sequence * 1000),stp_event, city = cty_nmstct,
--city = left( cty_nmstct,Charindex('/',cty_nmstct) - 1), 
fgt_number, fgt_sequence, fgt_seq = (ords.ordseq * 100000) +(stp_sequence * 1000) + fgt_sequence,fgt_description,stp_type,
s.ord_hdrnumber, ords.ord_number, ord_seq = ords.ordseq * 100000,ords.ord_number
from @ords ords
     join stops s on ords.ord_hdrnumber = s.ord_hdrnumber
     LEFT OUTER JOIN city c ON c.cty_code = s.stp_city 
	 join freightdetail f on s.stp_number = f.stp_number
Where  s.ord_hdrnumber > 0         --pts37616
and s.stp_type in ('PUP','DRP')
--and s.stp_number = f.stp_number
--and c.cty_code =* s.stp_city
--order by stp_sequence,fgt_sequence
order by fgt_seq
GO
GRANT EXECUTE ON  [dbo].[d_reftriplist_sp] TO [public]
GO
