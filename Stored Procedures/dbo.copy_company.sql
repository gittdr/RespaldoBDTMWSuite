SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[copy_company]
		(@copyid				varchar(8),
		@copynotes 			CHAR(1),
		@copyloadreqs 			CHAR(1),
		@new_cmp				varchar(8),
		@company_name		 	varCHAR(100),
		@alt_id	 			CHAR(25),
		@contacts 				CHAR(1),
		@inv_options			CHAR(1),
		@support_docs 			CHAR(1),
		@credit_info			CHAR(1),
		@replace_billto			char(1),
		@replace_parent			char(1),
		@cmp_instructions		char(1)
)
AS
	
/* Change Control
	LOR	PTS# 46016	created
	DJM	PTS 49371 - Support the Company Instructions
	vjh	pts	48903 - Add cmp_TollMethod
	PMILL PTS49552 - Add cmp_AvgFuelPriceDateOverride
	DJM	PTS 45980	-	Add cmp_servicedrp_rpt, cmp_servicepup_rpt, cmp_servicebillto_rpt
	SGB PTS 54471 Added cmp_misc5 - cmp_misc8
	SGB PTS 55729 SGB Added cmp_cmdvalue
	SGB PTS 55342 SGB Added cmp_useboldates, cmp_sendarrivalalert, cmp_senddeparturealert
	SGB PTS 52349 cmp_autobill, cmp_autobill_terms
	JJF PTS 57038 add cmp_ar_transfer_nonbundled
	DPETE PTS57997 cmp_defaultcons
	SPN PTS 51905 add bdt_required_for_dispatch
	SGB PTS 59166 added cmp_invoice_when
    DPETE 62072 add ,cmp_pophubmilesflag 
    NQIAO PTS62654 add cmp_othertype3 and cmp_othertype4
    DPETE 62660 add cmp_billing_rating_engine
*/

/*CREATE TABLE #company (
cmp_id	varchar	(8) null,									
cmp_name	varchar	(100) null,									
cmp_address1	varchar	(100) null,									
cmp_address2	varchar	(100) null,								
cmp_city	int null,								
cmp_zip	varchar	(10) null,									
cmp_primaryphone	varchar	(20) null,									
cmp_secondaryphone	varchar	(20) null,									
cmp_faxphone	varchar	(20) null,								
cmp_shipper	char	(1) null,									
cmp_consingee	char	(1) null,									
cmp_billto	char	(1) null,									
cmp_othertype1	varchar(6) null,									
cmp_othertype2	varchar	(6) null,									
cmp_artype	varchar	(6) null,									
cmp_invoicetype	varchar	(6) null,									
cmp_revtype1	varchar	(6) null,
cmp_revtype2	varchar	(6) null,
cmp_revtype3	varchar	(6) null,
cmp_revtype4	varchar	(6) null,
cmp_currency	varchar	(6) null,
cmp_active	char	(1) null,
cmp_opens_mo	int null,	
cmp_closes_mo	int null,	
cmp_creditlimit	money null,	
cmp_creditavail	money null,	
cmp_mileagetable	varchar	(2) null,
cmp_mastercompany	varchar	(8) null,
cmp_terms	char	(3) null,
cmp_defaultbillto	varchar	(8) null,
cmp_edi214	int null,	
cmp_edi210	int null,	
cmp_edi204	int null,	
cmp_state	varchar	(6) null,
cmp_region1	varchar	(6) null,
cmp_region2	varchar	(6) null,
cmp_region3	varchar	(6) null,
cmp_region4	varchar	(6) null,
cmp_addnewshipper	char	(1) null,
cmp_opensun	char	(1) null,
cmp_openmon	char	(1) null,
cmp_opentue	char	(1) null,
cmp_openwed	char	(1) null,
cmp_openthu	char	(1) null,
cmp_openfri	char	(1) null,
cmp_opensat	char	(1) null,
cmp_payfrom	varchar	(8) null,
cmp_mapfile	varchar	(8) null,
cmp_contact	varchar	(30) null,
cmp_directions	varchar(2000) null,
cty_nmstct	varchar	(25) null,
cmp_misc1	varchar	(254) null,
cmp_misc2	varchar	(254) null,
cmp_misc3	varchar	(254) null,
cmp_misc4	varchar	(254) null,
cmp_mbdays	smallint null,	
cmp_lastmb	datetime null,	
cmp_invcopies	smallint null,	
cmp_transfertype	varchar	(6) null,
cmp_altid	varchar	(25) null,
cmp_updatedby	varchar	(20) null,
cmp_updateddate	datetime null,	
cmp_defaultpriority	varchar	(6) null,
cmp_invoiceto	char	(3) null,
cmp_invformat	int null,	
cmp_invprintto	char	(1) null,
cmp_creditavail_update	datetime null,	
cmd_code	varchar	(8) null,
junknotinuse	datetime null,	
cmp_agedinvflag	char	(1) null,
cmp_max_dunnage	int null,	
cmp_acc_balance	money null,	
cmp_acc_dt	datetime null,	
cmp_opens_tu	int null,	
cmp_closes_tu	int null,	
cmp_opens_we	int null,	
cmp_closes_we	int null,	
cmp_opens_th	int null,	
cmp_closes_th	int null,	
cmp_opens_fr	int null,	
cmp_closes_fr	int null,	
cmp_opens_sa	int null,	
cmp_closes_sa	int null,	
cmp_opens_su	int null,	
cmp_closes_su	int null,	
cmp_subcompany	varchar	(6) null,
cmp_createdate	datetime null,	
cmp_taxtable1	char	(1) null,
cmp_taxtable2	char	(1) null,
cmp_taxtable3	char	(1) null,
cmp_taxtable4	char	(1) null,
cmp_quickentry	char	(1) null,
cmp_slack_time	int null,	
cmp_mailto_name	varchar	(30) null,
cmp_mailto_address1	varchar	(40) null,
cmp_mailto_address2	varchar	(40) null,
cmp_mailto_city	int null,	
cmp_mailto_state	varchar	(6) null,
cmp_mailto_zip	varchar	(10) null,
mailto_cty_nmstct	varchar	(25) null,
cmp_latseconds	int null,	
cmp_longseconds	int null,	
cmp_mailto_crterm1	varchar	(6) null,
cmp_mailto_crterm2	varchar	(6) null,
cmp_mailto_crterm3	varchar	(6) null,
cmp_mbformat	varchar	(20) null,
cmp_mbgroup	varchar	(20) null,
cmp_centroidcity	int null,	
cmp_centroidctynmstct	varchar	(25) null,
cmp_centroidzip	varchar	(10) null,
cmp_ooa_mileage	float null,
cmp_ooa_mileage_stops	float null,	
cmp_mapaddress	varchar	(50) null,
cmp_usestreetaddr	char	(1) null,
cmp_primaryphoneext	varchar	(6) null,
cmp_secondaryphoneext	varchar	(6) null,
cmp_palletcount	int null,	
cmp_fueltableid	varchar	(8) null,
grp_id	int null,	
cmp_parent	char	(1) null,
cmp_country	varchar	(50) null,
cmp_address3	varchar	(100) null,
cmp_slacktime_late	int null,	
cmp_geoloc	varchar	(50) null,
cmp_geoloc_forsearch	varchar	(50) null,
cmp_min_charge	money null,	
cmp_service_location	char	(1) null,
cmp_psoverride	char	(1) null,
cmp_MailtToForLinehaulFlag	char	(1) null,
cmp_mailtoTermsMatchFlag	char	(1) null,
cmp_taxid	varchar	(15) null,
cmp_gp_class	char	(11) null,
doc_language	varchar	(30) null,
cmp_image_routing1	varchar	(254) null,
cmp_image_routing2	varchar	(254) null,
cmp_image_routing3	varchar	(254) null,
cmp_port	char	(1) null,
cmp_depot	char	(1) null,
cmp_ivformat	varchar	(20) null,
cmp_ivgroup	varchar	(20) null,
cmp_max_weight	money null,	
cmp_max_weightunits	varchar	(6) null,
cmp_addcurrencysurcharge	char	(1) null,
ltsl_auto_add_pul_flag	varchar	(1) null,
ltsl_default_pickup_event	varchar	(6) null,
ltsl_default_delivery_event	varchar	(6) null,
cmp_PUPTimeAllowance	int null,	
cmp_DRPTimeAllowance	int null,	
cmp_maxdetmins	int null,	
--cmp_detcontacts	varchar	(1000) null,
cmp_allowdetcharges	char	(1) null,
cmp_latlongverifications	int null,	
cmp_maptuit_customnote	varchar	(512) null,
external_id	int null,	
external_type	varchar	(6) null,
cmp_service_location_qual	char	(1) null,
cmp_service_location_own	char	(1) null,
cmp_service_location_rating	varchar	(6) null,
cmp_TrlConfiguration	varchar	(6) null,
cmp_currencysurchargebase	money null,	
cmp_MileSearchLevel	varchar	(2) null,
cmp_det_start	int null,	
cmp_det_apply_if_late	char	(1) null,
cmp_reftype_unique	varchar	(6) null,
cmp_PUPalert	int null,	
cmp_DRPalert	int null,	
cmp_det_apply_if_early	char	(1) null,
cmp_senddetalert	char	(1) null,
cmp_railramp	char	(1) null,
cmp_leadtime	int null,	
cmp_athome_location	char	(1) null,
cmp_thirdpartytype1	varchar	(8) null,
cmp_thirdpartytype2	varchar	(8) null,
cmp_aceidtype	varchar	(6) null,
cmp_aceid	varchar	(30) null,
cmp_TMlatseconds	int null,	
cmp_TMlongseconds	int null,	
cmp_TMdistancetolatlong	decimal	(9,1) null,
cmp_TMlatlongdate	datetime null,	
cmp_dimoverride	char	(1) null,
cmp_rbd_FlatRateOption	varchar	(10) null,
cmp_MinLHAdj	money null,	
cmp_RateBy	char	(1) null,
cmp_supplier	char	(1) null,
cmp_overrideapplyhighestrate	char	(1) null,
cmp_rbd_highrateoption	varchar	(10) null,
cmp_last_call_date	datetime null,	
cmp_last_call_note	varchar	(255) null,
cmp_last_call_user	varchar	(255) null,
cmp_next_call_date	datetime null,	
cmp_SchdEarliestDateOverride	char	(1) null,
cmp_bookingterminal	varchar	(12) null,
cmp_det_increment	int null,	
cmp_det_rounding	char	(1) null,
cmp_det_threshold	int null,	
cmp_det_override	char	(1) null,
cmp_GeoCodeRequested	datetime null,	
cmp_ICaccessorial	int null,	
cmp_ICaccessorialfactor	decimal	(8,4) null,
cmp_stop_events	varchar	(100) null,
cmp_freestops	int null,	
cmp_stopevents_pay	varchar	(100) null,
cmp_freestops_pay	int null,	
cmp_MonObsHolFlag	smallint null,	
cmp_TueObsHolFlag	smallint null,	
cmp_WedObsHolFlag	smallint null,	
cmp_ThuObsHolFlag	smallint null,	
cmp_FriObsHolFlag	smallint null,	
cmp_SatObsHolFlag	smallint null,	
cmp_SunObsHolFlag	smallint null,	
cmp_FromHrDateAdj	smallint null,	
holiday_group	varchar	(6) null,
cmp_Payment_terms	varchar	(6) null,
cmp_blended_min_qty	decimal	(9,4) null,
cmp_BelongsTo	varchar	(6) null,
cmp_minchargeoption	varchar	(30) null,
cmp_acc_gvt_rpt	varchar	(50) null,
cmp_acc_id	char	(15) null,
cmp_refnum	varchar	(20) null,
cmp_statemiletype1	varchar	(8) null,
cmp_statemiletype2	varchar	(8) null,
cmp_splitbillonrefnbr	char	(1) null,
cmp_inv_toll_detail	char	(1) null,
cmp_refnum_gpinvxfer	varchar	(20) null,
rhh_id	int null,	
cmp_accountof	char	(1) null,
cmp_avgstopminutes	int null,	
cmp_mailto_country	varchar	(50) null,
cmp_billto_eligible_flag	char	(1) null,
cmp_invoiceby	varchar	(3) null,
cmp_volunits	varchar	(6) null,
cmp_wgtunits	varchar	(6) null,
cmp_crmtype	varchar	(6) null,
cmp_rateallocation	char	(1) null,
cmp_invoiceimageflag
cmp_stp_type2
cmp_stp_type3,
cmp_TollMethod,
cmp_AvgFuelPriceDateOverride,
cmp_servicedrp_rpt,
cmp_servicepup_rpt,
cmp_servicebillto_rpt,
cmp_dedicated_bill, /*PTS 52067*/
cmp_autobill, 
cmp_autobill_terms,
cmp_ar_transfer_nonbundled
)
*/
CREATE TABLE #notes_xref (
	not_id			INTEGER IDENTITY(1,1) NOT null,
	not_number		INTEGER	NOT null,
	new_not_number	INTEGER null)

CREATE TABLE #contacts_xref (
	ce_x_id	INTEGER IDENTITY(1,1) NOT null,
	ce_id	INTEGER NOT null)

--	company table is too big, need to split this one
create table #company_1 (
	cmp_id	varchar(8) not null,
	cmp_detcontacts	varchar	(1000) null)

DECLARE	@not_count			INTEGER,
		@newnotnbr_start	INTEGER,
		@min_id				INTEGER,
		@min_id1			INTEGER,
		@tmwuser 			VARCHAR(255),
		@ce_count			INTEGER

SELECT @tmwuser = suser_sname()
				
SELECT	@copynotes = Upper(Isnull(@copynotes,'N')),
		@copyloadreqs = Upper(Isnull(@copyloadreqs,'N')), 
		@contacts  = Upper(Isnull(@contacts,'N')), 
		@inv_options = Upper(Isnull(@inv_options,'N')), 
		@support_docs = Upper(Isnull(@support_docs,'N')), 
		@credit_info = Upper(Isnull(@credit_info,'N'))

IF @CopyNotes  = 'Y'
BEGIN
	SELECT 	@not_count = COUNT(not_number) 
	  FROM 	notes 
	 WHERE	ntb_table = 'company' AND
			nre_tablekey = @copyid AND
			ISnull(autonote, 'N') <> 'Y'
END

IF @CopyNotes  = 'Y' AND @not_count > 0
BEGIN
	EXEC @newnotnbr_start = getsystemnumberblock 'NOTES', null, @not_count

	INSERT INTO #notes_xref (not_number)
		SELECT	not_number
		  FROM	notes
		 WHERE	ntb_table = 'company' AND
				nre_tablekey = @copyid AND
				ISnull(autonote, 'N') <> 'Y'

	UPDATE 	#notes_xref
	SET	new_not_number = (@newnotnbr_start + (not_id - 1))
END

BEGIN TRAN COPY

Insert into company
			(cmp_id, 
			cmp_name, 
			cmp_address1, 
			cmp_address2, 
			cmp_city, 
			cmp_zip, 
			cmp_primaryphone, 
			cmp_secondaryphone, 
			cmp_faxphone, 
			cmp_shipper,				
			cmp_consingee, 
			cmp_billto, 
			cmp_othertype1, 
			cmp_othertype2, 
			cmp_artype, 
			cmp_invoicetype, 
			cmp_revtype1, 
			cmp_revtype2, 
			cmp_revtype3, 
			cmp_revtype4,				
			cmp_currency, 
			cmp_active, 
			cmp_opens_mo,
			cmp_closes_mo,
			cmp_creditlimit,
			cmp_creditavail,
			cmp_mileagetable,
			cmp_mastercompany,
			cmp_terms,
			cmp_defaultbillto,
			cmp_edi214,
			cmp_edi210,
			cmp_edi204,
			cmp_state,
			cmp_region1,
			cmp_region2,
			cmp_region3,
			cmp_region4,
			cmp_addnewshipper,
			cmp_opensun,
			cmp_openmon,
			cmp_opentue	,
			cmp_openwed,
			cmp_openthu,
			cmp_openfri,
			cmp_opensat,
			cmp_payfrom,
			cmp_mapfile,
			cmp_contact,
			cmp_directions,
			cty_nmstct,
			cmp_misc1,
			cmp_misc2,
			cmp_misc3,
			cmp_misc4,
			cmp_mbdays,
			cmp_lastmb,
			cmp_invcopies,
			cmp_transfertype,
			cmp_altid,
			cmp_updatedby,
			cmp_updateddate,
			cmp_defaultpriority,
			cmp_invoiceto,
			cmp_invformat,
			cmp_invprintto,
			cmp_creditavail_update,
			cmd_code,
			junknotinuse,
			cmp_agedinvflag,
			cmp_max_dunnage,
			cmp_acc_balance,
			cmp_acc_dt,
			cmp_opens_tu,
			cmp_closes_tu,
			cmp_opens_we,
			cmp_closes_we,
			cmp_opens_th,
			cmp_closes_th,
			cmp_opens_fr,
			cmp_closes_fr,
			cmp_opens_sa,
			cmp_closes_sa,
			cmp_opens_su,
			cmp_closes_su,
			cmp_subcompany,
			cmp_createdate,
			cmp_taxtable1,
			cmp_taxtable2,
			cmp_taxtable3,
			cmp_taxtable4,
			cmp_quickentry,
			cmp_slack_time,
			cmp_mailto_name,
			cmp_mailto_address1,
			cmp_mailto_address2,
			cmp_mailto_city,
			cmp_mailto_state,
			cmp_mailto_zip,
			mailto_cty_nmstct,
			cmp_latseconds,
			cmp_longseconds,
			cmp_mailto_crterm1,
			cmp_mailto_crterm2,
			cmp_mailto_crterm3,
			cmp_mbformat,
			cmp_mbgroup	,
			cmp_centroidcity,
			cmp_centroidctynmstct,
			cmp_centroidzip,
			cmp_ooa_mileage	,
			cmp_ooa_mileage_stops,
			cmp_mapaddress,
			cmp_usestreetaddr,
			cmp_primaryphoneext,
			cmp_secondaryphoneext,
			cmp_palletcount,
			cmp_fueltableid,
			grp_id,
			cmp_parent,
			cmp_country,
			cmp_address3,
			cmp_slacktime_late,
			cmp_geoloc,
			cmp_geoloc_forsearch,
			cmp_min_charge,
			cmp_service_location,
			cmp_psoverride,
			cmp_MailtToForLinehaulFlag,
			cmp_mailtoTermsMatchFlag,
			cmp_taxid,
			cmp_gp_class,
			doc_language,
			cmp_image_routing1,
			cmp_image_routing2,
			cmp_image_routing3,
			cmp_port,
			cmp_depot,
			cmp_ivformat,
			cmp_ivgroup,
			cmp_max_weight,
			cmp_max_weightunits,
			cmp_addcurrencysurcharge,
			ltsl_auto_add_pul_flag,
			ltsl_default_pickup_event,
			ltsl_default_delivery_event,
			cmp_PUPTimeAllowance,
			cmp_DRPTimeAllowance,
			cmp_maxdetmins,
			--cmp_detcontacts,
			cmp_allowdetcharges,
			cmp_latlongverifications,
			cmp_maptuit_customnote,
			external_id,
			external_type,
			cmp_service_location_qual,
			cmp_service_location_own,
			cmp_service_location_rating,
			cmp_TrlConfiguration,
			cmp_currencysurchargebase,
			cmp_MileSearchLevel,
			cmp_det_start,
			cmp_det_apply_if_late,
			cmp_reftype_unique,
			cmp_PUPalert,
			cmp_DRPalert,
			cmp_det_apply_if_early,
			cmp_senddetalert,
			cmp_railramp,
			cmp_leadtime,
			cmp_athome_location,
			cmp_thirdpartytype1,
			cmp_thirdpartytype2	,
			cmp_aceidtype,
			cmp_aceid,
			cmp_TMlatseconds,
			cmp_TMlongseconds,
			cmp_TMdistancetolatlong,
			cmp_TMlatlongdate,
			cmp_dimoverride,
			cmp_rbd_FlatRateOption,
			cmp_MinLHAdj,
			cmp_RateBy,
			cmp_supplier,
			cmp_overrideapplyhighestrate,
			cmp_rbd_highrateoption,
			cmp_last_call_date,
			cmp_last_call_note,
			cmp_last_call_user,
			cmp_next_call_date,
			cmp_SchdEarliestDateOverride,
			cmp_bookingterminal	,
			cmp_det_increment,
			cmp_det_rounding,
			cmp_det_threshold,
			cmp_det_override,
			cmp_GeoCodeRequested,
			cmp_ICaccessorial,
			cmp_ICaccessorialfactor,
			cmp_stop_events,
			cmp_freestops,
			cmp_stopevents_pay,
			cmp_freestops_pay,
			cmp_MonObsHolFlag,
			cmp_TueObsHolFlag,
			cmp_WedObsHolFlag,
			cmp_ThuObsHolFlag,
			cmp_FriObsHolFlag,
			cmp_SatObsHolFlag,
			cmp_SunObsHolFlag,
			cmp_FromHrDateAdj,
			holiday_group,
			cmp_Payment_terms,
			cmp_blended_min_qty,
			cmp_BelongsTo,
			cmp_minchargeoption,
			cmp_acc_gvt_rpt,
			cmp_acc_id,
			cmp_refnum,
			cmp_statemiletype1,
			cmp_statemiletype2,
			cmp_splitbillonrefnbr,
			cmp_inv_toll_detail,
			cmp_refnum_gpinvxfer,
			rhh_id,
			cmp_accountof,
			cmp_avgstopminutes,
			cmp_mailto_country,
			cmp_billto_eligible_flag,
			cmp_invoiceby,
			cmp_volunits,
			cmp_wgtunits,
			cmp_crmtype	,
			cmp_rateallocation,
			cmp_invoiceimageflag,
			cmp_stp_type2,
			cmp_stp_type3,
			cmp_TollMethod,
			cmp_AvgFuelPriceDateOverride,
			cmp_servicedrp_rpt,
			cmp_servicepup_rpt,
			cmp_servicebillto_rpt,
			cmp_dedicated_bill, /*PTS 52067*/
			cmp_misc5,
			cmp_misc6,
			cmp_misc7,
			cmp_misc8,
			cmp_cmdvalue,  -- PTS 56132 SGB
			cmp_useboldates,  -- PTS 55342 SGB
			cmp_sendarrivalalert, 
			cmp_senddeparturealert,  -- END PTS 55342 SGB
			cmp_autobill, -- PTS 52349 SGB
			cmp_autobill_terms, -- PTS 52349 SGB
			--PTS 57038 JJF 20110718
			cmp_ar_transfer_nonbundled,
			--END PTS 57038 JJF 20110718
			cmp_defaultcons,  -- 57997
			cmp_invoice_when, /*PTS 59166*/
			cmp_pophubmilesflag
			,cmp_mbdayofmonth	-- 60170
			,cmp_othertype3		-- 62654
			,cmp_othertype4		-- 62654
			,cmp_RateEachPickDrop	-- 61087
			,cmp_billing_rating_engine --62660
			,cmp_DROut
			,cmp_DRBack --73882
			,trl_freedays	--89958
			,trl_maxcharge	--89958
			,cmp_etawcbillto -- 87136
			)
SELECT  @new_cmp cmp_id, 
		@company_name cmp_name, 
			cmp_address1, 
			cmp_address2, 
			cmp_city, 
			cmp_zip, 
			cmp_primaryphone, 
			cmp_secondaryphone, 
			cmp_faxphone, 
			cmp_shipper,				
			cmp_consingee, 
			cmp_billto, 
			cmp_othertype1, 
			cmp_othertype2, 
			cmp_artype, 
			cmp_invoicetype, 
			cmp_revtype1, 
			cmp_revtype2, 
			cmp_revtype3, 
			cmp_revtype4,				
			cmp_currency, 
			cmp_active, 
			cmp_opens_mo,
			cmp_closes_mo,
			cmp_creditlimit,
			cmp_creditavail,
			cmp_mileagetable,
			cmp_mastercompany,
			cmp_terms,
			cmp_defaultbillto,
			cmp_edi214,
			cmp_edi210,
			cmp_edi204,
			cmp_state,
			cmp_region1,
			cmp_region2,
			cmp_region3,
			cmp_region4,
			cmp_addnewshipper,
			cmp_opensun,
			cmp_openmon,
			cmp_opentue	,
			cmp_openwed,
			cmp_openthu,
			cmp_openfri,
			cmp_opensat,
			cmp_payfrom,
			cmp_mapfile,
			cmp_contact = case @contacts when 'Y' then cmp_contact else '' end,
			cmp_directions,
			cty_nmstct,
			cmp_misc1,
			cmp_misc2,
			cmp_misc3,
			cmp_misc4,
			cmp_mbdays,
			cmp_lastmb,
			cmp_invcopies,
			cmp_transfertype,
			@alt_id cmp_altid,
			'COPYCOMPPROC' cmp_updatedby,
			getdate() cmp_updateddate,
			cmp_defaultpriority,
			cmp_invoiceto,
			cmp_invformat,
			cmp_invprintto,
			cmp_creditavail_update,
			cmd_code,
			junknotinuse,
			cmp_agedinvflag,
			cmp_max_dunnage,
			cmp_acc_balance,
			cmp_acc_dt,
			cmp_opens_tu,
			cmp_closes_tu,
			cmp_opens_we,
			cmp_closes_we,
			cmp_opens_th,
			cmp_closes_th,
			cmp_opens_fr,
			cmp_closes_fr,
			cmp_opens_sa,
			cmp_closes_sa,
			cmp_opens_su,
			cmp_closes_su,
			cmp_subcompany,
			getdate()  cmp_createdate,
			cmp_taxtable1,
			cmp_taxtable2,
			cmp_taxtable3,
			cmp_taxtable4,
			cmp_quickentry,
			cmp_slack_time,
			cmp_mailto_name,
			cmp_mailto_address1,
			cmp_mailto_address2,
			cmp_mailto_city,
			cmp_mailto_state,
			cmp_mailto_zip,
			mailto_cty_nmstct,
			cmp_latseconds,
			cmp_longseconds,
			cmp_mailto_crterm1,
			cmp_mailto_crterm2,
			cmp_mailto_crterm3,
			cmp_mbformat,
			cmp_mbgroup	,
			cmp_centroidcity,
			cmp_centroidctynmstct,
			cmp_centroidzip,
			cmp_ooa_mileage	,
			cmp_ooa_mileage_stops,
			cmp_mapaddress,
			cmp_usestreetaddr,
			cmp_primaryphoneext,
			cmp_secondaryphoneext,
			cmp_palletcount,
			cmp_fueltableid,
			grp_id,
			cmp_parent,
			cmp_country,
			cmp_address3,
			cmp_slacktime_late,
			cmp_geoloc,
			cmp_geoloc_forsearch,
			cmp_min_charge,
			cmp_service_location,
			cmp_psoverride,
			cmp_MailtToForLinehaulFlag,
			cmp_mailtoTermsMatchFlag,
			cmp_taxid,
			cmp_gp_class,
			doc_language,
			cmp_image_routing1,
			cmp_image_routing2,
			cmp_image_routing3,
			cmp_port,
			cmp_depot,
			cmp_ivformat,
			cmp_ivgroup,
			cmp_max_weight,
			cmp_max_weightunits,
			cmp_addcurrencysurcharge,
			ltsl_auto_add_pul_flag,
			ltsl_default_pickup_event,
			ltsl_default_delivery_event,
			cmp_PUPTimeAllowance,
			cmp_DRPTimeAllowance,
			cmp_maxdetmins,
			--cmp_detcontacts,
			cmp_allowdetcharges,
			cmp_latlongverifications,
			cmp_maptuit_customnote,
			external_id,
			external_type,
			cmp_service_location_qual,
			cmp_service_location_own,
			cmp_service_location_rating,
			cmp_TrlConfiguration,
			cmp_currencysurchargebase,
			cmp_MileSearchLevel,
			cmp_det_start,
			cmp_det_apply_if_late,
			cmp_reftype_unique,
			cmp_PUPalert,
			cmp_DRPalert,
			cmp_det_apply_if_early,
			cmp_senddetalert,
			cmp_railramp,
			cmp_leadtime,
			cmp_athome_location,
			cmp_thirdpartytype1,
			cmp_thirdpartytype2	,
			cmp_aceidtype,
			cmp_aceid,
			cmp_TMlatseconds,
			cmp_TMlongseconds,
			cmp_TMdistancetolatlong,
			cmp_TMlatlongdate,
			cmp_dimoverride,
			cmp_rbd_FlatRateOption,
			cmp_MinLHAdj,
			cmp_RateBy,
			cmp_supplier,
			cmp_overrideapplyhighestrate,
			cmp_rbd_highrateoption,
			cmp_last_call_date,
			cmp_last_call_note,
			cmp_last_call_user,
			cmp_next_call_date,
			cmp_SchdEarliestDateOverride,
			cmp_bookingterminal	,
			cmp_det_increment,
			cmp_det_rounding,
			cmp_det_threshold,
			cmp_det_override,
			cmp_GeoCodeRequested,
			cmp_ICaccessorial,
			cmp_ICaccessorialfactor,
			cmp_stop_events,
			cmp_freestops,
			cmp_stopevents_pay,
			cmp_freestops_pay,
			cmp_MonObsHolFlag,
			cmp_TueObsHolFlag,
			cmp_WedObsHolFlag,
			cmp_ThuObsHolFlag,
			cmp_FriObsHolFlag,
			cmp_SatObsHolFlag,
			cmp_SunObsHolFlag,
			cmp_FromHrDateAdj,
			holiday_group,
			cmp_Payment_terms,
			cmp_blended_min_qty,
			cmp_BelongsTo,
			cmp_minchargeoption,
			cmp_acc_gvt_rpt,
			cmp_acc_id,
			cmp_refnum,
			cmp_statemiletype1,
			cmp_statemiletype2,
			cmp_splitbillonrefnbr,
			cmp_inv_toll_detail,
			cmp_refnum_gpinvxfer,
			rhh_id,
			cmp_accountof,
			cmp_avgstopminutes,
			cmp_mailto_country,
			cmp_billto_eligible_flag,
			cmp_invoiceby,
			cmp_volunits,
			cmp_wgtunits,
			cmp_crmtype	,
			cmp_rateallocation,
			cmp_invoiceimageflag,
			cmp_stp_type2,
			cmp_stp_type3,
			cmp_TollMethod,
			cmp_AvgFuelPriceDateOverride,
			cmp_servicedrp_rpt,
			cmp_servicepup_rpt,
			cmp_servicebillto_rpt,
			cmp_dedicated_bill, /*PTS 52067*/
			cmp_misc5, --PTS 54471 SGB
			cmp_misc6,  
			cmp_misc7,
			cmp_misc8, --END PTS 54471 SGB
			cmp_cmdvalue, -- PTS 55729 SGB
			cmp_useboldates, -- PTS 55342 SGB
			cmp_sendarrivalalert, 
			cmp_senddeparturealert, -- END PTS 55342 SGB
			cmp_autobill, -- PTS 52349 SGB
			cmp_autobill_terms, -- PTS 52349 SGB
			--PTS 57038 JJF 20110718
			cmp_ar_transfer_nonbundled,
			--END PTS 57038 JJF 20110718
			cmp_defaultcons,   -- 57997
			cmp_invoice_when, /*PTS 59166*/
			cmp_pophubmilesflag,
			cmp_mbdayofmonth  -- 60170
			,cmp_othertype3		-- 62654
			,cmp_othertype4		-- 62654
			,cmp_RateEachPickDrop	-- 61087
			,cmp_billing_rating_engine --62660
			,cmp_DROut
			,cmp_DRBack --73882
			,trl_freedays	--89958
			,trl_maxcharge	--89958
			,cmp_etawcbillto -- 87136
  FROM company 
WHERE  cmp_id = @copyid

IF @@ERROR <> 0 GOTO ERROR_EXIT

insert into #company_1
		(cmp_id,
		cmp_detcontacts)
select @copyid cmp_id,
		cmp_detcontacts
  FROM company 
WHERE  cmp_id = @copyid

update company 
set cmp_detcontacts = c1.cmp_detcontacts
from #company_1 c1, company c
where c.cmp_id = c1.cmp_id

SELECT	@min_id = MIN(not_id) FROM	#notes_xref

WHILE ISnull(@min_id, 0) > 0 
BEGIN
	INSERT INTO notes
			(not_number,
			 not_text,
			 not_type,
			 not_urgent,
			 not_senton,
			 not_sentby,
			 not_expires,
			 not_forwardedfrom,
			 ntb_table,
			 nre_tablekey,
			 not_sequence,
			 last_updatedby,
			 last_updatedatetime,
             autonote,  
             not_text_large,
             not_viewlevel,
             ntb_table_copied_from,
             nre_tablekey_copied_from,
             not_number_copied_from,
             not_tmsend)
  	SELECT	nx.new_not_number,
			n.not_text,
			n.not_type,
			n.not_urgent,
			n.not_senton,
			n.not_sentby,
			n.not_expires,
			n.not_forwardedfrom,
			n.ntb_table,
			@new_cmp nre_tablekey,
			n.not_sequence,
			'COPYCOMPPROC',
			GETDATE(),
            n.autonote,  
            n.not_text_large,
            n.not_viewlevel,
            n.ntb_table_copied_from,
            n.nre_tablekey_copied_from,
            n.not_number_copied_from,
            n.not_tmsend
	FROM	#notes_xref nx
			INNER JOIN notes n ON nx.not_number = n.not_number
	WHERE	nx.not_id = @min_id 

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	SELECT	@min_id = MIN(not_id)
	FROM	#notes_xref
	WHERE	not_id > @min_id
END

IF @copyloadreqs = 'Y'
	BEGIN  
		INSERT INTO loadreqdefault
			(def_id,
				def_id_type,
				def_type,
				def_not, 
				def_manditory, 
				def_quantity, 
				def_equip_type, 
				def_cmd_id,
				def_required,
				def_expire_date,
				def_cmp_billto)
	     	SELECT @new_cmp def_id,
				def_id_type,
				def_type,
				def_not, 
				def_manditory, 
				def_quantity, 
				def_equip_type, 
				def_cmd_id,
				def_required,
				def_expire_date,
				def_cmp_billto
			FROM	loadreqdefault 
			WHERE	def_id = @copyid

			IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

If @inv_options = 'Y'
Begin
	insert into company_print_settings
		(cps_email_directory,   
         cmp_id,   
         cps_print_invoice,   
         cps_print_printer,   
         cps_fax_invoice,   
         cps_fax_number,   
         cps_fax_printer,   
         cps_email_invoice,   
         cps_email_address1,   
         cps_email_address2,   
         cps_email_address3,   
         cps_email_printer,   
         cps_email_subject,   
         cps_pdf_invoice,   
         --cps_id,   
         cps_work_directory,   
         cpd_email_bodytext,   
         cpd_fax_coverfile,   
         cpd_fax_subject,   
         cpd_fax_to,   
         cpd_clear_files)
	SELECT cps_email_directory,   
         @new_cmp,   
         cps_print_invoice,   
         cps_print_printer,   
         cps_fax_invoice,   
         cps_fax_number,   
         cps_fax_printer,   
         cps_email_invoice,   
         cps_email_address1,   
         cps_email_address2,   
         cps_email_address3,   
         cps_email_printer,   
         cps_email_subject,   
         cps_pdf_invoice,   
         --cps_id,   
         cps_work_directory,   
         cpd_email_bodytext,   
         cpd_fax_coverfile,   
         cpd_fax_subject,   
         cpd_fax_to,   
         cpd_clear_files
    FROM company_print_settings  
   WHERE cmp_id = @copyid

	IF @@ERROR <> 0 GOTO ERROR_EXIT
End

If @support_docs = 'Y'
Begin
	insert into BillDoctypes 
		(cmp_id,
		bdt_doctype,
		bdt_sequence,
		bdt_inv_required,
		bdt_inv_attach,
		bdt_required_for_application,
		bdt_required_for_fgt_event
		, bdt_required_for_dispatch
		)
	SELECT  
		@new_cmp cmp_id,
		bdt_doctype,
		bdt_sequence,
		bdt_inv_required,
	    bdt_inv_attach,
		bdt_required_for_application,
		bdt_required_for_fgt_event
		, bdt_required_for_dispatch
	FROM BillDoctypes      
	WHERE cmp_id = @copyid

	IF @@ERROR <> 0 GOTO ERROR_EXIT
End

If @credit_info = 'Y'
Begin
	insert into creditcheck 
		(cmp_id,
        cmp_aging1,   
        cmp_aging2,   
        cmp_aging3,   
        cmp_aging4,   
        cmp_aging5,   
        cmp_aging6 ,
		alt_id)
  SELECT @new_cmp,  
         cmp_aging1,   
         cmp_aging2,   
         cmp_aging3,   
         cmp_aging4,   
         cmp_aging5,   
         cmp_aging6 ,
		 @alt_id
    FROM creditcheck  
   WHERE cmp_id = @copyid

	IF @@ERROR <> 0 GOTO ERROR_EXIT
End

If (select count(*) from companyemail where cmp_id = @new_cmp) > 0
		delete companyemail where cmp_id = @new_cmp

If @contacts = 'Y'
Begin
	SELECT 	@ce_count = COUNT(*) 
	  FROM 	companyemail
	 WHERE	cmp_id = @copyid and ce_source =  'CMP'

	IF @ce_count > 0
	Begin
		INSERT INTO #contacts_xref (ce_id)
		SELECT	ce_id
		FROM	companyemail
		WHERE	cmp_id = @copyid and ce_source =  'CMP'

		SELECT	@min_id1 = MIN(ce_x_id) 
		FROM	#contacts_xref

		WHILE ISnull(@min_id1, 0) > 0 
		BEGIN
			insert into companyemail
					(cmp_id,  
					 email_address,   
					 contact_name,   
					 mail_default,   
					 type,   
					 --ce_id,   
					 ce_phone1,   
					 ce_phone1_ext,   
					 ce_phone2,   
					 ce_phone2_ext,   
					 ce_mobilenumber,   
					 ce_faxnumber,   
					 ce_defaultcontact,   
					 ce_comment,   
					 ce_source, 
					 ce_title,
						--PTS 46118 JJF 20090706
					 ce_contact_type
						--END PTS 46118 JJF 20090706
					 )
				SELECT @new_cmp,
					 email_address,   
					 contact_name,   
					 mail_default,   
					 type,   
					 --ce_id,   
					 ce_phone1,   
					 ce_phone1_ext,   
					 ce_phone2,   
					 ce_phone2_ext,   
					 ce_mobilenumber,   
					 ce_faxnumber,   
					 ce_defaultcontact,   
					 ce_comment,   
					 ce_source, 
					 ce_title,
						--PTS 46118 JJF 20090706
					 ce_contact_type
						--END PTS 46118 JJF 20090706
				FROM	#contacts_xref x INNER JOIN companyemail c ON x.ce_id = c.ce_id
				WHERE	x.ce_x_id = @min_id1 

				SELECT	@min_id1 = MIN(ce_x_id)
				FROM	#contacts_xref
				WHERE	ce_x_id > @min_id1

				IF @@ERROR <> 0 GOTO ERROR_EXIT
			END
	End
End

-- PTS 49371 - DJM - Support the Company Instructions
if @cmp_instructions = 'Y' AND exists (select 1 from company_delivery_instructions where cdi_company = @copyid)
	Begin

		Insert into company_delivery_instructions (
			cdi_company,
			cdi_commodity,
			cdi_stop_type,
			cdi_desc
			)
		Select @new_cmp,
			cdi_commodity,
			cdi_stop_type,
			cdi_desc
		from company_delivery_instructions
		where cdi_company = @copyid
		
		IF @@ERROR <> 0 GOTO ERROR_EXIT
	End


If @replace_billto = 'Y'
	update company 
	set cmp_defaultbillto = @new_cmp
	where cmp_defaultbillto = @copyid

If @replace_parent = 'Y'
	update company 
	set cmp_mastercompany = @new_cmp
	where cmp_mastercompany = @copyid

COMMIT TRAN
GOTO SUCCESS_EXIT

ERROR_EXIT:
  ROLLBACK TRAN COPY

SUCCESS_EXIT:

SELECT	cmp_id,
		cmp_name,
		cmp_altid,
		cmp_mastercompany,
		cmp_defaultbillto
FROM company  
WHERE cmp_id = @new_cmp

drop table #company_1
drop table #notes_xref
drop table #contacts_xref

GO
GRANT EXECUTE ON  [dbo].[copy_company] TO [public]
GO
