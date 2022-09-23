SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_post_legheader_processing]
	@mov int

as

declare @lgh int, @lgh_204status varchar(6), @lgh_outstatus varchar(6), @ord_ordhdr int, @ord_number varchar(12), @ord_edistate tinyint

select @lgh = min(lgh_number) from legheader where mov_number = @mov
if isnull(@lgh, 0) > 0
begin
	select @lgh_204status = legheader.lgh_204status, @lgh_outstatus = legheader.lgh_outstatus
	     , @ord_ordhdr = orderheader.ord_hdrnumber, @ord_number = orderheader.ord_number, @ord_edistate = orderheader.ord_edistate
	  from legheader
	 inner join orderheader
	    on legheader.ord_hdrnumber = orderheader.ord_hdrnumber
	 where legheader.lgh_number = @lgh

	if @ord_edistate = 12
	begin
		if @lgh_204status = 'TDA' and @lgh_outstatus = 'DSP'
		begin
			exec dx_edi_orderstate_update @ord_ordhdr, 22, 'DSP'
			exec dx_create_990_from_204 @ord_number, 'A'
		end

		if @lgh_204status IN ('TND','TDR') and @lgh_outstatus = 'AVL'
			exec dx_edi_orderstate_update @ord_ordhdr, 32, 'PND'
	end
end

return

GO
GRANT EXECUTE ON  [dbo].[dx_post_legheader_processing] TO [public]
GO
