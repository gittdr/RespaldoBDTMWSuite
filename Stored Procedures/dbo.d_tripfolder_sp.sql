SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[d_tripfolder_sp]
   @mov_number integer
as
/**
 *
 * NAME:
 * dbo.d_tripfolder_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns relevant data about a move that can be used by the
 * d_tripfolder(_xxx) series of datawindows
 *
 * RETURNS:
 * none
 *
 * RESULT SETS:
 * 001 - driver1
 * 002 - driver2
 * 003 - tractor
 * 004 - trailer1
 * 005 - trailer2
 * 006 - stops.ord_hdrnumber
 * 007 - stops.stp_number
 * 008 - stp_city
 * 009 - arrivaldate
 * 010 - earliestdate
 * 011 - latestdate
 * 012 - stops.cmp_id
 * 013 - stops.cmp_name
 * 014 - departuredate
 * 015 - reasonlate_arrival
 * 016 - stops.lgh_number
 * 017 - reasonlate_depart
 * 018 - stops.stp_sequence
 * 019 - comment
 * 020 - hubmiles
 * 021 - orderheader.ord_refnum
 * 022 - carrier
 * 023 - orderheader.ord_reftype
 * 024 - event.evt_sequence
 * 025 - mfh_sequence
 * 026 - freightdetail.fgt_sequence
 * 027 - freightdetail.fgt_number
 * 028 - freightdetail.cmd_code
 * 029 - cmd_description
 * 030 - weight
 * 031 - weightunit
 * 032 - cnt
 * 033 - countunit
 * 034 - volume
 * 035 - volumeunit
 * 036 - quantity
 * 037 - quantityunit
 * 038 - freightdetail.fgt_reftype
 * 039 - freightdetail.fgt_refnum
 * 040 - customer
 * 041 - event.evt_number
 * 042 - evt_pu_dr
 * 043 - eventcode
 * 044 - evt_status
 * 045 - mfh_mileage
 * 046 - ord_mileage
 * 047 - lgh_mileage
 * 048 - stops.mfh_number
 * 049 - billto_name
 * 050 - cty_nmstct
 * 051 - mov_number
 * 052 - stops.stp_origschdt
 * 053 - stops.stp_paylegpt
 * 054 - stops.stp_region1
 * 055 - stops.stp_region2
 * 056 - stops.stp_region3
 * 057 - stops.stp_region4
 * 058 - stops.stp_state
 * 059 - skip_trigger
 * 060 - lgh_outstatus
 * 061 - user0
 * 062 - stops.stp_reftype
 * 063 - stops.stp_refnum
 * 064 - user1
 * 065 - user2
 * 066 - user3
 * 067 - stp_refnumcount
 * 068 - fgt_refnumcount
 * 069 - ord_refnumcount
 * 070 - stops.stp_loadstatus
 * 071 - notes_count
 * 072 - to_miletype
 * 073 - from_miletype
 * 074 - freightdetail.tare_weight
 * 075 - freightdetail.tare_weightunit
 * 076 - lgh_type1
 * 077 - lgh_type1_t
 * 078 - stops.stp_type1
 * 079 - stops.stp_redeliver
 * 080 - stops.stp_osd
 * 081 - stops.stp_pudelpref
 * 082 - orderheader.ord_company
 * 083 - stops.stp_phonenumber
 * 084 - stops.stp_delayhours
 * 085 - stops.stp_ooa_mileage
 * 086 - freightdetail.fgt_pallets_in
 * 087 - freightdetail.fgt_pallets_out
 * 088 - freightdetail.fgt_pallets_on_trailer
 * 089 - freightdetail.fgt_carryins1
 * 090 - freightdetail.fgt_carryins2
 * 091 - stops.stp_zipcode
 * 092 - stops.stp_OOA_stop
 * 093 - stops.stp_address
 * 094 - stops.stp_transfer_stp
 * 095 - stops.stp_contact
 * 096 - stops.stp_phonenumber2
 * 097 - stops.stp_address2
 * 098 - billable_flag
 * 099 - ord_revtype1
 * 100 - ord_revtype2
 * 101 - ord_revtype3
 * 102 - ord_revtype4
 * 103 - ord_revtype1_t
 * 104 - ord_revtype2_t
 * 105 - ord_revtype3_t
 * 106 - ord_revtype4_t
 * 107 - stops.stp_custpickupdate
 * 108 - stops.stp_custdeliverydate
 * 109 - legheader.lgh_dispatchdate
 * 110 - freightdetail.fgt_length
 * 111 - freightdetail.fgt_width
 * 112 - freightdetail.fgt_height
 * 113 - freightdetail.fgt_stackable
 * 114 - stops.stp_podname
 * 115 - legheader.lgh_feetavailable
 * 116 - stops.stp_cmp_close
 * 117 - stops.stp_departure_status
 * 118 - freightdetail.fgt_ordered_count
 * 119 - freightdetail.fgt_ordered_weight
 * 120 - stops.stp_activitystart_dt
 * 121 - stops.stp_activityend_dt
 * 122 - stops.stp_eta
 * 123 - stops.stp_etd
 * 124 - freightdetail.fgt_rate
 * 125 - freightdetail.fgt_charge
 * 126 - freightdetail.fgt_rateunit
 * 127 - freightdetail.cht_itemcode
 * 128 - stops.stp_transfer_type
 * 129 - freightdetail.cht_basisunit
 * 130 - fgt_quantity_type
 * 131 - freightdetail.fgt_charge_type
 * 132 - freightdetail.tar_number
 * 133 - freightdetail.tar_tariffnumber
 * 134 - freightdetail.tar_tariffitem
 * 135 - freightdetail.fgt_ratingquantity
 * 136 - freightdetail.fgt_ratingunit
 * 137 - inv_protect
 * 138 - freightdetail.fgt_rate_type
 * 139 - cmp_geoloc
 * 140 - lgh_type2
 * 141 - lgh_type2_t
 * 142 - stops.psh_number
 * 143 - stops.stp_advreturnempty
 * 144 - stops.stp_country
 * 145 - loadingmeters
 * 146 - loadingmetersunit
 * 147 - fgt_additionl_description
 * 148 - stops.stp_cod_amount
 * 149 - stops.stp_cod_currency
 * 150 - freightdetail.fgt_specific_flashpoint
 * 151 - freightdetail.fgt_specific_flashpoint_unit
 * 152 - freightdetail.fgt_ordered_volume
 * 153 - freightdetail.fgt_ordered_loadingmeters
 * 154 - freightdetail.fgt_pallet_type
 * 155 - act_weight
 * 156 - est_weight
 * 157 - lgh_comment
 * 158 - legheader.lgh_reftype
 * 159 - legheader.lgh_refnum
 * 160 - lgh_refnumcount
 * 161 - stp_alloweddet
 * 162 - stops.stp_gfc_arr_radius
 * 163 - stops.stp_gfc_arr_radiusunits
 * 164 - stops.stp_gfc_arr_timeout
 * 165 - stops.stp_tmstatus
 * 166 - Driver1name
 * 167 - Driver2name
 * 168 - stops.stp_reasonlate_text
 * 169 - stops.stp_reasonlate_depart_text
 * 170 - cpr_density
 * 171 - scm_subcode
 * 172 - stops.nlm_time_diff
 * 173 - stops.stp_lgh_mileage_mtid
 * 174 - freightdetail.fgt_consignee
 * 175 - freightdetail.fgt_shipper
 * 176 - freightdetail.fgt_leg_origin
 * 177 - freightdetail.fgt_leg_dest
 * 178 - freightdetail.fgt_bolid
 * 179 - freightdetail.fgt_count2
 * 180 - freightdetail.fgt_count2unit
 * 181 - freightdetail.fgt_terms
 * 182 - fgt_bol_status
 * 183 - inv_protect
 * 184 - legheader.lgh_nexttrailer1
 * 185 - legheader.lgh_nexttrailer2
 * 186 - stops.stp_detstatus
 * 187 - stops.stp_est_drv_time
 * 188 - stops.stp_est_activity
 * 189 - service_zone
 * 190 - service_zone_t
 * 191 - service_area
 * 192 - service_area_t
 * 193 - service_center
 * 194 - service_center_t
 * 195 - service_region
 * 196 - service_region_t
 * 197 - stp_mileage_mtid
 * 198 - stp_ooa_mileage_mtid
 * 199 - lgh_route
 * 200 - lgh_booked_revtype1
 * 201 - booked_revtype1_t
 * 202 - stops.last_updateby
 *    the user ID of the last person to update one of the arrival datetimes or arrival status
 * 203 - stops.last_updatedate
 *    the date of the last update of the arrival datetimes or arrival status
 * 204 - lgh_permit_status
 * 205 - lgh_permit_status_t
 * 206 - stops.last_updatebydepart
 *    the user ID of the last person to update one of the departure datetimes or departure status
 * 207 - stops.last_updatedatedepart
 *    the date of the last update of the departure datetimes or departyrestatus
 * 208 - freightdetail.fgt_osdreason; Character code representing an overage,shortage or damage to freight
 * 209 - freightdetail.fgt_osdquantity; Quantity for OSD
 * 210 - freightdetail.fgt_osdunit; unit of measure for osd quantity
 * 211 - freightdetail.fgt_osdcomment; freeform text comment for OSD
 * 212 - orderheader.ord_no_recalc_miles; Flag to not lookup miles.
 * 213 - legheader.lgh_204status; Status for outbound 204 if sent.
 * 214 - legheader.lgh_204date; Date 204 was sent.
 * 215 - Blank - column to be used for indicating Company Expirations
 * 216 - Blank - column to be used for indicating Company Expirations
 * 217 - Blank - column to be used for indicating Company Expirations
 * 218 - Blank - column to be used for indicating Company Expirations
 * 219 - freightdetail.fgt_packageunit; Type of package unit.  Description will be found in label file.
 * 220 - stops.stp_unload_paytype
 * 221 - stops.stp_transferred
 * 222 - legheader.lgh_type3
 * 223 - lgh_type3_t
 * 224 - legheader.lgh_type4
 * 225 - lgh_type4_t
 * 226 - fgt_packageunit_t - Heading for PackageUnit from LabelFile
 * 227 - event.evt_hubmiles_trailer1
 * 228 - event.evt_hubmiles_trailer2
 * 229 - orderheader.ord_dest_zip
 * 230 - orderheader.ord_remark
 * 231 - undocumented column
 * 232 - undocumented column
 * 233 - stp_reasonlate_min
 * 234 - stp_reasonlate_depart_min
 * 235 - reasonlate_count
 * 236 - reasonlate_depart_count
 * 237 - stp_ord_toll_cost
 * 238 - fgt_osdstatus
 * 239 - fgt_osdopendate
 * 240 - fgt_osdclosedate
 * 241 - fgt_osdorigclaimamount
 * 242 - fgt_osdamtpaid
 * 243 - fgt_osdamtreceived
 * 244 - lgh_permitnumbers
 * 245 - lgh_permitby
 * 246 - lgh_permitdate
 * 247 - tank_loc
 * 248 - stp_rescheduledate
 * 249 - cmp_open
 * 250 - cmp_close
 * 251 - trl1_prefix
 * 252 - trl2_prefix
 * 253 - stops.stp_type2
 * 254 - stops.stp_type3
 * 255 - stp_type2_t
 * 256 - stp_type3_t
 * 257 - stp_delay_eligible
 * 258 - stp_firm_appt_flag
 * 259 - lgh_car_rate
 * 260 - lgh_car_charge
 * 261 - lgh_car_accessorials
 * 262 - lgh_car_totalcharge
 * 263 - lgh_spot_rate
 * 264 - lgh_faxemail_created
 * 265 - lgh_acc_fsc
 * 266 - evt_chassis
 * 267 - evt_chassis2
 * 268 - evt_dolly
 * 269 - evt_dolly2
 * 270 - evt_trailer3
 * 271 - evt_trailer4
 * * * *
 * 284 - ud_column1
 * 285 - ud_column1_t
 * 286 - ud_column2
 * 287 - ud_column2_t
 * 288 - ud_column3
 * 289 - ud_column3_t
 * 290 - ud_column4
 * 291 - ud_column4_t
 * 292 - lgh_plannedhours			--vjh 64871
 * 293 - stp_arr_confirmed
 * 294 - stp_dep_confirmed
 * 295 - stp_rpt_miles
 * 296 - stp_rpt_miles_mtid 
 * 297 - mpp_pta_date
 *
 * PARAMETERS:
 * 001 - @mov_number integer;
 *       The movement number

 *
 * REFERENCES:
 * none
 *
 * REVISION HISTORY:
dpete pts 10775 ad cht_basisunit ro return set, part of rating in VisDisp. 6/11/01
dpete pts9647 add tariff fields to freightdetail return set to record what tariff applied when pre rating by detail
dpete pts12066 bring back fgt_ratingquantity and fgt_ratingunit
DPETE 12/3/01 PTS12523 allow fixing rate
DPETE PTS12599 add cmp_geoloc 12/13/01
JET PTS 16016, added stp_country 11/18/2002
MBR PTS16217 Added and (evt_sequence = 1 or fgt_sequence = 1) to where clause
DPETE 18410 add lgh_comment to return set
DPETE 22760 add scm_subcode and cpr_density
DJM - PTS 26791 - Recode of PTS 20302 into main source.  Localization settings.
LOR   - PTS# 27341(28194) - route, booked_revtype1
 * 08/02/2005.01 - Vince Herman ? PTS 29052 add stp_lastupdatebydepart and stp_lastupdatedatedepart
 * 08/11/2005.02 - A. Rossman  - PTS 27619 add fgt_osdreason,fgt_osdunit,fgt_osdquantity and fgt_osdcomment
 * 10/26/2005.03 - MRH - PTS 30082 Added ord_no_recalc_miles.
 * 12/13/2005.04 - MBR - PTS30481 Added lgh_204status and lgh_204date.
 * 02/23/2006.05 - DJM - PTS 27430 Added columns to support displaying indicators of Company Expirations in the Tripfolder.
 * 03/29/2006.06 - PRB - PTS 31866 Added column to indicate package unit fgt_packageunit for ACE initiative.
 * 04/10/2006.07 - vjh - PTS 32460 New column for TotalMail
 * PTS 33550 - 08/28/2006 - DJM - Added fields for lgh_type3 and lgh_type4
 * PTS 33513 - 08/30/2006 - PRB Added field for package unit label display.
 * PTS 32408 JJF 9/27/06
 * PTS 34405 JJF 10/31/06
 * 04/19/2007.12 - vjh - PTS 35775 New columns for new reasonlate table
 --PTS 37496 SGB 05/22/07 use stop status for stops and event status for events
         --stops.stp_departure_status,
         CASE EVT_Sequence
            WHEN 1 THEN isnull(stops.stp_departure_status,'OPN')
            ELSE isnull(EVENT.evt_departure_status,'OPN')
         END,
--PTS 36702 JJF 20070514
 * 08/22/2007 - EMK - PTS 37029 Added Toll costs
 * 11/07/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 10/08/2008.01 - pts44505 - vjh add trl prefix for both trailers
 * 5/1/2009.01 - pts47315 - KMM add stp_type2 and stp_type3 to correspond to NG OE
 * 06/08/2009 - PTS 41569 GAP 47 - add stp_delay_eligible and stp_firm_appt_flag columns.
 * 05/08/12 - PTS 51911 per PTS 59158 Add 4 User Defined Columns
 * 10/26/2012 - PTS 64373 SPN - CalculateLegMiles
 * 05/15/2013 - vjh 64871 add lgh_plannedhours
 * 05/20/2013 JJF 69142
 **/

Declare @Service_revtype      varchar(10),
   @servicezone_labelname     varchar(20),
   @servicecenter_labelname   varchar(20),
   @serviceregion_labelname   varchar(20),
   @sericearea_labelname      varchar(20),
   @localization        char(1),
   @lgh_permit_status      varchar(20),
   @NewCompanyHours     CHAR(1),
   @cmp_id           VARCHAR(8),
        @arrivaldate       DATETIME,
   @stp_number       INTEGER,
        @ord_hdrnumber        INTEGER,
   @stp_type         VARCHAR(6),
   @open_dt       DATETIME,
        @close_dt       DATETIME,
    @ud_column1 char(1), --PTS 51911 per PTS 59158 SGB
   @ud_column2 char(1),  --PTS 51911 per PTS 59158 SGB
   @ud_column3 char(1), --PTS 51911 per PTS 59158 SGB
   @ud_column4 char(1),  --PTS 51911 per PTS 59158 SGB
   @procname varchar(255), --PTS 51911 per PTS 59158 SGB
   @udheader varchar(30) --PTS 51911 per PTS 59158 SGB

--PTS 40630 JJF 20071128
declare @rowsecurity char(1)
declare @tmwuser varchar(255)
declare @ordercount int
declare @orderpassrestrictioncount int
declare @retrievetrip int
--END PTS 40630 JJF 20071128

--BEGIN PTS 64373 SPN
DECLARE @CalculateLegMiles CHAR(1)
--END PTS 64373 SPN

--PTS74465 JJF 20140106
DECLARE @ord_status_top varchar(6)

SELECT @ord_status_top =	ISNULL	(	(	SELECT TOP 1 ohinner.ord_status 
											FROM	orderheader ohinner 
											WHERE	ohinner.mov_number = @mov_number
										), ''
									) 
--END PTS74465 JJF 20140106


--PTS41348 MBR 04/07/08 Changed proc to use temp table and grap open and close datetimes
CREATE TABLE #temp (
   driver1           VARCHAR(8)  NULL,
   driver2           VARCHAR(8)  NULL,
   tractor        VARCHAR(8)  NULL,
   trailer1       VARCHAR(13) NULL,
   trailer2          VARCHAR(13) NULL,
   ord_hdrnumber     INT NULL,
   stp_number        INT NULL,
   stp_city       INT NULL,
   arrivaldate       DATETIME NULL,
   earliestdate      DATETIME NULL,
   latestdate        DATETIME NULL,
   cmp_id            VARCHAR(8) NULL,
   cmp_name       VARCHAR(30) NULL,
   departuredate     DATETIME NULL,
   reasonlate_arrival   VARCHAR(6) NULL,
   lgh_number        INT NULL,
   reasonlate_depart VARCHAR(6) NULL,
   stp_sequence      INT NULL,
   comment           VARCHAR(254) NULL,
   hubmiles       INT NULL,
   ord_refnum        VARCHAR(30) NULL,
   carrier           VARCHAR(8) NULL,
   ord_reftype       VARCHAR(6) NULL,
   evt_sequence      INT NULL,
   mfh_sequence      INT NULL,
   fgt_sequence      SMALLINT NULL,
   fgt_number        INT NULL,
   cmd_code       VARCHAR(8) NULL,
   cmd_description      VARCHAR(60) NULL,
   weight            FLOAT NULL,
   weightunit        VARCHAR(6) NULL,
   cnt               DECIMAL(10, 2) NULL,
   countunit         VARCHAR(6) NULL,
   volume            FLOAT NULL,
   volumeunit        VARCHAR(6) NULL,
   quantity       FLOAT NULL,
   quantityunit      VARCHAR(6) NULL,
   fgt_reftype       VARCHAR(6) NULL,
   fgt_refnum        VARCHAR(30) NULL,
   customer       VARCHAR(8) NULL,
   evt_number        INT NULL,
   evt_pu_dr         VARCHAR(6) NULL,
   eventcode         VARCHAR(6) NULL,
   evt_status        VARCHAR(6) NULL,
   mfh_mileage       INT NULL,
   ord_mileage       INT NULL,
   lgh_mileage       INT NULL,
   mfh_number        INT NULL,
   billto_name       VARCHAR(100) NULL,
   cty_nmstct        VARCHAR(30) NULL,
   mov_number        INT NULL,
   stp_origschdt     DATETIME NULL,
   stp_paylegpt      CHAR(1) NULL,
   stp_region1       VARCHAR(6) NULL,
   stp_region2       VARCHAR(6) NULL,
   stp_region3       VARCHAR(6) NULL,
   stp_region4       VARCHAR(6) NULL,
   stp_state         VARCHAR(6) NULL,
   skip_trigger      INT NULL,
   lgh_outstatus     VARCHAR(6) NULL,
   user0          INT NULL,
   stp_reftype       VARCHAR(6) NULL,
   stp_refnum        VARCHAR(30) NULL,
   user1          VARCHAR(1) NULL,
   user2          VARCHAR(1) NULL,
   user3          VARCHAR(1) NULL,
   stp_refnumcount      INT NULL,
   fgt_refnumcount      INT NULL,
   ord_refnumcount      INT NULL,
   stp_loadstatus    CHAR(3) NULL,
   notes_count       INT NULL,
   to_miletype       VARCHAR(6) NULL,
   from_miletype     VARCHAR(6) NULL,
   tare_weight       FLOAT NULL,
   tare_weightunit      VARCHAR(6) NULL,
   lgh_type1         VARCHAR(6) NULL,
   lgh_type1_t       VARCHAR(8) NULL,
   stp_type1         VARCHAR(6) NULL,
   stp_redeliver     VARCHAR(1) NULL,
   stp_osd           VARCHAR(1) NULL,
   stp_pudelpref     VARCHAR(10) NULL,
   ord_company       VARCHAR(8) NULL,
   stp_phonenumber      VARCHAR(20) NULL,
   stp_delayhours    FLOAT NULL,
   stp_ooa_mileage      FLOAT NULL,
   fgt_pallets_in    FLOAT NULL,
   fgt_pallets_out      FLOAT NULL,
   fgt_pallets_on_trailer  FLOAT NULL,
   fgt_carryins1        FLOAT NULL,
   fgt_carryins2        FLOAT NULL,
   stp_zipcode          VARCHAR(10) NULL,
   stp_OOA_stop         INT NULL,
   stp_address          VARCHAR(40) NULL,
   stp_transfer_stp     INT NULL,
   stp_contact          VARCHAR(30) NULL,
   stp_phonenumber2     VARCHAR(20) NULL,
   stp_address2         VARCHAR(40) NULL,
   billable_flag        INT NULL,
   ord_revtype1         VARCHAR(6) NULL,
   ord_revtype2         VARCHAR(6) NULL,
   ord_revtype3         VARCHAR(6) NULL,
   ord_revtype4         VARCHAR(6) NULL,
   ord_revtype1_t       VARCHAR(8) NULL,
   ord_revtype2_t       VARCHAR(8) NULL,
   ord_revtype3_t       VARCHAR(8) NULL,
   ord_revtype4_t       VARCHAR(8) NULL,
   stp_custpickupdate      DATETIME NULL,
   stp_custdeliverydate DATETIME NULL,
   lgh_dispatchdate     DATETIME NULL,
   fgt_length           FLOAT NULL,
   fgt_length_feet         INT NULL,
   fgt_length_inches    INT NULL,
   fgt_width            FLOAT NULL,
   fgt_width_feet       INT NULL,
   fgt_width_inches     INT NULL,
   fgt_height           FLOAT NULL,
   fgt_height_feet         INT NULL,
   fgt_height_inches    INT NULL,
   fgt_stackable        VARCHAR(1) NULL,
   stp_podname          VARCHAR(20) NULL,
   lgh_feetavailable    SMALLINT NULL,
   stp_cmp_close        INT NULL,
   stp_departure_status VARCHAR(6) NULL,
   fgt_ordered_count    REAL NULL,
   fgt_ordered_weight      FLOAT NULL,
   stp_activitystart_dt DATETIME NULL,
   stp_activityend_dt      DATETIME NULL,
   stp_eta              DATETIME NULL,
   stp_etd              DATETIME NULL,
   fgt_rate          MONEY NULL,
   fgt_charge           MONEY NULL,
   fgt_rateunit         VARCHAR(6) NULL,
   cht_itemcode         VARCHAR(6) NULL,
   stp_transfer_type    CHAR(3) NULL,
   cht_basisunit        VARCHAR(6) NULL,
   fgt_quantity_type    SMALLINT NULL,
   fgt_charge_type         SMALLINT NULL,
   tar_number           INT NULL,
   tar_tariffnumber     VARCHAR(13) NULL,
   tar_tariffitem       VARCHAR(13) NULL,
   fgt_ratingquantity      FLOAT NULL,
   fgt_ratingunit       VARCHAR(6) NULL,
   inv_protect          INT NULL,
   fgt_rate_type        SMALLINT NULL,
   cmp_geoloc           VARCHAR(50) NULL,
   lgh_type2            VARCHAR(6) NULL,
   lgh_type2_t          VARCHAR(8) NULL,
   psh_number           INT NULL,
   stp_advreturnempty      INT NULL,
   stp_country          VARCHAR(50) NULL,
   loadingmeters        DECIMAL(12, 4) NULL,
   loadingmetersunit    VARCHAR(6) NULL,
   fgt_additionl_description  VARCHAR(25) NULL,
   stp_cod_amount       DECIMAL(8, 2) NULL,
   stp_cod_currency     VARCHAR(6) NULL,
   fgt_specific_flashpoint FLOAT NULL,
   fgt_specific_flashpoint_unit  VARCHAR(6) NULL,
   fgt_ordered_volume      DECIMAL(18, 0) NULL,
   fgt_ordered_loadingmeters  DECIMAL(18, 0) NULL,
   fgt_pallet_type         VARCHAR(6) NULL,
   act_weight           INT NULL,
   est_weight           FLOAT NULL,
   lgh_comment          VARCHAR(255) NULL,
   lgh_reftype          VARCHAR(6) NULL,
   lgh_refnum           VARCHAR(30) NULL,
   lgh_refnumcount         INT NULL,
   stp_alloweddet       INT NULL,
   stp_gfc_arr_radius      DECIMAL(7, 2) NULL,
   stp_gfc_arr_radiusunits VARCHAR(6) NULL,
   stp_gfc_arr_timeout     INT NULL,
   stp_tmstatus         VARCHAR(6) NULL,
   Driver1name          VARCHAR(45) NULL,
   Driver2name          VARCHAR(45) NULL,
   stp_reasonlate_text     VARCHAR(255) NULL,
   stp_reasonlate_depart_text VARCHAR(255) NULL,
   cpr_density          DECIMAL(9, 4) NULL,
   scm_subcode          VARCHAR(8) NULL,
   nlm_time_diff        INT NULL,
   stp_lgh_mileage_mtid INT NULL,
   fgt_consignee        CHAR(8) NULL,
   fgt_shipper          CHAR(8) NULL,
   fgt_leg_origin       CHAR(8) NULL,
   fgt_leg_dest         CHAR(8) NULL,
   fgt_bolid            INT NULL,
   fgt_count2           DECIMAL(10, 2) NULL,
   fgt_count2unit       VARCHAR(6) NULL,
   fgt_terms            CHAR(6) NULL,
   fgt_bol_status       VARCHAR(6) NULL,
   inv_protect_except      INT NULL,
   lgh_nexttrailer1     VARCHAR(13) NULL,
   lgh_nexttrailer2     VARCHAR(13) NULL,
   stp_detstatus        INT         NULL,
   stp_est_drv_time     INT         NULL,
   stp_est_activity     INT         NULL,
   service_zone         VARCHAR(7)  NULL,
   service_zone_t       VARCHAR(12) NULL,
   service_area         VARCHAR(7)  NULL,
   service_area_t       VARCHAR(12) NULL,
   service_center       VARCHAR(7)  NULL,
   service_center_t     VARCHAR(14) NULL,
   service_region       VARCHAR(7)  NULL,
   service_region_t     VARCHAR(14) NULL,
   stp_mileage_mtid     INT         NULL,
   stp_ooa_mileage_mtid INT         NULL,
   lgh_route            VARCHAR(15) NULL,
   lgh_booked_revtype1     VARCHAR(12) NULL,
   booked_revtype1_t    VARCHAR(60) NULL,
   last_updateby        VARCHAR(256) NULL,
   last_updatedate         DATETIME NULL,
   lgh_permit_status    VARCHAR(6)  NULL,
   lgh_permit_status_t     VARCHAR(20) NULL,
   last_updatebydepart     VARCHAR(256) NULL,
   last_updatedatedepart   DATETIME NULL,
   fgt_osdreason        VARCHAR(6)  NULL,
   fgt_osdquantity         INT         NULL,
   fgt_osdunit          VARCHAR(6)  NULL,
   fgt_osdcomment       VARCHAR(255) NULL,
   ord_no_recalc_miles     CHAR(1)     NULL,
   lgh_204status        VARCHAR(6)  NULL,
   lgh_204date          DATETIME NULL,
   cmp_pri1now          INT         NULL,
   cmp_pri1soon         INT         NULL,
   cmp_pri2now          INT         NULL,
   cmp_pri2soon         INT         NULL,
   fgt_packageunit         VARCHAR(6)  NULL,
   stp_unload_paytype      VARCHAR(6)  NULL,
   stp_transferred         CHAR(1)     NULL,
   lgh_type3            VARCHAR(6)  NULL,
   lgh_type3_t          VARCHAR(8)  NULL,
   lgh_type4            VARCHAR(6)  NULL,
   lgh_type4_t          VARCHAR(8)  NULL,
   fgt_packageunit_t    VARCHAR(12) NULL,
   evt_hubmiles_trailer1   INT         NULL,
   evt_hubmiles_trailer2   INT         NULL,
   ord_dest_zip         VARCHAR(10) NULL,
   ord_remark           VARCHAR(254) NULL,
   ord_totalvolume         FLOAT    NULL,
   ord_totalvolumeunits VARCHAR(6)  NULL,
   stp_reasonlate_min      INT         NULL,
   stp_reasonlate_depart_min  INT      NULL,
   reasonlate_count     INT         NULL,
   reasonlate_depart_count INT         NULL,
   stp_ord_toll_cost    MONEY    NULL,
   fgt_osdstatus        VARCHAR(6)  NULL,
   fgt_osdopendate         DATETIME NULL,
   fgt_osdclosedate     DATETIME NULL,
   fgt_osdorigclaimamount  MONEY    NULL,
   fgt_osdamtpaid       MONEY    NULL,
   fgt_osdamtreceived      MONEY    NULL,
   lgh_permitnumbers    VARCHAR(255) NULL,
   lgh_permitby         VARCHAR(12) NULL,
   lgh_permitdate       DATETIME NULL,
   tank_loc          VARCHAR(10) NULL,
   stp_rescheduledate      DATETIME NULL,
   cmp_open          DATETIME NULL,
   cmp_close            DATETIME NULL,
   stp_origarrival         DATETIME NULL,
   trl1_prefix          VARCHAR(32) NULL,
   trl2_prefix          VARCHAR(32) NULL,
   stp_type2            VARCHAR(6) NULL,
   stp_type3            VARCHAR(6) NULL,
   stp_type2_t          VARCHAR(8) NULL,
   stp_type3_t          VARCHAR(8) NULL,
   stp_delay_eligible      varchar(1) null,  -- PTS 41569  GAP 47  JSwindell  6-17-2008
   stp_firm_appt_flag      varchar(1) null,  -- PTS 41569  GAP 47  JSwindell  6-17-2008
   lgh_car_rate         MONEY    NULL, --PTS42845 MBR 12/16/09
   lgh_car_charge       MONEY    NULL, --PTS42845 MBR 12/16/09
   lgh_car_accessorials    DECIMAL(12,4)  NULL, --PTS42845 MBR 12/16/09
   lgh_car_totalcharge     MONEY    NULL, --PTS42845 MBR 12/16/09
   lgh_spot_rate        CHAR(1)  NULL, --PTS42845 MBR 12/16/09
   lgh_faxemail_created    CHAR(1)  NULL, --PTS42845 MBR 12/16/09
   lgh_acc_fsc       MONEY    NULL, --PTS42845 MBR 12/16/09
   evt_chassis          varchar(13) NULL,  --JLB PTS 49323
   evt_chassis2         varchar(13) NULL,  --JLB PTS 49323
   evt_dolly            varchar(13) NULL,  --JLB PTS 49323
   evt_dolly2           varchar(13) NULL,  --JLB PTS 49323
   evt_trailer3         varchar(13) NULL,  --JLB PTS 49323
   evt_trailer4         varchar(13) NULL,  --JLB PTS 49323
   fgt_volume2             FLOAT       NULL,    /* 08/12/2010 MDH PTS 53108: Added */
   fgt_volume2unit         VARCHAR (6) NULL,    /* 08/12/2010 MDH PTS 53108: Added */
   fgt_volumeunit2         VARCHAR (6) NULL, /* 08/12/2010 MDH PTS 53108: Added */
   --PTS 46682 JJF 20110506
   stp_ico_stp_number_parent int    NULL,
   stp_ico_stp_number_child int     NULL,
   --END PTS 46682 JJF 20110506
   ud_column1  varchar(255),      -- PTS 51911 per PTS 59158 SGB User Defined column
   ud_column1_t varchar(30),      --   PTS 51911 per PTS 59158 SGB User Defined column header
   ud_column2  varchar(255),      -- PTS 51911 per PTS 59158 SGB User Defined column
   ud_column2_t varchar(30),      --   PTS 51911 per PTS 59158 SGB User Defined column header
   ud_column3  varchar(255),      -- PTS 51911 per PTS 59158 SGB User Defined column
   ud_column3_t varchar(30),      --   PTS 51911 per PTS 59158 SGB User Defined column header
   ud_column4  varchar(255),      -- PTS 51911 per PTS 59158 SGB User Defined column
   ud_column4_t varchar(30),      --   PTS 51911 per PTS 59158 SGB User Defined column header
   lgh_plannedhours		DECIMAL(6,2) NULL,	--vjh 64871
   stp_arr_confirmed char(1) NULL,		-- PTS 69142 JJF 20130501
   stp_dep_confirmed char(1) NULL,		-- PTS 69142 JJF 20130501
   stp_rpt_miles decimal (7,2) null,		-- PTS 68385 -- added 
   stp_rpt_miles_mtid integer null, 
   mpp_pta_date datetime null
)

--BEGIN PTS 64373 SPN
SELECT @CalculateLegMiles = dbo.fn_GetSetting('CalculateLegMiles','C1')
--END PTS 64373 SPN

/* PTS 26791 - DJM - Display the Localization profiles for Eagle Global on the Tripfolder.         */
Select @service_revtype = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'ServiceRegionRevType'
select @servicezone_labelname =  ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )
select @servicecenter_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )
select @serviceregion_labelname =  (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )
select @sericearea_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )
select @lgh_permit_status = ( SELECT TOP 1 LGHPermitStatus FROM labelfile_headers)

--PTS41348 MBR 04/08/08
SELECT @NewCompanyHours = UPPER(LEFT(ISNULL(gi_string1, 'N'),1))
  FROM generalinfo
 WHERE gi_name = 'NewCompanyHours'

--PTS 40630 JJF 20071128
SET @retrievetrip = 1

SELECT @rowsecurity = gi_string1
FROM generalinfo
WHERE gi_name = 'RowSecurity'

--PTS 41877
--SELECT @tmwuser = suser_sname()
exec @tmwuser = dbo.gettmwuser_fn



--PTS 51570 JJF 20100510
--IF @rowsecurity = 'Y' AND EXISTS(SELECT *
--          FROM UserTypeAssignment
--          WHERE usr_userid = @tmwuser) BEGIN

-- --Do any orders pass security?
-- SELECT @orderpassrestrictioncount = count(*)
--    FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code
--          LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number
--          LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber ,
--    event,
--    freightdetail,
--    eventcodetable
-- WHERE freightdetail.stp_number = stops.stp_number and --pts40187 removed the outer join since it is not necessary any more from Ron
--    stops.stp_number = event.stp_number and
--    event.evt_eventcode = eventcodetable.abbr and
--    stops.mov_number = @mov_number and
--    (evt_sequence = 1 or fgt_sequence = 1)
--    --PTS 38816 JJF 20080312 add additional needed parms
--    AND dbo.RowRestrictByUser(orderheader.ord_BelongsTo, '', '', '') = 1

-- --any orders?
-- SELECT @ordercount = count(*)
--    FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code
--          LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number
--          LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber ,
--    event,
--    freightdetail,
--    eventcodetable
-- WHERE freightdetail.stp_number = stops.stp_number and --pts40187 removed the outer join since it is not necessary any more from Ron
--    stops.stp_number = event.stp_number and
--    event.evt_eventcode = eventcodetable.abbr and
--    stops.mov_number = @mov_number and
--    (evt_sequence = 1 or fgt_sequence = 1)
--    AND orderheader.ord_hdrnumber > 0

-- IF @ordercount > 0 BEGIN
--    IF @orderpassrestrictioncount = 0 BEGIN
--       SET @retrievetrip = 0
--    END
-- END
-- ELSE BEGIN
--    --make sure associated tractors at least are present
--    SELECT @orderpassrestrictioncount = count(*)
--       FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code
--             LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number
--             LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber
--             LEFT OUTER JOIN event on   stops.stp_number = event.stp_number
--             LEFT OUTER JOIN tractorprofile trc on event.evt_tractor = trc.trc_number,
--       freightdetail,
--       eventcodetable
--    WHERE freightdetail.stp_number = stops.stp_number and --pts40187 removed the outer join since it is not necessary any more from Ron
--       event.evt_eventcode = eventcodetable.abbr and
--       stops.mov_number = @mov_number and
--       (evt_sequence = 1 or fgt_sequence = 1)
--       --PTS 38816 JJF 20080312 add additional needed parms
--       AND dbo.RowRestrictByUser(trc.trc_terminal, '', '', '') = 1

--    IF @orderpassrestrictioncount = 0 BEGIN
--       SELECT @retrievetrip = 0
--    END
-- END
--END

----END PTS 40630 JJF 20071128

IF @rowsecurity = 'Y' BEGIN

   --Do any orders pass security?
   SELECT @orderpassrestrictioncount = count(*)
      FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code
            LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number
            LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber ,
      event,
      freightdetail,
      eventcodetable
   WHERE freightdetail.stp_number = stops.stp_number and --pts40187 removed the outer join since it is not necessary any more from Ron
      stops.stp_number = event.stp_number and
      event.evt_eventcode = eventcodetable.abbr and
      stops.mov_number = @mov_number and
      (evt_sequence = 1 or fgt_sequence = 1)
      --PTS 38816 JJF 20080312 add additional needed parms
      AND dbo.RowRestrictByUser('orderheader', orderheader.rowsec_rsrv_id, '', '', '') = 1

   --any orders?
   SELECT @ordercount = count(*)
      FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code
            LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number
            LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber ,
      event,
      freightdetail,
      eventcodetable
   WHERE freightdetail.stp_number = stops.stp_number and --pts40187 removed the outer join since it is not necessary any more from Ron
      stops.stp_number = event.stp_number and
      event.evt_eventcode = eventcodetable.abbr and
      stops.mov_number = @mov_number and
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
               LEFT OUTER JOIN event on   stops.stp_number = event.stp_number
               LEFT OUTER JOIN tractorprofile trc on event.evt_tractor = trc.trc_number,
         freightdetail,
         eventcodetable
      WHERE freightdetail.stp_number = stops.stp_number and --pts40187 removed the outer join since it is not necessary any more from Ron
         event.evt_eventcode = eventcodetable.abbr and
         stops.mov_number = @mov_number and
         (evt_sequence = 1 or fgt_sequence = 1)
         --PTS 38816 JJF 20080312 add additional needed parms
         AND dbo.RowRestrictByUser('tractorprofile', trc.rowsec_rsrv_id, '', '', '') = 1

      IF @orderpassrestrictioncount = 0 BEGIN
         SELECT @retrievetrip = 0
      END
   END
END
--END PTS 51570 JJF 20100510


/* PTS 26791 - DJM - Check setting used control use of the Localization values in the Planning
   worksheet and Tripfolder. To eliminate potential performance issues for customers
   not using this feature - SQL 2000 ONLY
*/
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
         evt_enddate departuredate,
         stops.stp_reasonlate reasonlate_arrival,
         stops.lgh_number,
         stops.stp_reasonlate_depart reasonlate_depart,
         stops.stp_sequence,
         stops.stp_comment comment,
         event.evt_hubmiles hubmiles,
         orderheader.ord_refnum,
         event.evt_carrier carrier,
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
         event.evt_status evt_status,
         stops.stp_mfh_mileage mfh_mileage,
         stops.stp_ord_mileage ord_mileage,
         (CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END) lgh_mileage,
         stops.mfh_number,
          (select cmp_name
         from company
         where company.cmp_id = orderheader.ord_billto) billto_name,
         city.cty_nmstct cty_nmstct,
         @mov_number mov_number,
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
		--PTS74465 JJF 20140106
		--lgh_type1,
		CASE @ord_status_top
			WHEN 'MST' THEN event.evt_lghtype1
			ELSE legheader.lgh_type1
		END as lgh_type1,
		--END PTS74465 JJF 20140106
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
         --PTS 36702 JJF 20070514
         CAST(ROUND(fgt_length, 0) AS int) / 12 AS fgt_length_feet,
         CAST(ROUND(fgt_length, 0) AS int) % 12 AS fgt_length_inches,
         --END PTS 36702 JJF 20070514
         freightdetail.fgt_width,
         --PTS 36702 JJF 20070514
         CAST(ROUND(fgt_width, 0) AS int) / 12 AS fgt_width_feet,
         CAST(ROUND(fgt_width, 0) AS int) % 12 AS fgt_width_inches,
         --END PTS 36702 JJF 20070514
         freightdetail.fgt_height,
         --PTS 36702 JJF 20070514
         CAST(ROUND(fgt_height, 0) AS int) / 12 AS fgt_height_feet,
         CAST(ROUND(fgt_height, 0) AS int) % 12 AS fgt_height_inches,
         --END PTS 36702 JJF 20070514
         freightdetail.fgt_stackable,
         stops.stp_podname,
         legheader.lgh_feetavailable,
         stops.stp_cmp_close,
         --PTS 37496 SGB 05/22/07 use stop status for stops and event status for events
         --stops.stp_departure_status,
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
         --PTS74465 JJF 20140106
         --lgh_type2,
		CASE @ord_status_top
			WHEN 'MST' THEN event.evt_lghtype2
			ELSE legheader.lgh_type2
		END as lgh_type2,
		  --END PTS74465 JJF 20140106
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
         -- PTS 19228 -- BL (start)
         stops.stp_reasonlate_text,
         stops.stp_reasonlate_depart_text
         -- PTS 19228 -- BL (end)
         ,cpr_density
         ,scm_subcode,
         stops.nlm_time_diff,
         -- JET - PTS 24078 - 8/31/2004, return the routed mileage type
         stops.stp_lgh_mileage_mtid
         -- PTS 24527 -- DPM (start)
         ,freightdetail.fgt_consignee,
         freightdetail.fgt_shipper,
         freightdetail.fgt_leg_origin,
         freightdetail.fgt_leg_dest,
         freightdetail.fgt_bolid,
         freightdetail.fgt_count2,
         freightdetail.fgt_count2unit,
         freightdetail.fgt_terms
         -- PTS 24527 -- DPM (end)
         -- PTS 21014 -- DPM (start)
         ,fgt_bol_status
         -- PTS 21014 -- DPM (end)
         ,0 inv_protect
         ,legheader.lgh_nexttrailer1
         ,legheader.lgh_nexttrailer2
         ,stops.stp_detstatus
         ,stops.stp_est_drv_time
         ,stops.stp_est_activity,
         -- PTS 26791 Begin
         'UNKNOWN' service_zone,
         'Service Zone' service_zone_t,
         'UNKNOWN' service_area,
         'Service Area' service_area_t,
         'UNKNOWN' service_center,
         'Service Center' service_center_t,
         'UNKNOWN' service_region,
         'Service Reqion' service_region_t
         -- PTS 26791 END
         ,stp_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0) -- RE - PTS #28205
         ,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0),
         lgh_route,
         lgh_booked_revtype1,
         -- JET - 3/13/2008 - PTS 41746, pull the username based on the gi_string3 value
         --'ExecutingTerminal' booked_revtype1_t,
         (select isnull(gi_string3, 'ExecutingTerminal') from generalinfo where gi_name = 'TrackBranch') booked_revtype1_t,
         stops.last_updateby,
         stops.last_updatedate,
         ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
         @lgh_permit_status lgh_permit_status_t,
         stops.last_updatebydepart,
         stops.last_updatedatedepart,
         freightdetail.fgt_osdreason,     --AROSS PTS 27619
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
         --PTS74465 JJF 20140106
         --legheader.lgh_type3,
		CASE @ord_status_top
			WHEN 'MST' THEN event.evt_lghtype3
			ELSE legheader.lgh_type3
		END as lgh_type3,
		  --END PTS74465 JJF 20140106
         'LghType3' lgh_type3_t,
		 --PTS74465 JJF 20140106
         --legheader.lgh_type4,
		CASE @ord_status_top
			WHEN 'MST' THEN event.evt_lghtype4
			ELSE legheader.lgh_type4
		END as lgh_type4,
		  --END PTS74465 JJF 20140106
         'LghType4' lgh_type4_t,
         'PackageUnits' fgt_packageunit_t,
         --PTS 32408 JJF 9/27/06
         event.evt_hubmiles_trailer1,
         event.evt_hubmiles_trailer2,
         --END PTS 32408 JJF 9/27/06
         --PTS 34405 JJF 10/31/06
         orderheader.ord_dest_zip,
         orderheader.ord_remark,
         ord_totalvolume,
         ord_totalvolumeunits,
         --PTS 34405 JJF 10/31/06
         stp_reasonlate_min,
         stp_reasonlate_depart_min,
         0 reasonlate_count,
         0 reasonlate_depart_count,
         --PTS 37029 EMK 08/22/07
         stops.stp_ord_toll_cost,
         fgt_osdstatus,
         fgt_osdopendate,
         fgt_osdclosedate,
         fgt_osdorigclaimamount,
         fgt_osdamtpaid,
         fgt_osdamtreceived,
         lgh_permitnumbers,                              -- RE - PTS #40759
         lgh_permitby,                                -- RE - PTS #40759
         lgh_permitdate,                                 -- RE - PTS #40759
         tank_loc = IsNull(freightdetail.tank_loc, 'UNKNOWN'),
         stp_rescheduledate,
         cast ('1950-01-01 00:00:01' as datetime) cmp_open,
				 cast ('2049-12-31 23:59:59' as datetime) cmp_close,
         stp_origarrival,
         (SELECT ISNULL(trl_prefix, ' ') FROM trailerprofile WHERE trl_id = event.evt_trailer1) trl1_prefix,
         (SELECT ISNULL(trl_prefix, ' ') FROm trailerprofile WHERE trl_id = event.evt_trailer2) trl2_prefix,
         stops.stp_type2,
         stops.stp_type3,
         'StpType2' stp_type2_t,
         'StpType3' stp_type3_t,
         stp_delay_eligible, -- PTS 41569  GAP 47  JSwindell  6-17-2008
         stp_firm_appt_flag,  -- PTS 41569  GAP 47  JSwindell  6-17-2008
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
         fgt_volume2, fgt_volume2unit, fgt_volumeunit2,     /* 08/12/2010 MDH PTS 53108: Added */
         --PTS 46682 JJF 20110506
         isnull(stops.stp_ico_stp_number_parent, 0) stp_ico_stp_number_parent,
         isnull(stops.stp_ico_stp_number_child, 0) stp_ico_stp_number_child,
         --END PTS 46682 JJF 20110506
         'UNKNOWN'   -- PTS 51911 per PTS 59158 SGB User Defined column
         ,'UD Column1'  -- PTS 51911 per PTS 59158 SGB User Defined column header
         ,'UNKNOWN'  -- PTS 51911 per PTS 59158 SGB User Defined column
         ,'UD Column2'     -- PTS 51911 per PTS 59158 SGB User Defined column header
         ,'UNKNOWN'  -- PTS 51911 per PTS 59158 SGB User Defined column
         ,'UD Column3'  -- PTS 51911 per PTS 59158 SGB User Defined column header
         ,'UNKNOWN'  -- PTS 51911 per PTS 59158 SGB User Defined column
         ,'UD Column4'     -- PTS 51911 per PTS 59158 SGB User Defined column header
         ,lgh_plannedhours,		--vjh 64871
         stops.stp_arr_confirmed, -- PTS 69142 JJF 20130501
         stops.stp_dep_confirmed -- PTS 69142 JJF 20130501
	 , stp_rpt_miles
	 , stp_rpt_miles_mtid 
	 , mpp_pta_date
      --pts40187 jguo outer join conversion
      FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code
               LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number
               LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber 
         			 left join event on stops.stp_number = event.stp_number
         			 left outer join manpowerprofile on manpowerprofile.mpp_id = event.evt_driver1,
         freightdetail,
         eventcodetable
      WHERE freightdetail.stp_number = stops.stp_number and --pts40187 removed the outer join since it is not necessary any more from Ron
         event.evt_eventcode = eventcodetable.abbr and
         stops.mov_number = @mov_number and
         (evt_sequence = 1 or fgt_sequence = 1)
         --PTS 40630 JJF 20071211
         and @retrievetrip = 1
         --END PTS 40630 JJF 20071211
--    FROM city,
--       legheader,
--       event,
--       stops,
--       freightdetail,
--       eventcodetable,
--       orderheader
--    WHERE stops.stp_city *= city.cty_code and
--       stops.lgh_number *= legheader.lgh_number and
--       freightdetail.stp_number =* stops.stp_number and
--       stops.stp_number = event.stp_number and
--       event.evt_eventcode = eventcodetable.abbr and
--       stops.mov_number = @mov_number and
--        stops.ord_hdrnumber *= orderheader.ord_hdrnumber and
--       (evt_sequence = 1 or fgt_sequence = 1)

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
         event.evt_status evt_status,
         stops.stp_mfh_mileage mfh_mileage,
         stops.stp_ord_mileage ord_mileage,
         (CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END) lgh_mileage,
         stops.mfh_number,
          (select cmp_name
         from company
         where company.cmp_id = orderheader.ord_billto) billto_name,
         city.cty_nmstct cty_nmstct,
         @mov_number mov_number,
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
         --PTS74465 JJF 20140106
         --lgh_type1,
		CASE @ord_status_top
			WHEN 'MST' THEN event.evt_lghtype1
			ELSE legheader.lgh_type1
		END as lgh_type1,
		  --END PTS74465 JJF 20140106
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
         --PTS 36702 JJF 20070514
         CAST(ROUND(fgt_length, 0) AS int) / 12 AS fgt_length_feet,
         CAST(ROUND(fgt_length, 0) AS int) % 12 AS fgt_length_inches,
         --END PTS 36702 JJF 20070514
         freightdetail.fgt_width,
         --PTS 36702 JJF 20070514
         CAST(ROUND(fgt_width, 0) AS int) / 12 AS fgt_width_feet,
         CAST(ROUND(fgt_width, 0) AS int) % 12 AS fgt_width_inches,
         --END PTS 36702 JJF 20070514
         freightdetail.fgt_height,
         --PTS 36702 JJF 20070514
         CAST(ROUND(fgt_height, 0) AS int) / 12 AS fgt_height_feet,
         CAST(ROUND(fgt_height, 0) AS int) % 12 AS fgt_height_inches,
         --END PTS 36702 JJF 20070514
         freightdetail.fgt_stackable,
         stops.stp_podname,
         legheader.lgh_feetavailable,
         stops.stp_cmp_close,
         --PTS 37496 SGB 05/22/07 use stop status for stops and event status for events
         --stops.stp_departure_status,
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
         --PTS74465 JJF 20140106
         --lgh_type2,
		CASE @ord_status_top
			WHEN 'MST' THEN event.evt_lghtype2
			ELSE legheader.lgh_type2
		END as lgh_type2,
		  --END PTS74465 JJF 20140106
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
         -- PTS 19228 -- BL (start)
         stops.stp_reasonlate_text,
         stops.stp_reasonlate_depart_text
         -- PTS 19228 -- BL (end)
         ,cpr_density
         ,scm_subcode,
         stops.nlm_time_diff,
         -- JET - PTS 24078 - 8/31/2004, return the routed mileage type
         stops.stp_lgh_mileage_mtid
         -- PTS 24527 -- DPM (start)
         ,freightdetail.fgt_consignee,
         freightdetail.fgt_shipper,
         freightdetail.fgt_leg_origin,
         freightdetail.fgt_leg_dest,
         freightdetail.fgt_bolid,
         freightdetail.fgt_count2,
         freightdetail.fgt_count2unit,
         freightdetail.fgt_terms
         -- PTS 24527 -- DPM (end)
         -- PTS 21014 -- DPM (start)
         ,fgt_bol_status
         -- PTS 21014 -- DPM (end)
         ,0 inv_protect
         ,legheader.lgh_nexttrailer1
         ,legheader.lgh_nexttrailer2
         ,stops.stp_detstatus
         ,stops.stp_est_drv_time
         ,stops.stp_est_activity,
         -- PTS 26791 Begin
         isNull((select cz_zone from cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip),'UNK') service_zone,
         @servicezone_labelname service_zone_t,
         isNull((select cz_area from cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip),'UNK') service_area,
         @sericearea_labelname service_area_t,
         isNull(Case isNull(@service_revtype,'UNKNOWN')
            when 'REVTYPE1' then
               (select max(svc_center) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
            when 'REVTYPE2' then
               (select max(svc_center) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
            when 'REVTYPE3' then
               (select max(svc_center) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
            when 'REVTYPE4' then
               (select max(svc_center) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
            else
               'UNKNOWN'
         End,'UNKNOWN') service_center,
         @servicecenter_labelname service_center_t,
         isNull(Case isNull(@service_revtype,'UNKNOWN')
            when 'REVTYPE1' then
               (select max(svc_region) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
            when 'REVTYPE2' then
               (select max(svc_region) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
            when 'REVTYPE3' then
               (select max(svc_region) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
            when 'REVTYPE4' then
               (select max(svc_region) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
            else 'UNKNOWN'
         End,'UNKNOWN') service_region,
         @serviceregion_labelname service_region_t
         -- PTS 26791 END
         ,stp_ord_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0) -- RE - PTS #28205
         ,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0),
         lgh_route,
         lgh_booked_revtype1,
         -- JET - 3/13/2008 - PTS 41746, pull the username based on the gi_string3 value
         --'ExecutingTerminal' booked_revtype1_t,
         (select isnull(gi_string3, 'ExecutingTerminal') from generalinfo where gi_name = 'TrackBranch') booked_revtype1_t,
         stops.last_updateby,
         stops.last_updatedate,
         ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
         @lgh_permit_status lgh_permit_status_t,
         stops.last_updatebydepart,
         stops.last_updatedatedepart,
         freightdetail.fgt_osdreason,     --AROSS PTS 27619
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
		 --PTS74465 JJF 20140106
         --legheader.lgh_type3,
		CASE @ord_status_top
			WHEN 'MST' THEN event.evt_lghtype3
			ELSE legheader.lgh_type3
		END as lgh_type3,
		  --END PTS74465 JJF 20140106
         'LghType3' lgh_type3_t,
		 --PTS74465 JJF 20140106
         --legheader.lgh_type4,
		CASE @ord_status_top
			WHEN 'MST' THEN event.evt_lghtype4
			ELSE legheader.lgh_type4
		END as lgh_type4,
		  --END PTS74465 JJF 20140106
         'LghType4' lgh_type4_t,
         'PackageUnits' fgt_packageunit_t,
         --PTS 32408 JJF 9/27/06
         event.evt_hubmiles_trailer1,
         event.evt_hubmiles_trailer2,
         --END PTS 32408 JJF 9/27/06
         --PTS 34405 JJF 10/31/06
         orderheader.ord_dest_zip,
         orderheader.ord_remark,
         ord_totalvolume,
         ord_totalvolumeunits,
         --PTS 34405 JJF 10/31/06
         stp_reasonlate_min,
         stp_reasonlate_depart_min,
         0 reasonlate_count,
         0 reasonlate_depart_count,
         --pts 37029 EMK 08/22/07
         stp_ord_toll_cost,
         fgt_osdstatus,
         fgt_osdopendate,
         fgt_osdclosedate,
         fgt_osdorigclaimamount,
         fgt_osdamtpaid,
         fgt_osdamtreceived,
         lgh_permitnumbers,                              -- RE - PTS #40759
         lgh_permitby,                                -- RE - PTS #40759
         lgh_permitdate,                                 -- RE - PTS #40759
         tank_loc = IsNull(freightdetail.tank_loc, 'UNKNOWN'),
         stp_rescheduledate,
         cast ('1950-01-01 00:00:01' as datetime) cmp_open,
				 cast ('2049-12-31 23:59:59' as datetime) cmp_close,
         stp_origarrival,
         (SELECT ISNULL(trl_prefix, ' ') FROM trailerprofile WHERE trl_id = event.evt_trailer1) trl1_prefix,
         (SELECT ISNULL(trl_prefix, ' ') FROm trailerprofile WHERE trl_id = event.evt_trailer2) trl2_prefix,
         stops.stp_type2,
         stops.stp_type3,
         'StpType2' stp_type2_t,
         'StpType3' stp_type3_t,
         stp_delay_eligible, -- PTS 41569  GAP 47  JSwindell  6-17-2008
         stp_firm_appt_flag, -- PTS 41569  GAP 47  JSwindell  6-17-2008
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
         fgt_volume2, fgt_volume2unit, fgt_volumeunit2,     /* 08/12/2010 MDH PTS 53108: Added */
         --PTS 46682 JJF 20110506
         isnull(stops.stp_ico_stp_number_parent, 0) stp_ico_stp_number_parent,
         isnull(stops.stp_ico_stp_number_child, 0) stp_ico_stp_number_child
         --END PTS 46682 JJF 20110506
         ,'UNKNOWN'  -- PTS 51911 per PTS 59158 SGB User Defined column
         ,'UD Column1'  -- PTS 51911 per PTS 59158 SGB User Defined column header
         ,'UNKNOWN'  -- PTS 51911 per PTS 59158 SGB User Defined column
         ,'UD Column2'     -- PTS 51911 per PTS 59158 SGB User Defined column header
         ,'UNKNOWN'  -- PTS 51911 per PTS 59158 SGB User Defined column
         ,'UD Column3'  -- PTS 51911 per PTS 59158 SGB User Defined column header
         ,'UNKNOWN'  -- PTS 51911 per PTS 59158 SGB User Defined column
         ,'UD Column4'     -- PTS 51911 per PTS 59158 SGB User Defined column header
         ,lgh_plannedhours,		--vjh 64871
         stops.stp_arr_confirmed, -- PTS 69142 JJF 20130501
         stops.stp_dep_confirmed -- PTS 69142 JJF 20130501
	 , stp_rpt_miles
	 , stp_rpt_miles_mtid 
	 , mpp_pta_date
--pts40187 jguo outer join conversion begin
      FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code
               LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number
               LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber
         			 left join event on stops.stp_number = event.stp_number
         			 left outer join manpowerprofile on manpowerprofile.mpp_id = event.evt_driver1,
         freightdetail,
         eventcodetable
      WHERE freightdetail.stp_number = stops.stp_number and --pts40187 removed the outer join since it is not necessary any more from Ron
         event.evt_eventcode = eventcodetable.abbr and
         stops.mov_number = @mov_number and
         (evt_sequence = 1 or fgt_sequence = 1)
         --PTS 40630 JJF 20071211
         and @retrievetrip = 1
         --END PTS 40630 JJF 20071211

--    FROM city,
--       legheader,
--       event,
--       stops,
--       freightdetail,
--       eventcodetable,
--       orderheader
--    WHERE stops.stp_city *= city.cty_code and
--       stops.lgh_number *= legheader.lgh_number and
--       freightdetail.stp_number =* stops.stp_number and
--       stops.stp_number = event.stp_number and
--       event.evt_eventcode = eventcodetable.abbr and
--       stops.mov_number = @mov_number and
--        stops.ord_hdrnumber *= orderheader.ord_hdrnumber and
--       (evt_sequence = 1 or fgt_sequence = 1)
--pts40187 jguo outer join conversion end

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


--PTS 51911 per PTS 59158 SGB Only run when setting turned on
Select @ud_column1 = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_COMPANY_COLUMNS'
Select @ud_column2 = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_COMPANY_COLUMNS'
Select @ud_column3 = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'
Select @ud_column4 = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_COLUMNS'

IF @ud_column1 = 'Y'
BEGIN
      Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_COMPANY_FUNCTIONS'
      If @procname not in ('','N')
      BEGIN


         SELECT   @udheader = dbo.ud_company_shell_FN ('','H',1)
         UPDATE #temp
         set ud_column1 = dbo.ud_company_shell_FN (t.cmp_id,'CO',1),
         ud_column1_t = @udheader
         from #temp t

      END

END

IF @ud_column2 = 'Y'
BEGIN
      Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_COMPANY_FUNCTIONS'
      If @procname not in ('','N')
      BEGIN


         SELECT   @udheader = dbo.ud_company_shell_FN ('','H',2)
         UPDATE #temp
         set ud_column2 = dbo.ud_company_shell_FN (t.cmp_id,'CO',2),
         ud_column2_t = @udheader
         from #temp t

      END

END

IF @ud_column3 = 'Y'
BEGIN
      Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
      If @procname not in ('','N')
      BEGIN


         SELECT   @udheader = dbo.UD_STOP_LEG_SHELL_FN ('','H',1)
         UPDATE #temp
         set ud_column3 = dbo.UD_STOP_LEG_SHELL_FN (t.stp_number,'S',1),
         ud_column3_t = @udheader
         from #temp t

      END

END

IF @ud_column4 = 'Y'
BEGIN
      Select @procname = Upper(LTRIM(RTRIM(isNull(gi_string2,'N')))) from generalinfo where gi_name = 'UD_STOP_LEG_FUNCTIONS'
      If @procname not in ('','N')
      BEGIN


         SELECT   @udheader = DBO.UD_STOP_LEG_SHELL_FN ('','H',2)
         UPDATE #temp
         set ud_column4 = DBO.UD_STOP_LEG_SHELL_FN (t.stp_number,'S',2),
         ud_column4_t = @udheader
         from #temp t

      END

END

SELECT *
  FROM #temp

GO
GRANT EXECUTE ON  [dbo].[d_tripfolder_sp] TO [public]
GO
