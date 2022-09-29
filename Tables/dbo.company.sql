CREATE TABLE [dbo].[company]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_company_cmp_name] DEFAULT (''),
[cmp_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_city] [int] NULL,
[cmp_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_primaryphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_secondaryphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_faxphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_shipper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_shi__13D2C5B1] DEFAULT ('N'),
[cmp_consingee] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_con__14C6E9EA] DEFAULT ('N'),
[cmp_billto] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_bil__15BB0E23] DEFAULT ('N'),
[cmp_othertype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_oth__16AF325C] DEFAULT ('UNK'),
[cmp_othertype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_oth__17A35695] DEFAULT ('UNK'),
[cmp_artype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_art__18977ACE] DEFAULT ('CSH'),
[cmp_invoicetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_inv__198B9F07] DEFAULT ('INV'),
[cmp_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_rev__1A7FC340] DEFAULT ('UNK'),
[cmp_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_rev__1B73E779] DEFAULT ('UNK'),
[cmp_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_rev__1C680BB2] DEFAULT ('UNK'),
[cmp_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_rev__1D5C2FEB] DEFAULT ('UNK'),
[cmp_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_act__1E505424] DEFAULT ('Y'),
[cmp_opens_mo] [int] NULL,
[cmp_closes_mo] [int] NULL,
[cmp_creditlimit] [money] NULL CONSTRAINT [DF__company__cmp_cre__44D6BB16] DEFAULT (0),
[cmp_creditavail] [money] NULL CONSTRAINT [DF__company__cmp_cre__45CADF4F] DEFAULT (0),
[cmp_mileagetable] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mastercompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_mas__212CC0CF] DEFAULT ('UNKNOWN'),
[cmp_terms] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_defaultbillto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_def__2220E508] DEFAULT ('UNKNOWN'),
[cmp_edi214] [int] NULL CONSTRAINT [DF__company__cmp_edi__23150941] DEFAULT (0),
[cmp_edi210] [int] NULL CONSTRAINT [DF__company__cmp_edi__24092D7A] DEFAULT (0),
[cmp_edi204] [int] NULL,
[cmp_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_reg__24FD51B3] DEFAULT ('UNK'),
[cmp_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_reg__25F175EC] DEFAULT ('UNK'),
[cmp_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_reg__26E59A25] DEFAULT ('UNK'),
[cmp_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_reg__27D9BE5E] DEFAULT ('UNK'),
[cmp_addnewshipper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_opensun] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_openmon] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_opentue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_openwed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_openthu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_openfri] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_opensat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_payfrom] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mapfile] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_contact] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_directions] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mbdays] [smallint] NULL CONSTRAINT [DF__company__cmp_mbd__29C206D0] DEFAULT (1),
[cmp_lastmb] [datetime] NULL CONSTRAINT [DF__company__cmp_las__2AB62B09] DEFAULT (getdate()),
[cmp_invcopies] [smallint] NULL CONSTRAINT [DF__company__cmp_inv__2BAA4F42] DEFAULT (1),
[cmp_transfertype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_tra__28CDE297] DEFAULT ('INV'),
[cmp_altid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_upd__2C9E737B] DEFAULT (suser_sname()),
[cmp_updateddate] [datetime] NULL CONSTRAINT [DF__company__cmp_upd__2D9297B4] DEFAULT (getdate()),
[cmp_defaultpriority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_def__2E86BBED] DEFAULT ('UNK'),
[cmp_invoiceto] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_invformat] [int] NULL,
[cmp_invprintto] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_creditavail_update] [datetime] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmd_cod__2F7AE026] DEFAULT ('UNKNOWN'),
[junknotinuse] [datetime] NULL,
[cmp_agedinvflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_age__306F045F] DEFAULT ('N'),
[cmp_max_dunnage] [int] NULL CONSTRAINT [DF__company__cmp_max__31632898] DEFAULT (0),
[cmp_acc_balance] [money] NULL,
[cmp_acc_dt] [datetime] NULL,
[cmp_opens_tu] [int] NULL,
[cmp_closes_tu] [int] NULL,
[cmp_opens_we] [int] NULL,
[cmp_closes_we] [int] NULL,
[cmp_opens_th] [int] NULL,
[cmp_closes_th] [int] NULL,
[cmp_opens_fr] [int] NULL,
[cmp_closes_fr] [int] NULL,
[cmp_opens_sa] [int] NULL,
[cmp_closes_sa] [int] NULL,
[cmp_opens_su] [int] NULL,
[cmp_closes_su] [int] NULL,
[cmp_subcompany] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_createdate] [datetime] NULL CONSTRAINT [DF__company__cmp_cre__32574CD1] DEFAULT (getdate()),
[cmp_taxtable1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_tax__334B710A] DEFAULT ('Y'),
[cmp_taxtable2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_tax__343F9543] DEFAULT ('Y'),
[cmp_taxtable3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_tax__3533B97C] DEFAULT ('N'),
[cmp_taxtable4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_tax__3627DDB5] DEFAULT ('N'),
[cmp_quickentry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_qui__371C01EE] DEFAULT ('N'),
[cmp_slack_time] [int] NULL CONSTRAINT [DF__company__cmp_sla__38102627] DEFAULT (0),
[cmp_mailto_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_address1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_city] [int] NULL,
[cmp_mailto_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_latseconds] [decimal] (11, 3) NULL,
[cmp_longseconds] [decimal] (11, 3) NULL,
[cmp_mailto_crterm1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_mai__39044A60] DEFAULT ('ANY'),
[cmp_mailto_crterm2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_mai__39F86E99] DEFAULT ('ANY'),
[cmp_mailto_crterm3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_mai__3AEC92D2] DEFAULT ('ANY'),
[cmp_mbformat] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mbgroup] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_centroidcity] [int] NULL,
[cmp_centroidctynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_centroidzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_ooa_mileage] [float] NULL,
[cmp_ooa_mileage_stops] [float] NULL,
[cmp_mapaddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_usestreetaddr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_use__3BE0B70B] DEFAULT ('N'),
[cmp_primaryphoneext] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_secondaryphoneext] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_palletcount] [int] NULL,
[cmp_fueltableid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grp_id] [int] NULL CONSTRAINT [DF__company__grp_id__3CD4DB44] DEFAULT (0),
[cmp_parent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_par__3DC8FF7D] DEFAULT ('N'),
[cmp_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_slacktime_late] [int] NULL,
[cmp_geoloc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_geoloc_forsearch] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_min_charge] [money] NULL,
[cmp_service_location] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_psoverride] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_MailtToForLinehaulFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailtoTermsMatchFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_max_weight] [money] NULL,
[cmp_max_weightunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_ivformat] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_ivgroup] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_taxid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_gp_class] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doc_language] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_doc_language] DEFAULT ('English'),
[cmp_image_routing1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_image_routing2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_image_routing3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_port] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_cmp_port] DEFAULT ('N'),
[cmp_depot] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_cmp_depot] DEFAULT ('N'),
[cmp_addcurrencysurcharge] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltsl_auto_add_pul_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltsl_default_pickup_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltsl_default_delivery_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_PUPTimeAllowance] [int] NULL,
[cmp_DRPTimeAllowance] [int] NULL,
[cmp_maxdetmins] [int] NULL,
[cmp_detcontacts] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_allowdetcharges] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_latlongverifications] [int] NULL,
[cmp_maptuit_customnote] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[external_id] [int] NULL,
[external_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_currencysurchargebase] [money] NULL,
[cmp_TrlConfiguration] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_service_location_qual] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_service_location_own] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_service_location_rating] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_MileSearchLevel] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_det_start] [int] NULL,
[cmp_det_apply_if_late] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_reftype_unique] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_PUPalert] [int] NULL,
[cmp_DRPalert] [int] NULL,
[cmp_det_apply_if_early] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_senddetalert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_leadtime] [int] NULL,
[cmp_railramp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_athome_location] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_thirdpartytype1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_thirdpartytype2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_aceidtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_aceid] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_TMlatseconds] [int] NULL,
[cmp_TMlongseconds] [int] NULL,
[cmp_TMdistancetolatlong] [decimal] (9, 1) NULL,
[cmp_TMlatlongdate] [datetime] NULL,
[cmp_dimoverride] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_supplier] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_overrideapplyhighestrate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_rbd_FlatRateOption] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_MinLHAdj] [money] NULL,
[cmp_RateBy] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_rbd_highrateoption] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_last_call_date] [datetime] NULL,
[cmp_last_call_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_last_call_user] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_next_call_date] [datetime] NULL,
[cmp_SchdEarliestDateOverride] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_bookingterminal] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cmp_bookingterminal] DEFAULT ('UNKNOWN'),
[cmp_ICaccessorial] [int] NOT NULL CONSTRAINT [DF_cmp_ICaccessorial] DEFAULT (0),
[cmp_ICaccessorialfactor] [decimal] (8, 4) NOT NULL CONSTRAINT [DF_cmp_ICaccessorialfactor] DEFAULT (100.00),
[cmp_GeoCodeRequested] [datetime] NULL,
[cmp_det_increment] [int] NULL,
[cmp_det_rounding] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_det_threshold] [int] NULL,
[cmp_det_override] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_stop_events] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_freestops] [int] NULL,
[cmp_stopevents_pay] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_freestops_pay] [int] NULL,
[cmp_MonObsHolFlag] [smallint] NULL,
[cmp_TueObsHolFlag] [smallint] NULL,
[cmp_WedObsHolFlag] [smallint] NULL,
[cmp_ThuObsHolFlag] [smallint] NULL,
[cmp_FriObsHolFlag] [smallint] NULL,
[cmp_SatObsHolFlag] [smallint] NULL,
[cmp_SunObsHolFlag] [smallint] NULL,
[cmp_FromHrDateAdj] [smallint] NULL,
[holiday_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_Payment_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_blended_min_qty] [decimal] (19, 4) NULL,
[cmp_minchargeoption] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_BelongsTo] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_acc_gvt_rpt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_acc_id] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_refnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_statemiletype1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_statemiletype2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_splitbillonrefnbr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_toll_detail] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_refnum_gpinvxfer] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_cmp_refnum_gpinvxfer] DEFAULT ('UNK'),
[cmp_avgstopminutes] [int] NULL,
[cmp_accountof] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_house_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_street_name] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_billto_eligible_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_stp_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_stp_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_crmtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_controlling_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_open_ivr_forward_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_closed_ivr_forward_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_numeric_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_firm_appt_value] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_CreditHoldStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company__cmp_Cre__50BC3BF4] DEFAULT ('UNK'),
[cmp_CreditHoldComment] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_InvSrvReleaseOnly] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company__cmp_Inv__5398A89F] DEFAULT ('N'),
[cmp_InvSrvMode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__company__cmp_Inv__548CCCD8] DEFAULT ('UNK'),
[cmp_ForecastBatch] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_SalesHistoryBatch] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_ForecasterLastReadingDate] [datetime] NULL,
[cmp_ForecasterLastRunDate] [datetime] NULL,
[cmp_ivr_pin] [int] NULL,
[cmp_dedicated_bill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_dedicated_usedate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_dedicated_datecycle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_sourcing_include_trans] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_cmp_sourcing_include_trans] DEFAULT ('Y'),
[cmp_sourcing_include_taxes] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_cmp_sourcing_include_taxes] DEFAULT ('Y'),
[cmp_sourcing_max_distance] [int] NOT NULL CONSTRAINT [DF_company_cmp_sourcing_max_distance] DEFAULT ((0)),
[cmp_sourcing_quote_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_cmp_sourcing_quote_type] DEFAULT ('UNK'),
[cmp_sourcing_quotebillto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_cmp_sourcing_quotebillto] DEFAULT ('UNKNOWN'),
[cmp_sourcing_quotetransbillto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_cmp_sourcing_quotetransbillto] DEFAULT ('UNKNOWN'),
[rowsec_rsrv_id] [int] NULL,
[cmp_defaultstptype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_cmp_defaultstptype1] DEFAULT ('UNK'),
[cmp_hiddenid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhh_id] [int] NULL,
[cmp_invoiceby] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_volunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_wgtunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_rateallocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_invoiceimageflag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_TollMethod] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_AvgFuelPriceDateOverride] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_autobill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_autobill_terms] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_refnum_gpdocdescxfer] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_cmp_refnum_gpdocdescxfer] DEFAULT ('UNK'),
[cmp_timezone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc5] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc6] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc7] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc8] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_useboldates] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_sendarrivalalert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_senddeparturealert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_cmdvalue] [money] NULL,
[cmp_mb_breaktype] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mb_breakvalue] [int] NULL,
[cmp_ar_transfer_nonbundled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_company_cmp_ar_transfer_nonbundled] DEFAULT ('N'),
[cmp_defaultcons] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_pophubmilesflag] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_servicedrp_rpt] [int] NULL,
[cmp_servicepup_rpt] [int] NULL,
[cmp_servicebillto_rpt] [int] NULL,
[cmp_invoice_when] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mbdayofmonth] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_RateEachPickDrop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_audit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_othertype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_othertype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_billing_rating_engine] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_app_eqcodes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_dbh_custinvnum_prefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_dbh_custinvnum_startnum] [int] NULL,
[cmp_dbh_custinvnum_digits] [tinyint] NULL,
[cmp_TaxGroup] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_cmp_TaxGroup] DEFAULT ('UNK'),
[cmp_UseDips] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Company_cmp_UseDips] DEFAULT ('N'),
[cmp_billto_spotquote] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_custequipprefix] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppianDistanceFldData] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_allow_tm_update] [tinyint] NULL,
[cmp_isbond] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_doublesdrop_location] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_primaryflagrequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company__cmp_pri__6BC29FED] DEFAULT ('N'),
[cmp_terminal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_ctw_conv] [float] NULL,
[cmp_ctw_break] [float] NULL,
[cmp_wtc_conv] [float] NULL,
[cmp_ctw_weightunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_ctw_volumeunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_yard_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_btm_toll_mileagetable] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_etawcbillto] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_freedays] [int] NOT NULL CONSTRAINT [DF__company__trl_fre__23DC0C58] DEFAULT ('0'),
[trl_maxcharge] [money] NULL,
[cmp_DRBack] [int] NULL,
[cmp_DROut] [int] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__company__INS_TIM__407A4548] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_company] ON [dbo].[company]
FOR DELETE 
AS
/*
 --
 -- REVISION HISTORY:
 -- 07/24/2007.01 ? PTS38486 - SLM ? Add Delete for Contact_Profile table
 -- 11/20/2007.02 ? PTS39866 - SLM ? Add Delete for Expiration table
 --
*/

SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
 DECLARE @cmp_id   VARCHAR(8)
 if exists 
  ( select * from stops, deleted
     where deleted.cmp_id = stops.cmp_id ) 
   begin
-- Sybase Syntax
--   raiserror 99999 'Cannot delete company: Assigned to trips'
-- MSS Syntax
     raiserror('Cannot delete company: Assigned to trips',16,1)
     rollback transaction
     return
   end
   
	--PTS 48633 JJF 20090825
	IF EXISTS(	SELECT	t.TASK_LINK_ENTITY_VALUE
				FROM	TASK t
				INNER JOIN TASK_LINK_ENTITY_TABLE tlet ON t.TASK_LINK_ENTITY_TABLE_ID = tlet.TASK_LINK_ENTITY_TABLE_ID 
															AND tlet.TABLE_NAME = 'COMPANY'
				INNER JOIN deleted on deleted.cmp_id = t.TASK_LINK_ENTITY_VALUE														
				
			) BEGIN
				RAISERROR('Cannot delete company: Has associated tasks', 16, 1)
				ROLLBACK TRANSACTION
				RETURN
	END
	--END PTS 48633 JJF 20090825

   SELECT @cmp_id = cmp_id
     FROM deleted
   IF EXISTS(SELECT m2refid
               FROM m2ref
              WHERE m2refid = @cmp_id
                AND m2refstat <> 'A')
   BEGIN
      UPDATE m2ref
         SET m2refstat = 'D'
       WHERE m2refid = @cmp_id
   END
--JLB PTS 23133  If there is a pending add row present delete it
   ELSE
   BEGIN
      DELETE m2ref
       WHERE m2refid = @cmp_id
         AND m2refstat = 'A'
   END

   -- PTS 34536 -- BL (start)
   IF EXISTS(SELECT not_number
               FROM notes
              WHERE nre_tablekey = @cmp_id
                AND ntb_table = 'company')
   BEGIN
      DELETE notes
       WHERE nre_tablekey = @cmp_id
         AND ntb_table = 'company'
   END
   -- PTS 34536 -- BL (end)

	delete from expiration where exp_id = @CMP_id and exp_idtype = 'CMP' --PTS 39866

	-- PTS 39796 -- TJH (start)
	IF EXISTS (select * from INFORMATION_SCHEMA.tables where table_name = 'FuelRelations')
	BEGIN
		DELETE FuelRelations WHERE BillTo = @cmp_id OR Pickup = @cmp_id OR Delivery = @cmp_id OR Supplier = @cmp_id OR AccountOf = @cmp_id
	END
	-- PTS 39796 -- TJH (end)
	--PTS 62566 SGB If 	cmp_chg_requirements exist for company delete them
	IF EXISTS (select * from cmp_chg_requirements where ccr_billto in (select cmp_id from deleted))
	BEGIN
		DELETE cmp_chg_requirements
		FROM cmp_chg_requirements ccr
		join deleted d
		on d.cmp_id = ccr.ccr_billto
	END
	--PTS END 62566 SGB 
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* PTS20988 MBR 01/30/04 */
CREATE TRIGGER [dbo].[it_company] ON [dbo].[company]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @maptuit_geocode  	char(1),
        @cmp_id            	varchar(8),
 	@cmp_name	  	varchar(100),
   	@cmp_address1	   	varchar(100),
   	@cmp_address2	   	varchar(100),
   	@cmp_zip	   	varchar(10),
   	@cmp_primaryphone  	varchar(20),
	@cmp_maptuit_customnote	varchar(512),
	@cmp_city		int,
	@cty_name		varchar(18),
	@cty_state		varchar(6),
	@contact		varchar(50), 
    @crmtype		varchar(6) 

	--PTS 84589
	if NOT EXISTS (select top 1 * from inserted)
    return

--JLB PTS 26950
if (select count(*) from inserted) = 1
  begin
	if (select right(cmp_name,1) from inserted) = ' ' or (select left(cmp_name,1) from inserted) = ' '
	begin
		update company
			set cmp_name = rtrim(ltrim(inserted.cmp_name))
			from inserted
		where inserted.cmp_id = company.cmp_id
	end
	
	-- PTS 30587 -- BL (start)
	if (select isnull(cmp_lastmb, '') from inserted) = '' OR (select rtrim(ltrim(cmp_lastmb)) from inserted) = ''
	begin
		update company
			set cmp_lastmb = getdate()
		from inserted
		where inserted.cmp_id = company.cmp_id
	end

	if (select isnull(cmp_updateddate, '') from inserted) = '' OR (select rtrim(ltrim(cmp_updateddate)) from inserted) = ''
	begin
		update company
			set cmp_updateddate = getdate()
		from inserted
		where inserted.cmp_id = company.cmp_id
	end
	-- PTS 30587 -- BL (end)
  end
--end 26950

   SELECT @maptuit_geocode = Upper(isnull(gi_string1,'N'))
     FROM generalinfo
    WHERE gi_name = 'MaptuitGeocode'
   IF @maptuit_geocode = 'Y'
   BEGIN
      SELECT @cmp_id = cmp_id,
	     @cmp_name = cmp_name,
             @cmp_address1 = cmp_address1,
             @cmp_address2 = cmp_address2,
             @cmp_zip = cmp_zip,
             @cmp_primaryphone = cmp_primaryphone,
             @cmp_maptuit_customnote = cmp_maptuit_customnote,
             @cmp_city = cmp_city 
        FROM inserted
      SELECT @cty_name = cty_name,
             @cty_state = cty_state
        FROM city
       WHERE cty_code = @cmp_city

      INSERT INTO m2ref (m2refid, m2refname, m2refaddr, m2refaddr2,m2refcity,m2refstate,
                         m2refzip, m2refphone, m2refnotes, m2refstat, m2refcrtdt)
                 VALUES (@cmp_id, @cmp_name, @cmp_address1, @cmp_address2, @cty_name, @cty_state,
                         @cmp_zip, @cmp_primaryphone, @cmp_maptuit_customnote, 'A', GETDATE())
   END

	--PTS 28370 11/25/05 JJF update the cmp_creditavail_update field if 
	--cmp_creditavail is modified
	UPDATE 	company
	SET 	cmp_creditavail_update = getdate()
	FROM 	inserted
	WHERE 	company.cmp_id = inserted.cmp_id
		AND inserted.cmp_creditavail IS NOT NULL


-- 34081
if (select count(*) from inserted) = 1
select @contact = (select cmp_contact from inserted)

if isnull(@contact,'') <> '' 
begin

if not exists (select 1 from companyemail inner join inserted on companyemail.cmp_id = inserted.cmp_id 
	and companyemail.contact_name = inserted.cmp_contact )
	AND COALESCE((SELECT TOP 1 gi_string1 FROM generalinfo WHERE gi_name = 'UpdateCompanyContactOnTriggers'), 'Y') = 'Y'

	Begin
		Select @cmp_id = min(cmp_id) 
		from inserted
		where cmp_primaryphone is not null OR
			cmp_faxphone is not null OR
			cmp_contact is not null OR 
			cmp_primaryphoneext is not null or
			cmp_secondaryphone is not null or
			cmp_secondaryphoneext is not null

		while @cmp_id is not null
		Begin
			update companyemail
			set ce_defaultcontact = 'N'
			where cmp_id = @cmp_id and ce_defaultcontact = 'Y'

			insert into companyemail (cmp_id, 
				contact_name,
				ce_phone1, 
				ce_phone1_ext, 
				ce_faxnumber, 				
				ce_phone2, 
				ce_phone2_ext,
				ce_defaultcontact,
				ce_source,
				type,
				mail_default)


			select 	@cmp_id, 
				cmp_contact, 
				cmp_primaryphone, 
				cmp_primaryphoneext, 
				cmp_faxphone, 				
				cmp_secondaryphone, 
				cmp_secondaryphoneext,
				'Y',
				'CMP',
				'S',
				'N'
		
			from inserted	
			where inserted.cmp_id = @cmp_id

			-- Get the Next Company ID
			Select @cmp_id = min(cmp_id) 
			from inserted
			where cmp_id > @cmp_id 
				AND (cmp_primaryphone is not null OR
				cmp_faxphone is not null OR
				cmp_contact is not null OR 
				cmp_primaryphoneext is not null or
				cmp_secondaryphone is not null or
				cmp_secondaryphoneext is not null)
		End
	End
end

-- JET - 1/2/2007 - PTS35604, add default paperwork types for new bill to customers
declare @application varchar(256),
        @cmpid varchar(8)
select @application = app_name()

if (select count(moduleid) from ttsmodules where app_name() = moduleid or app_name() = modulename) < 1
begin
	select @cmpid = MIN(cmp_id) from inserted where cmp_billto = 'Y'
    while len(@cmpid) > 0
	begin
		execute insert_company_paperwork @cmpid

		select @cmpid = MIN(cmp_id) from inserted where cmp_billto = 'Y' and cmp_id > @cmpid
	end
end

-- JET - 9/16/09 - PTS49071, CRM Audit Logging.
if isnull((select gi_string1 from generalinfo where gi_name = 'CRMAuditTasks'), 'N') = 'Y'
begin
	select @cmpid = MIN(cmp_id) from inserted where isnull(cmp_crmtype, 'UNK') <> 'UNK' 
    while len(@cmpid) > 0
	begin
		exec dbo.CRMAuditTask_sp @cmpid, 'New Customer Audit', 'New customer was added to the database'

		select @crmtype = cmp_crmtype from company where cmp_id = @cmpid
		if @crmtype = 'PNDCDT' 
			exec dbo.CRMAuditTask_sp @cmpid, 'CREDIT REVIEW', 'Pending Credit Review for new customer'

		select @cmpid = MIN(cmp_id) from inserted where  isnull(cmp_crmtype, 'UNK') <> 'UNK' and cmp_id > @cmpid 
	end
end

--PTS83919 JJF (SB CRE) 20141104 - Added 58081 to support audits upon insert
--Begin PTS58081 AVANE 20110729, PTS 58411 AVANE 20110811

declare @assetProfileLogging char(1)
select @assetProfileLogging = ISNULL((SELECT TOP 1 gi_string1 from generalinfo (nolock) where gi_name = 'EnableAssetProfileLogging'), 'Y')

--apply if the gi setting EnableAssetProfileLogging <> 'N'
if(@assetProfileLogging = 'Y')
begin
	declare @currentTime datetime, @currentUser varchar(255), @res_type varchar(8), @lbl_category varchar(16)

	exec gettmwuser @currentUser output
	select @currentTime = GETDATE()
	select @res_type = 'Company'

	if(update(cmp_revtype1))
	begin
		select @lbl_category = 'RevType1'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_revtype1, 'UNK'), 
			Case when d.cmp_revtype1 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_revtype1), 'UNKNOWN') end,
			i.cmp_revtype1,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_revtype1), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_revtype1
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_revtype1 is not NULL 
			and Coalesce(d.cmp_revtype1, '') <> i.cmp_revtype1 
			and apl.res_id is null
	end
		
	if(update(cmp_revtype2))
	begin
		select @lbl_category = 'RevType2'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_revtype2, 'UNK'), 
			Case when d.cmp_revtype2 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_revtype2), 'UNKNOWN') end,
			i.cmp_revtype2,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_revtype2), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_revtype2
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_revtype2 is not NULL 
			and Coalesce(d.cmp_revtype2, '') <> i.cmp_revtype2
			and apl.res_id is null
	end
		
	if(update(cmp_revtype3))
	begin
		select @lbl_category = 'RevType3'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_revtype3, 'UNK'), 
			Case when d.cmp_revtype3 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_revtype3), 'UNKNOWN') end,
			i.cmp_revtype3,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_revtype3), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_revtype3
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_revtype3 is not NULL 
			and Coalesce(d.cmp_revtype3, '') <> i.cmp_revtype3
			and apl.res_id is null
	end
		
	if(update(cmp_revtype4))
	begin
		select @lbl_category = 'RevType4'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_revtype4, 'UNK'), 
			Case when d.cmp_revtype4 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_revtype4), 'UNKNOWN') end,
			i.cmp_revtype4,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_revtype4), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_revtype4
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_revtype4 is not NULL 
			and Coalesce(d.cmp_revtype4, '') <> i.cmp_revtype4
			and apl.res_id is null
	end
		
	if(update(cmp_othertype1))
	begin
		select @lbl_category= 'OtherTypes1'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_othertype1, 'UNK'), 
			Case when d.cmp_othertype1 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_othertype1), 'UNKNOWN') end,
			i.cmp_othertype1,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_othertype1), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_othertype1
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_othertype1 is not NULL 
			and Coalesce(d.cmp_othertype1, '') <> i.cmp_othertype1
			and apl.res_id is null
	end
		
	if(update(cmp_othertype2))
	begin
		select @lbl_category = 'OtherTypes2'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_othertype2, 'UNK'), 
			Case when d.cmp_othertype2 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_othertype2), 'UNKNOWN') end,
			i.cmp_othertype2,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_othertype2), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_othertype2
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_othertype2 is not NULL 
			and Coalesce(d.cmp_othertype2, '') <> i.cmp_othertype2
			and apl.res_id is null
	end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE trigger [dbo].[iut_company_InvSrvLog] on [dbo].[company] for update, insert
as 
	set nocount on
	
	if (select count(*) from (select top 2 cmp_name from inserted) a) = 1
	begin
		insert company_InvSrvChangeLog(cmp_id, LogDate,	 UserID, cmp_InvSrvMode, cmp_InvSrvReleaseOnly, cmp_ForecastBatch, cmp_SalesHistoryBatch)
		select cmp_id, getdate(), suser_sname(), cmp_InvSrvMode, cmp_InvSrvReleaseOnly, cmp_ForecastBatch, cmp_SalesHistoryBatch from inserted 
		where update(cmp_InvSrvMode) or update(cmp_InvSrvReleaseOnly) or update(cmp_ForecastBatch) or update(cmp_SalesHistoryBatch)
	end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_set_nmstct_for_company]
on [dbo].[company] for insert,	update
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
if update(cmp_city) 
	update company 
	set 
	cty_nmstct = city.cty_nmstct,
	cmp_state = city.cty_state,
	cmp_region1 = city.cty_region1,
   cmp_region2 = city.cty_region2,
   cmp_region3 = city.cty_region3,
   cmp_region4 = city.cty_region4
   from company, inserted, city 
	where company.cmp_id = inserted.cmp_id and
	inserted.cmp_city = city.cty_code

if update(cmp_mailto_city) 
	update company 
	set mailto_cty_nmstct = city.cty_nmstct,
		cmp_mailto_state = city.cty_state
   	from company, inserted, city 
	where company.cmp_id = inserted.cmp_id and
		inserted.cmp_mailto_city = city.cty_code
return

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_addthirdparty] ON [dbo].[company]
FOR INSERT, UPDATE AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @old_cmp_service_location char(1),
                      @new_cmp_service_location char(1),
                      @cmpid varchar(8)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

IF UPDATE(cmp_service_location)
BEGIN
     SELECT @old_cmp_service_location = cmp_service_location
         FROM deleted
     SELECT @new_cmp_service_location = cmp_service_location
         FROM inserted
     SELECT @cmpid = cmp_id
         FROM inserted

     IF (@old_cmp_service_location IS NULL OR @old_cmp_service_location = 'N') AND 
           @new_cmp_service_location = 'Y' 
     BEGIN
          IF EXISTS (SELECT tpr_id FROM thirdpartyprofile WHERE tpr_id = @cmpid)
          BEGIN
               UPDATE thirdpartyprofile SET tpr_service_location = 'Y'
                 WHERE tpr_id = @cmpid
          END
          ELSE
          BEGIN
               INSERT INTO thirdpartyprofile (tpr_id, tpr_name, tpr_address1, tpr_address2, 
                                                           tpr_city, tpr_zip, tpr_primaryphone, tpr_secondaryphone, 
                                                           tpr_service_location, tpr_updatedby, tpr_updateddate, 
                                                           tpr_createdate, tpr_active, tpr_actg_type, tpr_cty_nmstct)
                      SELECT cmp_id, cmp_name, cmp_address1, cmp_address2, cmp_city, 
                                        cmp_zip, cmp_primaryphone, cmp_secondaryphone, 'Y',
                                        UPPER(@tmwuser), GETDATE(), GETDATE(), 'Y','A', cty_nmstct
                          FROM inserted
          END
     END

     IF @old_cmp_service_location = 'Y' and @new_cmp_service_location = 'N'
     BEGIN
          UPDATE thirdpartyprofile SET tpr_service_location = null
            WHERE tpr_id = @cmpid
     END
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_company] ON [dbo].[company]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @maptuit_geocode  	char(1),
        @cmp_id            	varchar(8),
	@cmp_name	  	varchar(100),
	@cmp_address1	   	varchar(100),
	@cmp_address2	   	varchar(100),
	@cmp_zip	   	varchar(10),
	@cmp_primaryphone  	varchar(20),
	@cmp_maptuit_customnote	varchar(512),
	@cmp_city		int,
	@cty_name		varchar(18),
	@cty_state		varchar(6),
	@tmwuser      varchar(255),
	@cmp_phone1 varchar(20),
	@cmp_phone1_ext varchar(5),
	@cmp_phone2 varchar(20),
	@cmp_phone2_ext varchar(5),
	@cmp_fax varchar(20),
	@cmp_contact varchar (30)

	--PTS 84589
	if NOT EXISTS (select top 1 * from inserted)
    return

-- PTS 36688 CGK 4/2/2007 Removed logic since it only ever removes Manual Company to Company mileage.
--    if update(cmp_address1) or update(cmp_address2) or update(cmp_city) or update(cmp_zip)or update(cmp_id) 
-- 	begin	
-- 	   delete 
-- 	   from   mileagetable 
-- 	   where (mileagetable.mt_origintype = 'O' and mileagetable.mt_origin IN (SELECT CMP_ID FROM DELETED)) 
-- 	      or (mileagetable.mt_destinationtype = 'O' and mileagetable.mt_destination IN (SELECT CMP_ID FROM DELETED))		
--         end 
	--JLB PTS 26950
	if (select count(*) from inserted) = 1
	begin
		if (select right(cmp_name,1) from inserted) = ' ' or (select left(cmp_name,1) from inserted) = ' '
		begin
			update company
				set cmp_name = rtrim(ltrim(inserted.cmp_name))
				from inserted
			where inserted.cmp_id = company.cmp_id
		end
		-- PTS 31210 -- BL (start)
		if (select isnull(cmp_lastmb, '') from inserted) = '' OR (select rtrim(ltrim(cmp_lastmb)) from inserted) = ''
		begin
			update company
				set cmp_lastmb = getdate()
			from inserted
			where inserted.cmp_id = company.cmp_id
		end
	
		if (select isnull(cmp_updateddate, '') from inserted) = '' OR (select rtrim(ltrim(cmp_updateddate)) from inserted) = ''
		begin
			update company
				set cmp_updateddate = getdate()
			from inserted
			where inserted.cmp_id = company.cmp_id
		end
		-- PTS 31210 -- BL (end)
	end
	--end 26950
   /* PTS20988 MBR 01/30/04 */
   SELECT @maptuit_geocode = Upper(isnull(gi_string1,'N'))
     FROM generalinfo
    WHERE gi_name = 'MaptuitGeocode'
   IF (UPDATE(cmp_address1) OR UPDATE(cmp_address2) OR UPDATE(cmp_city) OR UPDATE(cmp_zip) OR
      UPDATE(cmp_maptuit_customnote)) AND @maptuit_geocode = 'Y'
   BEGIN
      SELECT @cmp_id = cmp_id,
	     @cmp_name = cmp_name,
             @cmp_address1 = cmp_address1,
             @cmp_address2 = cmp_address2,
             @cmp_zip = cmp_zip,
             @cmp_primaryphone = cmp_primaryphone,
             @cmp_maptuit_customnote = cmp_maptuit_customnote,
             @cmp_city = cmp_city 
        FROM inserted
      SELECT @cty_name = cty_name,
             @cty_state = cty_state
        FROM city
       WHERE cty_code = @cmp_city
      IF EXISTS (SELECT m2refid 
                   FROM m2ref
                  WHERE m2refid = @cmp_id)
      BEGIN
         UPDATE m2ref
            SET m2refname = @cmp_name,
                m2refaddr = @cmp_address1,
                m2refaddr2 = @cmp_address2,
                m2refcity = @cty_name,
                m2refstate = @cty_state,
                m2refzip = @cmp_zip,
                m2refphone = @cmp_primaryphone,
                m2refnotes = @cmp_maptuit_customnote,
                m2refstat = 'U',
                m2refcrtdt = GETDATE()
          WHERE m2refid = @cmp_id
      END
   END
	--PTS 28370 11/25/05 JJF update the cmp_creditavail_update field if 
	--cmp_creditavail is updated AND cmp_creditavail_update is NOT updated
	IF (UPDATE(cmp_creditavail) AND NOT UPDATE(cmp_creditavail_update)) BEGIN
		UPDATE 	company
		SET 	cmp_creditavail_update = getdate()
		FROM 	inserted
		WHERE 	company.cmp_id = inserted.cmp_id
	END
   --JLB PTS 34408
   IF (UPDATE(cmp_last_call_note) OR UPDATE(cmp_next_call_date))
   begin
      exec gettmwuser @tmwuser output
      update company
         set cmp_last_call_date = getdate(),
             cmp_last_call_user = @tmwuser
        from inserted
       where company.cmp_id = inserted.cmp_id
   end
   --34408 end 

/* PTS 34081 - DJM - Enhace the Contact Management feature */
IF (UPDATE(cmp_primaryphone) or UPDATE(cmp_faxphone) or UPDATE(cmp_contact) or UPDATE(cmp_primaryphoneext) or UPDATE(cmp_secondaryphone) or UPDATE(cmp_secondaryphoneext))
AND COALESCE((SELECT TOP 1 gi_string1 FROM generalinfo WHERE gi_name = 'UpdateCompanyContactOnTriggers'), 'Y') = 'Y'
begin
	if not exists (select 1 from companyemail inner join inserted on companyemail.cmp_id = inserted.cmp_id and companyemail.contact_name = inserted.cmp_contact )
	Begin
		Select @cmp_id = min(cmp_id) 
		from inserted
		where cmp_primaryphone is not null OR
			cmp_faxphone is not null OR
			cmp_contact is not null OR 
			cmp_primaryphoneext is not null or
			cmp_secondaryphone is not null or
			cmp_secondaryphoneext is not null

		while @cmp_id is not null
		Begin

			select @cmp_contact = cmp_contact
			from inserted
			where cmp_id = @cmp_id
			if isnull(@cmp_contact, '') <> ''
			begin

				update companyemail
				set ce_defaultcontact = 'N'
				where cmp_id = @cmp_id and ce_defaultcontact = 'Y'
	
				insert into companyemail (cmp_id, 
					contact_name,
					ce_phone1, 
					ce_phone1_ext, 
					ce_faxnumber, 				
					ce_phone2, 
					ce_phone2_ext,
					ce_defaultcontact,
					ce_source,
					type,
					mail_default)
	
	
				select 	@cmp_id, 
					cmp_contact, 
					cmp_primaryphone, 
					cmp_primaryphoneext, 
					cmp_faxphone, 				
					cmp_secondaryphone, 
					cmp_secondaryphoneext,
					'Y',
					'CMP',
					'S',
					'N'
			
				from inserted	
				where inserted.cmp_id = @cmp_id
			end

			-- Get the Next Company ID
			Select @cmp_id = min(cmp_id) 
			from inserted
			where cmp_id > @cmp_id 
				AND (cmp_primaryphone is not null OR
				cmp_faxphone is not null OR
				cmp_contact is not null OR 
				cmp_primaryphoneext is not null or
				cmp_secondaryphone is not null or
				cmp_secondaryphoneext is not null)
		End
	End
	Else  -- contact exists in companyemail table.
	Begin
		Select @cmp_id = min(cmp_id) 
		from inserted
		where cmp_primaryphone is not null OR
			cmp_faxphone is not null OR
			cmp_contact is not null OR 
			cmp_primaryphoneext is not null or
			cmp_secondaryphone is not null or
			cmp_secondaryphoneext is not null

		while @cmp_id is not null
		Begin
			select @cmp_phone1 = cmp_primaryphone,
			@cmp_phone1_ext = cmp_primaryphoneext,
			@cmp_phone2 = cmp_secondaryphone,
			@cmp_phone2_ext = cmp_secondaryphoneext,
			@cmp_fax = cmp_faxphone,
			@cmp_contact = cmp_contact
			from inserted
			where cmp_id = @cmp_id

			if isnull(@cmp_contact, '') <> ''
			begin

				update companyemail
				set ce_defaultcontact = 'N'
				where cmp_id = @cmp_id and ce_defaultcontact = 'Y'	
				and contact_name <> @cmp_contact
				and ce_source = 'CMP'
	
				Declare	@ce_id		int
				
				select @ce_id = min(ce_id)
				from companyemail
				where cmp_id = @cmp_id and contact_name = @cmp_contact
				and ce_source = 'CMP'
				and (isnull(ce_phone1, 'XXX') <> isnull(@cmp_phone1, 'XXX')
					or isnull(ce_phone1_ext, 'XXX') <> isnull(@cmp_phone1_ext, 'XXX')
					or isnull(ce_phone2, 'XXX') <> isnull(@cmp_phone2, 'XXX')
					or isnull(ce_phone2_ext, 'XXX') <> isnull(@cmp_phone2_ext, 'XXX')
					or isnull(ce_faxnumber, 'XXX') <> isnull(@cmp_fax, 'XXX')
					or isnull(ce_defaultcontact, 'N') <> 'Y')		
	
				update companyemail
				set ce_phone1 = @cmp_phone1,
					ce_phone1_ext = @cmp_phone1_ext,
					ce_phone2 = @cmp_phone2,
					ce_phone2_ext = @cmp_phone2_ext,
					ce_faxnumber = @cmp_fax,
					ce_defaultcontact = 'Y',
					ce_source = 'CMP'
				where ce_id = @ce_id	
			end

			-- Get the Next Company ID
			Select @cmp_id = min(cmp_id) 
			from inserted
			where cmp_id > @cmp_id 
				AND (cmp_primaryphone is not null OR
				cmp_faxphone is not null OR
				cmp_contact is not null OR 
				cmp_primaryphoneext is not null)
		End
	End
end

-- JET - 9/16/09 - PTS49071, CRM Audit Logging.
declare @description varchar(255), 
        @cmpid varchar(8), 
        @crmtype varchar(6)
if isnull((select gi_string1 from generalinfo where gi_name = 'CRMAuditTasks'), 'N') = 'Y' and (UPDATE(cmp_revtype1) or UPDATE(cmp_revtype2) or UPDATE(cmp_revtype3) or UPDATE(cmp_revtype4) or UPDATE(cmp_bookingterminal) or UPDATE(cmp_active) or UPDATE(cmp_billto) or UPDATE(cmp_altid) or UPDATE(cmp_creditlimit) or UPDATE(cmp_crmtype))
begin
	declare @orgValue varchar(12), 
            @newValue varchar(12) 
	select @cmpid = MIN(cmp_id) from inserted where isnull(cmp_crmtype, 'UNK') <> 'UNK'
	set @description = ''
    while len(@cmpid) > 0
	begin
		if UPDATE(cmp_altid)
		begin
			select @orgValue = isnull(cmp_altid, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_altid, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = 'Alt Id has changed from ' + @orgValue + ' to ' + @newValue + ' '
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_revtype1)
		begin
			select @orgValue = isnull(cmp_revtype1, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_revtype1, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = 'RevType1'), 'RevType1')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_revtype2)
		begin
			select @orgValue = isnull(cmp_revtype2, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_revtype2, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = 'RevType2'), 'RevType2')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_revtype3)
		begin
			select @orgValue = isnull(cmp_revtype3, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_revtype3, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = 'RevType3'), 'RevType3')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_revtype4)
		begin
			select @orgValue = isnull(cmp_revtype4, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_revtype4, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = 'RevType4'), 'RevType4')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_bookingterminal)
		begin
			select @orgValue = isnull(cmp_bookingterminal, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_bookingterminal, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = isnull((select gi_string2 from generalinfo where gi_name = 'TrackBranch'), 'Branch')), 'Branch')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_crmtype)
		begin
			select @orgValue = isnull(cmp_crmtype, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_crmtype, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('CRM Type has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
 		if UPDATE(cmp_active)
		begin
			select @orgValue = isnull(cmp_active, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_active, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('Active flag has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
 		if UPDATE(cmp_billto)
		begin
			select @orgValue = isnull(cmp_billto, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_billto, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('Bill to flag has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
 		if UPDATE(cmp_parent)
		begin
			select @orgValue = isnull(cmp_parent, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_parent, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('Parent flag has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
 		if UPDATE(cmp_creditlimit)
		begin
			select @orgValue = isnull(convert(varchar(12), cmp_creditlimit), '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(convert(varchar(12), cmp_creditlimit), '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('credit limit has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end

		select @crmtype = cmp_crmtype from company where cmp_id = @cmpid
		if @crmtype = 'PNDCDT' 
			exec dbo.CRMAuditTask_sp @cmpid, 'CREDIT REVIEW', 'Pending Credit Review for existing customer'

		select @cmpid = MIN(cmp_id) from inserted where  isnull(cmp_crmtype, 'UNK') <> 'UNK' and cmp_id > @cmpid 
		set @description = ''
	end
end

--Begin PTS58081 AVANE 20110729, PTS 58411 AVANE 20110811
--PTS83919 JJF (SB CRE) 20141104 - change to left joins of deleted table to accommodate INSERTs
declare @assetProfileLogging char(1)
select @assetProfileLogging = ISNULL((SELECT TOP 1 gi_string1 from generalinfo (nolock) where gi_name = 'EnableAssetProfileLogging'), 'Y')

--apply if the gi setting EnableAssetProfileLogging <> 'N'
if(@assetProfileLogging = 'Y')
begin
	declare @currentTime datetime, @currentUser varchar(255), @res_type varchar(8), @lbl_category varchar(16)

	exec gettmwuser @currentUser output
	select @currentTime = GETDATE()
	select @res_type = 'Company'

	if(update(cmp_revtype1))
	begin
		select @lbl_category = 'RevType1'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_revtype1, 'UNK'), 
			Case when d.cmp_revtype1 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_revtype1), 'UNKNOWN') end,
			i.cmp_revtype1,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_revtype1), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_revtype1
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_revtype1 is not NULL 
			and Coalesce(d.cmp_revtype1, '') <> i.cmp_revtype1 
			and apl.res_id is null
	end
		
	if(update(cmp_revtype2))
	begin
		select @lbl_category = 'RevType2'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_revtype2, 'UNK'), 
			Case when d.cmp_revtype2 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_revtype2), 'UNKNOWN') end,
			i.cmp_revtype2,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_revtype2), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_revtype2
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_revtype2 is not NULL 
			and Coalesce(d.cmp_revtype2, '') <> i.cmp_revtype2
			and apl.res_id is null
	end
		
	if(update(cmp_revtype3))
	begin
		select @lbl_category = 'RevType3'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_revtype3, 'UNK'), 
			Case when d.cmp_revtype3 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_revtype3), 'UNKNOWN') end,
			i.cmp_revtype3,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_revtype3), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_revtype3
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_revtype3 is not NULL 
			and Coalesce(d.cmp_revtype3, '') <> i.cmp_revtype3
			and apl.res_id is null
	end
		
	if(update(cmp_revtype4))
	begin
		select @lbl_category = 'RevType4'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_revtype4, 'UNK'), 
			Case when d.cmp_revtype4 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_revtype4), 'UNKNOWN') end,
			i.cmp_revtype4,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_revtype4), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_revtype4
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_revtype4 is not NULL 
			and Coalesce(d.cmp_revtype4, '') <> i.cmp_revtype4
			and apl.res_id is null
	end
		
	if(update(cmp_othertype1))
	begin
		select @lbl_category= 'OtherTypes1'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_othertype1, 'UNK'), 
			Case when d.cmp_othertype1 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_othertype1), 'UNKNOWN') end,
			i.cmp_othertype1,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_othertype1), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_othertype1
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_othertype1 is not NULL 
			and Coalesce(d.cmp_othertype1, '') <> i.cmp_othertype1
			and apl.res_id is null
	end
		
	if(update(cmp_othertype2))
	begin
		select @lbl_category = 'OtherTypes2'
		insert into AssetProfileLog
			(res_id, res_type, lbl_category, lbl_original_value, lbl_original_name, lbl_value, lbl_name, created, effective, lastmodifiedby, lastupdatedon, appliedbysqljob, appliedon)
		select i.cmp_id, 
			@res_type, 
			@lbl_category, 
			ISNULL(d.cmp_othertype2, 'UNK'), 
			Case when d.cmp_othertype2 is null Then 'UNKNOWN' else ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = d.cmp_othertype2), 'UNKNOWN') end,
			i.cmp_othertype2,
			ISNULL((select top 1 name from labelfile (nolock) where labeldefinition = @lbl_category and abbr = i.cmp_othertype2), 'UNKNOWN'),
			@currentTime, 
			@currentTime, 
			@currentUser, 
			@currentTime, 
			'N', 
			@currentTime
		from inserted i 
			LEFT JOIN deleted d on d.cmp_id = i.cmp_id
			LEFT JOIN AssetProfileLog apl (nolock)  on i.cmp_id = apl.res_id
				and apl.lbl_category = @lbl_category
				and apl.lbl_value = i.cmp_othertype2
				and appliedon is NULL
				and appliedbysqljob = 'I' 
		where i.cmp_othertype2 is not NULL 
			and Coalesce(d.cmp_othertype2, '') <> i.cmp_othertype2
			and apl.res_id is null
	end
end

--End PTS58081 AVANE 20110729, PTS 58411 AVANE 20110811

--test code
--update company set cmp_address1 =  234 plaza place' where cmp_id = 'plamar'
--select * from company cmp, mileagetable mil where mil.mt_origin = cmp.cmp_id 
GO
CREATE NONCLUSTERED INDEX [dk_cmp_altid] ON [dbo].[company] ([cmp_altid]) INCLUDE ([cmp_name]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_bookingterminal] ON [dbo].[company] ([cmp_bookingterminal]) INCLUDE ([cmp_id]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_id] ON [dbo].[company] ([cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_cmp_inv_numeric_id] ON [dbo].[company] ([cmp_inv_numeric_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_mastercompany] ON [dbo].[company] ([cmp_mastercompany], [cmp_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_cmp_name] ON [dbo].[company] ([cmp_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_region1] ON [dbo].[company] ([cmp_region1]) INCLUDE ([cmp_city], [cmp_zip]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_region2] ON [dbo].[company] ([cmp_region2]) INCLUDE ([cmp_city], [cmp_zip]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_region3] ON [dbo].[company] ([cmp_region3]) INCLUDE ([cmp_city], [cmp_zip]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_region4] ON [dbo].[company] ([cmp_region4]) INCLUDE ([cmp_city], [cmp_zip]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cmp_revtype1_misc4] ON [dbo].[company] ([cmp_revtype1], [cmp_misc4]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cmp_revtype3] ON [dbo].[company] ([cmp_revtype3], [cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_zip] ON [dbo].[company] ([cmp_zip]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_external_id] ON [dbo].[company] ([external_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [company_INS_TIMESTAMP] ON [dbo].[company] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Company_timestamp] ON [dbo].[company] ([timestamp]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_453576654_13_14_60_1] ON [dbo].[company] ([cmp_othertype1], [cmp_othertype2], [cmp_transfertype], [cmp_id])
GO
CREATE STATISTICS [_dta_stat_453576654_60_1_13] ON [dbo].[company] ([cmp_transfertype], [cmp_id], [cmp_othertype1])
GO
GRANT DELETE ON  [dbo].[company] TO [public]
GO
GRANT INSERT ON  [dbo].[company] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company] TO [public]
GO
GRANT SELECT ON  [dbo].[company] TO [public]
GO
GRANT UPDATE ON  [dbo].[company] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'TABLE', N'company', 'TRIGGER', N'it_company'
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'TABLE', N'company', 'TRIGGER', N'ut_company'
GO
DECLARE @xp float
SELECT @xp=1.01

GO
DECLARE @xp float
SELECT @xp=1.01

GO
