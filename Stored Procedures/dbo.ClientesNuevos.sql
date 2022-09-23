SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ClientesNuevos] (@accion int )
	-- Add the parameters for the stored procedure here
	
AS

if (@accion = 1)
begin

	SELECT c.CMP_ID AS ID_EMPRESA,c.CMP_NAME NOMBRE_COMPANIA, c.CMP_CRMTYPE ESTATUS , CE_FNAME +' ' + CONTACT_NAME AS NOMBRE, EMAIL_ADDRESS CORREO,TYPE TIPO_DE_CONTACTO,
	 CE_PHONE1 TELEFONO, CE_MOBILENUMBER CELULAR , c.cmp_createdate as fechaRegistro
		from  [dbo].[company] c inner join COMPANYEMAIL cp on c.CMP_ID = cp.CMP_ID
		WHERE c.CMP_CRMTYPE = 'NEW' AND c.cmp_id NOT IN (SELECT CMP_ID FROM [dbo].clientes_nuevos)
		
	insert into [dbo].clientes_nuevos (cmp_id, cmp_name, cmp_address1, cmp_address2, cmp_city, cmp_zip, cmp_primaryphone, cmp_secondaryphone, cmp_faxphone, cmp_shipper, cmp_consingee, cmp_billto, cmp_othertype1, cmp_othertype2, cmp_artype, cmp_invoicetype, cmp_revtype1, cmp_revtype2, cmp_revtype3, cmp_revtype4, cmp_currency, cmp_active, cmp_opens_mo, cmp_closes_mo, cmp_creditlimit, cmp_creditavail, cmp_mileagetable, cmp_mastercompany, cmp_terms, cmp_defaultbillto, cmp_edi214, cmp_edi210, cmp_edi204, cmp_state, cmp_region1, cmp_region2, cmp_region3, cmp_region4, cmp_addnewshipper, cmp_opensun, cmp_openmon, cmp_opentue, cmp_openwed, cmp_openthu, cmp_openfri, cmp_opensat, cmp_payfrom, cmp_mapfile, cmp_contact, cmp_directions, cty_nmstct, cmp_misc1, cmp_misc2, cmp_misc3, cmp_misc4, cmp_mbdays, cmp_lastmb, cmp_invcopies, cmp_transfertype, cmp_altid, cmp_updatedby, cmp_updateddate, cmp_defaultpriority, cmp_invoiceto, cmp_invformat, cmp_invprintto, cmp_creditavail_update, cmd_code, junknotinuse, cmp_agedinvflag, cmp_max_dunnage, cmp_acc_balance, cmp_acc_dt, cmp_opens_tu, cmp_closes_tu, cmp_opens_we, cmp_closes_we, cmp_opens_th, cmp_closes_th, cmp_opens_fr, cmp_closes_fr, cmp_opens_sa, cmp_closes_sa, cmp_opens_su, cmp_closes_su, cmp_subcompany, cmp_createdate, cmp_taxtable1, cmp_taxtable2, cmp_taxtable3, cmp_taxtable4, cmp_quickentry, cmp_slack_time, cmp_mailto_name, cmp_mailto_address1, cmp_mailto_address2, cmp_mailto_city, cmp_mailto_state, cmp_mailto_zip, mailto_cty_nmstct, cmp_latseconds, cmp_longseconds, cmp_mailto_crterm1, cmp_mailto_crterm2, cmp_mailto_crterm3, cmp_mbformat, cmp_mbgroup, cmp_centroidcity, cmp_centroidctynmstct, cmp_centroidzip, cmp_ooa_mileage, cmp_ooa_mileage_stops, cmp_mapaddress, cmp_usestreetaddr, cmp_primaryphoneext, cmp_secondaryphoneext, cmp_palletcount, cmp_fueltableid, grp_id, cmp_parent, cmp_country, cmp_address3, cmp_slacktime_late, cmp_geoloc, cmp_geoloc_forsearch, cmp_min_charge, cmp_service_location, cmp_psoverride, cmp_MailtToForLinehaulFlag, cmp_mailtoTermsMatchFlag, cmp_max_weight, cmp_max_weightunits, cmp_ivformat, cmp_ivgroup, cmp_taxid, cmp_gp_class, doc_language, cmp_image_routing1, cmp_image_routing2, cmp_image_routing3, cmp_port, cmp_depot, cmp_addcurrencysurcharge, ltsl_auto_add_pul_flag, ltsl_default_pickup_event, ltsl_default_delivery_event, cmp_PUPTimeAllowance, cmp_DRPTimeAllowance, cmp_maxdetmins, cmp_detcontacts, cmp_allowdetcharges, cmp_latlongverifications, cmp_maptuit_customnote, external_id, external_type, cmp_currencysurchargebase, cmp_TrlConfiguration, cmp_service_location_qual, cmp_service_location_own, cmp_service_location_rating, cmp_MileSearchLevel, cmp_det_start, cmp_det_apply_if_late, cmp_reftype_unique, cmp_PUPalert, cmp_DRPalert, cmp_det_apply_if_early, cmp_senddetalert, cmp_leadtime, cmp_railramp, cmp_athome_location, cmp_thirdpartytype1, cmp_thirdpartytype2, cmp_aceidtype, cmp_aceid, cmp_TMlatseconds, cmp_TMlongseconds, cmp_TMdistancetolatlong, cmp_TMlatlongdate, cmp_dimoverride, cmp_supplier, cmp_overrideapplyhighestrate, cmp_rbd_FlatRateOption, cmp_MinLHAdj, cmp_RateBy, cmp_rbd_highrateoption, cmp_last_call_date, cmp_last_call_note, cmp_last_call_user, cmp_next_call_date, cmp_SchdEarliestDateOverride, cmp_bookingterminal, cmp_ICaccessorial, cmp_ICaccessorialfactor, cmp_GeoCodeRequested, cmp_det_increment, cmp_det_rounding, cmp_det_threshold, cmp_det_override, cmp_stop_events, cmp_freestops, cmp_stopevents_pay, cmp_freestops_pay, cmp_MonObsHolFlag, cmp_TueObsHolFlag, cmp_WedObsHolFlag, cmp_ThuObsHolFlag, cmp_FriObsHolFlag, cmp_SatObsHolFlag, cmp_SunObsHolFlag, cmp_FromHrDateAdj, holiday_group, cmp_Payment_terms, cmp_blended_min_qty, cmp_minchargeoption, cmp_BelongsTo, cmp_acc_gvt_rpt, cmp_acc_id, cmp_refnum, cmp_statemiletype1, cmp_statemiletype2, cmp_splitbillonrefnbr, cmp_inv_toll_detail, cmp_refnum_gpinvxfer, cmp_avgstopminutes, cmp_accountof, cmp_house_number, cmp_street_name, cmp_mailto_country, cmp_billto_eligible_flag, cmp_stp_type2, cmp_stp_type3, cmp_crmtype, cmp_inv_controlling_cmp_id, cmp_inv_open_ivr_forward_number, cmp_inv_closed_ivr_forward_number, cmp_inv_numeric_id, cmp_firm_appt_value, cmp_CreditHoldStatus, cmp_CreditHoldComment, cmp_InvSrvReleaseOnly, cmp_InvSrvMode, cmp_ForecastBatch, cmp_SalesHistoryBatch, cmp_ForecasterLastReadingDate, cmp_ForecasterLastRunDate, cmp_ivr_pin, cmp_dedicated_bill, cmp_dedicated_usedate, cmp_dedicated_datecycle, cmp_sourcing_include_trans, cmp_sourcing_include_taxes, cmp_sourcing_max_distance, cmp_sourcing_quote_type, cmp_sourcing_quotebillto, cmp_sourcing_quotetransbillto, rowsec_rsrv_id, cmp_defaultstptype1, cmp_hiddenid, rhh_id, cmp_invoiceby, cmp_volunits, cmp_wgtunits, cmp_rateallocation, cmp_invoiceimageflag, cmp_TollMethod, cmp_AvgFuelPriceDateOverride, cmp_autobill, cmp_autobill_terms, cmp_refnum_gpdocdescxfer, cmp_timezone, cmp_misc5, cmp_misc6, cmp_misc7, cmp_misc8, cmp_useboldates, cmp_sendarrivalalert, cmp_senddeparturealert, cmp_cmdvalue, cmp_mb_breaktype, cmp_mb_breakvalue, cmp_ar_transfer_nonbundled, cmp_defaultcons, cmp_pophubmilesflag, cmp_servicedrp_rpt, cmp_servicepup_rpt, cmp_servicebillto_rpt, cmp_invoice_when, cmp_mbdayofmonth, cmp_RateEachPickDrop, cmp_inv_audit, cmp_othertype3, cmp_othertype4, cmp_billing_rating_engine, cmp_app_eqcodes, cmp_dbh_custinvnum_prefix, cmp_dbh_custinvnum_startnum, cmp_dbh_custinvnum_digits, cmp_TaxGroup, cmp_UseDips, cmp_billto_spotquote, cmp_custequipprefix, AppianDistanceFldData, cmp_allow_tm_update, cmp_isbond, cmp_doublesdrop_location, cmp_primaryflagrequired, cmp_terminal, cmp_ctw_conv, cmp_ctw_break, cmp_wtc_conv, cmp_ctw_weightunits, cmp_ctw_volumeunits, cmp_yard_type, cmp_btm_toll_mileagetable, cmp_etawcbillto, trl_freedays, trl_maxcharge, cmp_DRBack, cmp_DROut)
	   SELECT cmp_id, cmp_name, cmp_address1, cmp_address2, cmp_city, cmp_zip, cmp_primaryphone, cmp_secondaryphone, cmp_faxphone, cmp_shipper, cmp_consingee, cmp_billto, cmp_othertype1, cmp_othertype2, cmp_artype, cmp_invoicetype, cmp_revtype1, cmp_revtype2, cmp_revtype3, cmp_revtype4, cmp_currency, cmp_active, cmp_opens_mo, cmp_closes_mo, cmp_creditlimit, cmp_creditavail, cmp_mileagetable, cmp_mastercompany, cmp_terms, cmp_defaultbillto, cmp_edi214, cmp_edi210, cmp_edi204, cmp_state, cmp_region1, cmp_region2, cmp_region3, cmp_region4, cmp_addnewshipper, cmp_opensun, cmp_openmon, cmp_opentue, cmp_openwed, cmp_openthu, cmp_openfri, cmp_opensat, cmp_payfrom, cmp_mapfile, cmp_contact, cmp_directions,cty_nmstct, cmp_misc1, cmp_misc2, cmp_misc3, cmp_misc4, cmp_mbdays, cmp_lastmb, cmp_invcopies, cmp_transfertype, cmp_altid, cmp_updatedby, cmp_updateddate, cmp_defaultpriority, cmp_invoiceto, cmp_invformat, cmp_invprintto, cmp_creditavail_update, cmd_code, junknotinuse, cmp_agedinvflag, cmp_max_dunnage, cmp_acc_balance, cmp_acc_dt, cmp_opens_tu, cmp_closes_tu, cmp_opens_we, cmp_closes_we, cmp_opens_th, cmp_closes_th, cmp_opens_fr, cmp_closes_fr, cmp_opens_sa, cmp_closes_sa, cmp_opens_su, cmp_closes_su, cmp_subcompany, cmp_createdate, cmp_taxtable1, cmp_taxtable2, cmp_taxtable3, cmp_taxtable4, cmp_quickentry, cmp_slack_time, cmp_mailto_name, cmp_mailto_address1, cmp_mailto_address2, cmp_mailto_city, cmp_mailto_state, cmp_mailto_zip, mailto_cty_nmstct, cmp_latseconds, cmp_longseconds, cmp_mailto_crterm1, cmp_mailto_crterm2, cmp_mailto_crterm3, cmp_mbformat, cmp_mbgroup, cmp_centroidcity, cmp_centroidctynmstct, cmp_centroidzip, cmp_ooa_mileage, cmp_ooa_mileage_stops, cmp_mapaddress, cmp_usestreetaddr, cmp_primaryphoneext, cmp_secondaryphoneext, cmp_palletcount, cmp_fueltableid, grp_id, cmp_parent, cmp_country, cmp_address3, cmp_slacktime_late, cmp_geoloc, cmp_geoloc_forsearch, cmp_min_charge, cmp_service_location, cmp_psoverride, cmp_MailtToForLinehaulFlag, cmp_mailtoTermsMatchFlag, cmp_max_weight, cmp_max_weightunits, cmp_ivformat, cmp_ivgroup, cmp_taxid, cmp_gp_class, doc_language, cmp_image_routing1, cmp_image_routing2, cmp_image_routing3, cmp_port, cmp_depot, cmp_addcurrencysurcharge, ltsl_auto_add_pul_flag, ltsl_default_pickup_event, ltsl_default_delivery_event, cmp_PUPTimeAllowance, cmp_DRPTimeAllowance, cmp_maxdetmins, cmp_detcontacts, cmp_allowdetcharges, cmp_latlongverifications, cmp_maptuit_customnote, external_id, external_type, cmp_currencysurchargebase, cmp_TrlConfiguration, cmp_service_location_qual, cmp_service_location_own, cmp_service_location_rating, cmp_MileSearchLevel, cmp_det_start, cmp_det_apply_if_late, cmp_reftype_unique, cmp_PUPalert, cmp_DRPalert, cmp_det_apply_if_early, cmp_senddetalert, cmp_leadtime, cmp_railramp, cmp_athome_location, cmp_thirdpartytype1, cmp_thirdpartytype2, cmp_aceidtype, cmp_aceid, cmp_TMlatseconds, cmp_TMlongseconds, cmp_TMdistancetolatlong, cmp_TMlatlongdate, cmp_dimoverride, cmp_supplier, cmp_overrideapplyhighestrate, cmp_rbd_FlatRateOption, cmp_MinLHAdj, cmp_RateBy, cmp_rbd_highrateoption, cmp_last_call_date, cmp_last_call_note, cmp_last_call_user, cmp_next_call_date, cmp_SchdEarliestDateOverride, cmp_bookingterminal, cmp_ICaccessorial, cmp_ICaccessorialfactor, cmp_GeoCodeRequested, cmp_det_increment, cmp_det_rounding, cmp_det_threshold, cmp_det_override, cmp_stop_events, cmp_freestops, cmp_stopevents_pay, cmp_freestops_pay, cmp_MonObsHolFlag, cmp_TueObsHolFlag, cmp_WedObsHolFlag, cmp_ThuObsHolFlag, cmp_FriObsHolFlag, cmp_SatObsHolFlag, cmp_SunObsHolFlag, cmp_FromHrDateAdj, holiday_group, cmp_Payment_terms, cmp_blended_min_qty, cmp_minchargeoption, cmp_BelongsTo, cmp_acc_gvt_rpt, cmp_acc_id, cmp_refnum, cmp_statemiletype1, cmp_statemiletype2, cmp_splitbillonrefnbr, cmp_inv_toll_detail, cmp_refnum_gpinvxfer, cmp_avgstopminutes, cmp_accountof, cmp_house_number, cmp_street_name, cmp_mailto_country, cmp_billto_eligible_flag, cmp_stp_type2, cmp_stp_type3, cmp_crmtype, cmp_inv_controlling_cmp_id, cmp_inv_open_ivr_forward_number, cmp_inv_closed_ivr_forward_number, cmp_inv_numeric_id, cmp_firm_appt_value, cmp_CreditHoldStatus, cmp_CreditHoldComment, cmp_InvSrvReleaseOnly, cmp_InvSrvMode, cmp_ForecastBatch, cmp_SalesHistoryBatch, cmp_ForecasterLastReadingDate, cmp_ForecasterLastRunDate, cmp_ivr_pin, cmp_dedicated_bill, cmp_dedicated_usedate, cmp_dedicated_datecycle, cmp_sourcing_include_trans, cmp_sourcing_include_taxes, cmp_sourcing_max_distance, cmp_sourcing_quote_type, cmp_sourcing_quotebillto, cmp_sourcing_quotetransbillto, rowsec_rsrv_id, cmp_defaultstptype1, cmp_hiddenid, rhh_id, cmp_invoiceby, cmp_volunits, cmp_wgtunits, cmp_rateallocation, cmp_invoiceimageflag, cmp_TollMethod, cmp_AvgFuelPriceDateOverride, cmp_autobill, cmp_autobill_terms, cmp_refnum_gpdocdescxfer, cmp_timezone, cmp_misc5, cmp_misc6, cmp_misc7, cmp_misc8, cmp_useboldates, cmp_sendarrivalalert, cmp_senddeparturealert, cmp_cmdvalue, cmp_mb_breaktype, cmp_mb_breakvalue, cmp_ar_transfer_nonbundled, cmp_defaultcons, cmp_pophubmilesflag, cmp_servicedrp_rpt, cmp_servicepup_rpt, cmp_servicebillto_rpt, cmp_invoice_when, cmp_mbdayofmonth, cmp_RateEachPickDrop, cmp_inv_audit, cmp_othertype3, cmp_othertype4, cmp_billing_rating_engine, cmp_app_eqcodes, cmp_dbh_custinvnum_prefix, cmp_dbh_custinvnum_startnum, cmp_dbh_custinvnum_digits, cmp_TaxGroup, cmp_UseDips, cmp_billto_spotquote, cmp_custequipprefix, AppianDistanceFldData, cmp_allow_tm_update, cmp_isbond, cmp_doublesdrop_location, cmp_primaryflagrequired, cmp_terminal, cmp_ctw_conv, cmp_ctw_break, cmp_wtc_conv, cmp_ctw_weightunits, cmp_ctw_volumeunits, cmp_yard_type, cmp_btm_toll_mileagetable, cmp_etawcbillto, trl_freedays, trl_maxcharge, cmp_DRBack, cmp_DROut
	   from  [dbo].[company] 
		WHERE CMP_CRMTYPE = 'NEW' 
		AND cmp_id NOT IN (SELECT CMP_ID FROM [dbo].clientes_nuevos)
			
end


	
GO
