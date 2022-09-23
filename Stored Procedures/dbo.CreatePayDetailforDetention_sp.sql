SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create proc [dbo].[CreatePayDetailforDetention_sp] 
	(@p_ord_number varchar(12), 
     @p_event varchar(6), 
     @p_quantity float)
as

/**
 * 
 * NAME:
 * dbo.CreatePayDetailforDetention_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:	Creates a pay detail for detention.  Zero rate.  
 * The first segment with a matching event is used.  
 * Pays the driver is acct-type is not none.  Pays tractor otherwise.
 * 
 * RETURNS:	error code
 *  -1 - no matching order
 *  -2 - no stop matching event parameter
 *  -3 - no paytype matching event parameter
 * 
 * RESULT SETS: None
 * 
 * PARAMETERS:
 *	@p_ord_number	varchar(12)
 *	@p_event		varchar(8)
 *	@p_quantity		float
 *
 * REFERENCES: NONE
 * 
 * REVISION HISTORY:
 * Date ? 		PTS# - 	AuthorName	 ? Revision Description
 * 06/24/2008	42757	SLM				Initial Creation of Stored Procedure for Modern Transportation, Inc.
 *										called from their Imaging system to create Pay Details for Detention 
 * 07/09/2008	42757	vjh				Continue development
 **/

declare	@ord_hdrnumber	int,
		@asgn_id		varchar(13),
		@asgn_type		varchar(6),
		@pyt_itemcode	varchar(6),
		@stp_sequence	int,
		@pyd_number		int, 
		@user			varchar (255),
		@pyt_rateunit	varchar(6), 
		@pyt_unit		varchar(6),
		@pyt_pretax		char(1),
		@pyd_prorap		char(1),
		@pyd_payto		varchar(12), 
		@pyd_minus		int,
		@mov_number		int,
		@asgn_number	int,
		@lgh_number		int

select @ord_hdrnumber = ord_hdrnumber from orderheader where ord_number = @p_ord_number
if @ord_hdrnumber is null return -1

select @user = suser_sname()
select @pyt_itemcode = case when @p_event = 'PU' then 'PUPDET' else 'DELDET' end
select @pyt_rateunit = pyt_rateunit,
	   @pyt_unit     = pyt_unit,
	   @pyt_pretax   = pyt_pretax
from   paytype where pyt_itemcode = @pyt_itemcode

if @pyt_pretax is null return -3

If @pyt_pretax = 'Y'
	select @pyd_minus = 1
Else
	select @pyd_minus = -1

--find first stop that has an event type that matches PU or DR and use assets from that leg.
select @stp_sequence = min(s.stp_sequence)
from orderheader o 
join stops s on o.ord_hdrnumber = s.ord_hdrnumber
join eventcodetable e on e.abbr = s.stp_event
where o.ord_number = @p_ord_number
and e.fgt_event = @p_event + 'P'
if @stp_sequence is null return -2

select @lgh_number = lgh_number, @mov_number = mov_number from stops where ord_hdrnumber = @ord_hdrnumber and stp_sequence = @stp_sequence

if exists (select 1 
from assetassignment a
join manpowerprofile m on a.asgn_id = m.mpp_id
 where lgh_number = @lgh_number and asgn_type = 'DRV'
and mpp_actg_type <> 'N')
begin
	select @asgn_type = 'DRV'
end else begin
	select @asgn_type = 'TRC'
end

select @asgn_id = min(asgn_id) from assetassignment where asgn_type = @asgn_type and lgh_number = @lgh_number

while @asgn_id is not null begin
	if @asgn_type = 'DRV' begin
		--any drv specific processing pluss bail if driver actg is none
		if not exists (select 1 from manpowerprofile where mpp_id = @asgn_id and mpp_actg_type <> 'N') break
	end

	exec dbo.getpayto_sp @asgn_type, @asgn_id, @pyd_payto output, @pyd_prorap output
	select @asgn_number = min(asgn_number) from assetassignment where asgn_type = @asgn_type and asgn_id = @asgn_id and lgh_number = @lgh_number
	execute @pyd_number = dbo.getsystemnumber N'PYDNUM', NULL
	
	INSERT INTO paydetail
	( pyd_number, pyh_number, lgh_number, asgn_number, asgn_type, asgn_id,
	  pyt_itemcode, mov_number, pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
	  pyd_rate, pyd_amount, pyd_currency, pyd_currencydate, pyd_status, pyd_refnumtype, pyd_workperiod, 
	  pyd_minus, pyh_payperiod, pyd_transdate, pyd_pretax, pyd_payto, pyd_prorap, 
	  pyt_fee1, pyt_fee2, pyd_grossamount, ivd_number, lgh_startpoint, lgh_startcity, 
	  lgh_endpoint, lgh_endcity, pyd_updatedby, ord_hdrnumber, pyd_adj_flag, pyd_loadstate, psd_id, pyd_sequence, pyd_releasedby, pyd_updsrc ) 
	VALUES 
	( @pyd_number, 0, @lgh_number, @asgn_number, @asgn_type, @asgn_id, 
	  @pyt_itemcode, @mov_number, 'FLT', @p_quantity, 'HR', 'HRS', 
	  0.0000, 0.0000, 'UNK', getdate(), 'HLD', '', getdate(), 
	  @pyd_minus, getdate(), getdate(), @pyt_pretax, @pyd_payto, @pyd_prorap, 
	  0.0000, 0.0000, 0.0000, @ord_hdrnumber, 'UNKNOWN', 0, 
	  'UNKNOWN', 0, @user, @ord_hdrnumber, 'N', 'NA', 0, 100, @user, 'M' )


	select @asgn_id = min(asgn_id) from assetassignment where asgn_type = @asgn_type and lgh_number = @lgh_number and asgn_id > @asgn_id
end

return 1
grant execute on dbo.CreatePayDetailforDetention_sp to public
GO
