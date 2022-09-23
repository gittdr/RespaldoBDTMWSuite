CREATE TABLE [dbo].[tariffkey]
(
[trk_number] [int] NOT NULL,
[trk_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[trk_startdate] [datetime] NULL,
[trk_enddate] [datetime] NULL,
[trk_billto] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_othertype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_othertype2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_class] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_revtype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_revtype2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_revtype3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_revtype4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_originpoint] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_origincity] [int] NULL,
[trk_originzip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_originstate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_destpoint] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_destcity] [int] NULL,
[trk_destzip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_deststate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_minmiles] [int] NULL,
[trk_minweight] [decimal] (19, 4) NULL,
[trk_minpieces] [int] NULL,
[trk_minvolume] [decimal] (19, 4) NULL,
[trk_maxmiles] [int] NULL,
[trk_maxweight] [decimal] (19, 4) NULL,
[trk_maxpieces] [int] NULL,
[trk_maxvolume] [decimal] (19, 4) NULL,
[trk_duplicateseq] [int] NULL,
[timestamp] [timestamp] NULL,
[trk_primary] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_minstops] [int] NULL,
[trk_maxstops] [int] NULL,
[trk_minodmiles] [int] NULL,
[trk_maxodmiles] [int] NULL,
[trk_minvariance] [money] NULL,
[trk_maxvariance] [money] NULL,
[trk_orderedby] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_minlength] [money] NULL,
[trk_maxlength] [money] NULL,
[trk_minwidth] [money] NULL,
[trk_maxwidth] [money] NULL,
[trk_minheight] [money] NULL,
[trk_maxheight] [money] NULL,
[trk_origincounty] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_destcounty] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_lghtype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_load] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_team] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_boardcarrier] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_distunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_wgtunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_volunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_odunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_stoptype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_delays] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_ooamileage] [int] NULL,
[trk_ooastop] [int] NULL,
[trk_carryins1] [int] NULL,
[trk_carryins2] [int] NULL,
[trk_terms] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_minmaxmiletype] [tinyint] NULL,
[trk_minrevpermile] [money] NULL,
[trk_maxrevpermile] [money] NULL,
[trk_triptype_or_region] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_tt_or_oregion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_dregion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mastercompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tariffkey__cmp_m__0B342966] DEFAULT ('UNKNOWN'),
[trk_mileagetable] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_fueltableid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_indexseq] [smallint] NULL,
[trk_stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_return_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_return_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[trk_custdoc] [int] NULL CONSTRAINT [DF_trk_custdoc] DEFAULT (0),
[trk_billtoregion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_partytobill] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_partytobill_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_id] [int] NULL,
[rth_id] [int] NULL,
[trk_originsvccenter] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffkey__trk_o__3F2D92C2] DEFAULT ('UNK'),
[trk_originsvcregion] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffkey__trk_o__4021B6FB] DEFAULT ('UNK'),
[trk_destsvccenter] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffkey__trk_d__4115DB34] DEFAULT ('UNK'),
[trk_destsvcregion] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffkey__trk_d__4209FF6D] DEFAULT ('UNK'),
[trk_lghtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffkey__trk_l__614E6BF3] DEFAULT ('UNK'),
[trk_lghtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffkey__trk_l__6242902C] DEFAULT ('UNK'),
[trk_lghtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffkey__trk_l__6336B465] DEFAULT ('UNK'),
[trk_thirdparty] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tariffkey__trk_t__32B50F49] DEFAULT ('UNKNOWN'),
[trk_thirdpartytype] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tariffkey_trk_thirdpartytype] DEFAULT ('UNKNOWN'),
[trk_minsegments] [int] NULL CONSTRAINT [trk_minsegments_dflt] DEFAULT (1),
[trk_maxsegments] [int] NULL CONSTRAINT [trk_maxsegments_dflt] DEFAULT (2147483647),
[billto_othertype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto_othertype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[masterordernumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_owner] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_owner] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_primary_driver] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_index_factor] [decimal] (19, 6) NULL,
[stop_othertype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stop_othertype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mintime] [decimal] (9, 4) NULL,
[trk_billto_car_key] [int] NULL,
[trk_ord_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mpp_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_trc_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_trl_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_tpr_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_car_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mileagetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowsec_rsrv_id] [int] NULL,
[trk_rowsec_revtype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_usefor_billable] [int] NULL CONSTRAINT [trk_usefor_billable_dflt] DEFAULT ((0)),
[trk_mincarriersvcdays] [int] NULL,
[trk_maxcarriersvcdays] [int] NULL,
[trk_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mpp_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mpp_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mpp_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mpp_domicile] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mpp_teamleader] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_trc_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_trc_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_trc_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_trl_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_trl_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_trl_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_pallet_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_pallet_count] [int] NULL,
[trk_ratemode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_servicelevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_dbs_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_mpp_grandfatherfromdate] [datetime] NULL,
[trk_mpp_grandfathertodate] [datetime] NULL,
[trk_trc_grandfatherfromdate] [datetime] NULL,
[trk_trc_grandfathertodate] [datetime] NULL,
[trk_svclevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_pallet_count_max] [int] NULL,
[trk_spec_hand] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_allow_between] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_excess_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_excess_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_excess_qty] [decimal] (10, 2) NULL,
[trk_pick_term] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_delv_term] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_hazmat] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_travel_mode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_temp_control] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_car_movetype] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_d83_min] [int] NULL,
[trk_minwgtperpallet] [int] NULL,
[trk_maxwgtperpallet] [int] NULL,
[ThirdPartyType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_touraware] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrivateRestriction] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_dbs_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trk_SortKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_TimeLogActivity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[iut_tariffkey_changelog]
ON [dbo].[tariffkey]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255), @dtNow datetime, 
	@runtrigger int

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
Select @runtrigger = count(*) from trigger_control with (nolock) where application_name = APP_NAME() and 
		trigger_name = 'iut_tariffkey_changelog' and fire_or_not = 0
If @runtrigger > 0
	return
	
set @dtNow = getdate()

exec gettmwuser @tmwuser output

	Update T
	set last_updateby = @tmwuser,
		last_updatedate = @dtNow
	from tariffkey T inner join inserted I on T.trk_number = i.trk_number
	
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tariffkey_ratemode_temp] ON [dbo].[tariffkey] FOR INSERT, UPDATE
AS
SET NOCOUNT ON
BEGIN
   IF EXISTS (SELECT TOP 1 * FROM inserted WHERE trk_ratemode IS NULL)
   BEGIN
      UPDATE tariffkey
         SET trk_ratemode = IsNull(inserted.trk_ratemode, 'UNK')
        FROM inserted
       WHERE inserted.trk_number = tariffkey.trk_number
         AND inserted.trk_ratemode IS NULL
   END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tariffkey_rowsec_seteffective] ON [dbo].[tariffkey]
FOR INSERT, UPDATE
AS
/*
12/10/12/PTS66193 DPETE getting row changed between retrieve and update on setting the revtype1 value
   on a billing tariff

*/
BEGIN
	IF	UPDATE(trk_revtype1)
		OR UPDATE(mpp_terminal) 
		OR UPDATE(trc_terminal)
		OR UPDATE(trl_terminal) BEGIN
		
	  If exists (SELECT 1 
	     FROM inserted join  tariffheaderstl on inserted.tar_number = tariffheaderstl.tar_number)
	   BEGIN	
		UPDATE	tariffkey
		SET		trk_rowsec_revtype1 =	CASE ISNULL(tariffkey.mpp_terminal, 'UNK') 
											WHEN 'UNK' THEN
												CASE ISNULL(tariffkey.trc_terminal, 'UNK')
													WHEN 'UNK' THEN
														ISNULL(tariffkey.trl_terminal, 'UNK')
													ELSE
														tariffkey.trc_terminal
													END
											ELSE 
												tariffkey.mpp_terminal
										END
		FROM	inserted tk
		WHERE	tk.tar_number = tariffkey.tar_number
		--		AND	EXISTS	(	SELECT	*
		--						FROM	tariffheaderstl th
		--						WHERE	th.tar_number = tk.tar_number
		--					)
      END

		UPDATE	tariffkey
		SET		trk_rowsec_revtype1 = isnull(tariffkey.trk_revtype1, 'UNK')
		FROM	inserted tk
		WHERE	tk.tar_number = tariffkey.tar_number
				AND	EXISTS	(	SELECT	*
								FROM	tariffheader th
								WHERE	th.tar_number = tk.tar_number
							)
		
		
	END
END
		
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tariffkey_SortKey] ON [dbo].[tariffkey] FOR INSERT, UPDATE
AS
SET NOCOUNT ON
BEGIN
   -- if this trigger has already fired and we're in recursion, don't update anything
   IF (TRIGGER_NESTLEVEL(OBJECT_ID(N'[dbo].[iut_tariffkey_SortKey]')) > 1)
   BEGIN
      RETURN
   END

    DECLARE @keys IntInParm
    INSERT INTO @keys
    SELECT trk_number FROM inserted

    EXEC sp_CompileTariffSortKey @keys
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_tariffkey_fingerprinting] ON [dbo].[tariffkey]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/*	Revision History:
	Date		Name		Description
	-----------	---------------	----------------------------------
	07/26/2006	Brian Hanson	Created
	8/4/2006	Brian Hanson	Added REQUIRES PTS30829.SQL for gorgo
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
		trigger_name = 'ut_tariffkey_fingerprinting' and fire_or_not = 0
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

	--trk_description..
	if update(trk_description)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey Description ' + ltrim(rtrim(isnull(d.trk_description, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_description, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_description, 'nU1L') <> isnull(d.trk_description, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey Description%')
	end

	--trk_startdate..
	if update(trk_startdate)
	begin
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
				,'Tariffkey Update'
				,@ldt_updated_dt
				,'Tariffkey start date ' + 
					isnull(convert(varchar(30), d.trk_startdate, 101) + ' ' + 
							convert(varchar(30), d.trk_startdate, 108), 'null') + ' -> ' + 
					isnull(convert(varchar(30), i.trk_startdate, 101) + ' ' + 
							convert(varchar(30), i.trk_startdate, 108), 'null')
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		  from	deleted d, inserted i
		  where	i.trk_number = d.trk_number
			and	isnull(i.trk_startdate, '1901-03-30') <> isnull(d.trk_startdate, '1901-03-30')
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariffkey Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.trk_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffkey'
			--		and     ea2.update_note like 'Tariffkey start date%')
	end

	--trk_enddate..
	if update(trk_enddate)
	begin
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
				,'Tariffkey Update'
				,@ldt_updated_dt
				,'Tariffkey end date ' + 
					isnull(convert(varchar(30), d.trk_enddate, 101) + ' ' + 
							convert(varchar(30), d.trk_enddate, 108), 'null') + ' -> ' + 
					isnull(convert(varchar(30), i.trk_enddate, 101) + ' ' + 
							convert(varchar(30), i.trk_enddate, 108), 'null')
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		  from	deleted d, inserted i
		  where	i.trk_number = d.trk_number
			and	isnull(i.trk_enddate, '1901-03-30') <> isnull(d.trk_enddate, '1901-03-30')
			--and	not exists		--this section commented out PTS62013 NLOKE
			--	(select	'x'
			--	  from	expedite_audit ea2
			--	  where	ea2.tar_number = isnull(i.tar_number, 0)
			--		and	ea2.updated_by = @ls_user
			--		and	ea2.activity = 'Tariffkey Update'
			--		and	ea2.updated_dt = @ldt_updated_dt
			--		and	ea2.key_value = convert(varchar(20), i.trk_number)
			--		and	ea2.mov_number = 0
			--		and	ea2.lgh_number = 0
			--		and	ea2.join_to_table_name = 'tariffkey'
			--		and     ea2.update_note like 'Tariffkey end date%')
	end

	--trk_billto
	if update(trk_billto)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey  billto ' + ltrim(rtrim(isnull(d.trk_billto, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_billto, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_billto, 'nU1L') <> isnull(d.trk_billto, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey  billto%')
	end

	--cmp_othertype1
	if update(cmp_othertype1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'cmp othertype1 ' + ltrim(rtrim(isnull(d.cmp_othertype1, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cmp_othertype1, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.cmp_othertype1, 'nU1L') <> isnull(d.cmp_othertype1, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'cmp othertype1%')
	end

	--cmp_othertype2
	if update(cmp_othertype2)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'cmp othertype2 ' + ltrim(rtrim(isnull(d.cmp_othertype2, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cmp_othertype2, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.cmp_othertype2, 'nU1L') <> isnull(d.cmp_othertype2, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'cmp othertype2%')
	end

	--cmd_code
	if update(cmd_code)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Commodity code ' + ltrim(rtrim(isnull(d.cmd_code, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cmd_code, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.cmd_code, 'nU1L') <> isnull(d.cmd_code, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Commodity code%')
	end

	--cmd_class
	if update(cmd_class)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Commodity class ' + ltrim(rtrim(isnull(d.cmd_class, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cmd_class, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.cmd_class, 'nU1L') <> isnull(d.cmd_class, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Commodity class%')
	end

	--trl_type1
	if update(trl_type1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Trailer type1 ' + ltrim(rtrim(isnull(d.trl_type1, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trl_type1, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trl_type1, 'nU1L') <> isnull(d.trl_type1, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Trailer type1%')
	end

	--trl_type2
	if update(trl_type2)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Trailer type2 ' + ltrim(rtrim(isnull(d.trl_type2, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trl_type2, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trl_type2, 'nU1L') <> isnull(d.trl_type2, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Trailer type2%')
	end

	--trl_type3
	if update(trl_type3)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Trailer type3 ' + ltrim(rtrim(isnull(d.trl_type3, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trl_type3, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trl_type3, 'nU1L') <> isnull(d.trl_type3, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Trailer type3%')
	end

	--trl_type4
	if update(trl_type4)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Trailer type4 ' + ltrim(rtrim(isnull(d.trl_type4, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trl_type4, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trl_type4, 'nU1L') <> isnull(d.trl_type4, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Trailer type4%')
	end


	--trk_revtype1
	if update(trk_revtype1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey Revtype1 ' + ltrim(rtrim(isnull(d.trk_revtype1, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_revtype1, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_revtype1, 'nU1L') <> isnull(d.trk_revtype1, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey Revtype1%')
	end

	--trk_revtype2
	if update(trk_revtype2)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey Revtype2 ' + ltrim(rtrim(isnull(d.trk_revtype2, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_revtype2, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_revtype2, 'nU1L') <> isnull(d.trk_revtype2, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey Revtype2%')
	end

	--trk_revtype3
	if update(trk_revtype3)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey Revtype3 ' + ltrim(rtrim(isnull(d.trk_revtype3, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_revtype3, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_revtype3, 'nU1L') <> isnull(d.trk_revtype3, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey Revtype3%')
	end

	--trk_revtype4
	if update(trk_revtype4)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey Revtype4 ' + ltrim(rtrim(isnull(d.trk_revtype4, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_revtype4, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_revtype4, 'nU1L') <> isnull(d.trk_revtype4, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey Revtype4%')
	end

	--trk_originpoint
	if update(trk_originpoint)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey origin point ' + ltrim(rtrim(isnull(d.trk_originpoint, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_originpoint, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_originpoint, 'nU1L') <> isnull(d.trk_originpoint, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey origin point%')
	end




	--trk_origincity..	
	if update(trk_origincity)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey origin city ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_origincity), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_origincity), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_origincity, -5107) <> isnull(d.trk_origincity, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey origin city%')
	end

	--trk_originzip
	if update(trk_originzip)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey origin zip ' + ltrim(rtrim(isnull(d.trk_originzip, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_originzip, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_originzip, 'nU1L') <> isnull(d.trk_originzip, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey origin zip%')
	end

	--trk_originstate
	if update(trk_originstate)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey origin state ' + ltrim(rtrim(isnull(d.trk_originstate, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_originstate, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_originstate, 'nU1L') <> isnull(d.trk_originstate, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey origin state%')
	end


	--trk_destpoint
	if update(trk_destpoint)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey dest point ' + ltrim(rtrim(isnull(d.trk_destpoint, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_destpoint, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_destpoint, 'nU1L') <> isnull(d.trk_destpoint, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey dest point%')
	end


	--trk_destcity
	if update(trk_destcity)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey dest city ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_destcity), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_destcity), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_destcity, -5107) <> isnull(d.trk_destcity, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey dest city%')
	end

	--trk_destzip
	if update(trk_destzip)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey dest zip ' + ltrim(rtrim(isnull(d.trk_destzip, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_destzip, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_destzip, 'nU1L') <> isnull(d.trk_destzip, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey dest zip%')
	end


	--trk_deststate
	if update(trk_deststate)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey dest state ' + ltrim(rtrim(isnull(d.trk_deststate, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_deststate, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_deststate, 'nU1L') <> isnull(d.trk_deststate, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey dest state%')
	end


	--trk_minmiles
	if update(trk_minmiles)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min miles ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minmiles), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minmiles), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minmiles, -5107) <> isnull(d.trk_minmiles, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min miles%')
	end

	--trk_minweight
	if update(trk_minweight)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min weight ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minweight), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minweight), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minweight, -5107) <> isnull(d.trk_minweight, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min weight%')
	end

	--trk_minpieces
	if update(trk_minpieces)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min pieces ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minpieces), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minpieces), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minpieces, -5107) <> isnull(d.trk_minpieces, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min pieces%')
	end

	--trk_minvolume
	if update(trk_minvolume)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min volume ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minvolume), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minvolume), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minvolume, -5107) <> isnull(d.trk_minvolume, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min volume%')
	end

	--trk_maxmiles
	if update(trk_maxmiles)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max miles ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxmiles), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxmiles), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxmiles, -5107) <> isnull(d.trk_maxmiles, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max miles%')
	end

	--trk_maxweight
	if update(trk_maxweight)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max weight ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxweight), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxweight), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxweight, -5107) <> isnull(d.trk_maxweight, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max weight%')
	end

	--trk_maxpieces
	if update(trk_maxpieces)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max pieces ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxpieces), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxpieces), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxpieces, -5107) <> isnull(d.trk_maxpieces, -5107)
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max pieces%')
	end

	--trk_maxvolume
	if update(trk_maxvolume)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max volume ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxvolume), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxvolume), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxvolume, -5107) <> isnull(d.trk_maxvolume, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max volume%')
	end

	--trk_duplicateseq
	if update(trk_duplicateseq)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey duplicate seq ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_duplicateseq), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_duplicateseq), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_duplicateseq, -5107) <> isnull(d.trk_duplicateseq, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey duplicate seq%')
	end

	--trk_primary
	if update(trk_primary)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey primary ' + ltrim(rtrim(isnull(d.trk_primary, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_primary, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_primary, 'nU1L') <> isnull(d.trk_primary, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey primary%')
	end


	--trk_minstops
	if update(trk_minstops)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min stops ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minstops), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minstops), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minstops, -5107) <> isnull(d.trk_minstops, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min stops%')
	end

	--trk_maxstops
	if update(trk_maxstops)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max stops ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxstops), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxstops), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxstops, -5107) <> isnull(d.trk_maxstops, -5107)
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max stops%')
	end

	--trk_minodmiles
	if update(trk_minodmiles)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min od miles ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minodmiles), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minodmiles), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minodmiles, -5107) <> isnull(d.trk_minodmiles, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min od miles%')
	end

	--trk_maxodmiles
	if update(trk_maxodmiles)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max od miles ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxodmiles), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxodmiles), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxodmiles, -5107) <> isnull(d.trk_maxodmiles, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max od miles%')
	end

	--trk_minvariance
	if update(trk_minvariance)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min variance ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minvariance), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minvariance), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minvariance, -5107) <> isnull(d.trk_minvariance, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min variance%')
	end

	--trk_maxvariance
	if update(trk_maxvariance)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max variance ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxvariance), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxvariance), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxvariance, -5107) <> isnull(d.trk_maxvariance, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max variance%')
	end

	--trk_orderedby
	if update(trk_orderedby)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey ordered by ' + ltrim(rtrim(isnull(d.trk_orderedby, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_orderedby, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_orderedby, 'nU1L') <> isnull(d.trk_orderedby, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey ordered by%')
	end


	--trk_minlength
	if update(trk_minlength)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min length ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minlength), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minlength), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minlength, -5107) <> isnull(d.trk_minlength, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min length%')
	end

	--trk_maxlength
	if update(trk_maxlength)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max length ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxlength), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxlength), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxlength, -5107) <> isnull(d.trk_maxlength, -5107)
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max length%')
	end

	--trk_minwidth
	if update(trk_minwidth)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min width ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minwidth), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minwidth), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minwidth, -5107) <> isnull(d.trk_minwidth, -5107)
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min width%')
	end

	--trk_maxwidth
	if update(trk_maxwidth)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max width ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxwidth), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxwidth), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxwidth, -5107) <> isnull(d.trk_maxwidth, -5107)
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max width%')
	end


	--trk_minheight
	if update(trk_minheight)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min height ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minheight), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minheight), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minheight, -5107) <> isnull(d.trk_minheight, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min height%')
	end

	--trk_maxheight
	if update(trk_maxheight)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max height ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxheight), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxheight), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxheight, -5107) <> isnull(d.trk_maxheight, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max height%')
	end

	--trk_origincounty..
	if update(trk_origincounty)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey origin county ' + ltrim(rtrim(isnull(d.trk_origincounty, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_origincounty, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_origincounty, 'nU1L') <> isnull(d.trk_origincounty, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey origin county%')
	end

	--trk_destcounty..
	if update(trk_destcounty)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey dest county ' + ltrim(rtrim(isnull(d.trk_destcounty, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_destcounty, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_destcounty, 'nU1L') <> isnull(d.trk_destcounty, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey dest county%')
	end

	--trk_company
	if update(trk_company)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey company ' + ltrim(rtrim(isnull(d.trk_company, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_company, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_company, 'nU1L') <> isnull(d.trk_company, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey company%')
	end

	--trk_carrier
	if update(trk_carrier)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey carrier ' + ltrim(rtrim(isnull(d.trk_carrier, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_carrier, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_carrier, 'nU1L') <> isnull(d.trk_carrier, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey carrier%')
	end

	--trk_lghtype1
	if update(trk_lghtype1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey lghtype1 ' + ltrim(rtrim(isnull(d.trk_lghtype1, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_lghtype1, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_lghtype1, 'nU1L') <> isnull(d.trk_lghtype1, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey lghtype1%')
	end

	--trk_load
	if update(trk_load)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey load ' + ltrim(rtrim(isnull(d.trk_load, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_load, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_load, 'nU1L') <> isnull(d.trk_load, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey load%')
	end

	--trk_team
	if update(trk_team)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey team ' + ltrim(rtrim(isnull(d.trk_team, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_team, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_team, 'nU1L') <> isnull(d.trk_team, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey team%')
	end

	--trk_boardcarrier
	if update(trk_boardcarrier)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey board carrier ' + ltrim(rtrim(isnull(d.trk_boardcarrier, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_boardcarrier, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_boardcarrier, 'nU1L') <> isnull(d.trk_boardcarrier, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey board carrier%')
	end

	--trk_distunit
	if update(trk_distunit)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey distance unit ' + ltrim(rtrim(isnull(d.trk_distunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_distunit, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_distunit, 'nU1L') <> isnull(d.trk_distunit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey distance unit%')
	end

	--trk_wgtunit
	if update(trk_wgtunit)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey weight unit ' + ltrim(rtrim(isnull(d.trk_wgtunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_wgtunit, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_wgtunit, 'nU1L') <> isnull(d.trk_wgtunit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey weight unit%')
	end

	--trk_countunit
	if update(trk_countunit)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey count unit ' + ltrim(rtrim(isnull(d.trk_countunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_countunit, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_countunit, 'nU1L') <> isnull(d.trk_countunit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey count unit%')
	end

	--trk_volunit
	if update(trk_volunit)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey volume unit ' + ltrim(rtrim(isnull(d.trk_volunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_volunit, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_volunit, 'nU1L') <> isnull(d.trk_volunit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey volume unit%')
	end

	--trk_odunit
	if update(trk_odunit)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey od unit ' + ltrim(rtrim(isnull(d.trk_odunit, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_odunit, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_odunit, 'nU1L') <> isnull(d.trk_odunit, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey od unit%')
	end

	--mpp_type1
	if update(mpp_type1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Manpowerprofile type1 ' + ltrim(rtrim(isnull(d.mpp_type1, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.mpp_type1, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.mpp_type1, 'nU1L') <> isnull(d.mpp_type1, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Manpowerprofile type1%')
	end

	--mpp_type2
	if update(mpp_type2)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Manpowerprofile type2 ' + ltrim(rtrim(isnull(d.mpp_type2, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.mpp_type2, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.mpp_type2, 'nU1L') <> isnull(d.mpp_type2, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Manpowerprofile type2%')
	end

	--mpp_type3
	if update(mpp_type3)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Manpowerprofile type3 ' + ltrim(rtrim(isnull(d.mpp_type3, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.mpp_type3, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.mpp_type3, 'nU1L') <> isnull(d.mpp_type3, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and ea2.update_note like 'Manpowerprofile type3%')
	end

	--mpp_type4
	if update(mpp_type4)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Manpowerprofile type4 ' + ltrim(rtrim(isnull(d.mpp_type4, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.mpp_type4, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.mpp_type4, 'nU1L') <> isnull(d.mpp_type4, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Manpowerprofile type4%')
		   		   
	end

	--trc_type1
	if update(trc_type1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tractor type1 ' + ltrim(rtrim(isnull(d.trc_type1, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trc_type1, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trc_type1, 'nU1L') <> isnull(d.trc_type1, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tractor type1%')
		   		   
	end


	--trc_type2
	if update(trc_type2)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tractor type2 ' + ltrim(rtrim(isnull(d.trc_type2, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trc_type2, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trc_type2, 'nU1L') <> isnull(d.trc_type2, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tractor type2%')
		   		   
	end

	--trc_type3
	if update(trc_type3)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tractor type3 ' + ltrim(rtrim(isnull(d.trc_type3, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trc_type3, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trc_type3, 'nU1L') <> isnull(d.trc_type3, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tractor type3%')
		   		   
	end

	--trc_type4
	if update(trc_type4)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tractor type4 ' + ltrim(rtrim(isnull(d.trc_type4, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trc_type4, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trc_type4, 'nU1L') <> isnull(d.trc_type4, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tractor type4%')
		   		   
	end


	--cht_itemcode
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Chargetype itemcode ' + ltrim(rtrim(isnull(d.cht_itemcode, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_itemcode, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.cht_itemcode, 'nU1L') <> isnull(d.cht_itemcode, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Chargetype itemcode%')
		   		   
	end

	--trk_stoptype
	if update(trk_stoptype)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey stop type ' + ltrim(rtrim(isnull(d.trk_stoptype, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_stoptype, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_stoptype, 'nU1L') <> isnull(d.trk_stoptype, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey stop type%')
		   		   
	end

	--trk_delays
	if update(trk_delays)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey delays ' + ltrim(rtrim(isnull(d.trk_delays, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_delays, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_delays, 'nU1L') <> isnull(d.trk_delays, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey delays%')
		   		   
	end

	--trk_ooamileage
	if update(trk_ooamileage)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey ooa mileage ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_ooamileage), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_ooamileage), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_ooamileage, -5107) <> isnull(d.trk_ooamileage, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey ooa mileage%')
	end

	--trk_ooastop
	if update(trk_ooastop)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey ooa stop ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_ooastop), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_ooastop), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_ooastop, -5107) <> isnull(d.trk_ooastop, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey ooa stop%')
	end

	--trk_carryins1
	if update(trk_carryins1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey carry insurance1 ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_carryins1), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_carryins1), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_carryins1, -5107) <> isnull(d.trk_carryins1, -5107)
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey carry insurance1%')
	end

	--trk_carryins2
	if update(trk_carryins2)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey carry insurance2 ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_carryins2), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_carryins2), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_carryins2, -5107) <> isnull(d.trk_carryins2, -5107)
			--and not exists	--this section commented out PTS62013 NLOKE	
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey carry insurance2%')
	end

	--trk_minmaxmiletype
	if update(trk_minmaxmiletype)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min max mile type ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minmaxmiletype), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minmaxmiletype), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minmaxmiletype, 255) <> isnull(d.trk_minmaxmiletype, 255)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min max mile type%')
	end

	--trk_terms..
	if update(trk_terms)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey terms ' + ltrim(rtrim(isnull(d.trk_terms, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_terms, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_terms, 'nU1L') <> isnull(d.trk_terms, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey terms%')
	end

	--trk_triptype_or_region..
	if update(trk_triptype_or_region)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey triptype or region ' + ltrim(rtrim(isnull(d.trk_triptype_or_region, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_triptype_or_region, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_triptype_or_region, 'nU1L') <> isnull(d.trk_triptype_or_region, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey triptype or region%')
	end


	--trk_tt_or_oregion..
	if update(trk_tt_or_oregion)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey tt or o region ' + ltrim(rtrim(isnull(d.trk_tt_or_oregion, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_tt_or_oregion, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_tt_or_oregion, 'nU1L') <> isnull(d.trk_tt_or_oregion, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey tt or o region%')
	end

	--trk_dregion..
	if update(trk_dregion)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey dregion ' + ltrim(rtrim(isnull(d.trk_dregion, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_dregion, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_dregion, 'nU1L') <> isnull(d.trk_dregion, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey dregion%')
	end

	--cmp_mastercompany..
	if update(cmp_mastercompany)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Master company ' + ltrim(rtrim(isnull(d.cmp_mastercompany, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cmp_mastercompany, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.cmp_mastercompany, 'nU1L') <> isnull(d.cmp_mastercompany, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Master company%')
	end

	--trk_mileagetable..
	if update(trk_mileagetable)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey mileage table ' + ltrim(rtrim(isnull(d.trk_mileagetable, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_mileagetable, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_mileagetable, 'nU1L') <> isnull(d.trk_mileagetable, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey mileage table%')
	end

	--trk_fueltableid..
	if update(trk_fueltableid)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey fuel table ID ' + ltrim(rtrim(isnull(d.trk_fueltableid, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_fueltableid, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_fueltableid, 'nU1L') <> isnull(d.trk_fueltableid, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey fuel table ID%')
	end

	--trk_minrevpermile..	
	if update(trk_minrevpermile)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min rev per mile ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minrevpermile), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minrevpermile), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minrevpermile, -5107) <> isnull(d.trk_minrevpermile, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min rev per mile%')
	end

	--trk_maxrevpermile..	
	if update(trk_maxrevpermile)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max rev per mile ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxrevpermile), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxrevpermile), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxrevpermile, -5107) <> isnull(d.trk_maxrevpermile, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max rev per mile%')
	end

	--trk_indexseq..	
	if update(trk_indexseq)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey index sequence ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_indexseq), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_indexseq), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_indexseq, -5107) <> isnull(d.trk_indexseq, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey index sequence%')
	end

	--trk_stp_event..
	if update(trk_stp_event)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey stop event ' + ltrim(rtrim(isnull(d.trk_stp_event, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_stp_event, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_stp_event, 'nU1L') <> isnull(d.trk_stp_event, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey stop event%')
	end

	--trk_return_billto..
	if update(trk_return_billto)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey return billto ' + ltrim(rtrim(isnull(d.trk_return_billto, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_return_billto, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_return_billto, 'nU1L') <> isnull(d.trk_return_billto, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey return billto%')
	end

	--trk_return_revtype1..
	if update(trk_return_revtype1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey return revtype1 ' + ltrim(rtrim(isnull(d.trk_return_revtype1, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_return_revtype1, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_return_revtype1, 'nU1L') <> isnull(d.trk_return_revtype1, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey return revtype1%')
	end

	--trk_custdoc..	
	if update(trk_custdoc)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey cust doc ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_custdoc), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_custdoc), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_custdoc, -5107) <> isnull(d.trk_custdoc, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey cust doc%')
	end

	--trk_billtoregion..
	if update(trk_billtoregion)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey billto region ' + ltrim(rtrim(isnull(d.trk_billtoregion, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_billtoregion, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_billtoregion, 'nU1L') <> isnull(d.trk_billtoregion, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey billto region%')
	end

	--trk_partytobill..
	if update(trk_partytobill)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey party to bill ' + ltrim(rtrim(isnull(d.trk_partytobill, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_partytobill, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_partytobill, 'nU1L') <> isnull(d.trk_partytobill, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey party to bill%')
	end

	--trk_partytobill_id..
	if update(trk_partytobill_id)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey - party to bill ID ' + ltrim(rtrim(isnull(d.trk_partytobill_id, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_partytobill_id, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_partytobill_id, 'nU1L') <> isnull(d.trk_partytobill_id, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey - party to bill ID%')
	end

	--tch_id..	
	if update(tch_id)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'TCH ID ' + ltrim(rtrim(isnull(convert(varchar(20),d.tch_id), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.tch_id), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.tch_id, -5107) <> isnull(d.tch_id, -5107)
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'TCH ID%')
	end

	--rth_id..	
	if update(rth_id)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'RTH ID ' + ltrim(rtrim(isnull(convert(varchar(20),d.rth_id), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.rth_id), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.rth_id, -5107) <> isnull(d.rth_id, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'RTH ID%')
	end


	--trk_originsvccenter..
	if update(trk_originsvccenter)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey origin service center ' + ltrim(rtrim(isnull(d.trk_originsvccenter, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_originsvccenter, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_originsvccenter, 'nU1L') <> isnull(d.trk_originsvccenter, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey origin service center%')
	end

	--trk_originsvcregion..
	if update(trk_originsvcregion)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey origin service region ' + ltrim(rtrim(isnull(d.trk_originsvcregion, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_originsvcregion, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_originsvcregion, 'nU1L') <> isnull(d.trk_originsvcregion, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey origin service region%')
	end

	--trk_destsvccenter..
	if update(trk_destsvccenter)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey dest service center ' + ltrim(rtrim(isnull(d.trk_destsvccenter, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_destsvccenter, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_destsvccenter, 'nU1L') <> isnull(d.trk_destsvccenter, 'nU1L')
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey dest service center%')
	end

	--trk_destsvcregion..
	if update(trk_destsvcregion)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey dest service region ' + ltrim(rtrim(isnull(d.trk_destsvcregion, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_destsvcregion, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_destsvcregion, 'nU1L') <> isnull(d.trk_destsvcregion, 'nU1L')
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey dest service region%')
	end

	--trk_lghtype2..
	if update(trk_lghtype2)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey lghtype2 ' + ltrim(rtrim(isnull(d.trk_lghtype2, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_lghtype2, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_lghtype2, 'nU1L') <> isnull(d.trk_lghtype2, 'nU1L')
			--and not exists	--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey lghtype2%')
	end

	--trk_lghtype3..
	if update(trk_lghtype3)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey lghtype3 ' + ltrim(rtrim(isnull(d.trk_lghtype3, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_lghtype3, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_lghtype3, 'nU1L') <> isnull(d.trk_lghtype3, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey lghtype3%')
	end

	--trk_lghtype4..
	if update(trk_lghtype4)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey lghtype4 ' + ltrim(rtrim(isnull(d.trk_lghtype4, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_lghtype4, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_lghtype4, 'nU1L') <> isnull(d.trk_lghtype4, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey lghtype4%')
	end

	--trk_minsegments..	
	if update(trk_minsegments)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey min segments ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_minsegments), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_minsegments), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_minsegments, -5107) <> isnull(d.trk_minsegments, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey min segments%')
	end

	--trk_maxsegments..	
	if update(trk_maxsegments)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey max segments ' + ltrim(rtrim(isnull(convert(varchar(20),d.trk_maxsegments), 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(convert(varchar(20),i.trk_maxsegments), 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		    from	deleted d,inserted i
		   where	i.trk_number = d.trk_number
			and isnull(i.trk_maxsegments, -5107) <> isnull(d.trk_maxsegments, -5107)
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--	    and  ea2.update_note like 'Tariffkey max segments%')
	end

	--trk_thirdparty..
	if update(trk_thirdparty)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey third party ' + ltrim(rtrim(isnull(d.trk_thirdparty, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_thirdparty, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_thirdparty, 'nU1L') <> isnull(d.trk_thirdparty, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey third party%')
	end

	--trk_thirdpartytype..
	if update(trk_thirdpartytype)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Tariffkey 3rd party type ' + ltrim(rtrim(isnull(d.trk_thirdpartytype, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.trk_thirdpartytype, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.trk_thirdpartytype, 'nU1L') <> isnull(d.trk_thirdpartytype, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Tariffkey 3rd party type%')
	end

	--billto_othertype1..
	if update(billto_othertype1)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Billto othertype1 ' + ltrim(rtrim(isnull(d.billto_othertype1, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.billto_othertype1, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.billto_othertype1, 'nU1L') <> isnull(d.billto_othertype1, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Billto othertype1%')
	end

	--billto_othertype2..
	if update(billto_othertype2)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Billto othertype2 ' + ltrim(rtrim(isnull(d.billto_othertype2, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.billto_othertype2, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.billto_othertype2, 'nU1L') <> isnull(d.billto_othertype2, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Billto othertype2%')
	end

	--masterordernumber..
	if update(masterordernumber)
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
				,'Tariffkey update'
				,@ldt_updated_dt
				,'Master order number ' + ltrim(rtrim(isnull(d.masterordernumber, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.masterordernumber, 'null')))
				,convert(varchar(20), i.trk_number)
				,0
				,0
				,'tariffkey'
				,i.tar_number
		   from	deleted d,inserted i
		  where	i.trk_number = d.trk_number
			and isnull(i.masterordernumber, 'nU1L') <> isnull(d.masterordernumber, 'nU1L')
			--and not exists		--this section commented out PTS62013 NLOKE
			--    (select 'x'
			--       from expedite_audit ea2
			--      where ea2.tar_number = isnull(i.tar_number, 0)
			--	    and	ea2.updated_by = @ls_user
			--	    and	ea2.activity = 'Tariffkey update'
			--	    and	ea2.updated_dt = @ldt_updated_dt
			--	    and	ea2.key_value = convert(varchar(20), i.trk_number)
			--	    and	ea2.mov_number = 0
			--	    and	ea2.lgh_number = 0
			--	    and	ea2.join_to_table_name = 'tariffkey'
			--		and  ea2.update_note like 'Master order number%')
	end


end 


GO
ALTER TABLE [dbo].[tariffkey] ADD CONSTRAINT [pk_trk_number] PRIMARY KEY CLUSTERED ([trk_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dkc_trk_mstcmp_billto] ON [dbo].[tariffkey] ([cmp_mastercompany], [trk_billto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_number] ON [dbo].[tariffkey] ([tar_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trk_billto] ON [dbo].[tariffkey] ([trk_billto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trk_orderedby_new] ON [dbo].[tariffkey] ([trk_orderedby]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffkey] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffkey] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffkey] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffkey] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffkey] TO [public]
GO
