SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[d_label_chargetypes_sp] (@ps_billto varchar(8))
as
/*  pts 13099 dpete 2/28/02 to support compute of total line haul in w_inv_edit add cht_rollintolh to return set
DPETE 18414 9/4/3 add taxtable values from chargetypes

--PTS 32689 JJF 4/20/06 - add support for setting_revenue_from_charge_types
*/
BEGIN
declare @li_count int,
	@ls_dochtsort varchar(60)

  if @ps_billto is null 
	select @ps_billto = ''	

  select @ls_dochtsort = gi_string1 from generalinfo where gi_name = 'ChrgTypSort'

IF @ls_dochtsort = 'Y'	
BEGIN
  SELECT 1 sort_by, 
	a.cht_itemcode,   
         min(a.tar_number) tar_number,   
         min(chargetype.cht_description) cht_description,   
         min(chargetype.cht_number) cht_number,   
         min(chargetype.cht_primary) cht_primary,   
         min(chargetype.cht_basis) cht_basis,   
         min(chargetype.cht_basisunit) cht_basisunit,   
         min(chargetype.cht_basisper) cht_basisper,   
         min(chargetype.cht_quantity) cht_quantity,   
         min(chargetype.cht_rateunit) cht_rateunit,   
         min(chargetype.cht_unit) cht_unit,   
         min(chargetype.cht_rate) cht_rate,   
         min(chargetype.cht_editflag) cht_editflag,   
         min(chargetype.cht_glnum) cht_glnum,   
         min(chargetype.cht_sign) cht_sign,   
         min(chargetype.cht_currunit) cht_currunit,   
         min(chargetype.cht_remark) cht_remark,   
         min(chargetype.cht_class) cht_class,
         min(chargetype.cht_rateprotect) cht_rateprotect ,
		min(IsNULL(chargetype.cht_rollintolh,0)) cht_rollintolh ,
	min(chargetype.cht_lh_min) cht_lh_min,
	min(chargetype.cht_lh_rev) cht_lh_rev,
	min(chargetype.cht_lh_stl) cht_lh_stl,
	min(chargetype.cht_lh_rpt) cht_lh_rpt,
	min(chargetype.cht_lh_prn) cht_lh_prn,
        min(isnull(chargetype.gp_tax, 0)) cht_gp_Tax  ,
   min(chargetype.cht_taxtable1) cht_taxtable1,
   min(chargetype.cht_taxtable2) cht_taxtable2,
   min(chargetype.cht_taxtable3) cht_taxtable3,
   min(chargetype.cht_taxtable4) cht_taxtable4,
--PTS 32689 JJF 4/20/06 - add support for setting_revenue_from_charge_types
   min(chargetype.cht_setrevfromchargetypelist) cht_setrevfromchargetypelist
--end PTS 32689 JJF 4/20/06 - add support for setting_revenue_from_charge_types

    INTO #temp	
    FROM tariffheader a,   
         tariffkey b,   
         chargetype  
   WHERE ( a.tar_number = b.tar_number ) and  
         ( a.cht_itemcode = chargetype.cht_itemcode ) and
-- RE PTS 8249 - do not return retired charge types
	 (IsNull(chargetype.cht_retired,'N') <> 'Y' ) and   	 
         ( ( b.trk_billto = @ps_billto ) and  
         ( b.trk_primary = 'L' ) )   
   GROUP BY a.cht_itemcode   

   select @li_count = @@rowcount	

  INSERT INTO #temp	
  SELECT 2,
	 chargetype.cht_itemcode,   
	 0,
         chargetype.cht_description,   
         chargetype.cht_number,   
         chargetype.cht_primary,   
         chargetype.cht_basis,   
         chargetype.cht_basisunit,   
         chargetype.cht_basisper,   
         chargetype.cht_quantity,   
         chargetype.cht_rateunit,   
         chargetype.cht_unit,   
         chargetype.cht_rate,   
         chargetype.cht_editflag,   
         chargetype.cht_glnum,   
         chargetype.cht_sign,   
         chargetype.cht_currunit,   
         chargetype.cht_remark,   
         chargetype.cht_class,
         chargetype.cht_rateprotect ,
		IsNULL(chargetype.cht_rollintolh,0) cht_rollintolh,
	chargetype.cht_lh_min,
	chargetype.cht_lh_rev,
	chargetype.cht_lh_stl,
	chargetype.cht_lh_rpt ,
	chargetype.cht_lh_prn,
        isnull (chargetype.gp_tax, 0),
   chargetype.cht_taxtable1,
   chargetype.cht_taxtable2,
   chargetype.cht_taxtable3,
   chargetype.cht_taxtable4,
--PTS 32689 JJF 4/20/06 - add support for setting_revenue_from_charge_types
   chargetype.cht_setrevfromchargetypelist
--end PTS 32689 JJF 4/20/06 - add support for setting_revenue_from_charge_types
    FROM chargetype
   WHERE chargetype.cht_itemcode Not In 
	(select #temp.cht_itemcode from #temp)  and
	IsNull(chargetype.cht_retired,'N') <> 'Y'    	 

 -- this is to set the UNKNOWN value grouped with the lineitem chargetypes
 if @li_count > 0 
    update #temp
    set sort_by = 1
    where cht_itemcode = 'UNK'

  select * from #temp

END
ELSE
BEGIN
  SELECT 2,
	 chargetype.cht_itemcode,   
	 0,
         chargetype.cht_description,   
         chargetype.cht_number,   
         chargetype.cht_primary,   
         chargetype.cht_basis,   
         chargetype.cht_basisunit,   
         chargetype.cht_basisper,   
         chargetype.cht_quantity,   
         chargetype.cht_rateunit,   
         chargetype.cht_unit,   
         chargetype.cht_rate,   
         chargetype.cht_editflag,   
         chargetype.cht_glnum,   
         chargetype.cht_sign,   
         chargetype.cht_currunit,   
         chargetype.cht_remark,   
         chargetype.cht_class,
         chargetype.cht_rateprotect	,
		IsNULL(chargetype.cht_rollintolh,0) cht_rollintolh,
	chargetype.cht_lh_min,
	chargetype.cht_lh_rev,
	chargetype.cht_lh_stl,
	chargetype.cht_lh_rpt ,
	chargetype.cht_lh_prn,
        isnull (chargetype.gp_tax, 0) ,
   chargetype.cht_taxtable1,
   chargetype.cht_taxtable2,
   chargetype.cht_taxtable3,
   chargetype.cht_taxtable4,
--PTS 32689 JJF 4/20/06 - add support for setting_revenue_from_charge_types
   chargetype.cht_setrevfromchargetypelist
--end PTS 32689 JJF 4/20/06 - add support for setting_revenue_from_charge_types
   FROM chargetype
   WHERE IsNull(chargetype.cht_retired,'N') <> 'Y'    	 


 END

END 	


GO
GRANT EXECUTE ON  [dbo].[d_label_chargetypes_sp] TO [public]
GO
