SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[clonetripwithoptions]
		(@copies 		INT
		,@movnumber		INT
		,@ordnumber 		VARCHAR(12)
		,@ordbookedby		VARCHAR(20)
		,@copydates 		CHAR(1)
		,@startdate		DATETIME
		,@incrementalDays 	INT
		,@incrementalHours 	INT
		,@incrementalMinutes	INT
		,@copystatus 		CHAR(1)
		,@status 		VARCHAR(6)
		,@copyquantities 	CHAR(1)
		,@copylinehaul 		CHAR(1)
		,@copyAccessorials 	CHAR(1)
		,@copynotes 		CHAR(1)
		,@copydelinstructions 	CHAR(1)
		,@copypaydetails 	CHAR(1)
		,@copyordrefs 		CHAR(1)
		,@copyotherrefs 	CHAR(1)
		,@copyloadrequirements 	CHAR(1)
		,@copyinvoicebackouts 	CHAR(1)
		,@copyassigns 		CHAR(1)
		,@asgndriver1 		VARCHAR(8)
		,@asgndriver2 		VARCHAR(8)
		,@asgntractor 		VARCHAR(8)
		,@asgntrailer1 		VARCHAR(13)
		,@asgntrailer2 		VARCHAR(13)
		,@asgncarrier 		VARCHAR(8)
		,@daysperweek 		SMALLINT
		,@revtype1 		VARCHAR(6)
		,@revtype1_format 	CHAR(1)
		,@reserved 		VARCHAR(254)
		,@UseAlphaOrdId		CHAR(1)
		,@copymasterinvstatus	char(1)
		,@copyextrainfo		char(1)
		,@toep_id		INTEGER
		,@copypermitrequirements char(1)
        -- TGRIFFIT - PTS #38785
        ,@copyreftype           varchar(50)
        ,@copyrefnum            varchar(30)
        -- END TGRIFFIT - PTS #38785
        -- TGRIFFIT - PTS #38783
        ,@availdtascurrdt       char(1)
        -- END TGRIFFIT - PTS #38783
        ,@OverrideBookedRevtype1 varchar(12)  -- 41629 recode Pauls 
		,@copythirdparty 		char(1)	-- 44064
)
AS
/* Change Control


06/29/2007 Created by Matt Roberts
09/21/2007 TGRIFFIT 38785 added 2 additional parameters @copyreftype and @copyrefnum which are used when creating
repetitive haul order copies. These values are used to set the 'Reference' field info for the resultant orders.
09/24/2007 TGRIFFIT 38783 added 1 additional parameter @availdtascurrdt. This flag will used to determine whether or not to set the orderheader.ord_availabledate column data to the current datetime.
SLM 39478 11/29/2007 Based upon GI setting, when copying Notes, populate 'lastupdated_by' with note userid not value COPYPROC
TGRIFFIT 38846 03/27/2008 added logic to copy the master's max gvw and max gvw uom data. If the max gvw value has not been populated, then grab the master order standards value instead.
MROIK - PTS #38843 - 3/28/2008 - Added ord_anc_number
08/21/2008  JSwindell PTS44064 Added @copythirdparty 
LOR	PTS# 42471	added thirdparty split
TGRIFFIT 43236 04/08/2008 added logic to copy the cyclic dispatch and preassign acknowledgement fields.
TGRIFFIT 43236 04/08/2008 changes made for PTS38773 (copying of new freight dtl qty fields) did not meet requirements. Reworked so that fields are direct from master.
DPETE 53587 must pass INI flag from ORderIDFormat (in argument @revtype1_format) to proc GET_ORD_TERMINAL_PREF
NQIAO 58978 copy the new order field 'ord_ratemode', 'ord_servicelevel' and 'ord_servicedays' when @copylinehaul is 'Y', otherwise
            copy 'UNK' for 'ord_ratemode' and 'ord_servicelevel', and NULL for 'ord_servicedays'
*/

--PTS 28542 JJF Kurt S. requested this be added 7/20/05 for performance reasons
SET NOCOUNT ON

Declare @RollBackCloneOrder char(1) -- PTS 35479
SELECT @RollBackCloneOrder = gi_string1 from generalinfo where upper(gi_name) = 'ROLLBACKCLONEORDER' -- PTS 35479

SET @toep_id = -1

CREATE TABLE #orderheader (
	ord_company 			VARCHAR(8) 	NULL,
	ord_number 			VARCHAR(12)	NULL,
	ord_customer 			VARCHAR(8) 	NULL,
	ord_bookdate 			DATETIME 	NULL,
	ord_bookedby 			VARCHAR(20)	NULL,
	ord_status 			VARCHAR(6) 	NULL,
	ord_originpoint 		VARCHAR(8) 	NULL,
	ord_destpoint 			VARCHAR(8) 	NULL,
	ord_invoicestatus 		VARCHAR(6) 	NULL,
	ord_origincity 			INTEGER 	NULL,
	ord_destcity 			INTEGER 	NULL,
	ord_originstate 		CHAR(6) 	NULL,
	ord_deststate 			CHAR(6) 	NULL,
	ord_originregion1 		VARCHAR(6) 	NULL,
	ord_destregion1 		VARCHAR(6) 	NULL,
	ord_supplier 			VARCHAR(8) 	NULL,
	ord_billto 			VARCHAR(8) 	NULL,
	ord_startdate 			DATETIME 	NULL,
	ord_completiondate 		DATETIME 	NULL,
	ord_revtype1 			VARCHAR(6) 	NULL,
	ord_revtype2 			VARCHAR(6) 	NULL,
	ord_revtype3 			VARCHAR(6)	NULL,
	ord_revtype4 			VARCHAR(6)	NULL,
	ord_totalweight 		FLOAT 		NULL,
	ord_totalpieces 		FLOAT 		NULL,
	ord_totalmiles 			INTEGER 	NULL,
	ord_totalcharge 		FLOAT 		NULL, 
	ord_currency 			VARCHAR(6) 	NULL,
	ord_currencydate 		DATETIME 	NULL,
	ord_totalvolume 		FLOAT 		NULL,
	ord_hdrnumber 			INTEGER 	NULL,	
	ord_refnum 			VARCHAR(30)	NULL,
	ord_invoicewhole 		CHAR(1) 	NULL,
	ord_remark 			VARCHAR(254)	NULL,
	ord_shipper 			VARCHAR(8) 	NULL,
	ord_consignee 			VARCHAR(8) 	NULL,
	ord_pu_at 			VARCHAR(6) 	NULL,
	ord_dr_at 			VARCHAR(6) 	NULL,
	ord_originregion2 		VARCHAR(6) 	NULL,
	ord_originregion3 		VARCHAR(6) 	NULL,
	ord_originregion4 		VARCHAR(6) 	NULL,
	ord_destregion2  		VARCHAR(6) 	NULL,
	ord_destregion3  		VARCHAR(6) 	NULL,
	ord_destregion4  		VARCHAR(6) 	NULL,
	mfh_hdrnumber 			INTEGER 	NULL,
	ord_priority 			VARCHAR(6) 	NULL,
	mov_number 			INTEGER 	NULL,
	tar_tarriffnumber 		VARCHAR(12)	NULL,
	tar_number 			INTEGER 	NULL,
	tar_tariffitem 			VARCHAR(12)	NULL,	
	ord_contact 			VARCHAR(30)	NULL,
	ord_showshipper 		VARCHAR(8) 	NULL,
	ord_showcons  			VARCHAR(8) 	NULL,
	ord_subcompany 			VARCHAR(8) 	NULL,
	ord_lowtemp 			TINYINT 	NULL,
	ord_hitemp 			TINYINT		NULL,
	ord_quantity 			FLOAT 		NULL,
	ord_rate 			MONEY 		NULL,
	ord_charge 			MONEY 		NULL,
	ord_rateunit 			VARCHAR(6) 	NULL,
	ord_unit 			VARCHAR(6) 	NULL,
	trl_type1 			VARCHAR(6) 	NULL,
	ord_driver1 			VARCHAR(8) 	NULL,
	ord_driver2 			VARCHAR(8) 	NULL,
	ord_tractor 			VARCHAR(8) 	NULL,
	ord_trailer 			VARCHAR(13)	NULL,
	ord_length 			MONEY 		NULL,
	ord_width 			MONEY 		NULL,
	ord_height 			MONEY 		NULL,
	ord_lengthunit  		VARCHAR(6) 	NULL,
	ord_widthunit  			VARCHAR(6) 	NULL,
	ord_heightunit  		VARCHAR(6) 	NULL,
	ord_reftype  			VARCHAR(6) 	NULL,
	cmd_code  			VARCHAR(8) 	NULL,
	ord_description 		VARCHAR(64)	NULL,
	ord_terms  			VARCHAR(6)	NULL,
	cht_itemcode  			VARCHAR(6)	NULL,
	ord_origin_earliestdate		DATETIME 	NULL,
	ord_origin_latestdate 		DATETIME 	NULL,
	ord_odmetermiles		INTEGER 	NULL,
	ord_stopcount 			TINYINT		NULL,
	ord_dest_earliestdate 		DATETIME 	NULL,
	ord_dest_latestdate		DATETIME 	NULL,
	ref_sid 			CHAR(1) 	NULL,
	ref_pickup 			CHAR(1) 	NULL,
	ord_cmdvalue	 		MONEY 		NULL,
	ord_accessorial_chrg		MONEY 		NULL,
	ord_availabledate 		DATETIME 	NULL,
	ord_miscqty			DECIMAL(12,4)	NULL,
	ord_tempunits 			VARCHAR(6) 	NULL,
	ord_datetaken			DATETIME 	NULL,
	ord_totalweightunits 		VARCHAR(6) 	NULL,
	ord_totalvolumeunits 		VARCHAR(6) 	NULL,
	ord_totalcountunits 		VARCHAR(6) 	NULL,
	ord_loadtime 			FLOAT 		NULL,
	ord_unloadtime 			FLOAT 		NULL,	
	ord_drivetime 			FLOAT 		NULL,
	ord_rateby 			CHAR(1) 	NULL,
	ord_quantity_type 		INTEGER 	NULL,
	ord_thirdpartytype1 		VARCHAR(8) 	NULL,
	ord_thirdpartytype2 		VARCHAR(8) 	NULL,
	ord_charge_type 		SMALLINT	NULL,
	ord_bol_printed 		VARCHAR(1)	NULL,
	ord_fromorder 			VARCHAR(12)	NULL,
	ord_mintemp 			SMALLINT	NULL,
	ord_maxtemp 			SMALLINT	NULL,
	ord_distributor 		VARCHAR(8) 	NULL,
	opt_trc_type4 			VARCHAR(6) 	NULL,
	opt_trl_type4 			VARCHAR(6) 	NULL,
	ord_cod_amount 			MONEY 		NULL,
	appt_init 			VARCHAR(3) 	NULL,
	appt_contact			VARCHAR(35)	NULL,
	ord_ratingquantity 		FLOAT 		NULL,
	ord_ratingunit 			VARCHAR(6) 	NULL,
	ord_booked_revtype1 		VARCHAR(12)	NULL,
	ord_hideshipperaddr 		CHAR(1) 	NULL,
	ord_hideconsignaddr 		CHAR(1) 	NULL,
	ord_trl_type2 			VARCHAR(6) 	NULL,
	ord_trl_type3 			VARCHAR(6) 	NULL,
	ord_trl_type4 			VARCHAR(6) 	NULL,
	ord_tareweight 			INTEGER 	NULL,
	ord_grossweight 		INTEGER 	NULL,
	ord_mileagetable 		VARCHAR(2) 	NULL,	
	ord_allinclusivecharge 		MONEY 		NULL,
	ord_rate_type 			SMALLINT	NULL,
	ord_stlquantity 		FLOAT 		NULL,
	ord_stlunit 			VARCHAR(6)	NULL,
	ord_stlquantity_type 		TINYINT		NULL,
	ord_revenue_pay 		MONEY 		NULL,
	ord_reserved_number 		CHAR(1) 	NULL,
	ord_customs_document 		INTEGER 	NULL, 
	ord_noautosplit 		TINYINT		NULL, 
	ord_noautotransfer 		TINYINT		NULL,
	ord_totalloadingmeters 		DECIMAL(12,4)	NULL,
	ord_totalloadingmetersunit	VARCHAR(6) 	NULL,
	ord_charge_type_lh  		SMALLINT	NULL,
	ord_mileage_adj_pct 		DECIMAL(9,2) 	NULL,
	ord_dimfactor 			DECIMAL(8,2) 	NULL,
	ord_trlconfiguration 		VARCHAR(6) 	NULL,
	ord_rate_mileagetable 		VARCHAR(2)	NULL,
	ord_raildest 			varchar(25) 	null,
	ord_railpoolid 			varchar(8) 	null,
	ord_trailer2 			varchar(13) 	null,
	ord_route 			varchar(15) 	null,
	ord_route_effc_date		datetime 	null,
	ord_route_exp_date		datetime 	null,
	ord_odmetermiles_mtid 		INTEGER 	NULL,
	ord_origin_zip			varchar(10)	null,
	ord_dest_zip			varchar(10)	null,
	ord_no_recalc_miles		char(1)		null,
    	car_key 			int null,   --41629
    	ord_gvw_unit            	varchar(6)  null,   --PTS 38846 TGRIFFIT
    	ord_gvw_adjstd_unit     	varchar(6)   null,   --PTS 38846 TGRIFFIT
    	ord_gvw_adjstd_amt      	numeric(19,4) null, --PTS 38846 TGRIFFIT
	ord_thirdpartytype3		varchar(8) null,
	ord_thirdparty_split_percent 	float  NULL,
	ord_thirdparty_split 		char(1) null,
    	ord_cyclic_dsp_enabled      	char(1)   null,   --PTS 43236 TGRIFFIT
    	ord_preassign_ack_required  	char(1)   null,   --PTS 43236 TGRIFFIT
	ord_broker			VARCHAR(8) NULL,			   --PTS50180 MBR 12/10/09
	ord_ratemode				varchar(6)		NULL,	/* 11/18/2011 NQIAO PTS 58978 */
	ord_servicelevel			varchar(6)		NULL,	/* 11/18/2011 NQIAO PTS 58978 */
	ord_servicedays				int				NULL	/* 11/18/2011 NQIAO PTS 58978 */
)

CREATE TABLE #orderheader_xref (
	ord_hdrnumber		INTEGER 	NOT NULL,
	copy_number		INTEGER 	NOT NULL,
	new_ord_hdrnumber	INTEGER 	NOT NULL,
	new_ord_number		VARCHAR(12) 	NOT NULL,
	new_mov_number		INTEGER 	NOT NULL,
	new_lgh_number		INTEGER 	NOT NULL)

CREATE TABLE #stops(
	ord_hdrnumber 		INTEGER 	NULL,
	stp_number 		INTEGER 	NULL,
	cmp_id 			VARCHAR(8) 	NULL,
	stp_region1 		VARCHAR(6) 	NULL,
	stp_region2 		VARCHAR(6) 	NULL,
	stp_region3 		VARCHAR(6) 	NULL,
	stp_city 		INTEGER 	NULL,
	stp_state 		CHAR(6) 	NULL,
	stp_schdtearliest 	DATETIME 	NULL,	
	stp_origschdt 		DATETIME 	NULL,
	stp_arrivaldate 	DATETIME 	NULL,
	stp_departuredate 	DATETIME 	NULL,
	stp_reasonlate 		VARCHAR(6) 	NULL,
	stp_schdtlatest 	DATETIME 	NULL,
	lgh_number 		INTEGER 	NULL,
	mfh_number 		INTEGER 	NULL,
	stp_type 		VARCHAR(6) 	NULL,
	stp_paylegpt 		CHAR(1) 	NULL,
	shp_hdrnumber 		INTEGER 	NULL,
	stp_sequence 		INTEGER 	NULL,
	stp_region4 		VARCHAR(6) 	NULL,
	stp_lgh_sequence 	INTEGER 	NULL,
	trl_id 			VARCHAR(13) 	NULL,
	stp_mfh_sequence 	INTEGER 	NULL,
	stp_event 		CHAR(6) 	NULL,
	stp_mfh_position 	CHAR(6) 	NULL,
	stp_lgh_position 	CHAR(6) 	NULL,
	stp_mfh_status 		CHAR(6) 	NULL,
	stp_lgh_status 		CHAR(6) 	NULL,
	stp_ord_mileage 	INTEGER 	NULL,
	stp_lgh_mileage 	INTEGER 	NULL,
	stp_mfh_mileage 	INTEGER 	NULL,
	mov_number 		INTEGER 	NULL,
	stp_loadstatus 		CHAR(3) 	NULL,
	stp_weight 		FLOAT 		NULL,
	stp_weightunit 		VARCHAR(6) 	NULL,
	cmd_code 		VARCHAR(8) 	NULL,
	stp_description 	VARCHAR(30) 	NULL,
	stp_count 		FLOAT 		NULL,
	stp_countunit 		VARCHAR(10) 	NULL,
	cmp_name 		VARCHAR(30) 	NULL,
	stp_Comment 		VARCHAR(254) 	NULL,
	stp_status 		VARCHAR(6) 	NULL,
	stp_reftype 		VARCHAR(6) 	NULL,
	stp_refnum 		VARCHAR(30) 	NULL,
	stp_reasonlate_depart	VARCHAR(6) 	NULL,
	stp_screenmode 		VARCHAR(6) 	NULL,
	skip_trigger 		TINYINT		NULL,
	stp_volume 		FLOAT 		NULL,
	stp_volumeunit 		CHAR(6) 	NULL,
	stp_dispatched_sequence	INTEGER 	NULL,
	stp_arr_confirmed 	CHAR(1) 	NULL,
	stp_dep_confirmed 	CHAR(1) 	NULL,
	stp_type1 		VARCHAR(6) 	NULL,
	stp_redeliver 		VARCHAR(1) 	NULL,
	stp_osd 		VARCHAR(1) 	NULL,
	stp_pudelpref 		VARCHAR(10) 	NULL,
	stp_phonenumber 	VARCHAR(20) 	NULL,
	stp_delayhours 		FLOAT 		NULL,
	stp_ooa_mileage 	FLOAT 		NULL,
	stp_zipcode 		VARCHAR(10) 	NULL,
	stp_ooa_stop 		INTEGER 	NULL,
	stp_address 		VARCHAR(40) 	NULL,
	stp_transfer_stp 	INTEGER 	NULL,
	stp_phonenumber2 	VARCHAR(20)	NULL,
	stp_address2 		VARCHAR(40)	NULL,
	stp_contact 		VARCHAR(30)	NULL,
	stp_custpickupdate 	DATETIME 	NULL,
	stp_custdeliverydate 	DATETIME 	NULL,
	stp_podname 		VARCHAR(20) 	NULL,
	stp_cmp_close 		INTEGER 	NULL,
	stp_activitystart_dt 	DATETIME 	NULL,
	stp_activityend_dt 	DATETIME 	NULL,
	stp_departure_status 	VARCHAR(6) 	NULL,
	stp_eta 		DATETIME 	NULL,
	stp_etd 		DATETIME 	NULL,
	stp_transfer_type 	CHAR(3) 	NULL,
	stp_trip_mileage 	INTEGER 	NULL,
	stp_loadingmeters 	DECIMAL(12,4)	NULL,
	stp_loadingmetersunit 	VARCHAR(6) 	NULL,
	stp_country 		VARCHAR(50) 	NULL,
	stp_cod_amount 		DECIMAL(8,2) 	NULL,
	stp_cod_currency 	VARCHAR(6) 	NULL,
	stp_ord_mileage_mtid 	INTEGER 	NULL,  
	stp_lgh_mileage_mtid 	INTEGER 	NULL,  
	stp_ooa_mileage_mtid 	INTEGER		NULL,  
	new_stp_number		INTEGER		NULL,
	stp_pallets_in          INTEGER         NULL,
	stp_pallets_out         INTEGER         NULL)

CREATE TABLE #stp_xref (
	stp_id			INTEGER IDENTITY(1,1) NOT NULL,
	stp_number		INTEGER	NOT NULL,
	new_stp_number		INTEGER NULL)

CREATE TABLE #lgh_xref (
	lgh_id			INTEGER IDENTITY(1,1) NOT NULL,
	copy_number		INTEGER NOT NULL,
        lgh_number		INTEGER NOT NULL,
	new_lgh_number		INTEGER NULL)

CREATE TABLE #freightdetail (
	fgt_number 			INTEGER 	NULL,
	cmd_code 			VARCHAR(8) 	NULL,
	fgt_weight 			FLOAT 		NULL,
	fgt_weightunit 			VARCHAR(6) 	NULL,
	fgt_description 		VARCHAR(60) 	NULL,
	stp_number 			INTEGER		NULL, 
	fgt_count 			FLOAT 		NULL,
	fgt_countunit 			VARCHAR(6) 	NULL,
	fgt_volume 			FLOAT 		NULL,
	fgt_volumeunit 			VARCHAR(6) 	NULL,
	fgt_lowtemp 			SMALLINT	NULL,
	fgt_hitemp 			SMALLINT	NULL,
	fgt_sequence 			SMALLINT	NULL,
	fgt_length 			FLOAT 		NULL,	
	fgt_lengthunit 			VARCHAR(6) 	NULL,
	fgt_height 			FLOAT 		NULL,
	fgt_heightunit 			VARCHAR(6) 	NULL,
	fgt_width 			FLOAT 		NULL,
	fgt_widthunit 			VARCHAR(6) 	NULL,
	fgt_reftype 			VARCHAR(6) 	NULL,
	fgt_refnum 			VARCHAR(30) 	NULL,
	fgt_quantity 			FLOAT 		NULL,
	fgt_rate 			MONEY 		NULL,
	fgt_charge 			MONEY 		NULL,
	fgt_rateunit 			VARCHAR(6) 	NULL,
	cht_itemcode 			VARCHAR(6) 	NULL,
	cht_basisunit 			VARCHAR(6) 	NULL,
	fgt_unit 			VARCHAR(6) 	NULL,
	skip_trigger 			TINYINT		NULL,
	tare_weight 			FLOAT 		NULL,
	tare_weightunit 		VARCHAR(6) 	NULL,
	fgt_pallets_in 			FLOAT 		NULL,
	fgt_pallets_out 		FLOAT 		NULL,
	fgt_carryins1 			FLOAT 		NULL,
	fgt_carryins2 			FLOAT 		NULL,
	fgt_stackable 			VARCHAR(1) 	NULL,
	fgt_ratingquantity 		FLOAT 		NULL,
	fgt_ratingunit 			VARCHAR(6) 	NULL,
	fgt_quantity_type 		SMALLINT	NULL,
	fgt_ordered_count 		REAL 		NULL,
	fgt_ordered_weight 		FLOAT 		NULL,
	tar_number 			INTEGER 	NULL,
	tar_tariffnumber 		VARCHAR(13) 	NULL,
	tar_tariffitem 			VARCHAR(13) 	NULL,
	fgt_charge_type 		SMALLINT	NULL,
	fgt_rate_type 			SMALLINT	NULL,
	fgt_loadingmeters 		DECIMAL(12,4)	NULL,
	fgt_loadingmetersunit 		VARCHAR(6) 	NULL,
	fgt_additionl_description 	VARCHAR(25)	NULL,
	fgt_specific_flashpoint 	FLOAT 		NULL,
	fgt_specific_flashpoint_unit	VARCHAR(6)	NULL,
	fgt_ordered_volume 		DECIMAL 	NULL,
	fgt_ordered_loadingmeters	DECIMAL 	NULL,
	fgt_pallet_type 		VARCHAR(6)	NULL,
	new_fgt_number			INTEGER		NULL,
	copy_number			INTEGER		NULL,
-- PTS 38773 Trimac added new columns to cc fcn.
	fgt_dispatched_quantity			FLOAT 			NULL,
	fgt_dispatched_unit				VARCHAR(6) 		NULL,
	fgt_actual_quantity				FLOAT 			NULL,
	fgt_actual_unit					VARCHAR(6) 		NULL,
	fgt_billable_quantity			FLOAT 			NULL,
	fgt_billable_unit				VARCHAR(6) 		NULL,
    tank_loc varchar(10) null   --41629
    )
   

CREATE TABLE #fgt_xref (
	fgt_id		INTEGER IDENTITY(1,1) NOT NULL,
	fgt_number	INTEGER	NOT NULL,
	new_fgt_number	INTEGER NULL)

CREATE TABLE #event(
	ord_hdrnumber 		INTEGER 	NULL,
	stp_number 		INTEGER 	NULL,
	evt_eventcode 		VARCHAR(6) 	NULL,
	evt_number 		INTEGER 	NULL,
	evt_startdate 		DATETIME 	NULL,
	evt_enddate 		DATETIME 	NULL,
	evt_status 		VARCHAR(6) 	NULL,
	evt_earlydate 		DATETIME 	NULL,
	evt_latedate 		DATETIME 	NULL,
	evt_weight 		FLOAT 		NULL,
	evt_weightunit 		VARCHAR(6) 	NULL,
	fgt_number 		INTEGER 	NULL,
	evt_count 		DECIMAL		NULL,
	evt_countunit 		VARCHAR(6) 	NULL,
	evt_volume 		FLOAT		NULL,
	evt_volumeunit 		VARCHAR(6)	NULL,
	evt_pu_dr 		VARCHAR(6)	NULL,
	evt_sequence 		INTEGER		NULL,
	evt_contact 		VARCHAR(30)	NULL,
	evt_driver1 		VARCHAR(8)	NULL,
	evt_driver2 		VARCHAR(8)	NULL,
	evt_tractor 		VARCHAR(8)	NULL,
	evt_trailer1 		VARCHAR(13)	NULL,
	evt_trailer2 		VARCHAR(13)	NULL,
	evt_chassis 		VARCHAR(13)	NULL,
	evt_dolly 		VARCHAR(13)	NULL,
	evt_carrier 		VARCHAR(8)	NULL,
	evt_refype 		VARCHAR(6)	NULL,
	evt_refnum 		VARCHAR(30)	NULL,
	evt_reason 		VARCHAR(6)	NULL,
	evt_enteredby		VARCHAR(20)	NULL,
	evt_hubmiles 		INTEGER 	NULL,
	skip_trigger 		TINYINT		NULL,
	evt_mov_number 		INTEGER 	NULL,
	evt_departure_status	VARCHAR(6)	NULL,
	new_evt_number		INTEGER		NULL,
	copy_number		INTEGER		NULL)

CREATE TABLE #evt_xref (
	evt_id		INTEGER IDENTITY(1,1) NOT NULL,
	evt_number	INTEGER	NOT NULL,
	new_evt_number	INTEGER NULL)

CREATE TABLE #referencenumber(
	ref_tablekey 	INTEGER 	NULL,
	ref_type 	VARCHAR(6) 	NULL,
	ref_number 	VARCHAR(20)	NULL,
	ref_typedesc 	VARCHAR(8) 	NULL,
	ref_sequence 	INTEGER 	NULL,
	ord_hdrnumber	INTEGER 	NULL,
	ref_table 	VARCHAR(18)	NULL,
	ref_sid 	CHAR(1) 	NULL,
	ref_pickup 	CHAR(1) 	NULL,
	ref_id		INTEGER IDENTITY(1,1) NOT NULL,
    	last_updateby 	VARCHAR(256) 	NULL,
    	last_updatedate DATETIME	NULL)

CREATE TABLE #ivd_xref (
	ivd_id		INTEGER IDENTITY(1,1) NOT NULL,
	ivd_number	INTEGER	NOT NULL,
	new_ivd_number	INTEGER NULL)

CREATE TABLE #pyd_xref (
	pyd_id		INTEGER IDENTITY(1,1) NOT NULL,
	pyd_number	INTEGER	NOT NULL,
	new_pyd_number	INTEGER NULL)

CREATE TABLE #notes_xref (
	not_id		INTEGER IDENTITY(1,1) NOT NULL,
	not_number	INTEGER	NOT NULL,
	new_not_number	INTEGER NULL)

--08/21/2008  JSwindell PTS44064 Add Thirdparty copy <<start>>
CREATE TABLE #temp_thirdpartyassignment (
	tpr_identity integer identity,
	tpr_id		VARCHAR(8)	NULL,  
	lgh_number	INTEGER 	NULL,
	mov_number	INTEGER 	NULL, 
	tpa_status	VARCHAR(6)	NULL,  
	pyd_status	VARCHAR(6)	NULL,
	tpr_type	VARCHAR(20)	NULL,
	ord_number	CHAR(12)	NULL) 	
declare @copythirdparty_count int	-- PTS 44064 Copy ThirdParty
--08/21/2008  JSwindell PTS44064 Add Thirdparty copy <<end>>

CREATE TABLE #temp (
	ord_num 	VARCHAR(12) NOT NULL)

CREATE TABLE #newords(
	ord_number 	VARCHAR(12),
	ord_startdate	DATETIME,
	ord_shipper	VARCHAR(8),
	shipper_name	VARCHAR(50),
	ord_consignee	VARCHAR(8),
	consignee_name	VARCHAR(50),
	ord_hdrnumber	INTEGER,
	ord_fromorder	VARCHAR(12),
	mov_number	INTEGER)

DECLARE	@orig_ord_hdrnumber		INTEGER,
	@stp_count			INTEGER,
	@evt_count			INTEGER,
	@fgt_count			INTEGER,
	@not_count			INTEGER,
	@ivd_count			INTEGER,
	@pyd_count			INTEGER,
	@loop_counter			INTEGER,
	@newordhdrnbr_start		INTEGER,
	@newordrevnbr_start		INTEGER,
	@newmovnbr_start		INTEGER,
	@oldmovnbr 			INTEGER,
	@newlghnbr_start		INTEGER,
	@newstpnbr_start		INTEGER,
	@newevtnbr_start		INTEGER,
	@newfgtnbr_start		INTEGER,
	@newnotnbr_start		INTEGER,
	@newivdnbr_start		INTEGER,
	@newpydnbr_start		INTEGER,
	@nbr				INTEGER,
	@ordstatus 			VARCHAR(6),
	@intervalminutes 		INTEGER,
	@return				INTEGER,
	@ord_rev 			CHAR(6),
	@revtype1_3 			CHAR(3),
	@reserved_str 			VARCHAR(254),
	@delete_reserved		VARCHAR(254),
	@ordhdr_nbr			INTEGER,
	@newordhdr_nbr			INTEGER,
	@newmov_nbr			INTEGER,
	@newlgh_nbr			INTEGER,
	@neword_nbr 			VARCHAR(12),
	@find				INTEGER,
	@minstp				INTEGER,
	@diffmins			INTEGER,
	@min_id				INTEGER,
	@ordstart	 		DATETIME,
	@ordcomplete 			DATETIME,
	@originearliest			DATETIME,
	@originlatest			DATETIME,
	@destearliest			DATETIME,
	@destlatest			DATETIME,
	@orderlist			VARCHAR(500),
	@tmwuser 			VARCHAR(255),
	@psreset			CHAR(1),
	@cmd_name			VARCHAR(60),
	@cmp_name			VARCHAR(100),
	@cmp_address1			VARCHAR(100),
	@cmp_address2			VARCHAR(100),
	@cmp_city			INTEGER,
	@cmp_state			VARCHAR(6),
	@cmp_zip			VARCHAR(10),
	@cty_nmstct			VARCHAR(25),
	@cmp_country			VARCHAR(50),
	@cmp_region1			VARCHAR(6),
	@cmp_region2			VARCHAR(6),
	@cmp_region3			VARCHAR(6),
	@cmp_region4			VARCHAR(6),
	@cmp_contact			VARCHAR(30),
	@cmp_phone1			VARCHAR(20),
	@cmp_phone2			VARCHAR(20),
	@stp_number			INTEGER,
	@cmd_code			VARCHAR(8),
	@shipper			VARCHAR(8),
	@CloneOrdersDefaultLRQ		CHAR(1),
	@toep_remaining_count 		INTEGER,
	@copiescreated			INTEGER,
	@CopyRefNumberExcludeRefType 	VARCHAR(60),
	@ref_sequence			INTEGER,
	@FirstRefNum 			VARCHAR(30),
	@FirstRefType 			VARCHAR(6),
	@CopyRefNumReplaceRefType	VARCHAR(60),
	@CopyRefNumReplaceRefTypeWith 	VARCHAR(60),
        @v_ret smallint,@v_newOrd 	INT,
	@neword_hdrnumber		INT,
	@newmov_number			INT,
	@newlgh_number			INT,
	@lghcount			INTEGER,
	@lghmin				INTEGER,
	@new_leg			INTEGER,
-- TGRIFFIT - PTS #38785
    @user_ref_flag CHAR(1),              
-- END TGRIFFIT - PTS #38785
    @DoNotUseCopyProcAsUser varchar(1), --PTS 39478 
    @NoteUser varchar(256),             --PTS 39478 
-- TGRIFFIT - PTS #38846
    @def_gvw_flag CHAR(1),
    @standards_gvw   DECIMAL(6,0)
-- END TGRIFFIT - PTS #38846  


SELECT @tmwuser = suser_sname()
				
SELECT	@copies = ISNULL(@copies, 1),
		@copydates = UPPER(ISNULL(@copydates,'N')),
		@startdate = ISNULL(@startdate,GETDATE()),
		@copystatus = Upper(IsNULL(@copystatus,'N')), 
		@status = Upper(IsNULL(@status,'AVL')),
		@copylinehaul  = Upper(IsNULL(@copylinehaul,'N')),
	 	@copyAccessorials = Upper(IsNULL(@copyAccessorials,'N')),
		@copynotes = Upper(IsNULL(@copynotes,'N')),
		@copydelinstructions = Upper(IsNULL(@copydelinstructions,'N')),
		@copypaydetails = Upper(IsNULL(@copypaydetails,'N')),
		@copyordrefs = Upper(IsNULL(@copyordrefs,'N')),
		@copyotherrefs = Upper(IsNULL(@copyotherrefs,'N')),
		@copyloadrequirements = Upper(IsNULL(@copyloadrequirements,'N')), 
		--PTS 28538 copy permit requirements
		@copypermitrequirements = Upper(IsNULL(@copypermitrequirements,'N')), 
		@copyinvoicebackouts = Upper(IsNULL(@copyinvoicebackouts,'N')),
		@status = UPPER(IsNULL(@status,'AVL')),
		@asgntractor = UPPER(IsNULL(@asgntractor,'UNKNOWN')),
		@asgntrailer1 = UPPER(IsNULL(@asgntrailer1,'UNKNOWN')),
		@asgntrailer2 = UPPER(IsNULL(@asgntrailer2,'UNKNOWN')),
		@asgndriver1 = UPPER(IsNULL(@asgndriver1,'UNKNOWN')),
		@asgndriver2 = UPPER(IsNULL(@asgndriver2,'UNKNOWN')),
		@asgncarrier = UPPER(IsNULL(@asgncarrier,'UNKNOWN')),
		@intervalminutes = (IsNULL(@incrementalDays,0) * 1440) + (IsNULL(@incrementalhours,0) * 60) + IsNULL(@incrementalminutes,0),
		@return = 0,
-- TGRIFFIT - PTS #38785 
        @copyreftype = ISNULL(@copyreftype, ''),
        @copyrefnum = ISNULL(@copyrefnum, ''),
-- END TGRIFFIT - PTS #38785
-- TGRIFFIT - PTS #38783
        @availdtascurrdt = ISNULL(@availdtascurrdt, 'N')
-- END TGRIFFIT - PTS #38783     

SELECT	@psreset = UPPER(LEFT(LTRIM(RTRIM(gi_string1)), 1)) 
  FROM	generalinfo 
 WHERE	gi_name = 'CopyResetPSOrdNum'

-- Begin PTS 39478
SELECT @DoNotUseCopyProcAsUser = isnull(Upper(gi_string1),'N') from generalinfo where gi_name = 'DoNotUseCopyProcAsUser' 
--End PTS 39478

IF @toep_id <> -1
BEGIN
	--32066 JJF 3/20/06 --make sure number of copies requested does not exceed max planned
	SELECT @toep_remaining_count = toep_ordered_count - toep_planned_count
	FROM ticket_order_entry_plan
	WHERE toep_id = @toep_id
	IF @copies > @toep_remaining_count BEGIN
		SET @copies = @toep_remaining_count
		--IF @copies < 1 BEGIN
			--GOTO SUCCESS_EXIT
		--END
	END
	--Set count now to reflect number created
	UPDATE ticket_order_entry_plan
	SET toep_planned_count = toep_planned_count + @copies
	WHERE toep_id = @toep_id
	--END 32066 JJF 3/20/06 --make sure number of copies requested does not exceed max planned

	SELECT	@cmd_name = cmd.cmd_name,
			@cmd_code = cmd.cmd_code
	  FROM	ticket_order_entry_plan toep
				INNER JOIN commodity cmd ON cmd.cmd_code = toep.cmd_code
	 WHERE	toep.toep_id = @toep_id

	SELECT	@shipper = cmp.cmp_id,
			@cmp_name = cmp.cmp_name,
			@cmp_address1 = cmp.cmp_address1,
			@cmp_address2 = cmp.cmp_address2,
			@cmp_city = cmp.cmp_city,
			@cmp_state = CASE ISNULL(cmp.cmp_state, 'XXXXXX')
							 WHEN 'XXXXXX' THEN cty.cty_state
							 ELSE cmp.cmp_state
						 END,
			@cmp_zip = CASE ISNULL(cmp.cmp_zip, 'XXXXXXXXXX')
						   WHEN 'XXXXXXXXXX' THEN cty.cty_zip
						   ELSE cmp.cmp_zip
					   END,
			@cty_nmstct = CASE ISNULL(cmp.cty_nmstct, 'XXXXXXXXXXXXXXXXXXXXXXXXX')
							  WHEN 'XXXXXXXXXXXXXXXXXXXXXXXXX' THEN cty.cty_nmstct
							  ELSE cmp.cty_nmstct
						  END,
			@cmp_country = CASE ISNULL(cmp.cmp_country, 'XXXXXXXXXXXXXXXXXXXXXXXXX')
							   WHEN 'XXXXXXXXXXXXXXXXXXXXXXXXX' THEN cty.cty_country
							   ELSE cmp.cmp_country
						   END,
			@cmp_region1 = CASE ISNULL(cmp.cmp_region1, 'XXXXXX')
							   WHEN 'XXXXXX' THEN cty.cty_region1
							   ELSE cmp.cmp_region1
						   END,
			@cmp_region2 = CASE ISNULL(cmp.cmp_region2, 'XXXXXX')
							   WHEN 'XXXXXX' THEN cty.cty_region2
							   ELSE cmp.cmp_region2
						   END,
			@cmp_region3 = CASE ISNULL(cmp.cmp_region3, 'XXXXXX')
							   WHEN 'XXXXXX' THEN cty.cty_region3
							   ELSE cmp.cmp_region3
						   END,
			@cmp_region4 = CASE ISNULL(cmp.cmp_region4, 'XXXXXX')
							   WHEN 'XXXXXX' THEN cty.cty_region4
							   ELSE cmp.cmp_region4
						   END,
			@cmp_contact = cmp.cmp_contact,
			@cmp_phone1 = cmp.cmp_primaryphone,
			@cmp_phone2 = cmp.cmp_secondaryphone
	  FROM	ticket_order_entry_plan toep
				INNER JOIN company cmp ON cmp.cmp_id = toep.toep_shipper
				LEFT OUTER JOIN city cty ON cmp.cmp_city = cty.cty_code
	 WHERE	toep.toep_id = @toep_id
END
ELSE
BEGIN
	SET @cmd_code = 'UNKNOWN'
	SET @shipper = 'UNKNOWN'
END

SELECT	@orig_ord_hdrnumber = ord_hdrnumber,
	@ordstatus = CASE @copystatus WHEN 'Y' THEN CASE ord_status
				WHEN 'MST' THEN 'AVL'
				WHEN 'ICO' THEN 'AVL'
				ELSE ord_status END ELSE @status END,
	@oldmovnbr = mov_number
  FROM	orderheader
 WHERE	ord_number = @ordnumber AND
		ord_hdrnumber > 0

SELECT	@stp_count = COUNT(ord_hdrnumber)
  FROM	stops
 WHERE	mov_number = @oldmovnbr AND
		stp_mfh_sequence > 0 AND
		stp_number > 0

SELECT	@evt_count = COUNT(e.stp_number)
  FROM	event e
			INNER JOIN stops s ON e.stp_number = s.stp_number
 WHERE	s.mov_number = @oldmovnbr AND
		s.stp_mfh_sequence > 0 AND
		e.evt_number > 0
		

SELECT	@fgt_count = COUNT(f.stp_number)
  FROM	freightdetail f
			INNER JOIN stops s ON f.stp_number = s.stp_number
 WHERE	s.mov_number = @oldmovnbr AND
		s.stp_mfh_sequence > 0 AND
		f.fgt_number > 0

IF @CopyAccessorials = 'Y' 
BEGIN
	SELECT	@ivd_count = COUNT(ivd_number)
	  FROM	invoicedetail i
				INNER JOIN chargetype c ON i.cht_itemcode = c.cht_itemcode
				LEFT OUTER JOIN invoiceheader ih ON i.ivh_hdrnumber = ih.ivh_hdrnumber
	 WHERE	i.ord_hdrnumber = @orig_ord_hdrnumber AND
			(ih.ivh_definition = 'LH' OR ih.ivh_definition IS NULL) AND
			c.cht_primary = 'N' AND
			i.ivd_number > 0
END


IF @copypaydetails = 'Y'
BEGIN
	SELECT	@pyd_count = COUNT(pyd_number)
	  FROM	paydetail
	 WHERE	ord_hdrnumber = @orig_ord_hdrnumber AND
			pyd_number > 0
END

IF @CopyNotes  = 'Y'
BEGIN
	SELECT 	@not_count = COUNT(not_number) 
	  FROM 	notes 
	 WHERE	ntb_table = 'orderheader' AND
			nre_tablekey = CONVERT(VARCHAR(18), @orig_ord_hdrnumber) AND
			ISNULL(autonote, 'N') <> 'Y'
END

EXEC @newordhdrnbr_start =  getsystemnumberblock 'ORDHDR', NULL, @copies
  IF @@ERROR <> 0 GOTO ERROR_EXIT2

IF @revtype1_format = 'Y'
BEGIN
	SELECT	@revtype1_3 = UPPER(LEFT(@revtype1 + '   ', 3))
	SELECT	@ord_rev = 'ORD' + @revtype1_3
	SELECT	@reserved_str = RTRIM(@reserved)

-- PTS 29681 -- BL (start)
--	(comment out)
--	EXEC @newordrevnbr_start =  getsystemnumberblock @ord_rev, NULL, @copies
-- PTS 29681 -- BL (end)
	IF @@ERROR <> 0 GOTO ERROR_EXIT2
END

--PRB PTS34451 - Add ability to use new TerminalPrefix7
IF @revtype1_format = 'T'
BEGIN
	SELECT	@revtype1_3 = UPPER(LEFT(@revtype1, 1))
	SELECT	@ord_rev = 'ORD' + @revtype1_3
	SELECT	@reserved_str = RTRIM(@reserved)

	IF @@ERROR <> 0 GOTO ERROR_EXIT2
END
--END PTS34451

SET @loop_counter = 1

WHILE @loop_counter <= @copies
BEGIN
   INSERT INTO #lgh_xref (lgh_number, copy_number)
      SELECT Distinct lgh_number, @loop_counter
        FROM stops
       WHERE mov_number = @movnumber
      ORDER BY lgh_number

   SET @loop_counter = @loop_counter + 1
END

SELECT @lghcount = Count(DISTINCT lgh_number)
  FROM stops
 WHERE mov_number = @movnumber

SET @lghcount = @lghcount * @copies


EXEC @newmovnbr_start =  getsystemnumberblock 'MOVNUM', NULL, @copies
IF @@ERROR <> 0 GOTO ERROR_EXIT2

EXEC @newlghnbr_start = getsystemnumberblock 'LEGHDR', NULL, @lghcount
IF @@ERROR <> 0 GOTO ERROR_EXIT2

SET @nbr = (@stp_count * @copies)
EXEC @newstpnbr_start =  getsystemnumberblock 'STPNUM', NULL, @nbr
IF @@ERROR <> 0 GOTO ERROR_EXIT2
	
SET @nbr = (@evt_count * @copies)
EXEC @newevtnbr_start =  getsystemnumberblock 'EVTNUM', NULL, @nbr
IF @@ERROR <> 0 GOTO ERROR_EXIT2

SET @nbr = (@fgt_count * @copies)
EXEC @newfgtnbr_start = getsystemnumberblock 'FGTNUM', NULL, @nbr
IF @@ERROR <> 0 GOTO ERROR_EXIT2

IF @CopyAccessorials = 'Y' AND @ivd_count > 0
BEGIN
	SET @nbr = (@ivd_count * @copies)
	EXEC @newivdnbr_start = getsystemnumberblock 'INVDET', NULL, @nbr
	IF @@ERROR <> 0 GOTO ERROR_EXIT2
END

IF @CopyNotes  = 'Y' AND @not_count > 0
BEGIN
	SET @nbr = (@not_count * @copies)
	EXEC @newnotnbr_start = getsystemnumberblock 'NOTES', NULL, @nbr
	IF @@ERROR <> 0 GOTO ERROR_EXIT2
END

IF @copypaydetails = 'Y' AND @pyd_count > 0
BEGIN
	SET @nbr = (@pyd_count * @copies)
	EXEC @newpydnbr_start = getsystemnumberblock 'PYDNUM', NULL, @nbr
	IF @@ERROR <> 0 GOTO ERROR_EXIT2
END

-- TGRIFFIT - PTS #38785      
  BEGIN
    SET @user_ref_flag = 'N'
    IF LTRIM(RTRIM(@copyreftype)) <> ''
        BEGIN
            SET @user_ref_flag = 'Y'
            SET @copyordrefs = 'N'
            SET @copyotherrefs = 'N'
        END
  END   
-- END TGRIFFIT - PTS #38785  

--34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
IF @copyordrefs = 'Y' BEGIN
	SELECT @CopyRefNumberExcludeRefType = gi_string1
	FROM generalinfo
	WHERE (gi_name = 'CopyRefNumberExclude')
END						
--END 34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value
IF @copyordrefs = 'Y' BEGIN
	SELECT 	@CopyRefNumReplaceRefType = gi_string1, 
		@CopyRefNumReplaceRefTypeWith = gi_string2
	FROM generalinfo
	WHERE (gi_name = 'CopyRefNumReplaceRefType')
END						
--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value

-- TGRIFFIT - PTS #38846
SELECT @def_gvw_flag = gi_string1 from generalinfo where upper(gi_name) = 'GVWCOLSDEFAULTS'
SELECT @standards_gvw = gvw from masterorders_ref where ord_hdrnumber = @orig_ord_hdrnumber
-- END TGRIFFIT - PTS #38846

INSERT INTO #orderheader
	SELECT	ord_company, 
			ord_number, 
			ord_customer, 
			GETDATE() ord_bookdate, 
			@ordbookedby ord_bookedby, 
			@ordstatus ord_status, 
			ord_originpoint, 
			ord_destpoint,												
			--vjh 20303 copymasterinvstatus
			Case When @copymasterinvstatus = 'Y' and ord_status = 'MST' then ord_invoicestatus
				Else Case @copystatus When 'Y' Then Case ord_status When 'MST' Then 'PND' When 'ICO' Then 'PND' Else ord_invoicestatus End  
				Else Case @status When 'CMP' Then 'AVL' Else 'PND' End End End,
--			CASE @ordstatus WHEN 'CMP' THEN 'AVL' ELSE 'PND' END ord_invoicestatus, 
			ord_origincity, 
			ord_destcity, 
			ord_originstate, 
			ord_deststate, 
			ord_originregion1, 
			ord_destregion1,		
			ord_supplier, 
			ord_billto, 
			ord_startdate, 
			ord_completiondate, 							
			CASE @revtype1_format 
				WHEN 'Y' THEN @revtype1
				WHEN 'T' THEN @revtype1 --PTS34451 
				ELSE ord_revtype1 
			END ord_revtype1,					
			ord_revtype2, 
			ord_revtype3, 
			ord_revtype4,
			CASE @copyquantities WHEN 'Y' THEN ord_totalweight ELSE 0 END ord_totalweight,
			CASE @copyquantities WHEN 'Y' THEN ord_totalpieces ELSE 0 END ord_totalpieces,				
			ord_totalmiles,
			ord_charge + ord_accessorial_chrg ord_totalcharge, 
			ord_currency, 
			GETDATE() ord_currencydate,
			CASE @copyquantities WHEN 'Y' THEN ord_totalvolume ELSE 0 END ord_totalvolume,		
			ord_hdrnumber,
			-- TGRIFFIT - PTS #38785  
			--CASE @copyordrefs WHEN 'Y' THEN ord_refnum ELSE NULL END ord_refnum,
            CASE @copyordrefs WHEN 'Y' THEN ord_refnum ELSE 
                CASE @user_ref_flag WHEN 'Y' THEN @copyrefnum ELSE NULL END END ord_refnum,
            -- END TGRIFFIT - PTS #38785 
			ord_invoicewhole, 
			ord_remark, 
			ord_shipper, 
			ord_consignee,	
			ord_pu_at, 
			ord_dr_at, 
			ord_originregion2, 
			ord_originregion3, 
			ord_originregion4,			
			ord_destregion2, 
			ord_destregion3, 
			ord_destregion4, 
			mfh_hdrnumber, 
			ord_priority,			
			mov_number,
			CASE @copylinehaul WHEN 'Y' THEN tar_tarriffnumber ELSE NULL END tar_tarriffnumber,
			CASE @copylinehaul WHEN 'Y' THEN tar_number ELSE 0 END tar_number,
			CASE @copylinehaul WHEN 'Y' THEN tar_tariffitem ELSE NULL END tar_tariffitem,
			ord_contact, 
			ord_showshipper, 
			ord_showcons, 
			ord_subcompany, 
			ord_lowtemp, 
			ord_hitemp,					
			CASE @copylinehaul WHEN 'Y' THEN ord_quantity ELSE 0.0 END ord_quantity,
			CASE @copylinehaul WHEN 'Y' THEN ord_rate ELSE CONVERT(MONEY,0.00) END ord_rate,
			CASE @copylinehaul WHEN 'Y' THEN ord_charge ELSE CONVERT(MONEY,0.00) END ord_charge, 
			ord_rateunit, 
			ord_unit,	
			trl_type1, 
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN' 
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN ord_driver1 
						ELSE @asgndriver1  
					 END
			END ord_driver1,
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN' 
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN ord_driver2 
						ELSE @asgndriver2  
					 END
			END ord_driver2, 
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN' 
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN ord_tractor 
						ELSE @asgntractor  
					 END
			END ord_tractor, 
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN'  
				ELSE CASE
						WHEN @copyassigns = 'Y' THEN ord_trailer 
						ELSE @asgntrailer1
					 END
			END ord_trailer, 							
			ord_length, 
			ord_width, 
			ord_height, 
			ord_lengthunit, 
			ord_widthunit,						
			ord_heightunit,
-- PTS 27421 -- BL (start)
--			CASE @copyordrefs WHEN 'Y' THEN ord_reftype ELSE 'UNK' END ord_reftype, 
-- TGRIFFIT - PTS #38785 
			--ord_reftype, 
            CASE @user_ref_flag WHEN 'Y' THEN @copyreftype ELSE ord_reftype END ord_reftype,
-- END TGRIFFIT - PTS #38785 
-- PTS 27421 -- BL (end)
			cmd_code, 
			ord_description, 
			ord_terms,						
			CASE @copylinehaul WHEN 'Y' THEN cht_itemcode ELSE 'UNK' END cht_itemcode, 
			ord_origin_earliestdate, 
			ord_origin_latestdate, 
			ord_odmetermiles,			
			ord_stopcount, 
			ord_dest_earliestdate, 
			ord_dest_latestdate, 
			ref_sid, 
			ref_pickup, 		
			ord_cmdvalue,
			CASE @copyaccessorials WHEN 'Y' THEN ord_accessorial_chrg ELSE CONVERT(MONEY,0.00) END ord_accessorial_chrg, 
-- TGRIFFIT - PTS #38783          
			--ord_availabledate, 
            CASE @availdtascurrdt WHEN 'Y' THEN GETDATE() ELSE ord_availabledate END ord_availabledate,
-- END TGRIFFIT - PTS #38783 
			ord_miscqty, 
			ord_tempunits, 		
			GETDATE() ord_datetaken, 
			ord_totalweightunits, 
			ord_totalvolumeunits, 
			ord_totalcountunits, 		
			ord_loadtime, 
			ord_unloadtime, 
			ord_drivetime, 
			ord_rateby,
			CASE @copylinehaul WHEN 'Y' THEN ord_quantity_type ELSE 0 END ord_quantity_type, 			
			ord_thirdpartytype1, 
			ord_thirdpartytype2, 
			CASE @copylinehaul 
				WHEN 'Y' THEN CASE @copyaccessorials 
								WHEN 'Y' THEN ord_charge_type 
								ELSE 0 
							  END
				ELSE 0 
			END ord_charge_type, 
			ord_bol_printed, 
			@ordnumber ord_fromorder, 
			ord_mintemp, 
			ord_maxtemp, 
			ord_distributor, 
			opt_trc_type4, 				
			opt_trl_type4, 
			ord_cod_amount, 
			appt_init, 
			appt_contact,
			CASE @copylinehaul WHEN 'Y' THEN ord_ratingquantity ELSE NULL END ord_ratingquantity, 			
			CASE @copylinehaul WHEN 'Y' THEN ord_ratingunit ELSE NULL END ord_ratingunit, 
			Case @OverrideBookedRevtype1 When '' Then ord_booked_revtype1 When 'UNK' Then ord_booked_revtype1 Else @OverrideBookedRevtype1 End ord_booked_revtype1, --41629 ord_booked_revtype1, 
			ord_hideshipperaddr, 
			ord_hideconsignaddr, 			
			ord_trl_type2, 
			ord_trl_type3, 
			ord_trl_type4, 
			ord_tareweight, 
			ord_grossweight, 
			ord_mileagetable, 
			CASE @copylinehaul WHEN 'Y' THEN ord_allinclusivecharge ELSE NULL END ord_allinclusivecharge, 
			CASE @copylinehaul WHEN 'Y' THEN ord_rate_type ELSE 0 END ord_rate_type, 
			CASE @copylinehaul WHEN 'Y' THEN ord_stlquantity ELSE 0.0 END ord_stlquantity, 
			CASE @copylinehaul WHEN 'Y' THEN ord_stlunit ELSE 'UNK' END ord_stlunit, 	
			CASE @copylinehaul WHEN 'Y' THEN ord_stlquantity_type ELSE 0 END ord_stlquantity_type, 
			CASE @copylinehaul WHEN 'Y' THEN ord_revenue_pay ELSE 0 END ord_revenue_pay,  
			ord_reserved_number, 
			ord_customs_document,  	
			ord_noautosplit,  
			ord_noautotransfer, 
			CASE @copyquantities WHEN 'Y' THEN ord_totalloadingmeters ELSE 0 END ord_totalloadingmeters,  						
			ord_totalloadingmetersunit,  
			CASE @copylinehaul WHEN 'Y' THEN ord_charge_type_lh ELSE 0 END ord_charge_type_lh, 
			ord_mileage_adj_pct, 
			ord_dimfactor, 
			ord_trlconfiguration,
			ord_rate_mileagetable,
			ord_raildest,
			ord_railpoolid,
			ord_trailer2,
			ord_route,
			ord_route_effc_date,
			ord_route_exp_date,
			ord_odmetermiles_mtid,
			ord_origin_zip,
			ord_dest_zip,
			ord_no_recalc_miles,
            car_key,  --41629
            CASE @def_gvw_flag WHEN 'Y' THEN 'LBS' ELSE NULL END ord_gvw_unit,  --PTS 38846 TGRIFFIT
            CASE @def_gvw_flag 
                WHEN 'Y' THEN
                    CASE ISNULL(ord_gvw_adjstd_amt,0) 
                        WHEN 0 THEN 'LBS' 
                        ELSE ord_gvw_adjstd_unit 
                    END 
                ELSE
                    NULL
                END ord_gvw_adjstd_unit,    
            CASE @def_gvw_flag 
                WHEN 'Y' THEN             
                    CASE ISNULL(ord_gvw_adjstd_amt,0) 
                        WHEN 0 THEN @standards_gvw
                        ELSE ord_gvw_adjstd_amt 
                    END 
                ELSE
                    NULL
                END ord_gvw_adjstd_amt,                                          -- END PTS 38846 TGRIFFIT    
			ord_thirdpartytype3,
			ord_thirdparty_split_percent,
			ord_thirdparty_split,
            ord_cyclic_dsp_enabled,                                              --PTS 43236 TGRIFFIT
            ord_preassign_ack_required,                                          --PTS 43236 TGRIFFIT
		ord_broker,	--PTS50180 MBR 12/10/09
		CASE @copylinehaul WHEN 'Y' THEN ord_ratemode ELSE 'UNK' END ord_ratemode,			/* 11/18/2011 NQIAO PTS 58978 */
		CASE @copylinehaul WHEN 'Y' THEN ord_servicelevel ELSE 'UNK' END ord_servicelevel,	/* 11/18/2011 NQIAO PTS 58978 */
		CASE @copylinehaul WHEN 'Y' THEN ord_servicedays ELSE NULL END ord_servicedays		/* 11/18/2011 NQIAO PTS 58978 */
	  FROM	orderheader
	 WHERE	ord_hdrnumber = @orig_ord_hdrnumber 

SET @loop_counter = 1
--PTS35926 MBR 09/28/07  Moved the next line here instead of inside the loop.
SET @new_leg = @newlghnbr_start
WHILE @loop_counter <= @copies
BEGIN
	SET @newordhdr_nbr = @newordhdrnbr_start + (@loop_counter - 1)
	SET @newmov_nbr = @newmovnbr_start + (@loop_counter - 1)
	SET @newlgh_nbr = @newlghnbr_start + (@loop_counter - 1)

	IF @revtype1_format = 'Y'
	BEGIN
		TRUNCATE TABLE #temp

		-- PTS 29681 -- BL (start)
--		INSERT #temp EXEC get_ord_terminal_pref @newordhdr_nbr
		EXEC @newordrevnbr_start =  getsystemnumber @ord_rev, NULL
		--INSERT #temp EXEC get_ord_terminal_pref @newordrevnbr_start
        INSERT #temp EXEC get_ord_terminal_pref @newordrevnbr_start,@revtype1_format
		-- PTS 29681 -- BL (end)

		SELECT @neword_nbr = ord_num FROM #temp

		IF @@ERROR <> 0 GOTO ERROR_EXIT2

		IF @reserved_str = ''
		BEGIN
			SELECT @neword_nbr = @revtype1_3 + RIGHT('00000' + @neword_nbr, 5)
		END
	--PRB PTS34451
	ELSE IF @revtype1_format = 'T'
	BEGIN
		TRUNCATE TABLE #temp

		EXEC @newordrevnbr_start =  getsystemnumber @ord_rev, NULL
        --INSERT #temp EXEC get_ord_terminal_pref @newordrevnbr_start
        INSERT #temp EXEC get_ord_terminal_pref @newordrevnbr_start,@revtype1_format

		SELECT @neword_nbr = ord_num FROM #temp

		IF @@ERROR <> 0 GOTO ERROR_EXIT2

		IF @reserved_str = ''
		BEGIN
			SELECT @neword_nbr = RTRIM(@revtype1_3) + RIGHT('0000000' + @neword_nbr, 7)
		END
		ELSE
		BEGIN
			SELECT @find = CHARINDEX(',', @reserved_str)
			IF @find > 0
			BEGIN
				SELECT @neword_nbr = SUBSTRING(@reserved_str, 1, (@find - 1))
				SELECT @delete_reserved = @neword_nbr 
				SELECT @reserved_str = SUBSTRING(@reserved_str, (@find + 1), (254 - @find))
			END
		END
	END
	--END PTS34451
		ELSE
		BEGIN
			SELECT @find = CHARINDEX(',', @reserved_str)
			IF @find > 0
			BEGIN
				SELECT @neword_nbr = SUBSTRING(@reserved_str, 1, (@find - 1))
				SELECT @delete_reserved = @neword_nbr 
				SELECT @reserved_str = SUBSTRING(@reserved_str, (@find + 1), (254 - @find))
			END
		END
	END
	ELSE
	BEGIN
		SELECT @neword_nbr = CONVERT(VARCHAR(12), @newordhdr_nbr)
	END

	IF @UseAlphaOrdId = 'Y'
	BEGIN
		TRUNCATE TABLE #temp 
		
        --INSERT #temp EXEC get_ord_terminal_pref @newordhdr_nbr
        INSERT #temp EXEC get_ord_terminal_pref @newordhdr_nbr,@revtype1_format
	
		SELECT @neword_nbr = ord_num FROM #temp

		IF @@ERROR <> 0 GOTO ERROR_EXIT2

		SET @neword_nbr = REPLACE(LTRIM(REPLACE(@neword_nbr, '0', ' ')), ' ', '0')
	END

	-- PTS 44064 Copy ThirdParty <<start>>
	IF @copythirdparty = 'Y' 
		BEGIN
			IF @copythirdparty = 'Y' 	
				declare @tpr_lgh_number int			-- this is needed for consolidated orders where
													-- order#'s are different but lgh_number is the same.
				set  @tpr_lgh_number = (select min(lgh_number) from thirdpartyassignment where ord_number = @ordnumber)

			INSERT INTO #temp_thirdpartyassignment(tpr_id, lgh_number, mov_number, tpa_status, pyd_status,tpr_type, ord_number)
			select tpr_id, @newlgh_nbr, @newmov_nbr, 'AUTOCC', 'NPD',tpr_type, CONVERT(VARCHAR(12), @newordhdr_nbr) 
			from thirdpartyassignment
			--where ord_number = @ordnumber 
			where lgh_number = @tpr_lgh_number		
			AND	  tpa_status <> 'DEL'
		END
	-- PTS 44064 Copy ThirdParty <<end>>		

	INSERT INTO #orderheader_xref
		SELECT	ord_hdrnumber,
				@loop_counter copy_number,
				@newordhdr_nbr new_ord_hdrnumber,
				@neword_nbr new_ord_number,
				@newmov_nbr new_mov_number,		
				@newlgh_nbr new_lgh_number
		  FROM	#orderheader
	
	SELECT @lghmin = MIN(lgh_number)
	  FROM #lgh_xref
         WHERE copy_number = @loop_counter

	WHILE ISNULL(@lghmin, 0) > 0 
	BEGIN
	   UPDATE #lgh_xref
              SET new_lgh_number = @new_leg
            WHERE lgh_number = @lghmin AND
                  copy_number = @loop_counter

	   SET @new_leg = @new_leg + 1
	   

	   SELECT @lghmin = MIN(lgh_number)
             FROM #lgh_xref
            WHERE copy_number = @loop_counter AND
                  lgh_number > @lghmin
	END
        

	SET @loop_counter = @loop_counter + 1
END

-- PTS 35479 Use GI setting to create copied rows
If Upper(@RollBackCloneOrder) = 'Y'
	Begin
	INSERT INTO #stops
			(ord_hdrnumber,
			 stp_number,
			 cmp_id,
			 stp_region1,
			 stp_region2,
			 stp_region3,
			 stp_city,
			 stp_state,
			 stp_schdtearliest,	
			 stp_origschdt,
			 stp_arrivaldate,
			 stp_departuredate,
			 stp_reasonlate,
			 stp_schdtlatest,
			 lgh_number,
			 mfh_number,
			 stp_type,	
			 stp_paylegpt,
			 shp_hdrnumber,
			 stp_sequence,
			 stp_region4,
			 stp_lgh_sequence,
			 trl_id,
			 stp_mfh_sequence,
			 stp_event,
			 stp_mfh_position,	
			 stp_lgh_position,
			 stp_mfh_status,
			 stp_lgh_status,
			 stp_ord_mileage,
			 stp_lgh_mileage,
			 stp_mfh_mileage,
			 mov_number,
			 stp_loadstatus,
			 stp_weight,
			 stp_weightunit,
			 cmd_code,
			 stp_description,
			 stp_count,
			 stp_countunit,
			 cmp_name,
			 stp_comment,
			 stp_status,
			 stp_reftype,	
			 stp_refnum,
			 stp_reasonlate_depart,
			 stp_screenmode,
			 skip_trigger,
			 stp_volume,
			 stp_volumeunit,
			 stp_dispatched_sequence,
			 stp_arr_confirmed,
			 stp_dep_confirmed,
			 stp_type1,
			 stp_redeliver,
			 stp_osd,
			 stp_pudelpref,
			 stp_phonenumber,
			 stp_delayhours,
			 stp_ooa_mileage,
			 stp_zipcode,
			 stp_ooa_stop,
			 stp_address,
	         stp_transfer_stp,
			 stp_phonenumber2,
			 stp_address2,
			 stp_contact,
			 stp_custpickupdate,
			 stp_custdeliverydate,
			 stp_podname,
			 stp_cmp_close, 
			 stp_activitystart_dt,
			 stp_activityend_dt,
			 stp_departure_status,
			 stp_eta,
			 stp_etd,
			 stp_transfer_type,
			 stp_trip_mileage, 
			 stp_loadingmeters, 
			 stp_loadingmetersunit, 
			 stp_country, 
			 stp_cod_amount, 
			 stp_cod_currency,
			 stp_ord_mileage_mtid,
			 stp_lgh_mileage_mtid,
			 stp_ooa_mileage_mtid,
			 stp_pallets_in,
			 stp_pallets_out)
			SELECT	ord_hdrnumber,
					stp_number,
					stops.cmp_id,
					stp_region1,
					stp_region2,
					stp_region3,
					stp_city,
					stp_state,
					stp_schdtearliest,	
					stp_origschdt,
					stp_arrivaldate,
					stp_departuredate,
					'UNK' stp_reasonlate,
					stp_schdtlatest,
					lgh_number,
					0 mfh_number,
					stp_type,	
					stp_paylegpt,
					shp_hdrnumber,
					stp_sequence,
					stp_region4,
					stp_lgh_sequence,
					trl_id,
					stp_mfh_sequence,
					stp_event,
					stp_mfh_position,	
					stp_lgh_position,
					stp_mfh_status,
					stp_lgh_status,
					stp_ord_mileage,
	--				stp_ord_mileage stp_lgh_mileage,	LOR
	-- PTS 31464 -- BL (start)
	--				stp_lgh_mileage,
	-- PTS 34082 -- BL (start)
	--				CASE stp_sequence WHEN 1 THEN NULL ELSE stp_lgh_mileage END stp_lgh_mileage,
	-- PTS 35479 -- SLM comment out this line to remove 34082 changes					CASE stp_sequence WHEN 1 THEN NULL ELSE stp_ord_mileage END stp_lgh_mileage,
	-- PTS 34082 -- BL (end)
	-- PTS 31464 -- BL (end)
	                                CASE stp_sequence WHEN 1 THEN NULL ELSE stp_lgh_mileage END stp_lgh_mileage, -- PTS 35479 SLM put back changes for PTS 24628, PTS 31464
					stp_mfh_mileage,
					mov_number,
					stp_loadstatus,
					CASE @copyquantities WHEN 'Y' THEN stp_weight ELSE 0 END stp_weight,
					stp_weightunit,
					stops.cmd_code,
					stp_description,
					CASE @copyquantities WHEN 'Y' THEN stp_count ELSE 0 END stp_count,
					stp_countunit,
					company.cmp_name, --cmp_name,
					CASE @copydelinstructions WHEN 'Y' THEN stp_comment ELSE '' END stp_comment,
					CASE @copystatus
						WHEN 'Y' THEN stp_status
						ELSE CASE
								WHEN @status = 'CMP' THEN 'DNE'
								WHEN @status = 'STD' AND stp_sequence = 1 THEN 'DNE'
								ELSE 'OPN'
							 END
					END stp_status,
					-- TGRIFFIT - PTS #38785   
					--CASE @copyotherrefs WHEN 'Y' THEN stp_reftype ELSE 'UNK' END stp_reftype,	
                    CASE @copyotherrefs WHEN 'Y' THEN stp_reftype ELSE 
                        CASE @user_ref_flag WHEN 'Y' THEN 'BL#' ELSE 'UNK' END END stp_reftype,
                    -- END TGRIFFIT - PTS #38785 	
					CASE @copyotherrefs WHEN 'Y' THEN stp_refnum ELSE NULL END stp_refnum,
					'UNK' stp_reasonlate_depart,
					stp_screenmode,
					skip_trigger,
					CASE @copyquantities WHEN 'Y' THEN stp_volume ELSE 0 END stp_volume,
					stp_volumeunit,
					stp_dispatched_sequence,
					stp_arr_confirmed,
					stp_dep_confirmed,
					stp_type1,
					stp_redeliver,
					stp_osd,
					stp_pudelpref,
					stp_phonenumber,
					stp_delayhours,
					stp_ooa_mileage,
					stp_zipcode,
					stp_ooa_stop,
					Case IsNull(stops.cmp_id,'UNKNOWN') When 'UNKNOWN' then stp_address else Substring(cmp_address1,1,40) END,   --stp_address,
			        NULL stp_transfer_stp,
					stp_phonenumber2,
					Case IsNull(stops.cmp_id,'UNKNOWN') When 'UNKNOWN' then stp_address2 else Substring(cmp_address2,1,40) END,     --stp_address2,
					stp_contact,
					stp_custpickupdate,
					stp_custdeliverydate,
					stp_podname,
					stp_cmp_close, 
					CASE WHEN @ordstatus IN ('PLN', 'AVL') THEN '19500101 00:00' ELSE stp_activitystart_dt END stp_activitystart_dt,
					CASE WHEN @ordstatus IN ('PLN', 'AVL') THEN '19500101 00:00' ELSE stp_activityend_dt END stp_activityend_dt,
					CASE @copystatus
						WHEN 'Y' THEN stp_departure_status
						ELSE CASE
								WHEN @status = 'CMP' THEN 'DNE'
								WHEN @status = 'STD' AND stp_sequence = 1 THEN 'DNE'
								ELSE 'OPN'
							 END
					END stp_departure_status,
					stp_eta,
					stp_etd,
					stp_transfer_type,
	-- PTS 34082 -- BL (start)
	--				stp_trip_mileage, 
	--				0,-- PTS 35479 SLM Comment out this line;  roll back changes made from PTS 34082
	-- PTS 34082 -- BL (end)
					stp_trip_mileage, -- PTS 35479 SLM roll back changes made from PTS 34082
					CASE @copyquantities WHEN 'Y' THEN stp_loadingmeters ELSE 0 END stp_loadingmeters, 
					stp_loadingmetersunit, 
					stp_country, 
					stp_cod_amount, 
					stp_cod_currency,
					stp_ord_mileage_mtid,
					stp_lgh_mileage_mtid,
					stp_ooa_mileage_mtid,
					isnull(stp_pallets_in,0),
					isnull(stp_pallets_out,0)
			  FROM	stops
	                  left outer join company on stops.cmp_id = company.cmp_id
			 WHERE	mov_number  = @movnumber AND
					stp_mfh_sequence > 0
	
	End
Else
	-- GI SETTING RollBackCloneOrder IS NOT being used.
	Begin
	INSERT INTO #stops
			(ord_hdrnumber,
			 stp_number,
			 cmp_id,
			 stp_region1,
			 stp_region2,
			 stp_region3,
			 stp_city,
			 stp_state,
			 stp_schdtearliest,	
			 stp_origschdt,
			 stp_arrivaldate,
			 stp_departuredate,
			 stp_reasonlate,
			 stp_schdtlatest,
			 lgh_number,
			 mfh_number,
			 stp_type,	
			 stp_paylegpt,
			 shp_hdrnumber,
			 stp_sequence,
			 stp_region4,
			 stp_lgh_sequence,
			 trl_id,
			 stp_mfh_sequence,
			 stp_event,
			 stp_mfh_position,	
			 stp_lgh_position,
			 stp_mfh_status,
			 stp_lgh_status,
			 stp_ord_mileage,
			 stp_lgh_mileage,
			 stp_mfh_mileage,
			 mov_number,
			 stp_loadstatus,
			 stp_weight,
			 stp_weightunit,
			 cmd_code,
			 stp_description,
			 stp_count,
			 stp_countunit,
			 cmp_name,
			 stp_comment,
			 stp_status,
			 stp_reftype,	
			 stp_refnum,
			 stp_reasonlate_depart,
			 stp_screenmode,
			 skip_trigger,
			 stp_volume,
			 stp_volumeunit,
			 stp_dispatched_sequence,
			 stp_arr_confirmed,
			 stp_dep_confirmed,
			 stp_type1,
			 stp_redeliver,
			 stp_osd,
			 stp_pudelpref,
			 stp_phonenumber,
			 stp_delayhours,
			 stp_ooa_mileage,
			 stp_zipcode,
			 stp_ooa_stop,
			 stp_address,
	         stp_transfer_stp,
			 stp_phonenumber2,
			 stp_address2,
			 stp_contact,
			 stp_custpickupdate,
			 stp_custdeliverydate,
			 stp_podname,
			 stp_cmp_close, 
			 stp_activitystart_dt,
			 stp_activityend_dt,
			 stp_departure_status,
			 stp_eta,
			 stp_etd,
			 stp_transfer_type,
			 stp_trip_mileage, 
			 stp_loadingmeters, 
			 stp_loadingmetersunit, 
			 stp_country, 
			 stp_cod_amount, 
			 stp_cod_currency,
			 stp_ord_mileage_mtid,
			 stp_lgh_mileage_mtid,
			 stp_ooa_mileage_mtid,
			 stp_pallets_in,
			 stp_pallets_out)
			SELECT	ord_hdrnumber,
					stp_number,
					stops.cmp_id,
					stp_region1,
					stp_region2,
					stp_region3,
					stp_city,
					stp_state,
					stp_schdtearliest,	
					stp_origschdt,
					stp_arrivaldate,
					stp_departuredate,
					'UNK' stp_reasonlate,
					stp_schdtlatest,
					lgh_number,
					0 mfh_number,
					stp_type,	
					stp_paylegpt,
					shp_hdrnumber,
					stp_sequence,
					stp_region4,
					stp_lgh_sequence,
					trl_id,
					stp_mfh_sequence,
					stp_event,
					stp_mfh_position,	
					stp_lgh_position,
					stp_mfh_status,
					stp_lgh_status,
					stp_ord_mileage,
	--				stp_ord_mileage stp_lgh_mileage,	LOR
	-- PTS 31464 -- BL (start)
	--				stp_lgh_mileage,
	-- PTS 34082 -- BL (start)
	--				CASE stp_sequence WHEN 1 THEN NULL ELSE stp_lgh_mileage END stp_lgh_mileage,
					CASE stp_sequence WHEN 1 THEN NULL ELSE stp_ord_mileage END stp_lgh_mileage,
	-- PTS 34082 -- BL (end)
	-- PTS 31464 -- BL (end)
					stp_mfh_mileage,
					mov_number,
					stp_loadstatus,
					CASE @copyquantities WHEN 'Y' THEN stp_weight ELSE 0 END stp_weight,
					stp_weightunit,
					stops.cmd_code,
					stp_description,
					CASE @copyquantities WHEN 'Y' THEN stp_count ELSE 0 END stp_count,
					stp_countunit,
					company.cmp_name, --cmp_name,
					CASE @copydelinstructions WHEN 'Y' THEN stp_comment ELSE '' END stp_comment,
					CASE @copystatus
						WHEN 'Y' THEN stp_status
						ELSE CASE
								WHEN @status = 'CMP' THEN 'DNE'
								WHEN @status = 'STD' AND stp_sequence = 1 THEN 'DNE'
								ELSE 'OPN'
							 END
					END stp_status,
					 -- TGRIFFIT - PTS #38785   
					--CASE @copyotherrefs WHEN 'Y' THEN stp_reftype ELSE 'UNK' END stp_reftype,	
                    CASE @copyotherrefs WHEN 'Y' THEN stp_reftype ELSE 
                        CASE @user_ref_flag WHEN 'Y' THEN 'BL#' ELSE 'UNK' END END stp_reftype,
                    -- END TGRIFFIT - PTS #38785 	
					CASE @copyotherrefs WHEN 'Y' THEN stp_refnum ELSE NULL END stp_refnum,
					'UNK' stp_reasonlate_depart,
					stp_screenmode,
					skip_trigger,
					CASE @copyquantities WHEN 'Y' THEN stp_volume ELSE 0 END stp_volume,
					stp_volumeunit,
					stp_dispatched_sequence,
					stp_arr_confirmed,
					stp_dep_confirmed,
					stp_type1,
					stp_redeliver,
					stp_osd,
					stp_pudelpref,
					stp_phonenumber,
					stp_delayhours,
					stp_ooa_mileage,
					stp_zipcode,
					stp_ooa_stop,
					Case IsNull(stops.cmp_id,'UNKNOWN') When 'UNKNOWN' then stp_address else Substring(cmp_address1,1,40) END,   --stp_address,
			        NULL stp_transfer_stp,
					stp_phonenumber2,
					Case IsNull(stops.cmp_id,'UNKNOWN') When 'UNKNOWN' then stp_address2 else Substring(cmp_address2,1,40) END,     --stp_address2,
					stp_contact,
					stp_custpickupdate,
					stp_custdeliverydate,
					stp_podname,
					stp_cmp_close, 
					CASE WHEN @ordstatus IN ('PLN', 'AVL') THEN '19500101 00:00' ELSE stp_activitystart_dt END stp_activitystart_dt,
					CASE WHEN @ordstatus IN ('PLN', 'AVL') THEN '19500101 00:00' ELSE stp_activityend_dt END stp_activityend_dt,
					CASE @copystatus
						WHEN 'Y' THEN stp_departure_status
						ELSE CASE
								WHEN @status = 'CMP' THEN 'DNE'
								WHEN @status = 'STD' AND stp_sequence = 1 THEN 'DNE'
								ELSE 'OPN'
							 END
					END stp_departure_status,
					stp_eta,
					stp_etd,
					stp_transfer_type,
	-- PTS 34082 -- BL (start)
	--				stp_trip_mileage, 
					0,
	-- PTS 34082 -- BL (end)
					CASE @copyquantities WHEN 'Y' THEN stp_loadingmeters ELSE 0 END stp_loadingmeters, 
					stp_loadingmetersunit, 
					stp_country, 
					stp_cod_amount, 
					stp_cod_currency,
					stp_ord_mileage_mtid,
					stp_lgh_mileage_mtid,
					stp_ooa_mileage_mtid,
					isnull(stp_pallets_in,0),
					isnull(stp_pallets_out,0)
			  FROM	stops
	                  left outer join company on stops.cmp_id = company.cmp_id
			 WHERE	mov_number  = @movnumber AND
					stp_mfh_sequence > 0
		
		End


INSERT INTO #stp_xref
	(stp_number)
	SELECT	stp_number
	  FROM	#stops
	ORDER BY stp_mfh_sequence
	
INSERT INTO #event
	(ord_hdrnumber,
	 stp_number,
	 evt_eventcode,
	 evt_number,
	 evt_startdate,
	 evt_enddate,
	 evt_status,
	 evt_earlydate,
	 evt_latedate,
	 evt_weight,
	 evt_weightunit,
	 fgt_number,
	 evt_count,
	 evt_countunit,
	 evt_volume,
	 evt_volumeunit,
	 evt_pu_dr,
	 evt_sequence,
	 evt_contact,
	 evt_driver1,
	 evt_driver2,
	 evt_tractor,
	 evt_trailer1,
	 evt_trailer2,
	 evt_chassis,
	 evt_dolly,
	 evt_carrier,
	 evt_refype,
	 evt_refnum,
	 evt_reason,
	 evt_enteredby,
	 evt_hubmiles,
	 skip_trigger,
	 evt_mov_number,
	 evt_departure_status)
	SELECT	e.ord_hdrnumber,
			e.stp_number,
			e.evt_eventcode,
			e.evt_number,
			e.evt_startdate,
			e.evt_enddate,
			e.evt_status,
			e.evt_earlydate,
			e.evt_latedate,
			e.evt_weight,
			e.evt_weightunit,
			e.fgt_number,
			e.evt_count,
			e.evt_countunit,
			e.evt_volume,
			e.evt_volumeunit,
			e.evt_pu_dr,
			e.evt_sequence,
			e.evt_contact,
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN' 
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN e.evt_driver1 
						ELSE @asgndriver1  
					 END 
			END evt_driver1,
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN' 
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN e.evt_driver2
						ELSE @asgndriver2
					 END 
			END evt_driver2,
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN' 
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN e.evt_tractor 
						ELSE @asgntractor  
					 END 
			END evt_tractor,
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN'  
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN e.evt_trailer1 
						ELSE @asgntrailer1  
					 END 
			END evt_trailer1,
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN'  
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN e.evt_trailer2
						ELSE @asgntrailer2
					 END 
			END evt_trailer2,
			e.evt_chassis,
			e.evt_dolly,
			CASE @ordstatus 
				WHEN 'AVL' THEN 'UNKNOWN' 
				ELSE CASE 
						WHEN @copyassigns = 'Y' THEN e.evt_carrier  
						ELSE @asgncarrier 
					 END 
			END evt_carrier,
			e.evt_refype,
			e.evt_refnum,
			--JLB PTS 28589 do not copy the reason to the new events
			--e.evt_reason,
			'UNK',
			--end 28589
			e.evt_enteredby,
			NULL evt_hubmiles,
			e.skip_trigger,
			e.evt_mov_number,
			e.evt_departure_status
	  FROM	#stops s
				INNER JOIN event e ON s.stp_number = e.stp_number

INSERT INTO #evt_xref
	(evt_number)
	SELECT	e.evt_number
	  FROM	#stops s
				INNER JOIN event e ON s.stp_number = e.stp_number
	ORDER BY s.stp_mfh_sequence, e.evt_sequence

INSERT INTO #freightdetail
	(fgt_number,
	 cmd_code,
	 fgt_weight,
	 fgt_weightunit,
	 fgt_description,
	 stp_number,
	 fgt_count,
	 fgt_countunit,
	 fgt_volume,
	 fgt_volumeunit,   -- 10
	 fgt_lowtemp,
	 fgt_hitemp,
	 fgt_sequence,
	 fgt_length,	
	 fgt_lengthunit,
	 fgt_height,
	 fgt_heightunit,
	 fgt_width,
	 fgt_widthunit,
	 fgt_reftype,   --20
	 fgt_refnum,
	 fgt_quantity,
	 fgt_rate,
	 fgt_charge,
	 fgt_rateunit,
	 cht_itemcode,
	 cht_basisunit,
	 fgt_unit,
	 skip_trigger,
	 tare_weight,   --30
	 tare_weightunit,
	 fgt_pallets_in,
	 fgt_pallets_out,
	 fgt_carryins1,
	 fgt_carryins2,
	 fgt_stackable,
	 fgt_ratingquantity,
	 fgt_ratingunit,
	 fgt_quantity_type,
	 fgt_ordered_count,    --40
	 fgt_ordered_weight,
	 tar_number,
	 tar_tariffnumber,
	 tar_tariffitem,
	 fgt_charge_type, 
	 fgt_rate_type,  
	 fgt_loadingmeters, 
	 fgt_loadingmetersunit, 
	 fgt_additionl_description, 
	 fgt_specific_flashpoint,   --50
	 fgt_specific_flashpoint_unit, 
	 fgt_ordered_volume, 
	 fgt_ordered_loadingmeters, 
 	 fgt_pallet_type,
            -- PTS 38773 Trimac added new columns to cc fcn. 
	fgt_dispatched_quantity,		
	fgt_dispatched_unit,				
	fgt_actual_quantity,				
	fgt_actual_unit,					
	fgt_billable_quantity,			
	fgt_billable_unit,   --60
    tank_loc ) --41629  
	SELECT	f.fgt_number,
			f.cmd_code,
			CASE @copyquantities WHEN 'Y' THEN f.fgt_weight else 0 END fgt_weight,
			f.fgt_weightunit,
			f.fgt_description,
			f.stp_number,
			CASE @copyquantities WHEN 'Y' THEN f.fgt_count else 0 END fgt_count,
			f.fgt_countunit,
			CASE @copyquantities WHEN 'Y' THEN f.fgt_volume else 0 END fgt_volume,
			f.fgt_volumeunit,   --10
			f.fgt_lowtemp,
			f.fgt_hitemp,
			f.fgt_sequence,
			f.fgt_length,	
			f.fgt_lengthunit,
			f.fgt_height,
			f.fgt_heightunit,
			f.fgt_width,
			f.fgt_widthunit,
			-- TGRIFFIT - PTS #38785   
			--CASE @copyotherrefs WHEN 'Y' THEN fgt_reftype ELSE 'UNK' END fgt_reftype,
			--CASE @copyotherrefs WHEN 'Y' THEN f.fgt_refnum ELSE NULL END fgt_refnum,
            CASE @copyotherrefs 
                 WHEN 'Y' THEN fgt_reftype 
                 ELSE 
                    CASE @user_ref_flag    WHEN 'Y' THEN @copyreftype ELSE 'UNK' END 
                 END fgt_reftype,  --20
            CASE @copyotherrefs WHEN 'Y' THEN f.fgt_refnum ELSE 
                CASE @user_ref_flag WHEN 'Y' THEN @copyrefnum ELSE NULL END END fgt_refnum,
            -- END TGRIFFIT - PTS #38785 
			CASE @copylinehaul WHEN 'Y' then f.fgt_quantity ELSE 0.0 END fgt_quantity,
			CASE @copylinehaul WHEN 'Y' then f.fgt_rate ELSE Convert(MONEY,0.00) END fgt_rate,
			CASE @copylinehaul WHEN 'Y' then f.fgt_charge ELSE Convert(MONEY,0.00) END fgt_charge,
			f.fgt_rateunit,
			CASE @copylinehaul WHEN 'Y' then f.cht_itemcode ELSE 'UNK' END cht_itemcode,
			f.cht_basisunit,
			CASE @copylinehaul WHEN 'Y' then f.fgt_unit ELSE 'UNK' END fgt_unit,
			f.skip_trigger,
			f.tare_weight,   --30
			f.tare_weightunit,
			isnull(f.fgt_pallets_in,0),
			isnull(f.fgt_pallets_out,0),
			f.fgt_carryins1,
			f.fgt_carryins2,
			f.fgt_stackable,
			case @copylinehaul WHEN 'Y' then f.fgt_ratingquantity ELSE NULL END fgt_ratingquantity,
			case @copylinehaul WHEN 'Y' then f.fgt_ratingunit ELSE NULL END fgt_ratingunit,
			case @copylinehaul WHEN 'Y' then f.fgt_quantity_type ELSE 0 END fgt_quantity_type,
			f.fgt_ordered_count,    --40
			f.fgt_ordered_weight,
			CASE @copylinehaul WHEN 'Y' then f.tar_number ELSE 0 END tar_number,
			CASE @copylinehaul WHEN 'Y' then f.tar_tariffnumber ELSE NULL END tar_tariffnumber,
			CASE @copylinehaul WHEN 'Y' then f.tar_tariffitem ELSE NULL END tar_tariffitem,
			case @copylinehaul WHEN 'Y' then f.fgt_charge_type ELSE 0 END fgt_charge_type, 
			CASE @copylinehaul WHEN 'Y' then f.fgt_rate_type ELSE 0 END fgt_rate_type,  
			f.fgt_loadingmeters, 
			CASE @copyquantities WHEN 'Y' THEN f.fgt_loadingmeters else 0 END fgt_loadingmetersunit, 
			f.fgt_additionl_description, 
			f.fgt_specific_flashpoint,    --50
			f.fgt_specific_flashpoint_unit, 
			f.fgt_ordered_volume, 
			f.fgt_ordered_loadingmeters, 
			f.fgt_pallet_type,
            -- PTS 38773 Trimac added new columns to cc fcn. 
			f.fgt_dispatched_quantity,		
			f.fgt_dispatched_unit,				
			f.fgt_actual_quantity,				
			f.fgt_actual_unit,					
			f.fgt_billable_quantity,			
			f.fgt_billable_unit,   --60
            f.tank_loc --41629   
	  FROM	#stops s
				INNER JOIN freightdetail f ON s.stp_number = f.stp_number

INSERT INTO #fgt_xref
	(fgt_number)
	SELECT	f.fgt_number
	  FROM	#stops s
				INNER JOIN #freightdetail f ON s.stp_number = f.stp_number
	ORDER BY s.stp_mfh_sequence, f.fgt_sequence

IF @CopyNotes  = 'Y' AND @not_count > 0
BEGIN
	INSERT INTO #notes_xref
		(not_number)
		SELECT	not_number
		  FROM	notes
		 WHERE	ntb_table = 'orderheader' AND
-- PTS 31439 -- BL (start)
--				nre_tablekey = @orig_ord_hdrnumber AND
			nre_tablekey = CONVERT(VARCHAR(18), @orig_ord_hdrnumber) AND
-- PTS 31439 -- BL (end)
				ISNULL(autonote, 'N') <> 'Y'
END

IF @copyotherrefs = 'Y'
BEGIN
	INSERT INTO #referencenumber
		(ref_tablekey, 
		 ref_type,
		 ref_number,
		 ref_typedesc,
		 ref_sequence,
		 ord_hdrnumber,
		 ref_table,
		 ref_sid,
		 ref_pickup, 
		 last_updateby,
		 last_updatedate )
		SELECT	r.ref_tablekey,
				r.ref_type,
				r.ref_number,
				r.ref_typedesc,
				r.ref_sequence,
				r.ord_hdrnumber,
				r.ref_table,
				r.ref_sid,
				r.ref_pickup,
				r.last_updateby,
				r.last_updatedate
		  FROM	#stops s
					INNER JOIN referencenumber r ON s.stp_number = r.ref_tablekey AND r.ref_table = 'stops'

	INSERT INTO #referencenumber
		(ref_tablekey, 
		 ref_type,
		 ref_number,
		 ref_typedesc,
		 ref_sequence,
		 ord_hdrnumber,
		 ref_table,
		 ref_sid,
		 ref_pickup, 
		 last_updateby,
		 last_updatedate)
		SELECT	r.ref_tablekey,
				r.ref_type,
				r.ref_number,
				r.ref_typedesc,
				r.ref_sequence,
				r.ord_hdrnumber,
				r.ref_table,
				r.ref_sid,
				r.ref_pickup,
				r.last_updateby,
				r.last_updatedate
		  FROM	#freightdetail f
					INNER JOIN referencenumber r ON f.fgt_number = r.ref_tablekey AND r.ref_table = 'freightdetail'
END

If @copyordrefs = 'Y'
BEGIN
	INSERT INTO #referencenumber
		(ref_tablekey, 
		 ref_type,
		 ref_number,
		 ref_typedesc,
		 ref_sequence,
		 ord_hdrnumber,
		 ref_table,
		 ref_sid,
		 ref_pickup, 
		 last_updateby,
		 last_updatedate)
		SELECT	r.ref_tablekey,
				r.ref_type,
				r.ref_number,
				r.ref_typedesc,
				r.ref_sequence,
				r.ord_hdrnumber,
				r.ref_table,
				r.ref_sid,
				r.ref_pickup,
				r.last_updateby,
				r.last_updatedate
		  FROM	#orderheader oh
					INNER JOIN referencenumber r ON oh.ord_hdrnumber = r.ref_tablekey and r.ref_table = 'orderheader'
		--34195 JJF 8/21/06 - selective exclude reftype 
		WHERE r.ref_type <> ISNULL(@CopyRefNumberExcludeRefType, '')
		--END 34195 JJF 8/21/06 - selective exclude reftype 
		--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value
		ORDER BY r.ref_sequence
		--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value

	--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value
	IF @CopyRefNumReplaceRefType IS NOT NULL BEGIN
		UPDATE #referencenumber
		SET 	ref_type = @CopyRefNumReplaceRefTypeWith,
			ref_number = ''
		WHERE 	ref_type = @CopyRefNumReplaceRefType
			AND ref_table = 'orderheader'
	END 
	--34525 JJF 9/15/06 - overwrite or replace reftype with another and blank out the value

END

-- TGRIFFIT - PTS #38785  
If @user_ref_flag = 'Y'
BEGIN
    INSERT INTO #referencenumber
		(ref_tablekey, 
		 ref_type,
		 ref_number,
		 ref_typedesc,
		 ref_sequence,
		 ord_hdrnumber,
		 ref_table,
		 ref_sid,
		 ref_pickup)
    SELECT fgt_number,
            @copyreftype,
		    @copyrefnum,
            NULL,
            1,
            NULL,
            'freightdetail',
            NULL,
            NULL
    FROM #freightdetail
        
    INSERT INTO #referencenumber
		(ref_tablekey, 
		 ref_type,
		 ref_number,
		 ref_typedesc,
		 ref_sequence,
		 ord_hdrnumber,
		 ref_table,
		 ref_sid,
		 ref_pickup)
    SELECT ord_hdrnumber,
            @copyreftype,
		    @copyrefnum,
            NULL,
            1,
            ord_hdrnumber,
            'orderheader',
            NULL,
            NULL
    FROM #orderheader
    
END
-- END TGRIFFIT - PTS #38785 

If @copyAccessorials = 'Y' AND @ivd_count > 0
BEGIN
	INSERT INTO #ivd_xref
		(ivd_number)
		SELECT	i.ivd_number
		  FROM	invoicedetail i
					INNER JOIN chargetype c ON i.cht_itemcode = c.cht_itemcode
					LEFT OUTER JOIN invoiceheader ih ON i.ivh_hdrnumber = ih.ivh_hdrnumber
	 	 WHERE	i.ord_hdrnumber = @orig_ord_hdrnumber AND
				(ih.ivh_definition = 'LH' OR ih.ivh_definition IS NULL) AND
				c.cht_primary = 'N' AND
				i.ivd_number > 0
		
END

IF @copypaydetails = 'Y' AND @pyd_count > 0
BEGIN
	INSERT INTO #pyd_xref
		(pyd_number)
		SELECT	pyd_number
		  FROM	paydetail
		 WHERE	ord_hdrnumber = @orig_ord_hdrnumber AND
				pyd_number > 0
END

SET @loop_counter = 1

WHILE @loop_counter <= @copies
BEGIN
	BEGIN TRAN COPYLOOP
	
	SELECT	@minstp = MIN(stp_mfh_sequence) 
	  FROM	#stops
	 WHERE	stp_mfh_sequence > 0

	IF @minstp IS NOT NULL
	BEGIN
		SELECT	@diffmins = CASE @copydates 
								WHEN 'Y' THEN 0 
								ELSE CASE @loop_counter 
										WHEN 1 THEN DateDiff(mi, stp_arrivaldate, @startdate) 
										ELSE @intervalminutes 
									 END 
							END
		  FROM	#stops 
		 WHERE	stp_mfh_sequence = @minstp
	END
	ELSE
	BEGIN
		SELECT	@diffmins = CASE @loop_counter
								WHEN 1 THEN 0
								ELSE @intervalminutes 
							END
	END

	UPDATE	#stops
	   SET	stp_arrivaldate = 
				CASE @ordstatus
					WHEN 'CMP' THEN DATEADD(mi, @diffmins, stp_arrivaldate)
					ELSE CASE
							WHEN @daysperweek = 6 AND DATENAME(dw, DATEADD(mi, @diffmins, stp_arrivaldate)) = 'Sunday' THEN DATEADD(mi, @diffmins + 1440, stp_arrivaldate) 
							WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_arrivaldate)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_arrivaldate) 
							WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_arrivaldate)) = 'Saturday' THEN  DATEADD(mi, @diffmins + 2880, stp_arrivaldate) 
							ELSE DATEADD(mi, @diffmins, stp_arrivaldate)	
						 END
				END,
				stp_origschdt = 
				CASE @ordstatus
					WHEN 'CMP' THEN DATEADD(mi, @diffmins, stp_arrivaldate)
					ELSE CASE
							WHEN @daysperweek = 6 AND DATENAME(dw, DATEADD(mi, @diffmins, stp_arrivaldate)) = 'Sunday' THEN DATEADD(mi, @diffmins + 1440, stp_arrivaldate) 
							WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_arrivaldate)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_arrivaldate) 
							WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_arrivaldate)) = 'Saturday' THEN  DATEADD(mi, @diffmins + 2880, stp_arrivaldate) 
							ELSE DATEADD(mi, @diffmins, stp_arrivaldate)	
						 END
				END,
				stp_departuredate = 
				CASE @ordstatus 
					WHEN 'CMP' THEN DATEADD(mi, @diffmins, stp_departuredate)
				 	ELSE CASE 
							WHEN @daysperweek = 6 And DATENAME(dw, DATEADD(mi, @diffmins, stp_departuredate)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_departuredate) 
							WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_departuredate)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_departuredate) 
							WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_departuredate)) = 'Saturday' THEN  DATEADD(mi, @diffmins + 2880, stp_departuredate) 
							ELSE DATEADD(mi, @diffmins, stp_departuredate)	
				      	 END
				END, 
			stp_schdtearliest = 
				CASE stp_schdtearliest
					WHEN '19500101' THEN '19500101'
					WHEN '20491231 23:59' THEN '20491231 23:59'
					WHEN '20491231 23:59:59' THEN '20491231 23:59:59'
					ELSE CASE @ordstatus
							WHEN 'CMP' THEN DATEADD(mi, @diffmins, stp_schdtearliest)
						 	ELSE CASE 
									WHEN @daysperweek = 6 And DATENAME(dw,DATEADD(mi,@diffmins,stp_schdtearliest)) = 'Sunday' THEN  DATEADD(mi,@diffmins + 1440,stp_schdtearliest) 
									WHEN @daysperweek = 5 And DATENAME(dw,DATEADD(mi,@diffmins,stp_schdtearliest)) = 'Sunday' THEN  DATEADD(mi,@diffmins + 1440,stp_schdtearliest) 
									WHEN @daysperweek = 5 And DATENAME(dw,DATEADD(mi,@diffmins,stp_schdtearliest)) = 'Saturday' THEN  DATEADD(mi,@diffmins + 2880,stp_schdtearliest) 
									ELSE DATEADD(mi,@diffmins,stp_schdtearliest)	
								 END
					     END
				END, 
			stp_schdtlatest = 
				CASE stp_schdtlatest
					WHEN '19500101' THEN '19500101'
					WHEN '20491231 23:59' THEN '20491231 23:59'
					WHEN '20491231 23:59:59' THEN '20491231 23:59:59'
					ELSE CASE @ordstatus
							WHEN 'CMP' THEN DATEADD(mi, @diffmins, stp_schdtlatest)
							ELSE CASE  
									WHEN @daysperweek = 6 And DATENAME(dw, DATEADD(mi, @diffmins, stp_schdtlatest)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_schdtlatest) 
									WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_schdtlatest)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_schdtlatest) 
									WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_schdtlatest)) = 'Saturday' THEN  DATEADD(mi, @diffmins + 2880, stp_schdtlatest) 
									ELSE DATEADD(mi, @diffmins, stp_schdtlatest)	
								 END
					     END
				END,
	        stp_eta =   
				CASE @ordstatus
					WHEN 'CMP' THEN DATEADD(mi,@diffmins,stp_eta)
					ELSE CASE 
							WHEN @daysperweek = 6 And DATENAME(dw,DATEADD(mi, @diffmins, stp_eta)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_eta)   
							WHEN @daysperweek = 5 And DATENAME(dw,DATEADD(mi, @diffmins, stp_eta)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_eta)   
							WHEN @daysperweek = 5 And DATENAME(dw,DATEADD(mi, @diffmins, stp_eta)) = 'Saturday' THEN  DATEADD(mi, @diffmins + 2880, stp_eta)   
							ELSE DATEADD(mi, @diffmins, stp_eta)   
						 END
				END,
			stp_etd =
				CASE @ordstatus
					WHEN 'CMP' THEN DATEADD(mi,@diffmins,stp_etd)
					ELSE CASE  
							WHEN @daysperweek = 6 And DATENAME(dw, DATEADD(mi, @diffmins, stp_etd)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_etd)   
							WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_etd)) = 'Sunday' THEN  DATEADD(mi, @diffmins + 1440, stp_etd)   
							WHEN @daysperweek = 5 And DATENAME(dw, DATEADD(mi, @diffmins, stp_etd)) = 'Saturday' THEN  DATEADD(mi, @diffmins + 2880, stp_etd)   
							ELSE DATEADD(mi, @diffmins, stp_etd)   
						 END
				END

	UPDATE	#stp_xref
	   SET	new_stp_number = (@newstpnbr_start + (@stp_count * (@loop_counter - 1)) + (stp_id - 1))

	UPDATE	#evt_xref
	   SET	new_evt_number = (@newevtnbr_start + (@evt_count * (@loop_counter - 1)) + (evt_id - 1))

	UPDATE 	#fgt_xref
	   SET	new_fgt_number = (@newfgtnbr_start + (@fgt_count * (@loop_counter - 1)) + (fgt_id - 1))

	IF @CopyNotes  = 'Y' AND @not_count > 0
	BEGIN
		UPDATE 	#notes_xref
		   SET	new_not_number = (@newnotnbr_start + (@not_count * (@loop_counter - 1)) + (not_id - 1))
	END

	IF @copyAccessorials = 'Y' AND @ivd_count > 0
	BEGIN
		UPDATE 	#ivd_xref
		   SET	new_ivd_number = (@newivdnbr_start + (@ivd_count * (@loop_counter - 1)) + (ivd_id - 1))
	END

	IF @copypaydetails = 'Y' AND @pyd_count > 0
	BEGIN
		UPDATE 	#pyd_xref
		   SET	new_pyd_number = (@newpydnbr_start + (@pyd_count * (@loop_counter - 1)) + (pyd_id - 1))
	END

	IF @copyordrefs = 'Y'
	BEGIN
		--34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
		SELECT @ref_sequence = 1
		--END 34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying

		SELECT	@min_id = MIN(ref_id)
		  FROM	#referencenumber
		 WHERE	ref_table = 'orderheader'

		WHILE ISNULL(@min_id, 0) > 0 
		BEGIN
			INSERT INTO referencenumber 
				(ref_tablekey,
				 ref_type,
				 ref_number,
				 ref_typedesc,
				 ref_sequence,
				 ord_hdrnumber,
				 ref_table,
				 ref_sid,
				 ref_pickup, 
			     last_updateby,
			     last_updatedate)
				SELECT	ox.new_ord_hdrnumber,
						r.ref_type,
						r.ref_number,
						r.ref_typedesc,
						--34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
						--r.ref_sequence,
						@ref_sequence,
						--END 34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
						ox.new_ord_hdrnumber,
						r.ref_table,
						r.ref_sid,
						r.ref_pickup,
						r.last_updateby,
						r.last_updatedate
				  FROM	#referencenumber r
							INNER JOIN #orderheader_xref ox ON r.ref_tablekey = ox.ord_hdrnumber AND r.ref_table = 'orderheader'
				 WHERE	ox.copy_number = @loop_counter AND
						r.ref_id = @min_id

			--34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
			IF @ref_sequence = 1 BEGIN
				SELECT  @FirstRefNum = r.ref_number,
					@FirstRefType = r.ref_type 
				FROM	#referencenumber r
				WHERE r.ref_id = @min_id
			END

			SELECT @ref_sequence = @ref_sequence + 1
			--END 34195 JJF 8/21/06 Don't copy if reftype to be excluded from copying
			
			SELECT	@min_id = MIN(ref_id)
			  FROM	#referencenumber
			 WHERE	ref_table = 'orderheader' AND
					ref_id > @min_id
		END

		IF @@ERROR <> 0 GOTO ERROR_EXIT
		--34195 JJF 8/21/06 If we excluded a reftype, make sure the orderheader has the first one.  The first one may have been an excluded reftype
		--34525 JJF 9/15/06 
		--IF LEN(@CopyRefNumberExcludeRefType) > 0 BEGIN
		IF LEN(ISNULL(@CopyRefNumberExcludeRefType, '')) > 0 OR LEN(ISNULL(@CopyRefNumReplaceRefType, '')) > 0 BEGIN
		--END 34525 JJF 9/15/06 
			UPDATE #orderheader
			SET 	ord_refnum = @FirstRefNum,
				ord_reftype =  @FirstRefType

		END 
		--END 34195 JJF 8/21/06 If we excluded a reftype, make sure the orderheader has the first one.  The first one may have been an excluded reftype

	END

	IF @copyotherrefs = 'Y'
	BEGIN
		SELECT	@min_id = MIN(ref_id)
		  FROM	#referencenumber
		 WHERE	ref_table = 'stops'

		WHILE ISNULL(@min_id, 0) > 0 
		BEGIN
			INSERT INTO referencenumber 
				(ref_tablekey,
				 ref_type,
				 ref_number,
				 ref_typedesc,
				 ref_sequence,
				 ord_hdrnumber,
				 ref_table,
				 ref_sid,
				 ref_pickup, 
			     last_updateby,
			     last_updatedate)
				SELECT	sx.new_stp_number,
						r.ref_type,
						r.ref_number,
						r.ref_typedesc,
						r.ref_sequence,
						ox.new_ord_hdrnumber,
						r.ref_table,
						r.ref_sid,
						r.ref_pickup, 
			            r.last_updateby,
			            r.last_updatedate
				  FROM	#referencenumber r
							INNER JOIN #stp_xref sx ON r.ref_tablekey = sx.stp_number AND r.ref_table = 'stops'
							INNER JOIN #stops s ON s.stp_number = sx.stp_number
							INNER JOIN #orderheader_xref ox ON s.ord_hdrnumber = ox.ord_hdrnumber
				 WHERE	ox.copy_number = @loop_counter AND
						r.ref_id = @min_id
			
			IF @@ERROR <> 0 GOTO ERROR_EXIT

			SELECT	@min_id = MIN(ref_id)
			  FROM	#referencenumber
			 WHERE	ref_table = 'stops' AND
					ref_id > @min_id
		END

		SELECT	@min_id = MIN(ref_id)
		  FROM	#referencenumber
		 WHERE	ref_table = 'freightdetail'

		WHILE ISNULL(@min_id, 0) > 0 
		BEGIN
			INSERT INTO referencenumber 
				(ref_tablekey,
				 ref_type,
				 ref_number,
				 ref_typedesc,
				 ref_sequence,
				 ord_hdrnumber,
				 ref_table,
				 ref_sid,
				 ref_pickup, 
			     last_updateby,
			     last_updatedate)
				SELECT	fx.new_fgt_number,
						r.ref_type,
						r.ref_number,
						r.ref_typedesc,
						r.ref_sequence,
						ox.new_ord_hdrnumber,
						r.ref_table,
						r.ref_sid,
						r.ref_pickup, 
			            r.last_updateby,
			            r.last_updatedate
				  FROM	#referencenumber r
							INNER JOIN #fgt_xref fx ON r.ref_tablekey = fx.fgt_number AND r.ref_table = 'freightdetail'
							INNER JOIN #freightdetail f ON f.fgt_number = fx.fgt_number
							INNER JOIN #stops s ON s.stp_number = f.stp_number
							INNER JOIN #orderheader_xref ox ON s.ord_hdrnumber = ox.ord_hdrnumber
				 WHERE	ox.copy_number = @loop_counter AND
						r.ref_id = @min_id

			IF @@ERROR <> 0 GOTO ERROR_EXIT
			
			SELECT	@min_id = MIN(ref_id)
			  FROM	#referencenumber
			 WHERE	ref_table = 'freightdetail' AND
					ref_id > @min_id
		END
	END

-- TGRIFFIT - PTS #38785  
    IF @user_ref_flag = 'Y'
        BEGIN
            SELECT	@min_id = MIN(ref_id)
              FROM	#referencenumber
             WHERE	ref_table = 'orderheader'
    
            WHILE ISNULL(@min_id, 0) > 0 
            BEGIN
                INSERT INTO referencenumber 
                    (ref_tablekey,
                     ref_type,
                     ref_number,
                     ref_typedesc,
                     ref_sequence,
                     ord_hdrnumber,
                     ref_table,
                     ref_sid,
                     ref_pickup, 
                     last_updateby,
                     last_updatedate)
                    SELECT	ox.new_ord_hdrnumber,
                            r.ref_type,
                            r.ref_number,
                            r.ref_typedesc,
                            r.ref_sequence,
                            ox.new_ord_hdrnumber,
                            r.ref_table,
                            r.ref_sid,
                            r.ref_pickup,
                            r.last_updateby,
                            r.last_updatedate
                      FROM	#referencenumber r
                                INNER JOIN #orderheader_xref ox ON r.ref_tablekey = ox.ord_hdrnumber 
                                AND r.ref_table = 'orderheader'
                     WHERE	ox.copy_number = @loop_counter AND
                            r.ref_id = @min_id
                            
                IF @@ERROR <> 0 GOTO ERROR_EXIT
                    
                SELECT	@min_id = MIN(ref_id)
                  FROM	#referencenumber
                 WHERE	ref_table = 'orderheader' AND
                        ref_id > @min_id
            END
  
            SELECT	@min_id = MIN(ref_id)
              FROM	#referencenumber
             WHERE	ref_table = 'freightdetail'
    
            WHILE ISNULL(@min_id, 0) > 0 
            BEGIN     
                INSERT INTO referencenumber 
                        (ref_tablekey,
                         ref_type,
                         ref_number,
                         ref_typedesc,
                         ref_sequence,
                         ord_hdrnumber,
                         ref_table,
                         ref_sid,
                         ref_pickup, 
                         last_updateby,
                         last_updatedate)
                        SELECT	fx.new_fgt_number,
                                r.ref_type,
                                r.ref_number,
                                r.ref_typedesc,
                                r.ref_sequence,
                                ox.new_ord_hdrnumber,
                                r.ref_table,
                                r.ref_sid,
                                r.ref_pickup, 
                                r.last_updateby,
                                r.last_updatedate
                        FROM	#referencenumber r
                                INNER JOIN #fgt_xref fx ON r.ref_tablekey = fx.fgt_number 
                                AND r.ref_table =  'freightdetail'
                                INNER JOIN #freightdetail f ON f.fgt_number = fx.fgt_number
                                INNER JOIN #stops s ON s.stp_number = f.stp_number
                                INNER JOIN #orderheader_xref ox ON s.ord_hdrnumber = ox.ord_hdrnumber
                    WHERE	ox.copy_number = @loop_counter AND
                            r.ref_id = @min_id
                            
                IF @@ERROR <> 0 GOTO ERROR_EXIT
                
                SELECT	@min_id = MIN(ref_id)
                  FROM	#referencenumber
                 WHERE	ref_table = 'freightdetail' AND
                        ref_id > @min_id
            END   
        END
    -- END TGRIFFIT - PTS #38785 

	SELECT	@min_id = MIN(fgt_id)
	  FROM	#fgt_xref

	WHILE ISNULL(@min_id, 0) > 0 
	BEGIN
		INSERT INTO freightdetail 
			(fgt_number,
			 cmd_code,
			 fgt_weight,
			 fgt_weightunit,
			 fgt_description,
			 stp_number,
			 fgt_count,
			 fgt_countunit,
			 fgt_volume,
			 fgt_volumeunit,
			 fgt_lowtemp,
			 fgt_hitemp,
			 fgt_sequence,
			 fgt_length,
			 fgt_lengthunit,
			 fgt_height,
			 fgt_heightunit,
			 fgt_width,
			 fgt_widthunit,
			 fgt_reftype,
			 fgt_refnum,
			 fgt_quantity,
			 fgt_rate,
			 fgt_charge,
			 fgt_rateunit,
			 cht_itemcode,
			 cht_basisunit,
			 fgt_unit,
			 skip_trigger,
			 tare_weight,
			 tare_weightunit,
			 fgt_pallets_in,
			 fgt_pallets_out,
			 fgt_carryins1,
			 fgt_carryins2,
			 fgt_stackable,
			 fgt_ratingquantity,
			 fgt_ratingunit,
			 fgt_quantity_type,
			 fgt_ordered_count,
			 fgt_ordered_weight,
			 tar_number,
			 tar_tariffnumber,
			 tar_tariffitem,
			 fgt_charge_type, 
			 fgt_rate_type,
			 fgt_loadingmeters, 
			 fgt_loadingmetersunit, 
			 fgt_additionl_description, 
			 fgt_specific_flashpoint,
			 fgt_specific_flashpoint_unit, 
			 fgt_ordered_volume, 
			 fgt_ordered_loadingmeters, 
			 fgt_pallet_type,
			-- PTS 38773 Trimac added new columns to cc fcn.
					fgt_dispatched_quantity,			
					fgt_dispatched_unit,				
					fgt_actual_quantity,				
					fgt_actual_unit,					
					fgt_billable_quantity,			
					fgt_billable_unit,
             tank_loc	)  --41629
			SELECT	fx.new_fgt_number,
					CASE @cmd_code
						WHEN 'UNKNOWN' THEN cmd_code
						ELSE @cmd_code
					END,
					fgt_weight,
					fgt_weightunit,
					fgt_description,
					sx.new_stp_number,
					fgt_count,
					fgt_countunit,
					fgt_volume,
					fgt_volumeunit,
					fgt_lowtemp,
					fgt_hitemp,
					fgt_sequence,
					fgt_length,
					fgt_lengthunit,
					fgt_height,
					fgt_heightunit,
					fgt_width,
					fgt_widthunit,
					fgt_reftype,
					fgt_refnum,
					fgt_quantity,
					fgt_rate,
					fgt_charge,
					fgt_rateunit,
					cht_itemcode,
					cht_basisunit,
					fgt_unit,
					1 skip_trigger,
					tare_weight,
					tare_weightunit,
					fgt_pallets_in,
					fgt_pallets_out,
					fgt_carryins1,
					fgt_carryins2,
					fgt_stackable,
					fgt_ratingquantity,
					fgt_ratingunit,
					fgt_quantity_type,
					fgt_ordered_count,
					fgt_ordered_weight,
					tar_number,
					tar_tariffnumber,
					tar_tariffitem,
					fgt_charge_type, 
					fgt_rate_type,
					fgt_loadingmeters, 
					fgt_loadingmetersunit, 
					fgt_additionl_description, 
					fgt_specific_flashpoint,
					fgt_specific_flashpoint_unit, 
					fgt_ordered_volume, 
					fgt_ordered_loadingmeters, 
					fgt_pallet_type,
					-- PTS 38773 Trimac added new columns to cc fcn.  
					-- PTS 43236 TGRIFFIT - removed CASE statements - now direct copy
					fgt_dispatched_quantity,		
                    fgt_dispatched_unit,				
                    fgt_actual_quantity,				
                    fgt_actual_unit,					
                    fgt_billable_quantity,			
                    fgt_billable_unit,
                    -- END PTS 43236 TGRIFFIT  					
					-- PTS 38773 Trimac END 
                    tank_loc --41629
			  FROM	#freightdetail f
						INNER JOIN #fgt_xref fx ON f.fgt_number = fx.fgt_number
						INNER JOIN #stp_xref sx ON f.stp_number = sx.stp_number
			 WHERE	fx.fgt_id = @min_id
		IF @@ERROR <> 0 GOTO ERROR_EXIT

		SELECT	@min_id = MIN(fgt_id)
		  FROM	#fgt_xref
		 WHERE	fgt_id > @min_id		
	END

	SELECT	@min_id = MIN(evt_id)
	  FROM	#evt_xref

	WHILE ISNULL(@min_id, 0) > 0 
	BEGIN
		INSERT INTO event 
			(ord_hdrnumber,
			 stp_number,
			 evt_eventcode,
			 evt_number,
			 evt_startdate,
			 evt_enddate,
			 evt_status,
			 evt_earlydate,
			 evt_latedate,
			 evt_weight,
			 evt_weightunit,
			 fgt_number,
			 evt_count,
			 evt_countunit,
			 evt_volume,
			 evt_volumeunit,
			 evt_pu_dr,
			 evt_sequence,
			 evt_contact,
			 evt_driver1,
			 evt_driver2,
			 evt_tractor,
			 evt_trailer1,
			 evt_trailer2,
			 evt_chassis,
			 evt_dolly,
			 evt_carrier,
			 evt_refype,
			 evt_refnum,
			 evt_reason,
			 evt_enteredby,
			 evt_hubmiles,
			 skip_trigger,
			 evt_mov_number,
			 evt_departure_status)
			SELECT	ISNULL(ox.new_ord_hdrnumber,0),
					sx.new_stp_number,
					evt_eventcode,
					ex.new_evt_number,
					s.stp_arrivaldate,
					s.stp_departuredate,
					s.stp_status,
					s.stp_schdtearliest,
					s.stp_schdtlatest,
					evt_weight,
					evt_weightunit,
					fgt_number,
					evt_count,
					evt_countunit,
					evt_volume,
					evt_volumeunit,
					evt_pu_dr,
					evt_sequence,
					evt_contact,
					evt_driver1,
					evt_driver2,
					evt_tractor,
					evt_trailer1,
					evt_trailer2,
					evt_chassis,
					evt_dolly,
					evt_carrier,
					evt_refype,
					evt_refnum,
					evt_reason,
					evt_enteredby,
					evt_hubmiles,
					1 skip_trigger,
					ox.new_mov_number,
					s.stp_status
			  FROM	#event e
						INNER JOIN #evt_xref ex ON e.evt_number = ex.evt_number
						INNER JOIN #stp_xref sx ON e.stp_number = sx.stp_number
						INNER JOIN #stops s ON s.stp_number = sx.stp_number
						INNER JOIN #orderheader_xref ox ON s.ord_hdrnumber = ox.ord_hdrnumber
			 WHERE	ex.evt_id = @min_id AND
					ox.copy_number = @loop_counter

		IF @@ERROR <> 0 GOTO ERROR_EXIT

		SELECT	@min_id = MIN(evt_id)
		  FROM	#evt_xref
		 WHERE	evt_id > @min_id
	END

	SELECT	@ordstart = MIN(stp_arrivaldate),
			@ordcomplete = MAX(stp_arrivaldate)
	  FROM	#stops

	SELECT	@originearliest = stp_schdtearliest,
			@originlatest = stp_schdtlatest,
			@stp_number	= stp_number
	  FROM	#stops
	 WHERE	stp_sequence = (SELECT MIN(stp_sequence) FROM #stops WHERE stp_type = 'PUP')

	SELECT	@destearliest = stp_schdtearliest,
			@destlatest = stp_schdtlatest
	  FROM	#stops
	 WHERE	stp_sequence = (SELECT MAX(stp_sequence) FROM #stops WHERE stp_type = 'DRP')

	SELECT	@min_id = MIN(evt_id)
	  FROM	#evt_xref

	WHILE ISNULL(@min_id, 0) > 0 
	BEGIN
		-- PTS 35479 Use GI setting RollBackCloneOrder to copy rows
		If Upper(@RollBackCloneOrder) = 'Y'
		Begin

			INSERT INTO stops 
				(ord_hdrnumber,
				 stp_number,
				 cmp_id,
				 stp_region1,
				 stp_region2,
				 stp_region3,
				 stp_city,
				 stp_state,
				 stp_schdtearliest,
				 stp_origschdt,
				 stp_arrivaldate,
				 stp_departuredate,
				 stp_reasonlate,
				 stp_schdtlatest,
				 lgh_number,
				 mfh_number,
				 stp_type,
				 stp_paylegpt,
				 shp_hdrnumber,
				 stp_sequence,
				 stp_region4,
				 stp_lgh_sequence,
				 trl_id,
				 stp_mfh_sequence,
				 stp_event,
				 stp_mfh_position,
				 stp_lgh_position,
				 stp_mfh_status,
				 stp_lgh_status,
				 stp_ord_mileage,
				 stp_lgh_mileage,
				 stp_mfh_mileage,
				 mov_number,
				 stp_loadstatus,
				 stp_weight,
				 stp_weightunit,
				 cmd_code,
				 stp_description,
				 stp_count,
				 stp_countunit,
				 cmp_name,
				 stp_comment,
				 stp_status,
				 stp_reftype,
				 stp_refnum,
				 stp_reasonlate_depart,
				 stp_screenmode,
				 skip_trigger,
				 stp_volume,
				 stp_volumeunit,
				 stp_dispatched_sequence,
				 stp_arr_confirmed,
				 stp_dep_confirmed,
				 stp_type1,
				 stp_redeliver,
				 stp_osd,
				 stp_pudelpref,
				 stp_phonenumber,
				 stp_delayhours,
				 stp_ooa_mileage,
				 stp_zipcode,
				 stp_ooa_stop,
				 stp_address,
				 stp_transfer_stp,
				 stp_phonenumber2,
				 stp_address2,
				 stp_contact,
				 stp_custpickupdate,
				 stp_custdeliverydate,
				 stp_podname,
				 stp_cmp_close,
				 stp_activitystart_dt,
				 stp_activityend_dt,
				 stp_departure_status,
				 stp_eta,
				 stp_etd,
				 stp_transfer_type,
				 stp_trip_mileage,
				 stp_loadingmeters,
				 stp_loadingmetersunit, 
				 stp_country,
				 stp_cod_amount,
				 stp_cod_currency,
				 stp_ord_mileage_mtid,
				 stp_lgh_mileage_mtid,
				 stp_ooa_mileage_mtid,
				 stp_pallets_in,
				 stp_pallets_out)
			SELECT	CASE @psreset
						WHEN 'Y' THEN CASE ISNULL(ect.ect_purchase_service, 'N')
										WHEN 'Y' THEN 0
										ELSE ox.new_ord_hdrnumber
									  END
						ELSE ox.new_ord_hdrnumber
					END,
					sx.new_stp_number,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.cmp_id
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @shipper
								ELSE s.cmp_id
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region1
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region1
								ELSE s.stp_region1
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region2
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region2
								ELSE s.stp_region2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region3
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region3
								ELSE s.stp_region3
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_city
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_city
								ELSE s.stp_city
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_state
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_state
								ELSE s.stp_state
							 END
					END,
					s.stp_schdtearliest,
					s.stp_origschdt,
					s.stp_arrivaldate,
					s.stp_departuredate,
					s.stp_reasonlate,
					s.stp_schdtlatest,
					ox.new_lgh_number,
					s.mfh_number,
					s.stp_type,
					s.stp_paylegpt,
					s.shp_hdrnumber,
					s.stp_sequence,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region4
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region4
								ELSE s.stp_region4
							 END
					END,
					s.stp_lgh_sequence,
					trl_id,
					s.stp_mfh_sequence,
					s.stp_event,
					s.stp_mfh_position,
					s.stp_lgh_position,
					s.stp_mfh_status,
					s.stp_lgh_status,
					s.stp_ord_mileage,
	-- PTS 34082 -- BL (start)
	--				s.stp_lgh_mileage,
	--				s.stp_ord_mileage,-- PTS 35479 -- SLM comment out this line;Roll back changes from PTS 34082
	-- PTS 34082 -- BL (end)
					s.stp_lgh_mileage,-- PTS 35479 SLM Roll back changes from PTS 34082
					s.stp_mfh_mileage,
					ox.new_mov_number,
					s.stp_loadstatus,
					s.stp_weight,
					s.stp_weightunit,
					CASE @cmd_code
						WHEN 'UNKNOWN' THEN s.cmd_code
						ELSE @cmd_code
					END,
					CASE @cmd_code
						WHEN 'UNKNOWN' THEN s.stp_description
						ELSE @cmd_name
					END,
					s.stp_count,
					s.stp_countunit,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.cmp_name
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_name
								ELSE s.cmp_name
							 END
					END,
					s.stp_comment,
					s.stp_status,
					s.stp_reftype,
					s.stp_refnum,
					s.stp_reasonlate_depart,
					s.stp_screenmode,
					s.skip_trigger,
					s.stp_volume,
					s.stp_volumeunit,
					s.stp_dispatched_sequence,
					NULL stp_arr_confirmed,
					NULL stp_dep_confirmed,
					s.stp_type1,
					s.stp_redeliver,
					s.stp_osd,
					s.stp_pudelpref,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_phonenumber
						ELSE CASE
								 WHEN s.stp_number = @stp_number THEN @cmp_phone1
								 ELSE s.stp_phonenumber
							 END
					END,
					s.stp_delayhours,
					s.stp_ooa_mileage,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_zipcode
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_zip
								ELSE s.stp_zipcode
							 END
					END,
					s.stp_ooa_stop,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_address
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_address1
								ELSE s.stp_address
							 END
					END,
					s.stp_transfer_stp,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_phonenumber2
						ELSE CASE 
								 WHEN s.stp_number = @stp_number THEN @cmp_phone2
								 ELSE s.stp_phonenumber2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_address2
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_address2
								ELSE s.stp_address2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNWON' THEN s.stp_contact
						ELSE CASE
								 WHEN s.stp_number = @stp_number THEN @cmp_contact
								 ELSE s.stp_contact
							 END
					END,
					s.stp_custpickupdate,
					s.stp_custdeliverydate,
					s.stp_podname,
					s.stp_cmp_close,
					s.stp_activitystart_dt,
					s.stp_activityend_dt,
					s.stp_departure_status,
					s.stp_eta,
					s.stp_etd,
					s.stp_transfer_type,
	-- PTS 34082 -- BL (start)
	--				s.stp_trip_mileage,
	--				0,-- PTS 35479 -- SLM comment out this line;Roll back changes from PTS 34082
	-- PTS 34082 -- BL (end)
					s.stp_trip_mileage,-- PTS 35479 SLM Roll back changes from PTS 34082
					s.stp_loadingmeters,
					s.stp_loadingmetersunit, 
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_country
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_country
								ELSE s.stp_country
							 END
					END,
					s.stp_cod_amount,
					s.stp_cod_currency,
					stp_ord_mileage_mtid,
					stp_lgh_mileage_mtid,
					stp_ooa_mileage_mtid,
					stp_pallets_in,
					stp_pallets_out
			  FROM	#stops s
						INNER JOIN #stp_xref sx ON s.stp_number = sx.stp_number
						RIGHT OUTER JOIN #orderheader_xref ox ON s.ord_hdrnumber = ox.ord_hdrnumber
						INNER JOIN eventcodetable ect ON ect.abbr = s.stp_event
			 WHERE	sx.stp_id = @min_id AND
					ox.copy_number = @loop_counter
	
			IF @@ERROR <> 0 GOTO ERROR_EXIT
	
			SELECT	@min_id = MIN(stp_id)
			  FROM	#stp_xref
			 WHERE	stp_id > @min_id

		End
		ELSE
		Begin 
			SELECT @neword_hdrnumber = new_ord_hdrnumber,
                               @newmov_number = new_mov_number
                          FROM #orderheader_xref
                          WHERE	copy_number = @loop_counter

			-- Gi Setting RollBackCloneOrder is not being used
			INSERT INTO stops 
				(ord_hdrnumber,
				 stp_number,
				 cmp_id,
				 stp_region1,
				 stp_region2,
				 stp_region3,
				 stp_city,
				 stp_state,
				 stp_schdtearliest,
				 stp_origschdt,
				 stp_arrivaldate,
				 stp_departuredate,
				 stp_reasonlate,
				 stp_schdtlatest,
				 lgh_number,
				 mfh_number,
				 stp_type,
				 stp_paylegpt,
				 shp_hdrnumber,
				 stp_sequence,
				 stp_region4,
				 stp_lgh_sequence,
				 trl_id,
				 stp_mfh_sequence,
				 stp_event,
				 stp_mfh_position,
				 stp_lgh_position,
				 stp_mfh_status,
				 stp_lgh_status,
				 stp_ord_mileage,
				 stp_lgh_mileage,
				 stp_mfh_mileage,
				 mov_number,
				 stp_loadstatus,
				 stp_weight,
				 stp_weightunit,
				 cmd_code,
				 stp_description,
				 stp_count,
				 stp_countunit,
				 cmp_name,
				 stp_comment,
				 stp_status,
				 stp_reftype,
				 stp_refnum,
				 stp_reasonlate_depart,
				 stp_screenmode,
				 skip_trigger,
				 stp_volume,
				 stp_volumeunit,
				 stp_dispatched_sequence,
				 stp_arr_confirmed,
				 stp_dep_confirmed,
				 stp_type1,
				 stp_redeliver,
				 stp_osd,
				 stp_pudelpref,
				 stp_phonenumber,
				 stp_delayhours,
				 stp_ooa_mileage,
				 stp_zipcode,
				 stp_ooa_stop,
				 stp_address,
				 stp_transfer_stp,
				 stp_phonenumber2,
				 stp_address2,
				 stp_contact,
				 stp_custpickupdate,
				 stp_custdeliverydate,
				 stp_podname,
				 stp_cmp_close,
				 stp_activitystart_dt,
				 stp_activityend_dt,
				 stp_departure_status,
				 stp_eta,
				 stp_etd,
				 stp_transfer_type,
				 stp_trip_mileage,
				 stp_loadingmeters,
				 stp_loadingmetersunit, 
				 stp_country,
				 stp_cod_amount,
				 stp_cod_currency,
				 stp_ord_mileage_mtid,
				 stp_lgh_mileage_mtid,
				 stp_ooa_mileage_mtid,
				 stp_pallets_in,
				 stp_pallets_out)
			SELECT	CASE @psreset
						WHEN 'Y' THEN CASE ISNULL(ect.ect_purchase_service, 'N')
										WHEN 'Y' THEN 0
										ELSE @neword_hdrnumber
									  END
						ELSE @neword_hdrnumber
					END,
					sx.new_stp_number,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.cmp_id
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @shipper
								ELSE s.cmp_id
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region1
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region1
								ELSE s.stp_region1
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region2
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region2
								ELSE s.stp_region2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region3
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region3
								ELSE s.stp_region3
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_city
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_city
								ELSE s.stp_city
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_state
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_state
								ELSE s.stp_state
							 END
					END,
					s.stp_schdtearliest,
					s.stp_origschdt,
					s.stp_arrivaldate,
					s.stp_departuredate,
					s.stp_reasonlate,
					s.stp_schdtlatest,
					#lgh_xref.new_lgh_number,
					s.mfh_number,
					s.stp_type,
					s.stp_paylegpt,
					s.shp_hdrnumber,
					s.stp_sequence,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region4
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region4
								ELSE s.stp_region4
							 END
					END,
					s.stp_lgh_sequence,
					trl_id,
					s.stp_mfh_sequence,
					s.stp_event,
					s.stp_mfh_position,
					s.stp_lgh_position,
					s.stp_mfh_status,
					s.stp_lgh_status,
					s.stp_ord_mileage,
	-- PTS 34082 -- BL (start)
	--				s.stp_lgh_mileage,
					s.stp_ord_mileage,
	-- PTS 34082 -- BL (end)
					s.stp_mfh_mileage,
					@newmov_number,
					s.stp_loadstatus,
					s.stp_weight,
					s.stp_weightunit,
					CASE @cmd_code
						WHEN 'UNKNOWN' THEN s.cmd_code
						ELSE @cmd_code
					END,
					CASE @cmd_code
						WHEN 'UNKNOWN' THEN s.stp_description
						ELSE @cmd_name
					END,
					s.stp_count,
					s.stp_countunit,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.cmp_name
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_name
								ELSE s.cmp_name
							 END
					END,
					s.stp_comment,
					s.stp_status,
					s.stp_reftype,
					s.stp_refnum,
					s.stp_reasonlate_depart,
					s.stp_screenmode,
					s.skip_trigger,
					s.stp_volume,
					s.stp_volumeunit,
					s.stp_dispatched_sequence,
					NULL stp_arr_confirmed,
					NULL stp_dep_confirmed,
					s.stp_type1,
					s.stp_redeliver,
					s.stp_osd,
					s.stp_pudelpref,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_phonenumber
						ELSE CASE
								 WHEN s.stp_number = @stp_number THEN @cmp_phone1
								 ELSE s.stp_phonenumber
							 END
					END,
					s.stp_delayhours,
					s.stp_ooa_mileage,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_zipcode
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_zip
								ELSE s.stp_zipcode
							 END
					END,
					s.stp_ooa_stop,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_address
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_address1
								ELSE s.stp_address
							 END
					END,
					s.stp_transfer_stp,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_phonenumber2
						ELSE CASE 
								 WHEN s.stp_number = @stp_number THEN @cmp_phone2
								 ELSE s.stp_phonenumber2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_address2
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_address2
								ELSE s.stp_address2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNWON' THEN s.stp_contact
						ELSE CASE
								 WHEN s.stp_number = @stp_number THEN @cmp_contact
								 ELSE s.stp_contact
							 END
					END,
					s.stp_custpickupdate,
					s.stp_custdeliverydate,
					s.stp_podname,
					s.stp_cmp_close,
					s.stp_activitystart_dt,
					s.stp_activityend_dt,
					s.stp_departure_status,
					s.stp_eta,
					s.stp_etd,
					s.stp_transfer_type,
	-- PTS 34082 -- BL (start)
	--				s.stp_trip_mileage,
					0,
	-- PTS 34082 -- BL (end)
					s.stp_loadingmeters,
					s.stp_loadingmetersunit, 
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_country
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_country
								ELSE s.stp_country
							 END
					END,
					s.stp_cod_amount,
					s.stp_cod_currency,
					stp_ord_mileage_mtid,
					stp_lgh_mileage_mtid,
					stp_ooa_mileage_mtid,
					stp_pallets_in,
					stp_pallets_out
			  FROM	#stops s
						INNER JOIN #stp_xref sx ON s.stp_number = sx.stp_number
                                                INNER JOIN #lgh_xref ON s.lgh_number = #lgh_xref.lgh_number AND
                                                                        #lgh_xref.copy_number = @loop_counter
						INNER JOIN eventcodetable ect ON ect.abbr = s.stp_event
			 WHERE	sx.stp_id = @min_id AND
                                s.ord_hdrnumber > 0
	
			IF @@ERROR <> 0 GOTO ERROR_EXIT

			INSERT INTO stops 
				(ord_hdrnumber,
				 stp_number,
				 cmp_id,
				 stp_region1,
				 stp_region2,
				 stp_region3,
				 stp_city,
				 stp_state,
				 stp_schdtearliest,
				 stp_origschdt,
				 stp_arrivaldate,
				 stp_departuredate,
				 stp_reasonlate,
				 stp_schdtlatest,
				 lgh_number,
				 mfh_number,
				 stp_type,
				 stp_paylegpt,
				 shp_hdrnumber,
				 stp_sequence,
				 stp_region4,
				 stp_lgh_sequence,
				 trl_id,
				 stp_mfh_sequence,
				 stp_event,
				 stp_mfh_position,
				 stp_lgh_position,
				 stp_mfh_status,
				 stp_lgh_status,
				 stp_ord_mileage,
				 stp_lgh_mileage,
				 stp_mfh_mileage,
				 mov_number,
				 stp_loadstatus,
				 stp_weight,
				 stp_weightunit,
				 cmd_code,
				 stp_description,
				 stp_count,
				 stp_countunit,
				 cmp_name,
				 stp_comment,
				 stp_status,
				 stp_reftype,
				 stp_refnum,
				 stp_reasonlate_depart,
				 stp_screenmode,
				 skip_trigger,
				 stp_volume,
				 stp_volumeunit,
				 stp_dispatched_sequence,
				 stp_arr_confirmed,
				 stp_dep_confirmed,
				 stp_type1,
				 stp_redeliver,
				 stp_osd,
				 stp_pudelpref,
				 stp_phonenumber,
				 stp_delayhours,
				 stp_ooa_mileage,
				 stp_zipcode,
				 stp_ooa_stop,
				 stp_address,
				 stp_transfer_stp,
				 stp_phonenumber2,
				 stp_address2,
				 stp_contact,
				 stp_custpickupdate,
				 stp_custdeliverydate,
				 stp_podname,
				 stp_cmp_close,
				 stp_activitystart_dt,
				 stp_activityend_dt,
				 stp_departure_status,
				 stp_eta,
				 stp_etd,
				 stp_transfer_type,
				 stp_trip_mileage,
				 stp_loadingmeters,
				 stp_loadingmetersunit, 
				 stp_country,
				 stp_cod_amount,
				 stp_cod_currency,
				 stp_ord_mileage_mtid,
				 stp_lgh_mileage_mtid,
				 stp_ooa_mileage_mtid,
				 stp_pallets_in,
				 stp_pallets_out)
			SELECT	0,
					sx.new_stp_number,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.cmp_id
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @shipper
								ELSE s.cmp_id
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region1
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region1
								ELSE s.stp_region1
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region2
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region2
								ELSE s.stp_region2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region3
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region3
								ELSE s.stp_region3
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_city
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_city
								ELSE s.stp_city
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_state
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_state
								ELSE s.stp_state
							 END
					END,
					s.stp_schdtearliest,
					s.stp_origschdt,
					s.stp_arrivaldate,
					s.stp_departuredate,
					s.stp_reasonlate,
					s.stp_schdtlatest,
					#lgh_xref.new_lgh_number,
					s.mfh_number,
					s.stp_type,
					s.stp_paylegpt,
					s.shp_hdrnumber,
					s.stp_sequence,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_region4
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_region4
								ELSE s.stp_region4
							 END
					END,
					s.stp_lgh_sequence,
					trl_id,
					s.stp_mfh_sequence,
					s.stp_event,
					s.stp_mfh_position,
					s.stp_lgh_position,
					s.stp_mfh_status,
					s.stp_lgh_status,
					s.stp_ord_mileage,
	-- PTS 34082 -- BL (start)
	--				s.stp_lgh_mileage,
					s.stp_ord_mileage,
	-- PTS 34082 -- BL (end)
					s.stp_mfh_mileage,
					@newmov_number,
					s.stp_loadstatus,
					s.stp_weight,
					s.stp_weightunit,
					CASE @cmd_code
						WHEN 'UNKNOWN' THEN s.cmd_code
						ELSE @cmd_code
					END,
					CASE @cmd_code
						WHEN 'UNKNOWN' THEN s.stp_description
						ELSE @cmd_name
					END,
					s.stp_count,
					s.stp_countunit,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.cmp_name
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_name
								ELSE s.cmp_name
							 END
					END,
					s.stp_comment,
					s.stp_status,
					s.stp_reftype,
					s.stp_refnum,
					s.stp_reasonlate_depart,
					s.stp_screenmode,
					s.skip_trigger,
					s.stp_volume,
					s.stp_volumeunit,
					s.stp_dispatched_sequence,
					NULL stp_arr_confirmed,
					NULL stp_dep_confirmed,
					s.stp_type1,
					s.stp_redeliver,
					s.stp_osd,
					s.stp_pudelpref,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_phonenumber
						ELSE CASE
								 WHEN s.stp_number = @stp_number THEN @cmp_phone1
								 ELSE s.stp_phonenumber
							 END
					END,
					s.stp_delayhours,
					s.stp_ooa_mileage,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_zipcode
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_zip
								ELSE s.stp_zipcode
							 END
					END,
					s.stp_ooa_stop,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_address
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_address1
								ELSE s.stp_address
							 END
					END,
					s.stp_transfer_stp,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_phonenumber2
						ELSE CASE 
								 WHEN s.stp_number = @stp_number THEN @cmp_phone2
								 ELSE s.stp_phonenumber2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_address2
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_address2
								ELSE s.stp_address2
							 END
					END,
					CASE @shipper
						WHEN 'UNKNWON' THEN s.stp_contact
						ELSE CASE
								 WHEN s.stp_number = @stp_number THEN @cmp_contact
								 ELSE s.stp_contact
							 END
					END,
					s.stp_custpickupdate,
					s.stp_custdeliverydate,
					s.stp_podname,
					s.stp_cmp_close,
					s.stp_activitystart_dt,
					s.stp_activityend_dt,
					s.stp_departure_status,
					s.stp_eta,
					s.stp_etd,
					s.stp_transfer_type,
	-- PTS 34082 -- BL (start)
	--				s.stp_trip_mileage,
					0,
	-- PTS 34082 -- BL (end)
					s.stp_loadingmeters,
					s.stp_loadingmetersunit, 
					CASE @shipper
						WHEN 'UNKNOWN' THEN s.stp_country
						ELSE CASE
								WHEN s.stp_number = @stp_number THEN @cmp_country
								ELSE s.stp_country
							 END
					END,
					s.stp_cod_amount,
					s.stp_cod_currency,
					stp_ord_mileage_mtid,
					stp_lgh_mileage_mtid,
					stp_ooa_mileage_mtid,
					stp_pallets_in,
					stp_pallets_out
			  FROM	#stops s
						INNER JOIN #stp_xref sx ON s.stp_number = sx.stp_number
                                                INNER JOIN #lgh_xref ON s.lgh_number = #lgh_xref.lgh_number AND
                                                                        #lgh_xref.copy_number = @loop_counter
						INNER JOIN eventcodetable ect ON ect.abbr = s.stp_event
			 WHERE	sx.stp_id = @min_id AND
                                s.ord_hdrnumber = 0

			IF @@ERROR <> 0 GOTO ERROR_EXIT
	
			SELECT	@min_id = MIN(stp_id)
			  FROM	#stp_xref
			 WHERE	stp_id > @min_id

		End--End for the ELSE
	END--End for the WHILE

	INSERT INTO orderheader 
		(ord_company,
		 ord_number,
		 ord_customer,
		 ord_bookdate,
		 ord_bookedby,
		 ord_status,
		 ord_originpoint,
		 ord_destpoint,
		 ord_invoicestatus,
		 ord_origincity,
		 ord_destcity,
		 ord_originstate,
		 ord_deststate,
		 ord_originregion1,
		 ord_destregion1,
		 ord_supplier,
		 ord_billto,
		 ord_startdate,
		 ord_completiondate,
		 ord_revtype1,
		 ord_revtype2,
		 ord_revtype3,
		 ord_revtype4,
		 ord_totalweight,
		 ord_totalpieces,
		 ord_totalmiles,
		 ord_totalcharge, 
		 ord_currency,
		 ord_currencydate,
		 ord_totalvolume,
		 ord_hdrnumber,
		 ord_refnum,
		 ord_invoicewhole,
		 ord_remark,
		 ord_shipper,
		 ord_consignee,
		 ord_pu_at,
		 ord_dr_at,
		 ord_originregion2,
		 ord_originregion3,
		 ord_originregion4,
		 ord_destregion2,
		 ord_destregion3,
		 ord_destregion4,
		 mfh_hdrnumber,
		 ord_priority,
		 mov_number,
		 tar_tarriffnumber,
		 tar_number,
		 tar_tariffitem,
		 ord_contact,
		 ord_showshipper,
		 ord_showcons,
		 ord_subcompany,
		 ord_lowtemp,
		 ord_hitemp,
		 ord_quantity,
		 ord_rate,
		 ord_charge,
		 ord_rateunit,
		 ord_unit,
		 trl_type1,
		 ord_driver1,
		 ord_driver2,
		 ord_tractor,
		 ord_trailer,
		 ord_length,
		 ord_width,
		 ord_height,
		 ord_lengthunit,
		 ord_widthunit,
		 ord_heightunit,
		 ord_reftype,
		 cmd_code,
		 ord_description,
		 ord_terms,
		 cht_itemcode,
		 ord_origin_earliestdate,
		 ord_origin_latestdate,
		 ord_odmetermiles,
		 ord_stopcount,
		 ord_dest_earliestdate,
		 ord_dest_latestdate,
		 ref_sid,
		 ref_pickup,
		 ord_cmdvalue,
		 ord_accessorial_chrg,
		 ord_availabledate,
		 ord_miscqty,
		 ord_tempunits,
		 ord_datetaken,
		 ord_totalweightunits,
		 ord_totalvolumeunits,
		 ord_totalcountunits,
		 ord_loadtime,
		 ord_unloadtime,
		 ord_drivetime,
		 ord_rateby,
		 ord_quantity_type,
		 ord_thirdpartytype1,
		 ord_thirdpartytype2,
		 ord_charge_type,
		 ord_bol_printed,
		 ord_fromorder,
		 ord_mintemp,
		 ord_maxtemp,
		 ord_distributor,
		 opt_trc_type4,
		 opt_trl_type4,
		 ord_cod_amount,
		 appt_init,
		 appt_contact,
		 ord_ratingquantity,
		 ord_ratingunit,
		 ord_booked_revtype1,
		 ord_hideshipperaddr,
		 ord_hideconsignaddr,
		 ord_trl_type2,
		 ord_trl_type3,
		 ord_trl_type4,
		 ord_tareweight,
		 ord_grossweight,
		 ord_mileagetable,
		 ord_allinclusivecharge, 
		 ord_rate_type,
		 ord_stlquantity,
		 ord_stlunit,
		 ord_stlquantity_type,
		 ord_revenue_pay, 
		 ord_reserved_number,
		 ord_customs_document, 
		 ord_noautosplit, 
		 ord_noautotransfer, 
		 ord_totalloadingmeters, 
		 ord_totalloadingmetersunit, 
		 ord_charge_type_lh,
		 ord_mileage_adj_pct, 
		 ord_dimfactor,
		 ord_trlconfiguration,
		 ord_rate_mileagetable,
		 ord_raildest,
		 ord_railpoolid,
		 ord_trailer2,
		 ord_route,
		 ord_route_effc_date,
		 ord_route_exp_date,
		 ord_odmetermiles_mtid,
		 ord_origin_zip,
		 ord_dest_zip,
		 ord_no_recalc_miles,
         	 car_key,  --41629
         	 ord_gvw_unit,           --PTS 38846 TGRIFFIT
         	 ord_gvw_adjstd_unit,    --PTS 38846 TGRIFFIT
         	 ord_gvw_adjstd_amt,     --PTS 38846 TGRIFFIT
         	 ord_anc_number, --MROIK - PTS #38843       
		 ord_thirdpartytype3,
		 ord_thirdparty_split_percent,
		 ord_thirdparty_split,
        	 ord_cyclic_dsp_enabled,     --PTS 43236 TGRIFFIT
        	 ord_preassign_ack_required, --PTS 43236 TGRIFFIT
		 ord_broker,	    	     --PTS50180 MBR 12/10/09	           
 		 ord_ratemode,			/* 11/18/2011 NQIAO PTS 58978 */
		 ord_servicelevel,		/* 11/18/2011 NQIAO PTS 58978 */
		 ord_servicedays)		/* 11/18/2011 NQIAO PTS 58978 */

		SELECT	oh.ord_company,
				ox.new_ord_number,
				oh.ord_customer,
				oh.ord_bookdate,
				oh.ord_bookedby,
				oh.ord_status,
				CASE @shipper
					WHEN 'UNKNOWN' THEN oh.ord_originpoint
					ELSE @shipper
				END,
				oh.ord_destpoint,
				oh.ord_invoicestatus,
				CASE @shipper
					WHEN 'UNKNOWN' THEN oh.ord_origincity
					ElSE @cmp_city
				END,
				oh.ord_destcity,
				CASE @shipper
					WHEN 'UNKNOWN' THEN oh.ord_originstate
					ELSE @cmp_state
				END,
				oh.ord_deststate,
				CASE @shipper
					WHEN 'UNKNOWN' THEN oh.ord_originregion1
					ELSE @cmp_region1
				END,
				oh.ord_destregion1,
				oh.ord_supplier,
				oh.ord_billto,
				@ordstart,
				@ordcomplete,
				oh.ord_revtype1,
				oh.ord_revtype2,
				oh.ord_revtype3,
				oh.ord_revtype4,
				oh.ord_totalweight,
				oh.ord_totalpieces,
				oh.ord_totalmiles,
				oh.ord_totalcharge, 
				oh.ord_currency,
				oh.ord_currencydate,
				oh.ord_totalvolume,
				ox.new_ord_hdrnumber,
				oh.ord_refnum,
				oh.ord_invoicewhole,
				oh.ord_remark,
				CASE @shipper
					WHEN 'UNKNOWN' THEN oh.ord_shipper
					ELSE @shipper
				END,
				oh.ord_consignee,
				oh.ord_pu_at,
				oh.ord_dr_at,
				CASE @shipper
					WHEN 'UNKNOWN' THEN oh.ord_originregion2
					ELSE @cmp_region2
				END,
				CASE @shipper
					WHEN 'UNKNOWN' THEN oh.ord_originregion3
					ELSE @cmp_region3
				END,
				CASE @shipper
					WHEN 'UNKNOWN' THEN oh.ord_originregion4
					ELSE @cmp_region4
				END,
				oh.ord_destregion2,
				oh.ord_destregion3,
				oh.ord_destregion4,
				oh.mfh_hdrnumber,
				oh.ord_priority,
				ox.new_mov_number,
				oh.tar_tarriffnumber,
				oh.tar_number,
				oh.tar_tariffitem,
				oh.ord_contact,
				oh.ord_showshipper,
				oh.ord_showcons,
				oh.ord_subcompany,
				oh.ord_lowtemp,
				oh.ord_hitemp,
				oh.ord_quantity,
				oh.ord_rate,
				oh.ord_charge,
				oh.ord_rateunit,
				oh.ord_unit,
				oh.trl_type1,
				oh.ord_driver1,
				oh.ord_driver2,
				oh.ord_tractor,
				oh.ord_trailer,
				oh.ord_length,
				oh.ord_width,
				oh.ord_height,
				oh.ord_lengthunit,
				oh.ord_widthunit,
				oh.ord_heightunit,
				oh.ord_reftype,
				CASE @cmd_code
					WHEN 'UNKNOWN' THEN	oh.cmd_code
					ELSE @cmd_code
				END,
				CASE @cmd_code
					WHEN 'UNKNOWN' THEN	oh.ord_description
					ELSE @cmd_name
				END,
				oh.ord_terms,
				oh.cht_itemcode,
				@originearliest,
				@originlatest,
				oh.ord_odmetermiles,
				oh.ord_stopcount,
				@destearliest,
				@destlatest,
				oh.ref_sid,
				oh.ref_pickup,
				oh.ord_cmdvalue,
				oh.ord_accessorial_chrg,
				oh.ord_availabledate,
				oh.ord_miscqty,
				oh.ord_tempunits,
				oh.ord_datetaken,
				oh.ord_totalweightunits,
				oh.ord_totalvolumeunits,
				oh.ord_totalcountunits,
				oh.ord_loadtime,
				oh.ord_unloadtime,
				oh.ord_drivetime,
				oh.ord_rateby,
				oh.ord_quantity_type,
				oh.ord_thirdpartytype1,
				oh.ord_thirdpartytype2,
				oh.ord_charge_type,
				oh.ord_bol_printed,
				oh.ord_fromorder,
				oh.ord_mintemp,
				oh.ord_maxtemp,
				oh.ord_distributor,
				oh.opt_trc_type4,
				oh.opt_trl_type4,
				oh.ord_cod_amount,
				oh.appt_init,
				oh.appt_contact,
				oh.ord_ratingquantity,
				oh.ord_ratingunit,
				oh.ord_booked_revtype1,
				oh.ord_hideshipperaddr,
				oh.ord_hideconsignaddr,
				oh.ord_trl_type2,
				oh.ord_trl_type3,
				oh.ord_trl_type4,
				oh.ord_tareweight,
				oh.ord_grossweight,
				oh.ord_mileagetable,
				oh.ord_allinclusivecharge, 
				oh.ord_rate_type,
				oh.ord_stlquantity,
				oh.ord_stlunit,
				oh.ord_stlquantity_type,
				oh.ord_revenue_pay, 
				oh.ord_reserved_number,
				oh.ord_customs_document, 
				oh.ord_noautosplit, 
				oh.ord_noautotransfer, 
				oh.ord_totalloadingmeters, 
				oh.ord_totalloadingmetersunit, 
				oh.ord_charge_type_lh,
				oh.ord_mileage_adj_pct, 
				oh.ord_dimfactor,
				oh.ord_trlconfiguration,
				oh.ord_rate_mileagetable,
				oh.ord_raildest,
				oh.ord_railpoolid,
				oh.ord_trailer2,
				oh.ord_route,
				oh.ord_route_effc_date,
				oh.ord_route_exp_date,
				oh.ord_odmetermiles_mtid,
				oh.ord_origin_zip,
				oh.ord_dest_zip,
				oh.ord_no_recalc_miles,
                		oh.car_key, --41629
                		ord_gvw_unit,           --PTS 38846 TGRIFFIT
                		ord_gvw_adjstd_unit,    --PTS 38846 TGRIFFIT
                		ord_gvw_adjstd_amt,     --PTS 38846 TGRIFFIT
                		oh.ord_fromorder,        --MROIK - PTS #38843
				oh.ord_thirdpartytype3,
				oh.ord_thirdparty_split_percent,
				oh.ord_thirdparty_split,
               			oh.ord_cyclic_dsp_enabled,    --PTS 43236 TGRIFFIT
                		oh.ord_preassign_ack_required,--PTS 43236 TGRIFFIT
				oh.ord_broker,			--PTS50180 MBR 12/10/09
         		oh.ord_ratemode,			/* 11/18/2011 NQIAO PTS 58978 */
				oh.ord_servicelevel,		/* 11/18/2011 NQIAO PTS 58978 */
				oh.ord_servicedays			/* 11/18/2011 NQIAO PTS 58978 */
		  FROM	#orderheader oh
					INNER JOIN #orderheader_xref ox ON oh.ord_hdrnumber = ox.ord_hdrnumber
		 WHERE	ox.copy_number = @loop_counter

	-- PTS 28233 KWS
	INSERT INTO	ticket_order_entry_plan_orders
			(toep_id, ord_hdrnumber)
		SELECT	@toep_id, ox.new_ord_hdrnumber
		FROM	#orderheader_xref ox 
		WHERE	ox.ord_hdrnumber = @orig_ord_hdrnumber AND
				ox.copy_number = @loop_counter AND
				@toep_id <> -1
	-- PTS 28233 KWS

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	INSERT INTO #newords 
		(ord_number ,
		 ord_startdate,
		 ord_shipper ,
		 shipper_name,
		 ord_consignee ,
		 consignee_name,
		 ord_hdrnumber,
		 ord_fromorder,
                 mov_number )
		SELECT	ox.new_ord_number,
				@ordstart ord_startdate,
				oh.ord_shipper,
				Substring(shp.cmp_name,1,50),
				oh.ord_consignee,
				Substring(con.cmp_name,1,50),
				ox.new_ord_hdrnumber,
				oh.ord_fromorder,
				ox.new_mov_number
		  FROM	#orderheader oh
					INNER JOIN #orderheader_xref ox ON oh.ord_hdrnumber = ox.ord_hdrnumber
					INNER JOIN company shp ON oh.ord_shipper = shp.cmp_id
					INNER JOIN company con ON oh.ord_consignee = con.cmp_id
		 WHERE	ox.copy_number = @loop_counter

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	SELECT	@min_id = MIN(not_id)
	  FROM	#notes_xref

	WHILE ISNULL(@min_id, 0) > 0 
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
			 nre_tablekey,  --10
			 not_sequence,
			 last_updatedby,
			 last_updatedatetime,
             autonote,  --41629 for bug PTS add 7 columns
             not_text_large,
             not_viewlevel,
             --not_table_copied_from,  -- PTS 44064 (fix name)
		     ntb_table_copied_from,	-- PTS 44064 (fix name)
             nre_tablekey_copied_from,
             not_number_copied_from,
             not_tmsend)          --20
		  	SELECT	nx.new_not_number,
					n.not_text,
					n.not_type,
					n.not_urgent,
					n.not_senton,
					n.not_sentby,
					n.not_expires,
					n.not_forwardedfrom,
					n.ntb_table,
					ox.new_ord_hdrnumber,       --10
					n.not_sequence,
--					'COPYPROC',
					CASE @DoNotUseCopyProcAsUser WHEN 'Y' THEN n.last_updatedby ELSE 'COPYPROC' END, -- SLM 39478
					GETDATE(),
                    autonote,  --41629 for bug PTS add 7 columns
                    n.not_text_large,
                    n.not_viewlevel,
                    --n.not_table_copied_from,   -- PTS 44064 - fix name
					n.ntb_table_copied_from,	-- PTS 44064 - fix name
                    n.nre_tablekey_copied_from,
                    n.not_number_copied_from,
                    n.not_tmsend
		  FROM	#notes_xref nx
					INNER JOIN notes n ON nx.not_number = n.not_number
					INNER JOIN #orderheader_xref ox ON n.nre_tablekey = ox.ord_hdrnumber
		 WHERE	nx.not_id = @min_id AND
				ox.copy_number = @loop_counter

		IF @@ERROR <> 0 GOTO ERROR_EXIT

		SELECT	@min_id = MIN(not_id)
		  FROM	#notes_xref
		 WHERE	not_id > @min_id
	END

	IF @copyAccessorials = 'Y' AND @ivd_count > 0
	BEGIN
		SELECT	@min_id = MIN(ivd_id)
		  FROM	#ivd_xref
	
		WHILE ISNULL(@min_id, 0) > 0 
		BEGIN
			INSERT INTO invoicedetail
				(ivh_hdrnumber,
				 ivd_number,
				 stp_number,
				 ivd_description,
				 cht_itemcode,
				 ivd_quantity,
				 ivd_rate,
				 ivd_charge,
				 ivd_taxable1,
				 ivd_taxable2,
				 ivd_taxable3,
				 ivd_taxable4,
				 ivd_unit,
				 cur_code,
				 ivd_currencydate,
				 ivd_glnum,
				 ord_hdrnumber,
				 ivd_type,
				 ivd_rateunit,
				 ivd_billto,
				 ivd_itemquantity,
				 ivd_subtotalptr,
				 ivd_allocatedrev,
				 ivd_sequence,
				 ivd_invoicestatus,
				 mfh_hdrnumber,
				 ivd_refnum,
				 cmd_code,
				 cmp_id,
				 ivd_distance,
				 ivd_distunit,
				 ivd_wgt,
				 ivd_wgtunit,
				 ivd_count,
				 ivd_countunit,
				 evt_number,
				 ivd_reftype,
				 ivd_volume,
				 ivd_volunit,
				 ivd_orig_cmpid,
				 ivd_payrevenue,
				 ivd_sign,
				 ivd_length,
				 ivd_lengthunit,
				 ivd_width,
				 ivd_widthunit,
				 ivd_height,
				 ivd_heightunit,
				 ivd_exportstatus,
				 cht_basisunit,
				 ivd_remark,
				 tar_number,
				 tar_tariffnumber,
				 tar_tariffitem,
				 ivd_fromord,
				 ivd_zipcode,
				 ivd_quantity_type,
				 cht_class,
				 ivd_mileagetable,
				 ivd_charge_type,
                                 cht_lh_min,
                                 cht_lh_rev,
                                 cht_lh_stl,
                                 cht_lh_rpt,
                                 cht_rollintolh,
                 ivd_car_key)  --41629
				SELECT	0 ivh_hdrnumber,
						ix.new_ivd_number,
						sx.new_stp_number,
						i.ivd_description,
						i.cht_itemcode,
						i.ivd_quantity,
						i.ivd_rate,
						i.ivd_charge,
						i.ivd_taxable1,
						i.ivd_taxable2,
						i.ivd_taxable3,
						i.ivd_taxable4,
						i.ivd_unit,
						i.cur_code,
						GETDATE() ivd_currencydate,
						i.ivd_glnum,
						ox.new_ord_hdrnumber,
						i.ivd_type,
						i.ivd_rateunit,
						i.ivd_billto,
						i.ivd_itemquantity,
						0 ivd_subtotalptr,
						i.ivd_allocatedrev,
						999 ivd_sequence,
						NULL ivd_invoicestatus,
						NULL mfh_hdrnumber,
						i.ivd_refnum,
						i.cmd_code,
						i.cmp_id,
						i.ivd_distance,
						i.ivd_distunit,
						i.ivd_wgt,
						i.ivd_wgtunit,
						i.ivd_count,
						i.ivd_countunit,
						ex.new_evt_number,
						i.ivd_reftype,
						i.ivd_volume,
						i.ivd_volunit,
						i.ivd_orig_cmpid,
						i.ivd_payrevenue,
						i.ivd_sign,
						i.ivd_length,
						i.ivd_lengthunit,
						i.ivd_width,
						i.ivd_widthunit,
						i.ivd_height,
						i.ivd_heightunit,
						NULL ivd_exportstatus,
						i.cht_basisunit,
						i.ivd_remark,
						i.tar_number,
						i.tar_tariffnumber,
						i.tar_tariffitem,
						i.ivd_fromord,
						i.ivd_zipcode,
						i.ivd_quantity_type,
						i.cht_class,
						i.ivd_mileagetable,
						i.ivd_charge_type,
                                                cht_lh_min,
                                                cht_lh_rev,
                                                cht_lh_stl,
                                                cht_lh_rpt,
                                                cht_rollintolh,
                        i.ivd_car_key   --41629
				  FROM	#ivd_xref ix
							INNER JOIN invoicedetail i ON i.ivd_number = ix.ivd_number
							LEFT OUTER JOIN #stp_xref sx ON i.stp_number = sx.stp_number
							LEFT OUTER JOIN #evt_xref ex ON i.evt_number = ex.evt_number
							INNER JOIN #orderheader_xref ox ON i.ord_hdrnumber = ox.ord_hdrnumber
				 WHERE	ix.ivd_id = @min_id AND
						ox.copy_number = @loop_counter

			IF @@ERROR <> 0 GOTO ERROR_EXIT

			SELECT	@min_id = MIN(ivd_id)
			  FROM	#ivd_xref
			 WHERE	ivd_id > @min_id
		END
	END

	IF @copyloadrequirements = 'Y'
	BEGIN
		INSERT INTO loadrequirement 
			(ord_hdrnumber, 
			 lrq_sequence, 
			 lrq_equip_type, 
			 lrq_type, 
			 lrq_not, 
			 lrq_manditory, 
			 lrq_quantity, 
			 cmp_id, 
			 def_id_type, 
			 lgh_number, 
			 mov_number, 
			 lrq_default, 
			 cmd_code)
	     	SELECT	ox.new_ord_hdrnumber, 
					lrq_sequence, 
					lrq_equip_type, 
					lrq_type, lrq_not, 
					lrq_manditory, 
					lrq_quantity, 
					cmp_id, 
					def_id_type, 
					ox.new_lgh_number,  
					ox.new_mov_number,
					lrq_default,
					cmd_code
		      FROM	loadrequirement lrq
						INNER JOIN #orderheader_xref ox ON lrq.ord_hdrnumber = ox.ord_hdrnumber
			 WHERE	ox.copy_number = @loop_counter

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END


	SELECT	@newordhdr_nbr = new_ord_hdrnumber,
			@ordhdr_nbr = ord_hdrnumber,
			@neword_nbr = new_ord_number,
			@newmov_nbr = new_mov_number,
			@newlgh_nbr = new_lgh_number
	  FROM	#orderheader_xref
	 WHERE	copy_number = @loop_counter

-- PTS 28980 -- BL (start)
 	Select @CloneOrdersDefaultLRQ = left(Upper(IsNUll(gi_string1,'N')),1) From generalinfo Where gi_name = 'CloneOrdersDefaultLRQ'
 	If @copyloadrequirements = 'Y' and @CloneOrdersDefaultLRQ = 'Y'
 		INSERT INTO loadrequirement 
        			(ord_hdrnumber, lrq_sequence, lrq_equip_type, lrq_type, lrq_not, lrq_manditory, 
 		  	lrq_quantity, cmp_id, def_id_type, lgh_number, mov_number,lrq_default,cmd_code)
      		SELECT @neword_nbr, lrq_sequence, lrq_equip_type, lrq_type, lrq_not, lrq_manditory, 
 	         	lrq_quantity, cmp_id, def_id_type, @newlgh_nbr,  @newmov_nbr,lrq_default,cmd_code
 	    	FROM loadrequirement 
 		WHERE mov_number = @oldmovnbr
 		and isnull(lrq_default, 'N') = 'X'
-- PTS 28980 -- BL (end)

	--25955 JJF copy extra info
	If @copyextrainfo = 'Y'
	BEGIN
		-- PTS 27194 -- BL (start)
--		EXEC cloneorderextrainfo @ordhdr_nbr, @newordhdr_nbr
		EXEC cloneorderextrainfo @orig_ord_hdrnumber, @newordhdr_nbr
		-- PTS 27194 -- BL (end)
	END

	--JJF 28538 Copy permit requirements

	IF @copypermitrequirements = 'Y'
	BEGIN
		EXEC cloneorderpermits @oldmovnbr, NULL, @newmov_nbr, @newlgh_nbr
		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	SELECT @orderlist = CASE ISNULL(@orderlist, '') WHEN '' THEN @neword_nbr ELSE (@orderlist + ',' + @neword_nbr) END

	COMMIT TRAN

--35747
  if exists (select 1 from generalinfo where gi_name = 'LocalTimeOption' and gi_string1 = 'LOCAL')
    BEGIN

   select @v_neword = new_ord_hdrnumber   from #orderheader_xref ox
   where ox.copy_number = @loop_counter
   exec AdjustStpOrdDatesForDST 'O',@orig_ord_hdrnumber,@v_neword
--if @@error > 0 return
    END

--35747 end

	EXEC UPDATE_MOVE @newmov_nbr

	IF @delete_reserved <> ''
	BEGIN
		DELETE reservedordnumbers WHERE ron_number = @delete_reserved
	END

	IF @copypaydetails = 'Y' AND @pyd_count > 0
	BEGIN
		SELECT	@min_id = MIN(pyd_id)
		  FROM	#pyd_xref

		WHILE ISNULL(@min_id, 0) > 0
		BEGIN
			INSERT INTO	paydetail
				(pyd_number,
				 pyh_number,
				 lgh_number,
				 asgn_number,
				 asgn_type,
				 asgn_id,
				 ivd_number,
				 pyd_prorap,
				 pyd_payto,
				 pyt_itemcode,
				 mov_number,
				 pyd_description,
				 pyr_ratecode,
				 pyd_quantity,
				 pyd_rateunit,
				 pyd_unit,
				 pyd_rate,
				 pyd_amount,
				 pyd_pretax,
				 pyd_glnum,
				 pyd_currency,
				 pyd_currencydate,
				 pyd_status,
				 pyd_refnumtype,
				 pyd_refnum,
				 pyh_payperiod,
				 pyd_workperiod,
				 lgh_startpoint,
				 lgh_startcity,
				 lgh_endpoint,
				 lgh_endcity,
				 ivd_payrevenue,
				 pyd_revenueratio,
				 pyd_lessrevenue,
				 pyd_payrevenue,
				 pyd_transdate,
				 pyd_minus,
				 pyd_sequence,
				 std_number,
				 pyd_loadstate,
				 pyd_xrefnumber,
				 ord_hdrnumber,
				 pyt_fee1,
				 pyt_fee2,
				 pyd_grossamount,
				 pyd_adj_flag,
				 pyd_updatedby,
				 psd_id,
				 pyd_transferdate,
				 pyd_exportstatus,
				 pyd_releasedby,
				 cht_itemcode,
				 pyd_billedweight,
				 tar_tarriffnumber,
				 psd_batch_id,
				 pyd_updsrc,
				 pyd_updatedon,
				 pyd_offsetpay_number,
				 pyd_credit_pay_flag,
				 pyd_ivh_hdrnumber,
				 psd_number,
				 pyd_ref_invoice,
				 pyd_ref_invoicedate)
				SELECT	px.new_pyd_number,
						0 pyh_number,
						@newlgh_nbr lgh_number,
						ISNULL(aa.asgn_number, 0),
						p.asgn_type,
						p.asgn_id,
						ISNULL(ix.new_ivd_number, 0),
						p.pyd_prorap,
						p.pyd_payto,
						p.pyt_itemcode,
						@newmov_nbr mov_number,
						p.pyd_description,
						p.pyr_ratecode,
						p.pyd_quantity,
						p.pyd_rateunit,
						p.pyd_unit,
						p.pyd_rate,
						p.pyd_amount,
						p.pyd_pretax,
						p.pyd_glnum,
						p.pyd_currency,
						p.pyd_currencydate,
						'HLD' pyd_status,
						p.pyd_refnumtype,
						p.pyd_refnum,
						'2049-12-31 23:59:00' pyh_payperiod,
						'2049-12-31 23:59:00' pyd_workperiod,
						p.lgh_startpoint,
						p.lgh_startcity,
						p.lgh_endpoint,
						p.lgh_endcity,
						p.ivd_payrevenue,
						p.pyd_revenueratio,
						p.pyd_lessrevenue,
						p.pyd_payrevenue,
						p.pyd_transdate,
						p.pyd_minus,
						p.pyd_sequence,
						p.std_number,
						p.pyd_loadstate,
						p.pyd_xrefnumber,
						@newordhdr_nbr	ord_hdrnumber,
						p.pyt_fee1,
						p.pyt_fee2,
						p.pyd_grossamount,
						p.pyd_adj_flag,
						@tmwuser pyd_updatedby,
						p.psd_id,
						p.pyd_transferdate,
						p.pyd_exportstatus,
						p.pyd_releasedby,
						p.cht_itemcode,
						p.pyd_billedweight,
						p.tar_tarriffnumber,
						p.psd_batch_id,
						p.pyd_updsrc,
						p.pyd_updatedon,
						p.pyd_offsetpay_number,
						p.pyd_credit_pay_flag,
						0 pyd_ivh_hdrnumber,
						0 psd_number,
						p.pyd_ref_invoice,
						p.pyd_ref_invoicedate
			  FROM	#pyd_xref px
						INNER JOIN paydetail p ON px.pyd_number = p.pyd_number
						INNER JOIN #ivd_xref ix ON ix.ivd_number = p.ivd_number
						LEFT OUTER JOIN assetassignment aa ON p.asgn_type = aa.asgn_type AND p.asgn_id = aa.asgn_id AND aa.lgh_number = @newlgh_nbr
			WHERE	px.pyd_id = @min_id

			SELECT	@min_id = MIN(pyd_id)
			  FROM	#pyd_xref
			 WHERE	pyd_id > @min_id
		END
	END

	--08/21/2008  JSwindell PTS44064 Add Thirdparty copy <<start>>			
	IF @copythirdparty = 'Y' 
		BEGIN
			set @copythirdparty_count = ( 
				select count(*) from #temp_thirdpartyassignment
				where #temp_thirdpartyassignment.ord_number in (select new_ord_number from #orderheader_xref where copy_number = @loop_counter)
				) 			

				IF @copythirdparty_count > 0 
				BEGIN 
					INSERT INTO thirdpartyassignment(tpr_id, lgh_number, mov_number, tpa_status, pyd_status,tpr_type, ord_number)
					select tpr_id, lgh_number, mov_number, tpa_status, pyd_status,tpr_type, ord_number
					from #temp_thirdpartyassignment
							INNER JOIN #orderheader_xref ox ON #temp_thirdpartyassignment.ord_number  = CONVERT(VARCHAR(12), ox.new_ord_number) 
							WHERE	ox.copy_number = @loop_counter
				END
		END
	--08/21/2008  JSwindell PTS44064 Add Thirdparty copy <<end>

	SET @loop_counter = @loop_counter + 1
END

GOTO SUCCESS_EXIT

ERROR_EXIT:
  ROLLBACK TRAN COPYLOOP

ERROR_EXIT2:

SUCCESS_EXIT:
	--32066 JJF 3/20/06 
	SELECT @copiescreated = count(*) 
	FROM #newords
	IF @copiescreated <> @copies BEGIN
		--Set count to reflect actual number created
		UPDATE ticket_order_entry_plan
		SET toep_planned_count = toep_planned_count - (@copies - @copiescreated)
		WHERE toep_id = @toep_id
	END
	--END 32066 JJF 3/20/06 

	SELECT * FROM #newords

-- PTS 32694 -- BL (start)
drop table #orderheader
drop table #orderheader_xref
drop table #stops
drop table #stp_xref
drop table #lgh_xref
drop table #freightdetail
drop table #fgt_xref
drop table #event
drop table #evt_xref
drop table #referencenumber
drop table #ivd_xref
drop table #pyd_xref
drop table #notes_xref
drop table #temp
drop table #newords
drop table #temp_thirdpartyassignment		-- PTS 44064
-- PTS 32694 -- BL (end)

GO
GRANT EXECUTE ON  [dbo].[clonetripwithoptions] TO [public]
GO
