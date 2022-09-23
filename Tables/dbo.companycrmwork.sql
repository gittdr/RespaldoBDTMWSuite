CREATE TABLE [dbo].[companycrmwork]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_n__043BDFFA] DEFAULT (''),
[cmp_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_city] [int] NULL,
[cmp_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_primaryphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_secondaryphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_faxphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_shipper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_s__05300433] DEFAULT ('N'),
[cmp_consingee] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_c__0624286C] DEFAULT ('N'),
[cmp_billto] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_b__07184CA5] DEFAULT ('N'),
[cmp_othertype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_o__080C70DE] DEFAULT ('UNK'),
[cmp_othertype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_o__09009517] DEFAULT ('UNK'),
[cmp_artype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_a__09F4B950] DEFAULT ('CSH'),
[cmp_invoicetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_i__0AE8DD89] DEFAULT ('INV'),
[cmp_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_r__0BDD01C2] DEFAULT ('UNK'),
[cmp_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_r__0CD125FB] DEFAULT ('UNK'),
[cmp_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_r__0DC54A34] DEFAULT ('UNK'),
[cmp_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_r__0EB96E6D] DEFAULT ('UNK'),
[cmp_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_a__0FAD92A6] DEFAULT ('Y'),
[cmp_opens_mo] [int] NULL,
[cmp_closes_mo] [int] NULL,
[cmp_creditlimit] [money] NULL CONSTRAINT [DF__companycr__cmp_c__10A1B6DF] DEFAULT ((0)),
[cmp_creditavail] [money] NULL CONSTRAINT [DF__companycr__cmp_c__1195DB18] DEFAULT ((0)),
[cmp_mileagetable] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mastercompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_m__1289FF51] DEFAULT ('UNKNOWN'),
[cmp_terms] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_defaultbillto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_d__137E238A] DEFAULT ('UNKNOWN'),
[cmp_edi214] [int] NULL CONSTRAINT [DF__companycr__cmp_e__147247C3] DEFAULT ((0)),
[cmp_edi210] [int] NULL CONSTRAINT [DF__companycr__cmp_e__15666BFC] DEFAULT ((0)),
[cmp_edi204] [int] NULL,
[cmp_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_r__165A9035] DEFAULT ('UNK'),
[cmp_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_r__174EB46E] DEFAULT ('UNK'),
[cmp_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_r__1842D8A7] DEFAULT ('UNK'),
[cmp_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_r__1936FCE0] DEFAULT ('UNK'),
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
[cmp_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_directions] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mbdays] [smallint] NULL CONSTRAINT [DF__companycr__cmp_m__1A2B2119] DEFAULT ((1)),
[cmp_lastmb] [datetime] NULL CONSTRAINT [DF__companycr__cmp_l__1B1F4552] DEFAULT (getdate()),
[cmp_invcopies] [smallint] NULL CONSTRAINT [DF__companycr__cmp_i__1C13698B] DEFAULT ((1)),
[cmp_transfertype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_t__1D078DC4] DEFAULT ('INV'),
[cmp_altid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_u__1DFBB1FD] DEFAULT (suser_sname()),
[cmp_updateddate] [datetime] NULL CONSTRAINT [DF__companycr__cmp_u__1EEFD636] DEFAULT (getdate()),
[cmp_defaultpriority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_d__1FE3FA6F] DEFAULT ('UNK'),
[cmp_invoiceto] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_invformat] [int] NULL,
[cmp_invprintto] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_creditavail_update] [datetime] NULL CONSTRAINT [DF__companycr__cmp_c__20D81EA8] DEFAULT (getdate()),
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmd_c__21CC42E1] DEFAULT ('UNKNOWN'),
[junknotinuse] [datetime] NULL,
[cmp_agedinvflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_a__22C0671A] DEFAULT ('N'),
[cmp_max_dunnage] [int] NULL CONSTRAINT [DF__companycr__cmp_m__23B48B53] DEFAULT ((0)),
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
[cmp_createdate] [datetime] NULL CONSTRAINT [DF__companycr__cmp_c__24A8AF8C] DEFAULT (getdate()),
[cmp_taxtable1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_t__259CD3C5] DEFAULT ('Y'),
[cmp_taxtable2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_t__2690F7FE] DEFAULT ('Y'),
[cmp_taxtable3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_t__27851C37] DEFAULT ('N'),
[cmp_taxtable4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_t__28794070] DEFAULT ('N'),
[cmp_quickentry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_q__296D64A9] DEFAULT ('N'),
[cmp_slack_time] [int] NULL CONSTRAINT [DF__companycr__cmp_s__2A6188E2] DEFAULT ((0)),
[cmp_mailto_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_address1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_city] [int] NULL,
[cmp_mailto_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_latseconds] [int] NULL,
[cmp_longseconds] [int] NULL,
[cmp_mailto_crterm1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_m__2B55AD1B] DEFAULT ('ANY'),
[cmp_mailto_crterm2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_m__2C49D154] DEFAULT ('ANY'),
[cmp_mailto_crterm3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_m__2D3DF58D] DEFAULT ('ANY'),
[cmp_mbformat] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mbgroup] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_centroidcity] [int] NULL,
[cmp_centroidctynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_centroidzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_ooa_mileage] [float] NULL,
[cmp_ooa_mileage_stops] [float] NULL,
[cmp_mapaddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_usestreetaddr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_u__2E3219C6] DEFAULT ('N'),
[cmp_primaryphoneext] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_secondaryphoneext] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_palletcount] [int] NULL,
[cmp_fueltableid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grp_id] [int] NULL CONSTRAINT [DF__companycr__grp_i__2F263DFF] DEFAULT ((0)),
[cmp_parent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companycr__cmp_p__301A6238] DEFAULT ('N'),
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
[doc_language] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companycr__doc_l__310E8671] DEFAULT ('English'),
[cmp_image_routing1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_image_routing2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_image_routing3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_port] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companycr__cmp_p__3202AAAA] DEFAULT ('N'),
[cmp_depot] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companycr__cmp_d__32F6CEE3] DEFAULT ('N'),
[cmp_addcurrencysurcharge] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltsl_auto_add_pul_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltsl_default_pickup_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltsl_default_delivery_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_make_payto] [int] NOT NULL CONSTRAINT [DF__companycr__cmp_m__33EAF31C] DEFAULT ((0)),
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
[cmp_bookingterminal] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companycr__cmp_b__34DF1755] DEFAULT ('UNKNOWN'),
[cmp_det_increment] [int] NULL,
[cmp_det_rounding] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_det_threshold] [int] NULL,
[cmp_det_override] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_avgstopminutes] [int] NULL,
[cmp_accountof] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_house_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_street_name] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_mailto_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_refnum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_GeoCodeRequested] [datetime] NULL,
[cmp_ICaccessorial] [int] NOT NULL CONSTRAINT [DF__companycr__cmp_I__35D33B8E] DEFAULT ((0)),
[cmp_ICaccessorialfactor] [decimal] (8, 4) NOT NULL CONSTRAINT [DF__companycr__cmp_I__36C75FC7] DEFAULT ((100.00)),
[cmp_stop_events] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_freestops] [int] NULL,
[cmp_stopevents_pay] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_freestops_pay] [int] NULL,
[cmp_billto_eligible_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[cmp_acc_gvt_rpt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_acc_id] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_BelongsTo] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhh_id] [int] NULL,
[cmp_firm_appt_value] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_toll_detail] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_refnum_gpinvxfer] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companycr__cmp_r__37BB8400] DEFAULT ('UNK'),
[cmp_invoiceby] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_volunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_wgtunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_servicedrp_rpt] [int] NULL,
[cmp_servicepup_rpt] [int] NULL,
[cmp_servicebillto_rpt] [int] NULL,
[cmp_rateallocation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_invoiceimageflag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_TollMethod] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_AvgFuelPriceDateOverride] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_statemiletype1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_statemiletype2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_splitbillonrefnbr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_stp_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_stp_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_crmtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_controlling_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_open_ivr_forward_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_closed_ivr_forward_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_inv_numeric_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_CreditHoldStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companycr__cmp_C__38AFA839] DEFAULT ('UNK'),
[cmp_CreditHoldComment] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_InvSrvReleaseOnly] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companycr__cmp_I__39A3CC72] DEFAULT ('N'),
[cmp_InvSrvMode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companycr__cmp_I__3A97F0AB] DEFAULT ('UNK'),
[cmp_ForecastBatch] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_SalesHistoryBatch] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_ForecasterLastReadingDate] [datetime] NULL,
[cmp_ForecasterLastRunDate] [datetime] NULL,
[rowsec_rsrv_id] [int] NULL,
[cmp_defaultstptype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_cmpcrm_defaultstptype1] DEFAULT ('UNK'),
[cmp_refnum_gpdocdescxfer] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_cmpcrm_refnum_gpdocdescxfer] DEFAULT ('UNK'),
[cmp_timezone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_othertype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_othertype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_invoice_when] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc5] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc6] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc7] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_misc8] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_sourcing_quotebillto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_companycrmwork_cmp_sourcing_quotebillto] DEFAULT ('UNKNOWN'),
[cmp_sourcing_quotetransbillto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_cmpcrmwork_sourcing_quotetransbillto] DEFAULT ('UNKNOWN'),
[cmp_sourcing_include_trans] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_companycrmwork_cmp_sourcing_include_trans] DEFAULT ('Y'),
[cmp_sourcing_include_taxes] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_cmpcrmwork_sourcing_include_taxes] DEFAULT ('Y'),
[cmp_sourcing_max_distance] [int] NULL CONSTRAINT [DF_companycrmwork_cmp_sourcing_max_distance] DEFAULT ((0)),
[cmp_dedicated_bill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_dedicated_usedate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_dedicated_datecycle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_billing_rating_engine] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_billto_spotquote] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppianDistanceFldData] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_custequipprefix] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_allow_tm_update] [tinyint] NULL,
[trl_freedays] [int] NOT NULL CONSTRAINT [DF__companycr__trl_f__093EBB63] DEFAULT ('0'),
[trl_maxcharge] [money] NULL,
[cmp_app_eqcodes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_companycrmwork_rowsec] ON [dbo].[companycrmwork]
FOR INSERT, UPDATE
AS
	DECLARE @COLUMNS_UPDATED_BIT_MASK varbinary(500)
	DECLARE @error int
	DECLARE @message varchar(1024)
	
	SELECT @COLUMNS_UPDATED_BIT_MASK = COLUMNS_UPDATED()
	
	SELECT cmp_id
	INTO #NewValues
	FROM inserted

	DECLARE @rowsecurity char(1)
	
	SELECT @rowsecurity = ISNULL(gi_string1, 'N') 
 	  FROM generalinfo 
	 WHERE gi_name = 'RowSecurity'

	IF @rowsecurity = 'Y' 
		exec RowSecUpdateRows_sp 'companycrmwork', @COLUMNS_UPDATED_BIT_MASK, @error out, @message out
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_companycrmwork] ON [dbo].[companycrmwork]
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

	if (select count(*) from inserted) = 1
	begin
		if (select right(cmp_name,1) from inserted) = ' ' or (select left(cmp_name,1) from inserted) = ' '
		begin
			update companycrmwork
				set cmp_name = rtrim(ltrim(inserted.cmp_name))
				from inserted
			where inserted.cmp_id = companycrmwork.cmp_id
		end
		if (select isnull(cmp_lastmb, '') from inserted) = '' OR (select rtrim(ltrim(cmp_lastmb)) from inserted) = ''
		begin
			update companycrmwork
				set cmp_lastmb = getdate()
			from inserted
			where inserted.cmp_id = companycrmwork.cmp_id
		end
	
		if (select isnull(cmp_updateddate, '') from inserted) = '' OR (select rtrim(ltrim(cmp_updateddate)) from inserted) = ''
		begin
			update companycrmwork
				set cmp_updateddate = getdate()
			from inserted
			where inserted.cmp_id = companycrmwork.cmp_id
		end
	end
	
	IF (UPDATE(cmp_creditavail) AND NOT UPDATE(cmp_creditavail_update)) BEGIN
		UPDATE 	companycrmwork
		SET 	cmp_creditavail_update = getdate()
		FROM 	inserted
		WHERE 	companycrmwork.cmp_id = inserted.cmp_id
	END
   
   IF (UPDATE(cmp_last_call_note) OR UPDATE(cmp_next_call_date))
   begin
      exec gettmwuser @tmwuser output
      update companycrmwork
         set cmp_last_call_date = getdate(),
             cmp_last_call_user = @tmwuser
        from inserted
       where companycrmwork.cmp_id = inserted.cmp_id
   end
   


-- CRM Audit Logging.
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
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_revtype1)
		begin
			select @orgValue = isnull(cmp_revtype1, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_revtype1, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = 'RevType1'), 'RevType1')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_revtype2)
		begin
			select @orgValue = isnull(cmp_revtype2, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_revtype2, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = 'RevType2'), 'RevType2')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_revtype3)
		begin
			select @orgValue = isnull(cmp_revtype3, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_revtype3, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = 'RevType3'), 'RevType3')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_revtype4)
		begin
			select @orgValue = isnull(cmp_revtype4, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_revtype4, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = 'RevType4'), 'RevType4')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_bookingterminal)
		begin
			select @orgValue = isnull(cmp_bookingterminal, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_bookingterminal, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = (isnull((select top 1 l.userlabelname from labelfile l where l.labeldefinition = isnull((select gi_string2 from generalinfo where gi_name = 'TrackBranch'), 'Branch')), 'Branch')  + ' has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
		if UPDATE(cmp_crmtype)
		begin
			select @orgValue = isnull(cmp_crmtype, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_crmtype, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('CRM Type has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
 		if UPDATE(cmp_active)
		begin
			select @orgValue = isnull(cmp_active, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_active, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('Active flag has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
 		if UPDATE(cmp_billto)
		begin
			select @orgValue = isnull(cmp_billto, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_billto, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('Bill to flag has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
 		if UPDATE(cmp_parent)
		begin
			select @orgValue = isnull(cmp_parent, '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(cmp_parent, '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('Parent flag has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end
 		if UPDATE(cmp_creditlimit)
		begin
			select @orgValue = isnull(convert(varchar(12), cmp_creditlimit), '') from deleted where cmp_id = @cmpid
			select @newValue = isnull(convert(varchar(12), cmp_creditlimit), '') from inserted where cmp_id = @cmpid
			
			if @orgValue <> @newValue or (@orgValue is not NULL and @newValue is NULL)
			begin
				select @description = ('credit limit has changed from ' + @orgValue + ' to ' + @newValue + ' ')
				exec dbo.CRMWorkAuditTask_sp @cmpid, 'Customer Audit', @description 
			end
		end

		select @crmtype = cmp_crmtype from companycrmwork where cmp_id = @cmpid
		if @crmtype = 'PNDCDT' 
			exec dbo.CRMWorkAuditTask_sp @cmpid, 'CREDIT REVIEW', 'Pending Credit Review for existing customer'

		select @cmpid = MIN(cmp_id) from inserted where  isnull(cmp_crmtype, 'UNK') <> 'UNK' and cmp_id > @cmpid 
		set @description = ''
	end
end
GO
ALTER TABLE [dbo].[companycrmwork] ADD CONSTRAINT [Pkey_companycrmwork] PRIMARY KEY CLUSTERED ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[companycrmwork] TO [public]
GO
GRANT INSERT ON  [dbo].[companycrmwork] TO [public]
GO
GRANT SELECT ON  [dbo].[companycrmwork] TO [public]
GO
GRANT UPDATE ON  [dbo].[companycrmwork] TO [public]
GO
