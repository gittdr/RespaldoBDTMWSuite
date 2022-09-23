SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[purgetrailercommhistory] @keepdays int, @debug int=0
as
SET NOCOUNT ON;
declare @startdate datetime;
declare @minid int, @checkid int, @purgetargetcount int, @totalpurgecount int;
declare @worktrailer varchar(13);
declare @purgetargets table (
                tchId int,
                ckc_number int null);

select @startdate=DATEADD(D, -@keepdays, GETDATE()), @totalpurgecount=0;

select @worktrailer = MIN(trl_id) from trailercommhistory
while(@worktrailer is not null)
begin
	if @debug <> 0 print convert(varchar(30), getdate(), 126)+': Starting '+@worktrailer
	while (1=1)
	begin
				IF @keepdays > 0 
					insert into @purgetargets (tchId, ckc_number)
					select top 10000 tch_id, ckc_number from trailercommhistory where trl_id = @worktrailer and tch_dttm < @startdate order by tch_dttm
				ELSE
					insert into @purgetargets (tchId, ckc_number)
					select top 10000 tch_id, ckc_number from trailercommhistory where trl_id = @worktrailer and tch_dttm > @startdate order by tch_dttm DESC
                
                select @purgetargetcount = COUNT(*) FROM @purgetargets
                if @purgetargetcount = 0 BREAK;
                
                if @debug <> 0 
					begin
	                select @totalpurgecount = @totalpurgecount + @purgetargetcount
					print convert(varchar(30), getdate(), 126)+': Deleting '+ convert(varchar(20), @purgetargetcount) + '=>' +convert(varchar(20), @totalpurgecount)
					end

                delete from checkcall
                from @purgetargets p where p.ckc_number is not null and checkcall.ckc_number = p.ckc_number;

                delete from traileralarmresolutions
                from 
                traileralarmdetail inner join @purgetargets on traileralarmdetail.tch_id = tchId
                where traileralarmresolutions.tadr_original_tad_id = traileralarmdetail.tad_id;
                
                delete from traileralarmdetail
                from @purgetargets where traileralarmdetail.tch_id = tchId;
                
                delete from trailercommhistory
                from @purgetargets where trailercommhistory.tch_id = tchId;
                
                DELETE FROM @purgetargets;
                if @debug <> 0 print convert(varchar(30), getdate(), 126)+': Deleted '+ convert(varchar(20), @purgetargetcount) + '=>' +convert(varchar(20), @totalpurgecount)
	end
	select @worktrailer = MIN(trl_id) from trailercommhistory where trl_id > @worktrailer
end
if @debug <> 0 print 'Done: Purged ' + convert(varchar(20), @totalpurgecount) + ' records'
GO
