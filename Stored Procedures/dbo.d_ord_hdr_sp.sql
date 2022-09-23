SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[d_ord_hdr_sp] (@ordnum varchar(12),@number int, @rettype varchar(10), @IgnoreRowSecurity char(1) = 'Y')  
AS  


/************************************************************************************
 NAME:        d_ord_hdr_sp
 TYPE:        stored procedure
 DATABASE:    TMW
 PURPOSE:     Obtains all of the information for an order being retrieved through 
              the Order Entry module
        
        
 RETURNS:     The selected list of data.


REVISION LOG

DATE          WHO             REASON
----          ---             ------
__-__-__      dpdte 	      pts6733 add ord_fromorder to orderheader to keep track of ord copied from  
              dpete           8760 add ord_ratinquantity and ord_ratinunit to orderheader  
04-Oct-01     Vern Jewett     label=vmj1  PTS 11668 DD&S Express: support an "all-inclusive" charge functionality.  
28-Nov-01     dpete           pts12523 add ord_rate_type to return set   
06-Dec-01     DPETE           PTS12599 DPETE 12/6/01 bring back cmp_geoloc from company profile  
14-Feb-02     DPETE           PTS13311 DPETE 2/14/02 need  field for scanning barcode for King  
__-__-__                      PTS15367 Add ord_stlquantity,ord_stlunit,ord_stlquantity_type to return set  
__-__-__      vmj             --vmj1+ The new column ord_allinclusivecharge will store 0 if not used on this order, non-zero if this functionality IS  
                              -- being used on the order (other charge & rate column values will be derived from this column).  
                              -- all_inclusive_indc is non-database, allows the user to turn on/off this functionality on the window..  
__-__-__      KPM             --kpm pts 14397 add revenue fix for pay check box and revenue amount  
__-__-__      LOR             PTS# 15548 add ord_charge_type_lh  
__-__-__      DPETE           16479  
__-__-__      DPETE           17551 Add ord_mileage_adj_pct used only for selecting table rates  
                              with miles on one dimension (B&K)  
__-__-__      DPETE           22082-23301 Add ord_trlconfiguration  
__-__-__                      pts 25713 add toll cost
21-Mar-06     DJM             PTS 27430 - DJM - 3/21/2006 - Added columns to show/track Company Expirations.
14-Sep-06     PRB             PTS 33324 - PRB - 9/14/2006 - Added columns to show/track Account Pin information.
13-Jun-07     BDH             PTS 36884 BDH 6/13/07. Returning branch label from GI.
24-Sep-07     Ryan Hing       PTS 38781/38782 - RHING 9/24/2007 - Modified the where 
                              clause to use explicit JOIN operations
			      Added master_refnumber to the list of returned columns.
01-Oct-07     Ryan Hing       Added this banner.
01-Oct-07     Ryan Hing       Added sample execution line.
                              Fomratted comments.
11-Jan-08     MRoik           Added ord_cyclic_dsp_enabled and ord_preassign_ack_required
                              for PTS #38813
2/20/08 PTS 40962  DPETE      DHL wants default value for eventcallmintes to be nto checked on the screen
27-Mar-08     TGRIFFIT        Added 4 'GVW' columns for PTS #38846
28-Mar-08     MRoik           Added ord_anc_number for PTS #38843
4/7/08        DPETE           PTS40260 recode Paul's Hauling
                 recode DPETE 23776 add ord_nomincharges to return set
                 recode DPETE 30355 add ord_billto_addrtype and flag indicating multi address on
                 recode 30583 DPETE return ord_no_ecalc_miles flag
LOR	PTS# 42471	add ord_thirdpartytype3
3/4/2010	DJM		PTS 48227 - Added field ord_broker_percent
07/28/2010	PMILL	PTS 48227 - Added field ord_target_margin


*************************************************************************************/
  
DECLARE @char10  char(10),  
   @count_ref  int,  
   @count_req  int,  
   @ord_notes  int,  
   @comp_notes int,  
   --ILB 15827 03/31/03  
   @thirdparty_notes int,  
   --ILB 15827 03/31/03  
   @c_drops  int,  
   @ref_count  int,  
   @load_req  int,  
   @orig_datetime1  datetime,  
   @orig_datetime2  datetime,  
   @dest_datetime1  datetime,  
   @dest_datetime2  datetime,  
   @work_quantity  float(15),  
   @work_unit  varchar(6),  
   @work_accessorial       money,  
   /* KM notes enhancement */  
   @notes_count   int,  
   @n_ord_hdrnumber int,  
   @driver1 varchar(8),     
   @driver2 varchar(8),     
   @tractor varchar(8),     
   @trailer1 varchar(13),  
   @trailer2 varchar(13),  
   @carrier varchar(8),  
   @origin_cmpid varchar(8),  
   @dest_cmpid varchar(8),  
   @billto_cmpid varchar(8),  
   --ILB 15827 03/31/03  
                        @thirdparty     varchar(8),  
    --ILB 15827 03/31/03  
   @mov_number int ,  
   @barcode varchar(30),  
   @evtcarrier varchar(8),  
   /* KM notes enhancement end */  
	@branch varchar(60) 	-- 36884
  
  
SELECT @rettype = UPPER(@rettype)  
IF @rettype = ''   
 SELECT @rettype = 'ORDHDR'  
IF @rettype = 'ORDHDR'  
 SELECT @ordnum = ord_number  
 FROM orderheader  
 WHERE ord_hdrnumber = @number  
SELECT @c_drops = 0  
SELECT @char10 = 'OrdMscQty1'  
  
/*  
SELECT @comp_notes  = COUNT(*)  
FROM notes, orderheader  
WHERE orderheader.ord_number = @ordnum AND  
 notes.ntb_table = 'company' AND  
 notes.nre_tablekey IN ( orderheader.ord_originpoint ,  orderheader.ord_destpoint)  
SELECT @ord_notes = COUNT(*)  
FROM notes, orderheader  
WHERE orderheader.ord_number = @ordnum AND  
 notes.ntb_table = 'orderheader' AND  
 notes.nre_tablekey IN (CONVERT(char(12),orderheader.ord_hdrnumber))  
SELECT @ord_notes = @comp_notes + @ord_notes*/  
  
/* KM notes enhancement */  
select   @n_ord_hdrnumber = ord_hdrnumber,  
  @mov_number = mov_number,  
  @origin_cmpid = ord_originpoint,  
  @dest_cmpid = ord_destpoint,  
  @billto_cmpid = ord_billto,  
--ILB 15827 03/31/03  
                @thirdparty = ord_thirdpartytype1  
  --ILB 15827 03/31/03  
from   orderheader  
where   ord_number = @ordnum  
  
If @n_ord_hdrnumber > 0  
  Select @evtCarrier = IsNull(evt_carrier,'UNKNOWN'),
  @trailer2 = IsNull(evt_trailer2,'UNKNOWN') -- 24469
  From event, stops  
  Where stops.ord_hdrnumber = @n_ord_hdrnumber  
  and stp_sequence = 1  
  and event.stp_number = stops.stp_number  
  and evt_sequence = 1  
  
Select @evtcarrier = IsNull(@evtcarrier,'UNKNOWN')  
  
exec @ord_notes = d_notes_check_sp  1,  
   @mov_number,  
   @n_ord_hdrnumber,  
   '',   
   '',   
           '',   
           '',   
           '',   
           '',   
           '',  
   '',   
   @dest_cmpid,  
   @billto_cmpid,  
   0,  
   '',  
   '',  
   0  
  
--ILB 03/31/03 15827  
exec @thirdparty_notes = d_notes_check_sp  1,  
   @mov_number,  
   @n_ord_hdrnumber,  
   '',   
   '',   
           '',   
           '',   
           '',   
           '',   
           '',  
   '',   
   '',  
   '',  
   0,  
   '',  
   @thirdparty,  
   0  
--ILB 15827 03/31/03  
/* KM notes enhancement end */  
  
 SELECT @ref_count = COUNT(*)  
   FROM referencenumber,orderheader  
   WHERE orderheader.ord_number = @ordnum AND  
     referencenumber.ref_table = 'orderheader' AND  
     referencenumber.ref_tablekey = orderheader.ord_hdrnumber  
Select @load_req = COUNT(*)  
  FROM loadrequirement,orderheader  
  WHERE orderheader.ord_number = @ordnum AND  
    loadrequirement.mov_number = orderheader.mov_number --pts6419 
-- PTS 23835 -- BL (start)
    and (loadrequirement.lrq_expire_date >= orderheader.ord_startdate
    or loadrequirement.lrq_expire_date is NULL)
-- PTS 23835 -- BL (end)
  
declare @min_code int, @settlement_status varchar(35)  
  
IF @n_ord_hdrnumber > 0  
BEGIN  
 SELECT  @min_code = min(labelfile.code)  
 FROM  paydetail,  
   labelfile  
 WHERE  paydetail.ord_hdrnumber = @n_ord_hdrnumber AND  
   paydetail.pyd_status = labelfile.abbr AND   
   labelfile.labeldefinition = 'PayStatus'  
  
 select @settlement_status = labelfile.name  
 from  labelfile  
 where  code = @min_code and  
  labelfile.labeldefinition = 'PayStatus'  
  
END   
  
select @settlement_status = IsNull(@settlement_status,'UNKNOWN')      

--36884
select @branch = isnull(gi_string2, 'Branch') from generalinfo where gi_name = 'TrackBranch'
  
SELECT orderheader.ord_number,     
         orderheader.ord_status,     
         orderheader.ord_invoicestatus,     
         orderheader.ord_revtype1,     
         orderheader.ord_bookedby,     
         orderheader.ord_subcompany,     
         orderheader.ord_company,     
         orderheader.ord_contact,     
         orderheader.ord_customer,     
         orderheader.ord_originpoint,     
         o_city.cty_nmstct,     
         orderheader.ord_destpoint,     
         d_city.cty_nmstct,     
         orderheader.ord_bookdate,     
         orderheader.ord_startdate,     
         orderheader.ord_completiondate,     
         orderheader.ord_billto,     
         orderheader.ord_reftype,     
         orderheader.ord_refnum,     
         orderheader.ord_priority,     
         orderheader.ord_revtype2,     
         orderheader.ord_revtype3,     
         orderheader.ord_revtype4,     
         orderheader.ord_totalweight,     
         orderheader.ord_totalmiles,     
         orderheader.ord_totalpieces,     
         orderheader.ord_length,     
         orderheader.ord_lengthunit,     
         orderheader.ord_width,     
         orderheader.ord_widthunit,     
         orderheader.ord_height,     
         orderheader.ord_heightunit,     
         orderheader.ord_lowtemp,   -- replaced by ord_mintemp below pts 6643    
         orderheader.ord_hitemp,    -- replaced by ord_maxtemp below pts6643   
         orderheader.trl_type1,    
         orderheader.tar_tarriffnumber,     
         orderheader.tar_tariffitem,     
         orderheader.ord_quantity,     
         orderheader.ord_rate,     
         orderheader.ord_charge,     
         orderheader.ord_rateunit,     
         orderheader.ord_unit,     
         orderheader.ord_remark,     
         orderheader.ord_trailer,     
         orderheader.ord_tractor,     
         orderheader.ord_driver2,     
         orderheader.ord_driver1,     
         orderheader.ord_showcons,     
         orderheader.ord_showshipper,     
         orderheader.mov_number,     
         orderheader.mfh_hdrnumber,     
         orderheader.ord_pu_at,     
         orderheader.ord_dr_at,     
         orderheader.ord_shipper,     
         orderheader.ord_consignee,     
         orderheader.ord_hdrnumber,     
         orderheader.ord_currency,     
         orderheader.ord_currencydate,     
         orderheader.ord_supplier,     
         orderheader.ord_destcity,     
         orderheader.ord_origincity,     
         orderheader.cmd_code,     
         orderheader.ord_description,     
         orderheader.ord_terms,     
         orderheader.cht_itemcode,    
     'RevType1' revtype1 ,  
     'RevType2' revtype2 ,  
     'RevType3' revtype3 ,  
     'RevType4' revtype4,  
    'TrlType1' trltype1,  
         orderheader.ord_origin_earliestdate,     
         orderheader.ord_origin_latestdate,     
         orderheader.ord_odmetermiles,     
         orderheader.ord_stopcount,     
         orderheader.ord_dest_earliestdate,     
         orderheader.ord_dest_latestdate,     
         orderheader.ref_sid,     
         orderheader.ref_pickup,     
         orderheader.ord_cmdvalue,            orderheader.ord_accessorial_chrg,     
         orderheader.ord_totalcharge,     
         orderheader.ord_availabledate,     
    @c_drops c_drops,  
         orderheader.ord_totalvolume,     
         orderheader.ord_miscqty,     
         @char10 ord_mscqty1_t,  
     @ref_count ref_count,   
    @ord_notes count_notes,  
    @load_req load_req,  
    orderheader.ord_tempunits,  
    orderheader.ord_totalweightunits,     
        orderheader.ord_totalvolumeunits,     
        orderheader.ord_totalcountunits,  
        orderheader.ord_datetaken  ,  
 orderheader.ord_loadtime,  
 orderheader.ord_unloadtime,  
 orderheader.ord_drivetime,  
 orderheader.ord_rateby,  
 ordby.cmp_name,  
 ordby.cty_nmstct,  
 orig.cmp_name,  
 dest.cmp_name,  
 billto.cmp_name,  
 billto.cty_nmstct,  
 @orig_datetime1 orig_datetime1,  
 @orig_datetime2 orig_datetime2,  
 @dest_datetime1 dest_datetime1,  
 @dest_datetime2 dest_datetime2,  
 @work_quantity work_quantity,  
 @work_unit work_unit,  
 orderheader.ord_quantity_type,  
 orderheader.tar_number,  
 @work_accessorial,   
 orderheader.ord_thirdpartytype1,   
 orderheader.ord_thirdpartytype2,  
 'TprType1' ord_thirdpartytype1_t,  
 'TprType2' ord_thirdpartytype2_t,  
 @settlement_status settlement_status,  
 orderheader.ord_charge_type,  
              orderheader.ord_fromorder ,  
              orderheader.ord_mintemp,  
              orderheader.ord_maxtemp,  
 orderheader.ord_distributor,  
        OrdBy_Active = ordby.cmp_active,  
 Origin_Active = orig.cmp_active,  
   Dest_Active = dest.cmp_active,  
   BillTo_Active = billto.cmp_active,  
 IsNull(orderheader.ord_cod_amount, 0) ord_cod_amount,  
 orderheader.opt_trc_type4,  
 orderheader.opt_trl_type4,  
 'TrcType4' trctype4,  
 'TrlType4' opt_trltype4 ,  
 ord_ratingquantity = ISNULL(ord_ratingquantity,ord_quantity),  
 ord_ratingunit = ISNULL(ord_ratingunit,ord_unit),  
        ord_booked_revtype1,     
         orderheader.ord_trl_type2,     
         orderheader.ord_trl_type3,     
         orderheader.ord_trl_type4,  
 'TrlType2' trltype2,  
 'TrlType3' trltype3,  
 'TrlType4' trltype4,   
 ord_mileagetable,  
 orderheader.ord_allinclusivecharge, --vmj1-  
 all_inclusive_indc = 'N', --vmj1-  
 ISNULL(ord_rate_type,0) ord_rate_type,  
 ISNULL(orig.cmp_geoloc,'') orig_cmp_geoloc,  
 ISNULL(dest.cmp_geoloc,'') dest_cmp_geoloc,  
 ord_hideshipperaddr,  
 ord_hideconsignaddr,  
 ord_barcode,  
        ord_revenue_pay_fix,  
        ord_revenue_pay,  
-- use all this case stuff until the new fields have been in use a while (9/5/2)  
 ord_stlquantity = Case  
  When Isnull(ord_stlquantity,0) <> 0 or IsNull(ord_stlquantity_type,0) = 1 then ord_stlquantity  
    When ord_quantity_type = 2 Then ord_quantity  
  Else Isnull(ord_stlquantity,0)   
  End,  
 ord_stlunit = Case  
  When Isnull(ord_stlquantity,0) <> 0 or IsNull(ord_stlquantity_type,0) = 1 then IsNull(ord_stlunit,'UNK')  
  When ord_quantity_type = 2 Then ord_unit  
  Else Isnull(ord_stlunit,'MIL')  
  End,  
 ord_stlquantity_type = Case  
  When IsNull(ord_stlquantity_type,0) <> 0 Then ord_stlquantity_type  
  When ord_quantity_type = 2 Then 1  
  Else 0  
  End,  
 ord_reserved_number,  
 ord_customs_document,   
        ord_noautosplit,   
        ord_noautotransfer,  
 ord_totalloadingmeters,  
 ord_totalloadingmetersunit,  
 ISNULL(ord_charge_type_lh,0) ord_charge_type_lh,  
 @evtcarrier,  
 isnull (ord_entryport, 'UNKNOWN'),  
 isnull (ord_exitport, 'UNKNOWN'),  
 --ILB 03/31/03 15827  
        @thirdparty_notes thirdparty_notes,  
        --ILB 03/31/03 15827  
 IsNull(ord_mileage_adj_pct,0) ord_mileage_pct,  
        trc_TareWgt = IsNull(trc_tareweight,0),  
    trc_tareweight_uom = IsNull(trc_tareweight_uom,'LBS'),  
    trl_tareweight = IsNull(trl_tareweight,0),  
    trl_tareweight_uom = IsNull(trl_tareweight_uom,'LBS'),  
 ord_commodities_weight,  
 isnull(ord_intermodal,'N') ord_intermodal,  
 ord_dimfactor,  
  ord_TrlConfiguration = IsNull(ord_TrlCOnfiguration,'UNK'), ord_TrlConfiguration_t = 'EquipmConfiguration',
 ord_origin_zip,
 ord_dest_zip,
	ord_rate_mileagetable,
 ord_toll_cost,
IsNull(ord_raildest,'UNKNOWN') ord_raildest,
IsNull(ord_railpoolid,'UNKNOWN') ord_railpoolid,
IsNull(ord_trailer2,'UNKNOWN') ord_trailer2,
IsNull(ord_route, 'UNKNOWN') ord_route,
ord_route_effc_date,
ord_route_exp_date,    
/*'Branch' ord_branch_t, 36884, changed to @branch variable  */
@branch ord_branch_t,
evt_trailer = @trailer2,
ord_odmetermiles_mtid = IsNull(ord_odmetermiles_mtid,0),
0 billto_pri1now,
0 billto_pri1soon,
0 billto_pri2now,
0 billto_pri2soon,
0 shipper_pri1now,
0 shipper_pri1soon,
0 shipper_pri2now,
0 shipper_pri2soon,
0 consignee_pri1now,
0 consignee_pri1soon,
0 consignee_pri2now,
0 consignee_pri2soon,
'LoadAccount' loadaccount_t, --PTS33324
ISNULL(ord_accounttype, 'UNK'), --PTS33324
ord_pin,                         --PTS33324
isnull(ord_manualeventcallminutes, -1),	 --isnull(ord_manualeventcallminutes, 0), pts35708
isnull(ord_manualcheckcallminutes, 0),	--pts35708
--PTS 35677 JJF/RE 2007-04-12
ord_grossweight,
ord_tareweight,
ord_order_source,
--END PTS 35677 JJF/RE 2007-04-12
--PTS 38461 EMK
orig.cmp_address1 orig_address1,
orig.cmp_address2 orig_address2,
orig.cmp_primaryphone orig_phone,
orig.cmp_contact orig_contact,
dest.cmp_address1 dest_address1,
dest.cmp_address2 dest_address2,
dest.cmp_primaryphone dest_phone,
dest.cmp_contact dest_contact,
orig.cmp_address3 orig_address3,
dest.cmp_address3 dest_address3
--PTS 38461 EMK
--PTS RHING - 38781 2007-09-19
,mstref.master_refnumber 
--MROIK - PTS #38813
,orderheader.ord_cyclic_dsp_enabled       
,orderheader.ord_preassign_ack_required
--END MROIK - PTS #38813
,orderheader.ord_anc_number --MROIK - PTS #38843
,ord_gvw_unit           --PTS 38846 TGRIFFIT
,ord_gvw_amt            --PTS 38846 TGRIFFIT
,ord_gvw_adjstd_unit    --PTS 38846 TGRIFFIT
,ord_gvw_adjstd_amt     --PTS 38846 TGRIFFIT
,ord_nomincharges = isnull(ord_noMinCharges,'N') --40260 recode Pauls
,multiaddrcount = (select count(*) from companyaddress where cmp_id = ord_billto) --40260 recode Pauls
,car_key --40260 recode Pauls
,ord_norecalc_miles = isnull(ord_no_recalc_miles,'N'), --40260 recode Pauls
 ord_thirdparty_split,
 ord_thirdparty_split_percent, 
 ord_thirdpartytype3,
 --PTS 46005 JJF 20090414
 ord_extequip_automatch,
 ISNULL(ord_broker, 'UNKNOWN') ord_broker,
 ISNULL(branch.brn_executingterminal_protect, 'N') brn_executingterminal_protect,
--END PTS 46005 JJF 20090414
--PTS 49184 JJF 20090923
isnull(ord_paystatus_override, 'NPD'),
--PTS 49184 JJF 20090923
 ISNULL(ord_broker_percent,0) ord_broker_percent,		-- PTS 48227 DJM
 ISNULL(ord_target_margin, 0) ord_target_margin			-- PTS 48227 PMILL
 ,ord_ratemode		/* 11/18/2011 NQIAO PTS 58978 */
 ,ord_servicelevel	/* 11/18/2011 NQIAO PTS 58978 */
 ,ord_servicedays	/* 11/18/2011 NQIAO PTS 58978 */
 --PTS 60199 JJF 20121217
,ISNULL(ord_over_credit_limit_approved, 'N')
,ISNULL(ord_over_credit_limit_approved_by, ''),
--END PTS 60199 JJF 20121217
 ISNULL(commodity.cmd_class2, 'UNKNOWN') cmd_class2		--PTS52530 MBR 06/14/13
-- WARNING If you add a column above to orderheader and want it to copy, also change cloneorderwithoption proc  
FROM orderheader
JOIN company billto on orderheader.ord_billto = billto.cmp_id
JOIN company orig on orderheader.ord_originpoint = orig.cmp_id
JOIN company dest on orderheader.ord_destpoint = dest.cmp_id		
JOIN company ordby on orderheader.ord_company = ordby.cmp_id
JOIN city d_city on orderheader.ord_destcity = d_city.cty_code
JOIN city o_city on orderheader.ord_origincity = o_city.cty_code
JOIN tractorprofile tr on orderheader.ord_tractor = tr.trc_number
JOIN trailerprofile trl on orderheader.ord_trailer = trl.trl_id
LEFT OUTER JOIN masterorders_ref mstref on mstref.ord_hdrnumber = orderheader.ord_hdrnumber
LEFT OUTER JOIN commodity ON orderheader.cmd_code = commodity.cmd_code
LEFT OUTER JOIN branch ON orderheader.ord_broker = branch.brn_id
WHERE 	orderheader.ord_number = @ordnum
--PTS 38816 JJF 20080312 add additional needed parms
--PTS 40630 JJF 20071211
--PTS 51570 JJF 20100510 
AND (dbo.RowRestrictByUser('orderheader', orderheader.rowsec_rsrv_id, '', '', '') = 1 OR isnull(@IgnoreRowSecurity, 'N') = 'Y')
--AND (dbo.RowRestrictByUser(ord_BelongsTo, '', '', '') = 1 OR isnull(@IgnoreRowSecurity, 'N') = 'Y')
--END PTS 40630 JJF 20071211


/*
FROM orderheader,     
 company ordby,  
 company orig,  
 company dest,  
 company billto,  
 city    d_city,  
 city o_city,  
 tractorprofile tr,  
 trailerprofile trl  
WHERE orderheader.ord_number = @ordnum AND  
 orderheader.ord_billto *= billto.cmp_id AND  
 orderheader.ord_originpoint *= orig.cmp_id AND  
 orderheader.ord_destpoint *= dest.cmp_id AND  
 orderheader.ord_company *= ordby.cmp_id AND  
 orderheader.ord_destcity *= d_city.cty_code AND  
 orderheader.ord_origincity *= o_city.cty_code and  
    ord_tractor *= tr.trc_number and  
    ord_trailer *= trl.trl_id  
*/
GO
GRANT EXECUTE ON  [dbo].[d_ord_hdr_sp] TO [public]
GO
