CREATE TABLE [dbo].[tractorprofile]
(
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trc_owner] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tractorpr__trc_o__3EBD23B6] DEFAULT ('UNKNOWN'),
[trc_make] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_model] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_currenthub] [int] NULL CONSTRAINT [DF__tractorpr__trc_c__3FB147EF] DEFAULT (0),
[trc_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_t__40A56C28] DEFAULT ('UNK'),
[trc_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_t__41999061] DEFAULT ('UNK'),
[trc_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_t__428DB49A] DEFAULT ('UNK'),
[trc_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_t__4381D8D3] DEFAULT ('UNK'),
[trc_year] [int] NULL,
[trc_startdate] [datetime] NULL CONSTRAINT [DF__tractorpr__trc_s__4475FD0C] DEFAULT (getdate()),
[trc_retiredate] [datetime] NULL CONSTRAINT [DF__tractorpr__trc_r__456A2145] DEFAULT ('12-31-2049 0:0:0.000'),
[trc_mpg] [float] NULL CONSTRAINT [DF__tractorpr__trc_m__465E457E] DEFAULT (0),
[trc_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_c__475269B7] DEFAULT ('UNK'),
[trc_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_d__48468DF0] DEFAULT ('UNK'),
[trc_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_f__493AB229] DEFAULT ('UNK'),
[trc_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_t__4A2ED662] DEFAULT ('UNK'),
[trc_dateacquired] [datetime] NULL CONSTRAINT [DF__tractorpr__trc_d__4B22FA9B] DEFAULT (getdate()),
[trc_origmileage] [int] NULL CONSTRAINT [DF__tractorpr__trc_o__4C171ED4] DEFAULT (0),
[trc_enginehrs] [int] NULL CONSTRAINT [DF__tractorpr__trc_e__4D0B430D] DEFAULT (0),
[trc_enginemake] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_enginemodel] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_engineserial] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_serial] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_licstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_licnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_origcost] [float] NULL CONSTRAINT [DF__tractorpr__trc_o__4DFF6746] DEFAULT (0),
[trc_opercostpermi] [float] NULL CONSTRAINT [DF__tractorpr__trc_o__4EF38B7F] DEFAULT (0),
[trc_grosswgt] [int] NULL CONSTRAINT [DF__tractorpr__trc_g__4FE7AFB8] DEFAULT (0),
[trc_axles] [smallint] NULL CONSTRAINT [DF__tractorpr__trc_a__50DBD3F1] DEFAULT (0),
[trc_warrantydays] [int] NULL CONSTRAINT [DF_tractorprofile_trc_warrantydays] DEFAULT (0),
[trc_commethod] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_s__52C41C63] DEFAULT ('AVL'),
[trc_avl_date] [datetime] NULL CONSTRAINT [DF__tractorpr__trc_a__53B8409C] DEFAULT (getdate()),
[trc_avl_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_a__54AC64D5] DEFAULT ('UNKNOWN'),
[trc_avl_city] [int] NULL CONSTRAINT [DF__tractorpr__trc_a__55A0890E] DEFAULT (0),
[trc_avl_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_a__5694AD47] DEFAULT ('AVL'),
[trc_pln_date] [datetime] NULL,
[trc_pln_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_p__5788D180] DEFAULT ('UNKNOWN'),
[trc_pln_city] [int] NULL CONSTRAINT [DF__tractorpr__trc_p__587CF5B9] DEFAULT (0),
[trc_pln_lgh] [int] NULL CONSTRAINT [DF__tractorpr__trc_p__597119F2] DEFAULT (0),
[trc_avl_lgh] [int] NULL CONSTRAINT [DF__tractorpr__trc_a__5A653E2B] DEFAULT (0),
[trc_cur_mileage] [int] NULL CONSTRAINT [DF__tractorpr__trc_c__5B596264] DEFAULT (0),
[trc_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_d__5C4D869D] DEFAULT ('UNKNOWN'),
[timestamp] [timestamp] NULL,
[trc_actg_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_a__5D41AAD6] DEFAULT ('A'),
[trc_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_d__5E35CF0F] DEFAULT ('UNKNOWN'),
[trc_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_u__5F29F348] DEFAULT (suser_sname()),
[trc_turndown] [datetime] NULL,
[trc_phone] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_nextdestpref] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_mtcalltime] [datetime] NULL,
[trc_updatedon] [datetime] NULL CONSTRAINT [DF__tractorpr__trc_u__601E1781] DEFAULT (getdate()),
[trc_tareweight] [float] NULL CONSTRAINT [DF__tractorpr__trc_t__62065FF3] DEFAULT (0),
[trc_tareweight_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_t__65D6F0D7] DEFAULT ('UNK'),
[trc_bmpr_to_steer] [float] NULL CONSTRAINT [DF__tractorpr__trc_b__62FA842C] DEFAULT (0),
[trc_bmpr_to_steer_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_b__66CB1510] DEFAULT ('UNK'),
[trc_steer_to_drive1] [float] NULL CONSTRAINT [DF__tractorpr__trc_s__63EEA865] DEFAULT (0),
[trc_steer_to_drive1_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_s__67BF3949] DEFAULT ('UNK'),
[trc_drive1_to_drive2] [float] NULL CONSTRAINT [DF__tractorpr__trc_d__6A9BA5F4] DEFAULT (0),
[trc_drive1_to_drive2_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_d__68B35D82] DEFAULT ('UNK'),
[trc_drive2_to_rear] [float] NULL CONSTRAINT [DF__tractorpr__trc_d__64E2CC9E] DEFAULT (0),
[trc_drive2_to_rear_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_d__69A781BB] DEFAULT ('UNK'),
[trc_createdate] [datetime] NULL CONSTRAINT [DF__tractorpr__trc_c__61123BBA] DEFAULT (getdate()),
[trc_whltobase] [int] NULL CONSTRAINT [DF__tractorpr__trc_w__6B8FCA2D] DEFAULT (0),
[trc_cabtoaxle] [int] NULL CONSTRAINT [DF__tractorpr__trc_c__6C83EE66] DEFAULT (0),
[trc_bprtobkcab] [int] NULL CONSTRAINT [DF__tractorpr__trc_b__6D78129F] DEFAULT (0),
[trc_frontaxlspc] [int] NULL CONSTRAINT [DF__tractorpr__trc_f__6E6C36D8] DEFAULT (0),
[trc_rearaxlspc] [int] NULL CONSTRAINT [DF__tractorpr__trc_r__6F605B11] DEFAULT (0),
[trc_fifthwhltvl] [int] NULL CONSTRAINT [DF__tractorpr__trc_f__70547F4A] DEFAULT (0),
[trc_dummy] [int] NULL,
[trc_ttltarewt] [int] NULL CONSTRAINT [DF__tractorpr__trc_t__7148A383] DEFAULT (0),
[trc_whltobase_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_w__723CC7BC] DEFAULT ('UNK'),
[trc_cabtoaxle_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_c__7330EBF5] DEFAULT ('UNK'),
[trc_bprtobkcab_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_b__7425102E] DEFAULT ('UNK'),
[trc_frontaxlspc_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_f__75193467] DEFAULT ('UNK'),
[trc_rearaxlspc_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_r__760D58A0] DEFAULT ('UNK'),
[trc_fifthwhltvl_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_f__77017CD9] DEFAULT ('UNK'),
[trc_ttltarewt_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_t__77F5A112] DEFAULT ('UNK'),
[trc_fifthwheelht] [int] NULL CONSTRAINT [DF__tractorpr__trc_f__78E9C54B] DEFAULT (0),
[trc_fifthwheelht_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_f__79DDE984] DEFAULT ('UNK'),
[trc_quickentry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_q__7AD20DBD] DEFAULT ('N'),
[trc_thirdparty] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_t__7BC631F6] DEFAULT ('UNKNOWN'),
[trc_gal_in_tank] [int] NULL,
[trc_tank_capacity] [int] NULL,
[trc_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_gps_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_gps_date] [datetime] NULL,
[trc_gps_latitude] [int] NULL,
[trc_gps_longitude] [int] NULL,
[trc_networks] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_exp1_date] [datetime] NULL,
[trc_exp2_date] [datetime] NULL,
[trc_nextmainthub] [int] NULL,
[trc_checkconflict] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tractorpr__trc_c__7CBA562F] DEFAULT ('Y'),
[trc_note_date] [datetime] NULL,
[trc_alert_date] [datetime] NULL,
[trc_prior_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_prior_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_prior_city] [int] NULL,
[trc_prior_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_prior_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_prior_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_prior_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_prior_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_next_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_next_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_next_city] [int] NULL,
[trc_next_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_next_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_next_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_next_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_next_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_require_drvtrl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_accessorylist] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_gps_odometer] [int] NULL,
[trc_newused] [int] NOT NULL CONSTRAINT [df_trc_newused] DEFAULT (1),
[trc_gp_class] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_trc_gp_class] DEFAULT ('TRACTOR'),
[trc_eta_skip] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_loading_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_axlgrp1_tarewgt] [float] NULL,
[trc_axlgrp1_grosswgt] [float] NULL,
[trc_axlgrp2_tarewgt] [float] NULL,
[trc_axlgrp2_grosswgt] [float] NULL,
[trc_exp1_enddate] [datetime] NULL,
[trc_exp2_enddate] [datetime] NULL,
[trc_m2_subconfig] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_lifetimemileage] [decimal] (12, 1) NULL,
[trc_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_usegeofencing] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_mctid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_aceid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_transponder] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_dotnumber] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_insurance_co] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_insurance_policy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_insurance_year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_insurance_amt] [int] NULL,
[trc_aceidtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_liccountry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_lastpos_datetime] [datetime] NULL,
[trc_lastpos_long] [float] NULL,
[trc_lastpos_nearctynme] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_lastpos_nearctyste] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_mobcommtype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_comment1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_cyclic_dsp_enabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_preassign_ack_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_suggested_paypercent] [float] NOT NULL CONSTRAINT [DF__tractorpr__trc_s__00A42029] DEFAULT (0),
[trc_lastpos_lat] [float] NULL,
[trc_prior_cmp_othertype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_next_cmp_othertype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_milestonext] [int] NULL,
[trc_next_stopnumber] [int] NULL,
[trc_next_legnumber] [int] NULL,
[trc_next_stoparrival] [datetime] NULL,
[trc_last_calcdate] [datetime] NULL,
[trc_altid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowsec_rsrv_id] [int] NULL,
[trc_dailyflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_dailyflagdate] [datetime] NULL,
[trc_distancecost_rate] [money] NULL,
[trc_costperhour] [money] NULL CONSTRAINT [DF__tractorpr__trc_c__7FF97B26] DEFAULT ((0)),
[trc_timezone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_owner2] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_ownerpct] [float] NULL,
[trc_teamleader] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tractorprofile_trc_teamleader] DEFAULT ('UNK'),
[trc_grandfather_date] [datetime] NULL,
[trc_app_eqcodes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_optimization_staging_customer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_optimization_modeling_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_reload_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_geo_process_oo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_geo_send_oo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_geo_process] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_geo_send] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_gps_heading] [float] NULL,
[trc_gps_speed] [int] NULL,
[trc_advpercent] [decimal] (5, 4) NULL,
[trc_DEFCapacity] [int] NULL,
[trc_DEFLevel] [int] NULL,
[trc_fueltype] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_mcommtrlid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_mcommID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_mcommType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_saldoedenred] [float] NULL,
[trc_pta_date] [datetime] NULL,
[PayScheduleId] [int] NULL,
[trc_optimizationdate] [datetime] NULL,
[trc_use_rfid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_rfid_tag] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginDestinationOption] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_ams_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__tractorpr__INS_T__7C8F2F4F] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_tractorprofile] ON [dbo].[tractorprofile] 
FOR DELETE 
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
 if exists 
  ( select * from event, deleted
     where deleted.trc_number = event.evt_tractor ) 
   begin
-- Sybase Syntax
--   raiserror 99999 'Cannot delete tractor: Assigned to trips'
-- MSS Syntax
     raiserror('Cannot delete tractor: Assigned to trips',16,1)
     rollback transaction
   end
Else
Begin
    -- PTS 38486    
	declare @trc_id varchar(8)
	select @trc_id = trc_number from deleted

	delete from contact_profile where con_id = @trc_id and con_asgn_type = 'TRACTOR'
	delete from expiration where exp_id = @trc_id and exp_idtype = 'TRC' -- PTS 39866
End

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tractor_changelog]
ON [dbo].[tractorprofile]
FOR INSERT, UPDATE 
AS 
/*
    11/17/2014  Mindy Curnutt			PTS 84589 - If an update fired but no rows were changed, get out of the trigger.
*/

if NOT EXISTS (select top 1 * from inserted)
    return

SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE	@updatecount	INTEGER,
	@delcount	INTEGER,
	@trc_number	    VARCHAR(8),
        @trc_gal_in_tank    INTEGER,
	@trc_litre_in_tank  DECIMAL(7,2),
	@trc_tank_capacity  INTEGER,
	@trc_litre_capacity DECIMAL(7,2),
        @trc_mpg            FLOAT,
	@trc_mpl            DECIMAL(7,2),
	@new_trc_driver	    VARCHAR(8),
	@old_trc_driver	    VARCHAR(8),
	@new_trc_fleet      VARCHAR(8),
	@old_trc_fleet	    VARCHAR(6),
	@mpp_teamleader	    VARCHAR(6),
	@m2qhid		    INTEGER

--PTS 61188 JJF 20120621
DECLARE @sDispatchGroupName varchar(30)
DECLARE @TotalMailConnectionPrefix varchar(1000)
DECLARE	@SQLDyn varchar(2500)
--END PTS 61188 JJF 20120621
--PTS71153 JJF 20130809
DECLARE @DriverToTractorFleetSyncGI char(1)
DECLARE @DriverToTractorGroupColumn varchar(30)
--END PTS71153 JJF 20130809
--PTS80644 JJF 20140829
DECLARE @CursorNeeded bit
DECLARE @TotalMailFleetToGroupsSyncGI char(1)
DECLARE @TotalMailTractorOnlyFleetSyncGI char(1)
DECLARE @TotalMailGroupColumn varchar(30)
DECLARE @TotalMailIgnoreMissingCommUnit char(1)
DECLARE @tm_sk_SyncNonMemberRelationship_flags int
DECLARE @sNonMemberGroupName varchar(30)
DECLARE @sOldDispatchGroupName varchar(30)
DECLARE @sOldNonMemberGroupName varchar(30)
--END PTS80644 JJF 20140829
--PTS85269 JJF 20150105 - add gi_string3
DECLARE @DriverToTractorTractorUpdatesDriver char(1)
--END PTS85269 JJF 20150105 - add gi_string3


--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

SELECT @updatecount = COUNT(*) FROM inserted
SELECT @delcount = COUNT(*) FROM deleted

IF (@updatecount > 0 AND NOT UPDATE(trc_updatedby) AND NOT UPDATE(trc_updatedon)) OR
	(@updatecount > 0 AND @delcount = 0)
BEGIN
	IF @delcount = 0
	BEGIN

		UPDATE	tractorprofile
		   SET	trc_updatedby = @tmwuser,
				trc_updatedon = GETDATE()
		  FROM	inserted
		 WHERE	inserted.trc_number = tractorprofile.trc_number AND
				(ISNULL(tractorprofile.trc_updatedby, '') <> @tmwuser OR
				 ISNULL(tractorprofile.trc_updatedon, '19500101') <> GETDATE())
	   -- PTS20988 MBR 02/23/04


           IF (SELECT UPPER(gi_string1) FROM generalinfo WHERE gi_name = 'MaptuitGeocode') = 'Y'
           BEGIN
              SELECT @trc_number = trc_number,
                     @trc_gal_in_tank = ISNULL(trc_gal_in_tank, 0),
                     @trc_tank_capacity = ISNULL(trc_tank_capacity, 0),
                     @trc_mpg = ISNULL(trc_mpg, 0),
                @new_trc_driver = trc_driver,
                @new_trc_fleet = isnull(trc_fleet,'')
                FROM inserted
              SET @trc_litre_in_tank = @trc_gal_in_tank/.264172951
              SET @trc_litre_capacity = @trc_tank_capacity/.264172951
              SET @trc_mpl = @trc_mpg/2.35214584
              INSERT INTO m2unfuelpf (ufunit, ufkeyvalue, ufvalue, ufstamp)
                              VALUES (@trc_number, 'FUELLEVEL', @trc_litre_in_tank, GETDATE())
              INSERT INTO m2unfuelpf (ufunit, ufkeyvalue, ufvalue, ufstamp)
                              VALUES (@trc_number, 'CAPACITY', @trc_litre_capacity, GETDATE())
              INSERT INTO m2unfuelpf (ufunit, ufkeyvalue, ufvalue, ufstamp)
                              VALUES (@trc_number, 'ECONOMY', @trc_mpl, GETDATE())
              --PTS22080 MBR 03/18/04
              SELECT @mpp_teamleader = isnull(mpp_teamleader,'')
                FROM manpowerprofile
               WHERE mpp_id = @new_trc_driver
              EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
              INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
				  VALUES (@m2qhid, 'Unit_UnitID', 'HIL', @trc_number)
	      	  INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
				  VALUES (@m2qhid, 'Unit_Trackable', 'HIL', '1')
              INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
				  VALUES (@m2qhid, 'Unit_DMUserID', 'HIL', @mpp_teamleader)
              INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
				  VALUES (@m2qhid, 'Unit_FleetID', 'HIL', @new_trc_fleet)
              INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
				  VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')
           END 
	
	END
	ELSE
	BEGIN


		IF RTRIM(LTRIM(APP_NAME())) = 'FIL'
		BEGIN
			UPDATE	tractorprofile
			   SET	trc_updatedby = @tmwuser,
					trc_updatedon = GETDATE()
			  FROM	inserted
			 WHERE	inserted.trc_number = tractorprofile.trc_number AND
					(ISNULL(tractorprofile.trc_updatedby, '') <> @tmwuser OR
					 ISNULL(tractorprofile.trc_updatedon, '19500101') <> GETDATE())
		END
	



	   -- PTS20988 MBR 02/23/04
           IF (SELECT UPPER(gi_string1) FROM generalinfo WHERE gi_name = 'MaptuitGeocode') = 'Y'
           BEGIN
              SELECT @trc_number = trc_number,
                     @trc_gal_in_tank = ISNULL(trc_gal_in_tank, 0),
                     @trc_tank_capacity = ISNULL(trc_tank_capacity, 0),
                     @trc_mpg = ISNULL(trc_mpg, 0)
                FROM inserted
              SET @trc_litre_in_tank = @trc_gal_in_tank/.264172951
              UPDATE m2unfuelpf 
                 SET ufvalue = @trc_litre_in_tank,
                     ufstamp = GETDATE()
               WHERE ufunit = @trc_number AND
                     ufkeyvalue = 'FUELLEVEL'
              SET @trc_litre_capacity = @trc_tank_capacity/.264172951
              UPDATE m2unfuelpf 
                 SET ufvalue = @trc_litre_capacity,
                     ufstamp = GETDATE()
               WHERE ufunit = @trc_number AND
                     ufkeyvalue = 'CAPACITY'
              SET @trc_mpl = @trc_mpg/2.35214584
              UPDATE m2unfuelpf 
                 SET ufvalue = @trc_mpl,
                     ufstamp = GETDATE()
               WHERE ufunit = @trc_number AND
                     ufkeyvalue = 'ECONOMY'
           END
 
	END
END



-- PTS22080 MBR 03/18/04
IF UPDATE(trc_driver) OR UPDATE(trc_fleet)
BEGIN
   IF (SELECT UPPER(gi_string1) FROM generalinfo WHERE gi_name = 'MaptuitAlert') = 'Y'
   BEGIN
      SELECT @trc_number = inserted.trc_number,
             @new_trc_driver = inserted.trc_driver,
             @old_trc_driver = deleted.trc_driver,
             @new_trc_fleet = isnull(inserted.trc_fleet,''),
             @old_trc_fleet  = isnull(deleted.trc_fleet,'')
        FROM inserted, deleted
       WHERE inserted.trc_number = deleted.trc_number
      if @new_trc_driver <> @old_trc_driver OR @new_trc_fleet <> @old_trc_fleet
      BEGIN
         SELECT @mpp_teamleader = isnull(mpp_teamleader,'')
           FROM manpowerprofile
          WHERE mpp_id = @new_trc_driver
         IF @mpp_teamleader is not null AND @mpp_teamleader <> '' AND @mpp_teamleader <> ' '
         BEGIN
            EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
            INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
				VALUES (@m2qhid, 'Unit_UnitID', 'HIL', @trc_number)
	    		INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
				VALUES (@m2qhid, 'Unit_DMUserID', 'HIL', @mpp_teamleader)
            INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
				VALUES (@m2qhid, 'Unit_FleetID', 'HIL', @new_trc_fleet)
            INSERT INTO m2msgqhdr VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')
         END 
      END
   END
END



-- 30236 JD Check if we need to create entries for activity table for single and team rates.
declare @ll_prk int
If @updatecount > 0 and @delcount = 0 -- insert 
BEGIN
	If exists (select * from generalinfo where gi_name = 'AutoAssignResourceToRates' and upper(gi_string2) ='TRC'  )
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
		Select @ll_prk,'TRC',trc_number , 'LGH','ACTV!','TRC'+trc_number+'ACTV!','N','BTH','19500101 00:00' from inserted
	END
END




--JLB PTS 43416
if @updatecount > 0 and @delcount > 0 and update(trc_dailyflag) --update and the dailyflag is getting set
begin
	update tractorprofile
	   set trc_dailyflagdate = convert(datetime,convert(varchar(2),(datepart(mm,getdate()))) + '/' + convert(varchar(2),(datepart(dd,getdate()))) + '/' + convert(varchar(4),datepart(yyyy,getdate())))
	  from inserted
	  where inserted.trc_number = tractorprofile.trc_number
end

--PTS 61188 JJF 20120621
--PTS71153 JJF 20130809 - add gi_string2
--PTS85269 JJF 20150105 - add gi_string3
SELECT	@DriverToTractorFleetSyncGI = gi_string1,
		@DriverToTractorGroupColumn = gi_string2,
		@DriverToTractorTractorUpdatesDriver = ISNULL(gi_string3, 'Y')
FROM	generalinfo
WHERE	gi_name = 'DriverToTractorFleetSync'

--PTS85269 JJF 20150105 - add gi_string3
--IF	@DriverToTractorFleetSyncGI = 'Y' BEGIN
--EO y por n  AQUI SE CAUSA UN PROBLEMA DONDE MANDA LLAMAR COMO LINKED SERVER A SI MISMO SERVIDOR
IF	@DriverToTractorFleetSyncGI = 'Y' AND @DriverToTractorTractorUpdatesDriver = 'Y' BEGIN
	IF	UPDATE(trc_driver) 
		OR	(	UPDATE(trc_fleet) AND @DriverToTractorGroupColumn = 'Fleet'	)
		OR	(	UPDATE(trc_teamleader) AND @DriverToTractorGroupColumn = 'TeamLeader'	) BEGIN

		IF EXISTS	(	SELECT	*
						FROM	inserted trc
								INNER JOIN manpowerprofile mpp with(nolock) on mpp.mpp_tractornumber = trc.trc_number --PTS71633 JJF/MCHAN 20130820 nolock
						WHERE	(	(	@DriverToTractorGroupColumn = 'Fleet' 
										AND trc.trc_fleet <> mpp.mpp_fleet
									)
									OR	(	@DriverToTractorGroupColumn = 'TeamLeader'
										AND trc.trc_teamleader <> mpp.mpp_teamleader
									)
								) AND mpp.mpp_id <> 'UNKNOWN'
								AND trc.trc_number <> 'UNKNOWN' --PTS84989
					) BEGIN
					
			IF @DriverToTractorGroupColumn = 'Fleet' BEGIN
				--print 'Tractor trigger updates manpowerprofile'

				UPDATE	manpowerprofile
				SET		mpp_fleet = trc.trc_fleet
				FROM	inserted trc
						INNER JOIN manpowerprofile mpp with(nolock) on mpp.mpp_tractornumber = trc.trc_number --PTS71633 JJF/MCHAN 20130820 nolock
				WHERE	trc.trc_fleet <> mpp.mpp_fleet
						AND mpp.mpp_id <> 'UNKNOWN'
						AND trc.trc_number <> 'UNKNOWN' --PTS84989
			END
			IF @DriverToTractorGroupColumn = 'TeamLeader' BEGIN
				UPDATE	manpowerprofile
				SET		mpp_teamleader = trc.trc_teamleader
				FROM	inserted trc
						INNER JOIN manpowerprofile mpp with(nolock) on mpp.mpp_tractornumber = trc.trc_number --PTS71633 JJF/MCHAN 20130820 nolock
				WHERE	trc.trc_teamleader <> mpp.mpp_teamleader
						AND mpp.mpp_id <> 'UNKNOWN'
						AND trc.trc_number <> 'UNKNOWN' --PTS84989
			END
		END
	END		
END





--IF EXISTS	(	SELECT	*
--				FROM	generalinfo
--				WHERE	gi_name = 'DriverToTractorFleetSync'
--						AND gi_string1 = 'Y'
--			) 
--			AND	(	UPDATE(trc_driver)
--					OR UPDATE(trc_fleet)
--				) BEGIN
--
--	IF EXISTS	(	SELECT	*
--					FROM	inserted trc
--							INNER JOIN manpowerprofile mpp on mpp.mpp_tractornumber = trc.trc_number
--					WHERE	trc.trc_fleet <> mpp.mpp_fleet
--							AND mpp.mpp_id <> 'UNKNOWN'
--				) BEGIN
--		IF UPDATE(trc_fleet)  BEGIN
--			UPDATE	manpowerprofile
--			SET		mpp_fleet = trc.trc_fleet
--			FROM	inserted trc
--					INNER JOIN manpowerprofile mpp on mpp.mpp_tractornumber = trc.trc_number
--			WHERE	trc.trc_fleet <> mpp.mpp_fleet
--					AND mpp.mpp_id <> 'UNKNOWN'
--		END
--	END 
--END
--END PTS71153 JJF 20130809 - add gi_string2


--PTS80644 JJF 20140829

SELECT	@TotalMailFleetToGroupsSyncGI = UPPER(gi_string1),
		@TotalMailGroupColumn = UPPER(ISNULL(gi_string2, 'Fleet')),
		@TotalMailIgnoreMissingCommUnit = UPPER(ISNULL(gi_string3, 'N'))
FROM	generalinfo
WHERE	gi_name = 'TotalMailFleetToGroupsSync'


SET @tm_sk_SyncNonMemberRelationship_flags = 0
IF @TotalMailIgnoreMissingCommUnit = 'Y' BEGIN
	SET @tm_sk_SyncNonMemberRelationship_flags = 1
END 

SELECT	@TotalMailTractorOnlyFleetSyncGI = UPPER(gi_string1)
FROM	generalinfo
WHERE	gi_name = 'TotalMailTractorOnlyFleetSync'


IF	@TotalMailFleetToGroupsSyncGI = 'Y' AND @TotalMailTractorOnlyFleetSyncGI = 'Y' AND @DriverToTractorFleetSyncGI = 'N' BEGIN
	SELECT @CursorNeeded = 1
END


--Cursor set up to iterate through inserted table
--Use for any other processing that must be done one row at a time


IF @CursorNeeded = 1 BEGIN

	DECLARE TractorProfileCursor CURSOR FAST_FORWARD FOR
		SELECT	trc.trc_number
		FROM	inserted trc
		WHERE	trc.trc_number <> 'UNKNOWN' --PTS84989

	OPEN	TractorProfileCursor

	FETCH NEXT FROM TractorProfileCursor
	INTO	@trc_number

	WHILE	@@FETCH_STATUS = 0 BEGIN
		SELECT	@sDispatchGroupName = ISNULL(LEFT(lbl.label_extrastring1, 30), ''),
				@sNonMemberGroupName = ISNULL(LEFT(lbl.label_extrastring3, 30), '')
		FROM	labelfile lbl
				INNER JOIN inserted trc on (	(@TotalMailGroupColumn = 'FLEET' AND trc.trc_fleet = lbl.abbr AND UPPER(lbl.labeldefinition) = 'FLEET')
												OR (@TotalMailGroupColumn = 'TEAMLEADER' AND trc.trc_teamleader = lbl.abbr AND UPPER(lbl.labeldefinition) = 'TEAMLEADER')
											)
				LEFT OUTER JOIN deleted trc_prior on (trc_prior.trc_number = trc.trc_number)
		WHERE	trc.trc_number = @trc_number

		SELECT	@sOldDispatchGroupName = ISNULL(LEFT(lbl.label_extrastring1, 30), ''),
				@sOldNonMemberGroupName = ISNULL(LEFT(lbl.label_extrastring3, 30), '')
		FROM	labelfile lbl
				INNER JOIN deleted trc on (	(@TotalMailGroupColumn = 'FLEET' AND trc.trc_fleet = lbl.abbr AND UPPER(lbl.labeldefinition) = 'FLEET')
												OR (@TotalMailGroupColumn = 'TEAMLEADER' AND trc.trc_teamleader = lbl.abbr AND UPPER(lbl.labeldefinition) = 'TEAMLEADER')
											)
		WHERE	trc.trc_number = @trc_number

		IF	(	(@TotalMailTractorOnlyFleetSyncGI = 'Y' )
				AND (	@trc_number <> 'UNKNOWN' )
				AND	(	@sDispatchGroupName	<> '' )
				AND	(	(	@TotalMailGroupColumn = 'FLEET' AND UPDATE(trc_fleet))
						 OR	(	@TotalMailGroupColumn = 'TEAMLEADER' AND UPDATE(trc_teamleader)	)
					)
			) BEGIN --Setting to sync to totalmail

			--print 'tractor trigger verified dispatch group'
					
			SELECT	@TotalMailConnectionPrefix = dbo.totalmail_connection_fn()

				--ensure group exists
				SELECT	@SQLDyn = 'EXEC	' + 
				@TotalMailConnectionPrefix + 'dbo.tm_CreateDispatchGroup ' + 
				'''' + @sDispatchGroupName + ''', ' +
				'''' + ''', ' +
				'0, ' +
				'0'
			EXEC (@SQLDyn)

			--print 'tractor trigger associates tractor with dispatch group'
		
			SELECT	@SQLDyn = 'EXEC	' + 
								@TotalMailConnectionPrefix + 'dbo.tm_sk_SyncDispatchRelationship ' + 
								'''' + @sDispatchGroupName + ''', ' +
								'''TRC'', ' +
								'''' + @trc_number + ''', ' +
								'0'
			EXEC (@SQLDyn)
		END


		IF	(@TotalMailTractorOnlyFleetSyncGI = 'Y' )
			AND @trc_number <> 'UNKNOWN' 
			AND	(	@sNonMemberGroupName	<> '' )
			AND	(	(@TotalMailGroupColumn = 'FLEET' AND UPDATE(trc_fleet))
					OR	(@TotalMailGroupColumn = 'TEAMLEADER' AND UPDATE(trc_teamleader))
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
		

	
		FETCH NEXT FROM TractorProfileCursor
		INTO	@trc_number
	END
	CLOSE TractorProfileCursor;
	DEALLOCATE TractorProfileCursor;
END
--END PTS80644 JJF 20140829
--END PTS 61188 JJF 20120621





-- RE - PTS #60818 BEGIN
IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'Manhattan_Interface' AND LEFT(gi_string1,1) = 'Y')
BEGIN
	INSERT INTO MANHATTAN_WorkQueue
		(mwq_type, trc_number, mwq_source)
		SELECT	'DRIVER', i.trc_number, 'IUT_TRACTOR_CHANGELOG' 
		  FROM	inserted i
		 WHERE	i.trc_number <> 'UNKNOWN'
		   AND	NOT EXISTS(SELECT * FROM MANHATTAN_WorkQueue mwq WHERE mwq.mwq_type = 'DRIVER' AND mwq.trc_number = i.trc_number)
		   
	IF UPDATE(trc_reload_status)
	BEGIN
		INSERT INTO expedite_audit
			(ord_hdrnumber, updated_by, activity, updated_dt, update_note, mov_number, lgh_number, join_to_table_name, key_value, tar_number)
			SELECT	ISNULL(l.ord_hdrnumber, 0),
					@tmwuser,
					'ReloadStatusChange',
					GETDATE(),
					'TRC: ' + i.trc_number + ' - ReloadStatus Changed. Previous: ' + ISNULL(d.trc_reload_status, 'UNK') + ' - New: ' + ISNULL(i.trc_reload_status, 'UNK'),
					ISNULL(l.mov_number, 0),
					ISNULL(l.lgh_number, 0), 
					'tractorprofile',
					i.trc_number,
					0
			  FROM	inserted i
						INNER JOIN deleted d ON d.trc_number = i.trc_number
						LEFT OUTER JOIN legheader l ON l.lgh_number = i.trc_avl_lgh
			 WHERE	ISNULL(i.trc_reload_status, 'UNK') <> ISNULL(d.trc_reload_status, 'UNK')			
	END
END
-- RE - PTS #60818 END





-- RE - PTS77738 - BEGIN
DECLARE	@InsertCount	INTEGER,
		@DeleteCount	INTEGER

SELECT	@InsertCount = COUNT(*) FROM inserted
SELECT	@DeleteCount = COUNT(*) FROM deleted

IF @InsertCount > 0 AND @DeleteCount = 0
BEGIN
	UPDATE	tractorprofile
	   SET	trc_optimizationdate = GETDATE()
	  FROM	inserted
	 WHERE	tractorprofile.trc_number = inserted.trc_number
END
ELSE IF @InsertCount > 0 AND @DeleteCount > 0
BEGIN
	If (UPDATE(trc_gps_date) OR UPDATE(trc_driver) OR UPDATE(trc_driver2) OR UPDATE(trc_division)) AND NOT UPDATE(trc_optimizationdate)
	BEGIN
		IF EXISTS(SELECT	*
					FROM	inserted i
								INNER JOIN deleted d ON d.trc_number = i.trc_number
				   WHERE	ISNULL(i.trc_gps_date, '19500101') <> ISNULL(d.trc_gps_date, '19500101') OR
							ISNULL(i.trc_driver, '') <> ISNULL(d.trc_driver, '')  OR
							ISNULL(i.trc_driver2, '') <> ISNULL(d.trc_driver2, '')  OR
							ISNULL(i.trc_division, '') <> ISNULL(d.trc_division, ''))
		BEGIN
				UPDATE	tractorprofile
				   SET	trc_optimizationdate = GETDATE()
				  FROM	inserted
				 WHERE	tractorprofile.trc_number = inserted.trc_number
		END
	END
END
-- RE - PTS77738 - END

--DMA PTS 84943 - added fuel card update queue
IF update(trc_status) and exists (select 1 from generalinfo where gi_name = 'ProcInteractiveDrvCardUpdates' and Left(gi_string2,1) = 'Y')
	begin
		
		DECLARE	@trc_status		VARCHAR(6),
			    @trc_nmbr       VARCHAR(8)
					
		SELECT @trc_status = trc_status, @trc_nmbr = trc_number FROM inserted 

		if @trc_status = 'OUT' 
			exec Interactive_Fuel_Update_sp 'TRC', @trc_nmbr, 0, 'TRCTERM'
	end
-- END PTS 84943
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tractorprofile_rowsec] ON [dbo].[tractorprofile]
FOR INSERT, UPDATE
AS
	-- PTS62831 JJF 20121001 - no longer needed
	
	--DECLARE @COLUMNS_UPDATED_BIT_MASK varbinary(500)
	--DECLARE @error int
	--DECLARE @message varchar(1024)

	--SELECT @COLUMNS_UPDATED_BIT_MASK = COLUMNS_UPDATED()
		
	--SELECT trc_number
	--INTO #NewValues
	--FROM inserted
		
	--exec RowSecUpdateRows_sp 'TractorProfile', @COLUMNS_UPDATED_BIT_MASK, @error out, @message out 
	
--Begin PTS 58081 AVANE 20110729, PTS 58411 AVANE 20110811
	
	declare @assetProfileLogging char(1)
	select @assetProfileLogging = ISNULL((SELECT TOP 1 gi_string1 from generalinfo (nolock) where gi_name = 'EnableAssetProfileLogging'), 'Y')
	
	--PTS 84589
	if NOT EXISTS (select top 1 * from inserted)
    return

	--apply to update only and if the gi setting EnableAssetProfileLogging <> 'N'
	--PTS83919 JJF (SB CRE) 20141104 - change to left joins of deleted table to accommodate INSERTs
	--if((select count(*) from deleted) > 0 AND @assetProfileLogging = 'Y')		
	if(@assetProfileLogging = 'Y')
	begin
		declare @currentTime datetime, @currentUser varchar(255), @res_type varchar(8), @lbl_category varchar(16)

		exec gettmwuser @currentUser output
		select @currentTime = GETDATE()
		select @res_type = 'Tractor'

		--PTS83919 JJF (SB CRE) 20141104 - change to left joins of deleted table to accommodate INSERTs
		if(update(trc_type1))
		begin
			select @lbl_category = 'TrcType1'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trc_number, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trc_type1, 'UNK'), 
				Case when d.trc_type1 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trc_type1), 'UNKNOWN') end,
				i.trc_type1,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trc_type1), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trc_number = i.trc_number
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trc_number = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trc_type1
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trc_type1 is not NULL 
				and Coalesce(d.trc_type1, '') <> i.trc_type1 
				and apl.res_id is null
		end

		if(update(trc_type2))
		begin
			select @lbl_category = 'TrcType2'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trc_number, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trc_type2, 'UNK'), 
				Case when d.trc_type2 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trc_type2), 'UNKNOWN') end,
				i.trc_type2,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trc_type2), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trc_number = i.trc_number
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trc_number = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trc_type2
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trc_type2 is not NULL 
				and Coalesce(d.trc_type2, '') <> i.trc_type2 
				and apl.res_id is null
		end

		if(update(trc_type3))
		begin
			select @lbl_category = 'TrcType3'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trc_number, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trc_type3, 'UNK'), 
				Case when d.trc_type3 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trc_type3), 'UNKNOWN') end,
				i.trc_type3,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trc_type3), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trc_number = i.trc_number
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trc_number = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trc_type3
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trc_type3 is not NULL 
				and Coalesce(d.trc_type3, '') <> i.trc_type3 
				and apl.res_id is null
		end

		if(update(trc_type4))
		begin
			select @lbl_category = 'TrcType4'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trc_number, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trc_type4, 'UNK'), 
				Case when d.trc_type4 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trc_type4), 'UNKNOWN') end,
				i.trc_type4,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trc_type4), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trc_number = i.trc_number
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trc_number = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trc_type4
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trc_type4 is not NULL 
				and Coalesce(d.trc_type4, '') <> i.trc_type4 
				and apl.res_id is null
		end

		if(update(trc_company))
		begin
			select @lbl_category = 'Company'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trc_number, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trc_company, 'UNK'), 
				Case when d.trc_company is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trc_company), 'UNKNOWN') end,
				i.trc_company,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trc_company), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trc_number = i.trc_number
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trc_number = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trc_company
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trc_company is not NULL 
				and Coalesce(d.trc_company, '') <> i.trc_company 
				and apl.res_id is null
		end

		if(update(trc_division))
		begin
			select @lbl_category = 'Division'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trc_number, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trc_division, 'UNK'), 
				Case when d.trc_division is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trc_division), 'UNKNOWN') end,
				i.trc_division,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trc_division), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trc_number = i.trc_number
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trc_number = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trc_division
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trc_division is not NULL 
				and Coalesce(d.trc_division, '') <> i.trc_division 
				and apl.res_id is null
		end

		if(update(trc_fleet))
		begin
			select @lbl_category = 'Fleet'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trc_number, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trc_fleet, 'UNK'), 
				Case when d.trc_fleet is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trc_fleet), 'UNKNOWN') end,
				i.trc_fleet,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trc_fleet), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trc_number = i.trc_number
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trc_number = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trc_fleet
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trc_fleet is not NULL 
				and Coalesce(d.trc_fleet, '') <> i.trc_fleet 
				and apl.res_id is null
		end

		if(update(trc_terminal))
		begin
			select @lbl_category = 'Terminal'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trc_number, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trc_terminal, 'UNK'), 
				Case when d.trc_terminal is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trc_terminal), 'UNKNOWN') end,
				i.trc_terminal,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trc_terminal), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trc_number = i.trc_number
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trc_number = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trc_terminal
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trc_terminal is not NULL 
				and Coalesce(d.trc_terminal, '') <> i.trc_terminal 
				and apl.res_id is null
		end
	end
--End PTS 58081 AVANE 20110729, PTS 58411 AVANE 20110811
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tractorprofile_setschedule]
ON [dbo].[tractorprofile]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
/**
 * 
 * NAME: 
 * dbo.iut_tractorprofile_setschedule
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
select d.trc_number from deleted d inner join inserted i on d.trc_number = i.trc_number
where 
(
d.trc_actg_type <> i.trc_actg_type OR
d.trc_company <> i.trc_company OR
d.trc_division <> i.trc_division OR
d.trc_terminal <> i.trc_terminal OR
d.trc_fleet <> i.trc_fleet OR
d.trc_type1 <> i.trc_type1 OR
d.trc_type2 <> i.trc_type2 OR
d.trc_type3 <> i.trc_type3 OR
d.trc_type4 <> i.trc_type4
)
and d.PayScheduleId is not null
)
	update t 
	set PayScheduleId = NULL
	from tractorprofile t
	inner join deleted d on t.trc_number = d.trc_number
	inner join inserted i on t.trc_number = i.trc_number
	where 
	(
	d.trc_actg_type <> i.trc_actg_type OR
	d.trc_company <> i.trc_company OR
	d.trc_division <> i.trc_division OR
	d.trc_terminal <> i.trc_terminal OR
	d.trc_fleet <> i.trc_fleet OR
	d.trc_type1 <> i.trc_type1 OR
	d.trc_type2 <> i.trc_type2 OR
	d.trc_type3 <> i.trc_type3 OR
	d.trc_type4 <> i.trc_type4
	)
	and d.PayScheduleId is not null

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ltl_straight_truck]
ON [dbo].[tractorprofile]  
AFTER Update
AS  
 IF Update(trc_require_drvtrl)
 BEGIN
  DECLARE @trc_id VARCHAR(8);
  DECLARE @drvtrl CHAR;
  DECLARE @LTLtype VARCHAR(6);
  DECLARE @count INT;

  SELECT @trc_id = trc_number, @drvtrl = trc_require_drvtrl from inserted

  SELECT @LTLtype = unit_type from asset_ltl_info where unit_id = @trc_id

  --SELECT @count = count(*) from asset_ltl_info where unit_id = @trc_id

  IF (@drvtrl = '5' AND @LTLtype <> 'STR')
   BEGIN
    delete from asset_ltl_info where unit_type = 'STR' and unit_id = @trc_id --Remove any existing duplicates that could cause primay key violation
    update asset_ltl_info set unit_type = 'STR' where unit_id = @trc_id --Modify the existing record.
   END
  IF (@drvtrl <> '5' AND @LTLtype = 'STR')
   BEGIN
    delete from asset_ltl_info where unit_type = 'TRC' and unit_id = @trc_id --Remove any existing duplicates that could cause primay key violation
    update asset_ltl_info set unit_type = 'TRC' where unit_id = @trc_id --Modify the existing record.
   END
 END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[NONULLSPOS] 
   ON  [dbo].[tractorprofile]
   AFTER insert
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   update tractorprofile set trc_gps_desc = 'INICIALIZANDO GPS' where trc_gps_desc is null 
   update tractorprofile set trc_gps_date =getdate() where trc_gps_date is null
      update tractorprofile set trc_gps_desc =  'SISTEMA NO ACTIVO' where trc_gps_desc = ''
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER  [dbo].[tg_actualiza_silt] ON [dbo].[tractorprofile]
After UPDATE
 As

Set Nocount on 

declare  @flota  numeric,
@i_fleet   varchar(6),
@proyecto varchar(15),
@division varchar(15),
@unidad  varchar(15),
@tipo_serv  varchar(15),
@depto numeric



Select @i_fleet  =  trc_fleet,	
          @unidad  = trc_number,
         @division  = trc_type4,
        @proyecto = trc_type3
From inserted


If  update(trc_fleet) 
begin

	Select @flota   = @i_fleet 
		/*
        Case @i_fleet 
        when '01'  then 11
		when '02'  then 9
		when '03'  then   16
		when '04' then  25
		when '05' then  7
		when '06' then  29
		when '07' then  22
		when '08' then  3
		when '09' then  24
		when '10' then  14
		when '11' then  24
		when '12' then  9
		when '13' then  23
		when '14' then  10
		when '15' then  14
		when '16' then 4
		when '17' then 12
		when '18' then 6
		when '19' then 15
		when '20' then  17
		when '21' then  37
		else 0
     
	end
*/ 
 
	Update tdrsilt.dbo.mtto_unidades   Set  id_flota = @flota  	
	where id_unidad  =  @unidad


	



	
end


If  update( trc_type3) 
begin

	Select @depto  =
		Case @proyecto
		when 'BAJ'  then 37
		when 'EUC'   then 34
		when 'FULM'  then   52
		when 'FULO' then  51
		when 'FULS' then  33
		when 'GAM'  then  55
		when 'KFD'  then  48
		when 'NOR'  then  61
		when 'OCC' then  50
		when 'P&G' then  58
		when 'PAC'  then  60
		when 'SAY' then  35
		when 'SUS' then  49
		when 'TOL' then  36
		when 'ABR' then  62
		when 'HED'  then 63
		when 'VEN' then 38
		when 'PRU' then 38
		when 'NTM' then 64
		when 'MTL' then 65
		when 'QRL' then  35
		when 'HYS'  then  52
		when 'ABI'  then  20
		when 'DHLX' then 71
		when 'SIG'	then 71
		else 0
	end

 
	Update  tdrsilt.dbo.mtto_unidades   Set  id_depto =@depto 	
	where id_unidad  =  @unidad
	
end



If  update( trc_type4) 
begin

	Select @tipo_serv  =
		Case @division
		when 'DED'  then 'C'
		when 'ESP'  then 'P'
		when 'FUL'  then 'F'
		when 'INT' then   'I'
		when 'SEN' then  'S'
		end
 
	Update tdrsilt.dbo.mtto_unidades   Set  tipo_serv = @tipo_serv
	where id_unidad  =  @unidad
	
end


GO
DISABLE TRIGGER [dbo].[tg_actualiza_silt] ON [dbo].[tractorprofile]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER  [dbo].[tg_actualiza_silt_insert] ON [dbo].[tractorprofile]
After INSERT
 As

Set Nocount on 

declare  @flota  numeric,
@i_fleet   varchar(6),
@proyecto varchar(15),
@division varchar(15),
@unidad  varchar(15),
@tipo_serv  varchar(15),
@depto numeric



Select @i_fleet  =  trc_fleet,	
          @unidad  = trc_number,
         @division  = trc_type4,
        @proyecto = trc_type3
From inserted


If  update(trc_fleet) 
begin

	Select @flota   = @i_fleet 
		/*
        Case @i_fleet 
        when '01'  then 11
		when '02'  then 9
		when '03'  then   16
		when '04' then  25
		when '05' then  7
		when '06' then  29
		when '07' then  22
		when '08' then  3
		when '09' then  24
		when '10' then  14
		when '11' then  24
		when '12' then  9
		when '13' then  23
		when '14' then  10
		when '15' then  14
		when '16' then 4
		when '17' then 12
		when '18' then 6
		when '19' then 15
		when '20' then  17
		when '21' then  37
		else 0
     
	end
*/ 
 
	Update tdrsilt.dbo.mtto_unidades   Set  id_flota = @flota  	
	where id_unidad  =  @unidad


	



	
end


If  update( trc_type3) 
begin

	Select @depto  =
		Case @proyecto
		when 'BAJ'  then 37
		when 'EUC'   then 34
		when 'FULM'  then   52
		when 'FULO' then  51
		when 'FULS' then  33
		when 'GAM'  then  55
		when 'KFD'  then  48
		when 'NOR'  then  61
		when 'OCC' then  50
		when 'P&G' then  58
		when 'PAC'  then  60
		when 'SAY' then  35
		when 'SUS' then  49
		when 'TOL' then  36
		when 'ABR' then  62
		when 'HED'  then 63
		when 'VEN' then 38
		when 'PRU' then 38
		when 'NTM' then 64
		when 'MTL' then 65
		when 'QRL' then  35
		when 'HYS'  then  52
		when 'ABI'  then  20
		when 'DHLX' then 71
		when 'SIG'	then 71
		else 0
	end

 
	Update  tdrsilt.dbo.mtto_unidades   Set  id_depto =@depto 	
	where id_unidad  =  @unidad
	
end



If  update( trc_type4) 
begin

	Select @tipo_serv  =
		Case @division
		when 'DED'  then 'C'
		when 'ESP'  then 'P'
		when 'FUL'  then 'F'
		when 'INT' then   'I'
		when 'SEN' then  'S'
		end
 
	Update tdrsilt.dbo.mtto_unidades   Set  tipo_serv = @tipo_serv
	where id_unidad  =  @unidad
	
end


GO
DISABLE TRIGGER [dbo].[tg_actualiza_silt_insert] ON [dbo].[tractorprofile]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[ut_tractorprofile_CopyGPSToLH] ON [dbo].[tractorprofile]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE
	  @gps		varchar(255)
--	, @pln_lgh	int
--	, @avl_lgh	int
	, @trc		varchar(8)
	, @optn_on  CHAR(1)
	, @gpsDate 	varchar(30)

SELECT @optn_on = gi_string1
FROM generalinfo 
WHERE gi_name = 'CopyGPSToLH'

IF (UPDATE (trc_gps_date) OR UPDATE (trc_gps_desc)) AND @optn_on = 'Y'
BEGIN
	BEGIN
		SET @trc = ''
		WHILE (SELECT count(*) FROM inserted WHERE trc_number > @trc) > 0
		BEGIN
			SELECT @trc = MIN(trc_number) FROM inserted WHERE trc_number > @trc
		
			SELECT	  @gps = trc_gps_desc
					, @gpsDate = convert(varchar(5), trc_gps_date, 1) + ' ' + convert(varchar(5), trc_gps_date, 8)
--					, @pln_lgh = trc_avl_lgh -- avl is planned and pln is avl!
--					, @avl_lgh = trc_pln_lgh
			FROM 	INSERTED
			WHERE	trc_number = @trc

			UPDATE	legheader_active
			   SET	lgh_extrainfo1 = @gps,
					lgh_extrainfo2 = @gpsDate
			 WHERE	lgh_tractor = @trc
			
--			IF @pln_lgh > 0
--				UPDATE 	legheader_active 
--				SET		lgh_extrainfo1 = @gps
--						, lgh_extrainfo2 = @gpsDate
--				WHERE	lgh_number = @pln_lgh
--			IF @avl_lgh > 0  
--				UPDATE 	legheader_active 
--				SET		lgh_extrainfo1 = @gps
--						, lgh_extrainfo2 = @gpsDate
--				WHERE	lgh_number = @avl_lgh
		END	
	END
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[ut_tractorprofile_ownerHistoryLog] ON [dbo].[tractorprofile] FOR UPDATE
AS

SET NOCOUNT ON

DECLARE @tmwuser VARCHAR(255)
EXEC gettmwuser @tmwuser OUTPUT

DECLARE @previous_owner VARCHAR(20)
DECLARE @new_owner VARCHAR(20)
DECLARE @trc_number VARCHAR(13)

IF UPDATE(trc_owner)
BEGIN
	SELECT @previous_owner = trc_owner, @trc_number = trc_number FROM deleted
	SELECT @new_owner = trc_owner FROM inserted

	INSERT INTO TractorOwnerHistoryLog (trc_id, previous_owner, new_owner, change_user, change_date)
	VALUES (@trc_number, @previous_owner, @new_owner, @tmwuser, GETDATE())
END
GO
ALTER TABLE [dbo].[tractorprofile] ADD CONSTRAINT [trc_ckmcommtype] CHECK (([dbo].[CheckLabel]([trc_mcommType],'MCommSystem',(1))=(1)))
GO
ALTER TABLE [dbo].[tractorprofile] ADD CONSTRAINT [pk_trc_number] PRIMARY KEY CLUSTERED ([trc_number]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tractorprofile_INS_TIMESTAMP] ON [dbo].[tractorprofile] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Tractorprofile_timestamp] ON [dbo].[tractorprofile] ([timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_tp_driver] ON [dbo].[tractorprofile] ([trc_driver]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tractor_trcnumber_trcretiredate] ON [dbo].[tractorprofile] ([trc_number], [trc_retiredate]) INCLUDE ([trc_driver], [trc_driver2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_trc_owner] ON [dbo].[tractorprofile] ([trc_owner]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_trcpro_retdate_status] ON [dbo].[tractorprofile] ([trc_retiredate], [trc_status]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tractorprofile] TO [public]
GO
GRANT INSERT ON  [dbo].[tractorprofile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tractorprofile] TO [public]
GO
GRANT SELECT ON  [dbo].[tractorprofile] TO [public]
GO
GRANT UPDATE ON  [dbo].[tractorprofile] TO [public]
GO
