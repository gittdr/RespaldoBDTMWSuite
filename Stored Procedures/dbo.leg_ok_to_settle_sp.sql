SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE proc [dbo].[leg_ok_to_settle_sp]  (
	@p_leg				int,
	@StlMustInv			char(1),
	@StlMustInvLH		char(60),
	@SplitMustInv		char(1),
	@StlMustOrd			char(1),
	@ps_CRBST			char(1), --ComputeRevenueByTripSegment
	@ps_invstat1		varchar(60),
	@ps_invstat2		varchar(60),
	@ps_invstat3		varchar(60),
	@ps_invstat4		varchar(60),
	@ps_returnvalue		varchar(60) output
	)

AS  
BEGIN
/**
 * 
 * NAME:
 * dbo.leg_ok_to_settle_sp
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * This proc replaces logic strung throughout d_scroll_assignments and
 * w_stlmnt_edit::wf_retrieveit, where settings SplitMustINV,
 * STLMustINV and StlXInvStat are applied.  It also introduces 2 changes:
 *   1. Cross Dock legs now become order aware
 *   2. Invoice by Move is supported
 *
 * RETURNS:
 * Y/N
 *
 * RESULT SETS: 
 * na
 *
 * PARAMETERS:
 *	001 - @p_leg			int
 *	002 - @ps_StlMustInv	char(1),
 *	003 - @ps_SplitMustInv	char(1),
 *	004 - @StlMustOrd		char(1),
 *	005 - @ps_CRBST			char(1), --ComputeRevenueByTripSegment
 *	006 - @ps_invstat1		varchar(60),
 *	007 - @ps_invstat2		varchar(60),
 *	008 - @ps_invstat3		varchar(60),
 *	009 - @ps_invstat4		varchar(60)
 *	010 - @ps_returnvalue	varchar(60) (output)
 *
 * REVISION HISTORY:
 * 03/30/09.01 PTS45562, PTS44306 - vjh - created function
 * 07/20/09.01 PTS47363 - vjh - Added LH functionality
 * 09/23/10.01 PTS52942 - vjh - add SLTMUSTORD to control restriction legs unless all orders on that led are complete.
 * 04/25/11.01 PTS56345 - vjh - better handle SPLITMUSTINV=N, STLMUSTINV=Y, STLMUSTORD=Y
 * 09/14/11    PTS58060 - vjh - Add SPLITMUSTINV=L
 * 12/06/13    PTS70636 - vjh - with stlmustinv='Y' and splitmustinv='L', non-split orders were erroneously being passed without an invoice
 *
 **/

declare	@ordlist	varchar(200)
declare	@minordhdr	int

CREATE TABLE #temp_Orders (
	lgh_number		int		null,
	ord_hdrnumber	int		null,
	Inv_OK_Flag		char(1)	null,
	Ord_OK_Flag		char(1)	null,
	split_flag		char(1) null )

if @stlmustinv = 'Y' or @StlMustOrd = 'Y' begin
	--get the orders we need to consider
	if @splitmustinv ='Y' or @StlMustOrd = 'Y' begin
		insert #temp_Orders
		select @p_leg, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
		from legheader l
		join stops s on l.lgh_number = s.lgh_number
		where s.lgh_number = @p_leg and s.ord_hdrnumber > 0
	end else begin
		if @splitmustinv ='N' begin
			--PTS58060
			--@splitmustinv = 'N' so only need to check for orders on stops with drop events
			insert #temp_Orders
			select @p_leg, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
			from legheader l
			join stops s on l.lgh_number = s.lgh_number
			join event e on e.stp_number = s.stp_number
			join eventcodetable ect on ect.abbr = e.evt_eventcode and fgt_event='DRP'
			where s.lgh_number = @p_leg and s.ord_hdrnumber > 0
		end else begin
			--PTS58060
			--@splitmustinv = 'L' so only need to check for orders on stops on last leg
			insert #temp_Orders
			select @p_leg, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
			from legheader l
			join stops s on l.lgh_number = s.lgh_number
			join event e on e.stp_number = s.stp_number
			where s.lgh_number = @p_leg and s.ord_hdrnumber > 0
			--and l.lgh_split_flag = 'F'	--vjh 70636 need to include non-split orders here, too.
			and l.lgh_split_flag in ('F', 'N')
		end
	end
end 

if @splitmustinv = 'N' begin
	--vjh 56345  splits without drops do not require invoicesif @splitmustinv = 'N'
	update #temp_Orders set Inv_OK_Flag = 'Y' 
	where not exists (
		select 1 from legheader l
		join stops s on l.lgh_number = s.lgh_number
		join event e on e.stp_number = s.stp_number
		join eventcodetable ect on ect.abbr = e.evt_eventcode and fgt_event='DRP'
		where s.lgh_number = @p_leg and s.ord_hdrnumber > 0
	)
end

if @splitmustinv = 'L' begin
	--PTS58060
	--@splitmustinv = 'L' so only need to check for orders on stops on last leg
	update #temp_Orders set Inv_OK_Flag = 'Y' 
	where split_flag = 'S'
end

if @StlMustOrd = 'Y' begin
	--@StlMustOrd = 'Y'
	update #temp_Orders set Ord_OK_Flag = 'Y' 
	where exists (select * 
					from orderheader o 
					where o.ord_hdrnumber = #temp_Orders.ord_hdrnumber
					and o.ord_status = 'CMP')				
end else begin
	--@StlMustOrd = 'N'
	update #temp_Orders set Ord_OK_Flag = 'Y' 
end

--now look at the invoices.
if @ps_invstat1 <> '' begin
	if @stlmustinv = 'Y' begin
		--@ps_invstat1 and @stlmustinv = 'Y'
		--update if any invoice exists for the order and the invoice status is not in the exclude list
		update #temp_Orders set Inv_OK_Flag = 'Y' 
		where exists (select * 
						from invoiceheader i 
						where i.ord_hdrnumber = #temp_Orders.ord_hdrnumber
						and ivh_invoicestatus not in (@ps_invstat1,@ps_invstat2,@ps_invstat3,@ps_invstat4)
						and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )
		or exists (select * 
						from invoiceheader i
						join invoicemaster on ivm_invoiceordhdrnumber = i.ord_hdrnumber
						where invoicemaster.ord_hdrnumber = #temp_Orders.ord_hdrnumber
						and ivh_invoicestatus not in (@ps_invstat1,@ps_invstat2,@ps_invstat3,@ps_invstat4)
						and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )
	end else begin
		--@ps_invstat1 and @stlmustinv = 'N'
		update #temp_Orders set Inv_OK_Flag = 'Y' 
	end	
end else begin --@ls_invstat1 = ''
	if @stlmustinv = 'Y' begin
		--update if any invoice exists for the order AND the order is on complete status
		update #temp_Orders set #temp_Orders.Inv_OK_Flag = 'Y' 
		where (
			exists (select * 
						from invoiceheader i 
						where i.ord_hdrnumber = #temp_Orders.ord_hdrnumber
						and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )
			or exists (select * 
						from invoiceheader i
						join invoicemaster on ivm_invoiceordhdrnumber = i.ord_hdrnumber
						where invoicemaster.ord_hdrnumber = #temp_Orders.ord_hdrnumber
						and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL'))	
		)
	end else begin
		--@ps_invstat1='' and @stlmustinv = 'N'
		update #temp_Orders set Inv_OK_Flag = 'Y' 
	end
end

if exists (select * from #temp_Orders where Inv_OK_Flag = 'N' or Ord_OK_Flag = 'N') begin
	set @ps_returnvalue = 'N'
	--blow on the orders
	select @ordlist=''
	select @minordhdr = min(ord_hdrnumber) from #temp_Orders where Inv_OK_Flag = 'N' or Ord_OK_Flag = 'N'
	while @minordhdr is not null begin
		select @ordlist=@ordlist + ' ' + ord_number from orderheader where ord_hdrnumber = @minordhdr
		select @minordhdr = min(ord_hdrnumber) from #temp_Orders where ord_hdrnumber > @minordhdr and (Inv_OK_Flag = 'N' or Ord_OK_Flag = 'N')
	end
	select @ps_returnvalue = @ps_returnvalue + left(@ordlist,59)
end else
	begin
		set @ps_returnvalue = 'Y'
	end
END
GO
GRANT EXECUTE ON  [dbo].[leg_ok_to_settle_sp] TO [public]
GO
