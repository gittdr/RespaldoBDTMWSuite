SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_EDIUpdateMatchedCommodityFromArchive]
	(@p_commodityid varchar(8),
	 @p_identity int)
as

declare @tmwuser varchar(20), @xrefid int, @tpid varchar(20), @cmdname varchar(60), @extendedid varchar(30)

--exec gettmwuser @tmwuser OUTPUT
exec dx_gettmwuser @tmwuser OUTPUT

select @tpid = ord_editradingpartner, @cmdname = rtrim(isnull(dx_field013,'')), @extendedid = rtrim(isnull(dx_field023,''))
  from dx_archive
 inner join orderheader
    on dx_orderhdrnumber = ord_hdrnumber
 where dx_ident = @p_identity

if @tpid is null
	return -1

if @extendedid > ''
	select @cmdname = @extendedid
	
select @xrefid = xref.cmd_xref_id 
  from commodity_xref xref
 where xref.cmd_name = @cmdname
   and xref.src_system = 'EDI'
   and xref.src_tradingpartner = @tpid

if @xrefid is null
	insert commodity_xref
		(cmd_id, cmd_name, crt_date, src_system, upd_date, upd_count, upd_by, src_tradingpartner)
	values (@p_commodityid, @cmdname, getdate(), 'EDI', getdate(), 1, @tmwuser, @tpid)
else
	update commodity_xref
	   set cmd_id = @p_commodityid
	     , upd_date = getdate()
	     , upd_count = upd_count + 1
	     , upd_by = @tmwuser
	 where cmd_xref_id = @xrefid

if @@ERROR <> 0 
	return -1

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_EDIUpdateMatchedCommodityFromArchive] TO [public]
GO
