CREATE TABLE [dbo].[tariffheaderstl]
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
[tar_updateby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_createdate] [datetime] NULL,
[tar_updateon] [datetime] NULL,
[tar_applyto_asset] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rate_override] [money] NULL,
[tar_override_type] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tblratingoption] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tro_roworcolumn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_override_pct_alloc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffhea__tar_o__691D71D6] DEFAULT ('N'),
[tar_total_minaccpay] [money] NULL,
[tar_totmil_minchg] [money] NULL,
[tar_total_minpay] [money] NULL,
[tar_tax_id] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_standardhours] [decimal] (9, 2) NULL,
[tar_maxquantity] [decimal] (19, 4) NULL,
[tar_maxcharge] [money] NULL,
[tar_proration_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_regional_account_manager] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_exclusive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_time_calc] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_BelongsTo] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_external_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffhea__tar_e__126F6157] DEFAULT ('N'),
[tar_external_provider] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_rounding] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_increment] [decimal] (19, 4) NULL,
[tar_timecalc_free_time] [decimal] (19, 4) NULL,
[tar_timecalc_event_list] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_events_inc_excl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_compid_list] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_compid_inc_excl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_free_time_multistop] [decimal] (19, 4) NULL,
[tar_use_bill_rate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_method] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_free_qty] [money] NULL,
[tar_timecalc_use_first_qualevent] [int] NULL,
[tar_timecalc_first_qualevent_freetime] [decimal] (19, 4) NULL,
[tar_timecalc_use_last_qualevent] [int] NULL,
[tar_timecalc_last_qualevent_freetime] [decimal] (19, 4) NULL,
[tar_timecalc_max_freetime] [decimal] (19, 4) NULL,
[tar_timecalc_min_freetime] [decimal] (19, 4) NULL,
[tar_minqty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tariffheaderstl_tar_minqty] DEFAULT ('N'),
[tar_zerorateisnorate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_round_amount] [smallint] NULL,
[tar_touraware] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_arrivelatexcl] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_stopeligible] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_indexbasis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number_group] [int] NULL,
[tar_reductionmin] [money] NULL,
[tar_reductionmax] [money] NULL,
[tar_groupname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_max_qty] [decimal] (19, 4) NULL,
[tar_timecalc_max_qty_timeframe] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_max_qty_timeframe_use] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_CollectRule] [int] NULL,
[pyt_otflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_tariffs_stl_fingerprinting] ON [dbo].[tariffheaderstl]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/*	Revision History:
	Date		Name		Description
	-----------	---------------	----------------------------------
	06/30/2006	Brian Hanson	Created
	07/25/2006	Brian Hanson	33860  Added all fields below tar_rate.  
					Added 'ea2.update_note like...' logic to each not exists select.
*/



DECLARE @ls_user	varchar(20),
 	@ldt_updated_dt	datetime,
	@ls_audit	varchar(1),
	@tmwuser 	varchar (255), 
	@runtrigger int

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
Select @runtrigger = count(*) from trigger_control with (nolock) where application_name = APP_NAME() and 
		trigger_name = 'ut_tariffs_stl_fingerprinting' and fire_or_not = 0
If @runtrigger > 0
	return


exec gettmwuser @tmwuser output

select	@ls_user = @tmwuser, @ldt_updated_dt = getdate() 

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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Header number ' + ltrim(rtrim(isnull(d.tar_tarriffnumber, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tarriffnumber, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		  from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and	isnull(i.tar_tarriffnumber, 'nU1L') <> isnull(d.tar_tarriffnumber, 'nU1L')
			--and	not exists			--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'TariffHdrStl update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.tar_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tariff Header number%'
			--		)
	end

	--Tar_Tarriffitem..
	if update(tar_tariffitem)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Item ' + ltrim(rtrim(isnull(d.tar_tariffitem, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tariffitem, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tariffitem, 'nU1L') <> isnull(d.tar_tariffitem, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tariff Item%')
	end

	--Tar_Rowbasis..
	if update(Tar_Rowbasis)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Row Basis ' + ltrim(rtrim(isnull(d.tar_rowbasis, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_rowbasis, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_rowbasis, 'nU1L') <> isnull(d.tar_rowbasis, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tariff Row Basis%')
	end

	--Tar_minquantity..	
	if update(tar_minquantity)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Min Quantity ' + ltrim(rtrim(isnull(cast(d.tar_minquantity as varchar(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(cast(i.tar_minquantity as varchar(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.tar_number = d.tar_number
			and isnull(i.tar_minquantity, -5107) <> isnull(d.tar_minquantity, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tariff Min Quantity%')
	end


	--Tar_tblratingoption..
	if update(tar_tblratingoption)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Table Rating Option ' + ltrim(rtrim(isnull(d.tar_tblratingoption, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tblratingoption, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tblratingoption, 'nU1L') <> isnull(d.tar_tblratingoption, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tariff Table Rating Option%')
	end

	--Tar_description..
	if update(tar_description)
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
				,'TariffHdrstl update'
				,@ldt_updated_dt
				,'Tariff Description ' + ltrim(rtrim(isnull(d.tar_description, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_description, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_description, 'nU1L') <> isnull(d.tar_description, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrstl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tariff Description%')
	end

	--Tar_Colbasis..
	if update(tar_colbasis)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Column Basis ' + ltrim(rtrim(isnull(d.tar_colbasis, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_colbasis, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_colbasis, 'nU1L') <> isnull(d.tar_colbasis, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tariff Column Basis%')
	end

	--Tar_mincharge..	
	if update(tar_mincharge)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Min Charge ' + ltrim(rtrim(isnull(convert(varchar(20),d.tar_mincharge), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.tar_mincharge), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.tar_number = d.tar_number
			and isnull(i.tar_mincharge, -5107) <> isnull(d.tar_mincharge, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tariff Min Charge%')
	end

	--Tar_Tro_RoworColumn..
	if update(tar_tro_roworcolumn)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Row or Column ' + ltrim(rtrim(isnull(d.tar_tro_roworcolumn, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tro_roworcolumn, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tro_roworcolumn, 'nU1L') <> isnull(d.tar_tro_roworcolumn, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
					--and  ea2.update_note like 'Tariff Row or Column%')
	end

	--Cht_Itemcode..
	if update(cht_itemcode)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Charge Type Item Code ' + ltrim(rtrim(isnull(d.cht_itemcode, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_itemcode, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_itemcode, 'nU1L') <> isnull(d.cht_itemcode, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Charge Type Item Code%')
	end

	--Cht_CurrUnit..
	if update(cht_currunit)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Charge Type Currency Unit ' + ltrim(rtrim(isnull(d.cht_currunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_currunit, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_currunit, 'nU1L') <> isnull(d.cht_currunit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Charge Type Currency Unit%')
	end

	--Ivd_Description..
	if update(ivd_description)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Invoice Detail Description ' + ltrim(rtrim(isnull(d.ivd_description, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.ivd_description, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.ivd_description, 'nU1L') <> isnull(d.ivd_description, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Invoice Detail Description%')
	end

	--Ivd_Remark..
	if update(ivd_remark)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Invoice Detail Remark ' + ltrim(rtrim(isnull(d.ivd_remark, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.ivd_remark, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.ivd_remark, 'nU1L') <> isnull(d.ivd_remark, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Invoice Detail Remark%')
	end

	-- tar_rate..
	if update(tar_rate)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Rate ' + ltrim(rtrim(isnull(CAST(d.tar_rate AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_rate AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_rate, -5107) <> isnull(d.tar_rate, -5107)
		  --where	not exists		--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--	and  ea2.update_note like 'Tariff Rate%')
	end

-- 33860 Starts below:

	-- tar_incremental..	
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Inctrememtal' + ltrim(rtrim(isnull(d.tar_incremental, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_incremental, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_incremental, 'nU1L') <> isnull(d.tar_incremental, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Inctrememtal%')
	end

	-- tar_nextbreak..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Next Break' + ltrim(rtrim(isnull(d.tar_nextbreak, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_nextbreak, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_nextbreak, 'nU1L') <> isnull(d.tar_nextbreak, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Next Break%')
	end

	-- cht_rateunit..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Rate Unit' + ltrim(rtrim(isnull(d.cht_rateunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_rateunit, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_rateunit, 'nU1L') <> isnull(d.cht_rateunit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Rate Unit%')
	end

	-- cht_unit..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Unit' + ltrim(rtrim(isnull(d.cht_unit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_unit, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.cht_unit, 'nU1L') <> isnull(d.cht_unit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Unit%')
	end

	-- tar_reduction..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tariff Reduction ' + ltrim(rtrim(isnull(CAST(d.tar_reduction AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_reduction AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_reduction, -5107) <> isnull(d.tar_reduction, -5107)
		  --where	not exists		--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--    and  ea2.update_note like 'Tariff Reduction%')
	end

	-- tar_reduction_rateunit..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Reduction Rate Unit ' + ltrim(rtrim(isnull(d.tar_reduction_rateunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_reduction_rateunit, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_reduction_rateunit, 'nU1L') <> isnull(d.tar_reduction_rateunit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Reduction Rate Unit%')
	end

	-- tar_applyto_asset..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Apply to Asset ' + ltrim(rtrim(isnull(d.tar_applyto_asset, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_applyto_asset, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_applyto_asset, 'nU1L') <> isnull(d.tar_applyto_asset, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Apply to Asset%')
	end

	-- tar_rate_override..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Rate Override' + ltrim(rtrim(isnull(CAST(d.tar_rate_override AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_rate_override AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_rate_override, -5107) <> isnull(d.tar_rate_override, -5107)
		  --where	not exists		--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--    and  ea2.update_note like 'Rate Override%')
	end

	-- tar_override_type..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Override Type ' + ltrim(rtrim(isnull(d.tar_override_type, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_override_type, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_override_type, 'nU1L') <> isnull(d.tar_override_type, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Override Type%')
	end

	-- tar_override_pct_alloc_ind..	
	if update(tar_override_pct_alloc_ind)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Override Pct Alloc Ind ' + ltrim(rtrim(isnull(d.tar_override_pct_alloc_ind, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_override_pct_alloc_ind, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_override_pct_alloc_ind, 'nU1L') <> isnull(d.tar_override_pct_alloc_ind, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Override Pct Alloc Ind%')
	end

	-- tar_totmil_minchg..
	if update(tar_totmil_minchg)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Totmil Minchg' + ltrim(rtrim(isnull(CAST(d.tar_totmil_minchg AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_totmil_minchg AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_totmil_minchg, -5107) <> isnull(d.tar_totmil_minchg, -5107)
		  --where	not exists		--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--    and  ea2.update_note like 'Totmil Minchg%')
	end

	-- tar_total_minpay..
	if update(tar_total_minpay)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Total Minpay' + ltrim(rtrim(isnull(CAST(d.tar_total_minpay AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_total_minpay AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_total_minpay, -5107) <> isnull(d.tar_total_minpay, -5107)
		  --where	not exists		--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--    and  ea2.update_note like 'Total Minpay%')
	end

	-- tar_tax_id..
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Tax ID ' + ltrim(rtrim(isnull(d.tar_tax_id, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_tax_id, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_tax_id, 'nU1L') <> isnull(d.tar_tax_id, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Tax ID%')
	end

	-- tar_total_minaccpay..
	if update(tar_total_minaccpay)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Total MinAccPay' + ltrim(rtrim(isnull(CAST(d.tar_total_minaccpay AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_total_minaccpay AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_total_minaccpay, -5107) <> isnull(d.tar_total_minaccpay, -5107)
		  --where	not exists		--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--    and  ea2.update_note like 'Total MinAccPay%')
	end

	-- tar_standardhours..
	if update(tar_standardhours)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Standard Hours' + ltrim(rtrim(isnull(CAST(d.tar_standardhours AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_standardhours AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_standardhours, -5107) <> isnull(d.tar_standardhours, -5107)
		  --where	not exists			--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--    and  ea2.update_note like 'Standard Hours%')
	end

	-- tar_maxquantity..
	if update(tar_maxquantity)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Max Quantity' + ltrim(rtrim(isnull(CAST(d.tar_maxquantity AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_maxquantity AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_maxquantity, -5107) <> isnull(d.tar_maxquantity, -5107)
		  --where	not exists		--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--    and  ea2.update_note like 'Max Quantity%')
	end

	-- tar_maxcharge..
	if update(tar_maxcharge)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Max Charge' + ltrim(rtrim(isnull(CAST(d.tar_maxcharge AS VARCHAR(20)), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(CAST(i.tar_maxcharge AS VARCHAR(20)), 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d join inserted i on i.tar_number = d.tar_number and isnull(i.tar_maxcharge, -5107) <> isnull(d.tar_maxcharge, -5107)
		  --where	not exists		--this section commented out PTS62013 NLOKE
			 --   (select 'x'
			 --      from expedite_audit ea2
			 --     where ea2.tar_number = isnull(i.tar_number, 0)
				--    and	ea2.updated_by = @ls_user
				--    and	ea2.activity = 'TariffHdrStl update'
				--    and	ea2.updated_dt = @ldt_updated_dt
				--    and	ea2.key_value = convert(varchar(20), i.tar_number)
				--    and	ea2.mov_number = 0
				--    and	ea2.lgh_number = 0
				--    and	ea2.join_to_table_name = 'tariffheaderstl'
				--    and  ea2.update_note like 'Max Charge%')
	end

	-- tar_proration_flag..
	if update(tar_proration_flag)
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
				,'TariffHdrStl update'
				,@ldt_updated_dt
				,'Proration Flag ' + ltrim(rtrim(isnull(d.tar_proration_flag, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.tar_proration_flag, 'null')))
				,convert(varchar(20), i.tar_number)
				,0
				,0
				,'tariffheaderstl'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.tar_number = d.tar_number
			and isnull(i.tar_proration_flag, 'nU1L') <> isnull(d.tar_proration_flag, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'TariffHdrStl update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.tar_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffheaderstl'
			--		and  ea2.update_note like 'Proration Flag%')
	end

end
GO
ALTER TABLE [dbo].[tariffheaderstl] ADD CONSTRAINT [PK_tariffheaderstl] PRIMARY KEY CLUSTERED ([tar_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_tariffheaderstl_tar_number_group] ON [dbo].[tariffheaderstl] ([tar_number_group]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_tarriffnumber] ON [dbo].[tariffheaderstl] ([tar_tarriffnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tariffheaderstl_timestamp] ON [dbo].[tariffheaderstl] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffheaderstl] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffheaderstl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffheaderstl] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffheaderstl] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffheaderstl] TO [public]
GO
