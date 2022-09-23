SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[autogenerate_tariffratehistory_sp](@pl_tarnum int) as
declare @ll_row int, @ll_col int,@fr_dt datetime, @to_dt datetime,@ldec_rate money
set nocount on
If exists (select * from tariffheader where tar_number = @pl_tarnum)
begin
	delete from tariffratehistory where tar_number = @pl_tarnum and 
	not exists (select * from tariffrate where tar_number =@pl_tarnum and  tariffrate.trc_number_row = tariffratehistory.trc_number_row)

	delete from tariffratehistory where tar_number = @pl_tarnum and 
	not exists (select * from tariffrate where tar_number =@pl_tarnum and tariffrate.trc_number_col = tariffratehistory.trc_number_col)

	If not exists (select * from tariffratehistory where tar_number = @pl_tarnum) 
	BEGIN
		insert into tariffratehistory (tar_number, trc_number_row,trc_number_col,trh_fromdate,trh_todate,tra_rate)
		select tar_number, trc_number_row,trc_number_col,IsNull(tra_activedate,'19500101 00:00:00'),IsNull(tra_retired,'20491231 23:59:59'),tra_rate
		from tariffrate
		where tar_number = @pl_tarnum  
	END
		insert into tariffratehistory (tar_number, trc_number_row,trc_number_col,trh_fromdate,trh_todate,tra_rate)
		select tar_number, trc_number_row,trc_number_col,IsNull(tra_activedate,'19500101 00:00:00'),IsNull(tra_retired,'20491231 23:59:59'),tra_rate
		from tariffrate
		where tar_number = @pl_tarnum  and not exists (select * from tariffratehistory b where b.tar_number = tariffrate.tar_number and 
		b.trc_number_row = tariffrate.trc_number_row and b.trc_number_col = tariffrate.trc_number_col)
end 
--		If exists (select * from tariffrate where tar_number = @pl_tarnum and (tra_activedate is not null or tra_retired  is not null))
--		BEGIN
--			Select @ll_row = 0 , @ll_col = 0
--			While 1 = 1 
--			BEGIN
--				select	@ll_row = min(trc_number_row)
--				from	tariffrate where tar_number = @pl_tarnum and trc_number_row > @ll_row and
--						(tra_activedate is not null or tra_retired  is not null)
--
--				If @ll_row is null 
--					break
--				select @ll_col = 0
--				While 2 = 2 
--				BEGIN
--					select	@ll_col = min(trc_number_col)
--					from	tariffrate where tar_number = @pl_tarnum and trc_number_row = @ll_row and
--							trc_number_col > @ll_col and
--							(tra_activedate is not null or tra_retired  is not null)
--					If @ll_col is null
--						break
--					select @fr_dt = IsNull(tra_activedate,'19500101 00:00:00') ,@to_dt = isnull(tra_retired,'20491231 23:59:59'), @ldec_rate = tra_rate from tariffrate where trc_number_row = @ll_row and trc_number_col = @ll_col
--					--select @fr_dt,@to_dt,@ll_row,@ll_col
--					If @fr_dt > '19500102 00:00:00'
--						insert into tariffratehistory (tar_number, trc_number_row,trc_number_col,trh_fromdate,trh_todate,tra_rate)
--						select @pl_tarnum, @ll_row,@ll_col,'19500101 00:00:00',dateadd(ss,-1,@fr_dt),0
--
--					If @to_dt < '20491230 23:59:59'
--					Begin
--						insert into tariffratehistory (tar_number, trc_number_row,trc_number_col,trh_fromdate,trh_todate,tra_rate)
--						select @pl_tarnum, @ll_row,@ll_col,@fr_dt,@to_dt,@ldec_rate
--						insert into tariffratehistory (tar_number, trc_number_row,trc_number_col,trh_fromdate,trh_todate,tra_rate)
--						select @pl_tarnum, @ll_row,@ll_col,dateadd(ss,1,@to_dt),'20491230 23:59:59',0
--
--					end
--					else
--						insert into tariffratehistory (tar_number, trc_number_row,trc_number_col,trh_fromdate,trh_todate,tra_rate)
--						select @pl_tarnum, @ll_row,@ll_col,dateadd(ss,1,@to_dt),'20491231 23:59:59',@ldec_rate
--					
--				END	  			
--			END
--		END
	

If exists (select * from tariffheaderstl where tar_number = @pl_tarnum)
	If not exists (select * from tariffratehistorystl where tar_number = @pl_tarnum) 
	 insert into tariffratehistorystl (tar_number, trc_number_row,trc_number_col,trh_fromdate,trh_todate,tra_rate)
	select tar_number, trc_number_row,trc_number_col,'19500101 00:00:00','20491231 23:59:59',tra_rate
	from tariffratestl
	where tar_number = @pl_tarnum

GO
GRANT EXECUTE ON  [dbo].[autogenerate_tariffratehistory_sp] TO [public]
GO
