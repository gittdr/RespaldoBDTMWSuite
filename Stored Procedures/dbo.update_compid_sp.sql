SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.update_compid_sp    Script Date: 8/20/97 1:59:49 PM ******/
create proc [dbo].[update_compid_sp] @oldcompid varchar(8), 
                             @newcompid varchar(8)
/*                             @newcompname varchar(40)*/
as
BEGIN
/*EXEC timerins "UPDATE", "START"*/
create index company on orderheader (ord_company)
   UPDATE orderheader
      SET orderheader.ord_company = @newcompid
    WHERE orderheader.ord_company = @oldcompid
drop index orderheader.company

create index company on orderheader (ord_originpoint)
   UPDATE orderheader
      SET orderheader.ord_originpoint = @newcompid
    WHERE orderheader.ord_originpoint = @oldcompid
drop index orderheader.company

create index company on orderheader (ord_destpoint)
   UPDATE orderheader
      SET orderheader.ord_destpoint = @newcompid
    WHERE orderheader.ord_destpoint = @oldcompid
drop index orderheader.company

create index company on orderheader (ord_billto)
   UPDATE orderheader
      SET orderheader.ord_billto = @newcompid
    WHERE orderheader.ord_billto = @oldcompid
drop index orderheader.company

create index company on orderheader (ord_shipper)
   UPDATE orderheader
      SET orderheader.ord_shipper = @newcompid
    WHERE orderheader.ord_shipper = @oldcompid
drop index orderheader.company

create index company on orderheader (ord_consignee)
   UPDATE orderheader
      SET orderheader.ord_consignee = @newcompid
    WHERE orderheader.ord_consignee = @oldcompid
drop index orderheader.company

create index company on orderheader (ord_showshipper)
   UPDATE orderheader
      SET orderheader.ord_showshipper = @newcompid
    WHERE orderheader.ord_showshipper = @oldcompid
drop index orderheader.company

create index company on orderheader (ord_showcons)
   UPDATE orderheader
      SET orderheader.ord_showcons = @newcompid
    WHERE orderheader.ord_showcons = @oldcompid
drop index orderheader.company

create index company on orderheader (ord_subcompany)
   UPDATE orderheader
      SET orderheader.ord_subcompany = @newcompid
    WHERE orderheader.ord_subcompany = @oldcompid
drop index orderheader.company

create index company on stops (cmp_id)
   UPDATE stops
      SET stops.cmp_id = @newcompid
    WHERE stops.cmp_id = @oldcompid
drop index stops.company

create index company on legheader (cmp_id_start)
   UPDATE legheader
      SET legheader.cmp_id_start = @newcompid
    WHERE legheader.cmp_id_start = @oldcompid
drop index legheader.company

create index company on legheader (cmp_id_end)
   UPDATE legheader
      SET legheader.cmp_id_end = @newcompid
    WHERE legheader.cmp_id_end = @oldcompid
drop index legheader.company

create index company on invoiceheader (ivh_billto)
   UPDATE invoiceheader
      SET invoiceheader.ivh_billto = @newcompid
    WHERE invoiceheader.ivh_billto = @oldcompid
drop index invoiceheader.company

create index company on invoiceheader (ivh_shipper)
   UPDATE invoiceheader
      SET invoiceheader.ivh_shipper = @newcompid
    WHERE invoiceheader.ivh_shipper = @oldcompid
drop index invoiceheader.company

create index company on invoiceheader (ivh_consignee)
   UPDATE invoiceheader
      SET invoiceheader.ivh_consignee = @newcompid
    WHERE invoiceheader.ivh_consignee = @oldcompid
drop index invoiceheader.company

create index company on invoiceheader (ivh_originpoint)
   UPDATE invoiceheader
      SET invoiceheader.ivh_originpoint = @newcompid
    WHERE invoiceheader.ivh_originpoint = @oldcompid
drop index invoiceheader.company

create index company on invoiceheader (ivh_destpoint)
   UPDATE invoiceheader
      SET invoiceheader.ivh_destpoint = @newcompid
    WHERE invoiceheader.ivh_destpoint = @oldcompid
drop index invoiceheader.company

create index company on invoiceheader (ivh_order_by)
   UPDATE invoiceheader
      SET invoiceheader.ivh_order_by = @newcompid
    WHERE invoiceheader.ivh_order_by = @oldcompid
drop index invoiceheader.company

create index company on invoicedetail (ivd_billto)
   UPDATE invoicedetail
      SET ivd_billto = @newcompid
    WHERE ivd_billto = @oldcompid
drop index invoicedetail.company

create index company on invoicedetail (cmp_id)
   UPDATE invoicedetail
      SET cmp_id = @newcompid
    WHERE cmp_id = @oldcompid
drop index invoicedetail.company

create index company on invoicedetail (ivd_orig_cmpid)
   UPDATE invoicedetail
      SET ivd_orig_cmpid = @newcompid
    WHERE ivd_orig_cmpid = @oldcompid
drop index invoicedetail.company

create index company on accessorydetail (cmp_id)
   UPDATE accessorydetail
      SET accessorydetail.cmp_id = @newcompid
    WHERE accessorydetail.cmp_id = @oldcompid
drop index accessorydetail.company

create index company on acct_glnum (tts_co)
   UPDATE acct_glnum
      SET acct_glnum.tts_co = @newcompid
    WHERE acct_glnum.tts_co = @oldcompid
drop index acct_glnum.company

create index company on cim_refnumbers (rfr_cmp_id)
   UPDATE cim_refnumbers
      SET cim_refnumbers.rfr_cmp_id = @newcompid
    WHERE cim_refnumbers.rfr_cmp_id = @oldcompid
drop index cim_refnumbers.company

create index company on companydirections (cdr_cmpid)
   UPDATE companydirections
      SET companydirections.cdr_cmpid = @newcompid
    WHERE companydirections.cdr_cmpid = @oldcompid
drop index companydirections.company

-- BEGIN PTS 69039 determine if change will violate existing cxr_conship key 

If (select count(1) from customercrossref 
	where cxr_shipper = @newcompid 
	and cxr_consignee 
	in (select ccr2.cxr_consignee from customercrossref ccr2
		where ccr2.cxr_shipper = @newcompid))
		= 0
		BEGIN
			create index company on customercrossref (cxr_shipper)
			   UPDATE customercrossref
				  SET customercrossref.cxr_shipper = @newcompid
				WHERE customercrossref.cxr_shipper = @oldcompid
			drop index customercrossref.company
		END
		
/*		
create index company on customercrossref (cxr_shipper)
   UPDATE customercrossref
	SET customercrossref.cxr_shipper = @newcompid
	WHERE customercrossref.cxr_shipper = @oldcompid
	drop index customercrossref.company	
	*/	
If (select count(1) from customercrossref 
	where cxr_consignee = @newcompid 
	and cxr_shipper 
	in (select ccr2.cxr_shipper from customercrossref ccr2
		where ccr2.cxr_consignee = @newcompid))
		= 0
		BEGIN 
		create index company on customercrossref (cxr_consignee)
		   UPDATE customercrossref
			  SET customercrossref.cxr_consignee = @newcompid
			WHERE customercrossref.cxr_consignee = @oldcompid
		drop index customercrossref.company

		END
/*		
create index company on customercrossref (cxr_consignee)
   UPDATE customercrossref
      SET customercrossref.cxr_consignee = @newcompid
    WHERE customercrossref.cxr_consignee = @oldcompid
drop index customercrossref.company
--END  PTS 69039 determine if change will violate existing cxr_conship key  
*/


create index company on dispatchview (dv_company)
   UPDATE dispatchview
      SET dispatchview.dv_company = @newcompid
    WHERE dispatchview.dv_company = @oldcompid
drop index dispatchview.company

create index company on dispatchview (dv_cmp_id)
   UPDATE dispatchview
      SET dispatchview.dv_cmp_id = @newcompid
    WHERE dispatchview.dv_cmp_id = @oldcompid
drop index dispatchview.company

create index company on driverpayexport (cmp_name_shipper)
   UPDATE driverpayexport
      SET driverpayexport.cmp_name_shipper = @newcompid
    WHERE driverpayexport.cmp_name_shipper = @oldcompid
drop index driverpayexport.company

create index company on driverpayexport (cmp_name_consignee)
   UPDATE driverpayexport
      SET driverpayexport.cmp_name_consignee = @newcompid
    WHERE driverpayexport.cmp_name_consignee = @oldcompid
drop index driverpayexport.company

create index company on driverpayexport (cmp_name_billto)
   UPDATE driverpayexport
      SET driverpayexport.cmp_name_billto = @newcompid
    WHERE driverpayexport.cmp_name_billto = @oldcompid
drop index driverpayexport.company

--PTS 69039 
--create index company on eventdefualts (cmp_id)
create index company on eventdefaults (cmp_id)
   UPDATE eventdefaults
      SET eventdefaults.cmp_id = @newcompid
    WHERE eventdefaults.cmp_id = @oldcompid
drop index eventdefaults.company

create index company on importcredit (cmp_id)
   UPDATE importcredit
      SET importcredit.cmp_id = @newcompid
    WHERE importcredit.cmp_id = @oldcompid
drop index importcredit.company
/*
create index company labelfile (abbr)
   UPDATE labelfile
      SET labelfile.abbr = @newcompid
    WHERE labelfile.abbr = @oldcompid 
drop index labelfile.company
create index company labelfile (abbr)
   UPDATE labelfile
      SET labelfile.name = @newcompname
    WHERE labelfile.name = @newcompid
drop index labelfile.company
create index company on loadrequirement2 (cmp_id)
   UPDATE loadrequirement2
      SET loadrequirement2.cmp_id = @newcompid
    WHERE loadrequirement2.cmp_id = @oldcompid
drop index loadrequirement2.company
*/
create index company on manpowerprofile (mpp_company)
   UPDATE manpowerprofile
      SET manpowerprofile.mpp_company = @newcompid
    WHERE manpowerprofile.mpp_company = @oldcompid
drop index manpowerprofile.company

create index company on manpowerprofile (mpp_avl_cmp_id)
   UPDATE manpowerprofile
      SET manpowerprofile.mpp_avl_cmp_id = @newcompid
    WHERE manpowerprofile.mpp_avl_cmp_id = @oldcompid
drop index manpowerprofile.company

create index company on manpowerprofile (mpp_pln_cmp_id)
   UPDATE manpowerprofile
      SET manpowerprofile.mpp_pln_cmp_id = @newcompid
    WHERE manpowerprofile.mpp_pln_cmp_id = @oldcompid
drop index manpowerprofile.company

create index company on payto (pto_company)
   UPDATE payto
      SET payto.pto_company = @newcompid
    WHERE payto.pto_company = @oldcompid
drop index payto.company

create index company on scheduleparms (ord_subcompany)
   UPDATE scheduleparms
      SET scheduleparms.ord_subcompany = @newcompid
    WHERE scheduleparms.ord_subcompany = @oldcompid
drop index scheduleparms.company

/* BEGIN PTS 69039 SGB 04/25/2013
create index company on scheduleparms (ord_company)
*/
create index company on scheduleviews (ord_company)-- PTS 69039 SGB change scheduleparms to scheduleviews 04/25/2013
   UPDATE scheduleviews
      SET scheduleviews.ord_company = @newcompid
    WHERE scheduleviews.ord_company = @oldcompid
drop index scheduleviews.company

create index company on tariffkey (trk_originpoint)
   UPDATE tariffkey
      SET tariffkey.trk_originpoint = @newcompid
    WHERE tariffkey.trk_originpoint = @oldcompid
drop index tariffkey.company

create index company on tariffkey (trk_destpoint)
   UPDATE tariffkey
      SET tariffkey.trk_destpoint = @newcompid
    WHERE tariffkey.trk_destpoint = @oldcompid
drop index tariffkey.company

create index company on tariffkey (trk_company)
   UPDATE tariffkey
      SET tariffkey.trk_company = @newcompid
    WHERE tariffkey.trk_company = @oldcompid
drop index tariffkey.company

create index company on tariffkey (trk_billto)
   UPDATE tariffkey
      SET tariffkey.trk_billto = @newcompid
    WHERE tariffkey.trk_billto = @oldcompid
drop index tariffkey.company 

create index company on tariffkey (trk_orderedby)
   UPDATE tariffkey
      SET tariffkey.trk_orderedby = @newcompid
    WHERE tariffkey.trk_orderedby = @oldcompid
drop index tariffkey.company

create index company on tariffrowcolumn (trc_matchvalue)
   UPDATE tariffrowcolumn
      SET tariffrowcolumn.trc_matchvalue = @newcompid
    WHERE tariffrowcolumn.trc_matchvalue = @oldcompid
drop index tariffrowcolumn.company


create index company on tariffrowcolumnstl (trc_matchvalue)
   UPDATE tariffrowcolumnstl
      SET tariffrowcolumnstl.trc_matchvalue = @newcompid
    WHERE tariffrowcolumnstl.trc_matchvalue = @oldcompid
drop index tariffrowcolumnstl.company

--//PTS 69039 SGB Check for existance of tables before attempting to modify
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tempordhdr]') AND type in (N'U'))
BEGIN
	create index company on tempordhdr (toh_billto)
	   UPDATE tempordhdr
		  SET tempordhdr.toh_billto = @newcompid
		WHERE tempordhdr.toh_billto = @oldcompid
	drop index tempordhdr.company
END	

--//PTS 69039 SGB Check for existance of tables before attempting to modify
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tempordhdr]') AND type in (N'U'))
BEGIN
	create index company on tempordhdr (toh_shipper)
	   UPDATE tempordhdr
		  SET tempordhdr.toh_shipper = @newcompid
		WHERE tempordhdr.toh_shipper = @oldcompid
	drop index tempordhdr.company
END

--//PTS 69039 SGB Check for existance of tables before attempting to modify
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tempordhdr]') AND type in (N'U'))
BEGIN
	create index company on tempordhdr (toh_consignee)
	   UPDATE tempordhdr
		  SET tempordhdr.toh_consignee = @newcompid
		WHERE tempordhdr.toh_consignee = @oldcompid
	drop index tempordhdr.company
END	


create index company on tractorprofile (trc_company)
   UPDATE tractorprofile
      SET tractorprofile.trc_company = @newcompid
    WHERE tractorprofile.trc_company = @oldcompid
drop index tractorprofile.company


create index company on tractorprofile (trc_avl_cmp_id)
   UPDATE tractorprofile
      SET tractorprofile.trc_avl_cmp_id = @newcompid
    WHERE tractorprofile.trc_avl_cmp_id = @oldcompid
drop index tractorprofile.company


create index company on tractorprofile (trc_pln_cmp_id)
   UPDATE tractorprofile
      SET tractorprofile.trc_pln_cmp_id = @newcompid
    WHERE tractorprofile.trc_pln_cmp_id = @oldcompid 
drop index tractorprofile.company


create index company on trailerprofile (trl_company)
   UPDATE trailerprofile
      SET trailerprofile.trl_company = @newcompid
    WHERE trailerprofile.trl_company = @oldcompid
drop index trailerprofile.company


create index company on trailerprofile (trl_avail_cmp_id)
   UPDATE trailerprofile
      SET trailerprofile.trl_avail_cmp_id = @newcompid
    WHERE trailerprofile.trl_avail_cmp_id = @oldcompid
drop index trailerprofile.company

--//PTS 69039 SGB Check for existance of tables before attempting to modify
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trimac_hierarchy]') AND type in (N'U'))
BEGIN
	create index company on trimac_hierarchy (trimac_company)
	   UPDATE trimac_hierarchy
		  SET trimac_hierarchy.trimac_company = @newcompid
		WHERE trimac_hierarchy.trimac_company = @oldcompid
	drop index trimac_hierarchy.company
END

--//PTS 69039 SGB Check for existance of tables before attempting to modify
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trip_modification_log]') AND type in (N'U'))
BEGIN
	UPDATE STATISTICS trip_modification_log
	--create index company on trip_modifications_log (cmp_id)
	create index company on trip_modification_log (cmp_id)
	   UPDATE trip_modification_log
		  SET trip_modification_log.cmp_id = @newcompid
		WHERE trip_modification_log.cmp_id = @oldcompid
	--drop index trip_modifications_log.company
	drop index trip_modification_log.company
END

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trip_modification_log]') AND type in (N'U'))
BEGIN
	UPDATE STATISTICS trip_modification_log
	--create index company on trip_modification_log (ord_subcompany)
	create index company_sub on trip_modification_log (ord_subcompany)
	   UPDATE trip_modification_log
		  SET trip_modification_log.ord_subcompany = @newcompid
		WHERE trip_modification_log.ord_subcompany = @oldcompid
	--drop index trip_modifications_log.company
	--drop index trip_modification_log.company
	drop index trip_modification_log.company_sub
	
END
--//PTS 69039 SGB Check for existance of tables before attempting to modify

/*
create index company on tstops (cmp_id)
   UPDATE tstops
      SET tstops.cmp_id = @newcompid
    WHERE tstops.cmp_id = @oldcompid
drop index tstops.company
create index company on tstops (cmp_name)
   UPDATE tstops
      SET tstops.cmp_name = @newcompname
    WHERE tstops.cmp_name = @newcompid
drop index tstops.company
*/
	
/*   Remove old company id from the company table */
     DELETE company
      WHERE company.cmp_id = @oldcompid 
/*EXEC timerins "UPDATE", "END"*/
END
RETURN

GO
GRANT EXECUTE ON  [dbo].[update_compid_sp] TO [public]
GO
