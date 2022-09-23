SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*****************************************************************************************
Revisions:
35209 BDH 01/05/2007  	Orig draft. 
37982 BDH 07/03/2007	Eliminated nulls from final select.
******************************************************************************************/


create proc [dbo].[d_eeview_res_sp] @userid varchar(10)
as

create table #filters(viewid varchar(6), viewname varchar(50))
	
declare @dv_validviews varchar(255),	
	@viewid varchar(6),
	@viewname varchar(50)


if exists (select 1 from dvassign where dva_userid = @userid and dv_type = 'EE')
begin		
	
	--PTS 46499 JJF 20091130
	INSERT	#filters(viewid, viewname)
	SELECT	'UNK',
			'UNKNOWN'
	--PTS 46499 JJF 20091130

	select @dv_validviews = (select dv_validviews from dvassign where dv_type = 'EE' and dva_userid = @userid)

	if isnull(@dv_validviews, '') = '' 
	begin
		insert #filters(viewid, viewname) select caf_viewid, caf_viewname from carrierfilter where isnull(caf_viewid, '') <> ''
	end
	else
	begin
		select @viewid = (select min(caf_viewid) from carrierfilter) 
		while len(@viewid) > 0
		begin
			
			if charindex(@viewid, @dv_validviews) > 0 
			begin
				select @viewname = (select min(caf_viewname) from carrierfilter where caf_viewid = @viewid)
				insert #filters(viewid, viewname) values (@viewid, @viewname)
			end
		
			select @viewid = (select min(caf_viewid) from carrierfilter where caf_viewid > @viewid)	
		end
	end

	select * from #filters
end
else
begin
	--PTS 46499 JJF 20091130
	--select caf_viewid, caf_viewname from carrierfilter where isnull(caf_viewid, '') <> ''
	select	caf_viewid, 
			caf_viewname 
	from	carrierfilter 
	where	isnull(caf_viewid, '') <> ''
	
	UNION
	
	SELECT	'UNK',
			'UNKNOWN'
	--END PTS 46499 JJF 20091130

	
end

drop table #filters

GO
GRANT EXECUTE ON  [dbo].[d_eeview_res_sp] TO [public]
GO
