SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 
  
create procedure [dbo].[SSRS_RB_TRIPSHEET_02]

--execute SSRS_RB_TRIPSHEET_02 @lgh_number = 650
 @lgh_number integer  
as  

  
Declare @Service_revtype  varchar(10),  
 @servicezone_labelname   varchar(20),  
 @servicecenter_labelname  varchar(20),  
 @serviceregion_labelname  varchar(20),  
 @sericearea_labelname   varchar(20),  
 @localization   char(1),  
 @lgh_permit_status   varchar(20),  
 @NewCompanyHours  CHAR(1),  
 @cmp_id    VARCHAR(8),  
        @arrivaldate   DATETIME,  
 @stp_number   INTEGER,  
        @ord_hdrnumber   INTEGER,  
 @stp_type   VARCHAR(6),  
 @open_dt   DATETIME,  
        @close_dt   DATETIME  
  

declare @rowsecurity char(1)  
declare @tmwuser varchar(255)  
declare @ordercount int  
declare @orderpassrestrictioncount int  
declare @retrievetrip int  

  

CREATE TABLE #temp (  
 driver1    VARCHAR(8) NULL,  
 driver2    VARCHAR(8) NULL,  
 tractor    VARCHAR(8) NULL,  
 trailer1   VARCHAR(13) NULL,  
 trailer2    VARCHAR(13) NULL,  
 ord_hdrnumber   INT NULL,  
 stp_number   INT NULL,  
 stp_city   INT NULL,  
 arrivaldate   DATETIME NULL,  
 earliestdate  DATETIME NULL,  
 latestdate   DATETIME NULL,  
 cmp_id    VARCHAR(8) NULL,  
 cmp_name   VARCHAR(30) NULL,  
 cmp_address1 varchar(50) NULL,
 cmp_city varchar(30) NULL,
 cmp_zip varchar(15) NULL,
 departuredate  DATETIME NULL,  
 reasonlate_arrival VARCHAR(6) NULL,  
 lgh_number   INT NULL,  
 reasonlate_depart VARCHAR(6) NULL,  
 stp_sequence  INT NULL,  
 comment    VARCHAR(254) NULL,  
 hubmiles   INT NULL,  
 ord_refnum   VARCHAR(30) NULL,  
 carrier    VARCHAR(8) NULL,  
 carrier_name    VARCHAR(100) NULL,  
 ord_reftype   VARCHAR(6) NULL,  
 evt_sequence  INT NULL,  
 mfh_sequence  INT NULL,  
 fgt_sequence  SMALLINT NULL,  
 fgt_number   INT NULL,  
 cmd_code   VARCHAR(8) NULL,  
 cmd_description  VARCHAR(60) NULL,  
 weight    FLOAT NULL,  
 weightunit   VARCHAR(6) NULL,  
 cnt     DECIMAL(10, 2) NULL,  
 countunit   VARCHAR(6) NULL,  
 volume    FLOAT NULL,  
 volumeunit   VARCHAR(6) NULL,  
 quantity   FLOAT NULL,  
 quantityunit  VARCHAR(6) NULL,  
 fgt_reftype   VARCHAR(6) NULL,  
 fgt_refnum   VARCHAR(30) NULL,  
 customer   VARCHAR(8) NULL,  
 evt_number   INT NULL,  
 evt_pu_dr   VARCHAR(6) NULL,  
 eventcode   VARCHAR(6) NULL,  
 evt_status   VARCHAR(6) NULL,  
 mfh_mileage   INT NULL,  
 ord_mileage   INT NULL,  
 lgh_mileage   INT NULL,  
 mfh_number   INT NULL,  
 billto_name   VARCHAR(100) NULL,  
 cty_nmstct   VARCHAR(30) NULL,  
 mov_number   INT NULL,  
 stp_origschdt  DATETIME NULL,  
 stp_paylegpt  CHAR(1) NULL,  
 stp_region1   VARCHAR(6) NULL,  
 stp_region2   VARCHAR(6) NULL,  
 stp_region3   VARCHAR(6) NULL,  
 stp_region4   VARCHAR(6) NULL,  
 stp_state   VARCHAR(6) NULL,  
 skip_trigger  INT NULL,  
 lgh_outstatus  VARCHAR(6) NULL,  
 user0    INT NULL,  
 stp_reftype   VARCHAR(6) NULL,  
 stp_refnum   VARCHAR(30) NULL,  
 user1    VARCHAR(1) NULL,  
 user2    VARCHAR(1) NULL,  
 user3    VARCHAR(1) NULL,  
 stp_refnumcount  INT NULL,  
 fgt_refnumcount  INT NULL,  
 ord_refnumcount  INT NULL,  
 stp_loadstatus  CHAR(3) NULL,  
 notes_count   INT NULL,  
 to_miletype   VARCHAR(6) NULL,  
 from_miletype  VARCHAR(6) NULL,  
 tare_weight   FLOAT NULL,  
 tare_weightunit  VARCHAR(6) NULL,  
 lgh_type1   VARCHAR(6) NULL,  
 lgh_type1_t   VARCHAR(8) NULL,  
 stp_type1   VARCHAR(6) NULL,  
 stp_redeliver  VARCHAR(1) NULL,  
 stp_osd    VARCHAR(1) NULL,  
 stp_pudelpref  VARCHAR(10) NULL,  
 ord_company   VARCHAR(8) NULL,  
 stp_phonenumber  VARCHAR(20) NULL,  
 stp_delayhours  FLOAT NULL,  
 stp_ooa_mileage  FLOAT NULL,  
 fgt_pallets_in  FLOAT NULL,  
 fgt_pallets_out  FLOAT NULL,  
 fgt_pallets_on_trailer FLOAT NULL,  
 fgt_carryins1   FLOAT NULL,  
 fgt_carryins2   FLOAT NULL,  
 stp_zipcode    VARCHAR(10) NULL,  
 stp_OOA_stop   INT NULL,  
 stp_address    VARCHAR(40) NULL,  
 stp_transfer_stp  INT NULL,  
 stp_contact    VARCHAR(30) NULL,  
 stp_phonenumber2  VARCHAR(20) NULL,  
 stp_address2   VARCHAR(40) NULL,  
 billable_flag   INT NULL,  
 ord_revtype1   VARCHAR(6) NULL,  
 ord_revtype2   VARCHAR(6) NULL,  
 ord_revtype3   VARCHAR(6) NULL,  
 ord_revtype4   VARCHAR(6) NULL,  
 ord_revtype1_t   VARCHAR(8) NULL,  
 ord_revtype2_t   VARCHAR(8) NULL,  
 ord_revtype3_t   VARCHAR(8) NULL,  
 ord_revtype4_t   VARCHAR(8) NULL,  
 stp_custpickupdate  DATETIME NULL,  
 stp_custdeliverydate DATETIME NULL,  
 lgh_dispatchdate  DATETIME NULL,  
 fgt_length    FLOAT NULL,  
 fgt_length_feet   INT NULL,  
 fgt_length_inches  INT NULL,  
 fgt_width    FLOAT NULL,  
 fgt_width_feet   INT NULL,  
 fgt_width_inches  INT NULL,  
 fgt_height    FLOAT NULL,  
 fgt_height_feet   INT NULL,  
 fgt_height_inches  INT NULL,  
 fgt_stackable   VARCHAR(1) NULL,  
 stp_podname    VARCHAR(20) NULL,  
 lgh_feetavailable  SMALLINT NULL,  
 stp_cmp_close   INT NULL,  
 stp_departure_status VARCHAR(6) NULL,  
 fgt_ordered_count  REAL NULL,  
 fgt_ordered_weight  FLOAT NULL,  
 stp_activitystart_dt DATETIME NULL,  
 stp_activityend_dt  DATETIME NULL,  
 stp_eta     DATETIME NULL,  
 stp_etd     DATETIME NULL,  
 fgt_rate    MONEY NULL,  
 fgt_charge    MONEY NULL,  
 fgt_rateunit   VARCHAR(6) NULL,  
 cht_itemcode   VARCHAR(6) NULL,  
 stp_transfer_type  CHAR(3) NULL,  
 cht_basisunit   VARCHAR(6) NULL,  
 fgt_quantity_type  SMALLINT NULL,  
 fgt_charge_type   SMALLINT NULL,  
 tar_number    INT NULL,  
 tar_tariffnumber  VARCHAR(13) NULL,  
 tar_tariffitem   VARCHAR(13) NULL,  
 fgt_ratingquantity  FLOAT NULL,  
 fgt_ratingunit   VARCHAR(6) NULL,  
 inv_protect    INT NULL,  
 fgt_rate_type   SMALLINT NULL,  
 cmp_geoloc    VARCHAR(50) NULL,  
 lgh_type2    VARCHAR(6) NULL,  
 lgh_type2_t    VARCHAR(8) NULL,  
 psh_number    INT NULL,  
 stp_advreturnempty  INT NULL,  
 stp_country    VARCHAR(50) NULL,  
 loadingmeters   DECIMAL(12, 4) NULL,  
 loadingmetersunit  VARCHAR(6) NULL,  
 fgt_additionl_description VARCHAR(25) NULL,  
 stp_cod_amount   DECIMAL(8, 2) NULL,  
 stp_cod_currency  VARCHAR(6) NULL,  
 fgt_specific_flashpoint FLOAT NULL,  
 fgt_specific_flashpoint_unit VARCHAR(6) NULL,  
 fgt_ordered_volume  DECIMAL(18, 0) NULL,  
 fgt_ordered_loadingmeters DECIMAL(18, 0) NULL,  
 fgt_pallet_type   VARCHAR(6) NULL,  
 act_weight    INT NULL,  
 est_weight    FLOAT NULL,  
 lgh_comment    VARCHAR(255) NULL,  
 lgh_reftype    VARCHAR(6) NULL,  
 lgh_refnum    VARCHAR(30) NULL,  
 lgh_refnumcount   INT NULL,  
 stp_alloweddet   INT NULL,  
 stp_gfc_arr_radius  DECIMAL(7, 2) NULL,  
 stp_gfc_arr_radiusunits VARCHAR(6) NULL,  
 stp_gfc_arr_timeout  INT NULL,  
 stp_tmstatus   VARCHAR(6) NULL,  
 Driver1name    VARCHAR(45) NULL,  
 Driver2name    VARCHAR(45) NULL,  
 stp_reasonlate_text  VARCHAR(255) NULL,  
 stp_reasonlate_depart_text VARCHAR(255) NULL,  
 cpr_density    DECIMAL(9, 4) NULL,  
 scm_subcode    VARCHAR(8) NULL,  
 nlm_time_diff   INT NULL,  
 stp_lgh_mileage_mtid INT NULL,  
 fgt_consignee   CHAR(8) NULL,  
 fgt_shipper    CHAR(8) NULL,  
 fgt_leg_origin   CHAR(8) NULL,  
 fgt_leg_dest   CHAR(8) NULL,  
 fgt_bolid    INT NULL,  
 fgt_count2    DECIMAL(10, 2) NULL,  
 fgt_count2unit   VARCHAR(6) NULL,  
 fgt_terms    CHAR(6) NULL,  
 fgt_bol_status   VARCHAR(6) NULL,  
 inv_protect_except  INT NULL,  
 lgh_nexttrailer1  VARCHAR(13) NULL,  
 lgh_nexttrailer2  VARCHAR(13) NULL,  
 stp_detstatus   INT   NULL,  
 stp_est_drv_time  INT   NULL,  
 stp_est_activity  INT   NULL,  
 service_zone   VARCHAR(7) NULL,  
 service_zone_t   VARCHAR(12) NULL,  
 service_area   VARCHAR(7) NULL,  
 service_area_t   VARCHAR(12) NULL,  
 service_center   VARCHAR(7) NULL,  
 service_center_t  VARCHAR(14) NULL,  
 service_region   VARCHAR(7) NULL,  
 service_region_t  VARCHAR(14) NULL,  
 stp_mileage_mtid  INT   NULL,  
 stp_ooa_mileage_mtid INT   NULL,  
 lgh_route    VARCHAR(15) NULL,  
 lgh_booked_revtype1  VARCHAR(12) NULL,  
 booked_revtype1_t  VARCHAR(25) NULL,  
 last_updateby   VARCHAR(256) NULL,  
 last_updatedate   DATETIME NULL,  
 lgh_permit_status  VARCHAR(6) NULL,  
 lgh_permit_status_t  VARCHAR(20) NULL,  
 last_updatebydepart  VARCHAR(256) NULL,  
 last_updatedatedepart DATETIME NULL,  
 fgt_osdreason   VARCHAR(6) NULL,  
 fgt_osdquantity   INT   NULL,  
 fgt_osdunit    VARCHAR(6) NULL,  
 fgt_osdcomment   VARCHAR(255) NULL,  
 ord_no_recalc_miles  CHAR(1)  NULL,  
 lgh_204status   VARCHAR(6) NULL,  
 lgh_204date    DATETIME NULL,  
 cmp_pri1now    INT   NULL,  
 cmp_pri1soon   INT   NULL,  
 cmp_pri2now    INT   NULL,  
 cmp_pri2soon   INT   NULL,  
 fgt_packageunit   VARCHAR(6) NULL,  
 stp_unload_paytype  VARCHAR(6) NULL,  
 stp_transferred   CHAR(1)  NULL,  
 lgh_type3    VARCHAR(6) NULL,  
 lgh_type3_t    VARCHAR(8) NULL,  
 lgh_type4    VARCHAR(6) NULL,  
 lgh_type4_t    VARCHAR(8) NULL,  
 fgt_packageunit_t  VARCHAR(12) NULL,  
 evt_hubmiles_trailer1 INT   NULL,  
 evt_hubmiles_trailer2 INT   NULL,  
 ord_dest_zip   VARCHAR(10) NULL,  
 ord_remark    VARCHAR(254) NULL,  
 ord_totalvolume   FLOAT  NULL,  
 ord_totalvolumeunits VARCHAR(6) NULL,  
 stp_reasonlate_min  INT   NULL,  
 stp_reasonlate_depart_min INT  NULL,  
 reasonlate_count  INT   NULL,  
 reasonlate_depart_count INT   NULL,  
 stp_ord_toll_cost  MONEY  NULL,  
 fgt_osdstatus   VARCHAR(6) NULL,  
 fgt_osdopendate   DATETIME NULL,  
 fgt_osdclosedate  DATETIME NULL,  
 fgt_osdorigclaimamount MONEY  NULL,  
 fgt_osdamtpaid   MONEY  NULL,  
 fgt_osdamtreceived  MONEY  NULL,  
 lgh_permitnumbers  VARCHAR(254) NULL,  
 lgh_permitby   VARCHAR(12) NULL,    
 lgh_permitdate   DATETIME NULL,  
 tank_loc    VARCHAR(10) NULL,  
 stp_rescheduledate  DATETIME NULL,  
 cmp_open    DATETIME NULL,  
 cmp_close    DATETIME NULL,  
 stp_origarrival   DATETIME NULL,  
 trl1_prefix    VARCHAR(32) NULL,  
 trl2_prefix    VARCHAR(32) NULL,  
 stp_type2    VARCHAR(6) NULL,  
 stp_type3    VARCHAR(6) NULL,  
 stp_type2_t    VARCHAR(8) NULL,  
 stp_type3_t    VARCHAR(8) NULL,  
 stp_delay_eligible  varchar(1) null,    
 stp_firm_appt_flag  varchar(1) null,   
 lgh_car_rate   MONEY  NULL,  
 lgh_car_charge   MONEY  NULL,  
 lgh_car_accessorials  DECIMAL(12,4) NULL, 
 lgh_car_totalcharge  MONEY  NULL, 
 lgh_spot_rate   CHAR(1)  NULL, 
 lgh_faxemail_created  CHAR(1)  NULL,
 lgh_acc_fsc   MONEY  NULL, 
 evt_chassis    varchar(13) NULL,  
 evt_chassis2   varchar(13) NULL,  
 evt_dolly    varchar(13) NULL,  
 evt_dolly2    varchar(13) NULL,    
 evt_trailer3   varchar(13) NULL,   
 evt_trailer4   varchar(13) NULL,   
 fgt_volume2             FLOAT       NULL,  
 fgt_volume2unit         VARCHAR (6) NULL,   
 fgt_volumeunit2         VARCHAR (6) NULL


)  
  
  
Select @service_revtype = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'ServiceRegionRevType'  
select @servicezone_labelname =  ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )  
select @servicecenter_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )  
select @serviceregion_labelname =  (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )  
select @sericearea_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )  
select @lgh_permit_status = ( SELECT TOP 1 LGHPermitStatus FROM labelfile_headers)  

SELECT @NewCompanyHours = UPPER(LEFT(ISNULL(gi_string1, 'N'),1))  
  FROM generalinfo  
 WHERE gi_name = 'NewCompanyHours'  
  
SET @retrievetrip = 1  
  
SELECT @rowsecurity = gi_string1  
FROM generalinfo   
WHERE gi_name = 'RowSecurity'  

exec @tmwuser = dbo.gettmwuser_fn  
  
 
IF @rowsecurity = 'Y' BEGIN   
  
 --Do any orders pass security?  
 SELECT @orderpassrestrictioncount = count(*)  
  FROM stops  
  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code     
    LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number     
    LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber  
  join event on stops.stp_number = event.stp_number  
  join freightdetail on  freightdetail.stp_number = stops.stp_number
  join eventcodetable  on event.evt_eventcode = eventcodetable.abbr 
 WHERE  --and --pts40187 removed the outer join since it is not necessary any more from Ron  
  
  stops.lgh_number = @lgh_number and  
  (evt_sequence = 1 or fgt_sequence = 1)  
  AND dbo.RowRestrictByUser('orderheader', orderheader.rowsec_rsrv_id, '', '', '') = 1  
  
 --any orders?  
 SELECT @ordercount = count(*)  
  FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code     
    LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number     
    LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber 
  join event on stops.stp_number = event.stp_number  
  join freightdetail on  freightdetail.stp_number = stops.stp_number
  join eventcodetable  on event.evt_eventcode = eventcodetable.abbr
 WHERE  --pts40187 removed the outer join since it is not necessary any more from Ron  
    stops.lgh_number = @lgh_number and  
  (evt_sequence = 1 or fgt_sequence = 1)  
  AND orderheader.ord_hdrnumber > 0   
  
 IF @ordercount > 0 BEGIN  
  IF @orderpassrestrictioncount = 0 BEGIN  
   SET @retrievetrip = 0  
  END  
 END  
 ELSE BEGIN  
  --make sure associated tractors at least are present  
  SELECT @orderpassrestrictioncount = count(*)  
   FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code     
     LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number     
     LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber   
     LEFT OUTER JOIN event on stops.stp_number = event.stp_number   
     LEFT OUTER JOIN tractorprofile trc on event.evt_tractor = trc.trc_number
   join freightdetail on freightdetail.stp_number = stops.stp_number 
   join eventcodetable  on event.evt_eventcode = eventcodetable.abbr 
  WHERE 
      stops.lgh_number = @lgh_number and  
   (evt_sequence = 1 or fgt_sequence = 1)  
   AND dbo.RowRestrictByUser('tractorprofile', trc.rowsec_rsrv_id, '', '', '') = 1  
  
  IF @orderpassrestrictioncount = 0 BEGIN  
   SELECT @retrievetrip = 0  
  END   
 END  
END  

select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'  
  
  
if Left(@localization,1) <> 'Y'  
 Begin  
                INSERT INTO #temp  
  SELECT event.evt_driver1 driver1,   
   event.evt_driver2 driver2,   
   event.evt_tractor tractor,   
   event.evt_trailer1 trailer1,   
   event.evt_trailer2 trailer2,   
   stops.ord_hdrnumber,   
   stops.stp_number,   
   stops.stp_city stp_city,   
   event.evt_startdate arrivaldate,   
   event.evt_earlydate earliestdate,   
   event.evt_latedate latestdate,   
   stops.cmp_id,   
   stops.cmp_name,
   (select cmp_address1 from company C where C.cmp_id = stops.cmp_id),
   (select cty_name from city where city.cty_code = stops.stp_city),
   stops.stp_zipcode,   
   evt_enddate departuredate,   
   stops.stp_reasonlate reasonlate_arrival,   
   stops.lgh_number,   
   stops.stp_reasonlate_depart reasonlate_depart,   
   stops.stp_sequence,   
   stops.stp_comment comment,   
   event.evt_hubmiles hubmiles,   
   orderheader.ord_refnum,   
   event.evt_carrier carrier,  
   (select car_name from carrier where car_id = event.evt_carrier), 
   orderheader.ord_reftype,   
   event.evt_sequence,   
   stops.stp_mfh_sequence mfh_sequence,   
   freightdetail.fgt_sequence,   
   freightdetail.fgt_number,   
   freightdetail.cmd_code,   
   freightdetail.fgt_description cmd_description,   
   freightdetail.fgt_weight weight,   
   freightdetail.fgt_weightunit weightunit,   
   freightdetail.fgt_count cnt,   
   freightdetail.fgt_countunit countunit,   
   freightdetail.fgt_volume volume,   
   freightdetail.fgt_volumeunit volumeunit,  
   freightdetail.fgt_quantity quantity,   
   freightdetail.fgt_unit quantityunit,   
   freightdetail.fgt_reftype,   
   freightdetail.fgt_refnum, 
   orderheader.ord_billto customer,     
   event.evt_number,   
   event.evt_pu_dr evt_pu_dr,   
   event.evt_eventcode eventcode, 
   Case event.evt_status
		When 'OPN' then 'E'
		When 'DNE' then 'A'
		Else event.evt_status
		end as evt_status,   
   stops.stp_mfh_mileage mfh_mileage,   
   stops.stp_ord_mileage ord_mileage,   
   stops.stp_lgh_mileage lgh_mileage,   
   stops.mfh_number,   
    (select cmp_name  
   from company  
   where company.cmp_id = orderheader.ord_billto) billto_name,  
   city.cty_nmstct cty_nmstct,   
   stops.mov_number,   
   stops.stp_origschdt,   
   stops.stp_paylegpt,   
   stops.stp_region1,   
   stops.stp_region2,   
   stops.stp_region3,   
   stops.stp_region4,   
   stops.stp_state ,  
   1 skip_trigger,  
   lgh_outstatus,  
   0 user0,  
   stops.stp_reftype,  
   stops.stp_refnum,   
   ' ' user1,    
   ' ' user2,  
   ' ' user3,  
   0 stp_refnumcount,  
   0 fgt_refnumcount,  
   0 ord_refnumcount,   
   stops.stp_loadstatus,   
   0 notes_count,  
   eventcodetable.mile_typ_to_stop to_miletype,  
   eventcodetable.mile_typ_from_stop from_miletype,  
   freightdetail.tare_weight,   
   freightdetail.tare_weightunit,  
   lgh_type1,  
   'LghType1' lgh_type1_t,   
   stops.stp_type1,   
   stops.stp_redeliver,   
   stops.stp_osd,   
   stops.stp_pudelpref,   
   orderheader.ord_company,   
   stops.stp_phonenumber,   
   stops.stp_delayhours,   
   stops.stp_ooa_mileage,   
   freightdetail.fgt_pallets_in,   
   freightdetail.fgt_pallets_out,   
   freightdetail.fgt_pallets_on_trailer,   
   freightdetail.fgt_carryins1,   
   freightdetail.fgt_carryins2,   
   stops.stp_zipcode,   
   stops.stp_OOA_stop,   
   stops.stp_address,   
   stops.stp_transfer_stp,   
   stops.stp_contact,   
   stops.stp_phonenumber2,   
   stops.stp_address2,   
   CASE stops.ord_hdrnumber   
   WHEN 0 THEN 0  
   WHEN NULL THEN 0  
   ELSE 1  
   END billable_flag,   
   ord_revtype1,   
   ord_revtype2,   
   ord_revtype3,   
   ord_revtype4,   
   'RevType1' ord_revtype1_t,   
   'RevType2' ord_revtype2_t,   
   'RevType3' ord_revtype3_t,   
   'RevType4' ord_revtype4_t,  
   stops.stp_custpickupdate,  
   stops.stp_custdeliverydate,  
   legheader.lgh_dispatchdate,  
   freightdetail.fgt_length,  
   CAST(ROUND(fgt_length, 0) AS int) / 12 AS fgt_length_feet,   
   CAST(ROUND(fgt_length, 0) AS int) % 12 AS fgt_length_inches,   
   freightdetail.fgt_width,  
   CAST(ROUND(fgt_width, 0) AS int) / 12 AS fgt_width_feet,   
   CAST(ROUND(fgt_width, 0) AS int) % 12 AS fgt_width_inches,   
   freightdetail.fgt_height,  
   CAST(ROUND(fgt_height, 0) AS int) / 12 AS fgt_height_feet,   
   CAST(ROUND(fgt_height, 0) AS int) % 12 AS fgt_height_inches,   
   freightdetail.fgt_stackable,  
   stops.stp_podname,  
   legheader.lgh_feetavailable,  
   stops.stp_cmp_close,  
   CASE EVT_Sequence   
    WHEN 1 THEN isnull(stops.stp_departure_status,'OPN')  
    ELSE isnull(EVENT.evt_departure_status,'OPN')  
   END,   
   freightdetail.fgt_ordered_count,  
   freightdetail.fgt_ordered_weight,  
   stops.stp_activitystart_dt,  
   stops.stp_activityend_dt,  
   stops.stp_eta,  
   stops.stp_etd,  
   freightdetail.fgt_rate,  
   freightdetail.fgt_charge,  
   freightdetail.fgt_rateunit,  
   freightdetail.cht_itemcode,  
   stops.stp_transfer_type,  
   freightdetail.cht_basisunit,  
   ISNULL(freightdetail.fgt_quantity_type, 0),  
   ISNULL(freightdetail.fgt_charge_type, 0),  
   freightdetail.tar_number,  
   freightdetail.tar_tariffnumber,  
   freightdetail.tar_tariffitem,  
   ISNULL(freightdetail.fgt_ratingquantity,fgt_quantity),  
   ISNULL(freightdetail.fgt_ratingunit,fgt_unit),  
   0 inv_protect,  
   ISNULL(freightdetail.fgt_rate_type,0),  
   cmp_geoloc = (SELECT ISNULL(cmp_geoloc,'') From company Where company.cmp_id = stops.cmp_id),  
   lgh_type2,  
   'LghType2' lgh_type2_t,  
   stops.psh_number,  
   stops.stp_advreturnempty,   
   stops.stp_country,  
   freightdetail.fgt_loadingmeters loadingmeters,  
   freightdetail.fgt_loadingmetersunit loadingmetersunit,  
   fgt_additionl_description,  
   stops.stp_cod_amount,  
   stops.stp_cod_currency,  
   freightdetail.fgt_specific_flashpoint,  
   freightdetail.fgt_specific_flashpoint_unit,  
   freightdetail.fgt_ordered_volume,  
   freightdetail.fgt_ordered_loadingmeters,  
   freightdetail.fgt_pallet_type,  
   orderheader.ord_tareweight act_weight,  
   orderheader.ord_totalweight est_weight,  
   lgh_comment,   
   legheader.lgh_reftype,  
   legheader.lgh_refnum,  
   0 lgh_refnumcount,  
   case stp_type  
   when 'PUP' then  
    ISNULL(  
    ISNULL(  
    ISNULL(  
     stops.stp_alloweddet,   
     ISNULL(  
      (SELECT MIN(cmp_PUPalert)   
       FROM company, orderheader o1  
       where o1.ord_billto = company.cmp_id   
       and o1.ord_hdrnumber = stops.ord_hdrnumber  
       and cmp_PUPalert is not null),   
      (SELECT cmp_PUPalert   
       FROM company WHERE company.cmp_id = stops.cmp_id))  
     ),  
    (select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionPUPMinsAlert')),  
    -1)  
   else  
    ISNULL(  
    ISNULL(  
    ISNULL(  
     stops.stp_alloweddet,   
     ISNULL(  
      (SELECT MIN(cmp_drpalert)   
       FROM company, orderheader o1  
       where o1.ord_billto = company.cmp_id   
       and o1.ord_hdrnumber = stops.ord_hdrnumber  
       and cmp_drpalert is not null),   
      (SELECT cmp_drpalert   
       FROM company WHERE company.cmp_id = stops.cmp_id))  
     ),  
    (select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionDRPMinsAlert')),  
    -1)  
   end stp_alloweddet,  
   Case IsNull(stops.stp_gfc_arr_radius, 0)  
    When 0 then (select gfc_auto_radius  
      FROM geofence_defaults  
      WHERE gfc_auto_cmp_id = 'UNKNOWN' AND  
        gfc_auto_evt = 'ALL' AND  
        gfc_auto_type = 'ARVING')  
   Else stops.stp_gfc_arr_radius  
   End,  
   Case IsNull(stops.stp_gfc_arr_radiusunits, '')  
    When '' then (select gfc_auto_radiusunits  
      FROM geofence_defaults  
      WHERE gfc_auto_cmp_id = 'UNKNOWN' AND  
        gfc_auto_evt = 'ALL' AND  
        gfc_auto_type = 'ARVING')  
   Else stops.stp_gfc_arr_radiusunits  
   End,  
   Case IsNull(stops.stp_gfc_arr_timeout, 0)  
    When 0 then (select gfc_auto_timeout  
      FROM geofence_defaults  
      WHERE gfc_auto_cmp_id = 'UNKNOWN' AND  
        gfc_auto_evt = 'ALL' AND  
        gfc_auto_type = 'ARVING')  
   Else stops.stp_gfc_arr_timeout  
   End,  
   stops.stp_tmstatus,  
   (SELECT ISNULL(mpp_lastfirst, ' ') FROM manpowerprofile WHERE mpp_id = evt_driver1) Driver1name,  
   (SELECT ISNULL(mpp_lastfirst, ' ') FROm manpowerprofile WHERE mpp_id = evt_driver2) Driver2name,  
   stops.stp_reasonlate_text,  
   stops.stp_reasonlate_depart_text  
   ,cpr_density   
   ,scm_subcode,  
   stops.nlm_time_diff,   
   stops.stp_lgh_mileage_mtid   
   ,freightdetail.fgt_consignee,   
   freightdetail.fgt_shipper,   
   freightdetail.fgt_leg_origin,   
   freightdetail.fgt_leg_dest,  
   freightdetail.fgt_bolid,   
   freightdetail.fgt_count2,   
   freightdetail.fgt_count2unit,  
   freightdetail.fgt_terms  
    ,fgt_bol_status  
    ,0 inv_protect  
   ,legheader.lgh_nexttrailer1  
   ,legheader.lgh_nexttrailer2  
   ,stops.stp_detstatus  
   ,stops.stp_est_drv_time  
   ,stops.stp_est_activity,  
   'UNKNOWN' service_zone,  
   'Service Zone' service_zone_t,  
   'UNKNOWN' service_area,  
   'Service Area' service_area_t,  
   'UNKNOWN' service_center,  
   'Service Center' service_center_t,  
   'UNKNOWN' service_region,  
   'Service Reqion' service_region_t  
   ,stp_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0) -- RE - PTS #28205  
   ,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0),  
   lgh_route,  
   lgh_booked_revtype1,  
   (select isnull(gi_string3, 'ExecutingTerminal') from generalinfo where gi_name = 'TrackBranch') booked_revtype1_t,  
   stops.last_updateby,  
   stops.last_updatedate,  
   ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,  
   @lgh_permit_status lgh_permit_status_t,  
   stops.last_updatebydepart,  
   stops.last_updatedatedepart,  
   freightdetail.fgt_osdreason,   
   freightdetail.fgt_osdquantity,  
   freightdetail.fgt_osdunit,  
   freightdetail.fgt_osdcomment,  
   orderheader.ord_no_recalc_miles,  
   legheader.lgh_204status,  
   legheader.lgh_204date,   
   0 cmp_pri1now,  
   0 cmp_pri1soon,  
   0 cmp_pri2now,  
   0 cmp_pri2soon,  
   fgt_packageunit = ISNULL(freightdetail.fgt_packageunit, 'UNK'),  
   stp_unload_paytype = ISNULL(stops.stp_unload_paytype, 'UNK'),  
   stops.stp_transferred,  
   legheader.lgh_type3,  
   'LghType3' lgh_type3_t,  
   legheader.lgh_type4,  
   'LghType4' lgh_type4_t,  
   'PackageUnits' fgt_packageunit_t,  
   event.evt_hubmiles_trailer1,  
   event.evt_hubmiles_trailer2,  
   orderheader.ord_dest_zip,  
   orderheader.ord_remark,  
   ord_totalvolume,  
   ord_totalvolumeunits,  
   stp_reasonlate_min,  
   stp_reasonlate_depart_min,  
   0 reasonlate_count,  
   0 reasonlate_depart_count,  
   stops.stp_ord_toll_cost,  
   fgt_osdstatus,  
   fgt_osdopendate,  
   fgt_osdclosedate,  
   fgt_osdorigclaimamount,  
   fgt_osdamtpaid,  
   fgt_osdamtreceived,  
   lgh_permitnumbers,           
   lgh_permitby,            
   lgh_permitdate,          
   tank_loc = IsNull(freightdetail.tank_loc, 'UNKNOWN'),  
   stp_rescheduledate,  
                        '1950-01-01 00:00:01' cmp_open,  
                        '2049-12-31 23:59:59' cmp_close,  
   stp_origarrival,  
   (SELECT ISNULL(trl_prefix, ' ') FROM trailerprofile WHERE trl_id = event.evt_trailer1) trl1_prefix,  
   (SELECT ISNULL(trl_prefix, ' ') FROm trailerprofile WHERE trl_id = event.evt_trailer2) trl2_prefix,  
   stops.stp_type2,   
   stops.stp_type3,  
   'StpType2' stp_type2_t,  
   'StpType3' stp_type3_t,     
   stp_delay_eligible,   
   stp_firm_appt_flag,   
   lgh_car_rate,  
   lgh_car_charge,  
   lgh_car_accessorials,  
   lgh_car_totalcharge,  
   lgh_spot_rate,  
   lgh_faxemail_created,  
   lgh_acc_fsc,  
   event.evt_chassis,  
   event.evt_chassis2,  
   event.evt_dolly,  
   event.evt_dolly2,  
   event.evt_trailer3,  
   event.evt_trailer4,  
   fgt_volume2, fgt_volume2unit, fgt_volumeunit2
   --isnull(stops.stp_ico_stp_number_parent, 0) stp_ico_stp_number_parent,  
   --isnull(stops.stp_ico_stp_number_child, 0) stp_ico_stp_number_child  
  FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code     
     LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number     
     LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber   
   join event on  stops.stp_number = event.stp_number
   join freightdetail on  freightdetail.stp_number = stops.stp_number 
   join eventcodetable  on event.evt_eventcode = eventcodetable.abbr
  WHERE  
   stops.lgh_number = @lgh_number and  
   (evt_sequence = 1 or fgt_sequence = 1)  
   and @retrievetrip = 1  
  
 End  
else  
 Begin  
                INSERT INTO #temp  
  SELECT event.evt_driver1 driver1,   
   event.evt_driver2 driver2,   
   event.evt_tractor tractor,   
   event.evt_trailer1 trailer1,   
   event.evt_trailer2 trailer2,   
   stops.ord_hdrnumber,   
   stops.stp_number,   
   stops.stp_city stp_city,   
   event.evt_startdate arrivaldate,   
   event.evt_earlydate earliestdate,   
   event.evt_latedate latestdate,   
   stops.cmp_id,  
   (select cmp_address1 from company C where C.cmp_id = stops.cmp_id),
   (select cty_name from city where city.cty_code = stops.stp_city),
   stops.stp_zipcode,    
   stops.cmp_name,   
   evt_enddate departuredate,   
   stops.stp_reasonlate reasonlate_arrival,   
   stops.lgh_number,   
   stops.stp_reasonlate_depart reasonlate_depart,   
   stops.stp_sequence,   
   stops.stp_comment comment,   
   event.evt_hubmiles hubmiles,   
   orderheader.ord_refnum,   
   event.evt_carrier carrier,   
   (select car_name from carrier where car_id = event.evt_carrier),
   orderheader.ord_reftype,   
   event.evt_sequence,   
   stops.stp_mfh_sequence mfh_sequence,   
   freightdetail.fgt_sequence,   
   freightdetail.fgt_number,   
   freightdetail.cmd_code,   
   freightdetail.fgt_description cmd_description,   
   freightdetail.fgt_weight weight,   
   freightdetail.fgt_weightunit weightunit,   
   freightdetail.fgt_count cnt,   
   freightdetail.fgt_countunit countunit,   
   freightdetail.fgt_volume volume,   
   freightdetail.fgt_volumeunit volumeunit,  
   freightdetail.fgt_quantity quantity,   
   freightdetail.fgt_unit quantityunit,   
   freightdetail.fgt_reftype,   
   freightdetail.fgt_refnum,   
   orderheader.ord_billto customer,     
   event.evt_number,   
   event.evt_pu_dr evt_pu_dr,   
   event.evt_eventcode eventcode,   
   Case event.evt_status
		When 'OPN' then 'E'
		When 'DNE' then 'A'
		Else event.evt_status
		end as evt_status,   
   stops.stp_mfh_mileage mfh_mileage,   
   stops.stp_ord_mileage ord_mileage,   
   stops.stp_lgh_mileage lgh_mileage,   
   stops.mfh_number,   
    (select cmp_name  
   from company  
   where company.cmp_id = orderheader.ord_billto) billto_name,  
   city.cty_nmstct cty_nmstct,   
   stops.mov_number,   
   stops.stp_origschdt,   
   stops.stp_paylegpt,   
   stops.stp_region1,   
   stops.stp_region2,   
   stops.stp_region3,   
   stops.stp_region4,   
   stops.stp_state ,  
   1 skip_trigger,  
   lgh_outstatus,  
   0 user0,  
   stops.stp_reftype,  
   stops.stp_refnum,   
   ' ' user1,    
   ' ' user2,  
   ' ' user3,  
   0 stp_refnumcount,  
   0 fgt_refnumcount,  
   0 ord_refnumcount,   
   stops.stp_loadstatus,   
   0 notes_count,  
   eventcodetable.mile_typ_to_stop to_miletype,  
   eventcodetable.mile_typ_from_stop from_miletype,  
   freightdetail.tare_weight,   
   freightdetail.tare_weightunit,  
   lgh_type1,  
   'LghType1' lgh_type1_t,   
   stops.stp_type1,   
   stops.stp_redeliver,   
   stops.stp_osd,   
   stops.stp_pudelpref,   
   orderheader.ord_company,   
   stops.stp_phonenumber,   
   stops.stp_delayhours,   
   stops.stp_ooa_mileage,   
   freightdetail.fgt_pallets_in,   
   freightdetail.fgt_pallets_out,   
   freightdetail.fgt_pallets_on_trailer,   
   freightdetail.fgt_carryins1,   
   freightdetail.fgt_carryins2,   
   stops.stp_zipcode,   
   stops.stp_OOA_stop,   
   stops.stp_address,   
   stops.stp_transfer_stp,   
   stops.stp_contact,   
   stops.stp_phonenumber2,   
   stops.stp_address2,   
   CASE stops.ord_hdrnumber   
   WHEN 0 THEN 0  
   WHEN NULL THEN 0  
   ELSE 1  
   END billable_flag,   
   ord_revtype1,   
   ord_revtype2,   
   ord_revtype3,   
   ord_revtype4,   
   'RevType1' ord_revtype1_t,   
   'RevType2' ord_revtype2_t,   
   'RevType3' ord_revtype3_t,   
   'RevType4' ord_revtype4_t,  
   stops.stp_custpickupdate,  
   stops.stp_custdeliverydate,  
   legheader.lgh_dispatchdate,  
   freightdetail.fgt_length,  
   CAST(ROUND(fgt_length, 0) AS int) / 12 AS fgt_length_feet,   
   CAST(ROUND(fgt_length, 0) AS int) % 12 AS fgt_length_inches,   
   freightdetail.fgt_width,  
   CAST(ROUND(fgt_width, 0) AS int) / 12 AS fgt_width_feet,   
   CAST(ROUND(fgt_width, 0) AS int) % 12 AS fgt_width_inches,   
   freightdetail.fgt_height,  
   CAST(ROUND(fgt_height, 0) AS int) / 12 AS fgt_height_feet,   
   CAST(ROUND(fgt_height, 0) AS int) % 12 AS fgt_height_inches,   
   freightdetail.fgt_stackable,  
   stops.stp_podname,  
   legheader.lgh_feetavailable,  
   stops.stp_cmp_close,  
    CASE EVT_Sequence   
     WHEN 1 THEN isnull(stops.stp_departure_status,'OPN')  
     ELSE isnull(EVENT.evt_departure_status,'OPN')  
   END,   
   freightdetail.fgt_ordered_count,  
   freightdetail.fgt_ordered_weight,  
   stops.stp_activitystart_dt,  
   stops.stp_activityend_dt,  
   stops.stp_eta,  
   stops.stp_etd,  
   freightdetail.fgt_rate,  
   freightdetail.fgt_charge,  
   freightdetail.fgt_rateunit,  
   freightdetail.cht_itemcode,  
   stops.stp_transfer_type,  
   freightdetail.cht_basisunit,  
   ISNULL(freightdetail.fgt_quantity_type, 0),  
   ISNULL(freightdetail.fgt_charge_type, 0),  
   freightdetail.tar_number,  
   freightdetail.tar_tariffnumber,  
   freightdetail.tar_tariffitem,  
   ISNULL(freightdetail.fgt_ratingquantity,fgt_quantity),  
   ISNULL(freightdetail.fgt_ratingunit,fgt_unit),  
   0 inv_protect,  
   ISNULL(freightdetail.fgt_rate_type,0),  
   cmp_geoloc = (SELECT ISNULL(cmp_geoloc,'') From company Where company.cmp_id = stops.cmp_id),  
   lgh_type2,  
   'LghType2' lgh_type2_t,  
   stops.psh_number,  
   stops.stp_advreturnempty,   
   stops.stp_country,  
   freightdetail.fgt_loadingmeters loadingmeters,  
   freightdetail.fgt_loadingmetersunit loadingmetersunit,  
   fgt_additionl_description,  
   stops.stp_cod_amount,  
   stops.stp_cod_currency,  
   freightdetail.fgt_specific_flashpoint,  
   freightdetail.fgt_specific_flashpoint_unit,  
   freightdetail.fgt_ordered_volume,  
   freightdetail.fgt_ordered_loadingmeters,  
   freightdetail.fgt_pallet_type,  
   orderheader.ord_tareweight act_weight,  
   orderheader.ord_totalweight est_weight,  
   lgh_comment,   
   legheader.lgh_reftype,  
   legheader.lgh_refnum,  
   0 lgh_refnumcount,  
   case stp_type  
   when 'PUP' then  
    ISNULL(  
    ISNULL(  
    ISNULL(  
     stops.stp_alloweddet,   
     ISNULL(  
      (SELECT MIN(cmp_PUPalert)   
       FROM company
	   join orderheader o1  on o1.ord_billto = company.cmp_id   
       where 
       o1.ord_hdrnumber = stops.ord_hdrnumber  
       and cmp_PUPalert is not null),   
      (SELECT cmp_PUPalert   
       FROM company WHERE company.cmp_id = stops.cmp_id))  
     ),  
    (select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionPUPMinsAlert')),  
    -1)  
   else  
    ISNULL(  
    ISNULL(  
    ISNULL(  
     stops.stp_alloweddet,   
     ISNULL(  
      (SELECT MIN(cmp_drpalert)   
       FROM company
	   join orderheader o1  on o1.ord_billto = company.cmp_id  
       where  
       o1.ord_hdrnumber = stops.ord_hdrnumber  
       and cmp_drpalert is not null),   
      (SELECT cmp_drpalert   
       FROM company WHERE company.cmp_id = stops.cmp_id))  
     ),  
    (select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionDRPMinsAlert')),  
    -1)  
   end stp_alloweddet,  
   Case IsNull(stops.stp_gfc_arr_radius, 0)  
    When 0 then (select gfc_auto_radius  
      FROM geofence_defaults  
      WHERE gfc_auto_cmp_id = 'UNKNOWN' AND  
        gfc_auto_evt = 'ALL' AND  
        gfc_auto_type = 'ARVING')  
   Else stops.stp_gfc_arr_radius  
   End,  
   Case IsNull(stops.stp_gfc_arr_radiusunits, '')  
    When '' then (select gfc_auto_radiusunits  
      FROM geofence_defaults  
      WHERE gfc_auto_cmp_id = 'UNKNOWN' AND  
        gfc_auto_evt = 'ALL' AND  
        gfc_auto_type = 'ARVING')  
   Else stops.stp_gfc_arr_radiusunits  
   End,  
   Case IsNull(stops.stp_gfc_arr_timeout, 0)  
    When 0 then (select gfc_auto_timeout  
      FROM geofence_defaults  
      WHERE gfc_auto_cmp_id = 'UNKNOWN' AND  
        gfc_auto_evt = 'ALL' AND  
        gfc_auto_type = 'ARVING')  
   Else stops.stp_gfc_arr_timeout  
   End,  
   stops.stp_tmstatus,  
   (SELECT ISNULL(mpp_lastfirst, ' ') FROM manpowerprofile WHERE mpp_id = evt_driver1) Driver1name,  
   (SELECT ISNULL(mpp_lastfirst, ' ') FROm manpowerprofile WHERE mpp_id = evt_driver2) Driver2name,  
   stops.stp_reasonlate_text,  
   stops.stp_reasonlate_depart_text  
   ,cpr_density   
   ,scm_subcode,  
   stops.nlm_time_diff,   
   stops.stp_lgh_mileage_mtid   
   ,freightdetail.fgt_consignee,   
   freightdetail.fgt_shipper,   
   freightdetail.fgt_leg_origin,   
   freightdetail.fgt_leg_dest,  
   freightdetail.fgt_bolid,   
   freightdetail.fgt_count2,   
   freightdetail.fgt_count2unit,  
   freightdetail.fgt_terms  
   ,fgt_bol_status  
   ,0 inv_protect  
   ,legheader.lgh_nexttrailer1  
   ,legheader.lgh_nexttrailer2  
   ,stops.stp_detstatus  
   ,stops.stp_est_drv_time  
   ,stops.stp_est_activity,  
   isNull((select cz_zone from cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip),'UNK') service_zone,  
   @servicezone_labelname service_zone_t,  
   isNull((select cz_area from cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip),'UNK') service_area,  
   @sericearea_labelname service_area_t,  
   isNull(Case isNull(@service_revtype,'UNKNOWN')  
    when 'REVTYPE1' then  
     (select max(svc_center) 
	 from serviceregion sc
	 join cityzip on cityzip.cz_area = sc.svc_area
	 where city.cty_nmstct = cityzip.cty_nmstct 
	 and stops.stp_zipcode = cityzip.zip 
	 AND orderheader.ord_revtype1 = sc.svc_revcode)  
    when 'REVTYPE2' then  
     (select max(svc_center) 
	 from serviceregion sc
	 join cityzip on cityzip.cz_area = sc.svc_area
	 where city.cty_nmstct = cityzip.cty_nmstct 
	 and stops.stp_zipcode = cityzip.zip 
	 AND orderheader.ord_revtype2 = sc.svc_revcode) 
    when 'REVTYPE3' then  
        (select max(svc_center) 
	 from serviceregion sc
	 join cityzip on cityzip.cz_area = sc.svc_area
	 where city.cty_nmstct = cityzip.cty_nmstct 
	 and stops.stp_zipcode = cityzip.zip 
	 AND orderheader.ord_revtype3 = sc.svc_revcode) 
    when 'REVTYPE4' then  
     (select max(svc_center) 
	 from serviceregion sc
	 join cityzip on cityzip.cz_area = sc.svc_area
	 where city.cty_nmstct = cityzip.cty_nmstct 
	 and stops.stp_zipcode = cityzip.zip 
	 AND orderheader.ord_revtype4 = sc.svc_revcode) 
    else  
      'UNKNOWN'  
   End,'UNKNOWN') service_center,  
   @servicecenter_labelname service_center_t,  
   isNull(Case isNull(@service_revtype,'UNKNOWN')  
    when 'REVTYPE1' then  
     (select max(svc_region) 
	 from serviceregion sc
	 join cityzip  on cityzip.cz_area = sc.svc_area
	 where city.cty_nmstct = cityzip.cty_nmstct 
	 and stops.stp_zipcode = cityzip.zip 
	  AND orderheader.ord_revtype1 = sc.svc_revcode)  
    when 'REVTYPE2' then  
          (select max(svc_region) 
	 from serviceregion sc
	 join cityzip  on cityzip.cz_area = sc.svc_area
	 where city.cty_nmstct = cityzip.cty_nmstct 
	 and stops.stp_zipcode = cityzip.zip 
	  AND orderheader.ord_revtype2 = sc.svc_revcode)  
    when 'REVTYPE3' then  
         (select max(svc_region) 
	 from serviceregion sc
	 join cityzip  on cityzip.cz_area = sc.svc_area
	 where city.cty_nmstct = cityzip.cty_nmstct 
	 and stops.stp_zipcode = cityzip.zip 
	  AND orderheader.ord_revtype3 = sc.svc_revcode)  
    when 'REVTYPE4' then  
          (select max(svc_region) 
	 from serviceregion sc
	 join cityzip  on cityzip.cz_area = sc.svc_area
	 where city.cty_nmstct = cityzip.cty_nmstct 
	 and stops.stp_zipcode = cityzip.zip 
	  AND orderheader.ord_revtype4 = sc.svc_revcode)  
    else 'UNKNOWN'  
   End,'UNKNOWN') service_region,  
   @serviceregion_labelname service_region_t  
   ,stp_ord_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0) -- RE - PTS #28205  
   ,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0),  
   lgh_route,  
   lgh_booked_revtype1,  
   (select isnull(gi_string3, 'ExecutingTerminal') from generalinfo where gi_name = 'TrackBranch') booked_revtype1_t,  
   stops.last_updateby,  
   stops.last_updatedate,  
   ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,  
   @lgh_permit_status lgh_permit_status_t,  
   stops.last_updatebydepart,  
   stops.last_updatedatedepart,  
   freightdetail.fgt_osdreason,    
   freightdetail.fgt_osdquantity,  
   freightdetail.fgt_osdunit,  
   freightdetail.fgt_osdcomment,  
   orderheader.ord_no_recalc_miles,  
   legheader.lgh_204status,  
   legheader.lgh_204date,  
   0 cmp_pri1now,  
   0 cmp_pri1soon,  
   0 cmp_pri2now,  
   0 cmp_pri2soon,  
   fgt_packageunit = ISNULL(freightdetail.fgt_packageunit, 'UNK'),  
   stp_unload_paytype = ISNULL(stops.stp_unload_paytype, 'UNK'),  
   stops.stp_transferred,  
   legheader.lgh_type3,  
   'LghType3' lgh_type3_t,  
   legheader.lgh_type4,  
   'LghType4' lgh_type4_t,  
   'PackageUnits' fgt_packageunit_t,  
   event.evt_hubmiles_trailer1,  
   event.evt_hubmiles_trailer2,  
   orderheader.ord_dest_zip,  
   orderheader.ord_remark,  
   ord_totalvolume,  
   ord_totalvolumeunits,  
   stp_reasonlate_min,  
   stp_reasonlate_depart_min,  
   0 reasonlate_count,  
   0 reasonlate_depart_count,  
   stp_ord_toll_cost,  
   fgt_osdstatus,  
   fgt_osdopendate,  
   fgt_osdclosedate,  
   fgt_osdorigclaimamount,  
   fgt_osdamtpaid,  
   fgt_osdamtreceived,  
   lgh_permitnumbers,            
   lgh_permitby,            
   lgh_permitdate,           
   tank_loc = IsNull(freightdetail.tank_loc, 'UNKNOWN'),  
   stp_rescheduledate,  
                        '1950-01-01 00:00:01' cmp_open,  
                        '2049-12-31 23:59:59' cmp_close,  
   stp_origarrival,  
   (SELECT ISNULL(trl_prefix, ' ') FROM trailerprofile WHERE trl_id = event.evt_trailer1) trl1_prefix,  
   (SELECT ISNULL(trl_prefix, ' ') FROm trailerprofile WHERE trl_id = event.evt_trailer2) trl2_prefix,  
   stops.stp_type2,  
   stops.stp_type3,  
   'StpType2' stp_type2_t,  
   'StpType3' stp_type3_t,  
   stp_delay_eligible,   
   stp_firm_appt_flag,
   lgh_car_rate,  
   lgh_car_charge,  
   lgh_car_accessorials,  
   lgh_car_totalcharge,  
   lgh_spot_rate,  
   lgh_faxemail_created,  
   lgh_acc_fsc,  
   event.evt_chassis,   
   event.evt_chassis2,  
   event.evt_dolly,  
   event.evt_dolly2,  
   event.evt_trailer3,  
   event.evt_trailer4,  
   fgt_volume2, fgt_volume2unit, fgt_volumeunit2  /* 08/12/2010 MDH PTS 53108: Added */     
   --isnull(stops.stp_ico_stp_number_parent, 0) stp_ico_stp_number_parent,  
   --isnull(stops.stp_ico_stp_number_child, 0) stp_ico_stp_number_child  

  FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code     
     LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number     
     LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber  
   join event on stops.stp_number = event.stp_number
   join freightdetail on freightdetail.stp_number = stops.stp_number
   join eventcodetable  on event.evt_eventcode = eventcodetable.abbr
  WHERE   --pts40187 removed the outer join since it is not necessary any more from Ron  
   stops.lgh_number = @lgh_number and  
   (evt_sequence = 1 or fgt_sequence = 1)  
   and @retrievetrip = 1  

  
 End  
  
IF @NewCompanyHours = 'Y'  
BEGIN  
   DECLARE temp_select CURSOR FOR  
      SELECT ISNULL(cmp_id, 'UNKNOWN'), arrivaldate, stp_number, ISNULL(ord_hdrnumber, 0), evt_pu_dr  
        FROM #temp  
      ORDER BY mfh_sequence  
  
   OPEN temp_select  
  
   FETCH NEXT FROM temp_select  
      INTO @cmp_id, @arrivaldate, @stp_number, @ord_hdrnumber, @stp_type  
  
   WHILE @@FETCH_STATUS = 0   
   BEGIN  
      IF @ord_hdrnumber > 0 AND @cmp_id <> 'UNKNOWN' AND @stp_type IN ('PUP', 'DRP')  
      BEGIN  
         SET @open_dt = NULL  
         SET @close_dt = NULL  
         EXECUTE p_get_companyopentime @cmp_id, @arrivaldate, @open_dt OUTPUT, @close_dt OUTPUT  
         UPDATE #temp  
            SET cmp_open = @open_dt,  
                cmp_close = @close_dt  
          WHERE stp_number = @stp_number  
      END  
        
      FETCH NEXT FROM temp_select  
         INTO @cmp_id, @arrivaldate, @stp_number, @ord_hdrnumber, @stp_type  
   END  
  
   CLOSE temp_select  
   DEALLOCATE temp_select  
END  
  
SELECT *  
  FROM #temp  
  order by mfh_sequence
  
  

GO
