CREATE TABLE [dbo].[trailerprofile]
(
[trl_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trl_owner] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__trailerpr__trl_o__20F7B6A5] DEFAULT ('UNKNOWN'),
[trl_make] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_model] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_currenthub] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__21EBDADE] DEFAULT (0),
[trl_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_t__22DFFF17] DEFAULT ('UNK'),
[trl_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_t__23D42350] DEFAULT ('UNK'),
[trl_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_t__24C84789] DEFAULT ('UNK'),
[trl_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_t__25BC6BC2] DEFAULT ('UNK'),
[trl_year] [int] NULL,
[trl_startdate] [datetime] NULL,
[trl_retiredate] [datetime] NULL,
[trl_mpg] [float] NULL CONSTRAINT [DF__trailerpr__trl_m__26B08FFB] DEFAULT (0),
[trl_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__27A4B434] DEFAULT ('UNK'),
[trl_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_f__2898D86D] DEFAULT ('UNK'),
[trl_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_d__298CFCA6] DEFAULT ('UNK'),
[trl_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_t__2A8120DF] DEFAULT ('UNK'),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__cmp_i__2B754518] DEFAULT ('UNKNOWN'),
[cty_code] [int] NULL CONSTRAINT [DF__trailerpr__cty_c__35F2D38B] DEFAULT (0),
[trl_ilt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_i__2C696951] DEFAULT ('N'),
[trl_mtwgt] [int] NULL CONSTRAINT [DF__trailerpr__trl_m__2D5D8D8A] DEFAULT (0),
[trl_grosswgt] [int] NULL CONSTRAINT [DF__trailerpr__trl_g__2E51B1C3] DEFAULT (0),
[trl_axles] [smallint] NULL CONSTRAINT [DF__trailerpr__trl_a__2F45D5FC] DEFAULT (0),
[trl_ht] [float] NULL CONSTRAINT [DF__trailerpr__trl_h__3039FA35] DEFAULT (0),
[trl_len] [float] NULL CONSTRAINT [DF__trailerpr__trl_l__312E1E6E] DEFAULT (0),
[trl_wdth] [float] NULL CONSTRAINT [DF__trailerpr__trl_w__322242A7] DEFAULT (0),
[trl_licstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_licnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_s__331666E0] DEFAULT ('AVL'),
[trl_serial] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_dateacquired] [datetime] NULL,
[trl_origcost] [float] NULL CONSTRAINT [DF__trailerpr__trl_o__340A8B19] DEFAULT (0),
[trl_opercostmile] [float] NULL CONSTRAINT [DF__trailerpr__trl_o__34FEAF52] DEFAULT (0),
[trl_sch_date] [datetime] NULL,
[trl_sch_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_sch_city] [int] NULL CONSTRAINT [DF__trailerpr__trl_s__36E6F7C4] DEFAULT (0),
[trl_sch_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_avail_date] [datetime] NULL CONSTRAINT [DF__trailerpr__trl_a__37DB1BFD] DEFAULT (getdate()),
[trl_avail_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_a__38CF4036] DEFAULT ('UNKNOWN'),
[trl_avail_city] [int] NULL CONSTRAINT [DF__trailerpr__trl_a__39C3646F] DEFAULT (0),
[trl_fix_record] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_last_stop] [int] NULL,
[trl_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trl_cur_mileage] [int] NULL,
[trl_bmp_pathname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[trl_actg_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_a__3AB788A8] DEFAULT ('N'),
[trl_ilt_scac] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_u__64ADC274] DEFAULT (suser_sname()),
[trl_updateon] [datetime] NULL CONSTRAINT [DF__trailerpr__trl_u__65A1E6AD] DEFAULT (getdate()),
[trl_tareweight] [float] NULL CONSTRAINT [DF__trailerpr__trl_t__3BABACE1] DEFAULT (0),
[trl_kp_to_axle1] [float] NULL CONSTRAINT [DF__trailerpr__trl_k__62C57A02] DEFAULT (0),
[trl_axle1_to_axle2] [float] NULL CONSTRAINT [DF__trailerpr__trl_a__3D93F553] DEFAULT (0),
[trl_axle2_to_axle3] [float] NULL CONSTRAINT [DF__trailerpr__trl_a__3E88198C] DEFAULT (0),
[trl_axle3_to_axle4] [float] NULL CONSTRAINT [DF__trailerpr__trl_a__3F7C3DC5] DEFAULT (0),
[trl_comprt1_size_wet] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__4535171B] DEFAULT (0),
[trl_comprt2_size_wet] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__46293B54] DEFAULT (0),
[trl_comprt3_size_wet] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__471D5F8D] DEFAULT (0),
[trl_comprt4_size_wet] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__481183C6] DEFAULT (0),
[trl_comprt5_size_wet] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__4905A7FF] DEFAULT (0),
[trl_comprt6_size_wet] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__49F9CC38] DEFAULT (0),
[trl_comprt1_uom_wet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__4AEDF071] DEFAULT ('UNK'),
[trl_comprt2_uom_wet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__4BE214AA] DEFAULT ('UNK'),
[trl_comprt3_uom_wet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__4CD638E3] DEFAULT ('UNK'),
[trl_comprt4_uom_wet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__4DCA5D1C] DEFAULT ('UNK'),
[trl_comprt5_uom_wet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__4EBE8155] DEFAULT ('UNK'),
[trl_comprt6_uom_wet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__4FB2A58E] DEFAULT ('UNK'),
[trl_comprt1_bulkhead] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5C187C73] DEFAULT ('SINGLE'),
[trl_comprt2_bulkhead] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5D0CA0AC] DEFAULT ('SINGLE'),
[trl_comprt3_bulkhead] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5E00C4E5] DEFAULT ('SINGLE'),
[trl_comprt4_bulkhead] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5EF4E91E] DEFAULT ('SINGLE'),
[trl_comprt5_bulkhead] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5FE90D57] DEFAULT ('SINGLE'),
[trl_tareweight_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_t__3C9FD11A] DEFAULT ('UNK'),
[trl_kp_to_axle1_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_k__63B99E3B] DEFAULT ('UNK'),
[trl_axle1_to_axle2_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_a__41648637] DEFAULT ('UNK'),
[trl_axle2_to_axle3_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_a__4258AA70] DEFAULT ('UNK'),
[trl_axle3_to_axle4_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_a__434CCEA9] DEFAULT ('UNK'),
[trl_createdate] [datetime] NULL CONSTRAINT [DF__trailerpr__trl_c__66960AE6] DEFAULT (getdate()),
[trl_pupid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_p__78B4BB21] DEFAULT ('UNKNOWN'),
[trl_axle4_to_axle5] [float] NULL CONSTRAINT [DF__trailerpr__trl_a__407061FE] DEFAULT (0),
[trl_axle4_to_axle5_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_a__4440F2E2] DEFAULT ('UNK'),
[trl_lastaxle_to_rear] [float] NULL CONSTRAINT [DF__trailerpr__trl_l__678A2F1F] DEFAULT (0),
[trl_lastaxle_to_rear_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_l__687E5358] DEFAULT ('UNK'),
[trl_nose_to_kp] [float] NULL CONSTRAINT [DF__trailerpr__trl_n__60DD3190] DEFAULT (0),
[trl_nose_to_kp_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_n__61D155C9] DEFAULT ('UNK'),
[trl_total_no_of_compartments] [int] NULL CONSTRAINT [DF__trailerpr__trl_t__69727791] DEFAULT (0),
[trl_total_trailer_size_wet] [float] NULL CONSTRAINT [DF__trailerpr__trl_t__6A669BCA] DEFAULT (0),
[trl_uom_wet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_u__6B5AC003] DEFAULT ('UNK'),
[trl_total_trailer_size_dry] [float] NULL CONSTRAINT [DF__trailerpr__trl_t__6C4EE43C] DEFAULT (0),
[trl_uom_dry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_u__6D430875] DEFAULT ('UNK'),
[trl_comprt1_size_dry] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__50A6C9C7] DEFAULT (0),
[trl_comprt2_size_dry] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__519AEE00] DEFAULT (0),
[trl_comprt3_size_dry] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__528F1239] DEFAULT (0),
[trl_comprt4_size_dry] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__53833672] DEFAULT (0),
[trl_comprt5_size_dry] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__54775AAB] DEFAULT (0),
[trl_comprt6_size_dry] [int] NULL CONSTRAINT [DF__trailerpr__trl_c__556B7EE4] DEFAULT (0),
[trl_comprt1_uom_dry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__565FA31D] DEFAULT ('UNK'),
[trl_comprt2_uom_dry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5753C756] DEFAULT ('UNK'),
[trl_comprt3_uom_dry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5847EB8F] DEFAULT ('UNK'),
[trl_comprt4_uom_dry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__593C0FC8] DEFAULT ('UNK'),
[trl_comprt5_uom_dry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5A303401] DEFAULT ('UNK'),
[trl_comprt6_uom_dry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_c__5B24583A] DEFAULT ('UNK'),
[trl_bulkhead_comprt1_thick] [float] NULL CONSTRAINT [DF__trailerpr__trl_b__6E372CAE] DEFAULT (0),
[trl_bulkhead_comprt2_thick] [float] NULL CONSTRAINT [DF__trailerpr__trl_b__6F2B50E7] DEFAULT (0),
[trl_bulkhead_comprt3_thick] [float] NULL CONSTRAINT [DF__trailerpr__trl_b__701F7520] DEFAULT (0),
[trl_bulkhead_comprt4_thick] [float] NULL CONSTRAINT [DF__trailerpr__trl_b__71139959] DEFAULT (0),
[trl_bulkhead_comprt5_thick] [float] NULL CONSTRAINT [DF__trailerpr__trl_b__7207BD92] DEFAULT (0),
[trl_bulkhead_comprt1_thick_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_b__72FBE1CB] DEFAULT ('UNK'),
[trl_bulkhead_comprt2_thick_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_b__73F00604] DEFAULT ('UNK'),
[trl_bulkhead_comprt3_thick_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_b__74E42A3D] DEFAULT ('UNK'),
[trl_bulkhead_comprt4_thick_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_b__75D84E76] DEFAULT ('UNK'),
[trl_bulkhead_comprt5_thick_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_b__76CC72AF] DEFAULT ('UNK'),
[trl_quickentry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_q__77C096E8] DEFAULT ('N'),
[trl_wash_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_manualupdate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__trailerpr__trl_m__79A8DF5A] DEFAULT ('N'),
[trl_exp1_date] [datetime] NULL,
[trl_exp2_date] [datetime] NULL,
[trl_last_cmd] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_last_cmd_ord] [int] NULL,
[trl_last_cmd_date] [datetime] NULL,
[trl_palletcount] [int] NULL,
[trl_customer_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_billto_parent] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_booked_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_next_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_next_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_next_city] [int] NULL,
[trl_next_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_next_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_next_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_next_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_next_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_prior_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_prior_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_prior_city] [int] NULL,
[trl_prior_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_prior_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_prior_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_prior_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_prior_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_accessorylist] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_newused] [int] NOT NULL CONSTRAINT [df_trl_newused] DEFAULT (1),
[trl_gp_class] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_trl_gp_class] DEFAULT ('TRAILER'),
[trl_worksheet_comment1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_worksheet_comment2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_loading_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_axlgrp1_tarewgt] [float] NULL,
[trl_axlgrp1_grosswgt] [float] NULL,
[trl_axlgrp2_tarewgt] [float] NULL,
[trl_axlgrp2_grosswgt] [float] NULL,
[trl_exp1_enddate] [datetime] NULL,
[trl_exp2_enddate] [datetime] NULL,
[trl_gps_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_gps_date] [datetime] NULL,
[trl_gps_latitude] [int] NULL,
[trl_gps_longitude] [int] NULL,
[trl_gps_odometer] [int] NULL,
[trl_lifetimemileage] [decimal] (12, 1) NULL,
[trl_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_height] [float] NULL,
[trl_width] [float] NULL,
[trl_liccountry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_aceid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_aceidtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_useGeofencing] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_prior_cmp_othertype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_next_cmp_othertype1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_equipmenttype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_equipmenttype] DEFAULT ('TRAILER'),
[trl_prefix] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_dwelltime] [decimal] (9, 1) NULL,
[rowsec_rsrv_id] [int] NULL,
[trl_capacity_wgt] [decimal] (12, 4) NULL,
[trl_capacity_ldm] [decimal] (10, 2) NULL,
[trl_mobilecommaccount] [int] NULL,
[trl_app_eqcodes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_unassigned_reasoncode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_unassigned_comments] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_gps_heading] [float] NULL,
[trl_gps_speed] [int] NULL,
[trl_validitychks] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_cmpt1_temp] [float] NULL,
[trl_cmpt2_temp] [float] NULL,
[trl_cmpt3_temp] [float] NULL,
[trl_cmpt4_temp] [float] NULL,
[trl_cmpt5_temp] [float] NULL,
[trl_cmpt1_setpoint] [float] NULL,
[trl_cmpt2_setpoint] [float] NULL,
[trl_cmpt3_setpoint] [float] NULL,
[trl_cmpt4_setpoint] [float] NULL,
[trl_cmpt5_setpoint] [float] NULL,
[trl_dischargetemp] [float] NULL,
[trl_ambienttemp] [float] NULL,
[trl_alarmstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_cmpt1_desired_setpoint] [float] NULL,
[trl_cmpt2_desired_setpoint] [float] NULL,
[trl_cmpt3_desired_setpoint] [float] NULL,
[trl_cmpt4_desired_setpoint] [float] NULL,
[trl_cmpt5_desired_setpoint] [float] NULL,
[trl_desired_setpoints_setby] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_reeferpower] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_mcommID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_mcommType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_reeferhist1] [int] NULL,
[trl_reeferhist2] [int] NULL,
[trl_iso_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_saldoedenred] [float] NULL,
[PayScheduleId] [int] NULL,
[trl_use_rfid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_rfid_tag] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginDestinationOption] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_ams_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__trailerpr__INS_T__7D835388] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_trailerprofile] ON [dbo].[trailerprofile] 
FOR DELETE 
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
 if exists 
  ( select * from event, deleted
     where deleted.trl_number = event.evt_trailer1
        or deleted.trl_number = event.evt_trailer2 ) 
   begin
-- Sybase Syntax
--   raiserror 99999 'Cannot delete trailer: Assigned to trips'
-- MSS Syntax
     raiserror('Cannot delete trailer: Assigned to trips',16,1)
     rollback transaction
   end
Else
Begin
    -- PTS 38486
	declare @trl_id varchar(8)
	select @trl_id = trl_number from deleted

	delete from contact_profile where con_id = @trl_id and con_asgn_type = 'TRAILER'

	delete from expiration where exp_id = @trl_id and exp_idtype = 'TRL' --PTS 39866
End

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_trailer_changelog]
ON [dbo].[trailerprofile]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE	@updatecount	INTEGER,
		@delcount		INTEGER

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--PTS 59329 JJF 20111004
--select ISNULL(@tmwuser, '')
--END PTS 59329 JJF 20111004

SELECT @updatecount = COUNT(*) FROM inserted
SELECT @delcount = COUNT(*) FROM deleted

IF (@updatecount > 0 AND NOT UPDATE(trl_updatedby) AND NOT UPDATE(trl_updateon)) OR
	(@updatecount > 0 AND @delcount = 0)
BEGIN
	IF @delcount = 0
	BEGIN
		UPDATE	trailerprofile
		   SET	trl_updatedby = isnull (SUSER_NAME(), ''),
				trl_updateon = GETDATE()
		  FROM	inserted
		 WHERE	inserted.trl_number = trailerprofile.trl_number AND
				(ISNULL(trailerprofile.trl_updatedby, '') <> @tmwuser OR
-- PTS 26501 -- BL (start)
				 Trailerprofile.trl_updateon is NULL)
--				 ISNULL(Trailerprofile.trl_updateon, '19500101') <> GETDATE())
-- PTS 26501 -- BL (end)
	END
	ELSE
	BEGIN
		IF RTRIM(LTRIM(APP_NAME())) = 'FIL'
		BEGIN
			UPDATE	trailerprofile
			   SET	trl_updatedby = isnull (SUSER_NAME(), ''),
					trl_updateon = GETDATE()
			  FROM	inserted
			 WHERE	inserted.trl_number = trailerprofile.trl_number AND
					(ISNULL(trailerprofile.trl_updatedby, '') <> @tmwuser OR
					 ISNULL(Trailerprofile.trl_updateon, '19500101') <> GETDATE())
		END
	END
END

-- 30236 JD Check if we need to create entries for activity table for single and team rates.
declare @ll_prk int
If @updatecount > 0 and @delcount = 0 -- insert 
BEGIN
	If exists (select * from generalinfo where gi_name = 'AutoAssignResourceToRates' and upper(gi_string3) ='TRL'  )
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
		Select @ll_prk,'TRL',trl_id , 'LGH','ACTV!','TRL'+trl_id+'ACTV!','N','BTH','19500101 00:00' from inserted
	END
END

-- PTS 65506 Trailer Unassign reason code changes , it will add data into table 

If @updatecount > 0 
BEGIN
	If UPDATE(trl_unassigned_reasoncode) 
	BEGIN
		INSERT INTO trailer_unassign_reasonlog
		( trl_number,
		  trl_unassigned_precode,
		  trl_unassigned_curcode,
		  trl_unassigned_comments,
		  updated_date,
		  last_updated_by	
		 )
		SELECT 
			i.trl_number,
			d.trl_unassigned_reasoncode,
			i.trl_unassigned_reasoncode,
			i.trl_unassigned_comments, 
			GETDATE(), 
			@tmwuser
		FROM inserted i
		LEFT OUTER JOIN deleted d on d.trl_number = i.trl_number
	END
END
	
--DMA PTS 84943 - added fuel card update queue
IF update(trl_status) and exists (select 1 from generalinfo where gi_name = 'ProcInteractiveDrvCardUpdates' and Left(gi_string3,1) = 'Y')
	begin
		
		DECLARE	@trl_status		VARCHAR(6),
			    @trl_nmbr       VARCHAR(8)
					
		SELECT @trl_status = i.TRL_status, @trl_nmbr = i.trl_number FROM inserted i
			
		if @trl_status = 'OUT' 
			exec Interactive_Fuel_Update_sp 'TRL', @trl_nmbr, 0, 'TRLTERM'
	end
-- END PTS 84943

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_trailerprofile_rowsec] ON [dbo].[trailerprofile]
FOR INSERT, UPDATE
AS
	-- PTS62831 JJF 20121001 - no longer needed
	
	--DECLARE @COLUMNS_UPDATED_BIT_MASK varbinary(500)
	--DECLARE @error int
	--DECLARE @message varchar(1024)
	
	--SELECT @COLUMNS_UPDATED_BIT_MASK = COLUMNS_UPDATED()
	
	--SELECT trl_id
	--INTO #NewValues
	--FROM inserted
	
	--exec RowSecUpdateRows_sp 'trailerprofile', @COLUMNS_UPDATED_BIT_MASK, @error out, @message out 
	
--Begin PTS 58081 AVANE 20110729, PTS 58081 AVANE 20110811
	
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
		select @res_type = 'Trailer'

		--PTS83919 JJF (SB CRE) 20141104 - change to left joins of deleted table to accommodate INSERTs
		if(update(trl_type1))
		begin
			select @lbl_category = 'TrlType1'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trl_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trl_type1, 'UNK'), 
				Case when d.trl_type1 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trl_type1), 'UNKNOWN') end,
				i.trl_type1,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trl_type1), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trl_id = i.trl_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trl_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trl_type1
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trl_type1 is not NULL 
				and Coalesce(d.trl_type1, '') <> i.trl_type1 
				and apl.res_id is null
		end

		if(update(trl_type2))
		begin
			select @lbl_category = 'TrlType2'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trl_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trl_type2, 'UNK'), 
				Case when d.trl_type2 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trl_type2), 'UNKNOWN') end,
				i.trl_type2,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trl_type2), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trl_id = i.trl_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trl_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trl_type2
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trl_type2 is not NULL 
				and Coalesce(d.trl_type2, '') <> i.trl_type2 
				and apl.res_id is null
		end

		if(update(trl_type3))
		begin
			select @lbl_category = 'TrlType3'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trl_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trl_type3, 'UNK'), 
				Case when d.trl_type3 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trl_type3), 'UNKNOWN') end,
				i.trl_type3,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trl_type3), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trl_id = i.trl_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trl_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trl_type3
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trl_type3 is not NULL 
				and Coalesce(d.trl_type3, '') <> i.trl_type3
				and apl.res_id is null
		end

		if(update(trl_type4))
		begin
			select @lbl_category = 'TrlType4'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trl_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trl_type4, 'UNK'), 
				Case when d.trl_type4 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trl_type4), 'UNKNOWN') end,
				i.trl_type4,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trl_type4), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trl_id = i.trl_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trl_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trl_type4
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trl_type4 is not NULL 
				and Coalesce(d.trl_type4, '') <> i.trl_type4
				and apl.res_id is null
		end

		if(update(trl_company))
		begin
			select @lbl_category = 'Company'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trl_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trl_company, 'UNK'), 
				Case when d.trl_company is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trl_company), 'UNKNOWN') end,
				i.trl_company,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trl_company), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trl_id = i.trl_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trl_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trl_company
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trl_company is not NULL 
				and Coalesce(d.trl_company, '') <> i.trl_company
				and apl.res_id is null
		end

		if(update(trl_division))
		begin
			select @lbl_category = 'Division'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trl_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trl_division, 'UNK'), 
				Case when d.trl_division is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trl_division), 'UNKNOWN') end,
				i.trl_division,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trl_division), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trl_id = i.trl_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trl_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trl_division
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trl_division is not NULL 
				and Coalesce(d.trl_division, '') <> i.trl_division
				and apl.res_id is null
		end

		if(update(trl_fleet))
		begin
			select @lbl_category = 'Fleet'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trl_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trl_fleet, 'UNK'), 
				Case when d.trl_fleet is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trl_fleet), 'UNKNOWN') end,
				i.trl_fleet,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trl_fleet), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trl_id = i.trl_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trl_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trl_fleet
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trl_fleet is not NULL 
				and Coalesce(d.trl_fleet, '') <> i.trl_fleet
				and apl.res_id is null
		end

		if(update(trl_terminal))
		begin
			select @lbl_category = 'Terminal'
			insert into AssetProfileLog
				(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
			select i.trl_id, 
				@res_type, 
				@lbl_category, 
				ISNULL(d.trl_terminal, 'UNK'), 
				Case when d.trl_terminal is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.trl_terminal), 'UNKNOWN') end,
				i.trl_terminal,
				ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.trl_terminal), 'UNKNOWN'),
				@currentTime, 
				@currentTime, 
				@currentUser, 
				@currentTime, 
				'N', 
				@currentTime
			from inserted i 
				LEFT JOIN deleted d on d.trl_id = i.trl_id
				LEFT JOIN AssetProfileLog apl (nolock)  on i.trl_id = apl.res_id
					and apl.lbl_category = @lbl_category
					and apl.lbl_value = i.trl_terminal
					and apl.appliedon is NULL
					and apl.appliedbysqljob = 'I' 
			where i.trl_terminal is not NULL 
				and Coalesce(d.trl_terminal, '') <> i.trl_terminal
				and apl.res_id is null
		end
	end
--End PTS 58081 AVANE 20110729, PTS 58411 AVANE 20110811
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_trailerprofile_setschedule]
ON [dbo].[trailerprofile]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
/**
 * 
 * NAME: 
 * dbo.iut_trailerprofile_setschedule
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
select d.trl_id from deleted d inner join inserted i on d.trl_id = i.trl_id
where 
(
d.trl_actg_type <> i.trl_actg_type OR
d.trl_company <> i.trl_company OR
d.trl_division <> i.trl_division OR
d.trl_terminal <> i.trl_terminal OR
d.trl_fleet <> i.trl_fleet OR
d.trl_type1 <> i.trl_type1 OR
d.trl_type2 <> i.trl_type2 OR
d.trl_type3 <> i.trl_type3 OR
d.trl_type4 <> i.trl_type4
)
and d.PayScheduleId is not null
)
      update t 
      set PayScheduleId = NULL
      from trailerprofile t 
      inner join deleted d on t.trl_id = d.trl_id
	  inner join inserted i on t.trl_id = i.trl_id
      where 
      (
      d.trl_actg_type <> i.trl_actg_type OR
      d.trl_company <> i.trl_company OR
      d.trl_division <> i.trl_division OR
      d.trl_terminal <> i.trl_terminal OR
      d.trl_fleet <> i.trl_fleet OR
      d.trl_type1 <> i.trl_type1 OR
      d.trl_type2 <> i.trl_type2 OR
      d.trl_type3 <> i.trl_type3 OR
      d.trl_type4 <> i.trl_type4
      )
      and d.PayScheduleId is not null

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--DROP TRIGGER tg_tr_actualiza_silt

CREATE TRIGGER  [dbo].[tg_tr_actualiza_silt] ON [dbo].[trailerprofile]
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



Select @i_fleet  =  trl_fleet,	
          @unidad  = trl_number,
         @division  = trl_type4,
        @proyecto = trl_type3
From inserted


If  update(trl_fleet) 
begin

	Select @flota   = @i_fleet
/*
		Case @i_fleet 
		when '01'  then 11
		when '02'  then 18
		when '03'  then   16
		when '04' then  25
		when '05' then  7
		when '06' then  29
		when '07' then  22
		when '08' then  3
		when '09' then  24
		when '10' then  0
		when '11' then  14
		when '12' then  9
		when '13' then  23
		when '14' then  10
		when '15' then  14
		when '16' then 4
		when '17' then 12
		when '18' then 6
		when '19' then 15
		when '20' then  17
		when '21' then 37
		else 0

	end
*/
 
	Update tdrsilt.dbo.mtto_unidades   Set  id_flota = @flota  	
	where id_unidad  =  @unidad
	
end


If  update( trl_type3) 
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
		when 'HER'  then 63
		when 'VEN' then 38
		when 'NTM' then 64
		when 'MTL' then 65
		when 'QRL' then  35
		when 'HYS'  then  52
		when 'ABI'  then  20
		when 'DHLX'  then  71
		when 'LIVER' then  33
		else 0
	end

 
	Update  tdrsilt.dbo.mtto_unidades   Set  id_depto =@depto 	
	where id_unidad  =  @unidad
	
end



If  update( trl_type4) 
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
DISABLE TRIGGER [dbo].[tg_tr_actualiza_silt] ON [dbo].[trailerprofile]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--DROP TRIGGER tg_tr_actualiza_silt

CREATE TRIGGER  [dbo].[tg_tr_actualiza_silt_insert] ON [dbo].[trailerprofile]
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



Select @i_fleet  =  trl_fleet,	
          @unidad  = trl_number,
         @division  = trl_type4,
        @proyecto = trl_type3
From inserted


If  update(trl_fleet) 
begin

	Select @flota   = @i_fleet
/*
		Case @i_fleet 
		when '01'  then 11
		when '02'  then 18
		when '03'  then   16
		when '04' then  25
		when '05' then  7
		when '06' then  29
		when '07' then  22
		when '08' then  3
		when '09' then  24
		when '10' then  0
		when '11' then  14
		when '12' then  9
		when '13' then  23
		when '14' then  10
		when '15' then  14
		when '16' then 4
		when '17' then 12
		when '18' then 6
		when '19' then 15
		when '20' then  17
		when '21' then 37
		else 0

	end
*/
 
	Update tdrsilt.dbo.mtto_unidades   Set  id_flota = @flota  	
	where id_unidad  =  @unidad
	
end


If  update( trl_type3) 
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
		when 'HER'  then 63
		when 'VEN' then 38
		when 'NTM' then 64
		when 'MTL' then 65
		when 'QRL' then  35
		when 'HYS'  then  52
		when 'ABI'  then  20
		when 'DHLX'  then  71
		when 'LIVER' then  33
		else 0
	end

 
	Update  tdrsilt.dbo.mtto_unidades   Set  id_depto =@depto 	
	where id_unidad  =  @unidad
	
end



If  update( trl_type4) 
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
DISABLE TRIGGER [dbo].[tg_tr_actualiza_silt_insert] ON [dbo].[trailerprofile]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Trigger Sobre la Tabla de trailerprofile
-- Toma los valores al hacer el insert en la tabla trailerprofile
-- 17- Septiembre - 2009 JRLR

--Drop trigger TMW_add_trailer
CREATE TRIGGER [dbo].[TMW_add_trailer]
ON [dbo].[trailerprofile] FOR INSERT
AS
	DECLARE @LS_TRL_NUMBER 	varchar(21),
		@LI_TRL_AXLES 	int

	/* Se hace el select para obtener los datos que se estan insertando y hacer la actualizacion de los ejes.*/

SELECT 	@LS_TRL_NUMBER 	= a.TRL_NUMBER,
	@LI_TRL_AXLES	= a.TRL_AXLES
FROM trailerprofile a, INSERTED b
WHERE   a.TRL_NUMBER	 = b.TRL_NUMBER;

-- si toma el dato de los ejes es igual a 0
	IF (@LI_TRL_AXLES = 0)
	Begin
		select @LI_TRL_AXLES = 2
	End

	IF  (@LI_TRL_AXLES) is null
	Begin
		select @LI_TRL_AXLES = 2
	End


	BEGIN
	/* Hace el update de la tabla con el monto en negativo...*/
		UPDATE trailerprofile
		SET 	TRL_AXLES  = @LI_TRL_AXLES 
		WHERE 	trl_number = @LS_TRL_NUMBER;
     
	END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- JET - 11/7/2002 - PTS 16131, remove the update portion of this trigger.
--     we decided to leave the insert so that customers who insert from legacy systems
--     but don't fill in the trl_id will not have a new issue/bug
/* Manage Triggers:  NGSERVER.ttsng_v2 as of 08/02/95 12:42:57 */

create TRIGGER [dbo].[TrailerUpdate]
ON [dbo].[trailerprofile] 
FOR insert AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

UPDATE trailerprofile 
   SET trl_id = CASE WHEN trl_ilt_scac IS NULL OR RTRIM(trl_ilt_scac) = '' THEN trl_number 
                     ELSE UPPER(trl_ilt_scac) + ',' + UPPER(ISNULL(trl_number, '')) END
 WHERE trl_id IS NULL OR RTRIM(trl_id) = '' 

--DECLARE @id varchar(13) , @iltscac varchar(4) , @num varchar(8) , @mintrl varchar(13) 
--
--/* exec timerins "trailerupdate", "BEGIN" */
--
--IF UPDATE ( trl_ilt_scac ) OR UPDATE ( trl_number ) 
--BEGIN
--
--SELECT @mintrl = ""
--
--while ( SELECT count(*)
--FROM inserted 
--WHERE ( ( ISNULL(trl_ilt_scac,'') + "," + trl_number ) > @mintrl )) > 0 begin
--
--/* exec timerins "trailerupdate", "1" */
--
--SELECT @mintrl = min ( ISNULL(trl_ilt_scac,'') + "," + trl_number ) 
--FROM inserted 
--WHERE ( ( ISNULL(trl_ilt_scac,'') + "," + trl_number ) > @mintrl ) 
--/* exec timerins "trailerupdate", "2" */
--
--SELECT @iltscac = trl_ilt_scac ,
--@num = trl_number 
--FROM inserted 
--WHERE ( ( ISNULL(trl_ilt_scac,'') + "," + trl_number ) = @mintrl ) 
--/* exec timerins "trailerupdate", "3" */
--
--if ( @iltscac is NULL ) or ( @iltscac = "" ) 
--SELECT @id = @num 
--else
--SELECT @id = @iltscac + "," + @num 
--
--UPDATE trailerprofile 
--
--SET trl_id = @id 
---- RE - 12/08/00 - PTS 9508 Added ISNULLs in where clause
--WHERE  ISNULL(trl_ilt_scac, '') = ISNULL(@iltscac, '') AND trl_number = @num
--/* exec timerins "trailerupdate", "4" */
--
--end
--END
--/* exec timerins "trailerupdate", "END" */
--
--
GO
ALTER TABLE [dbo].[trailerprofile] ADD CONSTRAINT [trl_ckalarmstate] CHECK (([dbo].[CheckLabel]([trl_alarmstate],'ReeferAlarmSummary',(1))<>(0)))
GO
ALTER TABLE [dbo].[trailerprofile] ADD CONSTRAINT [trl_ckmcommtype] CHECK (([dbo].[CheckLabel]([trl_mcommType],'MCommSystem',(1))=(1)))
GO
ALTER TABLE [dbo].[trailerprofile] ADD CONSTRAINT [pk_trailerprofile] PRIMARY KEY CLUSTERED ([trl_id]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trailerprofile_INS_TIMESTAMP] ON [dbo].[trailerprofile] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Trailerprofile_timestamp] ON [dbo].[trailerprofile] ([timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trl_type_id] ON [dbo].[trailerprofile] ([trl_equipmenttype]) INCLUDE ([trl_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_trl_id] ON [dbo].[trailerprofile] ([trl_ilt_scac], [trl_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_NUMBER] ON [dbo].[trailerprofile] ([trl_number]) INCLUDE ([trl_ams_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_trl_number_iltscac] ON [dbo].[trailerprofile] ([trl_number], [trl_ilt_scac]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_terminal] ON [dbo].[trailerprofile] ([trl_terminal]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailerprofile] TO [public]
GO
GRANT INSERT ON  [dbo].[trailerprofile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trailerprofile] TO [public]
GO
GRANT SELECT ON  [dbo].[trailerprofile] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailerprofile] TO [public]
GO
