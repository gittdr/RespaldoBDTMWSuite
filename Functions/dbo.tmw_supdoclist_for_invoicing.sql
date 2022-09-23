SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create function [dbo].[tmw_supdoclist_for_invoicing] (@cmp_id varchar(8), @ivh_hdrnumber int)
RETURNS varchar(2048)

AS
/*  
Created for CRST (PTS49226 by Keith Mader  ) 10/13/09

KM changes 10/13 Handle doc sequence and eliminate duplicates

*/


BEGIN
DECLARE	@doclist	varchar(2048),
		@nextcharge	varchar(6),
		@lastcharge	varchar(6)


DECLARE @doctypelist table (level			int,
							cmp_id			varchar(8),
							doctype			varchar(6),
							cht_itemcode	varchar(6),
							typesequence	int)

DECLARE @chargelist	table	(cht_itemcode	varchar(6))

INSERT @chargelist	(cht_itemcode)
					(select distinct cht_itemcode
					from	invoicedetail with (nolock)
					where	ivh_hdrnumber = @ivh_hdrnumber)

INSERT @doctypelist (level,
					cmp_id,
					doctype,
					cht_itemcode,
					typesequence)
					(select 1,
					@cmp_id,
					bdt_doctype,
					'NA',
					bdt_sequence
					from	billdoctypes with (nolock)
					where	bdt_inv_attach = 'Y' AND
							cmp_id = @cmp_id)


set @lastcharge = ''
set @nextcharge = ''
while 1 = 1
BEGIN
  select	@nextcharge = min(cht_itemcode)
  from		@chargelist
  where		cht_itemcode > @lastcharge

  If @nextcharge is null BREAK

  Insert @doctypelist (level,
					cmp_id, 
					doctype,
					cht_itemcode,
					typesequence)
					(select distinct 2,
					@cmp_id,
					chargetypepaperwork.cpw_paperwork,
					chargetype.cht_itemcode,
					cpw_sequence
					from		chargetype with (nolock)
					inner join	chargetypepaperwork with (nolock) on chargetype.cht_number = chargetypepaperwork.cht_number
					where		cht_itemcode = @nextcharge AND
								chargetypepaperwork.cpw_inv_attach = 'Y' AND
								not exists (select * 
											from @doctypelist 
											where doctype = chargetypepaperwork.cpw_paperwork))

  select @lastcharge = @nextcharge

END

SET @doclist = '' --we can't concatenate NULLs so make empty string

SELECT @doclist = @doclist + case when doctype is null then '' else doctype + ',' end
FROM @doctypelist 
where level = 1
order by typesequence, doctype

SELECT @doclist = @doclist + case when doctype is null then '' else doctype + ',' end
FROM @doctypelist 
where level = 2
order by cht_itemcode, typesequence, doctype

If Right(@doclist, 1) = ','
	set @doclist = left(@doclist, len(@doclist)-1)

RETURN @doclist

END
GO
GRANT EXECUTE ON  [dbo].[tmw_supdoclist_for_invoicing] TO [public]
GO
