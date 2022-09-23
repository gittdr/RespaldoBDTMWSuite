SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[completion_freightdetail_sp]		@p_ord_hdrnumber int

AS

/**
 * 
 * NAME:
 * completion_freightdetail_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * 6/28/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 * 02/19/2009 pmill 44766/45627 rather than deleting PUP freightdetail records, just filter them out.  Try to avoid losing records
 *					when the data is copied back to the main tables.  The freightdetail record just gets automatically re-created again anyway.
 *
 * DPETE SR 48803 now customer wants to maintain pickup freight information. Retrieve all freight from pickup and delivery
 *    add stp_type to return set to filter on the screen if necessary
 * PTS 53628 SGB Add Commodity Makeup Flag and Makeup Percentage to be updated in the datawindow 
 * 03/31/2011 PTS 56334 SPN now on we are using referencenumber table instead of completion_referencenumber
 **/

DECLARE	@v_bol			varchar(30),
	@v_max_fgt_number 	int,
	@v_cur_fgt_number 	int,
	@v_refnum_count		int,
	@Commodity_Makeup varchar(1),
	@Percentage decimal(8,4)	-- PTS 53268 SGB
	
declare @bols table (fgt_number int, bolref varchar(30) null)

/* table pf BL# ref numbers attached to freight records */
insert into @bols(fgt_number , bolref)
select ref_tablekey,max(ref_number)
--BEGIN PTS 56334 SPN
--from completion_referencenumber where
from referencenumber where
--END PTS 56334 SPN
ord_hdrnumber = @p_ord_hdrnumber
and ref_table = 'freightdetail'
and ref_type = 'BL#'
group by ref_tablekey

Select @Commodity_Makeup = 'N',  @Percentage = 0-- PTS 53268 SGB

--BEGIN PTS 56334 SPN
--SELECT	@v_refnum_count = COUNT(*) 
--FROM	completion_referencenumber 
--WHERE	completion_referencenumber.ref_table = 'freightdetail' AND 
--	completion_referencenumber.ord_hdrnumber = @p_ord_hdrnumber 
SELECT	@v_refnum_count = COUNT(*) 
FROM	referencenumber 
WHERE	ref_table = 'freightdetail' AND 
	ord_hdrnumber = @p_ord_hdrnumber 
--BEGIN PTS 56334 SPN

SELECT 	completion_freightdetail.fgt_number, 
	completion_freightdetail.cmd_code, 
	completion_freightdetail.fgt_weight, 
	completion_freightdetail.fgt_weightunit,
	completion_freightdetail.fgt_description, 
	completion_freightdetail.stp_number, 
	completion_freightdetail.fgt_count, 
	completion_freightdetail.fgt_countunit, 
	completion_freightdetail.fgt_volume, 
	completion_freightdetail.fgt_volumeunit, 
	completion_freightdetail.fgt_lowtemp, 
	completion_freightdetail.fgt_hitemp, 
	completion_freightdetail.fgt_sequence, 
	completion_freightdetail.fgt_length, 
	completion_freightdetail.fgt_lengthunit, 
	completion_freightdetail.fgt_height, 
	completion_freightdetail.fgt_heightunit, 
	completion_freightdetail.fgt_width, 
	completion_freightdetail.fgt_widthunit,  
	completion_freightdetail.fgt_reftype, 
	completion_freightdetail.fgt_refnum, 
	completion_freightdetail.fgt_quantity, 
	completion_freightdetail.fgt_rate, 
	completion_freightdetail.fgt_charge, 
	completion_freightdetail.fgt_rateunit, 
	completion_freightdetail.cht_itemcode, 
	completion_freightdetail.cht_basisunit, 
	completion_freightdetail.fgt_unit, 
	completion_freightdetail.skip_trigger, 
	completion_freightdetail.tare_weight, 
	completion_freightdetail.tare_weightunit, 
	completion_freightdetail.fgt_pallets_in, 
	completion_freightdetail.fgt_pallets_out, 
	completion_freightdetail.fgt_pallets_on_trailer, 
	completion_freightdetail.fgt_carryins1,
	completion_freightdetail.fgt_carryins2, 
	completion_freightdetail.fgt_stackable, 
	completion_freightdetail.fgt_ratingquantity, 
	completion_freightdetail.fgt_ratingunit, 
	completion_freightdetail.fgt_quantity_type, 
	completion_freightdetail.fgt_ordered_count, 
	completion_freightdetail.fgt_ordered_weight, 
	completion_freightdetail.tar_number, 
	completion_freightdetail.tar_tariffnumber, 
	completion_freightdetail.tar_tariffitem, 
	completion_freightdetail.fgt_charge_type, 
	completion_freightdetail.fgt_rate_type, 
	completion_freightdetail.fgt_loadingmeters, 
	completion_freightdetail.fgt_loadingmetersunit, 
	completion_freightdetail.fgt_additionl_description, 
	completion_freightdetail.fgt_specific_flashpoint, 
	completion_freightdetail.fgt_specific_flashpoint_unit, 
	completion_freightdetail.fgt_ordered_volume, 
	completion_freightdetail.fgt_ordered_loadingmeters, 
	completion_freightdetail.fgt_pallet_type, 
	completion_freightdetail.cpr_density, 
	completion_freightdetail.scm_subcode, 
	completion_freightdetail.fgt_terms, 
	completion_freightdetail.fgt_consignee, 
	completion_freightdetail.fgt_shipper, 
	completion_freightdetail.fgt_leg_origin, 
	completion_freightdetail.fgt_leg_dest, 
	completion_freightdetail.fgt_count2, 
	completion_freightdetail.fgt_count2unit, 
	completion_freightdetail.fgt_bolid, 
	completion_freightdetail.fgt_bol_status, 
	completion_freightdetail.fgt_osdreason, 
	completion_freightdetail.fgt_osdquantity, 
	completion_freightdetail.fgt_osdunit, 
	completion_freightdetail.fgt_osdcomment, 
	completion_freightdetail.fgt_packageunit,
	completion_freightdetail.fgt_completion_grossamt,
	completion_freightdetail.fgt_completion_netamt,
 	completion_freightdetail.fgt_completion_grossnet_flag,
	completion_freightdetail.fgt_completion_billedamt,
	completion_freightdetail.fgt_completion_supplier_id,
	completion_freightdetail.fgt_completion_supplier_name,
	completion_freightdetail.fgt_completion_supplier_ctyst,
	isnull(bols.bolref,'')  fgt_completion_bol,
	completion_freightdetail.fgt_completion_subcmd_list,
	isnull(completion_freightdetail.fgt_parentcmd_number,0),
	completion_freightdetail.fgt_completion_sequence,
	completion_freightdetail.fgt_completion_accountof,
	@v_refnum_count refnum_count,
    completion_stops.stp_type,
    completion_stops.cmp_id,
   @Commodity_Makeup,		--PTS 53268 SGB 
   Commodity.cmd_class,		--PTS 53268 SGB
   @Percentage,								--PTS 53268 SGB
   Commodity.cmd_class2		--PTS 53268 SGB
FROM 	
	completion_stops
    join completion_freightdetail on  completion_stops.stp_number = completion_freightdetail.stp_number
    left outer join @bols bols on completion_freightdetail.fgt_number = bols.fgt_number
		left outer join commodity on  commodity.cmd_code = completion_freightdetail.cmd_code --PTS 53268 SGB
WHERE	completion_stops.ord_hdrnumber = @p_ord_hdrnumber
AND completion_stops.stp_type in ( 'PUP','DRP')
--  AND	(completion_stops.stp_type <> 'PUP' OR (completion_stops.stp_type = 'PUP' AND isnull(completion_freightdetail.fgt_parentcmd_number, 0) <> 0 ) )  --44766/45627 pmill
/*
SELECT	@v_max_fgt_number = max(fgt_number)
FROM 	#temp

SELECT	@v_cur_fgt_number = min(fgt_number)
FROM	#temp

WHILE 	@v_cur_fgt_number <= @v_max_fgt_number
 BEGIN
	UPDATE	#temp
	SET	fgt_completion_bol = (SELECT 	max(ref_number)
				      FROM	completion_referencenumber
				      WHERE	ref_table = 'freightdetail'
				        AND	ref_tablekey = @v_cur_fgt_number
					AND	ord_hdrnumber = @p_ord_hdrnumber
					AND	ref_type = 'BL#')
	WHERE	fgt_number = @v_cur_fgt_number

	SELECT	@v_cur_fgt_number = min(fgt_number)
	FROM	#temp
	WHERE	fgt_number > @v_cur_fgt_number
 END

SELECT	*
FROM	#TEMP
*/

GO
GRANT EXECUTE ON  [dbo].[completion_freightdetail_sp] TO [public]
GO
