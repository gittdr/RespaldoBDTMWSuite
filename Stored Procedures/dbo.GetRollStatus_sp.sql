SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetRollStatus_sp] @ord INT, @status VARCHAR(6) OUT
AS
/* 5-9-07 jg use table variable to reduce recompiles.
*/
SET NOCOUNT ON
declare @rss TABLE(
status varchar(6),
revtype1	varchar(6),
revtype2	varchar(6),
revtype3	varchar(6),
revtype4	varchar(6),
nmatch int)

insert into @rss
select 
rss_status
		, case rss_revtype1	when 'UNK' THEN 'ZZZZZZ' ELSE rss_revtype1 END 
		, case rss_revtype2	when 'UNK' THEN 'ZZZZZZ' ELSE rss_revtype2 END 
		, case rss_revtype3	when 'UNK' THEN 'ZZZZZZ' ELSE rss_revtype3 END 
		, case rss_revtype4	when 'UNK' THEN 'ZZZZZZ' ELSE rss_revtype4 END 
		, 0
	from RollSettlementStatus rss
	join orderheader o ON
		rss_revtype1 = ord_revtype1
		and (rss_revtype2 = ord_revtype2 OR rss_revtype2 = 'UNK')
		and (rss_revtype3 = ord_revtype3 OR rss_revtype3 = 'UNK')
		and (rss_revtype4 = ord_revtype4 OR rss_revtype4 = 'UNK')
		and o.ord_hdrnumber = @ord

update @rss
set nmatch = nmatch + 1
where revtype2 <> 'ZZZZZZ'

update @rss
set nmatch = nmatch + 1
where revtype3 <> 'ZZZZZZ'

update @rss
set nmatch = nmatch + 1
where revtype4 <> 'ZZZZZZ'

select Top 1 @status = status from @rss
order by nmatch desc, revtype2, revtype3, revtype4

IF ISNULL(@status, '') = ''
	SET @status = 'NO'
--	SET @status = ''


GO
GRANT EXECUTE ON  [dbo].[GetRollStatus_sp] TO [public]
GO
