CREATE TABLE [dbo].[orderheader]
(
[ord_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_customer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_bookdate] [datetime] NULL,
[ord_bookedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_originpoint] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_destpoint] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_origincity] [int] NULL,
[ord_destcity] [int] NULL,
[ord_originstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_deststate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_originregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_destregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_startdate] [datetime] NULL,
[ord_completiondate] [datetime] NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalweight] [float] NULL,
[ord_totalpieces] [decimal] (10, 2) NULL,
[ord_totalmiles] [int] NULL,
[ord_totalcharge] [float] NULL,
[ord_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_currencydate] [datetime] NULL,
[ord_totalvolume] [float] NULL,
[ord_hdrnumber] [int] NULL,
[ord_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_invoicewhole] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_pu_at] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_dr_at] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_originregion2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_originregion3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_originregion4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_destregion2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_destregion3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_destregion4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfh_hdrnumber] [int] NULL,
[ord_priority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[tar_tarriffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[timestamp] [timestamp] NULL,
[tar_tariffitem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_showshipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_showcons] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_subcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_lowtemp] [int] NULL,
[ord_hitemp] [int] NULL,
[ord_quantity] [float] NULL,
[ord_rate] [money] NULL,
[ord_charge] [money] NULL,
[ord_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_length] [money] NULL,
[ord_width] [money] NULL,
[ord_height] [money] NULL,
[ord_lengthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_widthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_heightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_origin_earliestdate] [datetime] NULL,
[ord_origin_latestdate] [datetime] NULL,
[ord_odmetermiles] [int] NULL,
[ord_stopcount] [tinyint] NULL,
[ord_dest_earliestdate] [datetime] NULL,
[ord_dest_latestdate] [datetime] NULL,
[ref_sid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_pickup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_cmdvalue] [money] NULL,
[ord_accessorial_chrg] [money] NULL,
[ord_availabledate] [datetime] NULL,
[ord_miscqty] [decimal] (12, 4) NULL,
[ord_tempunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_datetaken] [datetime] NULL,
[ord_totalweightunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalvolumeunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalcountunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_loadtime] [float] NULL,
[ord_unloadtime] [float] NULL,
[ord_drivetime] [float] NULL,
[ord_rateby] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_quantity_type] [int] NULL,
[ord_thirdpartytype1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_thirdpartytype2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_charge_type] [smallint] NULL,
[ord_bol_printed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_fromorder] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_mintemp] [smallint] NULL,
[ord_maxtemp] [smallint] NULL,
[ord_distributor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opt_trc_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opt_trl_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_cod_amount] [money] NULL,
[appt_init] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[appt_contact] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_ratingquantity] [float] NULL,
[ord_ratingunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hideshipperaddr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hideconsignaddr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ord_booked_revtype1] DEFAULT ('UNK'),
[ord_mileagetable] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_tareweight] [int] NULL,
[ord_grossweight] [int] NULL,
[ord_trl_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_trl_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_trl_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_allinclusivecharge] [money] NULL,
[ord_extrainfo1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo6] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo7] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo8] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo9] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo10] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo11] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo12] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo13] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo14] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo15] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_rate_type] [smallint] NULL,
[ord_barcode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_broker] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_stlquantity] [float] NULL,
[ord_stlunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_stlquantity_type] [tinyint] NULL,
[ord_fromschedule] [int] NULL,
[ord_schedulebatch] [int] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_last_updateby] DEFAULT (suser_name()),
[last_updatedate] [datetime] NULL CONSTRAINT [DF_last_updatedate] DEFAULT (getdate()),
[ord_mileage_adj_pct] [decimal] (9, 2) NULL,
[ord_trlrentinv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revenue_pay_fix] [int] NULL CONSTRAINT [DF__ORDERHEAD__ord_r__4CACE708] DEFAULT (0),
[ord_revenue_pay] [money] NULL,
[ord_reserved_number] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_customs_document] [int] NULL CONSTRAINT [DF_ord_customs_document] DEFAULT (0),
[ord_charge_type_lh] [smallint] NULL,
[ord_noautosplit] [tinyint] NOT NULL CONSTRAINT [DF_orderheader_ord_noautosplit] DEFAULT (0),
[ord_noautotransfer] [tinyint] NOT NULL CONSTRAINT [DF_orderheader_ord_noautotransfer] DEFAULT (0),
[ord_complete_stamp] [datetime] NULL,
[ord_totalloadingmeters] [decimal] (12, 4) NULL,
[ord_totalloadingmetersunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_entryport] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ord_entryport] DEFAULT ('UNKNOWN'),
[ord_exitport] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ord_exitport] DEFAULT ('UNKNOWN'),
[ord_commodities_weight] [float] NULL,
[ord_intermodal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_dimfactor] [decimal] (12, 4) NULL,
[external_id] [int] NULL,
[external_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ord_UnlockKey] [int] NULL,
[ord_TrlConfiguration] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_origin_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_dest_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_rate_mileagetable] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_toll_cost] [money] NULL,
[ord_toll_cost_update_date] [datetime] NULL CONSTRAINT [DF_ord_toll_cost_update_date] DEFAULT (getdate()),
[ord_raildest] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_railpoolid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_odmetermiles_mtid] [int] NULL,
[ord_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_route_effc_date] [datetime] NULL,
[ord_route_exp_date] [datetime] NULL,
[ord_order_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_edipurpose] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_ediuseraction] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_edistate] [tinyint] NULL,
[ord_no_recalc_miles] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_editradingpartner] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_edideclinereason] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_miscdate1] [datetime] NULL,
[ord_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_pyd_status_1] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ord_pyd_status_1] DEFAULT ('NPD'),
[ord_pyd_status_2] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ord_pyd_status_2] DEFAULT ('NPD'),
[ord_pin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_accounttype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_shortcomment] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_lastratedate] [datetime] NULL,
[ord_manualeventcallminutes] [int] NULL,
[ord_manualcheckcallminutes] [int] NULL,
[sv_manu_export_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_cbp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_cyclic_dsp_enabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_preassign_ack_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_BelongsTo] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_anc_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_gvw_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_gvw_amt] [numeric] (19, 4) NULL,
[ord_gvw_adjstd_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_gvw_adjstd_amt] [numeric] (19, 4) NULL,
[ord_showasconsignee_dist] [int] NULL,
[ord_use_showasconsignee_dist] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_nomincharges] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_key] [int] NULL,
[ord_chassis] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__orderhead__ord_c__1ED5383C] DEFAULT ('UNKNOWN'),
[ord_chassis2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__orderhead__ord_c__1FC95C75] DEFAULT ('UNKNOWN'),
[ord_odometer_start] [int] NULL,
[ord_odometer_end] [int] NULL,
[ord_preventexternalupdate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_job_ordered] [int] NULL,
[ord_job_remaining] [int] NULL,
[ord_reviewneeded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_DelRptSent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recurring_job_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_remark2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_reviewed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_reviewedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revieweddate] [datetime] NULL,
[rowsec_rsrv_id] [int] NULL,
[ord_batchrateeligibility] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_batchratestatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_billmiles] [money] NULL,
[ord_paymiles] [money] NULL,
[ord_standardhours] [money] NULL,
[GST_REQ] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QST_REQ] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_thirdpartytype3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_thirdparty_split_percent] [float] NOT NULL CONSTRAINT [DF__orderhead__ord_t__5F8CAB94] DEFAULT ((0)),
[ord_thirdparty_split] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_carrierchangecode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extequip_automatch] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IVA_REQ] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_broker_percent] [decimal] (8, 4) NULL,
[ord_target_margin] [decimal] (12, 4) NULL,
[ord_paystatus_override] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HST_REQ] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_customdate] [datetime] NULL,
[ord_timezone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_datepromised] [datetime] NULL,
[ord_edistate_prior] [tinyint] NULL,
[ord_pallet_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_pallet_count] [int] NULL,
[ord_ratemode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_servicelevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_servicedays] [int] NULL,
[ord_railramporig] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_railrampdest] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_over_credit_limit_approved] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_over_credit_limit_approved_by] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_invoice_effectivedate] [datetime] NULL,
[ord_routename] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__orderhead__ord_r__1387DD68] DEFAULT (NULL),
[payrollcloseddate] [datetime] NULL,
[billingcloseddate] [datetime] NULL,
[ord_billing_usedate] [datetime] NULL,
[ord_billing_usedate_setting] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_override_stop_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_checklisttype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_mastermatchpending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_railschedulecascadepending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_importexport] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_pendinglegstatusupdate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_submode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalmileunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalpallets] [float] NULL,
[ord_totalpalletunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalcount2] [decimal] (10, 2) NULL,
[ord_totalcount2units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_rate_per] [float] NULL,
[ord_sub_charge] [decimal] (10, 2) NULL,
[ord_discount_rate] [decimal] (10, 2) NULL,
[ord_discount] [decimal] (10, 2) NULL,
[ord_discount_qty] [decimal] (10, 2) NULL,
[ord_discount_per] [decimal] (10, 2) NULL,
[ord_disc_tar_number] [int] NULL,
[ord_job_freightbased] [bit] NULL,
[ord_approved] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_triprpt_last_rundate] [datetime] NULL,
[ord_app_eqcodes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_ediaccepttext] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__orderhead__INS_T__63C38185] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
		/**
		 * NAME:
		 * ut_ord
		 * 
		 * TYPE:
		 * trigger
		 * 
		 * DESCRIPTION:
		 * TRIGGER dbo.dx_iut_orderheader ON dbo.orderheader FOR UPDATE
		 * 
		 * RETURN:
		 * None.
		 * 
		 * RESULT SETS:
		 * none
		 *
		 * PARAMETERS:
		 * none
		 * 
		 * REFERENCES: 
		 *  
		 * REVISION HISTORY:
		 * 
		*/
		
	CREATE TRIGGER [dbo].[dx_ut_orderheader] ON [dbo].[orderheader] FOR UPDATE
	AS
	
	DECLARE		 @tpid varchar(20)
				,@ord_number varchar(12)
				,@scac	varchar(4)
				,@old_status varchar(6)
				,@new_status varchar(6)
				,@ordersource	varchar(6)
				,@ord_hdrnumber int
				,@ord_billto varchar(8)
				,@lgh_number int
				,@ord_bookedby	varchar(20)
				,@ord_status varchar(6)
				
	declare @appname nvarchar(128)
	/*990 creation on change of ord_status to Planned */
	IF UPDATE(ord_status)
	begin
			select @ord_number = ord_number,
					@new_status = ord_status,
					@tpid = ISNULL(ord_editradingpartner,''),
					@ordersource = ISNULL(ord_order_source,''),
					@ord_billto =  ord_billto,
					@ord_bookedby = ord_bookedby
			from 	inserted
			
			--get prior ord_status
			select @old_status = ord_status
			from	deleted
				
			IF (@new_status = 'PLN' and (@old_status <> @new_status) and @tpid <> '' and @ordersource <> '')
			begin
				SELECT @scac = UPPER(ISNULL(gi_string1, 'SCAC'))
				FROM	generalinfo 
				WHERE	gi_name='SCAC'
				IF (select count(*) from dx_xref  where dx_trpid = @tpid and dx_entitytype = 'CustomSettings' and dx_entityname = 'Create990OnAssignment' and dx_xrefkey = 1) > 0
					--generate a 990
					EXEC dx_create_990_from_204 @ord_number,'A',@scac		
			
			
			end 
			
			--outbound 204 processing for order confirmations
			IF @new_status = 'AVL' and @old_status = 'PND' and @ord_billto <> 'UNKNOWN'
			begin
				
				--select @appname = APP_NAME()
					
					--do not create on updates made by LTSL
					--if @appname = 'TMWDX'
					--	return
			
			if @ord_bookedby in('TMWDX','IMPORT','DX') AND @ord_status <> 'PND'	
				if exists(select 1 from edi_trading_partner where cmp_id = @ord_billto)
				begin/*2*/
				
					if(select count(*) from edi_outbound204_order where ord_hdrnumber = @ord_hdrnumber and edi_code = '06') < 1
					begin/*3*/	
					select @lgh_number = lgh_number from legheader where ord_hdrnumber = @ord_hdrnumber
					IF (select count(*) from dx_xref  where dx_trpid = @tpid and dx_entitytype = 'CustomSettings' and dx_entityname = 'Createob204Confirm' and dx_xrefkey = 1) > 0
						IF NOT EXISTS(select 1 from edi_outbound204_order where ord_hdrnumber = @ord_hdrnumber and edi_code = '06')
								--generate the confirmation 204
								EXEC create_outbound204_bytp @lgh_number,@ord_billto,@ord_number,'CONFRM'			--generate a 204
				end/*2*/	
					end /*3*/	
			end			
						
	end	

	IF UPDATE(ord_billto)
	begin/*1*/
		--only send the outbound 204 if the billto is updated by a user and not LTSL
		--declare @appname nvarchar(128)
		--select @appname = APP_NAME()
		--	if @appname = 'TMWDX'
		--		return
		
			select @ord_number = ord_number,
					@ord_hdrnumber = ord_hdrnumber,
					@new_status = ord_status,
					@tpid = ISNULL(ord_editradingpartner,''),
					@ordersource = ISNULL(ord_order_source,''),
					@ord_billto = ord_billto,
					@ord_bookedby = ord_bookedby,
					@ord_status = ord_status				
			from 	inserted
			
		if @ord_bookedby in('TMWDX','IMPORT','DX') AND @ord_status <> 'PND'	
			if exists(select 1 from edi_trading_partner where cmp_id = @ord_billto)
			begin/*2*/
			
				if(select count(*) from edi_outbound204_order where ord_hdrnumber = @ord_hdrnumber and edi_code = '06') < 1
				begin/*3*/	
				select @lgh_number = lgh_number from legheader where ord_hdrnumber = @ord_hdrnumber
				IF (select count(*) from dx_xref  where dx_trpid = @tpid and dx_entitytype = 'CustomSettings' and dx_entityname = 'Createob204Confirm' and dx_xrefkey = 1) > 0
					IF NOT EXISTS(select 1 from edi_outbound204_order where ord_hdrnumber = @ord_hdrnumber and edi_code = '06')
							--generate the confirmation 204
							EXEC create_outbound204_bytp @lgh_number,@ord_billto,@ord_number,'CONFRM'			--generate a 204
				end/*2*/
			end	/*3*/
	end/*1*/
	return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_ord] ON [dbo].[orderheader] FOR INSERT AS   
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @auto214flag varchar(5), 
		@billto varchar(12), 
		@matchcount int, 
		@stp_number int, 
		@stp_sequence int, 
		@ord_hdrnumber int, 
		@startdate datetime,
		@ord_rateby			char(1),		-- 63181
		@tar_number			int,			-- 63181
		@tar_orderstoapply	int,			-- 63181
		@tar_remaining		int				-- 63181
		
DECLARE @v_GIallowETAonPlanned CHAR(1)
DECLARE @appName NVARCHAR(128),@tmwUser VARCHAR(255)



--PTS 49961 Get GI Value
Select @v_GIallowETAonPlanned =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI_GenerateETAOnCreation'
--PTS49961 END

SELECT  @auto214flag = upper(SUBSTRING(ISNULL(gi_string1,'NO'),1,1))   
	FROM generalinfo  
	WHERE gi_name = 'Auto214Flag'  
	
--Only handle one order at a time, just like other major triggers.
select @billto = ord_billto, @startdate = ord_startdate, @ord_hdrnumber = ord_hdrnumber from inserted

-- 63181 <start>
SELECT	@ord_rateby = ord_rateby,
		@tar_number = tar_number
FROM	inserted

IF @ord_hdrnumber > 0 AND @ord_rateby = 'T' AND @tar_number > 0
BEGIN
	SELECT	@tar_orderstoapply = ISNULL(tar_orderstoapply, 0)
	FROM	tariffheader
	WHERE	tar_number = @tar_number
	
	IF @tar_orderstoapply > 0
	BEGIN
		SELECT	@tar_remaining = @tar_orderstoapply - ISNULL(COUNT(1), 0)  -- count orders having this rate applied
		FROM	rate_order_list
		WHERE	rol_tar_number = @tar_number
		
		IF @tar_remaining > 0			-- rate is available to apply to the order
			INSERT INTO rate_order_list (rol_tar_number, rol_ord_hdrnumber)
			VALUES (@tar_number, @ord_hdrnumber)	
		ELSE							-- rate is no longer available to apply to the order
			UPDATE orderheader
			SET tar_number = null
			WHERE	ord_hdrnumber = @ord_hdrnumber
	END
END
-- 63181 <end>

IF @auto214flag = 'Y' 
BEGIN

	--PTS 49961 Generate ETA on Order Creation
	IF @v_GIallowETAonPlanned = 'Y'
		exec edi_create_eta214 @ord_hdrnumber
	--END PTS 49961
	
	select @matchcount = count(*)
		from edi_214_profile 
		where e214_cmp_id = @billto 
		and e214_triggering_activity = 'CREA'
	if @matchcount > 0
	begin
		--PTS74227 Determine source of status
		SELECT @appName = APP_NAME()
		EXEC gettmwuser @tmwUser OUTPUT
	
		SELECT @stp_sequence = MIN(stp_sequence)  
			FROM stops  
			WHERE ord_hdrnumber = @ord_hdrnumber  
			AND stp_type = 'PUP'  
  
		SELECT @stp_number = stp_number
			FROM stops  
			WHERE ord_hdrnumber = @ord_hdrnumber
    		AND stp_sequence = @stp_sequence

    	INSERT edi_214_pending (  
			e214p_ord_hdrnumber,  
			e214p_billto,  
			e214p_level,  
			e214p_ps_status,  
			e214p_stp_number,  
			e214p_dttm,  
			e214p_activity,  
			e214p_arrive_earlyorlate,  
			e214p_depart_earlyorlate,  
			e214p_stpsequence,  
			ckc_number,  
			e214p_firstlastflags,
			e214p_created,
			e214p_source,
			e214p_user)  
			VALUES (
			@ord_hdrnumber,  
			@billto,  
			'NON',  
			' ',  
			@stp_number,  
			@startdate,  
			'CREA',  
			'',  
			'',  
			@stp_sequence,  
  			0,  
  			'0,1,99',
			getdate(),
			@appName,
			@tmwUser)      		
	end
END  

-- PTS62719 NQIAO 01/10/13
UPDATE orderheader
SET ord_invoice_effectivedate = null
FROM orderheader O
JOIN Inserted I ON O.ord_hdrnumber = I.ord_hdrnumber
WHERE I.ord_invoice_effectivedate IS NOT NULL

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER [dbo].[it_orderheader]
ON [dbo].[orderheader]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/* Trigger it_orderheader
	This will log a fingerprinting entry, in expedite_audit table, whenever an orderheader is inserted.  Note that 
	it_ordersave is triggered on insert or update.  I want this code only to run on insert.

	Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	---------------------------------------------------------------------------
	08/15/2001	Vern Jewett		(none)	PTS 11797, CTX Item #53: Original.
	02/28/2002	Vern Jewett		vmj1	PTS 12286: don't insert audit row unless the feature is turned on.
	9/9/2      	DPETE 			PTS 15367 For LoadTender Imports set the ord_stl... fields from the ord_quantity_type
   8/8/3       dpete          pts 19451 Create paperwork record so imagin may tag as received.
    6/15/5     DPETE            PTS28369 Cowan reports no paperwork records updated by Imaging where bill to company UNKNOWN
       6/22/05 DPETE PTS28285 only write reocrds where labelfile entry is not retired
    1/4/7   DPETE 34647 use tmwuser instead of iut_ordersave as updateby for paperwork
   1/18/10 PTS50865 DPETE customer "concerned" that there is a date in the paperwork received date field
       when the received flag is not set Y
  6/4/10 DPETE PTS51844 add revenue tracking option
  6/28/10 DPETE PTS51844 changes made as a resultof dot net pre rating
  01/18/11 DPETE PTS55393 sdd miles to revenue_tracker table (for invoiceing only)
*/
declare @status varchar(6),@isactive char(1),@ordhdrnumber int
declare	@ls_audit	varchar(1)
--PTS 35741 JJF 2007-04-30
		,@ls_update_note	varchar(255)
--END PTS 35741 JJF 2007-04-30
declare     @v_appid varchar(30),@v_recordzerochanges char(1), @v_now datetime  -- 51844

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--vmj2+	Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
BEGIN  --PTS 42106 FMM need BEGIN and END
	--PTS 35741 JJF 2007-04-30
	SELECT @ls_update_note = 'OrdAvailableDate ' +  isnull(convert(varchar(30), i.ord_availabledate, 101) + ' ' + 
										convert(varchar(30), i.ord_availabledate, 108), 'null') 
	FROM inserted i
	SELECT @ls_update_note =  @ls_update_note + ' OrdRate ' + isnull(convert(varchar(20), i.ord_rate), 'null') 
	FROM inserted i
	--END PTS 35741 JJF 2007-04-30

	--vmj2-
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,mov_number
			,lgh_number
			,join_to_table_name
			,key_value)
	  select ord_hdrnumber
			,@tmwuser
			,'OrderHeader inserted'
			,getdate()
			--PTS 35741 JJF 2007-04-30
			--,''
			,@ls_update_note
			--END PTS 35741 JJF 2007-04-30
			,isnull(mov_number, 0)
			,0
			,'orderheader'
			,convert(varchar(100), ord_hdrnumber)
	  from	inserted
END  --PTS 42106 FMM

If Exists(Select ord_number from inserted where ord_quantity_type in (2,99) and ord_stlquantity_type is null)
   Update orderheader set ord_stlquantity =  orderheader.ord_quantity,
	ord_stlunit =  orderheader.ord_unit,
	Ord_stlquantity_type = 1,
	Ord_quantity_type = Case inserted.ord_quantity_type When 99 Then 0 Else inserted.ord_quantity_type End
	From inserted 
	Where orderheader.ord_hdrnumber = inserted.ord_hdrnumber


/* Add required paperwork so imaging may tag when received */
Insert Into paperwork (abbr,pw_received,ord_hdrnumber,pw_dt,last_updatedby,last_updateddatetime,lgh_number,pw_imaged)
  --Select labelfile.abbr,'N',inserted.ord_hdrnumber,getdate(),@tmwuser,getdate(),lgh_number,'N'
  Select labelfile.abbr,'N',inserted.ord_hdrnumber,'19500101 00:00',@tmwuser,getdate(),lgh_number,'N'
  From inserted,labelfile,stops
  Where stops.ord_hdrnumber = inserted.ord_hdrnumber
  --and ord_billto <> 'UNKNOWN'
  and stp_sequence = 1
  and labelfile.labeldefinition = 'PaperWork'
  and labelfile.abbr <> 'TEMP'
  and IsNull(labelfile.retired,'N') <> 'Y'
/* revenue tracking */

If  exists (select 1 from generalinfo where gi_name = 'TrackRevenue' and gi_string1 = '100') and 
    (select count(*) from (select top 2 ord_hdrnumber from inserted) a)  = 1 
  BEGIN
  /* option to record adds and backouts of zero dollars - used for debug */
    Select @v_recordzerochanges = Left(gi_string2,1) from generalinfo where gi_name = 'TrackRevenue'
    Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')
    select @v_appid = rtrim(left(app_name(),30))
    select @v_now = getdate()
    select @status = ord_status from inserted
    exec @isactive = fn_StatusIsActive @status

    if @isactive = 'Y' 
      BEGIN


        -- add status record 
       Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number,cur_code
       ,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource,rvt_appname,rvt_quantity,ivd_number,rvt_rateby
       , rvt_billmiles, rvt_billemptymiles)
           select ord_hdrnumber
           ,0
           ,'PRERATE'
           ,@v_now
           ,'UNK'
           ,0.00
           ,0
           ,ord_currency
           ,'N'
           ,ord_status
           ,'???'
           ,@tmwuser
           ,'it_orderheader'
           ,@v_appid
           ,0
           ,0
           ,ord_rateby
           ,0.0
           ,0.0
           from inserted 
        select @ordhdrnumber = ord_hdrnumber from inserted
        if (select ord_totalcharge from inserted where ord_hdrnumber = @ordhdrnumber) <> 0 or @v_recordzerochanges = 'Y'
           exec CreateRevenueForOrder @ordhdrnumber,'ADD',@tmwuser,'it_orderheader'
      END   
  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE TRIGGER [dbo].[it_ordersave]  
ON [dbo].[orderheader]  
FOR INSERT,update  
AS  
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  
/*  MODIFICATION LOG  
  
DPETE 16402 12/17/02 comment out code to set the ord_invoicestatus, update_ord does that  
 DPETE 16846 only put in imageorderlist for TMI if PLN,DSP,STD,CMP 

PTS 23188 - DJM - 8/3/04 - Added check for setting to create a Note holding the Phone number
	of the Agent assigned to the Order.

PTS 27820 - DJM - Added check for setting to update ExtraInfo fields with Driver Information	
PTS 33126 - JG - Use explicit conversion on ord_hdrnumber to improve performance 
                 when 'useracksecuritycode' setting is on.
PTS 35756 - vjh - Add auto population of ord_route
PTS 37339 - bpisk - Added generalinfo row for TMIImageTripPak
DJM PTS 38765 - 9/24/2007 - Add call to CBP Processing procedure.  Based on GI setting that defaults to 'off'
PMILL 42166/49873 add FLYINGJ imaging 
MTC 57472 6.15.2011 - Add nolocks to help with Deadlocks happening at certain customer sites.
*/  

if NOT EXISTS (select top 1 * from inserted)
    return

declare @ord_hdrnumber	int,  
	@ord_revtype4		varchar(6),  
	@ord_shipper		varchar(8),  
	@notesID			int,  
	@notesnumber		int,  
	@count				int,  
	@not_text			varchar(254),  
	@nre_tablekey		char(18),  
	@codes				varchar(30),
	@ImagingVendor		varchar(60),
	@tprid				varchar(8),
	@orig_tprid			varchar(8),
	@ord_driver1		varchar(8),
	@orig_ord_driver1	varchar(8),
	@ord_revtype1_pfx	varchar(60),
	@ord_route			varchar(60)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
declare @tripPakStatus varchar(256);

exec gettmwuser @tmwuser output  
  
/* PTS 7524  This SQl will prevent the order entry be saved if the move number, order number = 0 or -1  
*/  
if ( select count(*)  
   from   inserted  
   where mov_number < 0 or IsNull(mov_number,0) = 0 or ord_hdrnumber < 0 or IsNull(ord_hdrnumber,0) = 0 ) > 0   
BEGIN  
 ROLLBACK TRANSACTION  
 --vmj1+ PTS 15139 11/04/2002 Improve readability by returning if this condition occurs..  
 return  
 --vmj1-  
END  

--MTC CHANGES AT COVENANT 2014.05.06 BEGIN
declare @updatecount int,  
 @delcount int  
select @updatecount = count(*) from inserted  
select @delcount = count(*) from deleted  
--if inserted recs & no deleteds, that's a pure insert.
--if both, that's an update
declare @now datetime
select @now = getdate()
 
	/* PTS 16842 - DJM - Update the fields tracking last update user and datetime  */  
	if (@updatecount > 0 and @delcount > 0 and not update(ord_toll_cost)--is an UPDATE ONLY.
	and not (update(last_updateby) and update(last_updatedate))) --and these were not being updated by the statement.
	--INSERTS WILL BE HANDLED BY NEW DEFAULT CONSTRAINTS  
	 Update orderheader  
	 set last_updateby = @tmwuser,  
	  last_updatedate = @now  
	 from inserted  inner join orderheader on inserted.ord_hdrnumber = orderheader.ord_hdrnumber 
	  
	--PTS 25713 JJF stamp toll cost update date  
	if (@updatecount > 0 and @delcount > 0 and update(ord_toll_cost)) --is an UPDATE ONLY.
	--INSERTS WILL BE HANDLED BY NEW DEFAULT CONSTRAINTS 
	 Update orderheader  
	 set last_updateby = @tmwuser,  
	  last_updatedate = @now ,
	  ord_toll_cost_update_date = @now ---on an insert should be a default constraint. 
	 from inserted inner join orderheader on inserted.ord_hdrnumber = orderheader.ord_hdrnumber  
 --MTC CHANGES AT COVENANT 2014.05.06 end
  
/* PTS 13207 JYANG if useracksecurity code = 'Y' in generalinfo, whenever the orderheader   
   being updated, if a racksecuritycode associate with shipper.consignee,ord_revtype4(supplier) combined is found,  
   A record will be add to notes table with securitycode as note_text. IF there are more than 1 shipper in the order,   
   , then original note will be delete and user need to manually add the notes */  
SELECT @codes = gi_string1 FROM generalinfo  
   WHERE gi_name = 'useracksecuritycode'  
  
select @count= count(*)  
from   inserted i,  
 stops s  with (nolock) --57472
where s.stp_type = 'PUP' and  
 s.ord_hdrnumber=i.ord_hdrnumber   
  
if upper(ltrim(rtrim(@codes))) = 'Y'   
begin  
 DELETE   
  notes   
 from   
  inserted d  
 where   
  not_type='COMB' and  
  autonote = 'Y' and   
  --jg begin
  nre_tablekey=convert(char(18), d.ord_hdrnumber) and  
  --nre_tablekey=d.ord_hdrnumber and  
  --jg end
  d.ord_hdrnumber>0 and  
  ntb_table='orderheader'  
  
 IF @count < 2   
 begin  
  --create a match of all possible shipper/consignee/revtype 4 combinations of the inserted/stops tables  
  --This was done to address multiple drop combinations.  
  select   
   IDENTITY(int, 1,1) AS matchID,  
   isnull(ord_shipper,'UNKNOWN') as shipper,  
   isnull(s.cmp_id,'UNKNOWN') as consignee,  
   i.ord_revtype4,  
   i.ord_hdrnumber,  
   c.cmp_name   
  into         
   #match  
  from   
   inserted i,  
   stops s with (nolock),  --57472
   company c  with (nolock) --57472
  where  
   s.stp_type = 'DRP' and  
   s.ord_hdrnumber=i.ord_hdrnumber and  
   c.cmp_id = s.cmp_id  
  
  --Select all the notes fields  from the notescomb table which are to be applied.  These need to  
  --be staged because the not_number is a member of the systemcontrol table for system ids  
  select  
   IDENTITY(int, 1,1) AS noteID,    
   0 as not_number,  
   'comb' as not_type,  
   security_note as not_text,  
   901 as not_sequence,  
   ord_hdrnumber,  
   cmp_name  
  into  
   #notes  
  from  
   #match a,  
   notescomb b  
   
  where  
   a.shipper=b.shipper and  
   a.consignee=b.consignee and  
   a.ord_revtype4 = b.supplier  
  
  --Create a cursor to loop though any comb notes that are to be added.  
  
  
  declare notescursor cursor for  
  select noteID from #notes order by not_sequence  
  
  
  open notescursor  
  
  fetch next from notescursor into @notesID  
  
  while @@fetch_status = 0  
  begin  
   exec @notesnumber=getsystemnumber 'NOTES',''  
  
   if @notesnumber>0  
   BEGIN  
    update #notes set not_number=@notesnumber where  
    noteID= @notesID  
   END  
   ELSE  
   BEGIN  
    update #notes set not_number=-1 where  
    noteID= @notesID  
   END  
  
   fetch next from notescursor into @notesID  
  
  end  
  
  
  close notescursor  
  deallocate notescursor  
  
  --Create the new notes  
  insert into notes (not_number,not_text,nre_tablekey,ntb_table,not_type,not_sequence,not_urgent,not_expires,autonote)  
  (select not_number,not_text,ord_hdrnumber,'orderheader','COMB',901,'N','12/31/49','Y' from #notes where not_number > 0 )  
  
  --vjh emergency SQL 7 fix  02/03/19  
  --drop table #notes  
  --drop table #match  
 END  
END  

--PTS# 15477 add code to write the ord_hdrnumber to table ImageOrderList for TMI 
--           Imaging

IF EXISTS (SELECT gi_string1
   FROM generalinfo
   WHERE (gi_name = 'ImagingVendorOnRoad' Or gi_name = 'ImagingVendorInHouse') AND IsNull(gi_string1,'') in ('TMI','FLYINGJ')) --pmill 42166/49873 added flyingj
   BEGIN
--PTS37339 begin
     select @tripPakStatus  = coalesce(gi_string1,'DSP,STD,CMP,ICO') from generalinfo where gi_name = 'TMIImageTripStatus'

     if (@tripPakStatus is null or ltrim(@tripPakStatus) = '')
         set @tripPakStatus = 'DSP,STD,CMP,ICO';

     set @tripPakStatus = ',' + @tripPakStatus + ',';

		Insert Into ImageOrderList (ord_hdrnumber)
		Select distinct ord_hdrnumber from inserted
		Where inserted.ord_hdrnumber > 0 
		and Not Exists (select ord_hdrnumber from ImageOrderList i Where i.ord_hdrnumber = inserted.ord_hdrnumber)
        and 0 < charindex(',' + inserted.ord_status + ',', @tripPakStatus)
--PTS37339 end
   END
--PTS# 15477

-- PTS 23188 - DJM - Call proc to create/update a note with ThirdParty information
if exists (select gi_string1 from generalinfo where gi_name = 'AutoCreateTPRNote' and Left(gi_string1,1) = 'Y')
	Begin
		if (@updatecount > 0 AND @delcount = 0 and (Select ord_thirdpartytype1 from inserted) is not null)
			-- New Order. Create the Note
			Begin
				select @ord_hdrnumber = ord_hdrnumber,
					@tprid = isNull(ord_thirdpartytype1,'')
				from inserted
				
				if @tprid <> ''
					exec create_tpr_order_note_sp @ord_hdrnumber,@tprid,'N'
			End
		
		if (@updatecount > 0 AND @delcount > 0 )
			-- Existing Order.  Verify that ThirdParty has changed and delete original note.
			Begin
				select @ord_hdrnumber = ord_hdrnumber, @tprid = isNull(ord_thirdpartytype1,'') from inserted
				Select @orig_tprid = ord_thirdpartytype1 from deleted where ord_hdrnumber = @ord_hdrnumber
				
				if (isNull(@orig_tprid,'') <> isNull(@tprid,'')) --AND (@orig_tprid is not null)
					-- IF the Agent is different from the original, then delete the original NOTE
					Begin
	
						delete from notes 
						where notes.nre_tablekey = @ord_hdrnumber 
							and notes.ntb_table = 'orderheader' 
							and notes.not_text like ('%Agent ID: ' + @orig_tprid + '%')
		
						if @tprid <> ''	exec create_tpr_order_note_sp @ord_hdrnumber,@tprid,'N'
					End
			End
	End


-- PTS 27820 - DJM - Call proc to create/update Extrainfo tables with information.
if exists (select gi_string1 from generalinfo where gi_name = 'ExtraInfoData_driver' and Left(gi_string1,1) = 'Y')
Begin
	if (@updatecount > 0 AND @delcount = 0 and (Select ord_driver1 from inserted) is not null)
		-- New Order. Update data
		Begin
			select @ord_hdrnumber = ord_hdrnumber,
				@ord_driver1 = isNull(ord_driver1,'UNKNOWN')
			from inserted

			if @ord_driver1 <> '' and @ord_driver1 <> 'UNKNOWN'
				exec extrainfo_driverdata_data_sp @ord_hdrnumber, @ord_driver1
		End

	if (@updatecount > 0 AND @delcount > 0 )
		-- Existing Order.  Verify that Driver has changed.
		Begin
			select @ord_hdrnumber = ord_hdrnumber, @ord_driver1 = isNull(ord_driver1,'UNKNOWN') from inserted
			Select @orig_ord_driver1 = isNull(ord_driver1,'UNKNOWN') from deleted where ord_hdrnumber = @ord_hdrnumber
			
			if @orig_ord_driver1 <> @ord_driver1
				-- IF the Driver is different from the original, then update with new Driver information.	
				exec extrainfo_driverdata_data_sp @ord_hdrnumber, @ord_driver1
		End
End

-- PTS 35756 - vjh - Add auto population of ord_route
if exists (Select gi_string1 From generalinfo Where gi_name = 'OrdRouteCreation' and Left(gi_string1,1) = 'Y')
Begin
	if (@updatecount > 0 AND @delcount = 0 and (Select ord_revtype1 from inserted) is not null) Begin
		-- New Order. Update data
		select @ord_revtype1_pfx = isnull(left(label_extrastring1,1),'')
		from labelfile l, inserted i
		where l.labeldefinition='RevType1'
		and l.abbr = i.ord_revtype1
		if @ord_revtype1_pfx <> '' begin
			select @ord_route = @ord_revtype1_pfx +  substring('00000'+ord_number,len(ord_number)+1,5)
			from inserted
			Update orderheader
			set ord_route = @ord_route
			from inserted
			where inserted.ord_hdrnumber = orderheader.ord_hdrnumber
		end
	End
	if (@updatecount > 0 AND @delcount > 0 ) Begin
		-- Existing Order.  Verify that Driver has changed.
		select @ord_revtype1_pfx = isnull(left(label_extrastring1,1),'')
		from labelfile l, inserted i
		where l.labeldefinition='RevType1'
		and l.abbr = i.ord_revtype1
		if @ord_revtype1_pfx <> '' begin
			select @ord_route = @ord_revtype1_pfx +  substring('00000'+ord_number,len(ord_number)+1,5)
			from inserted
			Update orderheader
			set ord_route = @ord_route
			from inserted
			where inserted.ord_hdrnumber = orderheader.ord_hdrnumber
			and orderheader.ord_route <> @ord_route
		end
	End
End

/*****************************************************************************
	PTS 38765 - DJM - Add CBP Processing
******************************************************************************/
Declare @cbp_process char(1),
		@ord_status varchar(8),
		@ord_cbp	int,
		@process_ord	int

select @cbp_process = isnull(gi_string1,'N') from generalinfo where gi_name = 'ComputeCBPProcessingFlag'
if @cbp_process = 'Y'
	if not exists(select 1 from deleted) 
		Begin
			select @ord_hdrnumber = isNull(ord_hdrnumber,0) from inserted
			select @ord_status = isNull(ord_status,'AVL') from inserted -- where ord_hdrnumber = @ord_hdrnumber and @ord_hdrnumber > 0

			-- Verify that the order is in a status that is eligible for CBP processing.
			select @process_ord = isNull((select 1 from labelfile 
										where labeldefinition = 'dispstatus' 
											and abbr = @ord_status 
											and code > (select code from labelfile 
														where labeldefinition = 'dispstatus' 
														and abbr = 'AVL')),0)

			if @ord_hdrnumber > 0 and @process_ord > 0 
				Begin
					--Select @ord_status from Orderheader o where o.ord_hdrnumber = @ord_hdrnumber
					exec cbp_is_order_cbp @ord_hdrnumber, '', @ord_cbp out

					Declare @ord_cbp_tablevalue		char(1)
					select @ord_cbp_tablevalue = case 
									when @ord_cbp >= 0 then 'Y'
									when @ord_cbp = -1 then 'N'
									else 'E'		
								end	
					
					Update orderheader
					set ord_cbp = @ord_cbp_tablevalue			
					where ord_hdrnumber = @ord_hdrnumber
						and isNull(ord_cbp,'') <> @ord_cbp_tablevalue
				End
		End



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[orderheader_insert] on [dbo].[orderheader] FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/**
 * 
 * NAME: 
 * dbo.orderheader_insert 
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
 *
 **/

/* EXEC timerins "ord_ins", "START" */

/* RETOTAL TOTAL CHARGE FOR ORDER */
UPDATE orderheader  
SET ord_totalcharge = round(inserted.ord_accessorial_chrg, 4)  + round(inserted.ord_charge,4)  
FROM orderheader, inserted
WHERE ( orderheader.ord_hdrnumber = inserted.ord_hdrnumber ) AND  
      ( orderheader.ord_invoicestatus <> 'PPD' )

/* EXEC timerins "ord_ins", "END" */

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Trigger de cuando una orden es compleada y se envia cabecera de carga cuando tenga una orden planeada...

CREATE TRIGGER [dbo].[TR_ordencompletada_JR] ON [dbo].[orderheader]
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
		@ls_operador_PLN Varchar(8)
		
IF UPDATE (ord_status)
BEGIN
			/* Se hace el select para obtener los datos que se estan actualizando */
		SELECT 	@ls_mov_number		= b.mov_number,
				@ll_orden			= b.ord_hdrnumber,
				@ls_status			= b.ord_status, 
				@ls_unidad			= b.ord_tractor,
				@ls_operador		= b.ord_driver1
		FROM OrderHeader a, INSERTED b
		WHERE   a.ord_hdrnumber = b.ord_hdrnumber

		IF @ls_status = 'CMP'
			BEGIN	--1 status a CMP
				-- Revisa que este registrada en la tabla de unidades en QFS...
				--IF Exists ( SELECT count(*) FROM QSP..QFSVehicles WHERE displayname = @ls_unidad)
				--	BEGIN -- 2 cuando la unidad esta en QSP
						--Busca si tiene un viaje Planeado la unidad para enviar la cabezera de carga...
						select @ls_mov_num_PLN = IsNull(Min(mov_number),0)
						from orderheader where ord_driver1 = @ls_operador and
						ord_hdrnumber > @ll_orden and ord_status = 'PLN'  and ord_tractor in ('1109','1116','1117','1120')
						
						IF @ls_mov_num_PLN > 0
							BEGIN -- 3 cuando si hay una orden en PLN
								select @ls_unidad_PLN =	ord_tractor
								from orderheader where ord_driver1 = @ls_operador and
									ord_hdrnumber > @ll_orden and ord_status = 'PLN' and
									mov_number = @ls_mov_num_PLN

								Exec sp_enviaMacroCab_de_carga @ls_mov_num_PLN, @ls_unidad_PLN, 'PLN' 

							END -- 3 cuando si hay una orden en PLN
				--	END -- 2 cuando la unidad esta en QSP
	END--1 status a CMP
END -- 0 cuando el campo act es ord_status
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Trigger de cuando una orden es confirmada (DSP) y se envia numero de segmento para timbrar...

CREATE TRIGGER [dbo].[TRU_ordenDSP_JR] ON [dbo].[orderheader]
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
		@lm_totalcharge  money
		
IF UPDATE (ord_status)
BEGIN
			/* Se hace el select para obtener los datos que se estan actualizando */
		SELECT 	@ls_mov_number		= b.mov_number,
				@ll_orden			= b.ord_hdrnumber,
				@ls_status			= b.ord_status, 
				@ls_unidad			= b.ord_tractor,
				@ls_operador		= b.ord_driver1,
				@ls_billto			= b.ord_billto,
				@lm_totalcharge		= b.ord_totalcharge
		FROM OrderHeader a, INSERTED b
		WHERE   a.ord_hdrnumber = b.ord_hdrnumber

		IF @ls_status = 'STD' 
			BEGIN	--1 status a STD (Empezado)
					--cAMBIA el status de la ord_invoicestatus
					update orderheader set ord_invoicestatus = 'AVL' where ord_hdrnumber = @ll_orden
			END -- 3 cuando si h|ay una orden en PLN
			-- cuando el status es PLN y cte LIVERDED se inserta el segmento para timbrar

	    IF @ls_status = 'PLN' and @ls_billto = 'LIVERDED' and @lm_totalcharge > 0
			BEGIN
				SELECT 	@li_numsegmento		= max(a.lgh_number)
				FROM legheader a, INSERTED b
				WHERE   a.ord_hdrnumber = b.ord_hdrnumber
									
						IF @li_numsegmento > 0
							BEGIN -- 3 cuando si hay un segmento valido se inserta en la tabla
								Insert segmentosportimbrar_JR(billto,segmento,estatus,observaciones, fecha )
								values('LIVERDED',@li_numsegmento,1,'Segmento de la orden:'+CAST(@ll_orden as varchar(10)),getdate()) 
							END -- 3 cuando si h|ay una orden en PLN
			END--1 status PLN

			-- fin del cliente LIVERDED
END -- 0 cuando el campo act es ord_status
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_ord] ON [dbo].[orderheader] FOR UPDATE
AS

SET NOCOUNT ON;

IF NOT EXISTS(SELECT TOP 1 1 FROM inserted)
  RETURN;

DECLARE @tmwuser                      VARCHAR(255),
        @appName                      VARCHAR(128),
        @Auto214Flag                  CHAR(1),
        @CascadeMasterOrder           CHAR(1),
        @OrderEventExport             CHAR(1),
        @EdiNotificationProcessType   INTEGER,
        @EdiEnableLtlOutput           CHAR(1),
        @ProcessOutbound204           CHAR(1),
        @LoadFileExport               CHAR(1),
        @CtxActiveLegs                CHAR(1),
        @RevType1FromTrcType1         CHAR(1),
        @TrackRevenue                 INTEGER,
        @TrackRevenueZeroChanges      CHAR(1),
        @GETDATE                      DATETIME,
        @OrdInvoiceStatusChanged      CHAR(1),
        @OrdInvoiceStatusChangedToAvl CHAR(1),
        @OrdCancelled                 CHAR(1),
        @TarNumberChanged             CHAR(1),
        @OrdCompleteDateNeedsUpdate   CHAR(1),
        @OrdStatusChanged             CHAR(1),
        @OrdAvailableDateChanged      CHAR(1),
        @OrdConsigneeChanged          CHAR(1),
        @OrdTrailerChanged            CHAR(1),
        @OrdEdiStateChanged           CHAR(1),
        @OrdOriginPointChanged        CHAR(1),
        @OrdDestPointChanged          CHAR(1),
        @OrdAccessorialChrgChanged    CHAR(1),
        @OrdChargeChanged             CHAR(1),
        @OrdPriorityChanged           CHAR(1),
        @OrdTractorChanged            CHAR(1),
        @OrdNumberChanged             CHAR(1),
        @OrdRemarkChanged             CHAR(1),
        @OrdCarrierChanged            CHAR(1),
        @OrdTotalPiecesChanged        CHAR(1),               
        @OrdTotalWeightChanged        CHAR(1),
        @OrdTotalVolumeChanged        CHAR(1),
        @ord_hdrnumber                INTEGER,
        @lgh_number                   INTEGER,
        @stp_number                   INTEGER,
        @oldstatus                    VARCHAR(6),
        @newstatus                    VARCHAR(6),
        @Activity                     VARCHAR(6);
        
DECLARE @inserted UtOrd,
        @deleted  UtOrd;

EXECUTE dbo.gettmwuser @tmwuser OUTPUT;

SELECT  @appName = APP_NAME();

SELECT  @Auto214Flag = CASE
                         WHEN gi_name = 'Auto214Flag' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                         ELSE @Auto214Flag
                       END,
        @CascadeMasterOrder = CASE
                                WHEN gi_name = 'CascadeMSTChangesToCopied' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                                ELSE @CascadeMasterOrder
                              END,
        @OrderEventExport = CASE
                              WHEN gi_name = 'OrderEventExport' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                              ELSE @OrderEventExport
                            END,
        @EdiNotificationProcessType = CASE
                                        WHEN gi_name = 'EDI_Notification_Process_Type' THEN COALESCE(TRY_CONVERT(INTEGER, gi_string1), 1)
                                        ELSE @EdiNotificationProcessType
                                      END,
        @EdiEnableLtlOutput = CASE
                                WHEN gi_name = 'EDI_EnableLTLOutput' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                                ELSE @EdiEnableLtlOutput
                              END,
        @ProcessOutbound204 = CASE
                                WHEN gi_name = 'ProcessOutbound204' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                                ELSE @ProcessOutbound204
                              END,
        @LoadFileExport = CASE  
                            WHEN gi_name = 'LoadFileExport' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                            ELSE @LoadFileExport
                          END,
        @CtxActiveLegs = CASE
                           WHEN gi_name = 'CTXActiveLegs' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                           ELSE @CtxActiveLegs
                         END,
        @RevType1FromTrcType1 = CASE
                                  WHEN gi_name = 'RevType1FromTrcType1' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                                  ELSE @RevType1FromTrcType1
                                END,
        @TrackRevenue = CASE
                          WHEN gi_name = 'TrackRevenue' THEN COALESCE(TRY_CONVERT(INTEGER, gi_string1), 0)
                          ELSE @TrackRevenue
                        END,
        @TrackRevenueZeroChanges = CASE
                                     WHEN gi_name = 'TrackRevenue' THEN LEFT(COALESCE(gi_string2, 'N'), 1)
                                     ELSE @TrackRevenueZeroChanges
                                   END
  FROM  generalinfo
 WHERE  gi_name IN ('Auto214Flag', 'CascadeMSTChangesToCopied', 'OrderEventExport', 'EDI_Notification_Process_Type',
                    'EDI_EnableLTLOutput', 'ProcessOutbound204', 'LoadFileExport', 'CTXActiveLegs',
                    'RevType1FromTrcType1', 'TrackRevenue');

INSERT INTO @inserted
  SELECT  ord_hdrnumber,
          ord_number,
          ord_status,
          ord_invoicestatus,
          ord_billto,
          ord_bookdate,
          ord_availabledate,
          ord_invoice_effectivedate,
          tar_number,
          ord_rateby,
          ord_complete_stamp,
          ord_consignee,
          ord_company,
          ord_shipper,
          ord_carrier,
          ord_trailer,
          ord_tractor,
          ord_edistate,
          ord_originpoint,
          ord_destpoint,
          ord_startdate,
          ord_charge,
          ord_accessorial_chrg,
          ord_priority,
          ord_remark,
          ord_totalpieces,
          ord_totalweight,
          ord_totalvolume,
          ord_currency,
          ord_quantity,
          ord_completiondate,
          mov_number,
          cht_itemcode
    FROM  inserted

INSERT INTO @deleted
  SELECT  ord_hdrnumber,
          ord_number,
          ord_status,
          ord_invoicestatus,
          ord_billto,
          ord_bookdate,
          ord_availabledate,
          ord_invoice_effectivedate,
          tar_number,
          ord_rateby,
          ord_complete_stamp,
          ord_consignee,
          ord_company,
          ord_shipper,
          ord_carrier,
          ord_trailer,
          ord_tractor,
          ord_edistate,
          ord_originpoint,
          ord_destpoint,
          ord_startdate,
          ord_charge,
          ord_accessorial_chrg,
          ord_priority,
          ord_remark,
          ord_totalpieces,
          ord_totalweight,
          ord_totalvolume,
          ord_currency,
          ord_quantity,
          ord_completiondate,
          mov_number,
          cht_itemcode
    FROM  deleted

SELECT  @Auto214Flag = COALESCE(@Auto214Flag, 'N'),
        @CascadeMasterOrder = COALESCE(@CascadeMasterOrder, 'N'),
        @OrderEventExport = COALESCE(@OrderEventExport, 'N'),
        @EdiNotificationProcessType = COALESCE(@EdiNotificationProcessType, 1),
        @EdiEnableLtlOutput = COALESCE(@EdiEnableLtlOutput, 'N'),
        @ProcessOutbound204 = COALESCE(@ProcessOutbound204, 'N'),
        @LoadFileExport = COALESCE(@LoadFileExport, 'N'),
        @CtxActiveLegs = COALESCE(@CtxActiveLegs, 'N'),
        @RevType1FromTrcType1 = COALESCE(@RevType1FromTrcType1, 'N'),
        @TrackRevenue = COALESCE(@TrackRevenue, 0),
        @TrackRevenueZeroChanges = COALESCE(@TrackRevenueZeroChanges, 'N'),
        @GETDATE = GETDATE(),
        @OrdInvoiceStatusChanged = 'N',
        @OrdInvoiceStatusChangedToAvl = 'N',
        @OrdCancelled = 'N',
        @TarNumberChanged = 'N',
        @OrdCompleteDateNeedsUpdate = 'N',
        @OrdStatusChanged = 'N',
        @OrdAvailableDateChanged = 'N',
        @OrdConsigneeChanged = 'N',
        @OrdTrailerChanged = 'N',
        @OrdEdiStateChanged = 'N',
        @OrdOriginPointChanged = 'N',
        @OrdDestPointChanged = 'N',
        @OrdAccessorialChrgChanged = 'N',
        @OrdChargeChanged = 'N',
        @OrdPriorityChanged = 'N',
        @OrdTractorChanged = 'N',
        @OrdNumberChanged = 'N',
        @OrdRemarkChanged = 'N',
        @OrdCarrierChanged = 'N',
        @OrdTotalPiecesChanged = 'N',
        @OrdTotalWeightChanged = 'N',
        @OrdTotalVolumeChanged = 'N';


SELECT  @OrdInvoiceStatusChanged = CASE
                                     WHEN COALESCE(i.ord_invoicestatus, '') <> COALESCE(d.ord_invoicestatus, '') THEN 'Y'
                                     ELSE @OrdInvoiceStatusChanged
                                   END,
        @OrdInvoiceStatusChangedToAvl = CASE 
                                          WHEN COALESCE(i.ord_invoicestatus, '') = 'AVL' AND COALESCE(d.ord_invoicestatus, '') <> 'AVL' THEN 'Y'
                                          ELSE @OrdInvoiceStatusChangedToAvl
                                        END,
        @OrdCancelled = CASE
                          WHEN COALESCE(i.ord_status, '') = 'CAN' AND COALESCE(d.ord_status, '') <> 'CAN' THEN 'Y'
                          ELSE @OrdCancelled
                        END,
        @TarNumberChanged = CASE
                              WHEN COALESCE(i.tar_number, 0) <> 0 AND COALESCE(i.tar_number, 0) <> COALESCE(d.tar_number, 0) THEN 'Y'
                              ELSE @TarNumberChanged
                            END,
        @OrdCompleteDateNeedsUpdate = CASE
                                        WHEN COALESCE(i.ord_status, '') = 'CMP' AND COALESCE(d.ord_status, '') <> 'CMP' AND i.ord_complete_stamp IS NULL THEN 'Y'
                                        ELSE @OrdCompleteDateNeedsUpdate
                                      END,
        @OrdStatusChanged = CASE
                              WHEN COALESCE(i.ord_status, '') <> COALESCE(d.ord_status, '') THEN 'Y'
                              ELSE @OrdStatusChanged
                            END,
        @OrdConsigneeChanged = CASE
                              WHEN COALESCE(i.ord_consignee, '') <> COALESCE(d.ord_consignee, '') THEN 'Y'
                              ELSE @OrdConsigneeChanged
                            END,
        @OrdAvailableDateChanged = CASE
                                     WHEN COALESCE(i.ord_availabledate, CONVERT(DATETIME, 0)) <> COALESCE(d.ord_availabledate, CONVERT(DATETIME, 0)) THEN 'Y'
                                     ELSE @OrdAvailableDateChanged
                                   END,
        @OrdTrailerChanged = CASE
                               WHEN COALESCE(i.ord_trailer, '') <> COALESCE(d.ord_trailer, '') THEN 'Y'
                               ELSE @OrdTrailerChanged
                             END,
        @OrdEdiStateChanged = CASE
                                WHEN COALESCE(i.ord_edistate, 99) <> COALESCE(d.ord_edistate, 99) THEN 'Y'
                                ELSE @OrdEdiStateChanged
                              END,
        @OrdOriginPointChanged = CASE
                                   WHEN COALESCE(i.ord_originpoint, '') <> COALESCE(d.ord_originpoint, '') THEN 'Y'
                                   ELSE @OrdOriginPointChanged
                                 END,
        @OrdDestPointChanged = CASE
                                 WHEN COALESCE(i.ord_destpoint, '') <> COALESCE(d.ord_destpoint, '') THEN 'Y'
                                 ELSE @OrdDestPointChanged
                               END,
        @OrdAccessorialChrgChanged = CASE
                                       WHEN COALESCE(i.ord_accessorial_chrg, 0.0) <> COALESCE(d.ord_accessorial_chrg, 0.0) THEN 'Y'
                                       ELSE @OrdAccessorialChrgChanged
                                     END,
        @OrdChargeChanged = CASE
                              WHEN COALESCE(i.ord_charge, 0.0) <> COALESCE(d.ord_charge, 0.0) THEN 'Y'
                              ELSE @OrdChargeChanged
                            END,
        @OrdPriorityChanged = CASE
                                WHEN COALESCE(i.ord_priority, '') <> COALESCE(d.ord_priority, '') THEN 'Y'
                                ELSE @OrdPriorityChanged
                              END,
        @OrdTractorChanged = CASE
                               WHEN COALESCE(i.ord_tractor, '') <> COALESCE(d.ord_tractor, '') THEN 'Y'
                               ELSE @OrdTractorChanged
                             END,
        @OrdNumberChanged = CASE
                              WHEN i.ord_number <> d.ord_number THEN 'Y'
                              ELSE @OrdNumberChanged
                            END,
        @OrdCarrierChanged = CASE
                               WHEN COALESCE(i.ord_carrier, '') <> COALESCE(d.ord_carrier, '') THEN 'Y'
                               ELSE @OrdCarrierChanged
                             END,
        @OrdRemarkChanged = CASE
                              WHEN COALESCE(i.ord_remark, '') <> COALESCE(d.ord_remark, '') THEN 'Y'
                              ELSE @OrdRemarkChanged
                            END,
        @OrdTotalPiecesChanged = CASE
                                   WHEN COALESCE(i.ord_totalpieces, 0.0) <> COALESCE(d.ord_totalpieces, 0.0) THEN 'Y'
                                   ELSE @OrdTotalPiecesChanged
                                 END,
        @OrdTotalWeightChanged = CASE
                                   WHEN COALESCE(i.ord_totalweight, 0.0) <> COALESCE(d.ord_totalweight, 0.0) THEN 'Y'
                                   ELSE @OrdTotalWeightChanged
                                 END,
        @OrdTotalVolumeChanged = CASE
                                   WHEN COALESCE(i.ord_totalvolume, 0.0) <> COALESCE(d.ord_totalvolume, 0.0) THEN 'Y'
                                   ELSE @OrdTotalVolumeChanged
                                 END
  FROM  @inserted i
          INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber;

IF @OrdInvoiceStatusChangedToAvl = 'Y'
BEGIN
    EXECUTE dbo.UtOrd_InvoiceOverridedate_sp @inserted, @deleted;
END

IF @OrdCancelled = 'Y'
  DELETE  rate_order_list
   WHERE  rol_ord_hdrnumber IN (SELECT  i.ord_hdrnumber
                                  FROM  @inserted i
                                          INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
                                 WHERE  (COALESCE(i.ord_status, '') = 'CAN'
                                   AND   COALESCE(d.ord_status, '') <> 'CAN'));

IF @TarNumberChanged = 'Y'
BEGIN
  WITH CTE AS
  (
    SELECT  i.ord_hdrnumber,
            i.ord_rateby,
            i.tar_number,
            COALESCE(th.tar_orderstoapply, 0) MaxOrders,
            (SELECT COUNT(1) FROM rate_order_list WHERE rol_tar_number = i.tar_number) CurrentOrders
      FROM  @inserted i
              INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
              LEFT OUTER JOIN tariffheader th ON th.tar_number = i.tar_number
     WHERE  (COALESCE(i.tar_number, 0) <> COALESCE(d.tar_number, 0))
  )
  MERGE rate_order_list AS target
  USING CTE AS source
  ON target.rol_ord_hdrnumber = source.ord_hdrnumber
  WHEN NOT MATCHED BY TARGET AND source.ord_rateby = 'T' AND source.MaxOrders > source.CurrentOrders AND COALESCE(source.tar_number, 0) <> 0
    THEN INSERT (rol_tar_number, rol_ord_hdrnumber) VALUES (source.tar_number, source.ord_hdrnumber)
  WHEN MATCHED AND source.ord_rateby = 'T' AND source.MaxOrders > CurrentOrders AND COALESCE(source.tar_number, 0) <> 0
    THEN UPDATE SET target.rol_tar_number = source.tar_number
  WHEN MATCHED
    THEN DELETE;
END

IF @OrdCompleteDateNeedsUpdate = 'Y'
  UPDATE  OH
     SET  OH.ord_complete_stamp = @GETDATE
    FROM  orderheader OH
            INNER JOIN @inserted i ON i.ord_hdrnumber = OH.ord_hdrnumber
            INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
   WHERE  COALESCE(i.ord_status, '') = 'CMP'
     AND  COALESCE(d.ord_status, '') <> 'CMP'
     AND  i.ord_complete_stamp IS NULL;

IF @OrdStatusChanged = 'Y' OR @OrdAvailableDateChanged = 'Y' OR @OrdConsigneeChanged = 'Y'
BEGIN
  DECLARE OrderCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT  i.ord_hdrnumber,
            COALESCE(i.ord_status, ''),
            COALESCE(d.ord_status, '')
      FROM  @inserted i
              INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
     WHERE  COALESCE(i.ord_status, '') <> COALESCE(d.ord_status, '')
        OR  COALESCE(i.ord_consignee, '') <> COALESCE(d.ord_consignee, '')
        OR  COALESCE(i.ord_availabledate, CONVERT(DATETIME, 0)) <> COALESCE(d.ord_availabledate, CONVERT(DATETIME, 0));

  OPEN OrderCursor;
  FETCH OrderCursor INTO @ord_hdrnumber, @newstatus, @oldstatus;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF @Auto214Flag = 'Y'
      EXECUTE UtOrd_Auto214Flag_sp @inserted, @deleted, @ord_hdrnumber, @EdiEnableLtlOutput, @EdiNotificationProcessType, @tmwuser, @GETDATE, @appName;

    IF @newstatus = 'CAN' AND @oldstatus <> 'CAN' AND @ProcessOutbound204 = 'Y'
      UPDATE  LGH
         SET  lgh_carrier = 'UNKNOWN'
        FROM  legheader LGH WITH(NOLOCK)
                INNER JOIN @deleted d ON d.ord_hdrnumber = LGH.ord_hdrnumber
                INNER JOIN carrier c WITH(NOLOCK) ON c.car_id = d.ord_carrier
       WHERE  LGH.ord_hdrnumber = @ord_hdrnumber
         AND  COALESCE(c.car_204flag, 0) = 1
         AND  d.ord_carrier <> 'UNKNOWN';

    IF @LoadFileExport = 'Y' AND @newstatus = 'CAN' AND @oldstatus <> 'CAN'
		BEGIN
		  SELECT  @lgh_number = lgh_number
			  FROM  dbo.legheader WITH(NOLOCK)
		   WHERE  ord_hdrnumber = @ord_hdrnumber;
		      
       EXEC create_segment_output @lgh_number, 'N', 'N';
		END

    FETCH OrderCursor INTO @ord_hdrnumber, @newstatus, @oldstatus;
  END

  
  CLOSE OrderCursor;
  DEALLOCATE OrderCursor;
END

IF @OrdTrailerChanged = 'Y' AND @Auto214Flag = 'Y'
BEGIN
  DECLARE OrderCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT  e.e214ph_stp_number,
            e.e214ph_activity
      FROM  @inserted i
              INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
              INNER JOIN edi_214_pending_hold e WITH(NOLOCK) ON e.e214ph_ord_hdrnumber = i.ord_hdrnumber
     WHERE  COALESCE(i.ord_trailer, '') <> COALESCE(d.ord_trailer, '')
       AND  e.e214ph_holdreason = 'TRL';

  OPEN OrderCursor;
  FETCH OrderCursor INTO @stp_number, @Activity;

	WHILE @@FETCH_STATUS = 0
  BEGIN
    EXECUTE edi214_hold_to_pending_sp @stp_number, @Activity;

    FETCH OrderCursor INTO @stp_number, @Activity;
  END

  CLOSE OrderCursor;
  DEALLOCATE OrderCursor;
END

IF @OrdEdiStateChanged = 'Y'
  UPDATE  OH
     SET  OH.ord_edistate_prior = COALESCE(d.ord_edistate, 99)
    FROM  orderheader OH
            INNER JOIN @inserted i ON i.ord_hdrnumber = OH.ord_hdrnumber
            INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
   WHERE  COALESCE(i.ord_edistate, 99) <> COALESCE(d.ord_edistate, 99);

IF @OrdOriginPointChanged = 'Y' OR @OrdDestPointChanged = 'Y'
BEGIN
  WITH CTE AS
  (
    SELECT  i.ord_hdrnumber,
            i.ord_originpoint shipper,
            i.ord_destpoint consignee,
            i.ord_startdate startdate
      FROM  @inserted i
              INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
     WHERE  (COALESCE(i.ord_originpoint, '') <> COALESCE(d.ord_originpoint, '')
        OR   COALESCE(i.ord_destpoint, '') <> COALESCE(d.ord_destpoint, ''))
       AND  COALESCE(i.ord_originpoint, '') <> ''
       AND  COALESCE(d.ord_originpoint, '') <> ''
  )
  MERGE customercrossref AS target
  USING CTE AS source
  ON target.cxr_shipper = source.shipper AND target.cxr_consignee = source.consignee
  WHEN NOT MATCHED BY TARGET
    THEN INSERT (cxr_shipper, cxr_consignee, cxr_lastbusinessdt) VALUES (source.shipper, source.consignee, source.startdate)
  WHEN MATCHED
    THEN UPDATE SET target.cxr_lastbusinessdt = source.startdate;
END

IF @OrdAccessorialChrgChanged = 'Y' OR @OrdChargeChanged = 'Y'
  UPDATE  OH
     SET  OH.ord_totalcharge = ROUND(COALESCE(i.ord_accessorial_chrg, 0.0), 4) + ROUND(COALESCE(i.ord_charge, 0.0), 4)
    FROM  orderheader OH
            INNER JOIN @inserted i ON i.ord_hdrnumber = OH.ord_hdrnumber
            INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
   WHERE  COALESCE(i.ord_charge, 0.0) <> COALESCE(d.ord_charge, 0.0)
     OR   COALESCE(i.ord_accessorial_chrg, 0.0) <> COALESCE(d.ord_accessorial_chrg, 0.0);

IF @CtxActiveLegs = 'Y' AND @OrdPriorityChanged = 'Y'
	UPDATE  ctx 
		 SET	ctx.ord_priority = i.ord_priority
	  FROM 	ctx_active_legs ctx
            INNER JOIN @inserted i ON i.ord_hdrnumber = ctx.ord_hdrnumber
            INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
	 WHERE  COALESCE(i.ord_priority, '') <> COALESCE(d.ord_priority, '');

IF @OrdTractorChanged = 'Y' AND @RevType1FromTrcType1 = 'Y'
  UPDATE  OH
     SET  OH.ord_revtype1 = tp.trc_type1
    FROM  orderheader OH
            INNER JOIN @inserted i on i.ord_hdrnumber = OH.ord_hdrnumber
            INNER JOIN @deleted d on d.ord_hdrnumber = i.ord_hdrnumber
            INNER JOIN tractorprofile tp on tp.trc_number = i.ord_tractor
   WHERE  COALESCE(i.ord_tractor, 'UNKNOWN') <> 'UNKNOWN'
     AND  COALESCE(i.ord_tractor, '') <> COALESCE(d.ord_tractor, '');

IF @OrdNumberChanged = 'Y' AND @CascadeMasterOrder = 'Y'
	UPDATE	OH
		 SET	OH.ord_fromorder = i.ord_number
		FROM	orderheader OH
            INNER JOIN @deleted d ON d.ord_number = OH.ord_fromorder
            INNER JOIN @inserted i ON i.ord_hdrnumber = d.ord_hdrnumber
	 WHERE  OH.ord_invoicestatus IN ('AVL', 'PND')
		 AND  d.ord_status = 'MST'
     AND  i.ord_number <> d.ord_number;

IF @OrderEventExport = 'Y' AND (@OrdRemarkChanged = 'Y' OR @OrdCarrierChanged = 'Y')
  EXECUTE dbo.UtOrd_OrderEventExport_sp @inserted, @deleted;

IF @OrdTotalPiecesChanged = 'Y' OR @OrdTotalWeightChanged = 'Y' OR @OrdTotalVolumeChanged = 'Y'
	UPDATE  ticket_order_entry_plan
	   SET  toep_planned_work_quantity = toep_planned_work_quantity + 
			      CASE (SELECT TOP 1 
                          lbl.labeldefinition
								    FROM	labelfile lbl
								   WHERE	lbl.labeldefinition in ('FlatUnits', 'CountUnits', 'WeightUnits', 'VolumeUnits')
                     AND	COALESCE(lbl.retired, 'N') <> 'Y'
										 AND  lbl.abbr = toep.toep_work_unit)
				      WHEN 'CountUnits' THEN COALESCE(i.ord_totalpieces - d.ord_totalpieces, 0)
				      WHEN 'WeightUnits' THEN COALESCE(i.ord_totalweight - d.ord_totalweight, 0)
				      WHEN 'VolumeUnits' THEN COALESCE(i.ord_totalvolume - d.ord_totalvolume, 0)
				      ELSE 0
			      END
    FROM  @inserted i 
			      INNER JOIN @deleted d ON i.ord_hdrnumber = d.ord_hdrnumber
			      INNER JOIN ticket_order_entry_plan_orders toepo ON toepo.ord_hdrnumber = i.ord_hdrnumber
			      INNER JOIN ticket_order_entry_plan toep ON toep.toep_id = toepo.toep_id	
   WHERE  COALESCE(i.ord_totalpieces, 0.0) <> COALESCE(d.ord_totalpieces, 0.0)
      OR  COALESCE(i.ord_totalweight, 0.0) <> COALESCE(d.ord_totalweight, 0.0)
      OR  COALESCE(i.ord_totalvolume, 0.0) <> COALESCE(d.ord_totalvolume, 0.0)

IF @TrackRevenue = 100
  EXECUTE dbo.UtOrd_TrackRevenue_sp @inserted, @deleted, @TrackRevenueZeroChanges, @tmwuser, @GETDATE, @appname;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_orderheader_fingerprinting] ON [dbo].[orderheader] FOR UPDATE  AS 

/*******************************************************************************************************************  
  Object Description:
  Fingerprint audit
  Revision History:
  SOURCE : MasterUpgrade_2016.15_07.0311.sql
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  01/17/2017   Dan Clemens			          rewrite ut_orderheader_fingerprinting trigger
													                fixed implicit joins
													                certain sections were rewritten to handle multi-row insert
  01/18/2017   Dan Clemens                moved over code from ut_ord  

 ********************************************************************************************************************/

IF NOT EXISTS (SELECT 1	FROM inserted)
	RETURN

SET NOCOUNT ON 
DECLARE @ldt_updated_dt DATETIME = getdate()
	,@tmwuser VARCHAR(255) 

SET NOCOUNT ON  
IF (
		SELECT TOP 1 COALESCE(left(g1.gi_string1, 1), 'N') 
		FROM generalinfo g1
		WHERE g1.gi_name = 'FingerprintAudit'
			AND g1.gi_datein <= getdate()
		ORDER BY g1.gi_datein DESC
		) = 'Y'
BEGIN
	EXEC gettmwuser @tmwuser OUTPUT;

WITH main AS(
SELECT i.ord_hdrnumber,i.mov_number
,i.ord_priority AS iord_priority
,i.ord_tractor AS iord_tractor
,i.ord_driver1 AS iord_driver1
,i.ord_status AS iord_status
,i.ord_revenue_pay AS iord_revenue_pay
,i.ord_availabledate AS iord_availabledate
,i.ord_rate AS iord_rate
,i.ord_revtype1 AS iord_revtype1
,i.ord_revtype2 AS iord_revtype2
,i.ord_revtype3 AS iord_revtype3
,i.ord_revtype4 AS iord_revtype4
,i.ord_order_source AS iord_order_source
,i.ord_origin_earliestdate AS iord_origin_earliestdate
,i.ord_origin_latestdate AS iord_origin_latestdate
,i.ord_dest_earliestdate AS iord_dest_earliestdate
,i.ord_dest_latestdate AS iord_dest_latestdate
,i.ord_trlconfiguration AS iord_trlconfiguration
,d.ord_priority AS dord_priority
,d.ord_tractor AS dord_tractor
,d.ord_driver1 AS dord_driver1
,d.ord_status AS dord_status
,d.ord_revenue_pay AS dord_revenue_pay
,d.ord_availabledate AS dord_availabledate
,d.ord_rate AS dord_rate
,d.ord_revtype1 AS dord_revtype1
,d.ord_revtype2 AS dord_revtype2
,d.ord_revtype3 AS dord_revtype3
,d.ord_revtype4 AS dord_revtype4
,d.ord_order_source AS dord_order_source
,d.ord_origin_earliestdate AS dord_origin_earliestdate
,d.ord_origin_latestdate AS dord_origin_latestdate
,d.ord_dest_earliestdate AS dord_dest_earliestdate
,d.ord_dest_latestdate AS dord_dest_latestdate
,d.ord_trlconfiguration AS dord_trlconfiguration
, CASE  WHEN COALESCE(i.ord_priority,'null') <> COALESCE(d.ord_priority,'null') THEN 1 ELSE 0 END AS ord_priority_update
, CASE  WHEN COALESCE(i.ord_tractor,'null') <> COALESCE(d.ord_tractor,'null') THEN 1 ELSE 0 END AS ord_tractor_update
, CASE  WHEN COALESCE(i.ord_driver1,'null') <> COALESCE(d.ord_driver1,'null') THEN 1 ELSE 0 END AS ord_driver1_update
, CASE  WHEN COALESCE(i.ord_status,'null') <> COALESCE(d.ord_status,'null') THEN 1 ELSE 0 END AS ord_status_update
, CASE  WHEN COALESCE(i.ord_revenue_pay,0) <> COALESCE(d.ord_revenue_pay,0) THEN 1 ELSE 0 END AS ord_revenue_pay_update
, CASE  WHEN COALESCE(i.ord_availabledate,'2049-12-19 01:23:45.000') <> COALESCE(d.ord_availabledate,'2049-12-19 01:23:45.000') THEN 1 ELSE 0 END AS ord_availabledate_update
, CASE  WHEN COALESCE(i.ord_rate,0) <> COALESCE(d.ord_rate,0) THEN 1 ELSE 0 END AS ord_rate_update
, CASE  WHEN COALESCE(i.ord_revtype1,'null') <> COALESCE(d.ord_revtype1,'null') THEN 1 ELSE 0 END AS ord_revtype1_update
, CASE  WHEN COALESCE(i.ord_revtype2,'null') <> COALESCE(d.ord_revtype2,'null') THEN 1 ELSE 0 END AS ord_revtype2_update
, CASE  WHEN COALESCE(i.ord_revtype3,'null') <> COALESCE(d.ord_revtype3,'null') THEN 1 ELSE 0 END AS ord_revtype3_update
, CASE  WHEN COALESCE(i.ord_revtype4,'null') <> COALESCE(d.ord_revtype4,'null') THEN 1 ELSE 0 END AS ord_revtype4_update
, CASE  WHEN COALESCE(i.ord_order_source,'null') <> COALESCE(d.ord_order_source,'null') THEN 1 ELSE 0 END AS ord_order_source_update
, CASE  WHEN COALESCE(i.ord_origin_earliestdate,'2049-12-19 01:23:45.000') <> COALESCE(d.ord_origin_earliestdate,'2049-12-19 01:23:45.000') THEN 1 ELSE 0 END AS ord_origin_earliestdate_update
, CASE  WHEN COALESCE(i.ord_origin_latestdate,'2049-12-19 01:23:45.000') <> COALESCE(d.ord_origin_latestdate,'2049-12-19 01:23:45.000') THEN 1 ELSE 0 END AS ord_origin_latestdate_update
, CASE  WHEN COALESCE(i.ord_dest_earliestdate,'2049-12-19 01:23:45.000') <> COALESCE(d.ord_dest_earliestdate,'2049-12-19 01:23:45.000') THEN 1 ELSE 0 END AS ord_dest_earliestdate_update
, CASE  WHEN COALESCE(i.ord_dest_latestdate,'2049-12-19 01:23:45.000') <> COALESCE(d.ord_dest_latestdate,'2049-12-19 01:23:45.000') THEN 1 ELSE 0 END AS ord_dest_latestdate_update
, CASE  WHEN COALESCE(i.ord_trlconfiguration,'null') <> COALESCE(d.ord_trlconfiguration,'null') THEN 1 ELSE 0 END AS ord_trlconfiguration_update
FROM deleted d
INNER JOIN inserted i on d.ord_hdrnumber  = i.ord_hdrnumber
),
CTE AS(
SELECT ord_hdrnumber
	,'Status: ' + CASE WHEN COALESCE(lf1.name,'null') = 'null' THEN lf2.name ELSE lf1.name END [update_note]
	, ord_priority_update
FROM main
			 LEFT OUTER JOIN labelfile lf1 ON lf1.labeldefinition = 'OrderTag' AND lf1.abbr = iord_priority
			 LEFT OUTER JOIN labelfile lf2 ON lf2.labeldefinition = 'OrderPriority' AND lf2.abbr = iord_priority
WHERE ord_priority_update = 1

UNION

SELECT ord_hdrnumber
	,'Tractor ' + COALESCE(dord_tractor, 'null') + ' -> ' + COALESCE(iord_tractor, 'null')
	, ord_priority_update
FROM main 
WHERE ord_tractor_update = 1

UNION

SELECT ord_hdrnumber
	,'Driver1 ' + COALESCE(dord_driver1, 'null') + ' -> ' + COALESCE(iord_driver1, 'null')
	, ord_priority_update
FROM main 
WHERE ord_driver1_update = 1

UNION

SELECT ord_hdrnumber
	,'Status ' + COALESCE(dord_status, 'null') + ' -> ' + COALESCE(iord_status, 'null')
	, ord_priority_update
FROM main 
WHERE ord_status_update = 1

UNION

SELECT ord_hdrnumber
	,'OrdRevenuePay ' + COALESCE(convert(VARCHAR, dord_revenue_pay), 'null') + ' -> ' + COALESCE(convert(VARCHAR, iord_revenue_pay), 'null')
	, ord_priority_update
FROM main 
WHERE ord_revenue_pay_update = 1

UNION

SELECT ord_hdrnumber
		,'OrdAvailableDate ' + 	isnull(convert(varchar(30), dord_availabledate, 101) + ' ' + 
										convert(varchar(30), dord_availabledate, 108), 'null') + ' -> ' + 
								isnull(convert(varchar(30), iord_availabledate, 101) + ' ' + 
										convert(varchar(30), iord_availabledate, 108), 'null')
	, ord_priority_update
FROM main 
WHERE ord_availabledate_update = 1

UNION

SELECT ord_hdrnumber
	,'OrdRate ' + COALESCE(convert(VARCHAR, dord_rate), 'null') + ' -> ' + COALESCE(convert(VARCHAR, iord_rate), 'null')
	, ord_priority_update
FROM main 
WHERE ord_rate_update = 1

UNION

SELECT ord_hdrnumber
	,'RevType1 was changed from: ' + COALESCE(convert(VARCHAR, dord_revtype1), 'null') + ' --> ' + COALESCE(convert(VARCHAR, iord_revtype1), 'null')
	, ord_priority_update
FROM main 
WHERE ord_revtype1_update = 1

UNION

SELECT ord_hdrnumber
	,'RevType2 was changed from: ' + COALESCE(convert(VARCHAR, dord_revtype2), 'null') + ' --> ' + COALESCE(convert(VARCHAR, iord_revtype2), 'null')
	, ord_priority_update
FROM main 
WHERE ord_revtype2_update = 1

UNION

SELECT ord_hdrnumber
	,'RevType3 was changed from: ' + COALESCE(convert(VARCHAR, dord_revtype3), 'null') + ' --> ' + COALESCE(convert(VARCHAR, iord_revtype3), 'null')
	, ord_priority_update
FROM main 
WHERE ord_revtype3_update = 1

UNION

SELECT ord_hdrnumber
	,'RevType4 was changed from: ' + COALESCE(convert(VARCHAR, dord_revtype4), 'null') + ' --> ' + COALESCE(convert(VARCHAR, iord_revtype4), 'null')
	, ord_priority_update
FROM main 
WHERE ord_revtype4_update = 1

UNION

SELECT ord_hdrnumber
	,'Order Source was changed from: ' + COALESCE(convert(VARCHAR, dord_order_source), 'null') + ' --> ' + COALESCE(convert(VARCHAR, iord_order_source), 'null')
	, ord_priority_update
FROM main 
WHERE ord_order_source_update = 1

UNION

SELECT ord_hdrnumber,
	'Ord Origin Earliest was changed from: ' +isnull(convert(varchar(20), dord_origin_earliestdate, 120), 'null') + ' -> ' + 
					      isnull(convert(varchar(20), iord_origin_earliestdate, 120), 'null')
	, ord_priority_update
FROM main 
WHERE ord_origin_earliestdate_update = 1

UNION

SELECT ord_hdrnumber,
	'Ord Origin Latest was changed from: ' +isnull(convert(varchar(20), dord_origin_latestdate, 120), 'null') + ' -> ' + 
					      isnull(convert(varchar(20), iord_origin_latestdate, 120), 'null')
	, ord_priority_update
FROM main 
WHERE ord_origin_latestdate_update = 1

UNION

SELECT ord_hdrnumber,
	'Ord Dest Earliest was changed from: ' +isnull(convert(varchar(30), dord_dest_earliestdate, 101) + ' ' + 
		convert(varchar(30), dord_dest_earliestdate, 108), 'null') + ' -> ' + 
isnull(convert(varchar(30), iord_dest_earliestdate, 101) + ' ' + 
		convert(varchar(30), iord_dest_earliestdate, 108), 'null')
	, ord_priority_update
FROM main 
WHERE ord_dest_earliestdate_update = 1

UNION

SELECT ord_hdrnumber
	,'Ord Dest Latest was changed from: ' +isnull(convert(varchar(30), dord_dest_latestdate, 101) + ' ' + 
			convert(varchar(30), dord_dest_latestdate, 108), 'null') + ' -> ' + 
	isnull(convert(varchar(30), iord_dest_latestdate, 101) + ' ' + 
			convert(varchar(30), iord_dest_latestdate, 108), 'null')
	, ord_priority_update
FROM main 
WHERE ord_dest_latestdate_update = 1

UNION

SELECT ord_hdrnumber,
'TRL Config was changed from: ' +isnull( dord_trlconfiguration, 'null') + ' -> ' + isnull( iord_trlconfiguration, 'null')
	, ord_priority_update
FROM main 
WHERE ord_trlconfiguration_update = 1
)
		INSERT INTO expedite_audit_tbl (
			ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name
			)
SELECT 		c.ord_hdrnumber
			,x.updated_by
			,CASE WHEN c.ord_priority_update = 1 THEN LEFT(REPLACE(c.update_note, 'Status:', 'Tag:'), 20) ELSE x.activity END
			,x.updated_dt
			,c.update_note
			,x.key_value
			,x.mov_number
			,x.lgh_number
			,x.join_to_table_name
FROM CTE c
INNER JOIN (
SELECT COALESCE(ord_hdrnumber, 0) [ord_hdrnumber]
	,@tmwuser [updated_by]
	,'OrderHeader update' [Activity]
	,@ldt_updated_dt [updated_dt]
	,convert(VARCHAR(20), ord_hdrnumber) [key_value]
	,COALESCE(mov_number, 0) [Mov_number]
	,null [lgh_number]
	,'orderheader' [join_to_table_name]
FROM main
) x on x.ord_hdrnumber = c.ord_hdrnumber;

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_thirdpartystaging] ON [dbo].[orderheader] FOR UPDATE
AS
DECLARE @thirdpartystaging      CHAR(1),
        @application            VARCHAR(128),
        @old_status             VARCHAR(6),
        @new_status             VARCHAR(6),
        @ord_number             VARCHAR(12),		
        @mov_number             INTEGER,
        @lgh_number             INTEGER,
        @ord_hdrnumber          INTEGER

SELECT @thirdpartystaging = UPPER(LEFT(ISNULL(gi_string1, 'NO'), 1))
  FROM generalinfo
 WHERE gi_name = 'ThirdPartyStaging'

SELECT @application = APP_NAME()

if @thirdpartystaging = 'Y' AND @application = '.NO'
BEGIN
   IF UPDATE (ord_status)
   BEGIN
      SELECT @old_status = deleted.ord_status,
             @new_status = inserted.ord_status,
             @ord_number = inserted.ord_number,
             @mov_number = inserted.mov_number,
             @ord_hdrnumber = inserted.ord_hdrnumber
        FROM inserted, deleted
       WHERE inserted.ord_hdrnumber = deleted.ord_hdrnumber

      SELECT @lgh_number = stops.lgh_number
        FROM stops
       WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
             stops.stp_sequence = (SELECT MIN(stp_sequence)
                                     FROM stops
                                    WHERE ord_hdrnumber = @ord_hdrnumber)

      IF @old_status = 'AVL' AND @new_status = 'PLN'
      BEGIN
         INSERT INTO dbo.thirdpartystaging (ord_number, ss_updatedby, lgh_number, mov_number,
                                            ss_updateddt, ss_send_status, ss_original_status,
                                            ss_new_status)
                                    VALUES (@ord_number, USER_NAME(), @lgh_number, @mov_number,
                                            GETDATE(), 'N', @old_status, @new_status)
      END

      IF @old_status = 'PLN' AND @new_status = 'AVL'
      BEGIN
         INSERT INTO dbo.thirdpartystaging (ord_number, ss_updatedby, lgh_number, mov_number,
                                            ss_updateddt, ss_send_status, ss_original_status,
                                            ss_new_status)
                                    VALUES (@ord_number, USER_NAME(), @lgh_number, @mov_number,
                                            GETDATE(), 'N', @old_status, @new_status)
      END
   END
END
GO
CREATE NONCLUSTERED INDEX [dk_order_external_id] ON [dbo].[orderheader] ([external_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [orderheader_INS_TIMESTAMP] ON [dbo].[orderheader] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mov_number] ON [dbo].[orderheader] ([mov_number], [ord_billto]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_billto] ON [dbo].[orderheader] ([ord_billto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_bookdate_revtype3_billto] ON [dbo].[orderheader] ([ord_bookdate], [ord_revtype3], [ord_billto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_orderheader_billffg] ON [dbo].[orderheader] ([ord_booked_revtype1], [ord_billto], [ord_status], [ord_invoicestatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ord_company] ON [dbo].[orderheader] ([ord_company]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ord_completiondate_status] ON [dbo].[orderheader] ([ord_completiondate], [ord_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_cns] ON [dbo].[orderheader] ([ord_consignee]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dcity] ON [dbo].[orderheader] ([ord_destcity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ord_fromorder] ON [dbo].[orderheader] ([ord_fromorder]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_ordhdrnum] ON [dbo].[orderheader] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ord_number] ON [dbo].[orderheader] ([ord_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_order_source] ON [dbo].[orderheader] ([ord_order_source], [ord_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_order_source_status] ON [dbo].[orderheader] ([ord_order_source], [ord_status], [ord_totalmiles], [ord_edistate]) INCLUDE ([ord_number], [ord_startdate], [ord_revtype1], [ord_revtype2], [ord_revtype3], [ord_revtype4], [ord_editradingpartner]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_orgerldt_stat_rev_mov_city] ON [dbo].[orderheader] ([ord_origin_earliestdate], [ord_status], [ord_booked_revtype1], [mov_number], [ord_origincity], [ord_destcity]) INCLUDE ([ord_dest_earliestdate], [ord_dest_latestdate], [ord_number], [ord_origin_latestdate], [ord_revtype1], [ord_revtype2], [ord_revtype3], [ord_revtype4]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ocity] ON [dbo].[orderheader] ([ord_origincity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_orderheader_ord_refnum] ON [dbo].[orderheader] ([ord_refnum], [ord_reftype], [ord_hdrnumber]) INCLUDE ([ord_company], [ord_number], [ord_invoicestatus], [ord_billto], [ord_startdate], [ord_completiondate], [ord_revtype1], [ord_revtype2], [ord_revtype3], [ord_revtype4], [ord_shipper], [ord_consignee], [mov_number], [ord_description], [ord_rateby]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_rev1_invstatus] ON [dbo].[orderheader] ([ord_revtype1], [ord_invoicestatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_orderheader_ord_route] ON [dbo].[orderheader] ([ord_route]) INCLUDE ([ord_booked_revtype1], [ord_billto], [ord_route_effc_date], [ord_route_exp_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_shipper] ON [dbo].[orderheader] ([ord_shipper]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ordhdr_ordstartdate] ON [dbo].[orderheader] ([ord_startdate], [ord_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_status_mov] ON [dbo].[orderheader] ([ord_status], [mov_number], [ord_origincity], [ord_destcity], [ord_booked_revtype1]) INCLUDE ([ord_number], [ord_origin_earliestdate], [ord_origin_latestdate], [ord_dest_earliestdate], [ord_dest_latestdate], [ord_revtype1], [ord_revtype2], [ord_revtype3], [ord_revtype4]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ord_status] ON [dbo].[orderheader] ([ord_status], [ord_completiondate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_odrhdr_status_invstat] ON [dbo].[orderheader] ([ord_status], [ord_invoicestatus]) INCLUDE ([ord_number], [ord_bookedby], [ord_billto], [ord_completiondate], [ord_revtype1], [ord_revtype2], [ord_revtype3], [ord_revtype4], [ord_totalcharge], [ord_hdrnumber], [mov_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_matching] ON [dbo].[orderheader] ([ord_status], [ord_railschedulecascadepending], [ord_mastermatchpending]) INCLUDE ([ord_number], [mov_number], [ord_route], [ord_importexport]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Orderheader_timestamp] ON [dbo].[orderheader] ([timestamp]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[orderheader] ADD CONSTRAINT [FK_billto] FOREIGN KEY ([ord_billto]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[orderheader] ADD CONSTRAINT [FK_consignee] FOREIGN KEY ([ord_consignee]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[orderheader] ADD CONSTRAINT [FK_orderby] FOREIGN KEY ([ord_company]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[orderheader] ADD CONSTRAINT [FK_shipper] FOREIGN KEY ([ord_shipper]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[orderheader] TO [public]
GO
GRANT INSERT ON  [dbo].[orderheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[orderheader] TO [public]
GO
GRANT SELECT ON  [dbo].[orderheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[orderheader] TO [public]
GO
