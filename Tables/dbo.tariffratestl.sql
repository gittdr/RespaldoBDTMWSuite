CREATE TABLE [dbo].[tariffratestl]
(
[timestamp] [timestamp] NULL,
[tar_number] [int] NULL,
[trc_number_row] [int] NOT NULL,
[trc_number_col] [int] NOT NULL,
[tra_rate] [money] NULL,
[tra_standardhours] [decimal] (9, 2) NULL,
[tra_rateasflat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_tra_rateasflatstl] DEFAULT ('N'),
[tra_minrate] [money] NULL,
[tra_minqty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_tra_minqtystl] DEFAULT ('N'),
[tra_apply] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tra_retired] [datetime] NULL,
[tra_activedate] [datetime] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_tariffrate_stl_fingerprinting] ON [dbo].[tariffratestl]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/*	Revision History:
	Date		Name		Description
	-----------	---------------	----------------------------------
	06/30/2006	Brian Hanson	Created
	07/25/2006	Brian Hanson	33860  Added tra_standardhours.  
					Added 'ea2.update_note like...' logic to each not exists select.
    11/17/2014  Mindy Curnutt			PTS 84589 - If an update fired but no rows were changed, get out of the trigger.
*/

if NOT EXISTS (select top 1 * from inserted)
    return

DECLARE @ls_user	varchar(20),
	@ldt_updated_dt	datetime,
	@ls_audit	varchar(1),
	@tmwuser varchar (255), 
	@runtrigger int

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
Select @runtrigger = count(*) from trigger_control with (nolock) where application_name = APP_NAME() and 
		trigger_name = 'ut_tariffrate_stl_fingerprinting' and fire_or_not = 0
If @runtrigger > 0
	return



exec gettmwuser @tmwuser output

select	@ls_user = @tmwuser, @ldt_updated_dt = getdate()

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
	--Tra_Rate..
	if update(tra_rate)
	begin
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
				,'Tar Rate Stl Update'
				,@ldt_updated_dt
				,'Tariff Rate ' + ltrim(rtrim(isnull(cast(d.tra_rate as varchar(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.tra_rate as varchar(20)), 'null'))) + 
					' -- For ROW: '+ case tr.trc_matchvalue when 'UNKNOWN' then cast(tr.trc_rangevalue as varchar) ELSE isNull(tr.trc_matchvalue,'?') END + 
					' For COLUMN: ' + case tc.trc_matchvalue when 'UNKNOWN' then cast(tc.trc_rangevalue as varchar) ELSE isNull(tc.trc_matchvalue,'?') END
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffratestl'
				,i.tar_number
		  from	deleted d 	join inserted i on i.tar_number = d.tar_number
							LEFT OUTER JOIN tariffrowcolumnstl tr on tr.trc_number = i.trc_number_row
							LEFT OUTER JOIN tariffrowcolumnstl tc on tc.trc_number = i.trc_number_col
		  where	
			isnull(i.tra_rate, -5107) <> isnull(d.tra_rate, -5107)
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tar Rate Stl Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffratestl'
			--		and     ea2.update_note like 'Tariff Rate%')
	end


	--Trc_Number_Row..
	if update(trc_number_row)
	begin		
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
				,'Tar Rate Stl Update'
				,@ldt_updated_dt
				,'Tariff Number Row ' + ltrim(rtrim(isnull(cast(d.trc_number_row as varchar(20)) , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.trc_number_row as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffratestl'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.trc_number_row, -5107) <> isnull(d.trc_number_row, -5107)
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tar Rate Stl Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffratestl'
			--		and     ea2.update_note like 'Tariff Number Row%')
	end

	--Trc_Number_Col..
	if update(trc_number_col)
	begin
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
				,'Tar Rate Stl Update'
				,@ldt_updated_dt
				,'Tariff Number Col ' + ltrim(rtrim(isnull(cast(d.trc_number_col as varchar(20)) , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.trc_number_col as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffratestl'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.trc_number_col, -5107) <> isnull(d.trc_number_col, -5107)
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tar Rate Stl Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffratestl'
			--		and     ea2.update_note like 'Tariff Number Col%')
	end

	--tra_standardhours..
	if update(tra_standardhours)
	begin
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
				,'Tar Rate Stl Update'
				,@ldt_updated_dt
				,'Standard Hours ' + ltrim(rtrim(isnull(cast(d.tra_standardhours as varchar(20)) , 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.tra_standardhours as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffratestl'
				,i.tar_number
		  from	deleted d
			,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tra_standardhours, -5107) <> isnull(d.tra_standardhours, -5107)
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tar Rate Stl Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffratestl'
			--		and     ea2.update_note like 'Standard Hours%')
	end

	
	
end

GO
ALTER TABLE [dbo].[tariffratestl] ADD CONSTRAINT [PK_tariffratestl] PRIMARY KEY CLUSTERED ([trc_number_row], [trc_number_col]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_number] ON [dbo].[tariffratestl] ([tar_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffratestl] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffratestl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffratestl] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffratestl] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffratestl] TO [public]
GO
