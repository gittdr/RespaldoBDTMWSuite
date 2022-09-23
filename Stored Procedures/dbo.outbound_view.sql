SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[outbound_view]
  @revtype1 VARCHAR(254)
 ,@revtype2 VARCHAR(254)
 ,@revtype3 VARCHAR(254)
 ,@revtype4 VARCHAR(254)
 ,@trltype1 VARCHAR(254)
 ,@company VARCHAR(254)
 ,@states VARCHAR(254)
 ,@cmpids VARCHAR(254)
 ,@reg1 VARCHAR(254)
 ,@reg2 VARCHAR(254)
 ,@reg3 VARCHAR(254)
 ,@reg4 VARCHAR(254)
 ,@city INT
 ,@hoursback INT
 ,@hoursout INT
 ,@status VARCHAR(254) --55918
 ,@bookedby VARCHAR(254)
 ,@ref_type VARCHAR(6)
 ,@teamleader VARCHAR(254)
 ,@d_states VARCHAR(254)
 ,@d_cmpids VARCHAR(254)
 ,@d_reg1 VARCHAR(254)
 ,@d_reg2 VARCHAR(254)
 ,@d_reg3 VARCHAR(254)
 ,@d_reg4 VARCHAR(254)
 ,@d_city INT
 ,@includedrvplan VARCHAR(3)
 ,@miles_min INT
 ,@miles_max INT
 ,@tm_status VARCHAR(254)
 ,@lgh_type1 VARCHAR(254)
 ,@lgh_type2 VARCHAR(254)
 ,@billto VARCHAR(254)
 ,@lgh_hzd_cmd_classes VARCHAR(255)
 ,@orderedby VARCHAR(254)
 ,@o_servicearea VARCHAR(256)
 ,@o_servicezone VARCHAR(256)
 ,@o_servicecenter VARCHAR(256)
 ,@o_serviceregion VARCHAR(256)
 ,@dest_servicearea VARCHAR(256)
 ,@dest_servicezone VARCHAR(256)
 ,@dest_servicecenter VARCHAR(256)
 ,@dest_serviceregion VARCHAR(256)
 ,@lgh_route VARCHAR(256)
 ,@lgh_booked_revtype1 VARCHAR(256)
 ,@lgh_permit_status VARCHAR(256)
 ,@cmp_othertype1 VARCHAR(256)   /* 02/25/2008 MDH PTS 39077: Added */
 ,@d_cmp_othertype1 VARCHAR(256) /* 02/25/2008 MDH PTS 39077: Added */
 ,@startdate DATETIME
 ,@daysout INT
 ,@ord_booked_revtype1 VARCHAR(256)
 ,@pyt_linehaul VARCHAR(6) /* 08/04/2009 MDH PTS 42293: Added */
 ,@pyt_fuelcost VARCHAR(6) /* 08/04/2009 MDH PTS 42293: Added */
 ,@pyt_accessorial VARCHAR(6) /* 08/04/2009 MDH PTS 42293: Added */
 --PTS 57376 JJF 20110919
 ,@daysstartoffset INT
 ,@daysENDoffset INT
 ,@daterangemode SMALLINT
 --END PTS 57376 JJF 20110919
 --PTS 58161 JJF 20111017
 ,@cmp_othertype1_billto VARCHAR(256)
 ,@cmp_othertype2_billto VARCHAR(256)
 --END PTS 58161 JJF 20111017
 --PTS 64664 JJF 20121010 This allows inclusion of trips that include stop events at the specified origin. ,For instance, a trip may have a BMT preceeding the origin's HCT.
 ,@origin_include_stop_events VARCHAR(256)
 --END PTS 64664 JJF 20121010 
 --PTS 66628 KPM 20130205 This allows inclusion of trips that include That have a specific direct route staus. 
 ,@Direct_route_status1 VARCHAR(256) 
 --END 66628 KPM 20130205 
AS

/****** Object:  Stored Procedure dbo.outbound_view    Script Date: 6/24/98 10:15:30 AM ******/
/* MF 11/12/97 PTS 3215 changed to use newly populated fields ON LGH including lgh_active */
/* LOR 5/12/98 PTS# 3905 add shipper/consignee states, drivers' id's */
/* LOR 5/12/98 PTS# 3908 add ref type AND number */
/* JET 6/3/98 PTS# 3991 modified lgh_schdtearliest, lgh_schdtlatest to reflect ord_origin_earliestdate andord_origin_latestdate*/
/* MF 10/22/98 pts 4175 add extra cols*/
/* JET 10/20/99 PTS #6490 changed the WHERE clause ON the SELECT */
/* DSK 3/20/00 PTS 7566  add columns for total orders, total count, total weight, total volume */
/* KMM 7/10/00 PTS 8339  allow MPN records to be returned */
/* RJE 7/14/00 added ld_can_expires for CAN */
/* DPETE 12599 add origin AND dest company geoloc feilds to return set fro Gibsons SR */
/* Vern Jewett PTS 15033 07/31/2002 (label=vmj1) Add lgh_comments column. */
/* Vern Jewett PTS 18417 09/02/2003 (label=vmj2) Add lgh_etaalert1 column. */
/* PTS 26776 DJM  03/30/05 Recode changes made for Eagle in PTS number 19028, 22601,20302 INTo main source
    These Eagle enhancements will only work ON  SQL Server 2000 specific code. The
    SQL 7 compliant version MUST have the same columns AND parameters, but nothing
    will be done JOIN them. I.E. View retrictions will not be applied in the SQL 7
    version*/
/* PTS 26791 - DJM - Corrected display of Localization values.    */
/* BDH 9/12/06 PTS 33890  Returning next_ndrp_cmpid, next_ndrp_cmpname, next_ndrp_ctyname, next_ndrp_state, next_ndrp_arrivaldate FROM legheader_active */
/* EMK 10/3/06 PTS 33913  Returning ord_bookdate */
/* EMK 10/11/06 PTS 33913   Changed _2000 to PROVIDES statement. */
/* vjh 02/09/07 PTS 36608 Added Manual Check Call times. */
/* DPETE 35747 allow for GI option of alltimes in local time zone support
       return a minutes offset in each row to apply to Today()in datawindow for comparison (see attachemnt to PTS for how this works)*/
-- LOR PTS# 35761 added evt_earlydate AND ARRIVALDEPARTURE value to @LateWarnMode
/* BDH  36717 5/14/07  Added lockedby AND sessiondate columns as part of Command recode AND changed joins to ansi.  */
-- vjh 05/22/07 PTS 37626 use Apocalypse IF order event or check minutes are zero
-- vjh 05/30/07 PTS 37657 make the check call time time zone aware (when based ON stop time, but not WHEN based ON check calls)
-- vjh 38226 TZ shift the departure date before comparison
-- vjh 38677 redefine ord_manualeventcallminutes
-- SLM 08/31/2007 PTS 39133 Based ON General Info Setting 'PWSumOrdExtraInfo' use lgh_extrainfo1
-- DJM 38765 09/26/2007 - Added fields to planning worksheet.
-- DJM 42829 - Added trc_lastpos_lat AND trc_lastpos_long fields.
-- JJF 41795 20080506
-- SGB 42437 via 42994 changed subquery to tie to main query to avoid problem Subquery returned more than 1 value for LocalTime functionality
-- MTC 54532 Added "with (NOLOCK)" to part of insert statement to temp table that causes blocking IF slowness occurs.
-- MTC 55051 20101207 Changed the way that fuel surcharges are calculated to only look at mov_number FROM orderheader AND not BOTH that AND invoicedetail ord_hdrnumber values too.
-- MTC 55918 20110602 Change the way STATUS is handled. It is now in the join clause instead of in the WHERE clause. Use a function to
-- make the concatenated string INTo a table for joining. Populate JOIN a default IF the status is blank or null.
-- Add some indexes to support this change.
-- SGB 51911 Add UserDefined columns Default will be TimeZone
-- MTC 66651 Make dynamic so that proc will have consistent performance
-- KPM 66628 added paramater
-- MTC 74960 Fixed bug WHERE shipper AND consignee were not working JOIN client side filters.
-- MTC 88078 Removed most sub-SELECTs FROM ad-hoc SQL AND made them updates to the result set returned / performance.
-- ERB 93687 Made significant portions of the code dynamic for better plans 
--           formatted code for readability
--           added GI for fgt_length, width, height lookups since they are the slowest and often go unused
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE
  @char8 VARCHAR(8)
 ,@char1 VARCHAR(1)
 ,@char30 VARCHAR(30)
 ,@char20 VARCHAR(20)
 ,@char25 VARCHAR(25)
 ,@char40 VARCHAR(40)
 ,@cmdcount INT
 ,@floa FLOAT
 ,@hoursbackdate DATETIME
 ,@hoursoutdate DATETIME
 ,@gistring1 VARCHAR(60)
 ,@dttm DATETIME
 ,@char2 CHAR(2)
 ,@varchar45 VARCHAR(45)
 ,@varchar6 VARCHAR(6)
 ,@runpups CHAR(1)
 ,@rundrops CHAR(1)
 ,@retvarchar VARCHAR(3)
 ,@LateWarnMode VARCHAR(60)
 ,@PWExtraInfoLocation VARCHAR(20)
 ,@o_servicezone_labelname VARCHAR(20)
 ,@o_servicecenter_labelname VARCHAR(20)
 ,@o_serviceregion_labelname VARCHAR(20)
 ,@o_sericearea_labelname VARCHAR(20)
 ,@dest_servicezone_labelname VARCHAR(20)
 ,@dest_servicecenter_labelname VARCHAR(20)
 ,@dest_serviceregion_labelname VARCHAR(20)
 ,@dest_sericearea_labelname VARCHAR(20)
 ,@service_revtype VARCHAR(10)
 ,@localization CHAR(1)
 ,@pENDing_statuses VARCHAR(60)
 ,@UseShowAsShipperConsignee CHAR(1)
 ,@v_LghActiveUntilDepCompNBC CHAR(1)
 ,@ManualCheckCall CHAR(1)
 --35747
 ,@V_GILocalTImeOption VARCHAR(20)
 ,@v_LocalCityTZAdjFactor INT
 ,@v_LocalCityTZAdjMinutes INT	
 ,@InDSTFactor INT
 ,@DSTCountryCode INT 
 ,@V_LocalGMTDelta SMALLINT
 ,@v_LocalDSTCode SMALLINT
 ,@V_LocalAddnlMins SMALLINT
 --35747 END
 -- PTS 37075 SGB Added variable for column Label
 ,@SubCompanyLabel VARCHAR(20)
 ,@Apocalypse DATETIME
 ,@PlnWrkshtRefStr1 VARCHAR(60) --vjh pts 38986
 ,@PlnWrkshtRefStr2 VARCHAR(60) --vjh pts 38986
 ,@PlnWrkshtRefStr3 VARCHAR(60) --vjh pts 38986
 ,@ud_column1 CHAR(1) --PTS 51911 SGB
 ,@ud_column2 CHAR(1) --PTS 51911 SGB
 ,@ud_column3 CHAR(1) --PTS 51911 SGB
 ,@ud_column4 CHAR(1) --PTS 51911 SGB
 ,@procname VARCHAR(255) --PTS 51911 SGB
 ,@udheader VARCHAR(30) --PTS 51911 SGB
 ,@ShowDeliveryAndAppointment CHAR(1)	--PTS52228 MBR 06/27/12
 ,@UseUnknownCmpId CHAR(1)	--PTS67320 MBR 02/20/13
 ,@citylatlongunits CHAR(1)
 --PTS 40155 JJF 20071128
 ,@rowsecurity CHAR(1)
 --PTS 51570 JJF 20100510
 --,@tmwuser VARCHAR(255)
 --END PTS 51570 JJF 20100510
 --END PTS 40155 JJF 20071128
 --PTS 41795 JJF 20080506
 ,@FSCChargeTypeList VARCHAR(60)
 --END PTS 41795 JJF 20080506
 ,@IncludeRefNumbers VARCHAR(1)    /* 08/27/2008 MDH PTS 42301: Added */
 ,@PWSumOrdExtraInfo CHAR(1)
 ,@ACSInfo CHAR(1)           /* 08/28/2009 MDH PTS 42293: Added */
 --PTS 57376 JJF 20110919
 ,@CurrentDate DATETIME
 --END PTS 57376 JJF 20110919
 --PTS  66628 KPM 2/5/13
 ,@directroute CHAR(1)                            
 --END 66628 KPM 2/5/13
 --BEGIN PTS 52017
 ,@MatchAdviceInterface CHAR(1)
 ,@ma_transaction_id BIGINT
 ,@ma_inserted_date DATETIME
 ,@null_varchar8 VARCHAR(8)
 ,@null_varchar100 VARCHAR(100)
 ,@null_int INT
 ,@Check INT
 ,@MatchAdviceMultiCompany CHAR(1)
 ,@DefaultCompanyID VARCHAR(8)
 ,@UserCompanyID VARCHAR(8)
 ,@TMWUser VARCHAR(255)
  --END PTS 52017
 --BEGIN PTS 56436 SPN
 ,@ACS_Exclude_ACC_PayType VARCHAR(60)
 --END PTS 56436 SPN
 ,@sql NVARCHAR(max)
 ,@StatusList TMWTable_varchar256 -- ERB 93687 20150717
 ,@lghType1List TMWTable_varchar256-- ERB 93687 20150717
 ,@lghType2List TMWTable_varchar256-- ERB 93687 20150717
 ,@lghType3List TMWTable_varchar256-- ERB 93687 20150717
 ,@lghType4List TMWTable_varchar256-- ERB 93687 20150717
 ,@billtoList TMWTable_varchar256-- ERB 93687 20150717
 ,@StartRegion1List TMWTable_varchar256-- ERB 93687 20150717
 ,@StartRegion2List TMWTable_varchar256-- ERB 93687 20150717
 ,@StartRegion3List TMWTable_varchar256-- ERB 93687 20150717
 ,@StartRegion4List TMWTable_varchar256-- ERB 93687 20150717
 ,@startStateList TMWTable_varchar256-- ERB 93687 20150717
 ,@endStateList TMWTable_varchar256-- ERB 93687 20150717
 ,@endCompList TMWTable_varchar256-- ERB 93687 20150717
 ,@TeamLeaderList TMWTable_varchar256-- ERB 93687 20150717
 ,@TMStatusList TMWTable_varchar256-- ERB 93687 20150717
 ,@lgh_type1List TMWTable_varchar256-- ERB 93687 20150717
 ,@lgh_type2List TMWTable_varchar256-- ERB 93687 20150717
 ,@companyList TMWTable_varchar256-- ERB 93687 20150717
 ,@bookedbyList TMWTable_varchar256-- ERB 93687 20150717
 ,@trltype1List TMWTable_varchar256-- ERB 93687 20150717
 ,@lgh_routeList TMWTable_varchar256-- ERB 93687 20150717
 ,@lgh_booked_revtype1List TMWTable_varchar256-- ERB 93687 20150717
 ,@orderedbyList TMWTable_char20-- ERB 93687 20150717
 ,@reg1List TMWTable_varchar256-- ERB 93687 20150717
 ,@reg2List TMWTable_varchar256-- ERB 93687 20150717
 ,@reg3List TMWTable_varchar256-- ERB 93687 20150717
 ,@reg4List TMWTable_varchar256-- ERB 93687 20150717
 ,@d_reg1List TMWTable_varchar256-- ERB 93687 20150717
 ,@d_reg2List TMWTable_varchar256-- ERB 93687 20150717
 ,@d_reg3List TMWTable_varchar256-- ERB 93687 20150717
 ,@d_reg4List TMWTable_varchar256-- ERB 93687 20150717
 ,@lgh_permit_statusList TMWTable_varchar256-- ERB 93687 20150717
 ,@lgh_hzd_cmd_classesList TMWTable_varchar256-- ERB 93687 20150717
 ,@cmp_othertype1List TMWTable_varchar256-- ERB 93687 20150717
 ,@d_cmp_othertype1List TMWTable_varchar256-- ERB 93687 20150717
 ,@cmp_othertype1_billtoList TMWTable_varchar256-- ERB 93687 20150717
 ,@cmp_othertype2_billtoList TMWTable_varchar256-- ERB 93687 20150717
 ,@ord_booked_revtype1List TMWTable_varchar256-- ERB 93687 20150717
 ,@cmpidsList TMWTable_varchar256-- ERB 93687 20150717
 ,@origin_include_stop_eventsList TMWTable_char6-- ERB 93687 20150717
 ,@Direct_route_status1List TMWTable_varchar256-- ERB 93687 20150717

DECLARE @ttbl1 Table(
  lgh_number INT NULL
 ,ord_carrier	VARCHAR(13) NULL
 ,o_cmpid VARCHAR(12) NULL
 ,o_cmpname VARCHAR(30) NULL
 ,o_ctyname VARCHAR(25) NULL
 ,d_cmpid VARCHAR(12) NULL
 ,d_cmpname VARCHAR(30) NULL
 ,d_ctyname VARCHAR(25) NULL
 ,f_cmpid VARCHAR(8) NULL
 ,f_cmpname VARCHAR(30) NULL
 ,f_ctyname VARCHAR(25) NULL
 ,l_cmpid VARCHAR(8) NULL
 ,l_cmpname VARCHAR(30) NULL
 ,l_ctyname VARCHAR(25) NULL
 ,lgh_startdate DATETIME NULL
 ,lgh_ENDdate DATETIME NULL
 ,o_state VARCHAR(6) NULL
 ,d_state VARCHAR(6) NULL
 ,lgh_schdtearliest DATETIME NULL
 ,lgh_schdtlatest DATETIME NULL
 ,cmd_code VARCHAR(8) NULL
 ,fgt_description VARCHAR(60) NULL
 ,cmd_count INT NULL
 ,ord_hdrnumber INT NULL
 ,evt_driver1 VARCHAR(45) NULL
 ,evt_driver2 VARCHAR(45) NULL
 ,evt_tractor VARCHAR(8) NULL
 ,lgh_primary_trailer VARCHAR(13) NULL
 ,trl_type1 VARCHAR(6) NULL
 ,evt_carrier VARCHAR(8) NULL
 ,mov_number INT NULL
 ,ord_availabledate DATETIME NULL
 ,ord_stopcount TINYINT NULL
 ,ord_totalcharge FLOAT NULL
 ,ord_totalweight INT NULL
 ,ord_length MONEY NULL
 ,ord_width MONEY NULL
 ,ord_height MONEY NULL
 ,ord_totalmiles INT NULL
 ,ord_number CHAR(12) NULL
 ,o_city INT NULL
 ,d_city INT NULL
 ,lgh_priority VARCHAR(6) NULL
 ,lgh_outstatus VARCHAR(20) NULL
 ,lgh_instatus VARCHAR(20) NULL
 ,lgh_priority_name VARCHAR(20) NULL
 ,ord_subcompany VARCHAR(20) NULL
 ,trl_type1_name VARCHAR(20) NULL
 ,lgh_class1 VARCHAR(20) NULL
 ,lgh_class2 VARCHAR(20) NULL
 ,lgh_class3 VARCHAR(20) NULL
 ,lgh_class4 VARCHAR(20) NULL
 --PTS 37075 SGB changed FROM VARCHAR(7) to (20) AND changed name for clarification
 --,Company VARCHAR(7) NULL
 ,SubCompanyLabel VARCHAR(20) NULL
 ,trllabel1 VARCHAR(20) NULL
 ,revlabel1 VARCHAR(20) NULL
 ,revlabel2 VARCHAR(20) NULL
 ,revlabel3 VARCHAR(20) NULL
 ,revlabel4 VARCHAR(20) NULL
 ,ord_bookedby CHAR(20) NULL
 ,dw_rowstatus CHAR(10) NULL
 ,lgh_primary_pup VARCHAR(13) NULL
 ,triptime FLOAT NULL
 ,ord_totalweightunits VARCHAR(6) NULL
 ,ord_lengthunit VARCHAR(6) NULL
 ,ord_widthunit VARCHAR(6) NULL
 ,ord_heightunit VARCHAR(6) NULL
 ,loadtime FLOAT NULL
 ,unloadtime FLOAT NULL
 ,unloaddttm DATETIME NULL
 ,unloaddttm_early DATETIME NULL
 ,unloaddttm_late DATETIME NULL
 ,ord_totalvolume INT NULL
 ,ord_totalvolumeunits VARCHAR(6) NULL
 ,washstatus VARCHAR(1) NULL
 ,f_state VARCHAR(6) NULL
 ,l_state VARCHAR(6) NULL
 ,evt_driver1_id VARCHAR(8) NULL
 ,evt_driver2_id VARCHAR(8) NULL
 ,ref_type VARCHAR(6) NULL
 ,ref_number VARCHAR(30) NULL
 ,d_address1 VARCHAR(40) NULL
 ,d_address2 VARCHAR(40) NULL
 ,ord_remark VARCHAR(254) NULL
 ,mpp_teamleader VARCHAR(6) NULL
 ,lgh_dsp_date DATETIME NULL
 ,lgh_geo_date DATETIME NULL
 ,ordercount SMALLINT NULL
 ,npup_cmpid VARCHAR(8) NULL
 ,npup_cmpname VARCHAR(30) NULL
 ,npup_ctyname VARCHAR(25) NULL
 ,npup_state VARCHAR(6) NULL
 ,npup_arrivaldate DATETIME NULL
 ,ndrp_cmpid VARCHAR(8) NULL
 ,ndrp_cmpname VARCHAR(30) NULL
 ,ndrp_ctyname VARCHAR(25) NULL
 ,ndrp_state VARCHAR(6) NULL
 ,ndrp_arrivaldate DATETIME NULL
 ,can_ld_expires DATETIME NULL
 ,xdock INT NULL
 ,feetavailable SMALLINT NULL
 ,opt_trc_type4 VARCHAR(6) NULL
 ,opt_trc_type4_label VARCHAR(20) NULL
 ,opt_trl_type4 VARCHAR(6) NULL
 ,opt_trl_type4_label VARCHAR(20) NULL
 ,ord_originregion1 VARCHAR(6) NULL
 ,ord_originregion2 VARCHAR(6) NULL
 ,ord_originregion3 VARCHAR(6) NULL
 ,ord_originregion4 VARCHAR(6) NULL
 ,ord_destregion1 VARCHAR(6) NULL
 ,ord_destregion2 VARCHAR(6) NULL
 ,ord_destregion3 VARCHAR(6) NULL
 ,ord_destregion4 VARCHAR(6) NULL
 ,npup_departuredate DATETIME NULL
 ,ndrp_departuredate DATETIME NULL
 ,ord_FROMorder VARCHAR(12) NULL
 ,c_lgh_type1 VARCHAR(20) NULL
 ,lgh_type1_label VARCHAR(20) NULL
 ,c_lgh_type2 VARCHAR(20) NULL
 ,lgh_type2_label VARCHAR(20) NULL
 ,lgh_tm_status VARCHAR(6) NULL
 ,lgh_tour_number INT NULL
 ,extrainfo1 VARCHAR(255) NULL
 ,extrainfo2 VARCHAR(255) NULL
 ,extrainfo3 VARCHAR(255) NULL
 ,extrainfo4 VARCHAR(255) NULL
 ,extrainfo5 VARCHAR(255) NULL
 ,extrainfo6 VARCHAR(255) NULL
 ,extrainfo7 VARCHAR(255) NULL
 ,extrainfo8 VARCHAR(255) NULL
 ,extrainfo9 VARCHAR(255) NULL
 ,extrainfo10 VARCHAR(255) NULL
 ,extrainfo11 VARCHAR(255) NULL
 ,extrainfo12 VARCHAR(255) NULL
 ,extrainfo13 VARCHAR(255) NULL
 ,extrainfo14 VARCHAR(255) NULL
 ,extrainfo15 VARCHAR(255) NULL
 ,o_cmp_geoloc VARCHAR(50) NULL
 ,d_cmp_geoloc VARCHAR(50) NULL
 ,mpp_fleet VARCHAR(6) NULL
 ,mpp_fleet_name VARCHAR(20) NULL
 ,next_stp_event_code VARCHAR(6) NULL
 ,next_stop_of_total VARCHAR(10) NULL
 ,lgh_comment VARCHAR(255) NULL
 ,lgh_earliest_pu DATETIME NULL
 ,lgh_latest_pu DATETIME NULL
 ,lgh_earliest_unl DATETIME NULL
 ,lgh_latest_unl DATETIME NULL
 ,lgh_miles INT NULL
 ,lgh_linehaul FLOAT NULL
 ,evt_latedate DATETIME NULL
 ,lgh_ord_charge FLOAT NULL
 ,lgh_act_weight FLOAT NULL
 ,lgh_est_weight FLOAT NULL
 ,lgh_tot_weight FLOAT NULL
 ,lgh_outstat VARCHAR(6) NULL
 ,lgh_max_weight_exceeded CHAR(1) NULL
 ,lgh_reftype VARCHAR(6) NULL
 ,lgh_refnum VARCHAR(30) NULL
 ,trctype1 VARCHAR(20) NULL
 ,trc_type1name VARCHAR(20) NULL
 ,trctype2 VARCHAR(20) NULL
 ,trc_type2name VARCHAR(20) NULL
 ,trctype3 VARCHAR(20) NULL
 ,trc_type3name VARCHAR(20) NULL
 ,trctype4 VARCHAR(20) NULL
 ,trc_type4name VARCHAR(20) NULL
 ,lgh_etaalert1 CHAR(1) NULL
 ,lgh_detstatus INT NULL
 ,lgh_tm_statusname VARCHAR(20) NULL
 ,ord_billto VARCHAR(8) NULL
 ,cmp_name VARCHAR(100) NULL
 ,lgh_carrier VARCHAR(64) NULL
 ,TotalCarrierPay MONEY NULL
 ,lgh_hzd_cmd_class VARCHAR(8) NULL
 ,lgh_washplan VARCHAR(20) NULL
 ,fgt_length FLOAT NULL
 ,fgt_width FLOAT NULL
 ,fgt_height FLOAT NULL
 ,lgh_originzip VARCHAR(10) NULL
 ,lgh_destzip VARCHAR(10) NULL
 ,ord_company VARCHAR(12) NULL
 ,origin_servicezone VARCHAR(20) NULL
 ,o_servicezone_t VARCHAR(20) NULL
 ,origin_servicearea VARCHAR(20) NULL
 ,o_servicearea_t VARCHAR(20) NULL
 ,origin_servicecenter VARCHAR(20) NULL
 ,o_servicecenter_t VARCHAR(20) NULL
 ,origin_serviceregion VARCHAR(20) NULL
 ,o_serviceregion_t VARCHAR(20) NULL
 ,dest_servicezone VARCHAR(20) NULL
 ,dest_servicezone_t VARCHAR(20) NULL
 ,dest_servicearea VARCHAR(20) NULL
 ,dest_servicearea_t VARCHAR(20) NULL
 ,dest_servicecenter VARCHAR(20) NULL
 ,dest_servicecenter_t VARCHAR(20) NULL
 ,dest_serviceregion VARCHAR(20) NULL
 ,dest_serviceregion_t VARCHAR(20) NULL
 ,lgh_204status VARCHAR(30) NULL
 -- PTS 29347 -- BL (start)
 ,origin_cmp_lat DECIMAL(14,6) NULL
 ,origin_cmp_long DECIMAL(14,6) NULL
 ,origin_cty_lat DECIMAL(14,6) NULL
 ,origin_cty_long DECIMAL(14,6) NULL
 -- PTS 29347 -- BL (END)
 ,lgh_route VARCHAR(15) NULL
 ,lgh_booked_revtype1 VARCHAR(12) NULL
 ,lgh_permit_status VARCHAR(6) NULL
 ,lgh_permit_status_t VARCHAR(20) NULL
 ,lgh_204date DATETIME NULL
 -- PTS 33890 BDH 9/13/06 start
 ,next_ndrp_cmpid VARCHAR(8) null
 ,next_ndrp_cmpname VARCHAR(30) null
 ,next_ndrp_ctyname VARCHAR(25) null
 ,next_ndrp_state VARCHAR(6) null
 ,next_ndrp_arrivaldate DATETIME null
 -- PTS 33890 BDH 9/13/06 start
 -- PTS 33913 EMK 10/03/06 start
 ,ord_bookdate DATETIME null
 -- PTS 33913 EMK 10/03/06 END
 ,lgh_ace_status_name VARCHAR(20) null --PTS 35199 AROSS
 ,manualcheckcalltime DATETIME null --PTS 35708 vjh
 ,evt_earlydate DATETIME null
 ,TimeZoneAdjMins INT null --PTS35747
 ,locked_by VARCHAR(20) null -- 36717
 ,session_date DATETIME null -- 36717
 ,ord_cbp CHAR(1) null -- PTS 38765
 ,lgh_ace_status VARCHAR(6) null
 ,trc_latest_ctyst VARCHAR(30) null
 ,trc_latest_cmpid VARCHAR(8) null
 ,trc_last_mobcomm_received DATETIME null
 ,trc_mobcomm_type VARCHAR(20) null
 ,trc_nearest_mobcomm_nmstct VARCHAR(20) null -- PTS 38765
 ,next_stop_ref_number VARCHAR(30) null --PTS 38138 JJF 20080122
 ,compartment_loaded INT null --PTS29383 MBR 08/17/05 40762
 ,trc_lastpos_lat FLOAT null -- PTS 42829 - DJM
 ,trc_lastpos_long FLOAT null -- PTS 42829 - DJM
 ,fsc_fuel_surcharge MONEY null --PTS 41795 JJF 20080506
 /* 08/27/2008 MDH PTS 42301: <<BEGIN>> */
 ,ord_ref_type_2 VARCHAR(6) null
 ,ord_ref_number_2 VARCHAR(30) null
 ,ord_ref_type_3 VARCHAR(6) null
 ,ord_ref_number_3 VARCHAR(30) null
 ,ord_ref_type_4 VARCHAR(6) null
 ,ord_ref_number_4 VARCHAR(30) null
 ,ord_ref_type_5 VARCHAR(6) null
 ,ord_ref_number_5 VARCHAR(30) null
 /* 08/27/2008 MDH PTS 42301: <<END>> */
 ,ord_booked_revtype1 VARCHAR(12) null -- PTS 47850
 ,lgh_total_mov_bill_miles INT null /* 07/30/2009 MDH PTS 42281: Added */
 ,lgh_total_mov_miles INT null /* 07/30/2009 MDH PTS 42281: Added */
 /* 07/22/2009 MDH PTS 42293: <<BEGIN>> */
 ,num_legs INT null
 ,num_ords INT null
 ,pyt_linehaul VARCHAR(6) null
 ,pyd_accessorials MONEY null
 ,pyd_fuel MONEY null
 ,pyd_linehaul MONEY null
 ,pyd_total MONEY null /* 09/08/2009 MDH PTS 42293: Added */
 ,all_ord_revenue_pay MONEY null /* 09/08/2009 MDH PTS 42293: Added */
 ,all_ord_totalcharge MONEY null /* 09/08/2009 MDH PTS 42293: Added */
 ,ord_accessorials MONEY null
 ,ord_fuel MONEY null
 ,ord_linehaul MONEY null
 ,ord_total_charge MONEY null
 ,ord_or_leg VARCHAR(10) null -- Will be Order or Segment
 ,ord_percent DECIMAL (8,2) null -- 100% for one order/leg otherwise computed based ON miles
 /* 07/22/2009 MDH PTS 42293: <<END>> */
 ,ma_transaction_id bigint null -- RE - PTS #48722
 ,ma_tour_number INT null -- RE - PTS #48722
 ,ma_tour_sequence TINYINT null -- RE - PTS #48722
 ,ma_tour_max_sequence TINYINT null -- RE - PTS #48722
 ,ma_trc_number VARCHAR(8) null -- RE - PTS #48722
 ,ma_mpp_id VARCHAR(8) null -- RE - PTS #48722
 ,mile_overage_message VARCHAR(64) NULL /* 08/31/2009 MDH PTS 42281: Added */
 ,lgh_raildispatchstatus VARCHAR(6) NULL --PTS46536 MBR
 ,car_204tENDer CHAR(1) NULL --PTS46536 MBR
 ,car_204UPDATE VARCHAR(3) NULL --PTS46536 MBR
 ,lgh_car_rate MONEY NULL --PTS42845 MBR
 ,lgh_car_charge MONEY NULL --PTS42845 MBR
 ,lgh_car_accessorials DECIMAL(12, 4) NULL --PTS42845 MBR
 ,lgh_car_totalcharge MONEY NULL --PTS42845 MBR
 ,lgh_recommENDed_car_id VARCHAR(8) NULL --PTS42845 MBR
 ,lgh_spot_rate CHAR(1) NULL --PTS42845 MBR
 ,lgh_edi_counter VARCHAR(30) NULL --PTS42845 MBR
 ,lgh_ship_status VARCHAR(6) NULL --PTS42845 MBR
 ,lgh_faxemail_created CHAR(1) NULL --PTS42845 MBR
 ,lgh_externalrating_miles INT NULL --PTS42845 MBR
 ,lgh_acc_fsc MONEY NULL --PTS42845 MBR
 ,lgh_chassis VARCHAR(13) NULL --JLB PTS 49323
 ,lgh_chassis2 VARCHAR(13) NULL --JLB PTS 49323
 ,lgh_dolly VARCHAR(13) NULL --JLB PTS 49323
 ,lgh_dolly2 VARCHAR(13) NULL --JLB PTS 49323
 ,lgh_trailer3 VARCHAR(13) NULL --JLB PTS 49323
 ,lgh_trailer4 VARCHAR(13) NULL --JLB PTS 49323
 ,ord_order_source VARCHAR(6) NULL /* 08/19/2010 MDH PTS 52714: Added */
 ,ud_column1 VARCHAR(255) -- PTS 51911 SGB User Defined column
 ,ud_column1_t VARCHAR(30) -- PTS 51911 SGB User Defined column header
 ,ud_column2 VARCHAR(255) -- PTS 51911 SGB User Defined column
 ,ud_column2_t VARCHAR(30) -- PTS 51911 SGB User Defined column header
 ,ud_column3 VARCHAR(255) -- PTS 51911 SGB User Defined column
 ,ud_column3_t VARCHAR(30) -- PTS 51911 SGB User Defined column header
 ,ud_column4 VARCHAR(255) -- PTS 51911 SGB User Defined column
 ,ud_column4_t VARCHAR(30) -- PTS 51911 SGB User Defined column header
 ,o_tzminutes INT	NULL	/* 04/19/2012 MDH PTS 60772: Added */
 ,d_tzminutes INT	NULL
 ,stp_custdeliverydate DATETIME	NULL --PTS52228 MBR 06/27/12
 ,appt_date DATETIME	NULL --PTS52228 MBR 06/27/12
 ,Direct_route_status1 VARCHAR(6) --PTS 66628 KPM 2/5/2013 
 )

 /*
GENERAL INFO MASTER LOOKUP BEGIN
ALL GI LOOKUPS FOR THIS PROC GO HERE, ONE QUERY TO GI IN THE ENTIRE PROC.
*/
DECLARE @GI_VALUES_TO_LOOKUP TABLE (gi_name VARCHAR(30) PRIMARY KEY)
DECLARE @GIKEY TABLE (gi_name VARCHAR(30) PRIMARY KEY, gi_string1 VARCHAR(60), gi_string2 VARCHAR(60), gi_string3 VARCHAR(60), gi_string4 VARCHAR(60), gi_integer1 INT, gi_integer2 INT, gi_integer3 INT, gi_integer4 INT)

INSERT @GI_VALUES_TO_LOOKUP
        ( gi_name )
VALUES
      ('ACS_Exclude_ACC_PayType')
     ,('MatchAdviceInterface')
     ,('MatchAdviceMultiCompany')
     ,('CityLatLongUnits')
     ,('AppianDirectRoute')
     ,('PWSumOrdExtraInfo')
     ,('PlnWrkshtLateWarnMode')
     ,('PWExtraInfoLocation')
     ,('DisplayPENDingOrders')
     ,('LocalTimeOption')
     ,('UseShowAsShipperConsignee')
     ,('PlnWrkshtRef')
     ,('ACSInfoInWorksheet')
     ,('ShowDeliveryAndAppointment')
     ,('UseUnknownCmpId')
     ,('LghActiveUntilDepCompNBC')
     ,('ServiceLocalization')
     ,('ManualCheckCall')
     ,('OutboundRefNumbers')
     ,('ServiceRegionRevType')
     ,('RowSecurity')
     ,('NextDrpRefTypeOnPlanningWst')
     ,('FSCChargeTypes')     
     ,('UD_STOP_LEG_COLUMNS')
     ,('UD_STOP_LEG_FUNCTIONS')
     ,('Inbound214Appointment')
     ,('OBV_include_FD_LWH')

INSERT @GIKEY 
SELECT 
  gi_name
 ,gi_string1
 ,gi_string2
 ,gi_string3
 ,gi_string4
 ,gi_integer1
 ,gi_integer2
 ,gi_integer3
 ,gi_integer4
FROM (
      SELECT 
        gvtlu.gi_name
       ,g.gi_string1
       ,g.gi_string2
       ,g.gi_string3 
       ,g.gi_string4
       ,gi_integer1
       ,gi_integer2
       ,gi_integer3
       ,gi_integer4
       --What we're doing here is checking the date of the generalInfo row in case there are multiples.
       --This will order the rows in descending date order with the following exceptions.
       --Future dates are dropped to last priority by moving to less than the apocalypse.
       --Nulls are moved to second to last priority by using the apocalypse.
       --Everything else is ordered descending.
       --We then take the "newest".
       ,ROW_NUMBER() OVER (PARTITION BY gvtlu.gi_name ORDER BY CASE WHEN g.gi_datein > GETDATE() THEN '1/1/1949' ELSE ISNULL(g.gi_datein, '1/1/1950') END DESC) RN 
      FROM 
        @GI_VALUES_TO_LOOKUP gvtlu
          LEFT OUTER JOIN 
        dbo.generalinfo g on gvtlu.gi_name = g.gi_name) subQuery
WHERE
  RN = 1 --   <---This is how we take the top 1.


  

--BEGIN PTS 56436 SPN
SELECT 
  @ACS_Exclude_ACC_PayType = ''',' + gi_string1 + ','''
FROM 
  @GIKEY
WHERE 
  gi_name = 'ACS_Exclude_ACC_PayType'
--END PTS 56436 SPN


-- RE - PTS #52017 BEGIN
SELECT   
  @null_varchar8 = NULL
 ,@null_int = NULL
 ,@null_varchar100 = NULL

SELECT   
  @MatchAdviceInterface = LEFT(ISNULL(gi_string1, 'N'), 1)
 ,@Check = ISNULL(gi_integer1, 60)
FROM   
  @GIKEY
WHERE   
  gi_name = 'MatchAdviceInterface'

SELECT  
  @MatchAdviceMultiCompany = LEFT(ISNULL(gi_string1, 'N'), 1)
FROM   
  @GIKEY
WHERE   
  gi_name = 'MatchAdviceMultiCompany'
 
SELECT  
  @citylatlongunits = LEFT(gi_string1, 1)
FROM   
  @GIKEY
WHERE   
  gi_name = 'CityLatLongUnits'
 
SELECT  
  @directroute = LEFT(gi_string1, 1)
FROM   
  @GIKEY
WHERE   
  gi_name = 'AppianDirectRoute'
 
EXEC @tmwuser = dbo.gettmwuser_fn

SET @DefaultCompanyID = ISNULL(@DefaultCompanyID, '')

IF @MatchAdviceInterface = 'Y'
BEGIN
  IF @MatchAdviceMultiCompany = 'Y'
  BEGIN
    SELECT   
      @DefaultCompanyID = ISNULL(ttsusers.usr_type1, @DefaultCompanyID)
    FROM  
      dbo.ttsusers
    WHERE   
      @tmwuser IN (usr_userid, usr_windows_userid)
    
    SELECT TOP 1
      @ma_transaction_id = transaction_id
     ,@ma_inserted_date = inserted_date
    FROM   
      dbo.LastMATransactionID
    WHERE   
      company_id = @DefaultCompanyID
    ORDER BY 
      inserted_date DESC
   END
   ELSE
   BEGIN
     SELECT TOP 1
       @ma_transaction_id = transaction_id
      ,@ma_inserted_date = inserted_date
      FROM   
        dbo.LastMATransactionID
      ORDER BY 
        inserted_date DESC
   END

   IF ISNULL(@ma_transaction_id, -1) = -1
   BEGIN
     SET @ma_transaction_id = NULL
   END
   ELSE
   BEGIN
     IF DATEDIFF(mi, @ma_inserted_date, GETDATE()) > @Check
     BEGIN
       SET @ma_transaction_id = NULL
     END
   END
END
ELSE
BEGIN
   SET @ma_transaction_id = NULL
END
-- RE - PTS #52017 END

SELECT 
  @Apocalypse = CONVERT(DATETIME,'20491231 23:59:59')

SELECT 
  @PWSumOrdExtraInfo = LEFT(UPPER(ISNULL(gi_string1,'N')),1)
FROM 
  @GIKEY
WHERE 
  gi_name = 'PWSumOrdExtraInfo'

SET @hoursback = -1 * ABS(@hoursback);
SET @hoursout = ABS(@hoursout);


IF @startdate > '01/01/50'
BEGIN
  SET @hoursbackdate = DATEADD(dd, DATEDIFF(dd, 0, @startdate), 0);
  --PTS 54465 JJF 20101216 - last included date off by 1
  SET @hoursoutdate = DATEADD(dd, DATEDIFF(dd, 0, @startdate) + ABS(@daysout) + 1, 0);
  --END PTS 54465 JJF 20101216 - last included date off by 1
END
ELSE
BEGIN
  --PTS 57376 JJF 20110919
  /* strip time off when using days, don't when using hours */
  SET @hoursBackDate = CASE 
                         WHEN @daterangemode = 0 THEN DATEADD(hour, @hoursback, GETDATE())
										     ELSE DATEADD(dd,  DATEDIFF(dd, 0, @CurrentDate) - ABS(@daysstartoffset), 0)
											 END;

  SET @hoursoutDate = CASE 
                        WHEN @daterangemode = 0 THEN DATEADD(hour, @hoursout, GETDATE())
									      ELSE DATEADD(dd,  DATEDIFF(dd, 0, @CurrentDate) + ABS(@daysendoffset) + 1, 0)
										  END;

  SET @CurrentDate =  GETDATE();

  --END PTS 57376 JJF 20110919
END

-- RE - 10/15/02 - PTS #15024
SELECT 
  @LateWarnMode = gi_string1 
FROM 
  @GIKEY 
WHERE 
  gi_name = 'PlnWrkshtLateWarnMode'

-- PTS 25895 JLB need to add the ability to determine WHERE extrainfo comes FROM
SELECT 
  @PWExtraInfoLocation = UPPER(ISNULL(gi_string1,'ORDERHEADER'))
FROM 
  @GIKEY
WHERE 
  gi_name = 'PWExtraInfoLocation'

-- LOR PTS# 28465
SELECT 
  @pENDing_statuses = UPPER(RTRIM(LTRIM(ISNULL(gi_string2, ''))))
FROM 
  @GIKEY
WHERE 
  gi_name = 'DisplayPENDingOrders' AND gi_string1 = 'Y'

-- LOR
IF @miles_min = 0 
  SET @miles_min = -1000

/* 35747 Is local time option set (GI INTeger1 is the city code of the dispatch office) */
SELECT 
  @V_GILocalTimeOption = UPPER(ISNULL(gi_string1,''))
FROM 
  @GIKEY 
WHERE 
  gi_name = 'LocalTimeOption'

/* 04/19/2012 MDH PTS 60772: Moved out of IF block, added v_LocalCityTZAdjMinutes */
/* IF server is in different time zone that dipatch office there may be a few hours of error going in AND out of DST */
SET @DSTCountryCode = 0 /* IF you want to work outside North America, set this value see proc ChangeTZ */
SET @InDSTFactor = CASE dbo.InDst(getdate(),@DSTCountryCode) WHEN 'Y' THEN 1 ELSE 0 END
SET @v_LocalCityTZAdjFactor = 0
EXEC getusertimezoneinfo @V_LocalGMTDelta OUTPUT,@v_LocalDSTCode OUTPUT,@V_LocalAddnlMins  OUTPUT
SELECT @v_LocalCityTZAdjMinutes =
   ((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins

IF @V_GILocalTimeOption = 'LOCAL'
BEGIN
  SET @v_LocalCityTZAdjFactor = ((@V_LocalGMTDelta + (@InDSTFactor * @v_LocalDSTCode)) * 60) +   @V_LocalAddnlMins
END
/* 35747 END */

--PTS 37075 SGB Added SELECT to get label name for company label
SELECT TOP 1 
  @SubCompanyLabel = userlabelname 
FROM 
  dbo.labelfile WITH (NOLOCK)
WHERE
  labeldefinition = 'Company'

--PTS32875 MBR 05/16/06
SELECT 
  @UseShowAsShipperConsignee = LEFT(UPPER(ISNULL(gi_string1, 'N')), 1)
FROM 
  @GIKEY
WHERE 
  gi_name = 'UseShowAsShipperConsignee'

--PTS38986 vjh 09/07/07
SELECT 
  @PlnWrkshtRefStr1 = LEFT(UPPER(ISNULL(gi_string1, 'N')), 1)
 ,@PlnWrkshtRefStr2 = ISNULL(gi_string2, 'stops')
 ,@PlnWrkshtRefStr3 = ISNULL(gi_string3, 'REF')
FROM 
  @GIKEY
WHERE 
  gi_name = 'PlnWrkshtRef'


/* 08/28/2009 MDH PTS 42293: Get ACS Info setting */
SELECT 
  @ACSInfo = LEFT(ISNULL(gi_string1, 'N'), 1) 
FROM 
  @GIKEY 
WHERE 
  gi_name = 'ACSInfoInWorksheet'


--PTS52228 MBR 06/27/12
SELECT 
  @ShowDeliveryAndAppointment = UPPER(LEFT(ISNULL(gi_string1, 'No'), 1))
FROM 
  @GIKEY
WHERE 
  gi_name = 'ShowDeliveryAndAppointment'

--PTS67320 MBR 02/20/13
SELECT 
  @UseUnknownCmpId = UPPER(LEFT(ISNULL(gi_string1, 'No'), 1))
FROM 
  @GIKEY
WHERE 
  gi_name = 'UseUnknownCmpId'

--JLB PTS 33012
SELECT 
  @v_LghActiveUntilDepCompNBC = LEFT(ISNULL(gi_string1, 'N'), 1)
FROM 
  @GIKEY
WHERE 
  gi_name = 'LghActiveUntilDepCompNBC'

SELECT 
  @localization = UPPER(LTRIM(RTRIM(ISNULL(gi_string1,'N')))) 
FROM 
  @GIKEY 
WHERE 
  gi_name = 'ServiceLocalization'

/* PTS 36608 - vjh - Check setting used control use of the manual check call times in the Planning
 worksheet AND Tripfolder. To eliminate potential performance issues for customers
 not using this feature - SQL 2000 ONLY
*/
SELECT 
  @ManualCheckCall = UPPER(LTRIM(RTRIM(ISNULL(gi_string1,'N')))) 
FROM 
  @GIKEY 
WHERE 
  gi_name = 'ManualCheckCall'

/* 08/27/2008 MDH PTS 42301: Check IF we're to have 5 reference number columns <<BEGIN>> */
SELECT 
  @IncludeRefNumbers = UPPER(RTRIM(LEFT(ISNULL (gi_String1,''), 1)))
FROM 
  @GIKEY
WHERE 
  gi_name = 'OutboundRefNumbers'

/*66651 BEGIN*/
DECLARE 
  @lfh_trltype1 VARCHAR(20)
 ,@LghPermitStatus VARCHAR(20)
 ,@lfh_revtype1 VARCHAR(20)
 ,@lfh_revtype2 VARCHAR(20)
 ,@lfh_revtype3 VARCHAR(20)
 ,@lfh_revtype4 VARCHAR(20)
 ,@lfh_lghtype1 VARCHAR(20)
 ,@lfh_lghtype2 VARCHAR(20)
 ,@lfh_trctype1 VARCHAR(20)
 ,@lfh_trctype2 VARCHAR(20)
 ,@lfh_trctype3 VARCHAR(20)
 ,@lfh_trctype4 VARCHAR(20)

SELECT TOP 1
  @lfh_trltype1 = trltype1
 ,@lfh_revtype1 = revtype1 
 ,@lfh_revtype2 = revtype2 
 ,@lfh_revtype3 = revtype3 
 ,@lfh_revtype4 = revtype4
 ,@lfh_lghtype1 = lghtype1 
 ,@lfh_lghtype2 = lghtype2
 ,@lfh_trctype1 = trctype1 
 ,@lfh_trctype2 = trctype2 
 ,@lfh_trctype3 = trctype3 
 ,@lfh_trctype4 = trctype4
 ,@LghPermitStatus = LghPermitStatus
FROM 
  dbo.labelfile_headers

--SELECT STATEMENT
SET @sql = 
  N'SELECT 
    l.lgh_number
   ,oh.ord_carrier
   ,l.cmp_id_start o_cmpid
   ,o_cmpname
   ,lgh_startcty_nmstct o_ctyname
   ,l.cmp_id_END d_cmpid
   , ' --Special CASE because next field is technically unknown at this point

IF @UseUnknownCmpId = 'Y'  
BEGIN   
  SET @sql = @sql + N's2.cmp_name ' --This will display AND alias as d_cmpname
END
SET @sql = @sql + N'
  d_cmpname
 ,lgh_ENDcty_nmstct d_ctyname '    
  
IF @UseShowAsShipperConsignee = 'Y'  
BEGIN  
  SET @sql = @sql + N'
   ,CASE WHEN ord_showshipper <> ord_shipper AND ord_showshipper <> ''UNKNOWN'' AND ord_showshipper is not null THEN ord_showshipper ELSE f_cmpid END
   ,CASE WHEN ord_showshipper <> ord_shipper AND ord_showshipper <> ''UNKNOWN'' AND ord_showshipper is not null THEN (SELECT cmp_name FROM dbo.company WITH (NOLOCK) WHERE cmp_id = ord_showshipper) ELSE f_cmpname END
   ,CASE WHEN ord_showshipper <> ord_shipper AND ord_showshipper <> ''UNKNOWN'' AND ord_showshipper is not null THEN (SELECT cty_nmstct FROM dbo.company WITH (NOLOCK) WHERE cmp_id = ord_showshipper) ELSE f_ctyname END
   ,CASE WHEN ord_showcons <> ord_consignee AND ord_showcons <> ''UNKNOWN'' AND ord_Showcons is not null THEN ord_showcons ELSE l_cmpid END
   ,CASE WHEN ord_showcons <> ord_consignee AND ord_showcons <> ''UNKNOWN'' AND ord_Showcons is not null THEN (SELECT cmp_name FROM dbo.company WITH (NOLOCK) WHERE cmp_id = ord_showcons) ELSE l_cmpname END
   ,CASE WHEN ord_showcons <> ord_consignee AND ord_showcons <> ''UNKNOWN'' AND ord_Showcons is not null THEN (SELECT cty_nmstct FROM dbo.company WITH (NOLOCK) WHERE cmp_id = ord_showcons) ELSE l_ctyname END '
END  
ELSE  
BEGIN  
  SET @sql = @sql + N'
   ,f_cmpid
   ,f_cmpname
   ,f_ctyname
   ,l_cmpid
   ,l_cmpname
   ,l_ctyname '  
END  
      
SET @sql = @sql + N'
 ,l.lgh_startdate
 ,l.lgh_ENDdate
 ,lgh_startstate o_state
 ,lgh_ENDstate d_state
 ,oh.ord_origin_earliestdate lgh_schdtearliest
 ,oh.ord_origin_latestdate lgh_schdtlatest
 ,l.cmd_code
 ,l.fgt_description
 ,cmd_count
 ,l.ord_hdrnumber
 ,evt_driver1_name evt_driver1
 ,evt_driver2_name evt_driver2
 ,lgh_tractor evt_tractor
 ,l.lgh_primary_trailer
 ,oh.trl_type1
 ,lgh_carrier evt_carrier
 ,l.mov_number
 ,oh.ord_availabledate
 ,l.ord_stopcount
 ,oh.ord_totalcharge
 ,l.ord_totalweight
 ,oh.ord_length
 ,oh.ord_width
 ,oh.ord_height
 ,l.ord_totalmiles ord_totalmiles
 ,CASE 
     WHEN ISNULL(UPPER(lgh_split_flag),''N'') IN (''S'', ''F'') THEN LEFT(rtrim(oh.ord_number)+''*'',12) 
     ELSE oh.ord_number 
  END ord_number
 ,l.lgh_startcity o_city
 ,l.lgh_ENDcity d_city
 ,l.lgh_priority
 ,lgh_outstatus_name lgh_outstatus
 ,lgh_instatus_name lgh_instatus
 ,lgh_priority_name
 ,(SELECT name FROM dbo.labelfile WITH (NOLOCK) WHERE l.ord_ord_subcompany = abbr AND labeldefinition = ''Company'') ord_subcompany
 --,NULL  ord_subcompany,
 ,trl_type1_name
 ,lgh_class1_name lgh_class1
 ,lgh_class2_name lgh_class2
 ,lgh_class3_name lgh_class3
 ,lgh_class4_name lgh_class4
 ,''' + @SubcompanyLabel + ''' SubCompanyLabel
 ,''' + @lfh_TrlType1 + N''' trllabel1
 ,''' + @lfh_RevType1 + N''' revlabel1
 ,''' + @lfh_RevType2 + N''' revlabel2
 ,''' + @lfh_RevType3 + N''' revlabel3
 ,''' + @lfh_RevType4 + N''' revlabel4
 ,oh.ord_bookedby
 ,CONVERT(CHAR(10),'''') dw_rowstatus
 ,lgh_primary_pup
 ,ISNULL(ord_loadtime, 0) + ISNULL(ord_unloadtime, 0) + ISNULL(ord_drivetime, 0) triptime
 ,ord_totalweightunits
 ,ord_lengthunit
 ,ord_widthunit
 ,ord_heightunit
 ,ord_loadtime loadtime
 ,ord_unloadtime unloadtime
 ,ord_completiondate unloaddttm
 ,ord_dest_earliestdate unloaddttm_early
 ,ord_dest_latestdate unloaddttm_late
 ,l.ord_totalvolume
 ,ord_totalvolumeunits
 ,washstatus
 ,f_state
 ,l_state
 ,l.lgh_driver1 evt_driver1_id
 ,l.lgh_driver2 evt_driver2_id
 ,l.ref_type
 ,l.ref_number
 ,d_address1
 ,d_address2
 ,ord_remark
 ,l.mpp_teamleader
 ,lgh_dsp_date
 ,lgh_geo_date
 ,ordercount
 ,npup_cmpid
 ,npup_cmpname
 ,npup_ctyname
 ,npup_state
 ,npup_arrivaldate
 ,ndrp_cmpid
 ,ndrp_cmpname
 ,ndrp_ctyname
 ,ndrp_state
 ,ndrp_arrivaldate
 ,ISNULL(l.can_ld_expires,''19000101'') can_ld_expires
 ,xdock
 ,lgh_feetavailable feetavailable
 ,opt_trc_type4
 ,opt_trc_type4_label
 ,opt_trl_type4
 ,opt_trl_type4_label
 ,lgh_startregion1 ord_originregion1
 ,lgh_startregion2 ord_originregion2
 ,lgh_startregion3 ord_originregion3
 ,lgh_startregion4 ord_originregion4
 ,lgh_ENDregion1 ord_destregion1
 ,lgh_ENDregion2 ord_destregion2
 ,lgh_ENDregion3 ord_destregion3
 ,lgh_ENDregion4 ord_destregion4
 , npup_departuredate
 ,ndrp_departuredate
 ,ord_FROMorder
 ,c_lgh_type1
 ,''' + @lfh_LghType1 + N''' lgh_type1_label
 ,c_lgh_type2
 ,''' + @lfh_LghType2 + N''' lgh_type2_label
 ,lgh_tm_status
 ,lgh_tour_number '
  
IF @PWExtraInfoLocation = 'ORDERHEADER'  
BEGIN  
  SET @sql = @sql + N'
   ,ord_extrainfo1
   ,ord_extrainfo2
   ,ord_extrainfo3
   ,ord_extrainfo4
   ,ord_extrainfo5
   ,ord_extrainfo6
   ,ord_extrainfo7
   ,ord_extrainfo8
   ,ord_extrainfo9
   ,ord_extrainfo10
   ,ord_extrainfo11
   ,ord_extrainfo12
   ,ord_extrainfo13
   ,ord_extrainfo14
   ,ord_extrainfo15 '  
END  
ELSE  
BEGIN  
  SET @sql = @sql + N'
   ,lgh_extrainfo1
   ,lgh_extrainfo2
   ,lgh_extrainfo3
   ,lgh_extrainfo4
   ,lgh_extrainfo5
   ,lgh_extrainfo6
   ,lgh_extrainfo7
   ,lgh_extrainfo8
   ,lgh_extrainfo9
   ,lgh_extrainfo10
   ,lgh_extrainfo11
   ,lgh_extrainfo12
   ,lgh_extrainfo13
   ,lgh_extrainfo14
   ,lgh_extrainfo15 '  
END  
  
SET @sql = @sql + N'
 ,o_cmp_geoloc
 ,d_cmp_geoloc
 ,l.mpp_fleet
 ,mpp_fleet_name
 ,next_stp_event_code
 ,next_stop_of_total
 ,l.lgh_comment
 ,s1.stp_schdtearliest lgh_earliest_pu
 ,s1.stp_schdtlatest lgh_latest_pu
 ,s2.stp_schdtearliest lgh_earliest_unl
 ,s2.stp_schdtlatest lgh_latest_unl
 --,(SELECT SUM(stp_lgh_mileage) FROM dbo.stops s WITH (NOLOCK) WHERE s.lgh_number = l.lgh_number) lgh_miles
 ,NULL lgh_miles
 ,lgh_linehaul '  
  
--IF @LateWarnMode = 'EVENT'  
-- BEGIN  
--  SET @sql = @sql + N'ISNULL((SELECT MIN(evt_latedate) FROM dbo.event e WITH (NOLOCK), stops s WITH (NOLOCK) WHERE e.stp_number = s.stp_number AND '    
--  SET @sql = @sql + N's.lgh_number = l.lgh_number AND e.evt_status = ''OPN''), ''20491231'') evt_latedate, '  
-- END   
--ELSE IF @LateWarnMode = 'ARRIVALDEPARTURE'   
-- BEGIN   
--  SET @sql = @sql + N'ISNULL((SELECT MIN(evt_latedate) FROM dbo.event e WITH (NOLOCK), stops s WITH (NOLOCK) WHERE e.stp_number = s.stp_number AND '  
--  SET @sql = @sql + N's.lgh_number = l.lgh_number AND ISNULL(e.evt_departure_status, ''OPN'') = ''OPN''), ''20491231'') evt_latedate, '   END  
--ELSE   
  SET @sql = @sql + N'
   ,null evt_latedate '  --,''20491231'' evt_latedate ' 
  
SET @sql = @sql + N'
 ,lgh_ord_charge
 ,lgh_act_weight
 ,lgh_est_weight
 ,lgh_tot_weight
 ,lgh_outstatus lgh_outstat
 ,l.lgh_max_weight_exceeded
 ,lgh_reftype,lgh_refnum
 ,''' + @lfh_trctype1 + N'''
 ,l.trc_type1name
 ,''' + @lfh_trctype2 + N'''
 ,l.trc_type2name  
 ,''' + @lfh_trctype3 + N'''
 ,l.trc_type3name
 ,''' + @lfh_trctype4 + N'''
 ,l.trc_type4name 
 ,l.lgh_etaalert1
 ,ISNULL(lgh_detstatus,0) lgh_detstatus
 ,l.lgh_tm_statusname
 ,l.ord_billto
 ,company.cmp_name
 --,(SELECT car_name FROM dbo.carrier WITH (NOLOCK) WHERE car_id = l.lgh_carrier) lgh_carrier
 ,''UNKNOWN'' lgh_carrier
 --,ISNULL((SELECT SUM(pyd_amount) FROM dbo.paydetail WITH (NOLOCK) WHERE paydetail.asgn_id = l.lgh_carrier AND paydetail.asgn_type = ''CAR'' AND paydetail.lgh_number = l.lgh_number AND paydetail.mov_number = l.mov_number),0) TotalCarrierPay
 ,0 TotalCarrierPay
 ,lgh_hzd_cmd_class
 ,l.lgh_washplan 
 --,(SELECT MAX(fgt_length) FROM dbo.freightdetail WITH (NOLOCK) INNER JOIN stops WITH (NOLOCK) ON freightdetail.stp_number = stops.stp_number WHERE l.lgh_number = stops.lgh_number) as fgt_length    
 --,(SELECT MAX(fgt_width) FROM dbo.freightdetail WITH (NOLOCK) INNER JOIN stops WITH (NOLOCK) ON freightdetail.stp_number = stops.stp_number WHERE l.lgh_number = stops.lgh_number) as fgt_width
 --,(SELECT MAX(fgt_height) FROM dbo.freightdetail WITH (NOLOCK) INNER JOIN stops WITH (NOLOCK) ON freightdetail.stp_number = stops.stp_number WHERE l.lgh_number = stops.lgh_number) as fgt_height
 ,NULL fgt_length    
 ,NULL fgt_width
 ,NULL fgt_height
 ,lgh_originzip
 ,lgh_destzip
 ,l.ord_company
 ,''UNKNOWN'' origin_servicezone
 ,''ServiceZone'' o_servicezone_t
 ,''UNKNOWN'' origin_servicearea
 ,''ServiceArea'' o_servicearea_t
 ,''UNKNOWN'' origin_servicecenter
 ,''ServiceCenter'' o_servicecenter_t
 ,''UNKNOWN'' origin_serviceregion
 ,''ServiceRegion'' o_serviceregion_t
 ,''UNKNOWN'' dest_servicezone
 ,''ServiceZone'' dest_servicezone_t
 ,''UNKNOWN'' dest_servicearea
 ,''ServiceArea'' dest_servicearea_t
 ,''UNKNOWN'' dest_servicecenter
 ,''ServiceCenter'' dest_servicecenter_t
 ,''UNKNOWN'' dest_serviceregion
 ,''ServiceRegion'' dest_serviceregion_t
 ,l.lgh_204status
 ,CAST(COALESCE(ocomp.cmp_latseconds,0)/3600 AS DECIMAL(14,6)) as origin_cmp_lat
 ,CAST(COALESCE(ocomp.cmp_longseconds,0)/3600 AS DECIMAL(14,6))as origin_cmp_long
 ,CAST(COALESCE(octy.cty_latitude,0) AS DECIMAL(14,6)) as origin_cty_lat
 ,CAST(COALESCE(octy.cty_longitude,0) AS DECIMAL(14,6)) as origin_cty_long
 ,lgh_route
 ,lgh_booked_revtype1
 ,ISNULL(l.lgh_permit_status, ''UNK'') lgh_permit_status
 ,''' + @LghPermitStatus + N''' lgh_permit_status_t
 ,l.lgh_204date
 ,next_ndrp_cmpid
 ,next_ndrp_cmpname
 ,next_ndrp_ctyname
 ,next_ndrp_state
 ,next_ndrp_arrivaldate
 ,ord_bookdate
 ,lgh_ace_status_name
 ,null'  
  
IF @LateWarnMode = 'ARRIVALDEPARTURE'   
BEGIN   
  SET @sql = @sql + N'
   ,ISNULL((SELECT MIN(evt_earlydate) 
            FROM 
              dbo.event e WITH (NOLOCK) 
                INNER JOIN 
              dbo.stops s WITH (NOLOCK) ON e.stp_number = s.stp_number
            WHERE 
              s.lgh_number = l.lgh_number 
                AND 
              ISNULL(e.evt_status, ''OPN'') = ''OPN''), ''20491231'') evt_earlydate '  
END  
ELSE   
BEGIN
  SET @sql = @sql + N',Null evt_earlydate '  
END
  
SET @sql = @sql + N'
 ,0 TimeZoneAdjMins
 ,ISNULL(dbo.locked_by_fn(l.mov_number),'''')
 ,ISNULL(dbo.locked_date_fn(l.mov_number)
 ,''01/01/1950 00:00:00'')
 ,ISNULL(oh.ord_cbp,''N'') CBPOrder
 ,ISNULL(l.lgh_ace_status,''UNK'') ACE_Status
 ,'''' trc_latest_ctyst
 ,'''' trc_latest_cmpid
 ,'''' trc_last_mobcomm_received
 ,'''' trc_mobcomm_type
 ,'''' trc_nearest_mobcomm_nmstct
 ,'''' next_stop_ref_number
 --,CASE WHEN (SELECT COUNT(*) FROM dbo.freight_by_compartment fbc WITH (NOLOCK) WHERE fbc.mov_number = l.mov_number AND (fbc.fbc_weight > 0 or fbc.fbc_volume > 0)) > 0 THEN 1 ELSE 0 END compartment_loaded
 ,0 compartment_loaded
 ,0 trc_lastpos_lat
 ,0 trc_lastpos_long
 ,0 fsc_fuel_surcharge '  
  
IF @IncludeRefNumbers= 'Y'  
BEGIN  
 SET @sql = @sql + N'
  ,ref2.ref_type
  ,ref2.ref_number
  ,ref3.ref_type
  ,ref3.ref_number
  ,ref4.ref_type
  ,ref4.ref_number
  ,ref5.ref_type
  ,ref5.ref_number '   
END  
ELSE  
BEGIN           
 SET @sql = @sql + N'
  ,null ord_ref_type_2
  ,null ord_ref_number_2
  ,null ord_ref_type_3
  ,null ord_ref_number_3
  ,null ord_ref_type_4
  ,null ord_ref_number_4
  ,null ord_ref_type_5
  ,null ord_ref_number_5 '   
END  
               
SET @sql = @sql + N'
 ,oh.ord_booked_revtype1
 ,l.lgh_total_mov_bill_miles
 ,l.lgh_total_mov_miles
 --,(SELECT COUNT (*) FROM dbo.legheader_active lha WITH (NOLOCK) WHERE lha.mov_number = l.mov_number) num_legs  
 ,0 num_legs
 --,(SELECT COUNT (*) FROM dbo.orderheader o WITH (NOLOCK) WHERE o.mov_number = oh.mov_number) num_ords
 ,0 num_ords '
   
IF @ACSInfo = 'Y'  
BEGIN  
  --SET @sql = @sql + N'CASE (SELECT COUNT(pyd_number) FROM dbo.paydetail WITH (NOLOCK) WHERE asgn_id = oh.ord_carrier '  
  --SET @sql = @sql + N'AND asgn_type = ''CAR'' AND lgh_number= l.lgh_number AND mov_number = l.mov_number AND pyt_itemcode = ''' + @pyt_linehaul + ''') '    
  --SET @sql = @sql + N'WHEN 0 THEN (SELECT MIN(pyt_itemcode) FROM dbo.paydetail WITH (NOLOCK) WHERE asgn_id = oh.ord_carrier '   
  --SET @sql = @sql + N'AND asgn_type = ''CAR'' AND lgh_number= l.lgh_number AND mov_number= l.mov_number AND pyt_itemcode IN (SELECT pyt_itemcode '   
  --SET @sql = @sql + N'FROM dbo.paytype WITH (NOLOCK) WHERE pyt_basis = ''LGH'')) ELSE ''' + @pyt_linehaul + ''' END pyt_linehaul,'  
      
      
  --SET @sql = @sql + N'ISNULL((SELECT SUM(ISNULL (pyd_amount, 0)) FROM dbo.PayDetail WITH (NOLOCK) '    
  --SET @sql = @sql + N'WHERE asgn_id = oh.ord_carrier AND asgn_type = ''CAR'' AND lgh_number= l.lgh_number '    
  --SET @sql = @sql + N'AND mov_number= l.mov_number AND pyt_itemcode = ''' + @pyt_accessorial + '''), 0) pyd_accessorial,'   
      
  --SET @sql = @sql + N'ISNULL((SELECT SUM(ISNULL (pyd_amount, 0)) FROM dbo.PayDetail WITH (NOLOCK) WHERE asgn_id = oh.ord_carrier '  
  --SET @sql = @sql + N'AND asgn_type = ''CAR'' AND lgh_number= l.lgh_number AND mov_number= l.mov_number AND pyt_itemcode = ''' + @pyt_fuelcost + '''), 0) pyd_fuel,'  
             
  --SET @sql = @sql + N'(SELECT SUM (pyd_amount) FROM dbo.paydetail WITH (NOLOCK) WHERE paydetail.mov_number = l.mov_number AND paydetail.ord_hdrnumber <> 0 '  
  --SET @sql = @sql + N'and CHARINDEX('','' + paydetail.pyt_itemcode + '','',' + @ACS_Exclude_ACC_Paytype + ')> 0) pyd_total,'  
            
  --SET @sql = @sql + N'(SELECT SUM (ISNULL(ord_revenue_pay,0)) FROM dbo.orderheader o WITH (NOLOCK) WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM dbo.stops WITH (NOLOCK) WHERE stops.mov_number = l.mov_number AND ord_hdrnumber <> 0)) ord_revenue_pay,' 
      
  --SET @sql = @sql + N'(SELECT SUM (ISNULL(ord_totalcharge,0)) FROM dbo.orderheader o WITH (NOLOCK) WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM dbo.stops WITH (NOLOCK) WHERE stops.mov_number = l.mov_number AND ord_hdrnumber <> 0)) ord_totalcharge,' 
            
  --SET @sql = @sql + N'(SELECT SUM (ISNULL(ord_accessorial_chrg,0)) FROM dbo.orderheader o WITH (NOLOCK) WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM dbo.stops WITH (NOLOCK) WHERE stops.mov_number = l.mov_number AND ord_hdrnumber <> 0)) ord_accessorial_chrg,'  
            
  --SET @sql = @sql + N'(SELECT SUM (ivd_charge) FROM dbo.invoicedetail id WITH (NOLOCK) JOIN fuelchargetypes fct WITH (NOLOCK) ON id.cht_itemcode = fct.cht_itemcode '  
  --SET @sql = @sql + N'JOIN dbo.orderheader o WITH (NOLOCK) ON id.ord_hdrnumber = o.ord_hdrnumber WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM dbo.stops WITH (NOLOCK) WHERE stops.mov_number = l.mov_number AND ord_hdrnumber <> 0)) ord_fuel,'
              
  --SET @sql = @sql + N'(SELECT SUM (ISNULL(ord_charge,0)) FROM dbo.orderheader o WITH (NOLOCK) WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM stops WITH (NOLOCK) WHERE stops.mov_number = l.mov_number AND ord_hdrnumber <> 0)) ord_linehaul,'  
            
  --SET @sql = @sql + N'(SELECT SUM (ISNULL(ord_totalcharge,0)) FROM dbo.orderheader o WITH (NOLOCK) WHERE o.ord_hdrnumber IN (SELECT ord_hdrnumber FROM dbo.stops WITH (NOLOCK) WHERE stops.mov_number = l.mov_number AND ord_hdrnumber <> 0)) ord_totalcharge,' 
  SET @sql = @sql + N'
    ,NULL pyt_linehaul
	  ,0 pyt_accessorial
	  ,0 pyd_fuel
    ,0 pyd_linehaul
    ,NULL pyd_total
    ,0 ord_revenue_pay
    ,0 ord_totalcharge
    ,0 ord_accessorial_chrg 
    ,NULL ord_fuel
    ,0 ord_linehaul
    ,0 ord_totalcharge
    ,''Order'' ord_or_leg
    ,1.0 ord_percent '  
END  
ELSE  
BEGIN  
  SET @sql = @sql + N'
   ,NULL pyt_linehaul
   ,NULL pyd_accessorials
   ,NULL pyd_fuel
   ,NULL pyd_linehaul
   ,NULL pyd_total
   ,NULL ord_revenue_pay
   ,NULL all_ord_totalcharge
   ,NULL ord_accessorial_chrg
   ,NULL ord_fuel
   ,NULL ord_linehaul
   ,NULL ord_charge
   ,NULL ord_or_leg
   ,1.0 ord_percent '  
END  
   
IF @ma_transaction_id is null  
BEGIN
 SET @sql = @sql + N'
  ,NULL ma_transaction_id'  
END
ELSE  
BEGIN
  SET @sql = @sql + N'
   ,' + CONVERT(NVARCHAR(20),@ma_transaction_id) + N' ma_transaction_id '  
END
  
SET @sql = @sql + N'
 ,NULL ma_tour_number
 ,NULL ma_tour_sequence
 ,NULL ma_tour_max_sequence
 ,NULL ma_trc_number
 ,NULL ma_mpp_id
 ,lgh_mile_overage_message
 ,ISNULL(l.lgh_raildispatchstatus,''N'')
 ,ISNULL(carrier.car_204tENDer,''A'')
 ,ISNULL(carrier.car_204update,''ALL'')
 ,l.lgh_car_rate
 ,l.lgh_car_charge
 ,l.lgh_car_accessorials
 ,l.lgh_car_totalcharge
 ,l.lgh_recommENDed_car_id
 ,l.lgh_spot_rate
 ,l.lgh_edi_counter
 ,ISNULL(l.lgh_ship_status,''UNK'') lgh_ship_status
 ,l.lgh_faxemail_created
 ,l.lgh_externalrating_miles  
 ,l.lgh_acc_fsc
 ,l.lgh_chassis
 ,l.lgh_chassis2
 ,l.lgh_dolly
 ,l.lgh_dolly2
 ,l.lgh_trailer3
 ,l.lgh_trailer4
 ,oh.ord_order_source
 ,''UNKNOWN''
 ,''UD Column1''
 ,''UNKNOWN''
 ,''UD Column2''
 ,''UNKNOWN''
 ,''UD Column3''
 ,''UNKNOWN''
 ,''UD Column4''
 ,' + CONVERT(NVARCHAR(6),@v_LocalCityTZAdjMinutes) + N'-((ISNULL(octy.cty_GMTDelta,5)+(' + CONVERT(NVARCHAR(6),@InDSTFactor) 
    + N'* (CASE octy.cty_DSTApplies WHEN ''Y'' THEN 0 ELSE +1 END))) * 60) + ISNULL(octy.cty_TZMins,0) 
 ,' + CONVERT(NVARCHAR(6),@v_LocalCityTZAdjMinutes) + N'-((ISNULL(dcty.cty_GMTDelta,5)+(' + CONVERT(NVARCHAR(6),@InDSTFactor)  
    + N'* (CASE dcty.cty_DSTApplies WHEN ''Y'' THEN 0 ELSE +1 END))) * 60) + ISNULL(dcty.cty_TZMins,0)
 ,NULL
 ,NULL   
 ,l.lgh_direct_route_status1 '  
    
----FROM STATEMENT  
  
SET @sql = @sql + N'
FROM 
  dbo.legheader_active l WITH (NOLOCK) 
    INNER JOIN 
  dbo.stops s1 WITH (NOLOCK) ON l.stp_number_start = s1.stp_number
    INNER JOIN 
  dbo.stops s2 WITH (NOLOCK) ON l.stp_number_END = s2.stp_number
    INNER JOIN 
  dbo.company ocomp WITH (NOLOCK) ON l.cmp_id_start = ocomp.cmp_id
    INNER JOIN 
  dbo.city octy WITH (NOLOCK) ON l.lgh_startcity = octy.cty_code
    INNER JOIN 
  dbo.city dcty WITH (NOLOCK) ON l.lgh_ENDcity = dcty.cty_code
    INNER JOIN 
  dbo.company WITH (NOLOCK) ON company.cmp_id = ISNULL(l.ord_billto,''UNKNOWN'')
    LEFT JOIN 
  dbo.orderheader oh WITH (NOLOCK) ON l.ord_hdrnumber = oh.ord_hdrnumber
    LEFT JOIN 
  dbo.carrier WITH (NOLOCK) ON l.lgh_carrier = carrier.car_id '
  
IF @d_cmp_othertype1 <> 'UNK'  
BEGIN
  SET @sql = @sql + N'
      INNER JOIN 
    dbo.company dcomp WITH (NOLOCK) ON l.cmp_id_END = dcomp.cmp_id '  
END
  
IF @IncludeRefNumbers = 'Y'  
BEGIN  
 SET @sql = @sql + N'
     LEFT JOIN 
   referencenumber ref2 WITH (NOLOCK) ON (l.ord_hdrnumber = ref2.ref_tablekey AND ref2.ref_table = ''orderheader'' AND ref2.ref_sequence = 2)
     LEFT JOIN 
   referencenumber ref3 WITH (NOLOCK) ON (l.ord_hdrnumber = ref3.ref_tablekey AND ref3.ref_table = ''orderheader'' AND ref3.ref_sequence = 3)
     LEFT JOIN 
   referencenumber ref4 WITH (NOLOCK) ON (l.ord_hdrnumber = ref4.ref_tablekey AND ref4.ref_table = ''orderheader'' AND ref4.ref_sequence = 4)
     LEFT JOIN 
   referencenumber ref5 WITH (NOLOCK) ON (l.ord_hdrnumber = ref5.ref_tablekey AND ref5.ref_table = ''orderheader'' AND ref5.ref_sequence = 5) '
END  
  
--WHERE CLAUSE  
SET @sql = @sql + N'
WHERE
  l.ord_totalmiles between @miles_min AND @miles_max '

IF @hoursback <> 0
BEGIN
  SET @sql = @sql + N'AND lgh_startdate >= @hoursbackdate ';
END;
IF @hoursout <> 0
BEGIN
  SET @sql = @sql + N'AND lgh_startdate < @hoursoutdate ';
END;

--BEGIN ERB 93687
 SELECT @status = REPLACE(@status,' ','')  
 IF @status IS NULL or @status = '' or @status = 'UNK' or @status = 'UNKNOWN' or @status = 'ALL'    
 BEGIN
   INSERT @StatusList VALUES('AVL')
   INSERT @StatusList VALUES('DSP')
   INSERT @StatusList VALUES('PLN')
   INSERT @StatusList VALUES('STD')
   INSERT @StatusList VALUES('MPN')
   INSERT @StatusList VALUES('PND')     
 END
 ELSE
 BEGIN  
   INSERT @StatusList SELECT * FROM [dbo].[CSVStringsToTable_fn](@status)
 END;


SET @sql = @sql + 
    CASE (SELECT COUNT(*) FROM @StatusList) 
      WHEN 0 THEN N''
      WHEN 1 THEN N'AND l.lgh_outstatus = (SELECT KeyField FROM @StatusList) '
      ELSE N'AND l.lgh_outstatus IN (SELECT KeyField FROM @StatusList) '
    END;  
 --END ERB 93687 20150717
  
    
IF @includedrvplan='N'  
BEGIN
  SET @sql = @sql + N'
      AND 
    ISNULL(l.drvplan_number,0) = 0 '
END
     
-- START ERB 93687 20150717
if ISNULL(@revtype1, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@revtype1) > 0
BEGIN
  INSERT @lghType1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@revtype1)
  SELECT @sql = @sql + 
    CASE @@ROWCOUNT 
      WHEN 0 THEN N''
      WHEN 1 THEN N'AND l.lgh_class1 = (SELECT KeyField FROM @lghType1List) '
      ELSE N'AND l.lgh_class1 IN (SELECT KeyField FROM @lghType1List) '
    END;  
END

if ISNULL(@revtype2, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@revtype2) > 0
BEGIN
  INSERT @lghType2List SELECT * FROM [dbo].[CSVStringsToTable_fn](@revtype2)
  SET @sql = @sql + 
  CASE @@ROWCOUNT
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.lgh_class2 = (SELECT KeyField FROM @lghType2List) ' 
    ELSE N'AND l.lgh_class2 IN (SELECT KeyField FROM @lghType2List) ' 
  END;
END

if ISNULL(@revtype3, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@revtype3) > 0
BEGIN
  INSERT @lghType3List SELECT * FROM [dbo].[CSVStringsToTable_fn](@revtype3)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.lgh_class3 = (SELECT KeyField FROM @lghType3List) ' 
    ELSE N'AND l.lgh_class3 IN (SELECT KeyField FROM @lghType3List) ' 
  END;
END

if ISNULL(@revtype4, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@revtype4) > 0
BEGIN
  INSERT @lghType4List SELECT * FROM [dbo].[CSVStringsToTable_fn](@revtype4)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.lgh_class4 = (SELECT KeyField FROM @lghType4List) ' 
    ELSE N'AND l.lgh_class4 IN (SELECT KeyField FROM @lghType4List) ' 
  END;
END


select @states = REPLACE(@states,' ','')
if ISNULL(@states, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@states) > 0
BEGIN
  INSERT @startStateList SELECT * FROM [dbo].[CSVStringsToTable_fn](@states)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.lgh_startstate = (SELECT KeyField FROM @startStateList) ' 
    ELSE N'AND l.lgh_startstate IN (SELECT KeyField FROM @startStateList) ' 
  END;
END

select @d_states = REPLACE(@d_states,' ','')
if ISNULL(@d_states, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@d_states) > 0
BEGIN
  INSERT @endStateList SELECT * FROM [dbo].[CSVStringsToTable_fn](@d_states)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.lgh_endstate = (SELECT KeyField FROM @endStateList) '
    ELSE N'AND l.lgh_endstate IN (SELECT KeyField FROM @endStateList) '
  END;
END
-- END ERB 93687 20150717
 
SELECT @d_cmpids = REPLACE(@d_cmpids,' ','')  
if ISNULL(@d_cmpids, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@d_cmpids) > 0
BEGIN
  INSERT @endCompList SELECT * FROM [dbo].[CSVStringsToTable_fn](@d_cmpids)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND cmp_id_END = (SELECT KeyField FROM @endCompList) ' 
    ELSE N'AND cmp_id_END IN (SELECT KeyField FROM @endCompList) ' 
  END;
END

SELECT @teamleader = REPLACE(@teamleader,' ','')  
if ISNULL(@teamleader, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@teamleader) > 0
BEGIN
  INSERT @TeamLeaderList SELECT * FROM [dbo].[CSVStringsToTable_fn](@teamleader)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND mpp_teamleader = (SELECT KeyField FROM @TeamLeaderList) '
    ELSE N'AND mpp_teamleader IN (SELECT KeyField FROM @TeamLeaderList) '
  END;
END

SELECT @tm_status = REPLACE(@tm_status,' ','')  
if ISNULL(@tm_status, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@tm_status) > 0
BEGIN
  INSERT @TMStatusList SELECT * FROM [dbo].[CSVStringsToTable_fn](@tm_status)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_tm_status = (SELECT KeyField FROM @TMStatusList) ' 
    ELSE N'AND lgh_tm_status IN (SELECT KeyField FROM @TMStatusList) ' 
  END;
END 

SELECT @lgh_type1 = REPLACE(@lgh_type1,' ','')  
if ISNULL(@lgh_type1, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@lgh_type1) > 0
BEGIN
  INSERT @lgh_type1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@lgh_type1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_type1 = (SELECT KeyField FROM @lgh_type1List) ' 
    ELSE N'AND lgh_type1 IN (SELECT KeyField FROM @lgh_type1List) ' 
  END;
END 

SELECT @lgh_type2 = REPLACE(@lgh_type2,' ','')  
if ISNULL(@lgh_type2, 'UNK') NOT IN ('UNK', 'ALL') and LEN(@lgh_type2) > 0
BEGIN
  INSERT @lgh_type2List SELECT * FROM [dbo].[CSVStringsToTable_fn](@lgh_type2)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_type2 = (SELECT KeyField FROM @lgh_type2List) ' 
    ELSE N'AND lgh_type2 IN (SELECT KeyField FROM @lgh_type2List) ' 
  END;
END 

SELECT @company = REPLACE(@company,' ','')  
IF ISNULL(@company, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@company) > 0
BEGIN
  INSERT @companyList SELECT * FROM [dbo].[CSVStringsToTable_fn](@company)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.ord_ord_subcompany = (SELECT KeyField FROM @companyList) ' 
    ELSE N'AND l.ord_ord_subcompany IN (SELECT KeyField FROM @companyList) ' 
  END;
END 

SELECT @bookedby = REPLACE(@bookedby,' ','')  
IF ISNULL(@bookedby, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@bookedby) > 0
BEGIN
  INSERT @bookedbyList SELECT * FROM [dbo].[CSVStringsToTable_fn](@bookedby)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.ord_bookedby = (SELECT KeyField FROM @bookedbyList) ' 
    ELSE N'AND l.ord_bookedby IN (SELECT KeyField FROM @bookedbyList) ' 
  END;
END 

SELECT @trltype1 = REPLACE(@trltype1,' ','')  
IF ISNULL(@trltype1, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@trltype1) > 0
BEGIN
  INSERT @trltype1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@trltype1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.ord_trl_type1 = (SELECT KeyField FROM @trltype1List) ' 
    ELSE N'AND l.ord_trl_type1 IN (SELECT KeyField FROM @trltype1List) ' 
  END;
END 

SELECT @billto = REPLACE(@billto,' ','')  
IF ISNULL(@billto, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@billto) > 0
BEGIN
  INSERT @billtoList SELECT * FROM [dbo].[CSVStringsToTable_fn](@billto)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.ord_billto = (SELECT KeyField FROM @billtoList) ' 
    ELSE N'AND l.ord_billto IN (SELECT KeyField FROM @billtoList) ' 
  END;
END 

SELECT @lgh_route = REPLACE(@lgh_route,' ','')  
IF ISNULL(@lgh_route, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@lgh_route) > 0
BEGIN
  INSERT @lgh_routeList SELECT * FROM [dbo].[CSVStringsToTable_fn](@lgh_route)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0  THEN N'' 
    WHEN 1 THEN N'AND lgh_route = (SELECT KeyField FROM @lgh_routeList) ' 
    ELSE N'AND lgh_route IN (SELECT KeyField FROM @lgh_routeList) ' 
  END;
END 

SELECT @lgh_booked_revtype1 = REPLACE(@lgh_booked_revtype1,' ','')  
IF ISNULL(@lgh_booked_revtype1, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@lgh_booked_revtype1) > 0
BEGIN
  INSERT @lgh_booked_revtype1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@lgh_booked_revtype1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_booked_revtype1 = (SELECT KeyField FROM @lgh_booked_revtype1List) ' 
    ELSE N'AND lgh_booked_revtype1 IN (SELECT KeyField FROM @lgh_booked_revtype1List) ' 
  END;
END 

SELECT @orderedby = REPLACE(@orderedby,' ','')  
IF ISNULL(@orderedby, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@orderedby) > 0
BEGIN
  INSERT @orderedbyList SELECT * FROM [dbo].[CSVStringsToTable_fn](@orderedby)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.ord_company = (SELECT KeyField FROM @orderedbyList) ' 
    ELSE N'AND l.ord_company IN (SELECT KeyField FROM @orderedbyList) ' 
  END;
END 

SELECT @reg1 = REPLACE(@reg1,' ','')  
IF ISNULL(@reg1, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@reg1) > 0
BEGIN
  INSERT @reg1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@reg1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_startregion1 = (SELECT KeyField FROM @reg1List) ' 
    ELSE N'AND lgh_startregion1 IN (SELECT KeyField FROM @reg1List) ' 
  END;
END

SELECT @reg2 = REPLACE(@reg2,' ','')  
IF ISNULL(@reg2, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@reg2) > 0
BEGIN
  INSERT @reg2List SELECT * FROM [dbo].[CSVStringsToTable_fn](@reg2)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_startregion2 = (SELECT KeyField FROM @reg2List) ' 
    ELSE N'AND lgh_startregion2 IN (SELECT KeyField FROM @reg2List) ' 
  END;
END

SELECT @reg3 = REPLACE(@reg3,' ','')  
IF ISNULL(@reg3, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@reg3) > 0
BEGIN
  INSERT @reg3List SELECT * FROM [dbo].[CSVStringsToTable_fn](@reg3)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_startregion3 = (SELECT KeyField FROM @reg3List) ' 
    ELSE N'AND lgh_startregion3 IN (SELECT KeyField FROM @reg3List) ' 
  END;
END

SELECT @reg4 = REPLACE(@reg4,' ','')  
IF ISNULL(@reg4, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@reg4) > 0
BEGIN
  INSERT @reg4List SELECT * FROM [dbo].[CSVStringsToTable_fn](@reg4)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_startregion4 = (SELECT KeyField FROM @reg4List) ' 
    ELSE N'AND lgh_startregion4 IN (SELECT KeyField FROM @reg4List) ' 
  END;
END

SELECT @d_reg1 = REPLACE(@d_reg1,' ','')  
IF ISNULL(@d_reg1, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@d_reg1) > 0
BEGIN
  INSERT @d_reg1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@d_reg1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_ENDregion1 = (SELECT KeyField FROM @d_reg1List) ' 
    ELSE N'AND lgh_ENDregion1 IN (SELECT KeyField FROM @d_reg1List) ' 
  END;
END

SELECT @d_reg2 = REPLACE(@d_reg2,' ','')  
IF ISNULL(@d_reg2, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@d_reg2) > 0
BEGIN
  INSERT @d_reg2List SELECT * FROM [dbo].[CSVStringsToTable_fn](@d_reg2)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_ENDregion2 = (SELECT CAST(KeyField as CHAR(20)) FROM @d_reg2List) ' 
    ELSE N'AND lgh_ENDregion2 IN (SELECT CAST(KeyField as CHAR(20)) FROM @d_reg2List) ' 
  END;
END

SELECT @d_reg3 = REPLACE(@d_reg3,' ','')  
IF ISNULL(@d_reg3, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@d_reg3) > 0
BEGIN
  INSERT @d_reg3List SELECT * FROM [dbo].[CSVStringsToTable_fn](@d_reg3)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_ENDregion3 = (SELECT KeyField FROM @d_reg3List) ' 
    ELSE N'AND lgh_ENDregion3 IN (SELECT KeyField FROM @d_reg3List) ' 
  END;
END

SELECT @d_reg4 = REPLACE(@d_reg4,' ','')  
IF ISNULL(@d_reg4, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@d_reg4) > 0
BEGIN
  INSERT @d_reg4List SELECT * FROM [dbo].[CSVStringsToTable_fn](@d_reg4)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_ENDregion4 = (SELECT KeyField FROM @d_reg4List) ' 
    ELSE N'AND lgh_ENDregion4 IN (SELECT KeyField FROM @d_reg4List) ' 
  END;
END

SELECT @lgh_permit_status = REPLACE(@lgh_permit_status,' ','')  
IF ISNULL(@lgh_permit_status, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@lgh_permit_status) > 0
BEGIN
  INSERT @lgh_permit_statusList SELECT * FROM [dbo].[CSVStringsToTable_fn](@lgh_permit_status)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND l.lgh_permit_status = (SELECT KeyField FROM @lgh_permit_statusList) ' 
    ELSE N'AND l.lgh_permit_status IN (SELECT KeyField FROM @lgh_permit_statusList) ' 
  END;
END

SELECT @lgh_hzd_cmd_classes = REPLACE(@lgh_hzd_cmd_classes,' ','')  
IF ISNULL(@lgh_hzd_cmd_classes, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@lgh_hzd_cmd_classes) > 0
BEGIN
  INSERT @lgh_hzd_cmd_classesList SELECT * FROM [dbo].[CSVStringsToTable_fn](@lgh_hzd_cmd_classes)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND lgh_hzd_cmd_class = (SELECT KeyField FROM @lgh_hzd_cmd_classesList) ' 
    ELSE N'AND lgh_hzd_cmd_class IN (SELECT KeyField FROM @lgh_hzd_cmd_classesList) ' 
  END;
END

SELECT @cmp_othertype1 = REPLACE(@cmp_othertype1,' ','')  
IF ISNULL(@cmp_othertype1, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@cmp_othertype1) > 0
BEGIN
  INSERT @cmp_othertype1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@cmp_othertype1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND ocomp.cmp_othertype1 = (SELECT KeyField FROM @cmp_othertype1List) ' 
    ELSE N'AND ocomp.cmp_othertype1 IN (SELECT KeyField FROM @cmp_othertype1List) ' 
  END;
END

SELECT @d_cmp_othertype1 = REPLACE(@d_cmp_othertype1,' ','')  
IF ISNULL(@d_cmp_othertype1, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@d_cmp_othertype1) > 0
BEGIN
  INSERT @d_cmp_othertype1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@d_cmp_othertype1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND dcomp.cmp_othertype1 = (SELECT KeyField FROM @d_cmp_othertype1List) ' 
    ELSE N'AND dcomp.cmp_othertype1 IN (SELECT KeyField FROM @d_cmp_othertype1List) ' 
  END;
END

SELECT @cmp_othertype1_billto = REPLACE(@cmp_othertype1_billto,' ','')  
IF ISNULL(@cmp_othertype1_billto, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@cmp_othertype1_billto) > 0
BEGIN
  INSERT @cmp_othertype1_billtoList SELECT * FROM [dbo].[CSVStringsToTable_fn](@cmp_othertype1_billto)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND company.cmp_othertype1 = (SELECT KeyField FROM @cmp_othertype1_billtoList) ' 
    ELSE N'AND company.cmp_othertype1 IN (SELECT KeyField FROM @cmp_othertype1_billtoList) ' 
  END;
END

SELECT @cmp_othertype2_billto = REPLACE(@cmp_othertype2_billto,' ','')  
IF ISNULL(@cmp_othertype2_billto, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@cmp_othertype2_billto) > 0
BEGIN
  INSERT @cmp_othertype2_billtoList SELECT * FROM [dbo].[CSVStringsToTable_fn](@cmp_othertype2_billto)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND company.cmp_othertype2 = (SELECT KeyField FROM @cmp_othertype2_billtoList) ' 
    ELSE N'AND company.cmp_othertype2 IN (SELECT KeyField FROM @cmp_othertype2_billtoList) ' 
  END;
END

SELECT @ord_booked_revtype1 = REPLACE(@ord_booked_revtype1,' ','')  
IF ISNULL(@ord_booked_revtype1, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@ord_booked_revtype1) > 0
BEGIN
  INSERT @ord_booked_revtype1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@ord_booked_revtype1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N'' 
    WHEN 1 THEN N'AND ord_booked_revtype1 = (SELECT KeyField FROM @ord_booked_revtype1List) ' 
    ELSE N'AND ord_booked_revtype1 IN (SELECT KeyField FROM @ord_booked_revtype1List) ' 
  END;
END


SET @cmpids = REPLACE(@cmpids,' ','')  
IF ISNULL(@cmpids, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@cmpids) > 0
BEGIN  
  INSERT @cmpidsList SELECT * FROM [dbo].[CSVStringsToTable_fn](@cmpids)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N''
    WHEN 1 THEN N'AND (cmp_id_start = (SELECT KeyField FROM @cmpidsList) ' 
    ELSE N'AND (cmp_id_start IN (SELECT KeyField FROM @cmpidsList) ' 
  END;    
  
  SET @origin_include_stop_events = REPLACE(@origin_include_stop_events,' ','') 
  IF ISNULL(@origin_include_stop_events, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@origin_include_stop_events) > 0
  BEGIN  
    INSERT @origin_include_stop_eventsList SELECT * FROM [dbo].[CSVStringsToTable_fn](@origin_include_stop_events)
    SET @sql = @sql + 
    CASE @@ROWCOUNT 
      WHEN 0 THEN N''
      WHEN 1 THEN ' OR l.lgh_number IN (SELECT st.lgh_number FROM dbo.stops st WITH (NOLOCK) WHERE st.cmp_id IN (SELECT KeyField FROM @cmpidsList) AND st.stp_event = (SELECT KeyField FROM @origin_include_stop_eventsList)'
      ELSE N' OR l.lgh_number IN (SELECT st.lgh_number FROM dbo.stops st WITH (NOLOCK) WHERE st.cmp_id IN (SELECT KeyField FROM @cmpidsList) AND st.stp_event IN (SELECT KeyField FROM @origin_include_stop_eventsList)'   
    END;
  END;
  SET @sql = @sql + N') '  
END;

IF @city > 0  
 SET @sql = @sql + N'AND l.lgh_startcity = @city '
IF @d_city > 0  
 SET @sql = @sql + N'AND l.lgh_ENDcity = @d_City ' 


SELECT @Direct_route_status1 = REPLACE(@Direct_route_status1,' ','')  
IF ISNULL(@Direct_route_status1, 'UNK') NOT IN ('UNK', 'ALL') AND LEN(@Direct_route_status1) > 0 AND @directroute = 'Y'
BEGIN
  INSERT @Direct_route_status1List SELECT * FROM [dbo].[CSVStringsToTable_fn](@Direct_route_status1)
  SET @sql = @sql + 
  CASE @@ROWCOUNT 
    WHEN 0 THEN N''
    WHEN 1 THEN N'AND lgh_direct_route_status1 = (SELECT KeyField FROM @Direct_route_status1List) ' 
    ELSE N'AND lgh_direct_route_status1 IN (SELECT KeyField FROM @Direct_route_status1List) ' 
  END;
END

--select @sql

 
INSERT INTO @ttbl1  
EXEC sp_executesql @sql,   
@params=N'@hoursbackdate DATETIME
 ,@hoursoutdate DATETIME
 ,@miles_min INT
 ,@miles_max INT
 ,@city INT
 ,@d_city INT
 ,@StatusList TMWTable_varchar256 READONLY
 ,@lghType1List TMWTable_varchar256 READONLY
 ,@lghType2List TMWTable_varchar256 READONLY
 ,@lghType3List TMWTable_varchar256 READONLY
 ,@lghType4List TMWTable_varchar256 READONLY
 ,@billtoList TMWTable_varchar256 READONLY
 ,@startStateList TMWTable_varchar256 READONLY
 ,@endStateList TMWTable_varchar256 READONLY
 ,@endCompList TMWTable_varchar256 READONLY
 ,@TeamLeaderList TMWTable_varchar256 READONLY
 ,@TMStatusList TMWTable_varchar256 READONLY
 ,@lgh_type1List TMWTable_varchar256 READONLY
 ,@lgh_type2List TMWTable_varchar256 READONLY
 ,@companyList TMWTable_varchar256 READONLY
 ,@bookedbyList TMWTable_varchar256 READONLY
 ,@trltype1List TMWTable_varchar256 READONLY
 ,@lgh_routeList TMWTable_varchar256 READONLY
 ,@lgh_booked_revtype1List TMWTable_varchar256 READONLY
 ,@orderedbyList TMWTable_char20 READONLY
 ,@reg1List TMWTable_varchar256 READONLY
 ,@reg2List TMWTable_varchar256 READONLY
 ,@reg3List TMWTable_varchar256 READONLY
 ,@reg4List TMWTable_varchar256 READONLY
 ,@d_reg1List TMWTable_varchar256 READONLY
 ,@d_reg2List TMWTable_varchar256 READONLY
 ,@d_reg3List TMWTable_varchar256 READONLY
 ,@d_reg4List TMWTable_varchar256 READONLY
 ,@lgh_permit_statusList TMWTable_varchar256 READONLY
 ,@lgh_hzd_cmd_classesList TMWTable_varchar256 READONLY
 ,@cmp_othertype1List TMWTable_varchar256 READONLY
 ,@d_cmp_othertype1List TMWTable_varchar256 READONLY
 ,@cmp_othertype1_billtoList TMWTable_varchar256 READONLY
 ,@cmp_othertype2_billtoList TMWTable_varchar256 READONLY
 ,@ord_booked_revtype1List TMWTable_varchar256 READONLY
 ,@cmpidsList TMWTable_varchar256 READONLY
 ,@origin_include_stop_eventsList TMWTable_char6 READONLY
 ,@Direct_route_status1List TMWTable_varchar256 READONLY'
 ,@hoursbackdate=@hoursbackdate
 ,@hoursoutdate=@hoursoutdate
 ,@miles_min=@miles_min
 ,@miles_max=@miles_max
 ,@city = @city
 ,@d_city = @d_city
 ,@StatusList = @StatusList
 ,@lghType1List = @lghType1List
 ,@lghType2List = @lghType2List
 ,@lghType3List = @lghType3List
 ,@lghType4List = @lghType4List
 ,@billtoList = @billtoList
 ,@startStateList = @startStateList
 ,@endStateList = @endStateList
 ,@endCompList = @endCompList
 ,@TeamLeaderList = @TeamLeaderList
 ,@TMStatusList = @TMStatusList
 ,@lgh_type1List = @lgh_type1List
 ,@lgh_type2List = @lgh_type2List
 ,@companyList = @companyList
 ,@bookedbyList = @bookedbyList
 ,@trltype1List = @trltype1List
 ,@lgh_routeList = @lgh_routeList
 ,@lgh_booked_revtype1List = @lgh_booked_revtype1List
 ,@orderedbyList = @orderedbyList
 ,@reg1List = @reg1List
 ,@reg2List = @reg2List
 ,@reg3List = @reg3List
 ,@reg4List = @reg4List
 ,@d_reg1List = @d_reg1List
 ,@d_reg2List = @d_reg2List
 ,@d_reg3List = @d_reg3List
 ,@d_reg4List = @d_reg4List
 ,@lgh_permit_statusList = @lgh_permit_statusList
 ,@lgh_hzd_cmd_classesList = @lgh_hzd_cmd_classesList
 ,@cmp_othertype1List = @cmp_othertype1List
 ,@d_cmp_othertype1List = @d_cmp_othertype1List
 ,@cmp_othertype1_billtoList = @cmp_othertype1_billtoList
 ,@cmp_othertype2_billtoList = @cmp_othertype2_billtoList
 ,@ord_booked_revtype1List = @ord_booked_revtype1List
 ,@cmpidsList = @cmpidsList
 ,@origin_include_stop_eventsList = @origin_include_stop_eventsList
 ,@Direct_route_status1List = @Direct_route_status1List


  
/*66651 END*/  

--PTS 88078
UPDATE 
  t 
SET
  lgh_miles = s.sum_stp_lgh_mileage
FROM 
  @ttbl1 t 
    INNER JOIN
  (SELECT 
     lgh_number
    ,SUM(stp_lgh_mileage) sum_stp_lgh_mileage 
   FROM 
     dbo.stops 
   GROUP BY lgh_number) s ON t.lgh_number = s.lgh_number

IF @LateWarnMode = 'EVENT'    
BEGIN
	UPDATE 
    t 
  SET
    evt_latedate = COALESCE(o.min_evt_latedate, '20491231')
	FROM 
    @ttbl1 t 
      LEFT OUTER JOIN
	  (SELECT 
       s.lgh_number
      ,MIN(e.evt_latedate) AS min_evt_latedate 
     FROM
	     dbo.stops s 
         INNER JOIN 
       dbo.event e ON s.stp_number = e.stp_number
	   WHERE 
       e.evt_status = 'OPN'
	   GROUP BY s.lgh_number) o ON t.lgh_number = o.lgh_number
END

IF @LateWarnMode = 'ARRIVALDEPARTURE'
BEGIN
	UPDATE 
    t
  SET 
    evt_latedate = o.min_evt_latedate
	FROM 
    @ttbl1 t 
      INNER JOIN
	  (SELECT 
       s.lgh_number
      ,MIN(e.evt_latedate) AS min_evt_latedate 
     FROM
	     dbo.stops s 
         INNER JOIN 
       dbo.event e ON s.stp_number = e.stp_number
	   WHERE 
       e.evt_departure_status = 'OPN'
	   GROUP BY 
       s.lgh_number) o ON t.lgh_number = o.lgh_number
END

UPDATE 
  t
SET 
  lgh_carrier = ISNULL(c.car_name,'UNKNOWN')
FROM 
  @ttbl1 t 
    INNER JOIN 
  dbo.carrier c ON t.evt_carrier = c.car_id

UPDATE 
  t
SET 
  TotalCarrierPay = o.sum_pyd_amount
FROM 
  @ttbl1 t 
    INNER JOIN 
  (SELECT 
     lgh_number
    ,mov_number
    ,asgn_id
    ,SUM(ISNULL(pyd_amount,0)) AS sum_pyd_amount 
   FROM 
     dbo.paydetail
   WHERE 
     asgn_type = 'CAR'
   GROUP BY 
     lgh_number, mov_number, asgn_id) o ON t.lgh_number = o.lgh_number AND t.mov_number = o.mov_number AND t.evt_carrier = o.asgn_id


IF NOT EXISTS(SELECT TOP 1 1 FROM @GIKEY WHERE gi_name = 'OBV_include_FD_LWH' AND ISNULL(gi_string1, 'Y') = 'N')
BEGIN
  UPDATE 
    t
  SET 
    fgt_length = o.max_fgt_length
   ,fgt_width = o.max_fgt_width
   ,fgt_height = o.max_fgt_height
  FROM 
    @ttbl1 t 
      INNER JOIN
    (SELECT 
       s.lgh_number
      ,MAX(f.fgt_length) AS max_fgt_length
      ,MAX(f.fgt_width) AS max_fgt_width
      ,MAX(f.fgt_height) AS max_fgt_height
     FROM 
       dbo.stops s 
         INNER JOIN 
       dbo.freightdetail f ON s.stp_number = f.stp_number
     GROUP BY 
       s.lgh_number) o ON t.lgh_number = o.lgh_number
END 

UPDATE 
  t
SET
  compartment_loaded = CASE WHEN o.fbc_qty > 0 THEN 1 ELSE 0 END
FROM 
  @ttbl1 t 
    INNER JOIN 
  (SELECT 
     mov_number
    ,count(*) as fbc_qty 
   FROM
     dbo.freight_by_compartment
   WHERE 
     fbc_weight > 0 OR fbc_volume > 0
   GROUP BY 
     mov_number) o ON t.mov_number = o.mov_number

UPDATE 
  t
SET 
  num_legs = o.legqty
FROM 
  @ttbl1 t 
    INNER JOIN
  (SELECT 
     mov_number
    ,count(*) legqty 
   FROM 
     dbo.legheader_active 
   GROUP BY 
     mov_number) o ON t.mov_number = o.mov_number

UPDATE 
  t
SET
  num_ords = o.ordqty
FROM 
  @ttbl1 t 
    INNER JOIN
  (SELECT 
     mov_number
    ,count(*) ordqty
   FROM 
     dbo.orderheader 
   GROUP BY 
     mov_number) o ON t.mov_number = o.mov_number

IF @ACSInfo = 'Y'  
BEGIN  

	UPDATE 
    t
	SET 
    pyt_linehaul = @pyt_linehaul
	FROM 
    @ttbl1 t
	  INNER JOIN
    dbo.paydetail p ON 
      t.ord_carrier = p.asgn_id 
        AND 
      t.lgh_number = p.lgh_number
	    AND 
      t.mov_number = p.mov_number 
        AND 
      p.pyt_itemcode = @pyt_linehaul 
        AND 
      p.asgn_type = 'CAR'
 
	UPDATE 
    t
	SET 
    pyt_linehaul = o.min_pyt_itemcode
	FROM 
    @ttbl1 t 
      INNER JOIN
	(SELECT 
        p.asgn_id
      ,p.lgh_number
      ,p.mov_number
      ,MIN(p.pyt_itemcode) min_pyt_itemcode 
	  FROM 
        dbo.paydetail p 
          INNER JOIN 
        dbo.paytype pt ON p.pyt_itemcode = pt.pyt_itemcode
	  WHERE 
        pt.pyt_basis = 'LGH' 
          AND 
        p.asgn_type = 'CAR'
	  GROUP BY 
        p.asgn_id
      ,p.lgh_number
      ,p.mov_number) o ON t.lgh_number = o.lgh_number AND t.mov_number = o.mov_number AND t.ord_carrier = o.asgn_id
	WHERE t.pyt_linehaul IS NULL

	UPDATE 
    t
	SET 
    pyd_accessorials = o.sum_pyd_amount
	FROM 
    @ttbl1 t 
      INNER JOIN
	(SELECT 
        asgn_id
      ,lgh_number
      ,mov_number
      ,SUM(ISNULL(pyd_amount,0)) sum_pyd_amount 
      FROM 
        dbo.paydetail 
	  WHERE 
        asgn_type = 'CAR' 
          AND 
        pyt_itemcode = @pyt_accessorial
	  GROUP BY 
        asgn_id
      ,lgh_number
      ,mov_number) o ON t.ord_carrier = o.asgn_id AND t.mov_number = o.mov_number AND t.lgh_number = o.lgh_number
	
	  
	UPDATE 
    t
	SET 
    pyd_fuel = sum_pyd_amount
	FROM 
    @ttbl1 t 
      INNER JOIN
	(SELECT 
        asgn_id
      ,lgh_number
      ,mov_number
      ,SUM(ISNULL(pyd_amount,0)) sum_pyd_amount 
      FROM 
        dbo.paydetail 
	  WHERE 
        asgn_type = 'CAR' 
          AND 
        pyt_itemcode = @pyt_fuelcost
	  GROUP BY 
        asgn_id
      ,lgh_number
      ,mov_number) o ON t.ord_carrier = o.asgn_id AND t.mov_number = o.mov_number AND t.lgh_number = o.lgh_number

	UPDATE 
    t
	SET
    pyd_total = sum_pyd_amount
	FROM 
    @ttbl1 t 
      INNER JOIN
	(SELECT 
        mov_number
      ,SUM(pyd_amount) sum_pyd_amount
	  FROM 
        dbo.paydetail 
      WHERE 
        ord_hdrnumber > 0 
	      AND 
        CHARINDEX(',' + pyt_itemcode + ',',@ACS_Exclude_ACC_Paytype) > 0
	  GROUP BY 
        mov_number) o ON t.mov_number = o.mov_number
	

--SELECT SUM (ivd_charge) FROM invoicedetail id with (nolock) 
--JOIN fuelchargetypes fct with (nolock) ON id.cht_itemcode = fct.cht_itemcode 
--JOIN orderheader o with (nolock) ON id.ord_hdrnumber = o.ord_hdrnumber 
--WHERE o.ord_hdrnumber IN (

--SELECT ord_hdrnumber FROM stops with (nolock) 
--WHERE stops.mov_number = l.mov_number AND ord_hdrnumber <> 0) ord_fuel, 

	
  UPDATE 
    t
  SET
    all_ord_revenue_pay = a.sum_ord_revenue_pay
   ,all_ord_totalcharge = a.sum_ord_total_charge
   ,ord_accessorials = a.sum_ord_accessorial_charge
   ,ord_linehaul = a.sum_ord_charge
   ,ord_total_charge = a.sum_ord_total_charge
  FROM 
    @ttbl1 t 
      INNER JOIN 
      (
      SELECT 
        o.ord_hdrnumber
       ,SUM(ISNULL(o.ord_revenue_pay,0)) sum_ord_revenue_pay
       ,SUM(ISNULL(o.ord_totalcharge,0)) sum_ord_total_charge
       ,SUM(ISNULL(o.ord_accessorial_chrg,0)) sum_ord_accessorial_charge
       ,SUM(ISNULL(o.ord_charge,0)) sum_ord_charge
      FROM dbo.orderheader o with (nolock) where EXISTS (select s.ord_hdrnumber from stops s with (nolock)
      where s.mov_number = o.mov_number and s.ord_hdrnumber > 0) 
      GROUP BY 
        o.ord_hdrnumber) a 
        on t.ord_hdrnumber = a.ord_hdrnumber
 

	UPDATE --ANDREWS
    t
	SET 
    ord_fuel = o.sum_ivd_charge
	FROM 
	(SELECT 
       i.ord_hdrnumber
      ,SUM(i.ivd_charge) sum_ivd_charge
	  FROM        
       dbo.invoicedetail i
         INNER JOIN 
       dbo.FuelChargeTypes fct ON i.cht_itemcode = fct.Cht_itemcode
	  WHERE 
       i.ord_hdrnumber <> 0        
	  GROUP BY 
        i.ord_hdrnumber) o 
  INNER JOIN (select distinct ord_hdrnumber, mov_number FROM stops where ord_hdrnumber > 0) s ON s.ord_hdrnumber = o.ord_hdrnumber
  inner join  @ttbl1 t ON t.mov_number = s.mov_number
                  
END

-- Only perform the following logic IF the Feature is on.
IF @localization = 'Y'
BEGIN
  -- PTS 22601 - DJM
  SET @o_servicearea = ',' + LTRIM(RTRIM(ISNULL(@o_servicearea, '')))  + ','
  SET @o_servicezone = ',' + LTRIM(RTRIM(ISNULL(@o_servicezone, '')))  + ','
  SET @o_servicecenter = ',' + LTRIM(RTRIM(ISNULL(@o_servicecenter, '')))  + ','
  SET @o_serviceregion = ',' + LTRIM(RTRIM(ISNULL(@o_serviceregion, '')))  + ','
  SET @dest_servicearea = ',' + LTRIM(RTRIM(ISNULL(@dest_servicearea, '')))  + ','
  SET @dest_servicezone = ',' + LTRIM(RTRIM(ISNULL(@dest_servicezone, '')))  + ','
  SET @dest_servicecenter = ',' + LTRIM(RTRIM(ISNULL(@dest_servicecenter, '')))  + ','
  SET @dest_serviceregion = ',' + LTRIM(RTRIM(ISNULL(@dest_serviceregion, '')))  + ','

  /* PTS 20302 - DJM - display the localization settings for the Origin AND Desitinations */
  SELECT TOP 1 
    @o_servicezone_labelname =      'Origin ' + userlabelname
   ,@dest_servicezone_labelname =   'Dest '   + userlabelname
  FROM 
    dbo.labelfile 
  WHERE 
    labeldefinition = 'ServiceZone'

  SELECT TOP 1 
    @o_servicecenter_labelname =    'Origin ' + userlabelname 
   ,@dest_servicecenter_labelname = 'Dest '   + userlabelname
  FROM 
    dbo.labelfile 
  WHERE 
    labeldefinition = 'ServiceCenter'

  SELECT TOP 1 
    @o_serviceregion_labelname =    'Origin ' + userlabelname 
   ,@dest_serviceregion_labelname = 'Dest '   + userlabelname 
  FROM 
    dbo.labelfile 
  WHERE 
    labeldefinition = 'ServiceRegion'

  SELECT TOP 1 
    @o_sericearea_labelname =       'Origin ' + userlabelname 
   ,@dest_sericearea_labelname =    'Dest '   + userlabelname 
  FROM 
    dbo.labelfile 
  WHERE 
    labeldefinition = 'ServiceArea'
  
  SELECT @service_revtype = UPPER(LTRIM(RTRIM(ISNULL(gi_string1,'')))) FROM @GIKEY WHERE gi_name = 'ServiceRegionRevType'

  /* PTS 26766 - DJM - Set the Localization fields */
  --SELECT temp1.ord_hdrnumber,
  -- orderheader.ord_origincity,
  -- temp1.lgh_originzip,
  UPDATE
    temp1
  SET
    origin_servicezone = ISNULL((SELECT cz_zone FROM dbo.cityzip WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip),'UNK')
   ,o_servicezone_t = @o_servicezone_labelname
   ,origin_servicearea = ISNULL((SELECT cz_area FROM dbo.cityzip WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip),'UNK')
   ,o_servicearea_t = @o_sericearea_labelname
   ,origin_servicecenter = ISNULL((SELECT CASE ISNULL(@service_revtype,'UNK')
                                            WHEN 'REVTYPE1' THEN (SELECT MAX(svc_center) FROM dbo.serviceregion sc, dbo.cityzip WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
                                            WHEN 'REVTYPE2' THEN (SELECT MAX(svc_center) FROM dbo.serviceregion sc, dbo.cityzip WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
                                            WHEN 'REVTYPE3' THEN (SELECT MAX(svc_center) FROM dbo.serviceregion sc, dbo.cityzip WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
                                            WHEN 'REVTYPE4' THEN (SELECT MAX(svc_center) FROM dbo.serviceregion sc, dbo.cityzip WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
                                            ELSE 'UNK'
                                          END),'UNK')
   ,o_servicecenter_t = @o_servicecenter_labelname
   ,origin_serviceregion = ISNULL((SELECT CASE ISNULL(@service_revtype,'UNK')
                                            WHEN 'REVTYPE1' THEN (SELECT MAX(svc_region) FROM dbo.serviceregion sc, dbo.cityzip  WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
                                            WHEN 'REVTYPE2' THEN (SELECT MAX(svc_region) FROM dbo.serviceregion sc, dbo.cityzip  WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
                                            WHEN 'REVTYPE3' THEN (SELECT MAX(svc_region) FROM dbo.serviceregion sc, dbo.cityzip  WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
                                            WHEN 'REVTYPE4' THEN (SELECT MAX(svc_region) FROM dbo.serviceregion sc, dbo.cityzip  WHERE o_ctyname = cityzip.cty_nmstct AND lgh_originzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
                                            ELSE 'UNKNOWN'
	                                END),'UNK') 
   ,o_serviceregion_t = @o_serviceregion_labelname
   ,dest_servicezone = ISNULL((SELECT cz_zone FROM dbo.cityzip WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip),'UNK')
   ,dest_servicezone_t = @dest_servicezone_labelname
   ,dest_servicearea = ISNULL((SELECT cz_area FROM dbo.cityzip WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip),'UNK')
   ,dest_servicearea_t = @dest_sericearea_labelname
   ,dest_servicecenter = ISNULL((SELECT CASE ISNULL(@service_revtype,'UNKNOWN')
                                          WHEN 'REVTYPE1' THEN (SELECT MAX(svc_center) FROM dbo.serviceregion sc, dbo.cityzip WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
                                          WHEN 'REVTYPE2' THEN (SELECT MAX(svc_center) FROM dbo.serviceregion sc, dbo.cityzip WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
                                          WHEN 'REVTYPE3' THEN (SELECT MAX(svc_center) FROM dbo.serviceregion sc, dbo.cityzip WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
                                          WHEN 'REVTYPE4' THEN (SELECT MAX(svc_center) FROM dbo.serviceregion sc, dbo.cityzip WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
	                                ELSE 'UNKNOWN'
	                              END),'UNK') 
   ,dest_servicecenter_t = @dest_servicecenter_labelname
   ,dest_serviceregion = ISNULL((SELECT CASE ISNULL(@service_revtype,'UNK')
	                                WHEN 'REVTYPE1' THEN (SELECT MAX(svc_region) FROM dbo.serviceregion sc, dbo.cityzip  WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
	                                WHEN 'REVTYPE2' THEN (SELECT MAX(svc_region) FROM dbo.serviceregion sc, dbo.cityzip  WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
	                                WHEN 'REVTYPE3' THEN (SELECT MAX(svc_region) FROM dbo.serviceregion sc, dbo.cityzip  WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
	                                WHEN 'REVTYPE4' THEN (SELECT MAX(svc_region) FROM dbo.serviceregion sc, dbo.cityzip  WHERE d_ctyname = cityzip.cty_nmstct AND lgh_destzip = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
	                                ELSE 'UNK'
	                              END),'UNK') 
   ,dest_serviceregion_t = @dest_serviceregion_labelname
  FROM 
    @ttbl1 temp1
      INNER JOIN 
    dbo.Orderheader ON orderheader.ord_hdrnumber = temp1.ord_hdrnumber

  /* PTS 22601 - DJM - Remove rows FROM the temp table that do not meet the Localization parameter requirements,
  IF any
  */
  DELETE 
    @ttbl1
  WHERE 
    CHARINDEX(',' + ISNULL(origin_servicezone,'') + ',', @o_servicezone) = 0
      AND 
    @o_servicezone <> ',,'

  DELETE 
    @ttbl1
  WHERE 
    CHARINDEX(',' + ISNULL(origin_servicearea,'') + ',', @o_servicearea) = 0
      AND 
    @o_servicearea <> ',,'

  DELETE 
    @ttbl1
  WHERE 
    CHARINDEX(',' + ISNULL(origin_servicecenter,'') + ',', @o_servicecenter) = 0
      AND 
    @o_servicecenter <> ',,'

  DELETE 
    @ttbl1
  WHERE 
    CHARINDEX(',' + ISNULL(origin_serviceregion,'') + ',', @o_serviceregion) = 0
      AND 
    @o_serviceregion <> ',,'

  DELETE 
    @ttbl1
  WHERE 
    CHARINDEX(',' + ISNULL(dest_servicezone,'') + ',', @dest_servicezone) = 0
      AND 
    @dest_servicezone <> ',,'

  DELETE 
    @ttbl1
  WHERE 
    CHARINDEX(',' + ISNULL(dest_servicearea,'') + ',', @dest_servicearea) = 0
      AND 
    @dest_servicearea <> ',,'

  DELETE 
    @ttbl1
  WHERE 
    CHARINDEX(',' + ISNULL(dest_servicecenter,'') + ',', @dest_servicecenter) = 0
      AND 
    @dest_servicecenter <> ',,'

  DELETE 
    @ttbl1
  WHERE 
    CHARINDEX(',' + ISNULL(dest_serviceregion,'') + ',', @dest_serviceregion) = 0
      AND 
    @dest_serviceregion <> ',,'

  /* PTS 22601 - DJM - UPDATE the table JOIN the localization descriptions */
	UPDATE 
    @ttbl1
  SET 
    origin_servicezone =   ISNULL((SELECT name FROM dbo.labelfile WHERE labeldefinition = 'ServiceZone'   AND abbr = origin_servicezone),'UNKNOWN')
   ,origin_servicearea =   ISNULL((SELECT name FROM dbo.labelfile WHERE labeldefinition = 'ServiceArea'   AND abbr = origin_servicearea),'UNKNOWN')
   ,origin_servicecenter = ISNULL((SELECT name FROM dbo.labelfile WHERE labeldefinition = 'ServiceCenter' AND abbr = origin_servicecenter),'UNKNOWN')
   ,origin_serviceregion = ISNULL((SELECT name FROM dbo.labelfile WHERE labeldefinition = 'ServiceRegion' AND abbr = origin_serviceregion),'UNKNOWN') 
   ,dest_servicezone =     ISNULL((SELECT name FROM dbo.labelfile WHERE labeldefinition = 'ServiceZone'   AND abbr = dest_servicezone),'UNKNOWN')
   ,dest_servicearea =     ISNULL((SELECT name FROM dbo.labelfile WHERE labeldefinition = 'ServiceArea'   AND abbr = dest_servicearea),'UNKNOWN')
   ,dest_servicecenter =   ISNULL((SELECT name FROM dbo.labelfile WHERE labeldefinition = 'ServiceCenter' AND abbr = dest_servicecenter),'UNKNOWN')
   ,dest_serviceregion=    ISNULL((SELECT name FROM dbo.labelfile WHERE labeldefinition = 'ServiceRegion' AND abbr = dest_serviceregion),'UNKNOWN')
END


SELECT 
  @rowsecurity = gi_string1
FROM 
  @GIKEY
WHERE 
  gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' 
BEGIN
  DELETE   
    @ttbl1
  FROM  
    @ttbl1 tp
     --security only IF mov has an associated order
    WHERE EXISTS (SELECT   
                    *
                  FROM  
                    dbo.orderheader oh
                  WHERE 
                    tp.mov_number = oh.mov_number)
            AND 
          NOT EXISTS (SELECT  
                        *
                      FROM  
                        dbo.orderheader oh 
                          INNER JOIN 
                        RowRestrictValidAssignments_orderheader_fn() rsva ON   (oh.rowsec_rsrv_id = rsva.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0)
                      WHERE oh.mov_number = tp.mov_number)
END

--END PTS 51570 JJF 20100510

-- PTS 36608 vjh
-- Only perform the following logic IF the Feature is on.
-- This assumes that all check call times are in the local dispatch TZ
--vjh 38226 TZ sift the departure date before comparison
--vjh 38677 redefine ord_manualeventcallminutes
-- 0 means scheduled arrival
-- -1 means Apocalypse
IF @ManualCheckCall = 'Y'
BEGIN
  UPDATE 
    t
  SET manualcheckcalltime =
      CASE 
        --when s1.stp_status = 'OPN' AND ISNULL(ord_manualeventcallminutes,0) = 0 THEN @Apocalypse
        WHEN s1.stp_status = 'OPN' AND ISNULL(ord_manualeventcallminutes,-1) = -1 THEN @Apocalypse  /* 03/05/2008 MDH PTS 41679: Changed FROM ISNULL (...,0) */
        WHEN s1.stp_status = 'OPN' THEN DATEADD(MINUTE, -1*ISNULL(ord_manualeventcallminutes,0) -
                                        (@v_LocalCityTZAdjFactor - ((ISNULL(cty_GMTDelta,5) + 
                                        (@InDSTFactor * (CASE cty_DSTApplies WHEN 'Y' THEN 0 ELSE +1 END)))* 60) + ISNULL(cty_TZMins,0)), stp_arrivaldate)
        WHEN ISNULL(ord_manualcheckcallminutes,0) = 0 THEN @Apocalypse
        WHEN (SELECT MAX(ckc_date) FROM dbo.checkcall WHERE ckc_lghnumber = t.lgh_number) >
             dateadd(minute, 0 - (@v_LocalCityTZAdjFactor - ((ISNULL(cty_GMTDelta,5) + 
             (@InDSTFactor * (CASE cty_DSTApplies WHEN 'Y' THEN 0 ELSE +1 END)))* 60) + ISNULL(cty_TZMins,0)), stp_departuredate) THEN 
             DATEADD(MINUTE, ISNULL(ord_manualcheckcallminutes,0), (SELECT MAX(ckc_date) FROM dbo.checkcall WHERE ckc_lghnumber = t.lgh_number))
        ELSE dateadd(minute, ISNULL(ord_manualcheckcallminutes,0) -
             (@v_LocalCityTZAdjFactor - ((ISNULL(cty_GMTDelta,5) + (@InDSTFactor * (CASE cty_DSTApplies WHEN 'Y' THEN 0 ELSE +1 END)))* 60) + ISNULL(cty_TZMins,0)), stp_departuredate)
      END
   FROM 
     @ttbl1 t 
       INNER JOIN
     dbo.legheader_active l ON t.lgh_number = l.lgh_number
       INNER JOIN 
     dbo.stops s1 ON l.stp_number_start = s1.stp_number
       INNER JOIN
     dbo.orderheader o WITH (NOLOCK) ON l.ord_hdrnumber = o.ord_hdrnumber
       INNER JOIN
     dbo.city c ON c.cty_code = s1.stp_city
END

/* 35747 DPETE IF GI specified local time xzone compute TImeZone minutes adjustment for each row */
-- PTS 42437 BEGIN SGB updated subquery to tie temp table @ttbl1 lgh_number in WHERE clause
IF @v_GILocalTImeOption = 'LOCAL'
BEGIN
  ;WITH cte AS
  (
     SELECT stp_number, stp_schdtearliest, stp_mfh_sequence, stp_city, lgh_number, mov_number,
           ROW_NUMBER() OVER (PARTITION BY lgh_number, mov_number 
            ORDER BY stp_mfh_sequence, stp_schdtearliest ASC, stp_number ASC) AS rn
     FROM dbo.stops WHERE stp_status = 'DNE'
  )

  UPDATE 
    temp
  SET 
    TimeZoneADJMins = CASE
                        WHEN lgh_outstatus = 'Completed' THEN 0  -- trip is done it cant be late
                        WHEN evt_latedate is null AND lgh_outstatus = 'Started' THEN 0  -- dw sets flag to GREEN for this
                        WHEN evt_latedate is null THEN   -- dw uses lgh_startdate IF htis is true
                                                      @v_LocalCityTZAdjFactor -
                                                     (SELECT 
                                                       ((ISNULL(cty_GMTDelta,5)
                                                       + (@InDSTFactor * (CASE cty_DSTApplies WHEN 'Y' THEN 0 ELSE +1 END))) * 60)
                                                       + ISNULL(cty_TZMins,0)
                                                     FROM 
                                                       dbo.city 
                                                     WHERE 
                                                       cty_code = o_city)
                        ELSE
                              @v_LocalCityTZAdjFactor -
                              (SELECT 
                                ((ISNULL(cty_GMTDelta,5)
                                  + (@InDSTFactor * (CASE cty_DSTApplies WHEN 'Y' THEN 0 ELSE +1 END))) * 60)
                                  + ISNULL(cty_TZMins,0)
                              FROM 
                                dbo.city 
                                  INNER JOIN 
                                cte on cte.stp_city = city.cty_code
	                        WHERE 
                                cte.lgh_number = temp.lgh_number 
	                            AND 
                                cte.mov_number = temp.mov_number 
	                            AND 
                                cte.rn = 1)
        END   --case
  FROM @ttbl1 Temp
END -- BEGIN
--PTS 42437 END
/* 35747 END */

/*
   PTS 38765 - DJM - trc_latest_ctyst AND trc_latest_cmpid added to display the last
   completed stop FROM the current trip.  Only displays data once the trip is started.       */
UPDATE 
  t1
SET 
  t1.trc_latest_ctyst = city.cty_nmstct
 ,t1.trc_latest_cmpid = stops.cmp_id
FROM 
  dbo.stops
    INNER JOIN
  @ttbl1 t1 ON stops.lgh_number = t1.lgh_number
    INNER JOIN
  dbo.city ON stops.stp_city = city.cty_code
WHERE 
  stops.stp_status = 'DNE'
    AND 
  stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM dbo.stops WHERE stops.lgh_number = t1.lgh_number AND stp_status = 'DNE')


UPDATE 
  t1
SET
  trc_last_mobcomm_received = ISNULL(trc.trc_lastpos_DATETIME, '1900/01/01')
 ,trc_mobcomm_type = ISNULL(trc.trc_mobcommtype, 'UNKNOWN')
 ,trc_nearest_mobcomm_nmstct = ISNULL(trc.trc_lastpos_nearctynme, 'UNKNOWN')
 ,trc_lastpos_lat = ISNULL(trc.trc_lastpos_lat,0)               -- PTS 42829 - DJM
 ,trc_lastpos_long = ISNULL(trc.trc_lastpos_long,0)              -- PTS 42829 - DJM
FROM 
  @ttbl1 t1 
    INNER JOIN 
  dbo.tractorprofile trc ON t1.evt_tractor = trc.trc_number
-- END 38765

--vjh pts 38986
IF @PlnWrkshtRefStr1 = 'Y' 
BEGIN
  UPDATE 
    @ttbl1 
  SET 
    ref_type = @PlnWrkshtRefStr3
   ,ref_number = (SELECT 
                    MIN(r.ref_number) 
                  FROM 
                    dbo.referencenumber r 
                  WHERE 
                    r.ref_table=@PlnWrkshtRefStr2 
                      AND 
                    r.ref_type=@PlnWrkshtRefStr3 
                      AND 
                    r.ref_tablekey=s.stp_number)
  FROM 
    @ttbl1 l 
      INNER JOIN 
    dbo.stops s ON l.lgh_number = s.lgh_number
END

--PTS 38138 JJF 20080123
IF EXISTS(SELECT TOP 1 1
          FROM 
            @GIKEY gi
          WHERE 
            gi.gi_name = 'NextDrpRefTypeOnPlanningWst'
              AND 
            ISNULL(gi.gi_string1, '') <> '') 
BEGIN
  UPDATE 
    @ttbl1
  SET 
    next_stop_ref_number = ref.ref_number
  FROM 
    @ttbl1 t1 
      INNER JOIN 
    dbo.legheader_active lgh ON t1.lgh_number = lgh.lgh_number
      INNER JOIN 
    dbo.referencenumber ref ON (lgh.next_drp_stp_number = ref.ref_tablekey AND ref.ref_table = 'stops')
      INNER JOIN
    @GIKEY gi ON ref.ref_type = gi.gi_string1 AND gi.gi_name = 'NextDrpRefTypeOnPlanningWst'        
END
--END PTS 38138 JJF 20080123

--PTS 41795 JJF 20080123
--PTS 48970 JJF 20090914 - add string 4 additional switch
IF EXISTS(SELECT TOP 1 1
          FROM 
            @GIKEY gi
          WHERE 
            gi.gi_name = 'FSCChargeTypes'
              AND 
            ISNULL(gi.gi_string1, '') <> '' 
              AND 
            ISNULL(gi.gi_string4, 'N') = 'Y') 
BEGIN
   SELECT 
     @FSCChargeTypeList = gi.gi_string1
   FROM 
     @GIKEY gi
   WHERE 
     gi.gi_name = 'FSCChargeTypes'

   DECLARE @FSCChargeTypes TABLE  (value VARCHAR(6))

   INSERT @FSCChargeTypes(value) SELECT * FROM CSVStringsToTable_fn(@FSCChargeTypeList)

--BEGIN PTS 55051 MTC 20101207
-- UPDATE @ttbl1
-- SET fsc_fuel_surcharge = ISNULL((SELECT sum(ISNULL(ivd.ivd_charge, 0))
--                      FROM orderheader oh WITH (NOLOCK) INNER JOIN invoicedetail ivd WITH (NOLOCK) ON oh.ord_hdrnumber = ivd.ord_hdrnumber
--                            INNER JOIN @FSCChargeTypes cht ON ivd.cht_itemcode = cht.value
--                      WHERE (t1.mov_number = oh.mov_number) or (t1.ord_hdrnumber = ivd.ord_hdrnumber)
--                   ) ,0)
-- FROM @ttbl1 t1
    UPDATE 
      t1
    SET 
      fsc_fuel_surcharge = ISNULL((SELECT 
                                     SUM(ISNULL(ivd.ivd_charge, 0))
                                   FROM 
                                     dbo.orderheader oh WITH (NOLOCK) 
                                       INNER JOIN 
                                     dbo.invoicedetail ivd WITH (NOLOCK) ON oh.ord_hdrnumber = ivd.ord_hdrnumber
                                       INNER JOIN 
                                     @FSCChargeTypes cht ON ivd.cht_itemcode = cht.value
                                   WHERE 
                                    t1.mov_number = oh.mov_number) 
                                  ,0)
    FROM 
      @ttbl1 t1
    WHERE 
      t1.mov_number = mov_number
--END PTS 55051 MTC 20101207
END
--END PTS 41795 JJF 20080123

/* 08/05/2009 MDH PTS 42293: <<BEGIN>> */
IF @ACSInfo = 'Y'
BEGIN
   -- UPDATE the percentage column
	 -- Need to cast to the decimals to g
  UPDATE 
    @ttbl1
  SET 
    ord_percent = CASE 
                    WHEN lgh_total_mov_miles > 0 THEN CAST(CAST(lgh_miles AS decimal(8,4))/CAST(lgh_total_mov_miles AS decimal(8,4)) AS decimal(8,4))
                    ELSE 1 
                  END
   ,ord_or_leg = CASE 
                   WHEN num_legs > 1 THEN 'Segment'
                   WHEN num_ords = 0 THEN ''
                   ELSE 'Order' 
                 END
   -- UPDATE the pay detail line haul column
   UPDATE 
     x
   SET 
     pyd_linehaul = COALESCE ((SELECT 
                                 SUM (paydetail.pyd_amount)
                               FROM 
                                 dbo.paydetail
                               WHERE 
                                 paydetail.asgn_id = evt_carrier
                                   AND 
                                 paydetail.asgn_type = 'CAR'
                                   AND 
                                 paydetail.lgh_number = x.lgh_number
                                   AND 
                                 paydetail.mov_number = x.mov_number
                                   AND 
                                 paydetail.pyt_itemcode = pyt_linehaul), 0)
   FROM 
     @ttbl1 x
   WHERE 
     pyt_linehaul IS NOT NULL
       AND 
     pyt_linehaul <> ''
END
/* 08/05/2009 MDH PTS 42293: <<END>> */


--PTS 51911 SGB Only run WHEN setting turned on
SELECT 
  @ud_column1 = UPPER(LTRIM(RTRIM(ISNULL(gi_string1,'N')))) 
 ,@ud_column2 = UPPER(LTRIM(RTRIM(ISNULL(gi_string2,'N'))))
 ,@ud_column3 = UPPER(LTRIM(RTRIM(ISNULL(gi_string3,'N'))))
 ,@ud_column4 = UPPER(LTRIM(RTRIM(ISNULL(gi_string4,'N'))))
FROM 
  @GIKEY 
WHERE 
  gi_name = 'UD_STOP_LEG_COLUMNS'

IF @ud_column1 = 'Y'
BEGIN
  SELECT @procname = UPPER(LTRIM(RTRIM(ISNULL(gi_string1,'N')))) FROM @GIKEY WHERE gi_name = 'UD_STOP_LEG_FUNCTIONS'
  IF @procname NOT IN ('','N')
  BEGIN
    SET @udheader = dbo.UD_STOP_LEG_SHELL_FN ('','HS',1)
    UPDATE 
      t
    SET
      ud_column1 = dbo.UD_STOP_LEG_SHELL_FN (t.lgh_number,'LS',1)
     ,ud_column1_t = @udheader
    FROM 
      @ttbl1 t
  END
END

IF @ud_column2 = 'Y'
BEGIN
  SELECT @procname = UPPER(LTRIM(RTRIM(ISNULL(gi_string2,'N')))) FROM @GIKEY WHERE gi_name = 'UD_STOP_LEG_FUNCTIONS'
  IF @procname not in ('','N')
  BEGIN
    SELECT @udheader = DBO.UD_STOP_LEG_SHELL_FN ('','HE',2)
    UPDATE 
      t
    SET 
      ud_column2 = DBO.UD_STOP_LEG_SHELL_FN (t.lgh_number,'LE',2)
     ,ud_column2_t = @udheader
    FROM 
      @ttbl1 t

  END
END

IF @ud_column3 = 'Y'
BEGIN
  SELECT @procname = UPPER(LTRIM(RTRIM(ISNULL(gi_string3,'N')))) FROM @GIKEY WHERE gi_name = 'UD_STOP_LEG_FUNCTIONS'
  IF @procname not in ('','N')
  BEGIN
    SELECT   
      @udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',3)
    
    UPDATE 
      t
    SET
      ud_column3 = dbo.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',3)
     ,ud_column3_t = @udheader
    FROM 
      @ttbl1 t
  END
END

IF @ud_column4 = 'Y'
BEGIN
  SELECT @procname = UPPER(LTRIM(RTRIM(ISNULL(gi_string4,'N')))) FROM @GIKEY WHERE gi_name = 'UD_STOP_LEG_FUNCTIONS'
  IF @procname not in ('','N')
  BEGIN

    SELECT   
      @udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',4)
    
    UPDATE 
      t
    SET
      ud_column4 = DBO.UD_STOP_LEG_SHELL_FN (t.lgh_number,'L',4)
     ,ud_column4_t = @udheader
    FROM 
      @ttbl1 t

  END
END

--PTS52228 MBR 06/27/12
IF @ShowDeliveryAndAppointment = 'Y'
BEGIN
  UPDATE 
    t
  SET 
    stp_custdeliverydate = stops.stp_custdeliverydate
  FROM 
    @ttbl1 t 
      INNER JOIN 
    dbo.stops ON t.lgh_number = stops.lgh_number 
                   AND
                 stops.stp_mfh_sequence = (SELECT 
                                             MAX(stp_mfh_sequence)
                                           FROM 
                                             dbo.stops
                                           WHERE 
                                             stops.lgh_number = t.lgh_number 
                                               AND 
                                             stops.stp_type = 'DRP')
   
   DECLARE @appts VARCHAR(255)
   SELECT @appts = gi_string1 FROM @GIKEY WHERE gi_name = 'Inbound214Appointment'
   IF LEN(@appts) > 0
   BEGIN
     UPDATE 
       t
     SET appt_date = e.update_dt
     FROM 
       @ttbl1 t 
         INNER JOIN 
       dbo.edi_inbound214 e ON t.lgh_number = e.lgh_number 
                                 AND
                               e.id_num = (SELECT 
                                             MAX(id_num)
                                           FROM 
                                             dbo.edi_inbound214
                                               INNER JOIN
                                             dbo.carrier ON carrier.car_id = t.evt_carrier
                                           WHERE 
                                             edi_inbound214.lgh_number = t.lgh_number 
                                               AND
                                             edi_inbound214.process_status = 'ACC' 
                                               AND
                                             CHARINDEX(',' + edi_inbound214.edi_code + ',', ',' + @appts + ',') > 0 
                                               AND
                                             edi_inbound214.car_edi_scac = carrier.car_scac)
                                                                             
  END
END


--SELECT * FROM @ttbl1
SELECT
  lgh_number
 ,o_cmpid
 ,o_cmpname
 ,o_ctyname
 ,d_cmpid
 ,d_cmpname
 ,d_ctyname
 ,f_cmpid
 ,f_cmpname
 ,f_ctyname
 ,l_cmpid
 ,l_cmpname
 ,l_ctyname
 ,lgh_startdate
 ,lgh_ENDdate
 ,o_state
 ,d_state
 ,lgh_schdtearliest
 ,lgh_schdtlatest
 ,cmd_code
 ,fgt_description
 ,cmd_count
 ,ord_hdrnumber
 ,evt_driver1
 ,evt_driver2
 ,evt_tractor
 ,lgh_primary_trailer
 ,trl_type1
 ,evt_carrier
 ,mov_number
 ,ord_availabledate
 ,ord_stopcount
 ,ord_totalcharge
 ,ord_totalweight
 ,ord_length
 ,ord_width
 ,ord_height
 ,ord_totalmiles
 ,ord_number
 ,o_city
 ,d_city
 ,lgh_priority
 ,lgh_outstatus
 ,lgh_instatus
 ,lgh_priority_name
 ,ord_subcompany
 ,trl_type1_name
 ,lgh_class1
 ,lgh_class2
 ,lgh_class3
 ,lgh_class4
 ,SubCompanyLabel
 ,trllabel1
 ,revlabel1
 ,revlabel2
 ,revlabel3
 ,revlabel4
 ,ord_bookedby
 ,dw_rowstatus
 ,lgh_primary_pup
 ,triptime
 ,ord_totalweightunits
 ,ord_lengthunit
 ,ord_widthunit
 ,ord_heightunit
 ,loadtime
 ,unloadtime
 ,unloaddttm
 ,unloaddttm_early
 ,unloaddttm_late
 ,ord_totalvolume
 ,ord_totalvolumeunits
 ,washstatus
 ,f_state
 ,l_state
 ,evt_driver1_id
 ,evt_driver2_id
 ,ref_type
 ,ref_number
 ,d_address1
 ,d_address2
 ,ord_remark
 ,mpp_teamleader
 ,lgh_dsp_date
 ,lgh_geo_date
 ,ordercount
 ,npup_cmpid
 ,npup_cmpname
 ,npup_ctyname
 ,npup_state
 ,npup_arrivaldate
 ,ndrp_cmpid
 ,ndrp_cmpname
 ,ndrp_ctyname
 ,ndrp_state
 ,ndrp_arrivaldate
 ,can_ld_expires
 ,xdock
 ,feetavailable
 ,opt_trc_type4
 ,opt_trc_type4_label
 ,opt_trl_type4
 ,opt_trl_type4_label
 ,ord_originregion1
 ,ord_originregion2
 ,ord_originregion3
 ,ord_originregion4
 ,ord_destregion1
 ,ord_destregion2
 ,ord_destregion3
 ,ord_destregion4
 ,npup_departuredate
 ,ndrp_departuredate
 ,ord_FROMorder
 ,c_lgh_type1
 ,lgh_type1_label
 ,c_lgh_type2
 ,lgh_type2_label
 ,lgh_tm_status
 ,lgh_tour_number
 ,extrainfo1
 ,extrainfo2
 ,extrainfo3
 ,extrainfo4
 ,extrainfo5
 ,extrainfo6
 ,extrainfo7
 ,extrainfo8
 ,extrainfo9
 ,extrainfo10
 ,extrainfo11
 ,extrainfo12
 ,extrainfo13
 ,extrainfo14
 ,extrainfo15
 ,o_cmp_geoloc
 ,d_cmp_geoloc
 ,mpp_fleet
 ,mpp_fleet_name
 ,next_stp_event_code
 ,next_stop_of_total
 ,lgh_comment
 ,lgh_earliest_pu
 ,lgh_latest_pu
 ,lgh_earliest_unl
 ,lgh_latest_unl
 ,lgh_miles
 ,lgh_linehaul
 ,evt_latedate
 ,lgh_ord_charge
 ,lgh_act_weight
 ,lgh_est_weight
 ,lgh_tot_weight
 ,lgh_outstat
 ,lgh_max_weight_exceeded
 ,lgh_reftype
 ,lgh_refnum
 ,trctype1
 ,trc_type1name
 ,trctype2
 ,trc_type2name
 ,trctype3
 ,trc_type3name
 ,trctype4
 ,trc_type4name
 ,lgh_etaalert1
 ,lgh_detstatus
 ,lgh_tm_statusname
 ,ord_billto
 ,cmp_name
 ,lgh_carrier
 ,TotalCarrierPay
 ,lgh_hzd_cmd_class
 ,lgh_washplan
 ,COALESCE(fgt_length, 0) fgt_length
 ,COALESCE(fgt_width, 0) fgt_width
 ,COALESCE(fgt_height, 0) fgt_height 
 ,lgh_originzip
 ,lgh_destzip
 ,ord_company
 ,origin_servicezone
 ,o_servicezone_t
 ,origin_servicearea
 ,o_servicearea_t
 ,origin_servicecenter
 ,o_servicecenter_t
 ,origin_serviceregion
 ,o_serviceregion_t
 ,dest_servicezone
 ,dest_servicezone_t
 ,dest_servicearea
 ,dest_servicearea_t
 ,dest_servicecenter
 ,dest_servicecenter_t
 ,dest_serviceregion
 ,dest_serviceregion_t
 ,lgh_204status
 ,origin_cmp_lat
 ,origin_cmp_long
 ,origin_cty_lat
 ,origin_cty_long
 ,lgh_route
 ,lgh_booked_revtype1
 ,lgh_permit_status
 ,lgh_permit_status_t
 ,lgh_204date
 ,next_ndrp_cmpid
 ,next_ndrp_cmpname
 ,next_ndrp_ctyname
 ,next_ndrp_state
 ,next_ndrp_arrivaldate
 ,ord_bookdate
 ,lgh_ace_status_name
 ,manualcheckcalltime
 ,evt_earlydate
 ,TimeZoneAdjMins
 ,locked_by
 ,session_date
 ,ord_cbp
 ,lgh_ace_status
 ,trc_latest_ctyst
 ,trc_latest_cmpid
 ,trc_last_mobcomm_received
 ,trc_mobcomm_type
 ,trc_nearest_mobcomm_nmstct
 ,next_stop_ref_number   --PTS 38138 JJF 20080122
 ,compartment_loaded     --PTS29383 MBR 08/17/05 40762
 ,trc_lastpos_lat     -- PTS 42829
 ,trc_lastpos_long    -- PTS 42829
 ,fsc_fuel_surcharge     --PTS 41795 JJF 20080506
 /* 08/27/2008 MDH PTS 42301: <<BEGIN>> */
 ,ord_ref_type_2 
 ,ord_ref_number_2
 ,ord_ref_type_3 
 ,ord_ref_number_3
 ,ord_ref_type_4 
 ,ord_ref_number_4
 ,ord_ref_type_5 
 ,ord_ref_number_5
 /* 08/27/2008 MDH PTS 42301: <<END>> */
 ,0 org_distFROM    -- PTS 45271 - DJM
 ,0 dest_distFROM      -- PTS 45271 - DJM
 ,lgh_total_mov_bill_miles   /* 07/31/2009 MDH PTS 42281: Added */
 ,lgh_total_mov_miles         /* 07/31/2009 MDH PTS 42281: Added */
 /* 07/22/2009 MDH PTS 42293: <<BEGIN>> */
 ,num_legs            
 ,num_ords          
 ,pyt_linehaul            
 ,pyd_accessorials     
 ,pyd_fuel          
 ,pyd_linehaul         
 ,pyd_total
 ,(COALESCE (ord_accessorials, 0.0) - COALESCE (ord_fuel, 0.0)) * COALESCE (ord_percent, 1.0)  charge --DANDREWS
 ,COALESCE (ord_fuel, 0.0) * COALESCE (ord_percent, 1.0) fuel --DANDREWS
 ,COALESCE (ord_linehaul, 0.0) * COALESCE (ord_percent, 1.0) linehaul
 ,COALESCE (ord_total_charge, 0.0) * COALESCE (ord_percent, 1.0) total_charge
 ,ord_or_leg       
 ,COALESCE (ord_percent, 1.0) p_ord_percent
 /* 07/22/2009 MDH PTS 42293: <<END>> */
 ,ma_transaction_id                                          -- RE - PTS #52017
 ,CASE                                                  -- RE - PTS #52017
    WHEN ma_transaction_id IS NULL THEN @null_int                  -- RE - PTS #52017
    ELSE dbo.Load_MATourNumber_fn(@DefaultCompanyID, ma_transaction_id, lgh_number)     -- RE - PTS #52017
  END     Load_MAReccomENDation_fn                                             -- RE - PTS #52017
 ,@null_varchar8 blank1                                            -- RE - PTS #52017
 ,@null_varchar8    blank2                                         -- RE - PTS #52017
 ,CASE                                                  -- RE - PTS #52017
    WHEN ma_transaction_id IS NULL THEN @null_varchar100           -- RE - PTS #52017
    ELSE dbo.Load_MAReccomENDation_fn(@DefaultCompanyID, ma_transaction_id, lgh_number) -- RE - PTS #52017
  END     Load_MAReccomendation                                             -- RE - PTS #52017
 ,mile_overage_message      /* 08/31/2009 MDH PTS 42281: Added */
 ,all_ord_totalcharge * ord_percent       p_all_ord_totalcharge /* 09/08/2009 MDH PTS 42293: Added */
 ,all_ord_revenue_pay  * ord_percent p_all_ord_revenue_pay /* 09/08/2009 MDH PTS 42293: Added */
 ,lgh_raildispatchstatus    --PTS46536 MBR 10/15/09
 ,car_204tENDer       --PTS46536 MBR 10/15/09
 ,car_204UPDATE       --PTS46536 MBR 10/15/09
 ,lgh_car_rate        --PTS42845 MBR 12/18/09
 ,lgh_car_charge         --PTS42845 MBR 12/18/09
 ,lgh_car_accessorials      --PTS42845 MBR 12/18/09
 ,lgh_car_totalcharge    --PTS42845 MBR 12/18/09
 ,lgh_recommENDed_car_id    --PTS42845 MBR 12/18/09
 ,lgh_spot_rate       --PTS42845 MBR 12/18/09
 ,lgh_edi_counter     --PTS42845 MBR 12/18/09
 ,lgh_ship_status     --PTS42845 MBR 12/18/09
 ,lgh_faxemail_created      --PTS42845 MBR 12/18/09
 ,lgh_externalrating_miles  --PTS42845 MBR 12/18/09
 ,lgh_acc_fsc         --PTS42845 MBR 12/18/09
 ,lgh_chassis
 ,lgh_chassis2
 ,lgh_dolly
 ,lgh_dolly2
 ,lgh_trailer3
 ,lgh_trailer4
 ,ord_order_source     /* 08/19/2010 MDH PTS 52714: Added */
 ,ud_column1        -- PTS 51911 SGB User Defined column
 ,ud_column1_t      --   PTS 51911 SGB User Defined column header
 ,ud_column2        -- PTS 51911 SGB User Defined column
 ,ud_column2_t      --   PTS 51911 SGB User Defined column header
 ,ud_column3        -- PTS 51911 SGB User Defined column
 ,ud_column3_t      --   PTS 51911 SGB User Defined column header
 ,ud_column4        -- PTS 51911 SGB User Defined column
 ,ud_column4_t      --   PTS 51911 SGB User Defined column header
 ,o_tzminutes	/* 04/19/2012 MDH PTS 60772: Added */
 ,d_tzminutes
 ,stp_custdeliverydate	--PTS52228 MBR 06/27/12
 ,appt_date	--PTS52228 MBR 06/27/12
 ,Direct_route_status1 --PTS 66628 KPM 2/5/13	
FROM 
  @ttbl1


GO
GRANT EXECUTE ON  [dbo].[outbound_view] TO [public]
GO
