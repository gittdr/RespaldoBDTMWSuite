SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [dbo].[D_TRIPFOLDER_POM_SP]
	@mov_number integer
as
/**
 *
 * NAME:
 * dbo.D_TRIPFOLDER_POM_SP
 *
 * TYPE:
 * StoredProcedure -- Used in the Partorder Manager Window only!
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
 *		the user ID of the last person to update one of the arrival datetimes or arrival status
 * 203 - stops.last_updatedate
 *		the date of the last update of the arrival datetimes or arrival status
 * 204 - lgh_permit_status
 * 205 - lgh_permit_status_t
 * 206 - stops.last_updatebydepart
 *		the user ID of the last person to update one of the departure datetimes or departure status
 * 207 - stops.last_updatedatedepart
 *		the date of the last update of the departure datetimes or departyrestatus
 * 208 - freightdetail.fgt_osdreason; Character code representing an overage,shortage or damage to freight
 * 209 - freightdetail.fgt_osdquantity; Quantity for OSD
 * 210 - freightdetail.fgt_osdunit; unit of measure for osd quantity
 * 211 - freightdetail.fgt_osdcomment; freeform text comment for OSD
 * 212 - orderheader.ord_no_recalc_miles; Flag to not lookup miles. 
 * 213 - legheader.lgh_type3
 * 214 - lgh_type3_t
 * 215 - legheader.lgh_type4
 * 216 - lgh_type4_t
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
LOR	- PTS# 27341(28194) - route, booked_revtype1
 * 08/2/2005.01 - Vince Herman ? PTS 29052 add stp_lastupdatebydepart and stp_lastupdatedatedepart
 * 08/11/2005.02 - A. Rossman  - PTS 27619 add fgt_osdreason,fgt_osdunit,fgt_osdquantity and fgt_osdcomment
 * 10/26/2005.03 - MRH - PTS 30082 Added ord_no_recalc_miles.
 * PTS 33550 - 07/07/2006 - DJM - Added fields for lgh_type3 and lgh_type4
 *
 **/




Declare @Service_revtype	varchar(10),
	@servicezone_labelname varchar(20),
	@servicecenter_labelname varchar(20),
	@serviceregion_labelname varchar(20),
	@sericearea_labelname varchar(20),
	@localization	char(1),
	@lgh_permit_status varchar(20)


/* PTS 26791 - DJM - Display the Localization profiles for Eagle Global on the Tripfolder.			*/
Select @service_revtype = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'ServiceRegionRevType'
select @servicezone_labelname =  ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )
select @servicecenter_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )
select @serviceregion_labelname =  (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )
select @sericearea_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )
select @lgh_permit_status = ( SELECT TOP 1 LGHPermitStatus FROM labelfile_headers)

/* PTS 26791 - DJM - Check setting used control use of the Localization values in the Planning 
	worksheet and Tripfolder. To eliminate potential performance issues for customers
	not using this feature - SQL 2000 ONLY
*/
select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'


if Left(@localization,1) <> 'Y'
	Begin
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
			stops.stp_lgh_mileage lgh_mileage, 
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
			freightdetail.fgt_width,
			freightdetail.fgt_height,
			freightdetail.fgt_stackable,
			stops.stp_podname,
			legheader.lgh_feetavailable,
			stops.stp_cmp_close,
			stops.stp_departure_status,
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
			'ExecutingTerminal' booked_revtype1_t,
			stops.last_updateby,
			stops.last_updatedate,
			ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
			@lgh_permit_status lgh_permit_status_t,
			stops.last_updatebydepart,
			stops.last_updatedatedepart,
			freightdetail.fgt_osdreason,	   --AROSS PTS 27619
			freightdetail.fgt_osdquantity,
			freightdetail.fgt_osdunit,
			freightdetail.fgt_osdcomment,
			orderheader.ord_no_recalc_miles,
			legheader.lgh_type3,
			'LghType3' lgh_type3_t,
			legheader.lgh_type4,
			'LghType4' lgh_type4_t
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
--		FROM city,
--			legheader,
--			event, 
--			stops, 
--			freightdetail,
--			eventcodetable, 
--			orderheader
--		WHERE stops.stp_city *= city.cty_code and
--			stops.lgh_number *= legheader.lgh_number and
--			freightdetail.stp_number =* stops.stp_number and 
--			stops.stp_number = event.stp_number and 
--			event.evt_eventcode = eventcodetable.abbr and
--			stops.mov_number = @mov_number and
--			 stops.ord_hdrnumber *= orderheader.ord_hdrnumber and
--			(evt_sequence = 1 or fgt_sequence = 1)

	End
else
	Begin

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
			stops.stp_lgh_mileage lgh_mileage, 
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
			freightdetail.fgt_width,
			freightdetail.fgt_height,
			freightdetail.fgt_stackable,
			stops.stp_podname,
			legheader.lgh_feetavailable,
			stops.stp_cmp_close,
			stops.stp_departure_status,
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
			'ExecutingTerminal' booked_revtype1_t,
			stops.last_updateby,
			stops.last_updatedate,
			ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
			@lgh_permit_status lgh_permit_status_t,
			stops.last_updatebydepart,
			stops.last_updatedatedepart,
			freightdetail.fgt_osdreason,	   --AROSS PTS 27619
			freightdetail.fgt_osdquantity,
			freightdetail.fgt_osdunit,
			freightdetail.fgt_osdcomment,
			orderheader.ord_no_recalc_miles,
			legheader.lgh_type3,
			'LghType3' lgh_type3_t,
			legheader.lgh_type4,
			'LghType4' lgh_type4_t
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
			
		--FROM city,
		--	legheader,
		--	event, 
		--	stops, 
		--	freightdetail,
		--	eventcodetable, 
		--	orderheader
		--WHERE stops.stp_city *= city.cty_code and
		--	stops.lgh_number *= legheader.lgh_number and
		--	freightdetail.stp_number =* stops.stp_number and 
		--	stops.stp_number = event.stp_number and 
		--	event.evt_eventcode = eventcodetable.abbr and
		--	stops.mov_number = @mov_number and
		--	 stops.ord_hdrnumber *= orderheader.ord_hdrnumber and
		--	(evt_sequence = 1 or fgt_sequence = 1)


	End
GO
GRANT EXECUTE ON  [dbo].[D_TRIPFOLDER_POM_SP] TO [public]
GO
