CREATE TABLE [dbo].[manpowerprofile]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_t__0643C069] DEFAULT ('UNK'),
[mpp_tractornumber] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_t__0737E4A2] DEFAULT ('UNKNOWN'),
[mpp_otherid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_employedby] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_firstname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_middlename] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_lastname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_ssn] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_address1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_address2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_city] [int] NULL,
[mpp_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_hiredate] [datetime] NULL,
[mpp_senioritydate] [datetime] NULL,
[mpp_licensestate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_licenseclass] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_licensenumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_dateofbirth] [datetime] NULL,
[mpp_currentphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_alternatephone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_homephone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_t__082C08DB] DEFAULT ('UNK'),
[mpp_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_t__09202D14] DEFAULT ('UNK'),
[mpp_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_t__0A14514D] DEFAULT ('UNK'),
[mpp_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_t__0B087586] DEFAULT ('UNK'),
[mpp_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_p__0BFC99BF] DEFAULT ('UNKNOWN'),
[mpp_singlemilerate] [int] NULL,
[mpp_teammilerate] [int] NULL,
[mpp_hourlyrate] [decimal] (5, 2) NULL,
[mpp_revenuerate] [int] NULL,
[mpp_teamleader] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_t__0CF0BDF8] DEFAULT ('UNK'),
[mpp_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_f__0DE4E231] DEFAULT ('UNK'),
[mpp_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_d__0ED9066A] DEFAULT ('UNK'),
[mpp_domicile] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_d__0FCD2AA3] DEFAULT ('UNK'),
[mpp_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_c__10C14EDC] DEFAULT ('UNK'),
[mpp_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_t__11B57315] DEFAULT ('UNK'),
[mpp_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_s__12A9974E] DEFAULT ('AVL'),
[mpp_emerphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_emername] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_voicemailbox] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_terminationdt] [datetime] NULL,
[mpp_avl_date] [datetime] NULL CONSTRAINT [DF__manpowerp__mpp_a__1B3EDD4F] DEFAULT (getdate()),
[mpp_avl_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_a__139DBB87] DEFAULT ('UNKNOWN'),
[mpp_avl_city] [int] NULL CONSTRAINT [DF__manpowerp__mpp_a__1491DFC0] DEFAULT (0),
[mpp_avl_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_pln_date] [datetime] NULL,
[mpp_pln_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_p__158603F9] DEFAULT ('UNKNOWN'),
[mpp_pln_city] [int] NULL CONSTRAINT [DF__manpowerp__mpp_p__167A2832] DEFAULT (0),
[mpp_pln_lgh] [int] NULL CONSTRAINT [DF__manpowerp__mpp_p__176E4C6B] DEFAULT (0),
[mpp_avl_lgh] [int] NULL CONSTRAINT [DF__manpowerp__mpp_a__186270A4] DEFAULT (0),
[mpp_lastfirst] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[mpp_actg_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_a__195694DD] DEFAULT ('P'),
[mpp_last_home] [datetime] NULL,
[mpp_want_home] [datetime] NULL,
[mpp_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_usecashcard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_u__1C330188] DEFAULT ('N'),
[mpp_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_u__1A4AB916] DEFAULT (suser_sname()),
[mpp_bmp_pathname] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_updateon] [datetime] NULL CONSTRAINT [DF__manpowerp__mpp_u__1D2725C1] DEFAULT (getdate()),
[mpp_createdate] [datetime] NULL CONSTRAINT [DF__manpowerp__mpp_c__1E1B49FA] DEFAULT (getdate()),
[mpp_quickentry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_q__1F0F6E33] DEFAULT ('N'),
[mpp_servicerule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_s__2003926C] DEFAULT ('8/70'),
[mpp_gps_desc] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_gps_date] [datetime] NULL,
[mpp_gps_latitude] [int] NULL,
[mpp_gps_longitude] [int] NULL,
[mpp_travel_minutes] [smallint] NULL,
[mpp_mile_day7] [smallint] NULL,
[mpp_home_latitude] [int] NULL,
[mpp_home_longitude] [int] NULL,
[mpp_last_log_date] [datetime] NULL,
[mpp_hours1] [float] NULL,
[mpp_hours2] [float] NULL,
[mpp_hours3] [float] NULL,
[mpp_home_city] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_exp1_date] [datetime] NULL,
[mpp_exp2_date] [datetime] NULL,
[mpp_next_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_next_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_next_city] [int] NULL,
[mpp_next_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_next_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_next_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_next_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_next_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_prior_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_prior_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_prior_city] [int] NULL,
[mpp_prior_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_prior_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_prior_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_prior_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_prior_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_dailyhrsest] [float] NULL,
[mpp_weeklyhrsest] [float] NULL,
[mpp_lastlog_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_lastlog_estdate] [datetime] NULL,
[mpp_lastlog_cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_estlog_datetime] [datetime] NULL,
[mpp_password] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_qualificationlist] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_gp_class] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_manpowerprofile_mpp_gp_class] DEFAULT ('DEFAULT'),
[mpp_gps_odometer] [int] NULL,
[mpp_ArvDep_Allowance_mins] [smallint] NULL,
[mpp_nbrdependents] [tinyint] NULL,
[mpp_avghourlypay] [money] NULL,
[mpp_avgperiodpay] [money] NULL,
[mpp_dailyguarenteedhours] [money] NULL,
[mpp_periodguarenteedhours] [money] NULL,
[mpp_comparisonflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_exp1_enddate] [datetime] NULL,
[mpp_exp2_enddate] [datetime] NULL,
[mpp_hours1_week] [float] NULL,
[mpp_bid_next_starttime] [datetime] NULL,
[mpp_bid_next_hours] [decimal] (4, 2) NULL,
[mpp_bid_next_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_bid_next_routestore] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_90daystart] [datetime] NULL,
[mpp_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_perdiem_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_perdiem_eff_date] [datetime] NULL,
[mpp_athome_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_cmpissuedpoints] [tinyint] NULL,
[mpp_drivedate] [datetime] NULL,
[mpp_yearsofsafedrive] [tinyint] NULL,
[mpp_ysdasofdate] [datetime] NULL,
[mpp_mt_type_loaded] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_mt_type_empty] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_aceid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_aceidtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_proximitycardid] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_citizenship_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_citizenship_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_id] [int] NULL,
[mpp_pta_date] [datetime] NULL,
[mpp_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_eff_date] [datetime] NULL,
[mpp_tuitioncost] [decimal] (18, 2) NULL,
[mpp_forgive_amt] [decimal] (18, 2) NULL,
[mpp_forgive_week_crd_amt] [decimal] (18, 2) NULL,
[mpp_forgive_period] [int] NULL,
[mpp_contribution_amt] [decimal] (18, 2) NULL,
[mpp_cont_period] [int] NULL,
[mpp_cont_week_amt] [decimal] (18, 2) NULL,
[mpp_forgive_crd_nbr] [int] NULL,
[mpp_cont_ded_nbr] [int] NULL,
[mpp_eligible_start_date] [datetime] NULL,
[mpp_tuition_acct_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_train_anv_bonus_pd] [datetime] NULL,
[mpp_forgive_remain_balance] [decimal] (18, 2) NULL,
[mpp_cont_remain_balance] [decimal] (18, 2) NULL,
[mpp_train_anv_bonus_elig_date] [datetime] NULL,
[mpp_train_anv_bonus_amt] [decimal] (18, 2) NULL,
[mpp_updt_forgive_crd_nbr] [int] NULL,
[mpp_updt_cont_ded_nbr] [int] NULL,
[mpp_updt_forgive_remain_balance] [decimal] (18, 2) NULL,
[mpp_updt_cont_remain_balance] [decimal] (18, 2) NULL,
[mpp_comment1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_cyclic_dsp_enabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_preassign_ack_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_prior_cmp_othertype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_next_cmp_othertype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_hrs_dbl_time] [money] NULL,
[mpp_override_default_ot] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_shift_start] [datetime] NULL,
[mpp_shift_end] [datetime] NULL,
[sth_id] [int] NULL,
[sth_startdate] [datetime] NULL,
[mpp_default_shiftstart] [datetime] NULL,
[mpp_default_shiftend] [datetime] NULL,
[mpp_milestonext] [int] NULL,
[mpp_next_stopnumber] [int] NULL,
[mpp_next_legnumber] [int] NULL,
[mpp_next_stoparrival] [datetime] NULL,
[mpp_last_calcdate] [datetime] NULL,
[mpp_lastmobilecomm] [datetime] NULL,
[mpp_default_shiftpriority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_employeetype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_timeoffbetweenduty] [decimal] (5, 2) NULL,
[rowsec_rsrv_id] [int] NULL,
[mpp_shift_isbackup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_s__59DB91DA] DEFAULT ('N'),
[mpp_shift_backup_mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manpowerp__mpp_s__5ACFB613] DEFAULT ('UNK'),
[mpp_shiftnumber] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_csa_score] [int] NULL,
[mpp_driverlogtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_driverlogGroups] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_driverlogTerminal] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_advance_rate_solo] [money] NULL,
[mpp_advance_rate_team] [money] NULL,
[mpp_rtw_date] [datetime] NULL,
[mpp_hosstatus] [int] NULL,
[mpp_hosstatusdate] [datetime] NULL,
[mpp_hosactivityupdateon] [datetime] NULL,
[mpp_fourteenhrest] [float] NULL,
[mpp_grandfather_date] [datetime] NULL,
[guaranteed_pay_promised] [money] NULL,
[mpp_gps_heading] [float] NULL,
[mpp_gps_speed] [int] NULL,
[mpp_subsistence_eligible] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_subsistence_home_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_subsistence_pay_radius] [float] NULL,
[mpp_subsistence_use_at_home] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_subsistence_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_mcommID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_mcommType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_trainee] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_trainer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_last_DailyLogsDate] [datetime] NULL,
[mpp_last_DailyLogsConfirmedDate] [datetime] NULL,
[mpp_hos_poll_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayScheduleId] [int] NULL,
[CompensationType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginDestinationOption] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_usize] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_manpowerprofile] ON [dbo].[manpowerprofile] 
FOR DELETE 
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
 if exists 
  ( select * from event, deleted
     where deleted.mpp_id = event.evt_driver1
        or deleted.mpp_id = event.evt_driver2 ) 
   begin
-- Sybase Syntax
--   raiserror 99999 'Cannot delete driver: Assigned to trips'
-- MSS Syntax
     raiserror('Cannot delete driver: Assigned to trips',16,1)
     rollback transaction
   end
else
begin
-- 31937 BDH Delete from / update satellite driver tables as well if allowed to delete from manpowerprofile.
	declare @mpp_id varchar(8)
	select @mpp_id = mpp_id from deleted

	-- update
	update schedule_table set mpp_id = 'UNKNOWN' where mpp_id = @mpp_id
	
	-- deletes
	delete from driveraccident where mpp_id = @mpp_id
	
	delete from driverobservation where mpp_id = @mpp_id
	
	delete from drivertesting where mpp_id = @mpp_id
	
	delete from drivertraining where mpp_id = @mpp_id
	
	delete from drivercomplaint where mpp_id = @mpp_id
	
	delete from driverqualifications where drq_driver = @mpp_id and upper(drq_source) = 'DRV'

	delete from driverlogviolation where mpp_id = @mpp_id
	
	delete from log_driverlogs where mpp_id = @mpp_id
	
	delete from log_driverviolations where mpp_id = @mpp_id
	
	delete from log_missinglogs where mpp_id = @mpp_id
	
	delete from manpowerhomelog where mpp_id = @mpp_id
	
	delete from imagedriverlist where mpp_id = @mpp_id
	
	delete from drivercalendar where mpp_id = @mpp_id
	
	delete from drivercalendarhistory where mpp_id = @mpp_id

	-- drd_type needs to be specified in case a driver and passenger happen
	-- to have the same ID.
	DELETE FROM driverdocument WHERE mpp_id = @mpp_id
	AND drd_type = 'D'
	
	delete from ps_blob_data where blob_table = 'manpowerprofile' and blob_key = @mpp_id

    -- PTS 38486
    delete from contact_profile where con_id = @mpp_id and con_asgn_type = 'DRIVER'

    -- BEGIN PTS 39866 
    delete from notes where nre_tablekey = @mpp_id and ntb_table = 'manpowerprofile'
    delete from expiration where exp_id = @mpp_id and exp_idtype = 'DRV'
    -- END PTS 39866 
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================================
-- PTS16842 - DJM - Create trigger to track the last time the record was modified
-- PTS 36333 - DJM - Modify this trigger to update necessary fields for the Driver Training
--		Deduction functionality when appropriate.
-- ===================================================================================

CREATE TRIGGER [dbo].[iut_manpower_changelog]
ON [dbo].[manpowerprofile]
FOR INSERT, UPDATE 
AS 
/*
    11/17/2014  Mindy Curnutt			PTS 84589 - If an update fired but no rows were changed, get out of the trigger.
*/

if NOT EXISTS (select top 1 * from inserted)
    return

Set NOCOUNT ON

DECLARE	@updatecount	      INTEGER,
         @delcount            INTEGER,
         @v_curr_flag         char(1),
         @v_new_flag          char(1),
         @v_new_eff_date      datetime,
         @v_curr_eff_date     datetime

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

SELECT @updatecount = COUNT(*) FROM inserted
SELECT @delcount = COUNT(*) FROM deleted

IF (@updatecount > 0 AND NOT UPDATE(mpp_updatedby) AND NOT UPDATE(mpp_updateon)) OR
	(@updatecount > 0 and @delcount = 0)
BEGIN
	IF @delcount = 0 
	BEGIN	
		UPDATE	manpowerprofile
		   SET	mpp_updatedby = @tmwuser,
				mpp_updateon = GETDATE()
		  FROM	inserted
		 WHERE	inserted.mpp_id = manpowerprofile.mpp_id AND
				(ISNULL(manpowerprofile.mpp_updatedby, '') <> @tmwuser OR
				 ISNull(manpowerprofile.mpp_updateon, '19500101') <> GETDATE())
	END
	ELSE
	BEGIN
		IF RTRIM(LTRIM(APP_NAME())) = 'FIL'
		BEGIN
			UPDATE	manpowerprofile
			   SET	mpp_updatedby = @tmwuser,
					mpp_updateon = GETDATE()
			  FROM	inserted
			 WHERE	inserted.mpp_id = manpowerprofile.mpp_id AND
					(ISNULL(manpowerprofile.mpp_updatedby, '') <> @tmwuser OR
					 ISNULL(manpowerprofile.mpp_updateon, '19500101') <> GETDATE())
		END
	END
END
--24780 JD update the 90daystart field as soon as the drivertype1 is switched to mileage.
IF @updatecount > 0 and @delcount > 0 
BEGIN
	IF update(mpp_type1) 
	BEGIN
		if exists (select * from inserted where mpp_type1 = 'MIL')
			update manpowerprofile set mpp_90daystart = convert(varchar(8),getdate(),1) from inserted where manpowerprofile.mpp_id = inserted.mpp_id and manpowerprofile.mpp_type1 = 'MIL'
		else
			update manpowerprofile set mpp_90daystart = null from inserted where manpowerprofile.mpp_id = inserted.mpp_id

	END

END

-- 30236 JD Check if we need to create entries for activity table for single and team rates.
declare @ll_prk int
If @updatecount > 0 and @delcount = 0 -- insert 
BEGIN
	If exists (select * from generalinfo where gi_name = 'AutoAssignResourceToRates' and charindex('DRVS',upper(gi_string1)) > 0  )
	BEGIN
		exec  @ll_prk = getsystemnumber 'PRDNUM',''
		Insert into payratekey
				(
				prk_number,
				asgn_type,
				asgn_id,
				prk_paybasis,
				prh_number,
				prk_name,
				prk_team,
				prk_car_trc_flag,
				prk_effective)
		Select @ll_prk,'DRV',mpp_id , 'LGH','ACTV!','DRV'+mpp_id+'ACTV!','N','BTH','19500101 00:00' from inserted
	END

	If exists (select * from generalinfo where gi_name = 'AutoAssignResourceToRates' and charindex('DRVT',upper(gi_string1)) > 0  )
	BEGIN
		exec  @ll_prk = getsystemnumber 'PRDNUM',''
		Insert into payratekey
				(
				prk_number,
				asgn_type,
				asgn_id,
				prk_paybasis,
				prh_number,
				prk_name,
				prk_team,
				prk_car_trc_flag,
				prk_effective)
		Select @ll_prk,'DRV',mpp_id , 'LGH','ACTV!','DRV'+mpp_id+'ACTV!','Y','BTH','19500101 00:00' from inserted
            END
END
 
--JLB PTS 29829
IF @updatecount > 0 AND (UPDATE(mpp_perdiem_flag) OR UPDATE(mpp_perdiem_eff_date))
BEGIN
  --inserted inital record for those that need them
	INSERT INTO manpowerprofile_perdiem_history(mpp_id, mpp_perdiem_flag, mpp_perdiem_eff_date, mph_updated_by, mph_updated_on)
		SELECT	inserted.mpp_id, 'N', '19000101', @tmwuser, getdate()
		  FROM	inserted
		 WHERE	NOT EXISTS(SELECT	manpowerprofile_perdiem_history.mpp_id
							 FROM	manpowerprofile_perdiem_history
							WHERE	manpowerprofile_perdiem_history.mpp_id = inserted.mpp_id)
--39246 support multiple row updates
	INSERT INTO manpowerprofile_perdiem_history(mpp_id, mpp_perdiem_flag, mpp_perdiem_eff_date, mph_updated_by, mph_updated_on)
		SELECT	i.mpp_id, ISNULL(i.mpp_perdiem_flag, 'N'), ISNULL(i.mpp_perdiem_eff_date, '19000101'), @tmwuser, getdate()
		  FROM	inserted i
		 WHERE	NOT EXISTS(SELECT	mph.mpp_id
							 FROM	manpowerprofile_perdiem_history mph
							WHERE	mph.mpp_id = i.mpp_id AND
									mph.mpp_perdiem_flag = ISNULL(i.mpp_perdiem_flag, 'N') AND
									mph.mpp_perdiem_eff_date = ISNULL(i.mpp_perdiem_eff_date, '19000101'))
END
/*	
  --insert changed values for all records only if it's a single update
  if (@updatecount) = 1
  begin
    select @v_new_flag = inserted.mpp_perdiem_flag 
      from inserted
    select @v_curr_flag = isnull(deleted.mpp_perdiem_flag, 'N') 
      from deleted, inserted
     where inserted.mpp_id = deleted.mpp_id
 
    select @v_new_eff_date = inserted.mpp_perdiem_eff_date 
      from inserted
    select @v_curr_eff_date = isnull(deleted.mpp_perdiem_eff_date, '01/01/1900') 
      from deleted, inserted
     where inserted.mpp_id = deleted.mpp_id
 
  --insert changed values for all records only if the values are actually changing
    if (@v_new_flag <> @v_curr_flag) OR (@v_new_eff_date <> @v_curr_eff_date)
    begin
      INSERT INTO manpowerprofile_perdiem_history (mpp_id, mpp_perdiem_flag, mpp_perdiem_eff_date, mph_updated_by, mph_updated_on)
           SELECT inserted.mpp_id, inserted.mpp_perdiem_flag, inserted.mpp_perdiem_eff_date, @tmwuser, getdate()     
             FROM inserted
    end
  end
END
*/

/*PTS 36333 - DJM - logic to look at the fields updated Daily from the data load and see if they need to be 
carried over the the actual fields used in the calculations.  Should only be copied over if the
'real' fields are null or Zero.																*/
if exists (select 1 from generalinfo where gi_name = 'DriverTrainingDeduction' and Left(gi_string1,1) = 'Y')
	Begin	
		-- handle updates to existing Manpowerprofile records
		if exists (select 1 from manpowerprofile mpp inner join Inserted u on mpp.mpp_id = u.mpp_id)
			Begin
				if update(mpp_updt_forgive_crd_nbr)
					Update Manpowerprofile
					set mpp_forgive_crd_nbr = inserted.mpp_updt_forgive_crd_nbr
					from Inserted inner join Manpowerprofile on manpowerprofile.mpp_id = inserted.mpp_id	
					where isNull(inserted.mpp_updt_forgive_crd_nbr,0) >= isNull(manpowerprofile.mpp_forgive_crd_nbr,0)	

				if update(mpp_updt_cont_ded_nbr)
					Update Manpowerprofile
					set mpp_cont_ded_nbr = inserted.mpp_updt_cont_ded_nbr
					from Inserted inner join Manpowerprofile on manpowerprofile.mpp_id = inserted.mpp_id
					where isNull(inserted.mpp_updt_cont_ded_nbr,0) >= isNull(manpowerprofile.mpp_cont_ded_nbr,0)		

				if update(mpp_updt_forgive_remain_balance)
					Update Manpowerprofile
					set mpp_forgive_remain_balance = Inserted.mpp_updt_forgive_remain_balance
					from Inserted inner join Manpowerprofile on manpowerprofile.mpp_id = inserted.mpp_id		
					where isNull(inserted.mpp_updt_forgive_remain_balance,0) <= isNull(manpowerprofile.mpp_forgive_remain_balance,0)

				if update(mpp_updt_forgive_remain_balance)
					Update Manpowerprofile
					set mpp_forgive_remain_balance = Inserted.mpp_updt_forgive_remain_balance
					from Inserted inner join Manpowerprofile on manpowerprofile.mpp_id = inserted.mpp_id	
					where isNull(inserted.mpp_updt_forgive_remain_balance,0) <= isNull(manpowerprofile.mpp_forgive_remain_balance,0)	
			End

		-- Handle the inserts.
		if exists (select 1 from manpowerprofile mpp inner join Inserted u on mpp.mpp_id = u.mpp_id)
			Begin
				
				if update(mpp_updt_forgive_crd_nbr)
					Update Manpowerprofile
					set mpp_forgive_crd_nbr = inserted.mpp_updt_forgive_crd_nbr
					from Inserted inner join Manpowerprofile on manpowerprofile.mpp_id = inserted.mpp_id	
					where not exists (select 1 from deleted where inserted.mpp_id = deleted.mpp_id)

				if update(mpp_updt_cont_ded_nbr)
					Update Manpowerprofile
					set mpp_cont_ded_nbr = inserted.mpp_updt_cont_ded_nbr
					from Inserted inner join Manpowerprofile on manpowerprofile.mpp_id = inserted.mpp_id
					where not exists (select 1 from deleted where inserted.mpp_id = deleted.mpp_id)

				if update(mpp_updt_forgive_remain_balance)
					Update Manpowerprofile
					set mpp_forgive_remain_balance = Inserted.mpp_updt_forgive_remain_balance
					from Inserted inner join Manpowerprofile on manpowerprofile.mpp_id = inserted.mpp_id		
					where not exists (select 1 from deleted where inserted.mpp_id = deleted.mpp_id)

				if update(mpp_updt_forgive_remain_balance)
					Update Manpowerprofile
					set mpp_forgive_remain_balance = Inserted.mpp_updt_forgive_remain_balance
					from Inserted inner join Manpowerprofile on manpowerprofile.mpp_id = inserted.mpp_id	
					where not exists (select 1 from deleted where inserted.mpp_id = deleted.mpp_id)
					
			End	
	End
	
	--PWH PTS 60799 - added fuel card update queue
	IF update(mpp_status) and exists (select 1 from generalinfo where gi_name = 'ProcInteractiveDrvCardUpdates' and Left(gi_string1,1) = 'Y')--and exists (select 1 from manpowerprofile mpp inner join Inserted u on mpp.mpp_id = u.mpp_id)
		begin
		
			DECLARE	@new_mpp_status	   VARCHAR(6),	
			        @mpp_id            VARCHAR(8)
					
		    SELECT @new_mpp_status = i.mpp_status,   
		           @mpp_id = i.mpp_id 
		    FROM inserted i
			
			if @new_mpp_status = 'OUT' 
				exec Interactive_Fuel_Update_sp 'DRV', @mpp_id, 0, 'DRVTERM'
		end

-- RE - PTS #60818 BEGIN
IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'Manhattan_Interface' AND LEFT(gi_string1,1) = 'Y')
BEGIN
	INSERT INTO MANHATTAN_WorkQueue
		(mwq_type, trc_number, mwq_source)
		SELECT	'DRIVER', t.trc_number, 'IUT_TRACTOR_CHANGELOG' 
		  FROM	inserted i
					inner join tractorprofile t on t.trc_driver = i.mpp_id or t.trc_driver2 = i.mpp_id
		 WHERE	i.mpp_id <> 'UNKNOWN'
		   AND	t.trc_number <> 'UNKNOWN'
		   AND	NOT EXISTS(SELECT * FROM MANHATTAN_WorkQueue mwq WHERE mwq.mwq_type = 'DRIVER' AND mwq.trc_number = t.trc_number)
END
-- RE - PTS #60818 END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_manpowerprofile_rowsec] ON [dbo].[manpowerprofile]
FOR INSERT, UPDATE
AS
	-- PTS62831 JJF 20121001 - no longer needed
	
	--DECLARE @COLUMNS_UPDATED_BIT_MASK varbinary(500)
	--DECLARE @error int
	--DECLARE @message varchar(1024)
	
	--SELECT @COLUMNS_UPDATED_BIT_MASK = COLUMNS_UPDATED()
	
	--SELECT mpp_id
	--INTO #NewValues
	--FROM inserted
	
	--exec RowSecUpdateRows_sp 'manpowerprofile', @COLUMNS_UPDATED_BIT_MASK, @error out, @message out 
	
--Begin PTS 58081 AVANE 20110729, PTS 58411 AVANE 20110811
	
	declare @assetProfileLogging char(1)
	select @assetProfileLogging = ISNULL((SELECT TOP 1 gi_string1 from generalinfo (nolock) where gi_name = 'EnableAssetProfileLogging'), 'Y')
	
	--PTS 84589
	if NOT EXISTS (select top 1 * from inserted)
    return

	--PTS83919 JJF (SB CRE) 20141104 - change to left joins of deleted table to accommodate INSERTs
	--apply to update only and if the gi setting EnableAssetProfileLogging <> 'N'
	--if((select count(*) from deleted) > 0 AND @assetProfileLogging = 'Y')		
	if(@assetProfileLogging = 'Y')		
	begin
		declare @currentTime datetime, @currentUser varchar(255), @res_type varchar(8), @lbl_category varchar(16)

		exec gettmwuser @currentUser output
		select @currentTime = GETDATE()
		select @res_type = 'Driver'

		--PTS83919 JJF (SB CRE) 20141104 - change to left joins of deleted table to accommodate INSERTs
		if(update(mpp_type1))
		begin
			select @lbl_category = 'DrvType1'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_type1, 'UNK'), 
				Case when d.mpp_type1 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_type1), 'UNKNOWN') end,
				i.mpp_type1,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_type1), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_type1
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_type1 is not NULL 
				and Coalesce(d.mpp_type1, '') <> i.mpp_type1 
				and apl.res_id is null
		end
			
		if(update(mpp_type2))
		begin
			select @lbl_category = 'DrvType2'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_type2, 'UNK'), 
				Case when d.mpp_type2 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_type2), 'UNKNOWN') end,
				i.mpp_type2,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_type2), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_type2
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_type2 is not NULL 
				and Coalesce(d.mpp_type2, '') <> i.mpp_type2 
				and apl.res_id is null
		end
			
		if(update(mpp_type3))
		begin
			select @lbl_category = 'DrvType3'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_type3, 'UNK'), 
				Case when d.mpp_type3 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_type3), 'UNKNOWN') end,
				i.mpp_type3,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_type3), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_type3
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_type3 is not NULL 
				and Coalesce(d.mpp_type3, '') <> i.mpp_type3 
				and apl.res_id is null
		end
			
		if(update(mpp_type4))
		begin
			select @lbl_category = 'DrvType4'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_type4, 'UNK'), 
				Case when d.mpp_type4 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_type4), 'UNKNOWN') end,
				i.mpp_type4,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_type4), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_type4
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_type4 is not NULL 
				and Coalesce(d.mpp_type4, '') <> i.mpp_type4 
				and apl.res_id is null
		end
				
		if(update(mpp_company))
		begin
			select @lbl_category = 'Company'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_company, 'UNK'), 
				Case when d.mpp_company is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_company), 'UNKNOWN') end,
				i.mpp_company,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_company), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_company
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_company is not NULL 
				and Coalesce(d.mpp_company, '') <> i.mpp_company 
				and apl.res_id is null
		end

		if(update(mpp_division))
		begin
			select @lbl_category = 'Division'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_division, 'UNK'), 
				Case when d.mpp_division is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_division), 'UNKNOWN') end,
				i.mpp_division,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_division), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_division
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_division is not NULL 
				and Coalesce(d.mpp_division, '') <> i.mpp_division 
				and apl.res_id is null
		end

		if(update(mpp_fleet))
		begin
			select @lbl_category = 'Fleet'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_fleet, 'UNK'), 
				Case when d.mpp_fleet is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_fleet), 'UNKNOWN') end,
				i.mpp_fleet,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_fleet), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_fleet
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_fleet is not NULL 
				and Coalesce(d.mpp_fleet, '') <> i.mpp_fleet 
				and apl.res_id is null
		end

		if(update(mpp_terminal))
		begin
			select @lbl_category = 'Terminal'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_terminal, 'UNK'), 
				Case when d.mpp_terminal is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_terminal), 'UNKNOWN') end,
				i.mpp_terminal,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_terminal), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_terminal
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_terminal is not NULL 
				and Coalesce(d.mpp_terminal, '') <> i.mpp_terminal 
				and apl.res_id is null
		end

		if(update(mpp_teamleader))
		begin
			select @lbl_category = 'TeamLeader'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_teamleader, 'UNK'), 
				Case when d.mpp_teamleader is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_teamleader), 'UNKNOWN') end,
				i.mpp_teamleader,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_teamleader), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_teamleader
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_teamleader is not NULL 
				and Coalesce(d.mpp_teamleader, '') <> i.mpp_teamleader 
				and apl.res_id is null
		end

		if(update(mpp_domicile))
		begin
			select @lbl_category = 'Domicile'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.mpp_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.mpp_domicile, 'UNK'), 
				Case when d.mpp_domicile is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.mpp_domicile), 'UNKNOWN') end,
				i.mpp_domicile,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.mpp_domicile), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.mpp_id = i.mpp_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.mpp_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.mpp_domicile
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.mpp_domicile is not NULL 
				and Coalesce(d.mpp_domicile, '') <> i.mpp_domicile 
				and apl.res_id is null
		end
	end
--End PTS 58081 AVANE 20110729, PTS 58411 AVANE 20110811

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_manpowerprofile_setschedule]
ON [dbo].[manpowerprofile]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
/**
 * 
 * NAME: 
 * dbo.iut_manpowerprofile_setschedule
 *
 * TYPE: 
 * Trigger
 *
 * DESCRIPTION:
 * Sets the backoffice schedule ID on the asset
 *
 * RETURNS: 
 * N/A
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS: 
 * N/A
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 2014/10/28 | PTS 83554 | vjh	  - new trigger
 * 2015/04/08 | PTS 89156 | vjh   - Mindy's recommendations for how to test for update
 *
 **/

BEGIN

IF EXISTS
(
select d.mpp_id from deleted d inner join inserted i on d.mpp_id = i.mpp_id
where 
(
d.mpp_actg_type <> i.mpp_actg_type OR
d.mpp_company <> i.mpp_company OR
d.mpp_division <> i.mpp_division OR
d.mpp_terminal <> i.mpp_terminal OR
d.mpp_fleet <> i.mpp_fleet OR
d.mpp_type1 <> i.mpp_type1 OR
d.mpp_type2 <> i.mpp_type2 OR
d.mpp_type3 <> i.mpp_type3 OR
d.mpp_type4 <> i.mpp_type4
)
and d.PayScheduleId is not null
)
      update t 
      set PayScheduleId = NULL
      from manpowerprofile t 
      inner join deleted d on t.mpp_id = d.mpp_id
	  inner join inserted i on t.mpp_id = i.mpp_id
      where 
      (
      d.mpp_actg_type <> i.mpp_actg_type OR
      d.mpp_company <> i.mpp_company OR
      d.mpp_division <> i.mpp_division OR
      d.mpp_terminal <> i.mpp_terminal OR
      d.mpp_fleet <> i.mpp_fleet OR
      d.mpp_type1 <> i.mpp_type1 OR
      d.mpp_type2 <> i.mpp_type2 OR
      d.mpp_type3 <> i.mpp_type3 OR
      d.mpp_type4 <> i.mpp_type4
      )
      and d.PayScheduleId is not null
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[manpower_revtypes]
ON [dbo].[manpowerprofile]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/**
 * 
 * NAME: 
 * dbo.manpower_revtypes
 *
 * TYPE: 
 * Trigger
 *
 * DESCRIPTION:
 *
 * RETURNS: 
 * N/A
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS: 
 * N/A
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 08/05/2005.01 PTS29148 - jguo - replace double quotes
 * 05/28/2013 PTS69778 - mtc - trim comments to prevent truncation errors.
 *
    11/17/2014  Mindy Curnutt			PTS 84589 - If an update fired but no rows were changed, get out of the trigger.
*/

if NOT EXISTS (select top 1 * from inserted)
    return

/* Get the range of level for this job type from the jobs table. */
DECLARE @mpp_id varchar(8), 
        @rev_type1 varchar(8), 
	@rev_type2 varchar(8), 
        @msg varchar(255),
        @payto varchar(13),
        @ginfo int,
	@maptuitgeocode Char(1),
	@mpp_firstname varchar(40),
	@mpp_lastname varchar(40),
	@mpp_teamleader varchar(6),
	@m2qhid int

-- JET - 4/28/99 - PTS #5218, need to add trigger code from rest of PowerSuite
BEGIN
declare @DrvTrcProt varchar(10)
declare @home varchar(45), @latseconds int, @longseconds int --PTS 69778

--PTS 61188 JJF 20120621
DECLARE @CursorNeeded bit
DECLARE @TotalMailFleetToGroupsSyncGI char(1)
DECLARE @TotalMailDriverToTractorSyncGI char(1)
DECLARE @sDispatchGroupName varchar(30)
DECLARE @trc_number varchar(8)
DECLARE @TotalMailConnectionPrefix varchar(1000)
DECLARE	@SQLDyn varchar(2500)
DECLARE @prior_trc_number varchar(8)
--END PTS 61188 JJF 20120621
--PTS71153 JJF 20130809
DECLARE @DriverToTractorFleetSyncGI char(1)
DECLARE @DriverToTractorGroupColumn varchar(30)
DECLARE @TotalMailGroupColumn varchar(30)
DECLARE @sNonMemberGroupName varchar(30)
DECLARE @sOldDispatchGroupName varchar(30)
DECLARE @sOldNonMemberGroupName varchar(30)
DECLARE @prior_mpp_id varchar(8)
DECLARE @TotalMailIgnoreMissingCommUnit char(1)
DECLARE @tm_sk_SyncNonMemberRelationship_flags int
--END PTS71153 JJF 20130809
--PTS80644 JJF 20140829
DECLARE	@TotalMailTractorOnlyFleetSyncGI char(1)
--END PTS80644 JJF 20140829
--PTS105694
DECLARE @DriverTractorRelationSync char(1)
DECLARE @DriverTractorRelationSyncClearTractorsFormerDriver char(1)
-- return if bulk update
if @@rowcount > 1 
 return

                                                                                                                                                                                                                               
/*update the state mpp_state*/
if update(mpp_city)
   UPDATE manpowerprofile 
   SET    manpowerprofile.mpp_state = city.cty_state
   FROM   inserted,city 
   WHERE  ( manpowerprofile.mpp_id = inserted.mpp_id ) AND 
          ( inserted.mpp_city = city.cty_code ) 

/* update lastfirst */
if update(mpp_lastname) or update(mpp_firstname)  
begin
   UPDATE manpowerprofile 
   SET    mpp_lastfirst = inserted.mpp_lastname + ',' + inserted.mpp_firstname 
   FROM   manpowerprofile, inserted 
   WHERE  ( manpowerprofile.mpp_id = inserted.mpp_id ) AND 
          ( inserted.mpp_id <> 'UNKNOWN' ) 
end

/* update trc_driver 
	vjh pts4691 981115 dont update the driver 1 if defaultdrv='NO'
		or if the driver id to be placed is already in driver2 */
/* vjh pts4873 980112 DrvTrcProt GI entry rather than defaultdrv */

   IF NOT UPDATE ( mpp_avl_status )
   BEGIN
      select @DrvTrcProt=gi_string1 from generalinfo where gi_name='DrvTrcProt'
      if upper(isnull(@DrvTrcProt,'NONE')) = 'NONE' or 
         upper(isnull(@DrvTrcProt,'NONE')) = 'DRV'
      BEGIN
         UPDATE tractorprofile 
         SET    trc_driver = inserted.mpp_id 
         FROM   tractorprofile, inserted 
         WHERE  ( tractorprofile.trc_number = inserted.mpp_tractornumber ) AND
                ( inserted.mpp_tractornumber <> 'UNKNOWN' ) and
		( tractorprofile.trc_driver2 <> inserted.mpp_id)
      END
   END
END
-- JET - 4/28/99 - PTS #5218


--PTS105694 
IF UPDATE(mpp_tractornumber) BEGIN
	SELECT	@DriverTractorRelationSync = gi_string1, @DriverTractorRelationSyncClearTractorsFormerDriver = gi_string2
	FROM	generalinfo gi
	WHERE	gi.gi_name = 'DriverTractorRelationSync'

	IF @DriverTractorRelationSync = 'Y' BEGIN

		--Did the tractor indeed change?
		IF EXISTS	(	SELECT	*
					FROM	inserted mpp_current
							INNER JOIN deleted mpp_prior on mpp_current.mpp_id = mpp_prior.mpp_id		
					WHERE	mpp_current.mpp_tractornumber <> mpp_prior.mpp_tractornumber
				) BEGIN
		
			--Clear out former tractor profiles's driver 
			UPDATE	tractorprofile
			SET		trc_driver = 'UNKNOWN'
			FROM	inserted mpp_current
					INNER JOIN deleted mpp_prior on mpp_current.mpp_id = mpp_prior.mpp_id
			WHERE	trc_number = mpp_prior.mpp_tractornumber
					AND mpp_current.mpp_tractornumber <> mpp_prior.mpp_tractornumber

			--For any other drivers that have the newly assigned tractor, clear their default tractor
			IF @DriverTractorRelationSyncClearTractorsFormerDriver = 'Y' BEGIN
				UPDATE	manpowerprofile
				SET		mpp_tractornumber = 'UNKNOWN'
				FROM	manpowerprofile
						INNER JOIN inserted mppi on (manpowerprofile.mpp_tractornumber = mppi.mpp_tractornumber AND manpowerprofile.mpp_id <> mppi.mpp_id)
				WHERE	manpowerprofile.mpp_id <> 'UNKNOWN'
						AND mppi.mpp_tractornumber <> 'UNKNOWN'
			END

			--Set new tractor's default driver 
			UPDATE	tractorprofile 
			SET		trc_driver = trci.mpp_id 
			FROM	tractorprofile
					INNER JOIN inserted trci on tractorprofile.trc_number = trci.mpp_tractornumber
			WHERE	trci.mpp_tractornumber <> 'UNKNOWN'
					AND tractorprofile.trc_driver2 <> trci.mpp_id
		END 			
	END
END


-- initialize the general info setting variable
SELECT @ginfo = gi_integer1 
  FROM generalinfo
 WHERE Upper(gi_name) = 'TPRREVCHECK'



IF @ginfo = 1 and (SELECT count(*) FROM inserted) = 1
BEGIN
	-- initialize the error values
	SELECT @msg = ''
	-- store the mpp_id, mpp_company and mpp_terminal
	SELECT @mpp_id = mpp_id,
	       @rev_type1 = mpp_company,
	       @rev_type2 = mpp_terminal,
	       @payto = mpp_payto
	  FROM inserted
	IF @mpp_id in (NULL, '', 'UNKNOWN')
	   RETURN
	IF @rev_type1 in (NULL, '', 'UNK') or @rev_type2 in (NULL, '', 'UNK')
	BEGIN
	   -- if the rev type 1 value is missing, let the user know.
	   IF @rev_type1 in (NULL, '', 'UNK')
	      SELECT @msg = @mpp_id + ' requires a company value.' + CHAR(13)
	   -- if the rev type 2 value is missing, let the user know.
	   IF @rev_type2 in (NULL, '', 'UNK')
	      SELECT @msg = LTRIM(@msg + SPACE(16) + @mpp_id + ' requires a terminal value.' + CHAR(13))
	   RAISERROR (@msg, 16, -1)
	   ROLLBACK TRANSACTION
	END
	ELSE
	IF SUBSTRING(@rev_type1, 1, 1) <> SUBSTRING(@rev_type2, 1, 1)
	BEGIN
	   -- let the user know that the terminal does not match the company selected
	   SELECT @msg = 'Terminal ' + @rev_type2 + ' does not belong to Company ' + @rev_type1 + '.'
	   RAISERROR (@msg, 16, -1)
	   ROLLBACK TRANSACTION
	END
	ELSE
	IF @payto in (NULL, '', 'UNKNOWN')
	BEGIN
	   -- let the user know that the payto needs to be assigned
	   SELECT @msg = 'You must assign a Payto to driver ' + @mpp_id
	   RAISERROR (@msg, 16, -1)
	   ROLLBACK TRANSACTION
	END
END




   if update(mpp_home_latitude) or update(mpp_home_longitude)
   begin
	select @mpp_id=''
	while (select count(*)
		from inserted
		where mpp_id > @mpp_id and mpp_home_latitude > 0 and mpp_home_longitude > 0)> 0
	begin	 	
		select @mpp_id =min(mpp_id)
		from inserted
		where mpp_id > @mpp_id and mpp_home_latitude > 0 and mpp_home_longitude > 0

		select @latseconds=convert(int, (mpp_home_latitude + 50)/100)*100,
			@longseconds=convert(int, (mpp_home_longitude + 50)/100)*100
		from manpowerprofile	
		where mpp_id = @mpp_id
	
		select @home = LEFT(min(ckc_comment),45) --PTS69778
		from checkcall
		where @latseconds = convert(int, (ckc_latseconds + 50)/100)*100 and
			@longseconds = convert(int, (ckc_longseconds + 50)/100)*100 and
		ckc_asgnid = @mpp_id and ckc_asgntype = 'DRV'

		update manpowerprofile
		set mpp_home_city =@home
		where mpp_id = @mpp_id
	end
    end



/* PTS22080 MBR 03/01/04 */
IF UPDATE(mpp_firstname) OR UPDATE(mpp_lastname) OR UPDATE(mpp_teamleader)
BEGIN
   IF (SELECT UPPER(gi_string1) FROM generalinfo WHERE gi_name = 'MaptuitAlert') = 'Y'
   BEGIN
      SELECT @mpp_id = mpp_id,
             @mpp_firstname = isnull(mpp_firstname,''),
             @mpp_lastname = isnull(mpp_lastname,''),
             @mpp_teamleader = isnull(mpp_teamleader,'')
        FROM inserted
      IF @mpp_teamleader IS NOT NULL AND @mpp_teamleader <> 'UNK'
      BEGIN
         EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'Driver_DriverID', 'HIL', @mpp_id)
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'Driver_FirstName', 'HIL', @mpp_firstname)
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'Driver_LastName', 'HIL', @mpp_lastname)
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'Driver_DMUserID', 'HIL', @mpp_teamleader)
         INSERT INTO m2msgqhdr VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')
      END
   END
END



--PTS 61188 JJF 20120621
--PTS71153 JJF 20130809 - add gi_string2
SELECT	@DriverToTractorFleetSyncGI = UPPER(gi_string1),
		@DriverToTractorGroupColumn = UPPER(ISNULL(gi_string2, 'Fleet'))
FROM	generalinfo
WHERE	gi_name = 'DriverToTractorFleetSync'

IF @DriverToTractorGroupColumn = '' BEGIN
	SELECT @DriverToTractorGroupColumn = 'FLEET'
END

SELECT	@TotalMailTractorOnlyFleetSyncGI = UPPER(gi_string1)
FROM	generalinfo
WHERE	gi_name = 'TotalMailTractorOnlyFleetSync'



IF	@DriverToTractorFleetSyncGI = 'Y' BEGIN
	IF	UPDATE(mpp_tractornumber)
		OR	(	UPDATE(mpp_fleet) AND @DriverToTractorGroupColumn = 'FLEET'	)
		OR	(	UPDATE(mpp_teamleader) AND @DriverToTractorGroupColumn = 'TEAMLEADER'	) BEGIN
		
		IF EXISTS	(	SELECT	*
						FROM	inserted mpp
								INNER JOIN tractorprofile trc on mpp.mpp_tractornumber = trc.trc_number
						WHERE	(	(	@DriverToTractorGroupColumn = 'FLEET' 
										AND trc.trc_fleet <> mpp.mpp_fleet
									)
									OR	(	@DriverToTractorGroupColumn = 'TEAMLEADER'
										AND trc.trc_teamleader <> mpp.mpp_teamleader
									)
								) AND trc.trc_number <> 'UNKNOWN'
					) BEGIN
			IF @DriverToTractorGroupColumn = 'FLEET' BEGIN

				--print 'driver trigger updates corresponding tractor fleet'

				UPDATE	tractorprofile
				SET		trc_fleet = mpp.mpp_fleet
				FROM	inserted mpp
						INNER JOIN tractorprofile trc on mpp.mpp_tractornumber = trc.trc_number
				WHERE	trc.trc_fleet <> mpp.mpp_fleet
						AND trc.trc_number <> 'UNKNOWN'
			END
			IF @DriverToTractorGroupColumn = 'TEAMLEADER' BEGIN
				UPDATE	tractorprofile
				SET		trc_teamleader = mpp.mpp_teamleader
				FROM	inserted mpp
						INNER JOIN tractorprofile trc on mpp.mpp_tractornumber = trc.trc_number
				WHERE	trc.trc_teamleader <> mpp.mpp_teamleader
						AND trc.trc_number <> 'UNKNOWN'
			END
		END
													
	END
END



--IF EXISTS	(	SELECT	*
--				FROM	generalinfo
--				WHERE	gi_name = 'DriverToTractorFleetSync'
--						AND gi_string1 = 'Y'
--			) 
--			AND	(	UPDATE(mpp_tractornumber) 
--					OR UPDATE(mpp_fleet)
--				) BEGIN
--		
--	--Setting to keep trc_fleet = mpp_fleet
--	IF EXISTS	(	SELECT	*
--					FROM	inserted mpp 
--							INNER JOIN tractorprofile trc on mpp.mpp_tractornumber = trc.trc_number
--					WHERE	trc.trc_fleet <> mpp.mpp_fleet
--							AND trc.trc_number <> 'UNKNOWN'
--				) BEGIN
--		UPDATE	tractorprofile
--		SET		trc_fleet = mpp.mpp_fleet
--		FROM	inserted mpp 
--				INNER JOIN tractorprofile trc on mpp.mpp_tractornumber = trc.trc_number
--		WHERE	trc.trc_fleet <> mpp.mpp_fleet
--				AND trc.trc_number <> 'UNKNOWN'
--	END
--END


--Cursor set up to iterate through inserted table
--Use for any other processing that must be done one row at a time
--PTS71153 JJF 20130809 Add Groupcolumn
SELECT	@TotalMailFleetToGroupsSyncGI = UPPER(gi_string1),
		@TotalMailGroupColumn = UPPER(ISNULL(gi_string2, 'Fleet')),
		@TotalMailIgnoreMissingCommUnit = UPPER(ISNULL(gi_string3, 'N'))
FROM	generalinfo
WHERE	gi_name = 'TotalMailFleetToGroupsSync'

IF @TotalMailGroupColumn = '' BEGIN
	SELECT @TotalMailGroupColumn = 'FLEET'
END

SET @tm_sk_SyncNonMemberRelationship_flags = 0
IF @TotalMailIgnoreMissingCommUnit = 'Y' BEGIN
	SET @tm_sk_SyncNonMemberRelationship_flags = 1
END 

SELECT	@TotalMailDriverToTractorSyncGI = UPPER(gi_string1)
FROM	generalinfo
WHERE	gi_name = 'TotalMailDriverToTractorSync'


IF	@TotalMailFleetToGroupsSyncGI = 'Y'
	OR @TotalMailDriverToTractorSyncGI = 'Y' BEGIN
	SELECT @CursorNeeded = 1
END


--dentro de este cursor esta el problema

IF @CursorNeeded = 1 BEGIN
	DECLARE ManpowerProfileCursor CURSOR FAST_FORWARD FOR
		SELECT	mpp.mpp_id
		FROM	inserted mpp

	OPEN	ManpowerProfileCursor

	FETCH NEXT FROM ManpowerProfileCursor
	INTO	@mpp_id

	WHILE	@@FETCH_STATUS = 0 BEGIN
		--Primary select to fetch info for current row in cursor
		--PTS 66805 JJF 20130124 Add additional prior tractor
		--PTS71153 JJF 20130809 - add gi_string2
		SELECT	@sDispatchGroupName = ISNULL(LEFT(lbl.label_extrastring1, 30), ''),
				@sNonMemberGroupName = ISNULL(LEFT(lbl.label_extrastring3, 30), ''),
				@trc_number = mpp.mpp_tractornumber,
				@prior_trc_number = ISNULL(mpp_prior.mpp_tractornumber, 'UNKNOWN'),
				@prior_mpp_id = ISNULL(mpp_prior.mpp_id, 'UNKNOWN')
		FROM	labelfile lbl
				INNER JOIN inserted mpp on (	(@TotalMailGroupColumn = 'FLEET' AND mpp.mpp_fleet = lbl.abbr AND UPPER(lbl.labeldefinition) = 'FLEET')
												OR (@TotalMailGroupColumn = 'TEAMLEADER' AND mpp.mpp_teamleader = lbl.abbr AND UPPER(lbl.labeldefinition) = 'TEAMLEADER')
											)
				LEFT OUTER JOIN deleted mpp_prior on (mpp_prior.mpp_id = mpp.mpp_id)
		WHERE	mpp.mpp_id = @mpp_id

		SELECT	@sOldDispatchGroupName = ISNULL(LEFT(lbl.label_extrastring1, 30), ''),
				@sOldNonMemberGroupName = ISNULL(LEFT(lbl.label_extrastring3, 30), '')
		FROM	labelfile lbl
				INNER JOIN deleted mpp on (	(@TotalMailGroupColumn = 'FLEET' AND mpp.mpp_fleet = lbl.abbr AND UPPER(lbl.labeldefinition) = 'FLEET')
												OR (@TotalMailGroupColumn = 'TEAMLEADER' AND mpp.mpp_teamleader = lbl.abbr AND UPPER(lbl.labeldefinition) = 'TEAMLEADER')
											)
		WHERE	mpp.mpp_id = @mpp_id

		IF	@TotalMailFleetToGroupsSyncGI = 'Y' BEGIN
			SELECT	@TotalMailConnectionPrefix =  dbo.totalmail_connection_fn()
		END

		--PTS 66805 JJF 20130124
		--Disassociate this driver from the prior truck
		IF	(	(	@TotalMailDriverToTractorSyncGI = 'Y'	)
				--AND (	@TotalMailTractorOnlyFleetSyncGI = 'N'	)
				AND (	(	UPDATE(mpp_tractornumber) AND @prior_trc_number <> 'UNKNOWN' AND @prior_trc_number <> @trc_number )
						OR	(@prior_mpp_id = 'UNKNOWN'	)
					) 
			) BEGIN
			

			--print 'driver trigger removes driver from prior tractor'

			--remove driver from prior totalmail tractor
			--If prior_mpp_id is UNKNOWN, this has the net effect of adding the driver
			SELECT	@SQLDyn = 'EXEC	' + 
				@TotalMailConnectionPrefix + 'dbo.tm_ConfigDriver2 ' + 
				'''' + @mpp_id + ''', ' +
				'''' + @mpp_id + ''', ' +
				'NULL, ' +
				'NULL, ' +
				'''' + @mpp_id + ''', ' +
				'NULL, ' +
				''''', ' +
				'NULL, ' +
				'NULL, ' +
				'NULL ' 
			
			EXEC (@SQLDyn)
			
		END
		--END PTS 66805 JJF 20130124

		IF	@TotalMailDriverToTractorSyncGI = 'Y'
			--AND @TotalMailTractorOnlyFleetSyncGI = 'N'
			AND UPDATE(mpp_tractornumber) AND @trc_number <> 'UNKNOWN' BEGIN
			
			--print 'driver trigger associates driver to current tractor'

			--Totalmail driver to be assigned to totalmail tractor
			SELECT	@SQLDyn = 'EXEC	' + 
				@TotalMailConnectionPrefix + 'dbo.tm_ConfigTruck2 ' + 
				'''' + @trc_number + ''', ' +
				'''' + @trc_number + ''', ' +
				'NULL, ' +
				'NULL, ' +
				'NULL, ' +
				'''' + @mpp_id + ''', ' +
				'NULL, ' +
				'NULL, ' +
				'NULL ' 
			
			EXEC (@SQLDyn)
		END
			
		--PTS71153 JJF 20130809 - add gi_string2
		IF	(	(@TotalMailFleetToGroupsSyncGI = 'Y' )
				--AND (	@TotalMailTractorOnlyFleetSyncGI = 'N' )
				AND (	@mpp_id <> 'UNKNOWN' )
				AND	(	@sDispatchGroupName	<> '' )
				AND	(	(	@TotalMailGroupColumn = 'FLEET' AND UPDATE(mpp_fleet))
						 OR	(	@TotalMailGroupColumn = 'TEAMLEADER' AND UPDATE(mpp_teamleader)	)
					)
			) BEGIN --Setting to sync to totalmail
		
			--print 'driver trigger verifies dispatch group'

			SELECT	@SQLDyn = 'EXEC	' + 
				@TotalMailConnectionPrefix + 'dbo.tm_CreateDispatchGroup ' + 
				'''' + @sDispatchGroupName + ''', ' +
				'''' + ''', ' +
				'0, ' +
				'0'
			EXEC (@SQLDyn)
			
			--print 'driver trigger associates driver with dispatch group.'

			--Driver's dispatch group in totalmail is to be updated to match the driver's fleet dispatch group setting in fleet's extrastring1	
			SELECT	@SQLDyn = 'EXEC	' + 
								@TotalMailConnectionPrefix + 'dbo.tm_sk_SyncDispatchRelationship ' + 
								'''' + @sDispatchGroupName + ''', ' +
								'''DRV'', ' +
								'''' + @mpp_id + ''', ' +
								'0'
			
			EXEC (@SQLDyn)
			
		END

		--PTS71153 JJF 20130809 - add gi_string2
		IF	@TotalMailFleetToGroupsSyncGI = 'Y'
			AND @DriverToTractorFleetSyncGI = 'Y' --PTS 80644 - Take new setting into account.
			--AND @TotalMailTractorOnlyFleetSyncGI = 'N'
			AND @mpp_id <> 'UNKNOWN' 
			AND	(	@sDispatchGroupName	<> '' )
			AND @trc_number <> 'UNKNOWN'  
			AND	(	UPDATE(mpp_tractornumber)
					OR	(@TotalMailGroupColumn = 'FLEET' AND UPDATE(mpp_fleet))
					OR	(@TotalMailGroupColumn = 'TEAMLEADER' AND UPDATE(mpp_teamleader))
				) BEGIN --Setting to sync to totalmail


			--print 'driver trigger verifies dispatch group for updated tractor'

			SELECT	@SQLDyn = 'EXEC	' + 
				@TotalMailConnectionPrefix + 'dbo.tm_CreateDispatchGroup ' + 
				'''' + @sDispatchGroupName + ''', ' +
				'''' + ''', ' +
				'0, ' +
				'0'
			EXEC (@SQLDyn)

			--print 'driver trigger associates tractor with dispatch group'
				
			--Tractor dispatch group in totalmail is to be update to match the tractors (driver) fleet dispatch group setting in fleet's extrastring1
			SELECT	@SQLDyn = 'EXEC	' + 
								@TotalMailConnectionPrefix + 'dbo.tm_sk_SyncDispatchRelationship ' + 
								'''' + @sDispatchGroupName + ''', ' +
								'''TRC'', ' +
								'''' + @trc_number + ''', ' +
								'0'
			EXEC (@SQLDyn)
		END
				
		IF	@TotalMailFleetToGroupsSyncGI = 'Y' 
			--AND @TotalMailTractorOnlyFleetSyncGI = 'N'
			AND @mpp_id <> 'UNKNOWN' 
			AND	(	@sNonMemberGroupName	<> '' )
			AND @trc_number <> 'UNKNOWN'  
			AND	(	UPDATE(mpp_tractornumber)
					OR	(@TotalMailGroupColumn = 'FLEET' AND UPDATE(mpp_fleet))
					OR	(@TotalMailGroupColumn = 'TEAMLEADER' AND UPDATE(mpp_teamleader))
				) BEGIN --Setting to sync to totalmail

			--print 'driver trigger verifies member group for tractor'

			SELECT	@SQLDyn = 'EXEC ' +
								@TotalMailConnectionPrefix + 'dbo.tm_CreateMemberGroup ' +
								'''' + @sNonMemberGroupName + ''', ' +
								'''' + ''', ' + 
								'0, ' +
								'2 '
			EXEC (@SQLDyn)
			

			--print 'driver trigger associates tractor to member group'

			SELECT	@SQLDyn = 'EXEC	' + 
								@TotalMailConnectionPrefix + 'dbo.tm_sk_SyncNonMemberRelationship ' + 
								'''' + @sOldNonMemberGroupName + ''', ' +
								'''' + @sNonMemberGroupName + ''', ' +
								'''' + @sDispatchGroupName + ''', ' +
								'''TRC'', ' +
								'''' + @trc_number + ''', ' +
								'''' + convert(varchar(6), @tm_sk_SyncNonMemberRelationship_flags) + ''''
			EXEC (@SQLDyn)
		END
		

		FETCH NEXT FROM ManpowerProfileCursor
		INTO	@mpp_id
	END
	
	CLOSE ManpowerProfileCursor
	DEALLOCATE ManpowerProfileCursor

END
--END PTS 61188 JJF 20120621

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [dbo].[tr_alta_personal_tmw]  ON [dbo].[manpowerprofile] 
AFTER INSERT
AS

begin
 -- select * from  sp_help manpowerprofile where mpp_id = 'ORTGE01'

 --select id_personal, fecha_nacimiento, fecha_ingreso, nombre, direccion, telefono, rfc, imss, 
 --folio_licencia, tipo_licencia, cp, Curp, Sexo,tipo_empleado, tel_movil, id_categoria , id_Depto, * from tdrsilt..personal_personal where id_personal >= 6418


Set Nocount on 

declare @V_mpp_lastfirst varchar(45),
 @V_mpp_firstname varchar(40),
@V_mpp_lastname varchar(40),
@V_mpp_address1 varchar(30),
@V_mpp_zip varchar(10),
@V_mpp_hiredate datetime,
@V_mpp_licenseclass varchar(15),
@V_mpp_licensenumber varchar(25),
@V_mpp_dateofbirth datetime,
@V_mpp_currentphone  varchar(20),
@V_mpp_homephone  varchar(20),
@V_mpp_misc1  varchar(254),
@V_mpp_misc3  varchar(254),
@V_mpp_misc4  varchar(254),
@V_idoperador integer




Select @V_mpp_firstname = I.mpp_firstname,
@V_mpp_lastname = I.mpp_lastname,
@V_mpp_address1			= I.mpp_address1,
@V_mpp_zip				= I.mpp_zip,
@V_mpp_hiredate			= I.mpp_hiredate,
@V_mpp_licenseclass		= I.mpp_licenseclass,
@V_mpp_licensenumber	= I.mpp_licensenumber,
@V_mpp_dateofbirth		= I.mpp_dateofbirth,
@V_mpp_currentphone		= I.mpp_currentphone,
@V_mpp_homephone		= I.mpp_homephone,
@V_mpp_misc1			= I.mpp_misc1,
@V_mpp_misc3			= I.mpp_misc3,
@V_mpp_misc4			= I.mpp_misc4
From INSERTED I


select @V_mpp_lastfirst	= Isnull(@V_mpp_lastname," ") +" "+ IsNull(@V_mpp_firstname," ")

	-- Busca el proximo Id del operador para hacer el insert
	Select @V_idoperador = max(id_personal)  from tdrsilt..personal_personal;

	select @V_idoperador = @V_idoperador+1
	--print "nombre " + isnull(@V_mpp_lastfirst,'nulo')
	Insert tdrsilt..personal_personal( id_personal, fecha_nacimiento, fecha_ingreso, nombre, direccion, 
	telefono, rfc, imss, folio_licencia, tipo_licencia, 
	cp, Curp, Sexo,tipo_empleado, tel_movil,
	id_Categoria, id_area, id_depto, estado, tipo_contrato,causa_alta,id_flota)
	Values(@V_idoperador, @V_mpp_dateofbirth, @V_mpp_hiredate, @V_mpp_lastfirst, @V_mpp_address1, 
	@V_mpp_homephone, @V_mpp_misc3,@V_mpp_misc1, @V_mpp_licensenumber, @V_mpp_licenseclass, 
	@V_mpp_zip, @V_mpp_misc4,'M','O', @V_mpp_currentphone,
	16,1, 4 ,'A','E','V',0 )

end

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [dbo].[tr_altapersonalexpiration]  ON [dbo].[manpowerprofile] 
FOR INSERT
AS


Set Nocount on 

declare	@oper   varchar(10)
declare @hire datetime



Select @oper  = mpp_id     ,
@hire =       mpp_hiredate
From inserted



INSERT INTO  TMWsuite.dbo.expiration
				( exp_idtype,   exp_id,   exp_code,   exp_lastdate,   exp_expirationdate,   
				  exp_routeto,  exp_completed,  exp_priority,   exp_compldate,   exp_updateby,   
				exp_creatdate,   exp_updateon,   exp_description, exp_milestoexp,    
				exp_city,   mov_number,   exp_control_avl_date,   skip_trigger)  

				  VALUES ( 'DRV',  @oper,   'INS',   @hire,  @hire,  
					   'TDRQUERE', 'Y',   1, @hire, 'AUTO',   
						   @hire, @hire, 'Fecha de contratacion',  Null,
						   15765,    null,   'N',  null );
GO
ALTER TABLE [dbo].[manpowerprofile] ADD CONSTRAINT [mpp_ckmcommtype] CHECK (([dbo].[CheckLabel]([mpp_mcommType],'MCommSystem',(1))=(1)))
GO
ALTER TABLE [dbo].[manpowerprofile] ADD CONSTRAINT [PK_manpowerprofile] PRIMARY KEY NONCLUSTERED ([mpp_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [u_mpp_id] ON [dbo].[manpowerprofile] ([mpp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lastfirst] ON [dbo].[manpowerprofile] ([mpp_lastfirst]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [d_mpp_otherid] ON [dbo].[manpowerprofile] ([mpp_otherid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mpp_shiftbackup] ON [dbo].[manpowerprofile] ([mpp_shift_isbackup]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_manpowerprofile_mpp_status] ON [dbo].[manpowerprofile] ([mpp_status]) INCLUDE ([mpp_company], [mpp_division], [mpp_domicile], [mpp_fleet], [mpp_id], [mpp_teamleader], [mpp_terminal], [mpp_type1], [mpp_type2], [mpp_type3], [mpp_type4]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [dk_terminal_teamleader] ON [dbo].[manpowerprofile] ([mpp_terminal], [mpp_teamleader]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Manpowerprofile_timestamp] ON [dbo].[manpowerprofile] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[manpowerprofile] TO [public]
GO
GRANT INSERT ON  [dbo].[manpowerprofile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[manpowerprofile] TO [public]
GO
GRANT SELECT ON  [dbo].[manpowerprofile] TO [public]
GO
GRANT UPDATE ON  [dbo].[manpowerprofile] TO [public]
GO
