SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_EDIUnmatchedCommodityIdent] (@p_ordhdr int)
as

declare @v_sourcedate datetime, @v_tpid varchar(20), @cmd_gravity float

select @v_sourcedate = max(dx_sourcedate)
  from dx_archive WITH (NOLOCK)
 where dx_importid = 'dx_204'
   and dx_orderhdrnumber = @p_ordhdr

if @v_sourcedate is null return 0

select @v_tpid = ord_editradingpartner
  from orderheader
 where ord_hdrnumber = @p_ordhdr

if isnull(@v_tpid,'') = '' return 0

if isnull((select dx_xrefkey from dx_xref where dx_importid = 'dx_204' and dx_trpid = @v_tpid and dx_entitytype = 'TPSettings' and dx_entityname = 'MatchCommodities'),'0') = '1'
begin
	declare @cmdmatches table
		(Ident int, OrderHdrNumber int, MoveNumber int, StopNumber int, FreightNumber int, CommodityName varchar(60),
		 TmwCmdID varchar(8), TmwWeight float, TmwGravity bit)
	
	insert @cmdmatches
		(Ident, OrderHdrNumber, MoveNumber, StopNumber, FreightNumber, CommodityName, TmwCmdID, TmwWeight, TmwGravity)
	select dx_ident, dx_orderhdrnumber, dx_movenumber, dx_stopnumber, dx_freightnumber
		 , case when rtrim(isnull(dx_field023,'')) > '' then rtrim(dx_field023) else rtrim(dx_field013) end, freightdetail.cmd_code, freightdetail.fgt_weight
	     , case when isnull(freightdetail.fgt_weight,0.0) > 0.0 and isnull(freightdetail.fgt_volume,0.0) = 0.0 and freightdetail.fgt_weightunit = 'LBS' then 1 else 0 end
	  from dx_archive (NOLOCK)
	 inner join freightdetail
	    on dx_freightnumber = fgt_number
	 where dx_importid = 'dx_204'
	   and dx_orderhdrnumber = @p_ordhdr
	   and dx_sourcedate = @v_sourcedate
	   and dx_field001 = '04'
	   and (RTRIM(ISNULL(dx_field023,'')) > '' OR RTRIM(ISNULL(dx_field013,'')) > '')
	 order by dx_ident
	
	delete @cmdmatches where isnull(TmwCmdID,'') <> 'UNKNOWN'
	
	if (select count(1) from @cmdmatches) = 0 return 0
	
	declare @v_ident int, @v_cmdid varchar(8), @v_cmdname varchar(60), @v_stpnum int, @v_fgtnum int, @v_fgtseq int, 
		@v_weight float, @v_gravity bit, @v_volume float
	select @v_ident = 0
	
	while 1=1
	begin
		select @v_ident = min(Ident) from @cmdmatches where Ident > @v_ident
		if @v_ident is null
			break
		select @v_cmdid = null
		select @v_cmdid = MAX(cmd_id)
		  from commodity_xref xref
		 inner join @cmdmatches dx
		    on xref.cmd_name = dx.CommodityName
		   and xref.src_system = 'EDI'
		   and xref.src_tradingpartner = @v_tpid
		 where dx.Ident = @v_ident
	
		if @v_cmdid is null
			break
	
		--if (select count(1) from commodity where cmd_code = @v_cmdid) = 0
		select @cmd_gravity = ISNULL(cmd_specificgravity, 0.0) from commodity where cmd_code = @v_cmdid
		if @@rowcount = 0
		begin
			delete commodity_xref where cmd_id = @v_cmdid
			select @v_ident = @v_ident - 1
			continue
		end
		else
			select @v_cmdname = cmd_name from commodity where cmd_code = @v_cmdid
	
		select @v_stpnum = StopNumber, @v_fgtnum = FreightNumber, @v_weight = TmwWeight, @v_gravity = TmwGravity
		  from @cmdmatches where Ident = @v_ident

		if @v_gravity = 1 and @cmd_gravity > 0.0
			select @v_volume = CEILING(CEILING(@v_weight) / CEILING(@cmd_gravity))
	
		if (select fgt_sequence from freightdetail where fgt_number = @v_fgtnum) = 1
		begin
			if @v_gravity = 1 and @cmd_gravity > 0.0
				update stops
				   set cmd_code = @v_cmdid, stp_description = @v_cmdname, stp_volume = @v_volume, stp_volumeunit = 'GAL'
				 where stp_number = @v_stpnum
			else
				update stops
				   set cmd_code = @v_cmdid, stp_description = @v_cmdname
				 where stp_number = @v_stpnum
		end
		else
		begin
			if @v_gravity = 1 and @cmd_gravity > 0.0
				update freightdetail
				   set cmd_code = @v_cmdid, fgt_description = @v_cmdname, fgt_volume = @v_volume, fgt_volumeunit = 'GAL'
				 where fgt_number = @v_fgtnum
			else
				update freightdetail
				   set cmd_code = @v_cmdid, fgt_description = @v_cmdname
				 where fgt_number = @v_fgtnum
		end
	end
	
	return isnull(@v_ident, 0)
end
else
	return 0

GO
GRANT EXECUTE ON  [dbo].[dx_EDIUnmatchedCommodityIdent] TO [public]
GO
