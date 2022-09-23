CREATE TABLE [dbo].[legheader]
(
[lgh_number] [int] NOT NULL,
[lgh_firstlegnumber] [int] NULL,
[lgh_lastlegnumber] [int] NULL,
[lgh_drvtripnumber] [int] NULL,
[lgh_cost] [float] NULL,
[lgh_revenue] [float] NULL,
[lgh_odometerstart] [int] NULL,
[lgh_odometerend] [int] NULL,
[lgh_milesshortest] [smallint] NULL,
[lgh_milespractical] [smallint] NULL,
[lgh_allocfactor] [float] NULL,
[lgh_startdate] [datetime] NULL,
[lgh_enddate] [datetime] NULL,
[lgh_startcity] [int] NULL,
[lgh_endcity] [int] NULL,
[lgh_startregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_startstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_outstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_startlat] [int] NULL,
[lgh_startlong] [int] NULL,
[lgh_endlat] [int] NULL,
[lgh_endlong] [int] NULL,
[lgh_class1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_class2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_class3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_class4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number_start] [int] NULL,
[stp_number_end] [int] NULL,
[cmp_id_start] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id_end] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_startregion2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_startregion3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_startregion4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endregion2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endregion3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endregion4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_instatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_primary_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[fgt_number] [int] NULL,
[lgh_priority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_schdtearliest] [datetime] NULL,
[lgh_schdtlatest] [datetime] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_teamleader] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_domicile] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfh_number] [int] NULL,
[trl_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[timestamp] [timestamp] NULL,
[lgh_fueltaxstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_mtmiles] [smallint] NULL,
[lgh_prjdate1] [datetime] NULL,
[lgh_etamins1] [int] NULL,
[lgh_outofroute_routing] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [lghtype1default] DEFAULT ('UNK'),
[lgh_alloc_revenue] [money] NULL,
[lgh_primary_pup] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_prod_hr] [float] NULL,
[lgh_tot_hr] [float] NULL,
[lgh_ld_unld_time] [float] NULL,
[lgh_load_time] [float] NULL,
[lgh_startcty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endcty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_enddate_arrival] [datetime] NULL,
[lgh_dsp_date] [datetime] NULL,
[lgh_geo_date] [datetime] NULL,
[lgh_nexttrailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_nexttrailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_etamilestofinal] [int] NULL,
[lgh_etamintofinal] [int] NULL,
[lgh_split_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_createdon] [datetime] NULL,
[lgh_createapp] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_updatedon] [datetime] NULL,
[lgh_updateapp] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_feetavailable] [smallint] NULL,
[lgh_rstartdate] [datetime] NULL,
[lgh_renddate] [datetime] NULL,
[lgh_rstartcity] [int] NULL,
[lgh_rendcity] [int] NULL,
[lgh_rstartregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rendregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rstartstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rendstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rstartlat] [int] NULL,
[lgh_rstartlong] [int] NULL,
[lgh_rendlat] [int] NULL,
[lgh_rendlong] [int] NULL,
[stp_number_rstart] [int] NULL,
[stp_number_rend] [int] NULL,
[cmp_id_rstart] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id_rend] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rstartregion2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rstartregion3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rstartregion4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rendregion2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rendregion3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rendregion4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rstartcty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rendcty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[can_cap_expires] [datetime] NULL,
[can_ld_expires] [datetime] NULL,
[lgh_dispatchdate] [datetime] NULL,
[lgh_asset_lock] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_asset_lock_dtm] [datetime] NULL,
[lgh_asset_lock_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drvplan_number] [int] NULL,
[lgh_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [lghtype2default] DEFAULT ('UNK'),
[lgh_tm_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [lghtmdefault] DEFAULT ('NOSENT'),
[lgh_tour_number] [int] NULL,
[lgh_acttransferdate] [datetime] NULL CONSTRAINT [DF__legheader__lgh_a__353EA674] DEFAULT ('12/31/2049 23:59'),
[lgh_fuelburned] [money] NULL CONSTRAINT [DF__legheader__lgh_f__3632CAAD] DEFAULT (0),
[lgh_actualmiles] [money] NULL CONSTRAINT [DF__legheader__lgh_a__3726EEE6] DEFAULT (0),
[lgh_triphours] [money] NULL CONSTRAINT [DF__legheader__lgh_t__381B131F] DEFAULT (0),
[lgh_fueltaxstatusdate] [datetime] NULL,
[lgh_load_origin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_miles] [int] NULL,
[lgh_linehaul] [float] NULL,
[lgh_noautosplit] [tinyint] NOT NULL CONSTRAINT [DF_legheader_lgh_noautosplit] DEFAULT (0),
[lgh_noautotransfer] [tinyint] NOT NULL CONSTRAINT [DF_legheader_lgh_noautotransfer] DEFAULT (0),
[lgh_ord_charge] [float] NULL,
[lgh_act_weight] [float] NULL,
[lgh_est_weight] [float] NULL,
[lgh_tot_weight] [float] NULL,
[lgh_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_max_weight_exceeded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_manuallysettypeclass] [int] NULL,
[lgh_tmstatusstopnumber] [int] NULL,
[lgh_detstatus] [int] NOT NULL CONSTRAINT [DF__legheader__lgh_d__12B61AF4] DEFAULT (0),
[lgh_eta_cmp_list] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_etacalcdate] [datetime] NULL,
[lgh_etacomment] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_washplan] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_hzd_cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_acttransfer] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_originzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_destzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_204status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_order_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_permit_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_204date] [datetime] NULL,
[lgh_trc_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_ace_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_mpp_type_editdatetime] [datetime] NULL,
[mpp2_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp2_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp2_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp2_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_car_totalcharge] [money] NULL,
[lgh_triphours2] [money] NULL CONSTRAINT [DF__legheader__lgh_t__24F75A8F] DEFAULT (0),
[lgh_permitnumbers] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_permitby] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_permitdate] [datetime] NULL,
[lgh_chassis] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__legheader__lgh_c__22A5C920] DEFAULT ('UNKNOWN'),
[lgh_chassis2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__legheader__lgh_c__2399ED59] DEFAULT ('UNKNOWN'),
[lgh_recommended_car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_204_tradingpartner] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__legheader__lgh_2__6C245F47] DEFAULT ('UNKNOWN'),
[shift_ss_id] [int] NULL,
[lgh_plandate] [datetime] NULL,
[lgh_204validate] [int] NULL,
[ma_transaction_id] [bigint] NULL,
[ma_tour_number] [int] NULL,
[ma_tour_sequence] [tinyint] NULL,
[ma_mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ma_trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_etaalert1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_shiftdate] [datetime] NULL,
[lgh_shiftnumber] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_eta_est_startdate] [datetime] NULL,
[lgh_eta_est_enddate] [datetime] NULL,
[lgh_eta_next_pickup] [datetime] NULL,
[lgh_eta_next_drop] [datetime] NULL,
[lgh_total_mov_bill_miles] [int] NULL,
[lgh_total_mov_miles] [int] NULL,
[lgh_mile_overage_message] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_car_rate] [money] NULL,
[lgh_car_charge] [money] NULL,
[lgh_car_accessorials] [decimal] (12, 4) NULL,
[lgh_spot_rate_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_spot_rate_updateddt] [datetime] NULL,
[lgh_spot_rate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_ship_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_protected_rate] [money] NULL,
[lgh_avg_rate] [money] NULL,
[lgh_edi_counter] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_acc_so1] [money] NULL,
[lgh_acc_so2] [money] NULL,
[lgh_acc_so3] [money] NULL,
[lgh_acc_so4] [money] NULL,
[lgh_acc_so5] [money] NULL,
[lgh_acc_so6] [money] NULL,
[lgh_rate_dt] [datetime] NULL,
[lgh_acc_fsc] [money] NULL,
[lgh_rate_error] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_rate_error_desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_faxemail_created] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_externalrating_miles] [int] NULL,
[lgh_rtd_id] [int] NULL,
[lgh_prev_seg_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_prev_seg_status_last_updated] [datetime] NULL,
[lgh_raildispatchstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_dolly] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_dolly2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_trailer3] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_trailer4] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_railtemplatedetail_id] [int] NULL,
[trc_teamleader] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_optimizestatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_optimizedrouteid] [int] NULL,
[lgh_ratemode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_servicelevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_servicedays] [int] NULL,
[lgh_other_status1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_other_status2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RailServiceLevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_plannedhours] [decimal] (6, 2) NULL,
[lgh_direct_route_status1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_laneid] [int] NULL,
[lgh_extrainfo1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_extrainfo2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_extrainfo3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_railschedule_id] [int] NULL,
[lgh_optimizationdate] [datetime] NULL,
[lgh_payTermCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_car_accessorial_codes] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_car_accessorial_rates] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_autoloadmaxgvw] [float] NULL,
[lgh_op_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[dt_legheader_consolidated] on [dbo].[legheader] for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/*
	10/17/2006	JG 	PTS 34308 consolidate and optimize trigger.

	11/17/2008	DJM	PTS 44336	Delete the geofuelrequest record for the Trip Segment if the Leg is deleted.
	02/04/2014  HMA PTS 73672 Fix Identity for INSERT INTO TMSQLMessageData
*/

declare @lgh_number 		int,
	@ls_CtxActiveLegs	char(1),
	@maptuit_geocode        CHAR(1),
        @lgh_outstatus		VARCHAR(6),
	@ord_hdrnumber		INTEGER,
	@m2qhid			INTEGER,
	@StlAssetInDispatch	char(1),
	@lgh_recommended_car_id	VARCHAR(8),
	@ord_start		DATETIME


--PTS34308 prevent empty firing
if not exists (select 1 from deleted) return
--PTS34308 end

select @lgh_number = 0
SELECT @maptuit_geocode = Upper(isnull(gi_string1,'N'))
 FROM generalinfo
WHERE gi_name = 'MaptuitAlert'

--JLB PTS 42415
select @StlAssetInDispatch = Upper(isnull(gi_string1,'N'))
 from generalinfo
where gi_name = 'StlAssetInDispatch'
--end 42415

while exists (select * from deleted
	where lgh_number > @lgh_number)
begin
	select @lgh_number = min(lgh_number)
	from deleted
	where lgh_number > @lgh_number
	
	delete legheader_active
	where lgh_number=@lgh_number
	
	delete assetassignment
	where lgh_number = @lgh_number

  SELECT @lgh_outstatus = lgh_outstatus,
         @ord_hdrnumber = ord_hdrnumber
    FROM deleted
   WHERE lgh_number = @lgh_number

   --PTS22080 MBR 03/25/04
   IF @maptuit_geocode = 'Y'
   BEGIN
      /* moving outside since the status is needed outisde of this if
      SELECT @lgh_outstatus = lgh_outstatus,
             @ord_hdrnumber = ord_hdrnumber
        FROM deleted
       WHERE lgh_number = @lgh_number
	  */
      IF (@lgh_outstatus = 'DSP' OR @lgh_outstatus = 'STD') AND @ord_hdrnumber > 0
      BEGIN
         EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'DispatchID', 'HIL', convert(varchar, @lgh_number))
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'Timestamp', 'HIL', convert(varchar, getdate(), 20))
         INSERT INTO m2msgqhdr VALUES (@m2qhid, 'Void', getdate(), 'R')
      END
   END
	--JLB PTS 42415
	if @StlAssetInDispatch = 'Y' and @lgh_number > 0 and (@lgh_outstatus = 'DSP' or @lgh_outstatus = 'PLN')
	begin
		delete
		  from paydetail 
         where lgh_number = @lgh_number
		   and isnull(pyd_updsrc,'x') not in ('M','F')
	end
	--end 42415
end

--PTS51128 MBR 03/03/10
select @lgh_number = lgh_number
from deleted

SELECT @lgh_recommended_car_id = ISNULL(lgh_recommended_car_id, 'UNKNOWN'),
       @ord_hdrnumber = ISNULL(ord_hdrnumber, 0)
  FROM deleted
 WHERE lgh_number = @lgh_number

IF @lgh_recommended_car_id <> 'UNKNOWN' AND @ord_hdrnumber > 0 AND
   (SELECT UPPER(SUBSTRING(gi_string1, 1,1))
      FROM generalinfo WITH (NOLOCK)
     WHERE gi_name = 'UpdateCarrierCommitments') = 'Y'
BEGIN
   SELECT @ord_start = ord_startdate
     FROM orderheader
    WHERE ord_hdrnumber = @ord_hdrnumber
   EXEC core_updatecarrierrecommendation @ord_hdrnumber, @ord_start, @lgh_recommended_car_id, 'DEC' 
END


--vmj1+	PTS 16885	01/24/2003	All further code should only be run if ctx_active_legs is 
--being used..
select	@ls_CtxActiveLegs = upper(isnull(left(gi_string1, 1), 'N'))
  from	generalinfo
  where	gi_name = 'CTXActiveLegs'
select @ls_CtxActiveLegs = ltrim(rtrim(@ls_CtxActiveLegs))
if @ls_CtxActiveLegs = '' 
	select @ls_CtxActiveLegs = 'N'
if @ls_CtxActiveLegs <> 'Y'
	return

--only handle single row updates
if (select count(*) from deleted) > 1 
	return

select @lgh_number = lgh_number
from deleted

exec update_ctx_active_legs @lgh_number
--vmj1-

--PTS37165 MBR 08/07/07
DELETE FROM paperwork
 WHERE lgh_number = @lgh_number


-- PTS 44336 - DJM
Delete from geofuelrequest where gf_lgh_number = @lgh_number and gf_status in ('RUN','HOLD','SEND')


----------------------------------------------------------------------------------
--PTS34308 jg begin logic (DELETE) relocated from udt_legheader_tmail_updates 
----------------------------------------------------------------------------------
-- trigger for PTS12969 send info to TMail when order changes

declare @TMailTRCChangeFormID int,
	@ord int, @mov int, @lgh int, @stp int, @temp varchar(60),
	@delete char(1), @stp_type varchar(6), @trc varchar(8),
	@outstatus varchar(6), @lgh_dsp_date datetime,
	@old_outstatus varchar(6), @newtrc varchar(8)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output
	
--only run for singe row updates
--if (select count(*) from inserted) > 1 or
--	(select count(*) from deleted) > 1 Return

if NOT ((select count(*) from inserted) > 1 or
	(select count(*) from deleted) > 1 )
BEGIN

select @TMailTRCChangeFormID = 0

select @temp = gi_string1 from generalinfo
where gi_name = 'TMailTRCChangeFormID'
if isnumeric(@temp) = 1 select @TMailTRCChangeFormID = convert(int, @temp)

--make sure one of the option are turned on
if @TMailTRCChangeFormID > 0
begin
	select @delete = 'Y'
	select 	@ord = ord_hdrnumber,
		@mov = mov_number,
		@lgh = lgh_number,
		@outstatus = lgh_outstatus,
		@lgh_dsp_date = lgh_dsp_date,
		@newtrc = lgh_tractor,
		@delete = 'N'
	from inserted
	
	--get old tractor to send cancel message 
	if @delete = 'N'
		select 	@trc = lgh_tractor,
			@old_outstatus = lgh_outstatus 
		from deleted
	else
		select 	@ord = ord_hdrnumber,  --deleted legheader
			@mov = mov_number,
			@lgh = lgh_number,
			@trc = lgh_tractor,
			@newtrc = lgh_tractor,
			@lgh_dsp_date = lgh_dsp_date,
			@old_outstatus = lgh_outstatus 
		from deleted

	
	if (@lgh_dsp_date is not null) and --macro sent
		((@old_outstatus in ('DSP','STD') and (isnull(@outstatus,'') = 'CAN' or @delete = 'Y')) or --order canceled
		(@old_outstatus in ('DSP','STD') and (@newtrc <> @trc or @outstatus='AVl'))) --tractor changed
	begin
		declare @IDENT int

		insert TMSQLMessage (msg_date, msg_FormID, msg_To, msg_ToType, msg_FilterData,
			msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
		values (getdate(), 
			@TMailTRCChangeFormID, 
			@trc, 
			4, --type 4 tractor
			@trc+convert(varchar(5),@TMailTRCChangeFormID)+convert(varchar(15),@lgh), --filter duolicate rows
			30, --wait 30 seconds
			@tmwuser,
			0, --0 who knows
			'Trip Assignment Changed')

		select @IDENT = scope_identity() --pts 73672

		insert TMSQLMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		values (@IDENT, 1, 'lgh_number', @lgh)

		insert TMSQLMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		values (@IDENT, 1, 'Field01', @ord)

		insert TMSQLMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		values (@IDENT, 1, 'ord_number', @ord)
	end
end

-- RE - PTS 77738 - BEGIN
UPDATE	tractorprofile
   SET	trc_optimizationdate = GETDATE()
  FROM	deleted
 WHERE	tractorprofile.trc_number = deleted.lgh_tractor
   AND	deleted.lgh_tractor <> 'UNKNOWN'
END
-- RE - PTS77738 - END

-- RE - PTS87004 - START
IF EXISTS(SELECT	* 
			FROM	deleted d
			WHERE	d.lgh_tractor = 'UNKNOWN'
				AND	d.lgh_carrier <> 'UNKNOWN')
BEGIN
	DECLARE @powerIds TABLE (powerId VARCHAR(25))

	INSERT INTO @powerIds
		SELECT	d.lgh_carrier + '|' + CAST(d.lgh_number AS varchar(20))
		  FROM	deleted d 
		 WHERE	d.lgh_tractor = 'UNKNOWN'
		   AND	d.lgh_carrier <> 'UNKNOWN'

	DELETE	opt_eta_pta_stop_state
		WHERE	truck_id IN (SELECT powerId FROM @powerIds)

	DELETE	opt_eta_pta_load_state
		WHERE	truck_id IN (SELECT powerId FROM @powerIds)

	DELETE	opt_eta_pta_hos_segments
		WHERE	truck_id IN (SELECT powerId FROM @powerIds)

	DELETE	opt_eta_pta_power_state
		WHERE	power_id IN (SELECT powerId FROM @powerIds)
END
-- RE - PTS87004 - END


--PTS34308 jg end logic (DELETE) relocated from udt_legheader_tmail_updates 
----------------------------------------------------------------------------------

-- PTS 88288 DMA
IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'ProcessInteractiveTripUpdates' AND ((LEFT(LTRIM(gi_string1), 1) = 'Y') OR LEFT(LTRIM(gi_string1), 1) = 'Y') OR (LEFT(LTRIM(gi_string1), 1) = 'Y') OR (LEFT(LTRIM(gi_string1), 1) = 'Y'))
	begin
		DECLARE @driver varchar(8),
                @driver2 varchar(8),
                @tractor varchar(8),
                @trailer varchar(8),
                @carrier varchar(8)

		SELECT  @lgh_number = deleted.lgh_number,
				@driver = deleted.lgh_driver1,
				@driver2 = deleted.lgh_driver2,
				@tractor = deleted.lgh_tractor,
				@trailer = deleted.lgh_primary_trailer
			FROM deleted

		IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'ProcessInteractiveTripUpdates' AND LEFT(LTRIM(gi_string1), 1) = 'Y') 
			begin
				exec Interactive_Fuel_Update_sp 'DRV', @driver, @lgh_number, 'TRIP'
				exec Interactive_Fuel_Update_sp 'DRV', @driver2, @lgh_number, 'TRIP'
			end

		IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'ProcessInteractiveTripUpdates' AND LEFT(LTRIM(gi_string2), 1) = 'Y') 
			begin
				exec Interactive_Fuel_Update_sp 'TRC', @tractor, @lgh_number, 'TRIP'
			end

		IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'ProcessInteractiveTripUpdates' AND LEFT(LTRIM(gi_string3), 1) = 'Y') 
			begin
				exec Interactive_Fuel_Update_sp 'TRL', @trailer, @lgh_number, 'TRIP'
			end

		IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'ProcessInteractiveTripUpdates' AND LEFT(LTRIM(gi_string4), 1) = 'Y') 
			begin
				exec Interactive_Fuel_Update_sp 'CAR', @carrier, @lgh_number, 'TRIP'
			end
	end
-- PTS 88288 DMA -- END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_legheader_consolidated] ON [dbo].[legheader] 
FOR INSERT
AS

SET NOCOUNT ON; -- 06/25/2007 MDH PTS: 38085: Added 

/*	Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	----------------------------------------
	01/16/2006	DJM				PTS 31021 Modified to update the pyd_status of the Asset Assignment record if required.
	07/07/2006	DJM				PTS 33550 Modified logic from 31021 to allow for other lgh_type columns.
	10/17/2006	JG				PTS 34308 Consolidate and optimize trigger
*/

DECLARE 
  @commentstatus                VARCHAR(60)
, @movnum                       INT
, @m2qhid                       INT
, @ord_hdrnumber                INT
, @lgh_tractor                  VARCHAR(8)
, @lastcityname                 VARCHAR(18)
, @lastcitystate                VARCHAR(6)
, @new_lgh_outstatus            VARCHAR(6)
, @prev_lghnum                  INT
, @count                        INT
, @lgh_split_flag               CHAR(1)
, @lgh_carrier                  VARCHAR(8)
, @lgh_createapp                VARCHAR(128)
, @car_204flag                  SMALLINT --PTS46536 MBR 01/06/10
, @car_204tender                VARCHAR(6) --PTS46536 MBR 01/06/10
, @lgh_cmp_start                VARCHAR(12) --PTS46536 MBR 01/06/10
, @lgh_cmp_end                  VARCHAR(12) --PTS46536 MBR 01/06/10
, @origin_rail                  CHAR(1) --PTS46536 MBR 01/06/10
, @dest_rail                    CHAR(1) --PTS46536 MBR 01/06/10
, @RequireAssignedTrailerEDI204 CHAR(1) -- PTS 61858 DMA
, @trailer                      VARCHAR(13) -- PTS 61858 DMA
, @driver                       VARCHAR(13) -- PTS 88288 DMA
, @driver2                      VARCHAR(13) -- PTS 88288 DMA
, @tractor                      VARCHAR(13) -- PTS 88288 DMA
, @edi204CarTypeField           VARCHAR(60) -- PTS 64334 DMA - Tells what carrier profile field to look for values 
, @edi204CarTypes               VARCHAR(60)					-- PTS 64334 DMA - Tells what values in the above field that will send out a 204
, @tmwuser                      VARCHAR(255)
, @donotpay_status              VARCHAR(6)
, @donotpay_type                VARCHAR(6)
, @donotpay_field               VARCHAR(60) 
, @newdate                      DATETIME
, @lgh_number                   INT
, @ord                          INT 
, @send_204                     CHAR(1)
, @check4trailer                CHAR(1)
, @pos                          INT
, @piece                        NVARCHAR(500);

--PTS34308 prevent empty firing
IF NOT EXISTS(SELECT 1 FROM inserted)
BEGIN
  RETURN;
END;
--PTS34308 end

/*
GENERAL INFO MASTER LOOKUP BEGIN
*/

DECLARE @GI_VALUES_TO_LOOKUP TABLE (
  gi_name VARCHAR(30) PRIMARY KEY);

DECLARE @GIKEY TABLE (
  gi_name     VARCHAR(30) PRIMARY KEY
, gi_string1  VARCHAR(60)
, gi_string2  VARCHAR(60)
, gi_string3  VARCHAR(60)
, gi_string4  VARCHAR(60)
, gi_integer1 INT
, gi_integer2 INT
, gi_integer3 INT
, gi_integer4 INT);

INSERT 
  @GI_VALUES_TO_LOOKUP
VALUES
  --Replace these lookups with value(s) that match your needs.
  ('ProcessOutbound204')
, ('Outbound204railbilling')
, ('FingerprintAudit')
, ('TrailerCommentsResetStatus')
, ('MaptuitAlert')
, ('RequireAssignedTrailerEDI204')
, ('LoadFileExport')
, ('MinAssetAssignPayCode')
, ('ProcessInteractiveTripUpdates');  

INSERT INTO @GIKEY (gi_name
, gi_string1
, gi_string2
, gi_string3
, gi_string4
, gi_integer1
, gi_integer2
, gi_integer3
, gi_integer4)
SELECT 
  gi_name
, RTRIM(LTRIM(gi_string1))
, gi_string2
, gi_string3
, gi_string4
, gi_integer1
, gi_integer2
, gi_integer3
, gi_integer4
FROM (
      SELECT 
        gvtlu.gi_name
      , g.gi_string1
      , g.gi_string2
      , g.gi_string3 
      , g.gi_string4
      , gi_integer1
      , gi_integer2
      , gi_integer3
      , gi_integer4
       --What we're doing here is checking the date of the generalInfo row in case there are multiples.
       --This will order the rows in descending date order with the following exceptions.
       --Future dates are dropped to last priority by moving to less than the apocalypse.
       --Nulls are moved to second to last priority by using the apocalypse.
       --Everything else is ordered descending.
       --We then take the "newest".
      , ROW_NUMBER() OVER (PARTITION BY gvtlu.gi_name ORDER BY CASE WHEN g.gi_datein > GETDATE() THEN '1/1/1949' ELSE COALESCE(g.gi_datein, '1/1/1950') END DESC) RN 
      FROM 
        @GI_VALUES_TO_LOOKUP gvtlu
          LEFT OUTER JOIN 
        dbo.generalinfo g on gvtlu.gi_name = g.gi_name) subQuery
WHERE
  RN = 1; --   <---This is how we take the top 1.

--GENERAL INFO MASTER LOOKUP END




--PTS 23691 CGK 9/3/2004
EXEC gettmwuser @tmwuser OUTPUT;

-- PTS 31021 - DJM
--PTS46536 MBR 01/06/10

IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'FingerprintAudit' AND LEFT(gi_string1, 1) = 'Y')
BEGIN
  INSERT INTO dispaudit(
    ord_hdrnumber
  , lgh_number
  , updated_by
  , updated_dt
  , new_dispatch_dt)
  SELECT
    stops.ord_hdrnumber
  , legheader.lgh_number
  , @tmwuser
  , GETDATE()
  , legheader.lgh_dispatchdate
  FROM 
    stops
      INNER JOIN
    inserted legheader ON stops.stp_number = legheader.stp_number_start;
END;

-- RE - 4/2/03 - PTS #17795
SELECT @commentstatus = ',' + gi_string1 + ',' FROM @GIKEY WHERE gi_name = 'TrailerCommentsResetStatus';

IF EXISTS(SELECT 
            1
          FROM 
            inserted
          WHERE
            CHARINDEX(','+lgh_outstatus+',' , @commentstatus) > 0)
BEGIN
  UPDATE 
    trailerprofile
  SET 
    trl_worksheet_comment1 = NULL
  , trl_worksheet_comment2 = NULL
  FROM 
    inserted i
  WHERE
    trl_id IN(i.lgh_primary_trailer, i.lgh_primary_pup)
      AND
    trl_id <> 'UNKNOWN'
      AND
    CHARINDEX(','+lgh_outstatus+',', @commentstatus) > 0;
END;

-- KMM FOR MBR  PTS 22080
IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'MaptuitAlert' AND LEFT(gi_string1, 1) = 'Y')
BEGIN
------------------------------------------------------

  SELECT --Why count here?  Why not exists like everywhere else?  Because I need to know how many IDENTs to get.
    @COUNT = COUNT(*)
  FROM 
    inserted i
  WHERE
    i.lgh_outstatus IN ('STD', 'CMP') 
      AND 
    lgh_tractor <> 'UNKNOWN'
      AND 
    i.ord_hdrnumber = 0

  IF @COUNT > 0
  BEGIN
    EXEC @m2qhid = [dbo].[getsystemnumberblock] 'M2QHID', '', @COUNT;
      
    INSERT dbo.m2msgqdtl (
      m2qdid
    , m2qdkey
    , m2qdcrtpgm
    , m2qdvalue)
    SELECT
      ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
    , 'RoutelinePoint_CityName'
    , 'HIL'
    , c.cty_name
    FROM 
      inserted i
        INNER JOIN
      city c ON i.lgh_endcity = c.cty_code
    WHERE
      i.lgh_outstatus IN ('STD', 'CMP') 
        AND 
      lgh_tractor <> 'UNKNOWN'
        AND 
      i.ord_hdrnumber = 0;

    INSERT dbo.m2msgqdtl (
      m2qdid
    , m2qdkey
    , m2qdcrtpgm
    , m2qdvalue)
    SELECT
      ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
    , 'RoutelinePoint_RegionCode'
    , 'HIL'
    , c.cty_state
    FROM 
      inserted i
        INNER JOIN
      city c ON i.lgh_endcity = c.cty_code
    WHERE
      i.lgh_outstatus IN ('STD', 'CMP') 
        AND 
      lgh_tractor <> 'UNKNOWN'
        AND 
      i.ord_hdrnumber = 0;

    INSERT dbo.m2msgqdtl (
      m2qdid
    , m2qdkey
    , m2qdcrtpgm
    , m2qdvalue)
    SELECT
      ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
    , 'UnitID'
    , 'HIL'
    , lgh_tractor
    FROM 
      inserted i
    WHERE
      i.lgh_outstatus IN ('STD', 'CMP') 
        AND 
      lgh_tractor <> 'UNKNOWN'
        AND 
      i.ord_hdrnumber = 0;

     
    INSERT dbo.m2msgqdtl (
      m2qdid
    , m2qdkey
    , m2qdcrtpgm
    , m2qdvalue)
    SELECT
      ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
    , 'TimeStamp'
    , 'HIL'
    , CONVERT(VARCHAR, GETDATE(), 20)
    FROM 
      inserted i
    WHERE
      i.lgh_outstatus IN ('STD', 'CMP') 
        AND 
      lgh_tractor <> 'UNKNOWN'
        AND 
      i.ord_hdrnumber = 0;

    INSERT dbo.m2msgQhdr 
    SELECT
      ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
    , 'Deadhead'
    , GETDATE()
    , 'R'
    FROM 
      inserted i
    WHERE
      i.lgh_outstatus IN ('STD', 'CMP') 
        AND 
      lgh_tractor <> 'UNKNOWN'
        AND 
      i.ord_hdrnumber = 0;
    
  END;--IF @COUNT > 0
END;
-- END FOR MBR

--PTS46536 MBR 11/05/09 Rewrote the following section and included the rail billing mods.
--PTS30434 MBR 10/31/05
IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'ProcessOutbound204' AND LEFT(gi_string1, 1) = 'Y')
     AND
   EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'Outbound204railbilling' AND LEFT(gi_string1, 1) = 'Y')
BEGIN
  
  DECLARE @legs TABLE(
    lgh_number          INT
  , lgh_carrier         VARCHAR(8)
  , lgh_primary_trailer VARCHAR(13)
  , check4Trailer       CHAR(1))

  INSERT @legs
  SELECT
    lgh_number
  , COALESCE(lgh_carrier , 'UNKNOWN')
  , lgh_primary_trailer
  , 'N'
  FROM
    inserted 
      LEFT OUTER JOIN
    dbo.carrier ON inserted.lgh_carrier = carrier.car_id
  WHERE
    COALESCE(lgh_204validate , 1) = 1
      AND
    COALESCE(lgh_carrier , 'UNKNOWN') <> 'UNKNOWN'
      AND
    COALESCE(lgh_createapp, '') <> 'EDI 204 Order Editor'
      AND
    car_204flag = 1;

  SELECT 
    @RequireAssignedTrailerEDI204 = LEFT(COALESCE(gi_string1 , 'N'), 1)
  , @edi204CarTypeField = COALESCE(gi_string2 , '')
  , @edi204CarTypes = COALESCE(gi_string3 , '')
  FROM
    @GIKEY
  WHERE
    gi_name = 'RequireAssignedTrailerEDI204';

  IF @RequireAssignedTrailerEDI204 <> 'Y'
  BEGIN
    SET @RequireAssignedTrailerEDI204 = 'N';
  END;

  IF @edi204CarTypes = ''
  BEGIN			-- Everything requires a trailer check
    UPDATE
      @legs
    SET 
      check4trailer = 'Y';
  END;

  -- Now load available CARTypes into a table string for later processing.
  DECLARE @edi204CarTypeStrings TABLE(value NVARCHAR(512));

  IF @RequireAssignedTrailerEDI204 = 'Y'
       AND
     EXISTS(SELECT 1 FROM @legs WHERE check4trailer = 'N')
  BEGIN
    
    INSERT INTO @edi204CarTypeStrings(
      value)
    SELECT 
      value
    FROM
      dbo.CSVStringsToTable_fn(@edi204CarTypes)
  

    IF @edi204CarTypeField = 'CARTYPE1'
    BEGIN
      UPDATE
        @legs
      SET
        check4trailer = 'Y'
      FROM
        dbo.carrier
      WHERE
        carrier.car_id = lgh_carrier
          AND 
        carrier.car_Type1 IN (SELECT value FROM @edi204CarTypeStrings);
    END;

    IF @edi204CarTypeField = 'CARTYPE2'
    BEGIN
      UPDATE
        @legs
      SET
        check4trailer = 'Y'
      FROM
        dbo.carrier
      WHERE
        carrier.car_id = lgh_carrier
          AND 
        carrier.car_Type2 IN (SELECT value FROM @edi204CarTypeStrings);
    END;

    IF @edi204CarTypeField = 'CARTYPE3'
    BEGIN
      UPDATE
        @legs
      SET
        check4trailer = 'Y'
      FROM
        dbo.carrier
      WHERE
        carrier.car_id = lgh_carrier
          AND 
        carrier.car_Type3 IN (SELECT value FROM @edi204CarTypeStrings);
    END;


    IF @edi204CarTypeField = 'CARTYPE4'
    BEGIN
      UPDATE
        @legs
      SET
        check4trailer = 'Y'
      FROM
        dbo.carrier
      WHERE
        carrier.car_id = lgh_carrier
          AND 
        carrier.car_Type4 IN (SELECT value FROM @edi204CarTypeStrings);
    END;
  END;

  
  
  DECLARE EDI204Cursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT
    lgh_number
  , lgh_carrier
  FROM
    @legs
  WHERE
    @RequireAssignedTrailerEDI204 = 'N'
        OR
    @RequireAssignedTrailerEDI204 = 'Y'
      AND
    check4trailer = 'Y'
      AND
    lgh_primary_trailer <> 'UNKNOWN'
        OR
    @RequireAssignedTrailerEDI204 = 'Y'
      AND
    check4trailer = 'N';

  OPEN EDI204Cursor;
  FETCH NEXT FROM EDI204Cursor INTO @lgh_number, @lgh_carrier;
  
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC create_outbound204 @lgh_number, @lgh_carrier, 'ADD';
    FETCH NEXT FROM EDI204Cursor INTO @lgh_number, @lgh_carrier;
  END;
  CLOSE EDI204Cursor;
  DEALLOCATE EDI204Cursor;

END;

--PTS30545 MBR 12/05/05
IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'LoadFileExport' AND LEFT(gi_string1, 1) = 'Y')
BEGIN
  --ERIC - For the record, I am embarassed by this.  But my mind can't think of a way to window it.
  --But we should only be talking about a few rows here anyways, right?
  DECLARE LegCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT 
    i.lgh_number
  , (SELECT COUNT(1) FROM dbo.legheader WHERE mov_number = i.mov_number) TheCount
  , COALESCE((SELECT MAX(lgh_number) FROM dbo.legheader WHERE mov_number = i.mov_number AND lgh_number < i.lgh_number), -1) TheLast
  FROM 
    inserted i
      INNER JOIN
    legheader l ON i.mov_number = l.mov_number;
  
  OPEN LegCursor
  FETCH NEXT FROM LegCursor INTO @lgh_number, @Count, @prev_lghnum

  WHILE @@FETCH_STATUS = 0
  BEGIN

    IF @count > 1
    BEGIN
      IF @prev_lghnum > 0
      BEGIN
        IF @count = 2
        BEGIN
          EXEC create_segment_output @prev_lghnum, 'Y', 'N';
        END;
        ELSE
        BEGIN
          EXEC create_segment_output @prev_lghnum, 'N', 'N';
        END;
      END;
      EXEC create_segment_output @lgh_number, 'Y', 'N';
    END;
    ELSE
    BEGIN
      EXEC create_segment_output @lgh_number, 'N', 'N';
    END;

    FETCH NEXT FROM LegCursor INTO @lgh_number, @Count, @prev_lghnum;

  END;
  CLOSE LegCursor;
  DEALLOCATE LegCursor;
END;
--DONE
/* PTS 33550 (31021) - DJM - Set the Pay Status to the specified code if the specified condition exists		*/

IF EXISTS(SELECT gi_string1 FROM @GIKEY WHERE gi_name = 'MinAssetAssignPayCode' AND gi_string1 = 'Y')
BEGIN

  SELECT 
    @donotpay_status = gi_string1
  , @donotpay_type = gi_string2
  , @donotpay_field = gi_string3
  FROM 
    @GIKEY
  WHERE
    gi_name = 'MinAssetAssignPayStatus';

  IF EXISTS(SELECT 
              1
            FROM 
              inserted i
            WHERE
              @donotpay_type = CASE
                                 WHEN @donotpay_field = 'lgh_type1' THEN i.lgh_type1
                                 WHEN @donotpay_field = 'lgh_type2' THEN i.lgh_type2
                                 WHEN @donotpay_field = 'lgh_type3' THEN i.lgh_type3
                                 WHEN @donotpay_field = 'lgh_type4' THEN i.lgh_type4
                               END)				
		/* Set the Asset Assignment status to the non-payable status for all the
			AssetAssignment records of the Leg that are not already paid		*/

  BEGIN
    UPDATE 
      AssetAssignment
    SET 
      pyd_status = @donotpay_status
    FROM 
      inserted
    WHERE 
      assetassignment.asgn_type = 'DRV'
        AND
      assetassignment.pyd_status <> 'PPD'
        AND
      assetassignment.asgn_id IN (inserted.lgh_driver1, inserted.lgh_driver2)
        AND
      assetassignment.lgh_number = inserted.lgh_number
        AND
      @donotpay_type = CASE
                         WHEN @donotpay_field = 'lgh_type1' THEN inserted.lgh_type1
                         WHEN @donotpay_field = 'lgh_type2' THEN inserted.lgh_type2
                         WHEN @donotpay_field = 'lgh_type3' THEN inserted.lgh_type3
                         WHEN @donotpay_field = 'lgh_type4' THEN inserted.lgh_type4
                       END;

    UPDATE 
      AssetAssignment
    SET 
      pyd_status = @donotpay_status
    FROM 
      inserted
    WHERE 
      assetassignment.asgn_type = 'TRC'
        AND
      assetassignment.pyd_status <> 'PPD'
        AND
      assetassignment.asgn_id = inserted.lgh_tractor
        AND
      assetassignment.lgh_number = inserted.lgh_number
        AND
      @donotpay_type = CASE
                         WHEN @donotpay_field = 'lgh_type1' THEN inserted.lgh_type1
                         WHEN @donotpay_field = 'lgh_type2' THEN inserted.lgh_type2
                         WHEN @donotpay_field = 'lgh_type3' THEN inserted.lgh_type3
                         WHEN @donotpay_field = 'lgh_type4' THEN inserted.lgh_type4
                       END;

    UPDATE 
      AssetAssignment
    SET 
      pyd_status = @donotpay_status
    FROM 
      inserted
    WHERE 
      assetassignment.asgn_type = 'TRL'
        AND
      assetassignment.pyd_status <> 'PPD'
        AND
      assetassignment.asgn_id IN (inserted.lgh_primary_trailer, inserted.lgh_primary_pup)
        AND
      assetassignment.lgh_number = inserted.lgh_number
        AND
      @donotpay_type = CASE
                         WHEN @donotpay_field = 'lgh_type1' THEN inserted.lgh_type1
                         WHEN @donotpay_field = 'lgh_type2' THEN inserted.lgh_type2
                         WHEN @donotpay_field = 'lgh_type3' THEN inserted.lgh_type3
                         WHEN @donotpay_field = 'lgh_type4' THEN inserted.lgh_type4
                       END;



    UPDATE 
      AssetAssignment
    SET 
      pyd_status = @donotpay_status
    FROM 
      inserted
    WHERE 
      assetassignment.asgn_type = 'CAR'
        AND
      assetassignment.pyd_status <> 'PPD'
        AND
      assetassignment.asgn_id = inserted.lgh_carrier
        AND
      assetassignment.lgh_number = inserted.lgh_number
        AND
      @donotpay_type = CASE
                         WHEN @donotpay_field = 'lgh_type1' THEN inserted.lgh_type1
                         WHEN @donotpay_field = 'lgh_type2' THEN inserted.lgh_type2
                         WHEN @donotpay_field = 'lgh_type3' THEN inserted.lgh_type3
                         WHEN @donotpay_field = 'lgh_type4' THEN inserted.lgh_type4
                       END;

  END;
END;

-- RE - PTS77738 - BEGIN
UPDATE 
  tractorprofile
SET 
  trc_optimizationdate = GETDATE()
FROM 
  inserted
WHERE 
  tractorprofile.trc_number = inserted.lgh_tractor
    AND
  inserted.lgh_tractor <> 'UNKNOWN';

UPDATE 
  legheader
SET 
  lgh_optimizationdate = GETDATE()
FROM 
  inserted
WHERE 
  legheader.lgh_number = inserted.lgh_number;
-- RE - PTS77738 - END

-- PTS 88288 DMA
IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'ProcessInteractiveTripUpdates' AND  LEFT(gi_string1 , 1) = 'Y')
BEGIN

  DECLARE legCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT 
    lgh_number
  , lgh_driver1
  , lgh_driver2
  , lgh_tractor
  , lgh_primary_trailer
  , lgh_carrier
  FROM 
    inserted i;

  OPEN legCursor
  FETCH NEXT FROM legCursor INTO @lgh_number, @driver, @driver2, @tractor, @trailer, @lgh_carrier;

  WHILE @@FETCH_STATUS = 0
  BEGIN

    EXEC Interactive_Fuel_Update_sp 
      'DRV'
    , @driver
    , @lgh_number
    , 'TRIP';
    
    EXEC Interactive_Fuel_Update_sp 
      'DRV'
    , @driver2
    , @lgh_number
    , 'TRIP';
  
    IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'ProcessInteractiveTripUpdates' AND LEFT(gi_string2, 1) = 'Y')
    BEGIN
      EXEC Interactive_Fuel_Update_sp 
        'TRC'
      , @tractor
      , @lgh_number
      , 'TRIP';
    END;

    IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'ProcessInteractiveTripUpdates' AND LEFT(LTRIM(gi_string3) , 1) = 'Y')
    BEGIN
      EXEC Interactive_Fuel_Update_sp 
        'TRL'
      , @trailer
      , @lgh_number
      , 'TRIP';
    END;

    IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'ProcessInteractiveTripUpdates' AND LEFT(LTRIM(gi_string4) , 1) = 'Y')
    BEGIN
      EXEC Interactive_Fuel_Update_sp 
        'CAR'
      , @lgh_carrier
      , @lgh_number
      , 'TRIP';
    END;

    FETCH NEXT FROM legCursor INTO @lgh_number, @driver, @driver2, @tractor, @trailer, @lgh_carrier;
  END;

END;
-- PTS 88288 DMA -- END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create trigger [dbo].[iut_legheader_active] on [dbo].[legheader] for insert, update
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 


declare @lgh_number 		int
		,@ls_CtxActiveLegs	char(1)


--vmj3+	PTS 16885	01/24/2003	Check if ctx_active_legs is being used..
select	@ls_CtxActiveLegs = isnull(upper(left(ltrim(rtrim(g1.gi_string1)), 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'CTXActiveLegs'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'CTXActiveLegs'
							and	g2.gi_datein <= getdate())
if @ls_CtxActiveLegs = ''
	select @ls_CtxActiveLegs = 'N'
--vmj3-


select @lgh_number = 0

while exists (select * from inserted
	where lgh_number > @lgh_number)
begin
	select @lgh_number = min(lgh_number)
	from inserted
	where lgh_number > @lgh_number
	
	exec update_legheader_active @lgh_number

	--vmj3+
	if @ls_CtxActiveLegs = 'Y'
		execute update_ctx_active_legs @lgh_number
	--vmj3-
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[TMW_Auto_Load_Assign] ON [dbo].[legheader] 
FOR UPDATE, INSERT
AS

/* Does not use LegHeader.OutStatus right now but may in the future */
DECLARE @TM_FormID int,
	@TM_UnAssignFormID int,
	@TM_FormIDSubject varchar(60),
	@TM_UnAssignFormIDSubject varchar(60),
	@new_lgh_outstatus	varchar(6),
	@old_lgh_outstatus	varchar(6),
	@lgh_number int,
	@new_tractor varchar(8),
	@old_tractor varchar(8),
	@ord int,
	@Mov int,
	@Lgh_num int,
	@FilterData varchar(50),
	@UseFingerPrintAudit int

IF (SELECT COUNT(*) FROM inserted) = 0
	RETURN

SELECT 	@TM_FormID = gi_integer1
FROM	generalinfo (NOLOCK)
WHERE	gi_name = 'Auto_Send_LA_On_Assign'

SELECT 	@TM_UnAssignFormID = gi_integer1
FROM	generalinfo (NOLOCK)
WHERE	gi_name = 'Auto_Send_UA_On_Assign'

SELECT 	@TM_FormIDSubject = gi_String1
FROM	generalinfo (NOLOCK)
WHERE	gi_name = 'Auto_Send_LA_On_Assign_Subject'

SELECT @TM_FormIDSubject = LEFT(LTRIM(@TM_FormIDSubject), 50)

SELECT 	@TM_UnAssignFormIDSubject = gi_String1
FROM	generalinfo (NOLOCK)
WHERE	gi_name = 'Auto_Send_UA_On_Assign_Subject'

SELECT @TM_UnAssignFormIDSubject = LEFT(LTRIM(@TM_UnAssignFormIDSubject), 50)

IF ISNULL(@TM_FormID, 0) = 0 AND ISNULL(@TM_UnAssignFormID, 0) = 0
	RETURN

-- Should we log changes to expedite_audit?
IF (SELECT ISNULL(UPPER(LEFT(g1.gi_string1, 1)), 'N') 
	FROM generalinfo g1
	WHERE g1.gi_name = 'FingerprintAudit'
		AND	g1.gi_datein = (SELECT MAX(g2.gi_datein)
							  FROM generalinfo g2 (NOLOCK)
							  WHERE g2.gi_name = 'FingerprintAudit'
								AND g2.gi_datein <= GETDATE())) = 'Y'
	SET @UseFingerPrintAudit = 1
ELSE
	SET @UseFingerPrintAudit = 0

SELECT	@new_tractor = MIN(inserted.lgh_tractor),
	@new_lgh_outstatus = MIN(inserted.lgh_outstatus),
	@Ord = MIN(inserted.ord_hdrnumber),
	@Mov = MIN(inserted.mov_number),
	@Lgh_num = MIN(inserted.lgh_number)
FROM	inserted 

SELECT	@old_tractor = MIN(deleted.lgh_tractor),
		@old_lgh_outstatus = MIN(deleted.lgh_outstatus)
FROM	deleted 

--Update driver who had the assignment
IF @TM_UnAssignFormID > 0 AND (ISNULL(@old_tractor, 'UNKNOWN') != @new_tractor) -- OR @old_lgh_outstatus != @new_lgh_outstatus) 
	IF ( @old_tractor != 'UNKNOWN' ) AND ( ISNULL(@old_tractor, '') != '' ) -- AND (@new_lgh_outstatus = 'DSP') AND EXISTS (SELECT 1 from generalinfo where gi_name = 'tripchange' AND gi_string1 = 'legheader' and gi_string2 = 'lgh_carrier')
		BEGIN	
			SET @FilterData = 'AutoSendUA:' + CONVERT(VARCHAR(12), @Lgh_num)
			exec dbo.asyncmessage_sp 	@ord, 
						@Mov, 
						@Lgh_num,
						@old_tractor,
						4, --Tractor
						@TM_UnAssignFormID,
						@FilterData,
						@TM_UnAssignFormIDSubject,
						'lgh_number',
						@Lgh_num,
						30

			IF (@UseFingerPrintAudit = 1) 
				--Insert into fingerprint
				insert into expedite_audit
						(ord_hdrnumber
						,updated_by
						,activity
						,updated_dt
						,update_note
						,key_value
						,mov_number
						,lgh_number
						,join_to_table_name)
				  select isnull(@Ord, 0)
						,suser_sname()
						,'Auto Send UA'
						,GETDATE()
						,'Tractor ' + ltrim(rtrim(isnull(@old_tractor, 'null'))) + ' -> ' + 
							ltrim(rtrim(isnull(@new_tractor, 'null')))
						,convert(varchar(20), @Ord)
						,isnull(@Mov, 0)
						,0
						,'orderheader'
		END

--Send Load assignment to new driver
IF @TM_FormID > 0 AND (ISNULL(@old_tractor, '') != @new_tractor) -- OR @old_lgh_outstatus != @new_lgh_outstatus) 
	IF ( @new_tractor != 'UNKNOWN' ) AND ( ISNULL(@new_tractor, '') != '' ) -- AND (@new_lgh_outstatus = 'DSP') AND EXISTS (SELECT 1 from generalinfo where gi_name = 'tripchange' AND gi_string1 = 'legheader' and gi_string2 = 'lgh_carrier')
		BEGIN	

			SET @FilterData = 'AutoSendPA:' + CONVERT(VARCHAR(12), @Lgh_num)
			exec dbo.asyncmessage_sp 	@ord, 
						@Mov, 
						@Lgh_num,
						@new_tractor,
						4, --Tractor
						@TM_FormID,
						@FilterData,
						@TM_FormIDSubject,
						'lgh_number',
						@Lgh_num,
						30

			IF (@UseFingerPrintAudit = 1)
				--Insert into fingerprint
				insert into expedite_audit
						(ord_hdrnumber
						,updated_by
						,activity
						,updated_dt
						,update_note
						,key_value
						,mov_number
						,lgh_number
						,join_to_table_name)
				  select isnull(@Ord, 0)
						,suser_sname()
						,'Auto Send PA'
						,GETDATE()
						,'Tractor ' + ltrim(rtrim(isnull(@old_tractor, 'null'))) + ' -> ' + 
							ltrim(rtrim(isnull(@new_tractor, 'null')))
						,convert(varchar(20), @Ord)
						,isnull(@Mov, 0)
						,0
						,'orderheader'
		END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Trigger de cuando una orden es confirmada (DSP) y se envia numero de segmento para timbrar...

CREATE TRIGGER [dbo].[TRU_legDSP_JR] ON [dbo].[legheader]
AFTER UPDATE
AS


	DECLARE @ls_mov_number 	Integer,
		@ll_orden		 Integer,
		@ls_status		 Varchar(5),
		@ls_unidad		 Varchar(8),
		@ls_operador	 Varchar(8),
		@ls_mov_num_PLN	 Integer,
		@ll_orden_PLN	 Integer,
		@ls_status_PLN	 Varchar(5),
		@ls_unidad_PLN	 Varchar(8),
		@ls_operador_PLN Varchar(8),
		@ls_billto		 Varchar(8),
		@li_numsegmento	 Integer,
		@lm_totalcharge  money,
		@ls_ord_fromorder varchar(12)
		
IF UPDATE (lgh_outstatus)
BEGIN
			/* Se hace el select para obtener los datos que se estan actualizando */
		SELECT 	@ll_orden			= b.ord_hdrnumber,
				@ls_status			= b.lgh_outstatus, 
				@ls_unidad			= b.lgh_tractor,
				@ls_operador		= b.lgh_driver1,
				@li_numsegmento		= b.lgh_number
		FROM legheader a, INSERTED b
		WHERE   a.lgh_number = b.lgh_number

		select @lm_totalcharge = ord_totalcharge, @ls_billto = ord_billto,
		@ls_ord_fromorder = isnull(ord_fromorder,'NA') from orderheader where ord_hdrnumber = @ll_orden

		IF @ls_status = 'DSP' and @lm_totalcharge > 0.00 and @ls_ord_fromorder <> 'SAYER-VACIO'
			BEGIN	--1 status a STD (Empezado)
					----Busca el numero del segmento
					--	select @li_numsegmento = min(lgh_number) 
					--	from legheader where 
					--		 ord_hdrnumber = @ll_orden and 
					--		 lgh_driver1 = @ls_operador and 
					--		 lgh_tractor = @ls_unidad
						
						IF @li_numsegmento > 0
							BEGIN -- 3 cuando si hay un segmento valido se inserta en la tabla
								Insert segmentosportimbrar_JR(billto,segmento,estatus,observaciones, fecha )
								values(@ls_billto,@li_numsegmento,1,'TLH Seg de la orden:'+CAST(@ll_orden as varchar(10)),getdate()) 
							END -- 3 cuando si h|ay una orden en PLN
				--	END -- 2 cuando la unidad esta en QSP
			END--1 status a DSP
END -- 0 cuando el campo act es ord_status

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[ut_legheader_consolidated] ON [dbo].[legheader] 
FOR UPDATE
AS

/*	Revision History:
	Date		    Name			       Label     Description(New GI setting list)
	-----------	---------------	 --------- ----------------------------------------
	05/07/2001	Vern Jewett		             Added a check for NULL before attempting to insert expedite_audit row.
	01/17/2002  Matt B Roberts   PTS 12352 Added code to lgh_tractor update for the checkcall update.
  09/23/2002	Matt Zerefos     PTS 12673 Added code to create TM msg if leg criteria changes
	02/14/2003	Matt Zerefos		 PTS 12673 Removed all Meijer specific code
                               PTS 12969 send info to TMail when order changes (TMailTRCChangeFormID)
              vv               PTS 17428 Insert rows into stops_extract if legheader.lgh_type2 changes to 'SENT' that signifies that order is ready to be sent to CADEC will not work if order is created and immediately dispatched in VD 
  04/02/2003  RE?              PTS 17795 trailer comments (TrailerCommentsResetStatus)
  02/12/2004  Matt B Roberts   PTS 20988 (MaptuitGeocode, MaptuitDirectionsOnDispatch)
                               PTS 23359 add ability to send fuel with directions?
  03/18/2004  Matt B Roberts   PTS 19920 set some before/after statuses?
  03/25/2004  Matt B Roberts   PTS 22080 maptuit messages? (MaptuitAlert)
                               PTS 23359 add ability to send fuel with directions
  09/03/2004  CGK              PTS 23691 gettmwuser?
	06/08/2004	Matt Zerefos		 PTS 23405 lgh_tm_status update when changing tractor/driver (TMCancelOrderFormId)
                               PTS 24154 remove the send fuel option
  04/21/2005  Matt B Roberts   PTS 27660 Send new ob204 if carrier is an edi carrier and carrier is changing from unknown
  04/22/2005  Matt B Roberts   PTS 27662 Send cancellation ob204 if carrier is edi carrier and carrier is getting taken off a load and the load is now unassigned.
  07/06/2005  Matt B Roberts   PTS 28768 (ProcessOutbound204)
  12/05/2005  Matt B Roberts   PTS 30545 (LoadFileExport)
  	          Douc McRowe      PTS 31021 Set the Pay Status to the specified code if the specified condition exists(MinAssetAssignPayStatus)
	02/10/2006	Brian Hanson		 PTS 31123 insert table VIN_EVENT_EXPORT when Carrier changes.
  02/21/2006	Doug McRowe		   PTS 31864 Update the GeoFuelRequest record for the trip segemnt that is set to HOLD	
	03/27/2006  Matt B Roberts   PTS 32352 ReLoadExternalEquipment_sp (tripchange)
  05/02/2006  Matt B Roberts   PTS 32874 no idea - just listed in a useless pile of version comments
  05/12/2006	Brian Hanson		 PTS 32720 Allow copies orders to be not settled - 4/24/2006
	07/11/2006	Doug McRowe		   PTS 33550 Modify changes for 31021 to allow for other lgh_type codes.
  **********  **************** ********* ************************                             
	10/17/2006	Junhai Guo		   PTS 34308 consolidate and optimize trigger.
  **********  **************** ********* ************************                                                            
	11/20/2006	Doug McRowe		   PTS 35205 Modify the logic added for PTS 31864 to only update the Fuel Level when it was not manully entered.
	04/18/2007 	Brian Hanson		 PTS 36078 Moved functionality for PTS 31123 to ut_ord.
	06/20/2007  Doug McRowe			 PTS 36468	Added AVL to the list of 'from' status codes (LoadFileExport)
              JD               PTS 37857 reoded pts to remove a temp table from the trigger for SuperValu?  (SVStopsExtract)
	10/08/2007  Matt B Roberts   PTS 39756 Exec create_segment_output
  02/12/2008	Ron Eyink		  	 PTS 41378 Added SET NOCOUNT ON was causing problems with PB10.5's new DB driver
	04/21/2008  Doug McRowe			 PTS 40522	Tried to close up some 'holes' in the Loadfile export calls if the @old_lgh_outstatus is null., Added check for Null value incase the Deleted table does not exist (ie, it's a new Legheader)
  03/26/2009  JJF              PTS 46005 (ExternalEquipAutoReload)
	04/08/2009	Adam Rossman		 PTS 40745 lgh_204_tradingpartner 
                               PTS 43659 (UpdateCarrierCommitments)
	04/22/2009  Doug McRowe			 PTS 43872 Modified to support Round Trip Dispatch functionality for PTS 43872. (TRCRTDTracking)
	04/25/2009	JJF              PTS 46005 20090326 exec ReLoadExternalEquipment_sp (ExternalEquipAutoReload)
  07/16/2009  Matt B Roberst   PTS 53659 UpdateCarrierCommitments
	07/29/2009	Jim Teubner			 PTS 48417 added lgh_booked_revtype1 to the finger print audit (FingerprintAudit)
	09/23/2009	Doug McRowe			 PTS 49194 Add option in gi_string2 of existing 'ProcessFuelReqOnStart' GI setting to conrol which Trip status codes are required to set the request to 'Run'. (CreateNewRequestOnStart, ProcessFuelReqOnStart)
	09/29/2009  Matt B Roberts   PTS 48629 create_outbound204? (ProcessOutbound204)
  11/09/2009  Matt B Roberts   PTS 46536 outbound 204 rail billing (outbound204railbilling)
  03/22/2010  Doug McRowe	     PTS 51325 Update the Driver on a Checkcall when the Checkcall is changed from one leg to another based on the Tractor.  Need to also update the Driver on the Checkcall when we change the Tractor.
	01/31/2011	Jason Bauwin		 PTS 55467 Add functionality for automatic fuel card updates when driver changes interactive_fuel_update_sp
  05/17/2011  JJF              PTS 46682 If this leg has a child leg, and if the assets change, cancel the child order.
              Doug McRowe      PTS 56896 Driver Hours Worked calculations (UseDrivingHoursCalc)
  06/16/2011  JJF/MC           PTS 58773 added nolock to simple PK queries? and dispaudit/expedite_audit insert
	07/27/2011	Doug McRowe			 PTS 57896 Add option to call proc to calculate Driver hours fields.(UseDrivingHoursCalc)
	07/27/2011	Doug Mcrowe			 PTS 57799 Modifiy the RTD logic created in prior PTS 43872
	10/04/2011	Doug McRowe			 PTS 59362 Add option to create Fuel Requests when trip is started automatically.(ProcessFuelReqOnStart, CreateNewRequestOnStart)
  09/10/2012  DMA              PTS 61858 (ProcessOutbound204)
              NLOKE            PTS 62031 changes from Mindy to enhance performance
              JLB              PTS 62677 stp_AppointmentStatus - This is for CRE (NEW GI needed)
  09/10/2012  DMA              PTS 64334 (RequireAssignedTrailerEDI204)
              DMA              PTS 64434 create_outbound204
              Greg Kopp        PTS 66059 expedite_audit insert for other_status
  09/12/2012                   PTS 88288 (ProcessInteractiveTripUpdates)
  03/14/2013  Matt B Roberts   PTS 67912 (MinAssetAssignPayCode)
  11/26/2013  Mindy Curnutt		 PTS 73750 Add GI Setting to circumvent auditing of Tractor/Trailer change as concatenated text field in EA table.(FingerprintAudit)
	02/04/2014  Harry Abramowski PTS 73672 Fix Identity for INSERT INTO TMSQLMessageData
              RE               PTS 77738 optimization stuff
  11/17/2014  Mindy Curnutt		 PTS 84589 If an update fired but no rows were changed, get out of the trigger.
	03/26/2015  Mindy/DMcRowe		 PTS 86861
                               PTS 88288 (ProcessInteractiveTripUpdates)
  01/26/2016  Eric Blinn       PTS 98531 Complete rewrite for performance, formatting, multi-row udpates.
  02/20/2017  Dan Clemens                Adding proc splits


*/

--pts34308 prevent empty firing  
IF NOT EXISTS (SELECT TOP 1 1 FROM inserted) AND NOT EXISTS (SELECT TOP 1 1 FROM deleted) RETURN;

SET NOCOUNT ON;-- RE - PTS #41378

--PTS 62031 NLOKE changes from Mindy to enhance performance
SET TRANSACTION ISOLATION LEVEL READ uncommitted;
--end 62031

DECLARE 
  @mov_number INT
, @new_lgh_carrier VARCHAR(8)
, @old_lgh_carrier VARCHAR(8)
, @ord_reftype VARCHAR(6)
, @new_lgh_outstatus VARCHAR(6)
, @old_lgh_outstatus VARCHAR(6)
, @lgh_number INT
, @ord INT
, @new_tractor VARCHAR(8)
, @old_tractor VARCHAR(8)
, @lgh_tractor VARCHAR(8)
, @gps_latitude INT
, @gps_longitude INT
, @lat DECIMAL(7, 4)
, @long DECIMAL(7, 4)
, @movnum INT
, @m2qhid INT
, @ord_hdrnumber INT
, @endcity INT
, @lastcityname VARCHAR(18)
, @lastcitystate VARCHAR(6)
, @tractor VARCHAR(8)
, @driver VARCHAR(8)
, @driver2 VARCHAR(8)
, @external_type VARCHAR(6)
, @external_id INTEGER
, @TMFormId INT
, @ord_number VARCHAR(12)
, @old_driver VARCHAR(8)
, @old_driver2 VARCHAR(8)
, @new_driver VARCHAR(8)
, @tmstatus VARCHAR(8)
, @trc_fuellevel INT
, @geofuel_reqid INT
, @geofuel_gal_override INT
, @geofuel_fuel_level INT
, @lgh_204status VARCHAR(6)
, @new_recommended_car_id VARCHAR(8)
, @old_recommended_car_id VARCHAR(8)
, @old_lgh_tradingpartner VARCHAR(20) --PTS40745
, @new_lgh_tradingpartner VARCHAR(20) --PTS40745
, @old_lgh_startdate DATETIME
, @new_lgh_startdate DATETIME
, @lgh_booked_revtype1_label VARCHAR(60)
, @old_lgh_204validate INTEGER --PTS48629 MBR 09/29/09
, @new_lgh_204validate INTEGER --PTS48629 MBR 09/29/09
, @outbound204railbilling CHAR(1) --PTS46536 MBR 11/09/09
, @lgh_cmp_start VARCHAR(12) --PTS46536 MBR 11/09/09
, @lgh_cmp_end VARCHAR(12) --PTS46536 MBR 11/09/09
, @car_204flag INTEGER --PTS46536 MBR 11/09/09
, @car_type1 VARCHAR(6) --PTS46536 MBR 11/09/09
, @car_204update VARCHAR(3) --PTS46536 MBR 11/09/09
, @origin_rail CHAR(1) --PTS46536 MBR 11/09/09
, @dest_rail CHAR(1) --PTS46536 MBR 11/09/09
, @newleg INTEGER -- PTS 51325 - DJM
, @istartdate DATETIME -- PTS 57799 - DJM
, @CreateNewRequestOnStart CHAR(1) -- PTS 59362 - DJM
, @CreateNewRequstProc VARCHAR(100) -- PTS 59362 - DJM
, @RequireAssignedTrailerEDI204 CHAR(1) -- PTS 61858 DMA
, @old_trailer VARCHAR(13) -- PTS 61858 DMA
, @trailer VARCHAR(13) -- PTS 61858 DMA
, @edi204Created CHAR(1) -- PTS 61858 DMA
, @edi204CarTypeField VARCHAR(60) -- PTS 64334 DMA - Tells what carrier profile field to look for values 
, @edi204CarTypes VARCHAR(60) -- PTS 64334 DMA - Tells what values in the above field that will send out a 204
, @donotpay_status AS VARCHAR(6)
, @donotpay_type AS VARCHAR(6)
, @donotpay_field AS VARCHAR(20)
, @changecount AS INT
, @send_204 CHAR(1)
, @check4trailer CHAR(1)
, @lastcarrier204 VARCHAR(8)
, @StartDate DATETIME
, @CkcCount INT
, @IDENT INT
, @TMailTRCChangeFormID INT
, @mov INT
, @lgh INT
, @delete CHAR(1)
, @trc VARCHAR(8)
, @outstatus VARCHAR(6)
, @lgh_dsp_date DATETIME
, @old_outstatus VARCHAR(6)
, @newtrc VARCHAR(8)
, @IDENT2 INT
, @ord_hdrn INT
, @lgh_num INT
, @RTD_lghtype VARCHAR(10)
, @RTD_value VARCHAR(12)
, @RTD_ignore VARCHAR(12)
, @updated INT
, @rtdid INT
, @typevalue VARCHAR(12)
, @trcid VARCHAR(13)
, @oo_trc VARCHAR(10)
, @RTD_startdate DATETIME
, @PriorLghDate DATETIME
, @trcchanged CHAR(1)
, @insertrc VARCHAR(13)
, @deltrc VARCHAR(13)
, @driver1 VARCHAR(8)
, @curleg INT
, @lghstatus VARCHAR(6)
, @route_dt DATETIME
, @COUNT INT
, @procAction VARCHAR(6)
, @gf_request INT
, @ProcessOutbound204 CHAR(1); 

/*dclemens 2017-02-21 declare & fill our tblvars that will get passed as TVPs */
 DECLARE @inserted UtLegheaderConsolidated
	,@deleted UtLegheaderConsolidated;

INSERT INTO @inserted (
	lgh_number
	,lgh_startdate
	,lgh_outstatus
	,stp_number_start
	,cmp_id_start
	,cmp_id_end
	,lgh_driver1
	,lgh_driver2
	,lgh_tractor
	,lgh_primary_trailer
	,mov_number
	,ord_hdrnumber
	,lgh_type1
	,lgh_primary_pup
	,lgh_carrier
	,lgh_dsp_date
	,lgh_dispatchdate
	,lgh_type2
	,lgh_tm_status
	,lgh_type3
	,lgh_type4
	,lgh_204status
	,lgh_booked_revtype1
	,lgh_recommended_car_id
	,lgh_204_tradingpartner
	,lgh_204validate
  ,lgh_other_status1
  ,lgh_other_status2
	)
SELECT lgh_number
	,lgh_startdate
	,lgh_outstatus
	,stp_number_start
	,cmp_id_start
	,cmp_id_end
	,lgh_driver1
	,lgh_driver2
	,lgh_tractor
	,lgh_primary_trailer
	,mov_number
	,ord_hdrnumber
	,lgh_type1
	,lgh_primary_pup
	,lgh_carrier
	,lgh_dsp_date
	,lgh_dispatchdate
	,lgh_type2
	,lgh_tm_status
	,lgh_type3
	,lgh_type4
	,lgh_204status
	,lgh_booked_revtype1
	,lgh_recommended_car_id
	,lgh_204_tradingpartner
	,lgh_204validate
  ,lgh_other_status1
  ,lgh_other_status2
FROM inserted

INSERT INTO @deleted (
	lgh_number
	,lgh_startdate
	,lgh_outstatus
	,stp_number_start
	,cmp_id_start
	,cmp_id_end
	,lgh_driver1
	,lgh_driver2
	,lgh_tractor
	,lgh_primary_trailer
	,mov_number
	,ord_hdrnumber
	,lgh_type1
	,lgh_primary_pup
	,lgh_carrier
	,lgh_dsp_date
	,lgh_dispatchdate
	,lgh_type2
	,lgh_tm_status
	,lgh_type3
	,lgh_type4
	,lgh_204status
	,lgh_booked_revtype1
	,lgh_recommended_car_id
	,lgh_204_tradingpartner
	,lgh_204validate
  ,lgh_other_status1
  ,lgh_other_status2
	)
SELECT lgh_number
	,lgh_startdate
	,lgh_outstatus
	,stp_number_start
	,cmp_id_start
	,cmp_id_end
	,lgh_driver1
	,lgh_driver2
	,lgh_tractor
	,lgh_primary_trailer
	,mov_number
	,ord_hdrnumber
	,lgh_type1
	,lgh_primary_pup
	,lgh_carrier
	,lgh_dsp_date
	,lgh_dispatchdate
	,lgh_type2
	,lgh_tm_status
	,lgh_type3
	,lgh_type4
	,lgh_204status
	,lgh_booked_revtype1
	,lgh_recommended_car_id
	,lgh_204_tradingpartner
	,lgh_204validate
  ,lgh_other_status1
  ,lgh_other_status2
FROM deleted


UPDATE a SET ord_number = b.ord_number FROM @inserted a INNER JOIN dbo.orderheader b ON a.ord_hdrnumber = b.ord_hdrnumber
UPDATE a SET ord_number = b.ord_number FROM @deleted a INNER JOIN dbo.orderheader b ON a.ord_hdrnumber = b.ord_hdrnumber

DECLARE @edi204CarTypeStrings TABLE(
  string NVARCHAR(512));

DECLARE @GI_VALUES_TO_LOOKUP TABLE (
  gi_name VARCHAR(30) PRIMARY KEY);

DECLARE @GIKEY TABLE (
  gi_name     VARCHAR(30) PRIMARY KEY
, gi_string1  VARCHAR(60)
, LEFTgi_string1 CHAR(1)--This is nonstandard.  Beware.
, gi_string2  VARCHAR(60)
, gi_string3  VARCHAR(60)
, gi_string4  VARCHAR(60)
, gi_integer1 INT
, gi_integer2 INT
, gi_integer3 INT
, gi_integer4 INT
, gi_date1 DATETIME );

INSERT @GI_VALUES_TO_LOOKUP
VALUES
  --Replace these lookups with value(s) that match your needs.
  ('outbound204railbilling')
, ('CreateNewRequestOnStart')
, ('ExternalEquipAutoReload')
, ('FingerprintAudit')
, ('LoadFileExport')
, ('MaptuitAlert')
, ('MaptuitDirectionsOnDispatch')
, ('Maptuitgeocode')
, ('MinAssetAssignPayStatus')
, ('OrderEventExport')
, ('ProcessFuelReqOnStart')
, ('ProcessInteractiveTripUpdates')
, ('ProcessOutbound204')
, ('RequireAssignedTrailerEDI204')
, ('SVStopsExtract')
, ('TMailTRCChangeFormID')
, ('TMCancelOrderFormId')
, ('TrackTRCRTD')
, ('TrailerCommentsResetStatus')
, ('TRCRTDTracking')
, ('tripchange')
, ('UpdateCarrierCommitments')
, ('UseDrivingHoursCalc')
, ('UT_LHG_OPTIMIZATION')
, ('UT_LHG_APPT_STUS')
, ('MinAssetAssignPayCode');

 

INSERT @GIKEY 
SELECT 
  gi_name
, gi_string1
, LEFTgi_string1 --This is nonstandard.  Beware.
, gi_string2
, gi_string3
, gi_string4
, gi_integer1
, gi_integer2
, gi_integer3
, gi_integer4
, gi_date1
FROM (
      SELECT 
        gvtlu.gi_name
      , g.gi_string1
      , LEFT(LTRIM(g.gi_string1), 1) LEFTgi_string1 --This is nonstandard.  Beware.
      , g.gi_string2
      , g.gi_string3 
      , g.gi_string4
      , gi_integer1
      , gi_integer2
      , gi_integer3
      , gi_integer4
      , gi_date1
       --What we're doing here is checking the date of the generalInfo row in case there are multiples.
       --This will order the rows in descending date order with the following exceptions.
       --Future dates are dropped to last priority by moving to less than the apocalypse.
       --Nulls are moved to second to last priority by using the apocalypse.
       --Everything else is ordered descending.
       --We then take the "newest".
      , ROW_NUMBER() OVER (PARTITION BY gvtlu.gi_name ORDER BY CASE WHEN g.gi_datein > GETDATE() THEN '1/1/1949' ELSE ISNULL(g.gi_datein, '1/1/1950') END DESC) RN 
      FROM 
        @GI_VALUES_TO_LOOKUP gvtlu
          LEFT OUTER JOIN 
        dbo.generalinfo g ON gvtlu.gi_name = g.gi_name) subQuery
WHERE
  RN = 1;--   <---This is how we take the top 1.
  
--**************************************************************************--
---------------------------Fingerprint only section---------------------------
--**************************************************************************--
/*dclemens 2017-01-27 SPLIT16 BEGIN*/
IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'FingerprintAudit' AND LEFTgi_string1 = 'Y')
BEGIN
EXEC lgh_cons_tr_FPrintTBranch_sp @inserted, @deleted
END
/*dclemens 2017-01-27 SPLIT16 END*/

--**************************************************************************--
-------------------------end Fingerprint only section-------------------------
--**************************************************************************--



--**************************************************************************--
-----------------------Start CarrierCommitments section-----------------------
--**************************************************************************--

--PTS43659 MBR 07/16/09
/*dclemens 2017-01-27 SPLIT07 BEGIN*/
IF UPDATE(lgh_startdate) OR UPDATE(lgh_carrier) OR UPDATE(lgh_recommended_car_id)
     AND
   EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'UpdateCarrierCommitments' AND LEFTgi_string1 = 'Y')
BEGIN
 EXEC dbo.lgh_cons_tr_updatecarcomm_sp @inserted,@deleted
END;

/*dclemens 2017-01-27 SPLIT07 END*/
--**************************************************************************--
------------------------End CarrierCommitments section------------------------
--**************************************************************************--
--**************************************************************************--
-------------------------------No limit section-------------------------------
--**************************************************************************--

/*dclemens 2017-01-27 SPLIT15 BEGIN*/
IF UPDATE(lgh_outstatus)
BEGIN

EXEC dbo.lgh_cons_tr_TrlComntsResetStatus_sp @inserted,@deleted

END;

/*dclemens 2017-01-27 SPLIT15 END*/

--PTS32352 MBR 03/27/06
--PTS32874 MBR 05/02/06
--PTS36468 DJM 06/20/07 - Added AVL to the list of 'from' status codes and CMP to the list of new status codes.
--PTS 40522 - DJM - Added check for Null value incase the Deleted table does not exist (ie, it's a new Legheader)
IF EXISTS (SELECT 1 FROM @GIKEY WHERE gi_name = 'LoadFileExport' AND LEFTgi_string1 = 'Y')
     OR 
   EXISTS (SELECT 1 FROM @GIKEY WHERE gi_name = 'ExternalEquipAutoReload' AND LEFTgi_string1 = 'Y')
BEGIN

  DECLARE LegStartedCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT
    i.lgh_number
  FROM
    inserted i
      INNER JOIN
    deleted d ON i.lgh_number = d.lgh_number
  WHERE
    i.lgh_outstatus IN ('STD', 'CMP') 
      AND
    ISNULL(d.lgh_outstatus, 'AVL') IN ('PLN', 'DSP', 'AVL');
  
  OPEN LegStartedCursor;
  FETCH NEXT FROM LegStartedCursor INTO @lgh_number;
  
  WHILE @@FETCH_STATUS = 0
  BEGIN
    --We double check this GI Key because we only want to declare the cursor if one or both are true.
    --But once we get here we aren't sure if one or both are actually on.
    IF EXISTS (SELECT 1 FROM @GIKEY WHERE gi_name = 'LoadFileExport' AND LEFTgi_string1 = 'Y')
    BEGIN
      EXEC create_segment_output @lgh_number, 'N', 'N';
    END;

    --PTS 46005 JJF 20090326
    IF EXISTS(SELECT gi_string1 FROM @GIKEY WHERE gi_name = 'ExternalEquipAutoReload' AND gi_string1 = 'Y')
    BEGIN
      EXEC ReLoadExternalEquipment_sp @lgh_number;
    END;
    FETCH NEXT FROM LegStartedCursor INTO @lgh_number;
  END;

  CLOSE LegStartedCursor;
  DEALLOCATE LegStartedCursor;
END;

/*dclemens 2017-01-27 SPLIT06 BEGIN*/
IF UPDATE(lgh_carrier) OR UPDATE(lgh_outstatus) OR UPDATE(lgh_carrier) --We're stair stepping here in hopes to avoid doing some of the later queries altogether.
BEGIN
  IF EXISTS(SELECT --we can't use GI_Key here because there are 3 disctinct string2's with the same gi_name that we want to check.
              1
            FROM  
              dbo.generalinfo
            WHERE  
              gi_name = 'tripchange' 
                AND
              gi_string1 = 'legheader'
                AND
              gi_string2 IN ('lgh_carrier', 'lgh_outstatus','lgh_carrier'))
  BEGIN

    EXEC dbo.lgh_cons_tr_tripchange_sp @inserted,@deleted

  END;--Includes one or the other trip change GI
END;--UPDATE(lgh_carrier) OR UPDATE(lgh_outstatus)
/*dclemens 2017-01-27 SPLIT06 END*/

/*dclemens 2017-01-27 SPLIT02 BEGIN*/
IF EXISTS (	SELECT 1 FROM @GIKEY	WHERE gi_name = 'Maptuitgeocode' and LEFTgi_string1 = 'Y'	)
BEGIN
	EXEC lgh_cons_tr_Maptuit_sp @inserted,@deleted
  
END
/*dclemens 2017-01-27 SPLIT02 END*/

/*  PTS12352 MBR 1/17/02 Added code to lgh_tractor update for the checkcall update.  */
IF UPDATE(lgh_tractor)
BEGIN

  --If you have changed the tractor and you aren't assigning for the first time.
  IF EXISTS(SELECT 
             TOP 1 1
            FROM 
              inserted i
                INNER JOIN
              deleted d ON i.lgh_number = d.lgh_number
            WHERE
              d.lgh_tractor <> i.lgh_tractor
                AND
              d.lgh_tractor <> 'UNKNOWN')
              
  BEGIN
    --Are there checkcalls associated to the old tractor and current leg
    DECLARE @LegTable TABLE(
      CurrentLghNumber INT
    , oldTractor VARCHAR(8)
    , minckcdate datetime2(3)
    , PreviousLghNumber INT)

    INSERT @LegTable (
      CurrentLghNumber
    , oldTractor
    , minckcdate)
    SELECT 
      i.lgh_number
    , d.lgh_tractor
    , MIN(ckc_date) as min_ckc_date
    FROM 
      inserted i
        INNER JOIN
      deleted d ON i.lgh_number = d.lgh_number
        INNER JOIN
      dbo.checkcall c ON i.lgh_number = c.ckc_lghnumber AND d.lgh_tractor = c.ckc_tractor
    GROUP BY 
      i.lgh_number
    , d.lgh_tractor;
    

    
    IF @@ROWCOUNT > 0
    BEGIN
      
      -- PTS 51325 - DJM - Need to also update the Driver on the Checkcall when we change the Tractor.
      UPDATE 
        a
      SET
        PreviousLghNumber = b.lgh_number
      FROM
       @LegTable a
         INNER JOIN
       (SELECT 
          b.CurrentLghNumber
        , a.lgh_number
        , ROW_NUMBER() OVER (ORDER BY asgn_date DESC) as RowRank
        FROM
          dbo.assetassignment a
            INNER JOIN
          @LegTable b ON a.asgn_id = b.oldTractor AND a.asgn_date < b.minckcdate AND a.lgh_number <> b.CurrentLghNumber
        WHERE 
          a.asgn_type = 'TRC') b ON a.CurrentLghNumber = b.CurrentLghNumber AND b.RowRank = 1
                    
      UPDATE 
        dbo.checkcall
      SET 
        ckc_asgnid = a.lgh_driver1
      FROM
        dbo.legheader a
          INNER JOIN
        @LegTable b ON a.lgh_number = b.PreviousLghNumber
      WHERE 
        ckc_asgntype = 'DRV'
          AND 
        ckc_tractor = b.oldTractor
          AND 
        ckc_lghnumber = b.CurrentLghNumber;

      UPDATE 
        dbo.checkcall
      SET 
        ckc_lghnumber = PreviousLghNumber
      FROM
        @LegTable a
      WHERE 
        ckc_tractor = a.oldTractor
          AND
        ckc_lghnumber = a.CurrentLghNumber;
      
    END;--IF @@ROWCOUNT > 0 (Are there checkcalls associated to the old tractor and current leg)
  END;----If you have changed the tractor and you aren't assigning for the first time.


  --PTS30545 MBR 12/05/05
  IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'LoadFileExport' AND LEFTgi_string1 = 'Y')
  BEGIN
    --PTS39756 MBR 10/08/07
    DECLARE @param2 CHAR(1) --I have no idea what this is.  Hence the bad name.

    --If you have definitely changed the tractor
    DECLARE LegCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT 
      i.lgh_number
    , CASE WHEN i.lgh_outstatus = 'CMP' THEN 'Y' ELSE 'N' END
    FROM 
      inserted i
        INNER JOIN
      deleted d ON i.lgh_number = d.lgh_number
    WHERE
      d.lgh_tractor <> i.lgh_tractor

    OPEN LegCursor
    FETCH NEXT FROM LegCursor INTO @lgh_number, @param2

    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC create_segment_output @lgh_number, 'N', @param2;
      FETCH NEXT FROM LegCursor INTO @lgh_number, @param2
    END;--WHILE @@FETCH_STATUS = 0
  END;--IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'LoadFileExport' AND LEFTgi_string1 = 'Y')
END;--UPDATE(lgh_tractor)



--ERICNOTE -- not 100% on this one.  Is that outputed table join specific enough?
-- Change the lgh_tm_status to NOSENT
UPDATE dbo.legheader
SET lgh_tm_status = 'NOSENT'
WHERE lgh_number IN (
		                SELECT i.lgh_number
		                FROM @inserted i
                      INNER JOIN @deleted d ON i.lgh_number = d.lgh_number
                      WHERE 
                        (d.lgh_tractor <> i.lgh_tractor OR d.lgh_driver1 <> i.lgh_driver1)
	                      AND i.lgh_outstatus IN ('AVL', 'PLN', 'DSP')
	                      AND ISNULL(i.lgh_tm_status, '') <> 'NOSENT');
/*  PTS23405 MZ 06/08/04 lgh_tm_status update when changing tractor/driver */

IF EXISTS (
		SELECT 1
		FROM @inserted i
      INNER JOIN @deleted d on i.lgh_number = d.lgh_number
		WHERE 
      ISNULL(d.lgh_tm_status, 'NOSENT') <> 'NOSENT'
        AND
      (d.lgh_tractor <> i.lgh_tractor OR d.lgh_driver1 <> i.lgh_driver1)
	      AND 
      i.lgh_outstatus IN ('AVL', 'PLN', 'DSP')
        AND
      i.lgh_tractor <> '')
BEGIN
	-- If it originally was some status other than Not Sent.
	-- Send the Cancel Order message to the driver if set up to do so.
	SELECT @TMFormId = ISNULL(gi_integer1, 0)
	FROM @GIKEY
	WHERE gi_name = 'TMCancelOrderFormId';

	IF @TMFormId > 0
	BEGIN
		/*dclemens 2017-01-27 SPLIT11 BEGIN*/
		EXEC dbo.lgh_cons_tr_TMCancelOrderFormId_sp @inserted, @deleted ,@TMFormId
		/*dclemens 2017-01-27 SPLIT11 END*/

	END;--IF @TMFormId > 0 AND EXISTS(SELECT TOP 1 1 FROm @LegTMStatus WHERE lgh_tractor <> '')
END;---- If it originally was some status other than Not Sent.


--PTS30545 MBR 12/05/05
IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'LoadFileExport' AND LEFTgi_string1 = 'Y')
     AND
   EXISTS(SELECT 
            1 
          FROM 
            inserted i
              INNER JOIN
            deleted d ON i.lgh_number = d.lgh_number
          WHERE
            i.lgh_driver1 <> d.lgh_driver1
              AND
            d.lgh_driver1 IS NOT NULL)     
BEGIN
  EXEC create_segment_output @lgh_number, 'N', 'N';
END;

--PTS67912 MBR 03/14/13
IF UPDATE(lgh_spot_rate)
BEGIN
  UPDATE 
    dbo.legheader
  SET 
    lgh_spot_rate_updatedby = SUSER_NAME()
  , lgh_spot_rate_updateddt = GETDATE()
  FROM
    inserted i
  WHERE
    i.lgh_number = legheader.lgh_number;
END;

/*dclemens 2017-02-20 SPLIT03 BEGIN */

/* PTS 31021 - DJM - Set the Pay Status to the specified code if the specified condition exists    */
IF EXISTS (SELECT gi_string1 FROM @GIKEY WHERE gi_name = 'MinAssetAssignPayCode' AND LEFTgi_string1 = 'Y')
BEGIN

EXEC lgh_cons_MinAssetAssignPayStatus_sp @inserted	,@deleted

END
/*dclemens 2017-02-20 SPLIT03 END */
  
--This is used repeatedly through the proc so we're going to store it all alone.
--PTS46536 MBR 11/09/09
SELECT 
  @outbound204railbilling = ISNULL(LEFTgi_string1, 'N')
FROM 
  @GIKEY
WHERE 
  gi_name = 'outbound204railbilling';
--**************************************************************************--
-----------------------------end No limit section-----------------------------
--**************************************************************************--

SELECT  
  @new_lgh_carrier = i.lgh_carrier
, @new_lgh_outstatus = i.lgh_outstatus
, @new_lgh_startdate = i.lgh_startdate
, @new_recommended_car_id = ISNULL(i.lgh_recommended_car_id, 'UNKNOWN')
, @old_lgh_carrier = d.lgh_carrier
, @old_lgh_outstatus = ISNULL(d.lgh_outstatus, 'AVL')
, @old_lgh_startdate = d.lgh_startdate
, @old_recommended_car_id = ISNULL(d.lgh_recommended_car_id, 'UNKNOWN')
, @new_lgh_tradingpartner = ISNULL(i.lgh_204_tradingpartner,'UNKNOWN')      --PTS #40745
, @old_lgh_tradingpartner = ISNULL(d.lgh_204_tradingpartner,'UNKNOWN')
, @new_lgh_204validate = ISNULL(i.lgh_204validate, 1)
, @old_lgh_204validate = ISNULL(d.lgh_204validate, 1)
, @lgh_cmp_start = ISNULL(i.cmp_id_start, 'UNKNOWN')
, @lgh_cmp_end = ISNULL(i.cmp_id_end, 'UNKNOWN')
, @lgh_204status = i.lgh_204status
, @old_trailer = ISNULL(d.lgh_primary_trailer,'UNKNOWN')
, @trailer = ISNULL(i.lgh_primary_trailer,'UNKNOWN')
, @ord_reftype = o.ord_reftype
, @movnum = i.mov_number
, @lgh_tractor = i.lgh_tractor
, @ord_hdrnumber = i.ord_hdrnumber
, @endcity = i.lgh_endcity
FROM  
  inserted i
    INNER JOIN
  deleted d ON i.lgh_number = d.lgh_number
    INNER JOIN
  orderheader o ON o.mov_number = i.mov_number;

-- PTS64334 DMA 9/10/2012, PTS61858
SET @edi204Created = 'N';
SET @RequireAssignedTrailerEDI204 = 'N';
SET @edi204CarTypeField = '';
SET @edi204CarTypes = '';
SET @send_204 = 'N';

SELECT 
  @RequireAssignedTrailerEDI204 = ISNULL(LEFTgi_string1, 'N')
, @edi204CarTypeField = ISNULL(gi_string2, '')
, @edi204CarTypes = ISNULL(gi_string3, '')
FROM 
  @GIKEY 
WHERE
  gi_name = 'RequireAssignedTrailerEDI204';


SELECT 
  @ProcessOutbound204 = ISNULL(LEFTgi_string1, 'N')
FROM 
  @GIKEY 
WHERE
  gi_name = 'ProcessOutbound204';

IF (@ProcessOutbound204 = 'Y' )

/*dclemens 2017-02-20 SPLIT01 BEGIN */

BEGIN

EXEC dbo.lgh_con_tr_EDI204_sp @inserted, @deleted

END

/*dclemens 2017-02-20 SPLIT01 END */

/*dclemens 2017-02-20 SPLIT08 BEGIN */

IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'ProcessFuelReqOnStart' AND ISNULL(LEFTgi_string1,'N') = 'Y')
     AND
   UPDATE(lgh_outstatus)
BEGIN

EXEC dbo.lgh_cons_tr_requestonstart_sp @inserted,@deleted

END;-- EXISTS(SELECT TOP 1 1 FRom @GIKEY WHERE gi_name = 'ProcessFuelReqOnStart' AND ISNULL(LEFTgi_string1,'N') = 'Y')     AND   UPDATE(lgh_outstatus)

/*dclemens 2017-02-20 SPLIT08 END */


/*dclemens 2017-01-27 SPLIT09 BEGIN*/

SELECT @TMailTRCChangeFormID = CASE 
		WHEN gi_string1 NOT LIKE N'%[^0-9]%'
			AND LEN(gi_string1) > 0
			THEN CAST(gi_string1 AS INT)
		ELSE 0
		END
FROM @GIKEY
WHERE gi_name = 'TMailTRCChangeFormID';

--only run for singe row updates
IF (SELECT COUNT(*) FROM inserted) = 1
	AND 
   (SELECT COUNT(*)	FROM deleted) = 1
	AND @TMailTRCChangeFormID > 0
BEGIN
	EXEC lgh_cons_tr_tmtrcchange_sp @inserted, @deleted	,@TMailTRCChangeFormID
END;

/*dclemens 2017-01-27 SPLIT09 END*/

/*dclemens 2017-01-27 SPLIT10 BEGIN*/

IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'SVStopsExtract' AND LEFTgi_string1 = 'Y')
BEGIN

  IF EXISTS(SELECT 1 FROM inserted WHERE lgh_type2 = 'SENT')  AND
     EXISTS(SELECT 1 FROM deleted WHERE lgh_type2 <> 'SENT')  AND 
     EXISTS(SELECT 1  FROM inserted where lgh_dsp_date IS NULL ) 
  BEGIN

  EXEC lgh_cons_tr_SVStopsExtract_sp @inserted,@deleted

  END;
 
END;

/*dclemens 2017-01-27 SPLIT10 END*/

/*PTS 43872 - DJM - Round Trip Dispatch*/

/*dclemens 2017-01-27 SPLIT04 BEGIN*/
IF EXISTS (
		SELECT 1
		FROM @GIKEY
		WHERE gi_name = 'TrackTRCRTD'
			AND LEFTgi_string1 = 'Y'
		)
BEGIN
	EXEC dbo.lgh_con_tr_trcrtdtracking_sp @inserted ,@deleted
END;
-- End 43872
/*dclemens 2017-01-27 SPLIT04 END*/

/*  
*  PTS 56896 - DJM - Driver Hours Worked calculations. Uses the proc "drv_service_hrs_calc_sp" to perform the
*    actual calculation.  This just determines if it should be calculated for the Legheader record.
*/
IF EXISTS(SELECT 1 FROM @GIKEY WHERE gi_name = 'UseDrivingHoursCalc' AND gi_string1 = 'Y')
BEGIN

  SELECT @curleg = MIN(lgh_number) FROM inserted i;
  
  WHILE @curleg > 0 
  BEGIN
    
    SELECT @lghstatus = lgh_outstatus FROM inserted WHERE lgh_number = @curleg;
     
    IF (@lghstatus) = 'CMP'
    BEGIN
            
      SELECT 
        @driver1 = ISNULL(i.lgh_driver1,'UNKNOWN')
      , @driver2 = ISNULL(i.lgh_driver2,'UNKNOWN')
      FROM 
        inserted i
      WHERE 
        lgh_number = @curleg;
          
      IF @driver1 <> 'UNKNOWN'
      BEGIN
        EXEC drv_service_hrs_calc_sp @curleg, @driver1;
      END;
          
      IF @driver2 <> 'UNKNOWN'
      BEGIN
        EXEC drv_service_hrs_calc_sp @curleg, @driver2;
      END;
            
      --Clean up.  In case they change the Driver remove any records from the table.
      DELETE 
        dbo.legheader_driver_hours
      WHERE 
        lgh_number = @curleg
          AND 
        mpp_id <> @driver1
          AND 
        mpp_id <> @driver2;
              
    END;
              
    SELECT @curleg = ISNULL(MIN(lgh_number),0) FROM inserted WHERE lgh_number > @curleg;

  END;-- End loop of legs in the Inserted buffer.
END;
-- End 56896

--ERB PTS 93230 --Added IF block to stop empty trigger fires
IF EXISTS (SELECT 1	FROM @GIKEY	WHERE gi_name = 'UT_LHG_APPT_STUS' AND LEFTgi_string1 = 'Y')
BEGIN
	--ERB PTS 93230 --Added IF block to stop empty trigger fires
	UPDATE stops
	SET stp_AppointmentStatus = 'R'
	FROM inserted i
	JOIN deleted d ON d.lgh_number = i.lgh_number
	WHERE i.lgh_other_status1 = 'R'
		AND d.lgh_other_status1 <> 'R'
		AND stops.lgh_number = i.lgh_number
		AND stops.stp_status = 'OPN'
		AND (
			stops.stp_type = 'DRP'
			OR stops.stp_type = 'PUP'
			)
END --start / end 93230
	--end 62677
/*dclemens 2017-01-27 SPLIT20 BEGIN*/
IF EXISTS (	SELECT 1 FROM @GIKEY WHERE gi_name = 'UT_LHG_OPTIMIZATION' and LEFTgi_string1 = 'Y')
BEGIN
  -- RE - PTS77738 - BEGIN
  IF (UPDATE(lgh_tractor) OR UPDATE(lgh_driver1) OR UPDATE(lgh_driver2) OR UPDATE(lgh_carrier)) AND NOT UPDATE(lgh_optimizationdate)
  BEGIN
   EXEC dbo.lgh_cons_tr_Optimization_sp @inserted, @deleted
  END;
END;
-- RE - PTS77738 - END
/*dclemens 2017-01-27 SPLIT20 END*/

-- PTS 88288
/*dclemens 2017-01-27 SPLIT05 BEGIN*/
IF EXISTS(SELECT * FROM @GIKEY WHERE gi_name = 'ProcessInteractiveTripUpdates' AND ((LEFTgi_string1 = 'Y') OR (LEFT(LTRIM(gi_string2), 1) = 'Y') OR (LEFT(LTRIM(gi_string3), 1) = 'Y')))
BEGIN
  EXEC dbo.lgh_cons_tr_ProcessIntTrUpd_sp @inserted, @deleted
  END;
/*dclemens 2017-01-27 SPLIT05 END*/
GO
ALTER TABLE [dbo].[legheader] ADD CONSTRAINT [pk_legheader_lgh_number] PRIMARY KEY NONCLUSTERED ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [d_lgh_active_class1] ON [dbo].[legheader] ([lgh_active], [lgh_class1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_lgh_booked_revtype] ON [dbo].[legheader] ([lgh_booked_revtype1], [lgh_carrier]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_carrier_enddate] ON [dbo].[legheader] ([lgh_carrier], [lgh_enddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_class3] ON [dbo].[legheader] ([lgh_class3], [ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_driver1] ON [dbo].[legheader] ([lgh_driver1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_lh_dr1_outst_stdt] ON [dbo].[legheader] ([lgh_driver1], [lgh_outstatus], [lgh_startdate] DESC) INCLUDE ([lgh_tm_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_lh_dr2_outst_stdt] ON [dbo].[legheader] ([lgh_driver2], [lgh_outstatus], [lgh_startdate] DESC) INCLUDE ([lgh_tm_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_leg_lghdriver2_lghstartdate] ON [dbo].[legheader] ([lgh_driver2], [lgh_startdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_enddate] ON [dbo].[legheader] ([lgh_enddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_etaalert1] ON [dbo].[legheader] ([lgh_etaalert1] DESC, [lgh_active]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_legheader_lgh_laneid] ON [dbo].[legheader] ([lgh_laneid]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [headernumber] ON [dbo].[legheader] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_outstat_active_instat_tractor_lghnum] ON [dbo].[legheader] ([lgh_outstatus], [lgh_active], [lgh_instatus], [lgh_tractor], [lgh_number]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_status] ON [dbo].[legheader] ([lgh_outstatus], [lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_plandate] ON [dbo].[legheader] ([lgh_plandate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_lh_prtrl_outst] ON [dbo].[legheader] ([lgh_primary_trailer], [lgh_outstatus], [lgh_startdate]) INCLUDE ([lgh_tm_status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_lgh_refnum] ON [dbo].[legheader] ([lgh_refnum]) INCLUDE ([lgh_endcity], [fgt_description], [ord_hdrnumber], [lgh_reftype]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_legheader_lgh_refnum] ON [dbo].[legheader] ([lgh_reftype], [lgh_refnum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_leg_lghstartdate_lghenddate] ON [dbo].[legheader] ([lgh_startdate], [lgh_enddate]) INCLUDE ([lgh_driver2], [lgh_tractor]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_lh_stdt_outstat] ON [dbo].[legheader] ([lgh_startdate], [lgh_outstatus]) INCLUDE ([lgh_class1], [lgh_class2], [lgh_class3], [lgh_class4], [mpp_teamleader], [mpp_fleet], [mpp_division], [mpp_domicile], [mpp_company], [mpp_type1], [mpp_type2], [mpp_type3], [mpp_type4], [trc_company], [trc_division], [trc_fleet], [trc_terminal], [trc_type1], [trc_type2], [trc_type3], [trc_type4]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [lgh_tour_index] ON [dbo].[legheader] ([lgh_tour_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tractor_active] ON [dbo].[legheader] ([lgh_tractor], [lgh_active]) INCLUDE ([lgh_enddate], [lgh_outstatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tractor] ON [dbo].[legheader] ([lgh_tractor], [lgh_outstatus], [lgh_instatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TractorDates] ON [dbo].[legheader] ([lgh_tractor], [lgh_startdate], [lgh_enddate]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_lgh_updatedon_lgh_number] ON [dbo].[legheader] ([lgh_updatedon], [lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_legheader_ma_tran_tour] ON [dbo].[legheader] ([ma_transaction_id], [ma_tour_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_mov] ON [dbo].[legheader] ([mov_number], [lgh_startcity], [lgh_endcity], [lgh_booked_revtype1]) INCLUDE ([lgh_outstatus], [lgh_startdate], [lgh_enddate], [lgh_type1], [lgh_type2], [lgh_schdtearliest], [lgh_schdtlatest], [lgh_carrier]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_legheader_ord_hdrnumber] ON [dbo].[legheader] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_shift_ss_id] ON [dbo].[legheader] ([shift_ss_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Legheader_timestamp] ON [dbo].[legheader] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legheader] TO [public]
GO
GRANT INSERT ON  [dbo].[legheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legheader] TO [public]
GO
GRANT SELECT ON  [dbo].[legheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheader] TO [public]
GO
