CREATE TABLE [dbo].[tariffheader]
(
[timestamp] [timestamp] NULL,
[tar_number] [int] NOT NULL,
[tar_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rowbasis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_colbasis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rate] [money] NULL,
[tar_incremental] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_nextbreak] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_minquantity] [decimal] (19, 4) NULL,
[tar_mincharge] [money] NULL,
[tar_tarriffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tariffitem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_currunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_reduction] [money] NULL,
[tar_reduction_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_creatdate] [datetime] NULL,
[tar_updateon] [datetime] NULL,
[tar_applyto_asset] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rate_override] [money] NULL,
[tar_override_type] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tblratingoption] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tro_roworcolumn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tablebreakon] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_min] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_rev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_stl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_rpt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rollintolh] [int] NULL,
[tar_totlh_mincharge] [money] NULL,
[cht_lh_prn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tax_id] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_regional_account_manager] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_function] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_func_round] [int] NULL,
[tar_minrule] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_maxrule] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_minqty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tar_minqty] DEFAULT ('N'),
[tar_time_calc] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_BelongsTo] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_method] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_rounding] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_increment] [decimal] (19, 4) NULL,
[tar_timecalc_free_time] [decimal] (19, 4) NULL,
[tar_timecalc_event_list] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_events_inc_excl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_compid_list] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_compid_inc_excl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_free_time_multistop] [decimal] (19, 4) NULL,
[tar_use_bill_rate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_tar_type] DEFAULT ('T'),
[tar_free_qty] [money] NULL,
[tar_non_billable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_roundunits] [smallint] NULL,
[tar_zerorateisnorate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_external_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffhea__tar_e__0982E560] DEFAULT ('N'),
[tar_external_provider] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_use_first_qualevent] [int] NULL,
[tar_timecalc_first_qualevent_freetime] [decimal] (19, 4) NULL,
[tar_timecalc_use_last_qualevent] [int] NULL,
[tar_timecalc_last_qualevent_freetime] [decimal] (19, 4) NULL,
[tar_timecalc_max_freetime] [decimal] (19, 4) NULL,
[tar_timecalc_min_freetime] [decimal] (19, 4) NULL,
[tar_holiday_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_maxquantity] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__tariffhea__tar_m__610ADFB2] DEFAULT ((0)),
[tar_maxcharge] [money] NOT NULL CONSTRAINT [DF__tariffhea__tar_m__61FF03EB] DEFAULT ((0)),
[tar_rowcolbasis_view] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_quantity_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rate_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_charge_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_description_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_dedicated_quantity] [decimal] (19, 4) NULL,
[tar_dedicated_allocation] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rate_roundby] [money] NULL,
[tar_orderstoapply] [int] NULL,
[tar_timecalc_arrivelatexcl] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_func_negative] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_stopeligible] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number_group] [int] NULL,
[tar_indexbasis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_override_pct_alloc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rowunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_colunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_d83_id] [int] NULL,
[tar_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_groupname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_max_qty] [decimal] (19, 4) NULL,
[tar_timecalc_max_qty_timeframe] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_max_qty_timeframe_use] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rerate_oncompute] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_artaxauth] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tarhdr_changelog]
ON [dbo].[tariffheader]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

declare @updatecount	int,
	@delcount	int, 
	@runtrigger int

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
Select @runtrigger = count(*) from trigger_control with (nolock) where application_name = APP_NAME() and 
		trigger_name = 'iut_tarhdr_changelog' and fire_or_not = 0
If @runtrigger > 0
	return

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

if (@updatecount > 0 and not update(tar_updateby) and not update(tar_updateon)) OR
	(@updatecount > 0 and @delcount = 0)
	Update Tariffheader
	set tar_updateby = @tmwuser,
		tar_updateon = getdate()
	from inserted
	where inserted.tar_number = Tariffheader.tar_number
		and (isNull(Tariffheader.tar_updateby,'') <> @tmwuser
		OR isNull(Tariffheader.tar_updateon,'19500101') <> getdate())
	
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--ILB PTS#18486 10/20/03
CREATE TRIGGER [dbo].[ut_tariffs_fingerprinting] ON [dbo].[tariffheader] FOR UPDATE AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @ls_user	varchar(20),
 	@ldt_updated_dt	datetime,
	@ls_audit	varchar(1), 
	@runtrigger int

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
Select @runtrigger = count(*) from trigger_control with (nolock) where application_name = APP_NAME() and 
		trigger_name = 'ut_tariffs_fingerprinting' and fire_or_not = 0
If @runtrigger > 0
	return


--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select	@ls_user = @tmwuser,@ldt_updated_dt = getdate() 

--Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit' and
	g1.gi_datein = (select	max(g2.gi_datein)
			  from	generalinfo g2
			 where	g2.gi_name = 'FingerprintAudit' and
				g2.gi_datein <= getdate())
if @ls_audit = 'Y'
begin

	--Tar_Tarriffnumber..
	if update(tar_tarriffnumber)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Number ' + 
		--		      ltrim(rtrim(isnull(d.tar_tarriffnumber, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.tar_tarriffnumber, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_tarriffnumber, 'nU1L') <> isnull(d.tar_tarriffnumber, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Header number ' + ltrim(rtrim(isnull(d.tar_tarriffnumber, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tarriffnumber, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_tarriffnumber, 'nU1L') <> isnull(d.tar_tarriffnumber, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Header number%')
	end

	--Tar_Tarriffitem..
	if update(tar_tariffitem)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Item ' + 
		--		      ltrim(rtrim(isnull(d.tar_tariffitem, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.tar_tariffitem, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_tariffitem, 'nU1L') <> isnull(d.tar_tariffitem, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Item ' + ltrim(rtrim(isnull(d.tar_tariffitem, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tariffitem, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tariffitem, 'nU1L') <> isnull(d.tar_tariffitem, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Item%')
	end

	--Tar_Rowbasis..
	if update(Tar_Rowbasis)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row Basis ' + 
		--		      ltrim(rtrim(isnull(d.tar_rowbasis, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.tar_rowbasis, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_rowbasis, 'nU1L') <> isnull(d.tar_rowbasis, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Row Basis ' + ltrim(rtrim(isnull(d.tar_rowbasis, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_rowbasis, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_rowbasis, 'nU1L') <> isnull(d.tar_rowbasis, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Row Basis%')
	end

	--Tar_minquantity..	
	if update(tar_minquantity)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Min Quantity ' + 
		--		      ltrim(rtrim(isnull(cast(d.tar_minquantity as varchar(20)), 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(cast(i.tar_minquantity as varchar(20)), 'null')))                       
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_minquantity , -5701) <> isnull(d.tar_minquantity , -5107)			
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'
		
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Min Quantity ' + ltrim(rtrim(isnull(cast(d.tar_minquantity as varchar(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.tar_minquantity as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.tar_number = d.tar_number
			and isnull(i.tar_minquantity, -5107) <> isnull(d.tar_minquantity, -5107)
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Min Quantity%')
	end
        
	--Tar_tblratingoption..
	if update(tar_tblratingoption)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Table rating option ' + 
		--		      ltrim(rtrim(isnull(d.tar_tblratingoption, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.tar_tblratingoption, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_tblratingoption, 'nU1L') <> isnull(d.tar_tblratingoption, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Table Rating Option ' + ltrim(rtrim(isnull(d.tar_tblratingoption, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tblratingoption, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tblratingoption, 'nU1L') <> isnull(d.tar_tblratingoption, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Table Rating Option%')
	end

	--Tar_description..
	if update(tar_description)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Description ' + 
		--		      ltrim(rtrim(isnull(d.tar_description, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.tar_description, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_description, 'nU1L') <> isnull(d.tar_description, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Description ' + ltrim(rtrim(isnull(d.tar_description, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_description, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_description, 'nU1L') <> isnull(d.tar_description, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Description%')
	end

	--Tar_Colbasis..
	if update(tar_colbasis)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Column Basis ' + 
		--		      ltrim(rtrim(isnull(d.tar_colbasis, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.tar_colbasis, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_colbasis, 'nU1L') <> isnull(d.tar_colbasis, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Column Basis ' + ltrim(rtrim(isnull(d.tar_colbasis, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_colbasis, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_colbasis, 'nU1L') <> isnull(d.tar_colbasis, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Column Basis%')
	end

	
	--Tar_mincharge..	
	if update(tar_mincharge)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Min Charge ' + 
		--		      ltrim(rtrim(isnull(convert(varchar(20),d.tar_mincharge), 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(convert(varchar(20),i.tar_mincharge), 'null')))                       
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_mincharge, -5107) <> isnull(d.tar_mincharge, -5107)			
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'
       
		
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Min Charge ' + ltrim(rtrim(isnull(convert(varchar(20),d.tar_mincharge), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.tar_mincharge), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.tar_number = d.tar_number
			and isnull(i.tar_mincharge, -5107) <> isnull(d.tar_mincharge, -5107)
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Min Charge%')
	end
        
	--Tar_Tro_RoworColumn..
	if update(tar_tro_roworcolumn)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Row or Column ' + 
		--		      ltrim(rtrim(isnull(d.tar_tro_roworcolumn, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.tar_tro_roworcolumn, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_tro_roworcolumn, 'nU1L') <> isnull(d.tar_tro_roworcolumn, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Row or Column ' + ltrim(rtrim(isnull(d.tar_tro_roworcolumn, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tro_roworcolumn, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tro_roworcolumn, 'nU1L') <> isnull(d.tar_tro_roworcolumn, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Row or Column%')
	end

	--Cht_Itemcode..
	if update(cht_itemcode)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Charge Type Item Code ' + 
		--		      ltrim(rtrim(isnull(d.cht_Itemcode, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.cht_Itemcode, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.cht_Itemcode, 'nU1L') <> isnull(d.cht_Itemcode, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Item Code ' + ltrim(rtrim(isnull(d.cht_itemcode, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_itemcode, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_itemcode, 'nU1L') <> isnull(d.cht_itemcode, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Item Code%')
	end

	--Cht_CurrUnit..
	if update(cht_currunit)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Chrage Type Currency Unit ' + 
		--		      ltrim(rtrim(isnull(d.cht_currunit, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.cht_currunit, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.cht_currunit, 'nU1L') <> isnull(d.cht_currunit, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Currency Unit ' + ltrim(rtrim(isnull(d.cht_currunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_currunit, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_currunit, 'nU1L') <> isnull(d.cht_currunit, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Currency Unit%')
	end

	--Cht_Class..
	if update(cht_class)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Charge Type Class ' + 
		--		      ltrim(rtrim(isnull(d.cht_class, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.cht_class, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.cht_class, 'nU1L') <> isnull(d.cht_class, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Class ' + ltrim(rtrim(isnull(d.cht_class, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_class, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_class, 'nU1L') <> isnull(d.cht_class, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Class%')
	end

	--Ivd_Description..
	if update(ivd_description)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Description ' + 
		--		      ltrim(rtrim(isnull(d.ivd_description, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.ivd_description, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.ivd_description, 'nU1L') <> isnull(d.ivd_description, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TarriffHeader update'
				,@ldt_updated_dt
				,'Description ' + ltrim(rtrim(isnull(d.ivd_description, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.ivd_description, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.ivd_description, 'nU1L') <> isnull(d.ivd_description, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Description%')
	end

	--Ivd_Remark..
	if update(ivd_remark)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Remark ' + 
		--		      ltrim(rtrim(isnull(d.ivd_remark, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.ivd_remark, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.ivd_remark, 'nU1L') <> isnull(d.ivd_remark, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Remark ' + ltrim(rtrim(isnull(d.ivd_remark, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.ivd_remark, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.ivd_remark, 'nU1L') <> isnull(d.ivd_remark, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Remark%')
	end

	--Tar_TableBreakOn..
	if update(tar_tablebreakon)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Table Break On ' + 
		--		      ltrim(rtrim(isnull(d.tar_tablebreakon, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.tar_tablebreakon, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_tablebreakon, 'nU1L') <> isnull(d.tar_tablebreakon, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Table Break On ' + ltrim(rtrim(isnull(d.tar_tablebreakon, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tablebreakon, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tablebreakon, 'nU1L') <> isnull(d.tar_tablebreakon, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Table Break On%')
	end

	--Cht_RollintoLH..
	if update(cht_rollintolh)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
--		update	expedite_audit		--this section taken out PTS62013 NLOKE
--		  set	update_note = ea.update_note + ', Charge Type Roll Into LH ' + 
--				      ltrim(rtrim(isnull(cast(d.cht_rollintolh as varchar(20)), 'null'))) + ' -> ' + 
--				      ltrim(rtrim(isnull(cast(i.cht_rollintolh as varchar(20)), 'null')))
----				      ltrim(rtrim(isnull(d.cht_rollintolh, 'null'))) + ' -> ' + 	--vjh 23329 varchar to int does not work
----				      ltrim(rtrim(isnull(i.cht_rollintolh, 'null')))			--vjh 23329 varchar to int does not work
--		  from	expedite_audit ea,deleted d,inserted i
--		  where	i.tar_number = d.tar_number
--			and	isnull(i.cht_rollintolh, -5107) <> isnull(d.cht_rollintolh, -5107)
----			and	isnull(i.cht_rollintolh, 'nU1l') <> isnull(d.cht_rollintolh, 'nU1l')	--vjh 23329 varchar to int does not work
--			and	ea.tar_number = isnull(i.tar_number, 0)
--			and	ea.updated_by = @ls_user
--			and	ea.activity = 'Tariff Header update'
--			and	ea.updated_dt = @ldt_updated_dt
--			and	ea.key_value = convert(varchar(20), i.tar_number)
--			and	ea.mov_number = 0
--			and	ea.lgh_number = 0
--			and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
-- PTS 24496 -- BL (start)
--				,'Charge Type Roll into LH ' + ltrim(rtrim(isnull(d.cht_rollintolh, 'null'))) + ' -> ' + 
--					ltrim(rtrim(isnull(i.cht_rollintolh, 'null')))
				,CASE 
					WHEN d.cht_rollintolh IS NULL THEN 
						CASE 
							WHEN i.cht_rollintolh IS NULL THEN 'Charge Type Roll into LH null -> null'
							WHEN i.cht_rollintolh IS NOT NULL THEN 'Charge Type Roll into LH null -> ' + convert(varchar(5), i.cht_rollintolh)
						END
					WHEN d.cht_rollintolh IS NOT NULL THEN
						CASE 
							WHEN i.cht_rollintolh IS NULL THEN 'Charge Type Roll into LH ' + convert(varchar(5), d.cht_rollintolh) + ' -> null'
							WHEN i.cht_rollintolh IS NOT NULL THEN 'Charge Type Roll into LH ' + convert(varchar(5), d.cht_rollintolh) + ' -> ' + convert(varchar(5), i.cht_rollintolh) 
						END
				END 
-- PTS 24496 -- BL (end)
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
-- PTS 24496 -- BL (start)
--			and isnull(i.cht_rollintolh, 'nU1L') <> isnull(d.cht_rollintolh, 'nU1L')
			and isnull(i.cht_rollintolh, -1) <> isnull(d.cht_rollintolh, -1)
-- PTS 24496 -- BL (end)
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Roll into LH%')
	end

	--Cht_Lh_Min..
	if update(cht_lh_min)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Charge Type LineHaul Min ' + 
		--		      ltrim(rtrim(isnull(d.cht_lh_min, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.cht_lh_min, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.cht_lh_min, 'nU1L') <> isnull(d.cht_lh_min, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Linehaul Min ' + ltrim(rtrim(isnull(d.cht_lh_min, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_lh_min, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_lh_min, 'nU1L') <> isnull(d.cht_lh_min, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Linehaul Min%')
	end

	--Cht_Lh_Rev..
	if update(cht_lh_rev)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Charge Type Linehaul Rev ' + 
		--		      ltrim(rtrim(isnull(d.cht_lh_rev, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.cht_lh_rev, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.cht_lh_rev, 'nU1L') <> isnull(d.cht_lh_rev, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Linehaul Rev ' + ltrim(rtrim(isnull(d.cht_lh_rev, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_lh_rev, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_lh_rev, 'nU1L') <> isnull(d.cht_lh_rev, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Linehaul Rev%')
	end

	--Cht_Lh_Stl..
	if update(cht_lh_stl)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Charge Type Linehaul Stl ' + 
		--		      ltrim(rtrim(isnull(d.cht_lh_stl, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.cht_lh_stl, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.cht_lh_stl, 'nU1L') <> isnull(d.cht_lh_stl, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Linehaul Stl ' + ltrim(rtrim(isnull(d.cht_lh_stl, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_lh_stl, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_lh_stl, 'nU1L') <> isnull(d.cht_lh_stl, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Linehaul Stl%')
	end

	--Cht_Lh_Rpt..
	if update(cht_lh_rpt)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Charge Type Linehaul Rpt ' + 
		--		      ltrim(rtrim(isnull(d.cht_lh_rpt, 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(i.cht_lh_rpt, 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.cht_lh_rpt, 'nU1L') <> isnull(d.cht_lh_rpt, 'nU1L')
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'

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
		  select        0
				,@ls_user
				,'TarriffHeader update'
				,@ldt_updated_dt
				,'Charge Type Linehaul Rpt ' + ltrim(rtrim(isnull(d.cht_lh_rpt, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_lh_rpt, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tarriffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tariffitem, 'nU1L') <> isnull(d.tar_tariffitem, 'nU1L')
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Linehaul Rpt%')
	end

	--Tar_Totlh_MinCharge..
	if update(tar_totlh_mincharge)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
		--update	expedite_audit		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Total Linehaul Min Charge ' + 
		--		      ltrim(rtrim(isnull(cast(d.tar_totlh_mincharge as varchar(20)), 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(cast(i.tar_totlh_mincharge AS varchar(20)), 'null')))
		--  from	expedite_audit ea,deleted d,inserted i
		--  where	i.tar_number = d.tar_number
		--	and	isnull(i.tar_totlh_mincharge, -5107) <> isnull(d.tar_totlh_mincharge, -5107)
		--	and	ea.tar_number = isnull(i.tar_number, 0)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.key_value = convert(varchar(20), i.tar_number)
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'
   
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Total Linehaul Min Charge ' + ltrim(rtrim(isnull(CAST(d.tar_totlh_mincharge AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_totlh_mincharge AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_totlh_mincharge, -5107) <> isnull(d.tar_totlh_mincharge, -5107)
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Total Linehaul Min Charge%')
	end

	--tar_rate.. 31591 2/1/06 BYoung
	if update(tar_rate)
	begin
		-- Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		-- to represent NULL in comparisons..	
   
		--update	ea		--this section taken out PTS62013 NLOKE
		--  set	update_note = ea.update_note + ', Tariff Rate ' + 
		--		      ltrim(rtrim(isnull(cast(d.tar_rate as varchar(20)), 'null'))) + ' -> ' + 
		--		      ltrim(rtrim(isnull(cast(i.tar_rate AS varchar(20)), 'null')))
		--  from	expedite_audit ea
		--		join inserted i on ea.tar_number = isnull(i.tar_number, 0)
		--		join deleted d on i.tar_number = d.tar_number
		--  where	
		--	isnull(i.tar_rate, -5107) <> isnull(d.tar_rate, -5107)
		--	and	ea.updated_by = @ls_user
		--	and	ea.activity = 'Tariff Header update'
		--	and	ea.updated_dt = @ldt_updated_dt
		--	and	ea.mov_number = 0
		--	and	ea.lgh_number = 0
		--	and	ea.join_to_table_name = 'tariffheader'
		

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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Rate ' + ltrim(rtrim(isnull(CAST(d.tar_rate AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_rate AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_rate, -5107) <> isnull(d.tar_rate, -5107)
		  --where	not exists		--this section taken out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHeader update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheader'
				--	and  ea2.update_note like 'Tariff Rate%')
	end




-- 33860 7/25/06 BDH Added remaining fields of the table to the trigger. 
	-- tar_incremental
	if update(tar_incremental)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Incremental ' + ltrim(rtrim(isnull(d.tar_incremental, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_incremental, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_incremental, 'nU1L') <> isnull(d.tar_incremental, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Incremental%')
	end

	--tar_nextbreak
	if update(tar_nextbreak)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Next Break ' + ltrim(rtrim(isnull(d.tar_nextbreak, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_nextbreak, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_nextbreak, 'nU1L') <> isnull(d.tar_nextbreak, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Next Break%')
	end

	--cht_rateunit
	if update(cht_rateunit)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Rate Unit ' + ltrim(rtrim(isnull(d.cht_rateunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_rateunit, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.cht_rateunit, 'nU1L') <> isnull(d.cht_rateunit, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Rate Unit%')
	end

	--cht_unit
	if update(cht_unit)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Unit ' + ltrim(rtrim(isnull(d.cht_unit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_unit, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.cht_unit, 'nU1L') <> isnull(d.cht_unit, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Unit%')
	end


	--tar_reduction
	if update(tar_reduction)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Reduction ' + ltrim(rtrim(isnull(cast(d.tar_reduction as varchar(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.tar_reduction as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.tar_number = d.tar_number
			and isnull(i.tar_reduction, -5107) <> isnull(d.tar_reduction, -5107)
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Reduction%')
	end

	--tar_reduction_rateunit	
	if update(tar_reduction_rateunit)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Reduction Rate Unit ' + ltrim(rtrim(isnull(d.tar_reduction_rateunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_reduction_rateunit, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_reduction_rateunit, 'nU1L') <> isnull(d.tar_reduction_rateunit, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Reduction Rate Unit%')
	end



	--tar_applyto_asset
	if update(tar_applyto_asset)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Apply to Asset ' + ltrim(rtrim(isnull(d.tar_applyto_asset, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_applyto_asset, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_applyto_asset, 'nU1L') <> isnull(d.tar_applyto_asset, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Apply to Asset%')
	end

	--tar_rate_override
	if update(tar_rate_override)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Rate Override ' + ltrim(rtrim(isnull(cast(d.tar_rate_override as varchar(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.tar_rate_override as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.tar_number = d.tar_number
			and isnull(i.tar_rate_override, -5107) <> isnull(d.tar_rate_override, -5107)
			--and not exists		--this section taken out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHeader update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Rate Override%')
	end


	--tar_override_type
	if update(tar_override_type)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Override Type ' + ltrim(rtrim(isnull(d.tar_override_type, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_override_type, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_override_type, 'nU1L') <> isnull(d.tar_override_type, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Override Type%')
	end


	--cht_lh_prn	
	if update(cht_lh_prn)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Charge Type Linehaul Prn ' + ltrim(rtrim(isnull(d.cht_lh_prn, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_lh_prn, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.cht_lh_prn, 'nU1L') <> isnull(d.cht_lh_prn, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Charge Type Linehaul Prn%')
	end

	--tar_tax_id
	if update(tar_tax_id)
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
		  select        0
				,@ls_user
				,'TariffHeader update'
				,@ldt_updated_dt
				,'Tariff Tax ID ' + ltrim(rtrim(isnull(d.tar_tax_id, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tax_id, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheader'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_tax_id, 'nU1L') <> isnull(d.tar_tax_id, 'nU1L')
			--and	not exists		--this section taken out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHeader update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheader'
			--		and  ea2.update_note like 'Tariff Tax ID%')
	end

end
GO
ALTER TABLE [dbo].[tariffheader] ADD CONSTRAINT [pk_tar_number] PRIMARY KEY CLUSTERED ([tar_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_tariffheader_tar_number_group] ON [dbo].[tariffheader] ([tar_number_group]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_tarriffnumber] ON [dbo].[tariffheader] ([tar_tarriffnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tariffheader_timestamp] ON [dbo].[tariffheader] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffheader] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffheader] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffheader] TO [public]
GO
