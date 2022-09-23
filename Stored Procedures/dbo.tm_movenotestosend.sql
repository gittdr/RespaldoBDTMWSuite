SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
--PTS 44013 SGB Change the unique identifier for Billto companies from 7 to 3 so it corrects duplicates if Billto is alos a stop company
*/

CREATE PROC [dbo].[tm_movenotestosend] @lgh_number int=0
AS

declare @mov_number int
declare @use_large_notes char (1)
-- thirdpartyprofile, thirdpartyprofile, carrier, trailerprofile, tractorprofile, manpowerprofile, movement, orderheader, TASK, invoiceheader, payheader, company 
-- order, driver, tractor, trailer, movement, company

set nocount on

select @mov_number=mov_number from legheader where lgh_number=@lgh_number
select @use_large_notes = gi_string1 from generalinfo where gi_name = 'UseLargeNotes'
if @use_large_notes is null
	select @use_large_notes = 'N'
	
declare @noteslist table (not_number integer, ntb_table char(18), nre_tablekey char(18), nlt_reportedkey varchar(18), nlt_typeseq int)
declare @unique_list table (not_number integer, nre_tablekey char(18))
--create table #notes(nre_tablekey char(18), not_text varchar(max), nlt_typeseq int, not_sequence int)

insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'orderheader', orderheader.ord_hdrnumber, 'ORD: ' + CONVERT(varchar(13), orderheader.ord_number), 2 
	from stops 
	inner join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber 
	where stops.mov_number = @mov_number and isnull(stops.ord_hdrnumber, 0)<>0
	-- PTS 44013 SGB 10/27/08 Changed 7 to 3 so that Billto comapny has the same value as the stop companies
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'company', orderheader.ord_billto, 'COMP: ' + orderheader.ord_billto, 3 from stops inner join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber where stops.mov_number = @mov_number and isnull( orderheader.ord_billto, 'UNKNOWN')<>'UNKNOWN'
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'invoiceheader', invoiceheader.ivh_hdrnumber, 'INV: ' + invoiceheader.ivh_invoicenumber, 8 from stops inner join invoiceheader on stops.ord_hdrnumber = invoiceheader.ord_hdrnumber where stops.mov_number = @mov_number and isnull(invoiceheader.ivh_hdrnumber, 0)<>0
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select 'movement', @mov_number, 'MOV: ' + CONVERT(varchar(13), @mov_number), 1 where isnull(@mov_number, 0) <> 0
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'company', cmp_id, 'COMP: ' + cmp_id, 3 from stops where lgh_number = @lgh_number and isnull(cmp_id, 'UNKNOWN')<>'UNKNOWN'
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'manpowerprofile', event.evt_driver1, 'DRV: ' + event.evt_driver1, 4 from stops inner join event on stops.stp_number = event.stp_number where stops.lgh_number = @lgh_number and isnull(event.evt_driver1, 'UNKNOWN')<>'UNKNOWN'
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'manpowerprofile', event.evt_driver2, 'DRV: ' + event.evt_driver2, 4 from stops inner join event on stops.stp_number = event.stp_number where stops.lgh_number = @lgh_number and isnull(event.evt_driver2, 'UNKNOWN')<>'UNKNOWN'
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'tractorprofile', event.evt_tractor, 'TRC: ' + event.evt_tractor, 5 from stops inner join event on stops.stp_number = event.stp_number where stops.lgh_number = @lgh_number and isnull(event.evt_tractor, 'UNKNOWN')<>'UNKNOWN'
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'trailerprofile', event.evt_trailer1, 'TRL: ' + event.evt_trailer1, 6 from stops inner join event on stops.stp_number = event.stp_number where stops.lgh_number = @lgh_number and isnull(event.evt_trailer1, 'UNKNOWN')<>'UNKNOWN'
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'trailerprofile', event.evt_trailer2, 'TRL: ' + event.evt_trailer2, 6 from stops inner join event on stops.stp_number = event.stp_number where stops.lgh_number = @lgh_number and isnull(event.evt_trailer2, 'UNKNOWN')<>'UNKNOWN'
--JLB PTS 32232 add carrier and commodity notes to the queue
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'commodity', freightdetail.cmd_code, 'CMD: ' + freightdetail.cmd_code, 9 from freightdetail inner join stops on stops.stp_number = freightdetail.stp_number where stops.lgh_number = @lgh_number and isnull(freightdetail.cmd_code, 'UNKNOWN')<>'UNKNOWN'
insert @noteslist(ntb_table, nre_tablekey, nlt_reportedkey, nlt_typeseq)
	select distinct 'carrier', event.evt_carrier, 'CAR: ' + event.evt_carrier, 10 from stops inner join event on stops.stp_number = event.stp_number where stops.lgh_number = @lgh_number and isnull(event.evt_carrier, 'UNKNOWN')<>'UNKNOWN'

update x
	set x.not_number = n.not_number 
	from notes n, @noteslist x 
	where n.ntb_table = x.ntb_table 
	and n.nre_tablekey = x.nre_tablekey
	and n.not_tmsend=1
insert into @unique_list	
	select Distinct not_number, nre_tablekey from @noteslist

--select * from @unique_list

if @use_large_notes = 'Y' 
	select u.nre_tablekey, CAST (not_text_large as varchar (8000)) as not_text_large
		from @unique_list u inner join notes on u.not_number = notes.not_number 
		where notes.not_tmsend=1 
		and datalength(not_text_large) > 0
	-- PTS 34434 -- BL (start)
		and not_expires > getdate()
	-- PTS 34434 -- BL (end)
else
	select u.nre_tablekey, not_text
		from @unique_list u inner join notes on u.not_number = notes.not_number 
		where notes.not_tmsend=1 
		and isnull(notes.not_text, '') <> ''
	-- PTS 34434 -- BL (start)
		and not_expires > getdate()
	-- PTS 34434 -- BL (end)

GO
GRANT EXECUTE ON  [dbo].[tm_movenotestosend] TO [public]
GO
