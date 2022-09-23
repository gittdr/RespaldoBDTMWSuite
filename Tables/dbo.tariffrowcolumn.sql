CREATE TABLE [dbo].[tariffrowcolumn]
(
[timestamp] [timestamp] NULL,
[trc_number] [int] NOT NULL,
[tar_number] [int] NOT NULL,
[trc_rowcolumn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trc_sequence] [int] NOT NULL,
[trc_matchvalue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_rangevalue] [money] NULL,
[trc_multimatch] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[trc_rateasflat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_trc_rateasflat] DEFAULT ('N')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tariffrowcol_changelog]
ON [dbo].[tariffrowcolumn]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

declare @updatecount	int,
	@delcount	int, 
	@runtrigger int

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
Select @runtrigger = count(*) from trigger_control with (nolock) where application_name = APP_NAME() and 
		trigger_name = 'iut_tariffrowcol_changelog' and fire_or_not = 0
If @runtrigger > 0
	return

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)
	Update TariffRowColumn
	set last_updateby = @tmwuser,
		last_updatedate = getdate()
	from inserted
	where inserted.trc_number = TariffRowColumn.trc_number
		and (isNull(TariffRowColumn.last_updateby,'') <> @tmwuser
		OR isnull(TariffRowColumn.last_updatedate,'19500101') <> getdate())
	
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--ILB PTS#18486 10/20/03
CREATE TRIGGER [dbo].[ut_tariffrowcol_fingerprinting] ON [dbo].[tariffrowcolumn] FOR UPDATE  AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE 
	   	@ls_user	varchar(20),
		@ldt_updated_dt	datetime,
		@ls_audit	varchar(1), 
	@runtrigger int

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
Select @runtrigger = count(*) from trigger_control with (nolock) where application_name = APP_NAME() and 
		trigger_name = 'ut_tariffs_stl_fingerprinting' and fire_or_not = 0
If @runtrigger > 0
	return

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select	@ls_user = @tmwuser,@ldt_updated_dt = getdate()

--Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
				  from	generalinfo g2
			         where	g2.gi_name = 'FingerprintAudit'
					and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
begin

	--Trc_Number..
	if update(trc_number)
	begin
		/* Update the rows that already exist.  Note below that -5107' is an unlikely string value used
			to represent NULL in comparisons..	*/
		--update	expedite_audit		--this section commented out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row Column Number ' + 
		--		      ltrim(rtrim(isnull(cast(d.trc_number as varchar(20)), 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(cast(i.trc_number as varchar(20)), 'null')))
		--  from	expedite_audit ea
		--		,deleted d
		--		,inserted i
		--  where	i.tar_number = d.tar_number			
		--	and	isnull(i.trc_number, -5107) <> isnull(d.trc_number, -5107)
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff RowCol Update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffrowcolumn'

		--Insert where the row doesn't already exist..
		insert into expedite_audit
				(ord_hdrnumber
				,updated_by
				,activity
				,updated_dt
				,update_note
				,key_value
				,mov_number
				,lgh_number
				,join_to_table_name
				,tar_number)
		  select 	 0
				,@ls_user
				,'Tariff RowCol Update'
				,@ldt_updated_dt
				,' Tariff Row Column Number ' + ltrim(rtrim(isnull(cast(d.trc_number as varchar(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.trc_number as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffrowcolumn'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.trc_number, -5107) <> isnull(d.trc_number, -5107)
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariff RowCol Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffrowcolumn')
	end


	--Trc_RangeValue...
	if update(trc_rangevalue)
	begin
		/* Update the rows that already exist.  Note below that -5107 is an unlikely string value used
			to represent NULL in comparisons..	*/
		--update	expedite_audit		--this section commented out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row Column Range Value' + 
		--		      ltrim(rtrim(isnull(cast(d.trc_rangevalue as varchar(20)), 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(cast(i.trc_rangevalue as varchar(20)), 'null')))
		--  from	expedite_audit ea
		--		,deleted d
		--		,inserted i
		--  where	i.tar_number = d.tar_number			
		--	and	isnull(i.trc_rangevalue, -5107) <> isnull(d.trc_rangevalue, -5107)
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff RowCol Update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffrowcolumn'

		--Insert where the row doesn't already exist..
		insert into expedite_audit
				(ord_hdrnumber
				,updated_by
				,activity
				,updated_dt
				,update_note
				,key_value
				,mov_number
				,lgh_number
				,join_to_table_name
				,tar_number)
		  select 	 0
				,@ls_user
				,'Tariff RowCol Update'
				,@ldt_updated_dt
				,'Tariff Row Column Range Value ' + ltrim(rtrim(isnull(cast(d.trc_rangevalue as varchar(20)) , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.trc_rangevalue as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffrowcolumn'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.trc_rangevalue, -5107) <> isnull(d.trc_rangevalue, -5107)
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariff RowCol Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffrowcolumn')
	end

	--Trc_Sequence..
	if update(trc_sequence)
	begin
		/* Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
			to represent NULL in comparisons..	*/
		--update	expedite_audit		--this section commented out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row Column Sequence' + 
		--		      ltrim(rtrim(isnull(cast(d.trc_sequence as varchar(20)), 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(cast(i.trc_sequence as varchar(20)), 'null')))
		--  from	expedite_audit ea
		--		,deleted d
		--		,inserted i
		--  where	i.tar_number = d.tar_number			
		--	and	isnull(i.trc_sequence, -5107) <> isnull(d.trc_sequence, -5107)
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff RowCol Update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffrowcolumn'

		--Insert where the row doesn't already exist..
		insert into expedite_audit
				(ord_hdrnumber
				,updated_by
				,activity
				,updated_dt
				,update_note
				,key_value
				,mov_number
				,lgh_number
				,join_to_table_name
				,tar_number)
		  select 	 0
				,@ls_user
				,'Tariff RowCol Update'
				,@ldt_updated_dt
				,'Tariff Row Column Sequence ' + ltrim(rtrim(isnull(cast(d.trc_sequence as varchar(20)) , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.trc_sequence as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffrowcolumn'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.trc_sequence, -5107) <> isnull(d.trc_sequence, -5107)
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariff RowCol Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
					--and	ea2.join_to_table_name = 'tariffrowcolumn')
	end

	--Tar_Number..
	if update(tar_number)
	begin
		/* Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
			to represent NULL in comparisons..	*/
		--update	expedite_audit		--this section commented out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row Column Number ' + 
		--		      ltrim(rtrim(isnull(cast(d.tar_number as varchar(20)), 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(cast(i.tar_number as varchar(20)), 'null')))
		--  from	expedite_audit ea
		--		,deleted d
		--		,inserted i
		--  where	i.tar_number = d.tar_number			
		--	and	isnull(i.tar_number, -5107) <> isnull(d.tar_number, -5107)
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff RowCol Update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffrowcolumn'

		--Insert where the row doesn't already exist..
		insert into expedite_audit
				(ord_hdrnumber
				,updated_by
				,activity
				,updated_dt
				,update_note
				,key_value
				,mov_number
				,lgh_number
				,join_to_table_name
				,tar_number)
		  select 	 0
				,@ls_user
				,'Tariff RowCol Update'
				,@ldt_updated_dt
				,'Tariff Row Column Number ' + ltrim(rtrim(isnull(cast(d.tar_number as varchar(20)) , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.tar_number as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffrowcolumn'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_number, -5107) <> isnull(d.tar_number, -5107)
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariff RowCol Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffrowcolumn')
	end


	--Trc_Rowcolumn..
	if update(trc_rowcolumn)
	begin
		/* Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
			to represent NULL in comparisons..	*/
		--update	expedite_audit		--this section commented out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row Column ' + 
		--		      ltrim(rtrim(isnull(d.trc_rowcolumn , 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.trc_rowcolumn, 'null')))
		--  from	expedite_audit ea
		--		,deleted d
		--		,inserted i
		--  where	i.tar_number = d.tar_number			
		--	and	isnull(i.trc_rowcolumn, 'nU1L') <> isnull(d.trc_rowcolumn, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff RowCol Update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffrowcolumn'


		--Insert where the row doesn't already exist..
		insert into expedite_audit
				(ord_hdrnumber
				,updated_by
				,activity
				,updated_dt
				,update_note
				,key_value
				,mov_number
				,lgh_number
				,join_to_table_name
				,tar_number)
		  select 	 0
				,@ls_user
				,'Tariff RowCol Update'
				,@ldt_updated_dt
				,'Tariff Row Column ' + ltrim(rtrim(isnull(d.trc_rowcolumn , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trc_rowcolumn, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffrowcolumn'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.trc_rowcolumn, 'nU1L') <> isnull(d.trc_rowcolumn, 'nU1L')
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariff RowCol Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffrowcolumn')

	end

	--Trc_MatchValue..
	if update(trc_matchvalue)
	begin
		/* Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
			to represent NULL in comparisons..	*/
		--update	expedite_audit		--this section commented out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row Column MatchValue ' + 
		--		      ltrim(rtrim(isnull(d.trc_matchvalue , 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.trc_matchvalue, 'null')))
		--  from	expedite_audit ea
		--		,deleted d
		--		,inserted i
		--  where	i.tar_number = d.tar_number			
		--	and	isnull(i.trc_matchvalue, 'nU1L') <> isnull(d.trc_matchvalue, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff RowCol Update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffrowcolumn'


		--Insert where the row doesn't already exist..
		insert into expedite_audit
				(ord_hdrnumber
				,updated_by
				,activity
				,updated_dt
				,update_note
				,key_value
				,mov_number
				,lgh_number
				,join_to_table_name
				,tar_number)
		  select 	 0
				,@ls_user
				,'Tariff RowCol Update'
				,@ldt_updated_dt
				,'Tariff Row Column MatchValue ' + ltrim(rtrim(isnull(d.trc_matchvalue , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trc_matchvalue, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffrowcolumn'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.trc_matchvalue, 'nU1L') <> isnull(d.trc_matchvalue, 'nU1L')
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariff RowCol Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffrowcolumn')

	end

	--Trc_MultiMatch..
	if update(trc_multimatch)
	begin
		/* Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
			to represent NULL in comparisons..	*/
		--update	expedite_audit		--this section commented out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row Column MatchValue ' + 
		--		      ltrim(rtrim(isnull(d.trc_multimatch , 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.trc_multimatch, 'null')))
		--  from	expedite_audit ea
		--		,deleted d
		--		,inserted i
		--  where	i.tar_number = d.tar_number			
		--	and	isnull(i.trc_multimatch, 'nU1L') <> isnull(d.trc_multimatch, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff RowCol Update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffrowcolumn'


		--Insert where the row doesn't already exist..
		insert into expedite_audit
				(ord_hdrnumber
				,updated_by
				,activity
				,updated_dt
				,update_note
				,key_value
				,mov_number
				,lgh_number
				,join_to_table_name
				,tar_number)
		  select 	 0
				,@ls_user
				,'Tariff RowCol Update'
				,@ldt_updated_dt
				,'Tariff Row Column MatchValue ' + ltrim(rtrim(isnull(d.trc_multimatch , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trc_multimatch, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffrowcolumn'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.trc_multimatch, 'nU1L') <> isnull(d.trc_multimatch, 'nU1L')
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariff RowCol Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffrowcolumn')

	end
	
end
GO
ALTER TABLE [dbo].[tariffrowcolumn] ADD CONSTRAINT [pk_trcol_number] PRIMARY KEY CLUSTERED ([trc_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_number_rc] ON [dbo].[tariffrowcolumn] ([tar_number], [trc_rowcolumn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffrowcolumn] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffrowcolumn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffrowcolumn] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffrowcolumn] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffrowcolumn] TO [public]
GO
