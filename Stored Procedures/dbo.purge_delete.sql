SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Object:  Stored Procedure dbo.purge_delete    Script Date: 01/23/98 17:09 ******/
--purge sql for exel - pgmr: db
/*
Added to Mainline for foreign key support if StopTrailer

This procedure is called from powerbuilder for each move number it finds
in the purgework table.  The procedure takes two arguments:

  1 The integer move number to delete

  2 An integer flag that indicates whether the order should be checked before
    removal.  If 1 the system checks for order status = cancel or complete.  If
    0 the system does not perform this check and the move is delete w/o
    regard to status.
*/

CREATE PROCEDURE [dbo].[purge_delete]
	@mov int,
	@check int
AS

declare @ord_count integer, @sql varchar(200)

if @mov is null 
	return

begin transaction

if @check = 1
	select @ord_count = count(ord_hdrnumber)
	 from orderheader
	 where mov_number = @mov
	   and ( ord_status = 'CMP' or ord_status = 'CAN' )
else
	select @ord_count = 1

if @ord_count > 0 
begin

	/* reference number (stops) */
	delete referencenumber
	 from stops s, referencenumber r
	 where r.ref_table = 'stops'
	   and r.ref_tablekey = s.stp_number
	   and s.mov_number = @mov

	/* reference number (invoiceheader) */
	delete referencenumber
	 from referencenumber r, invoiceheader i
	 where r.ref_table = 'invoiceheader'
	   and r.ref_tablekey = i.ivh_hdrnumber
	   and i.mov_number = @mov

	/* reference number (orderheader) */
	delete referencenumber
	 from referencenumber r, orderheader o
	 where r.ref_table = 'orderheader'
	   and r.ref_tablekey = o.ord_hdrnumber
	   and o.mov_number = @mov

	/* reference number (legheader) */
	delete referencenumber
	 from referencenumber r, legheader l
	 where r.ref_table = 'legheader'
	   and r.ref_tablekey = l.lgh_number
	   and l.mov_number = @mov

	/* reference number frieghtdetail */
	delete referencenumber
	 from referencenumber r, stops s, freightdetail f
	 where ref_table = 'freightdetail'
	   and r.ref_tablekey = f.fgt_number and
		f.stp_number = s.stp_number
	        and s.mov_number = @mov

	/* invoice detail (non-invoiced orders) -- FMM PTS 41966 */
	delete invoicedetail	
	 from orderheader oh, invoicedetail id
	 where oh.ord_hdrnumber = id.ord_hdrnumber
	   and id.ivh_hdrnumber = 0
	   and oh.mov_number = @mov

	/* invoice detail */
	delete invoicedetail
	 from invoiceheader ih, invoicedetail id
	 where ih.ivh_hdrnumber = id.ivh_hdrnumber
	   and ih.mov_number = @mov

	/* invoice header */
	delete from invoiceheader
	 where mov_number = @mov

	/* trip_modification_log */
	delete trip_modification_log
         from trip_modification_log t, stops s
         where t.stp_number = s.stp_number
	   and s.mov_number = @mov

	/* trip_export */
	delete trip_export
         from trip_export t, stops s
         where t.stp_number = s.stp_number
           and s.mov_number = @mov

	/* StopTrailer */
	delete StopTrailer
         from StopTrailer st, stops s
         where st.stp_number = s.stp_number
           and s.mov_number = @mov	

	/* stops */
	delete from stops
	 where mov_number = @mov

	/* event */
	/* event is deleted through dt_stops trigger on stops table */

	/* assetassignment */
	delete assetassignment
         from assetassignment a, legheader l
         where a.lgh_number = l.lgh_number
	   and l.mov_number = @mov

	/* fuel purchase */
	delete from fuelpurchased         where mov_number = @mov

	/* fuel tax */
	delete from fueltax
         where mov_number = @mov

	/* MCMESSAGE */
	delete from MCMESSAGE
	 where MOV_NUMBER = @mov

	/* driverpayexport */
	delete from driverpayexport
         where mov_number = @mov

	delete notes
	 from notes n, orderheader o
	 where n.ntb_table = 'orderheader'
	   and n.nre_tablekey = o.ord_number
           and o.mov_number = @mov

	delete notes
	 from notes n, orderheader o
	 where n.ntb_table = 'orderheader'
	   and n.nre_tablekey = convert(varchar(15),o.ord_hdrnumber)
           and o.mov_number = @mov

	/* order_queue */
	delete order_queue
	 from order_queue oq, orderheader o
         where oq.ord_hdrnumber = o.ord_hdrnumber
           and o.mov_number = @mov


	/* paperworkmisc */
		
	delete from paperworkmisc where pw_ident in (select p.pw_ident from paperwork p, orderheader o
         where p.ord_hdrnumber = o.ord_hdrnumber
           and o.mov_number = @mov)

	/* paperwork */
	delete paperwork
	 from paperwork p, orderheader o
         where p.ord_hdrnumber = o.ord_hdrnumber
           and o.mov_number = @mov

	/* schedule */
	delete schedule_table
	 from schedule_table s, orderheader o
         where s.ord_hdrnumber = o.ord_hdrnumber
           and o.mov_number = @mov

	/* orderheader */
	delete from orderheader
	 where mov_number = @mov

	/* payheader */
	delete payheader
	 from payheader ph, paydetail pd, legheader
	 where ph.pyh_pyhnumber = pd.pyh_number and
		legheader.lgh_number = pd.lgh_number
	   and legheader.mov_number = @mov

	/* paydetail */
	delete paydetail
	from legheader
	 where legheader.mov_number = @mov and
	        legheader.lgh_number = paydetail.lgh_number	
		


	/* legheader */
	delete from legheader
	 where mov_number = @mov


	/* purgework */
	delete purgework
	 where mov_number = @mov

    /* freight by compartment */
    If object_id('freight_by_compartment') is not null 
      delete freight_by_compartment
      where mov_number = @mov
end

commit transaction


GO
GRANT EXECUTE ON  [dbo].[purge_delete] TO [public]
GO
