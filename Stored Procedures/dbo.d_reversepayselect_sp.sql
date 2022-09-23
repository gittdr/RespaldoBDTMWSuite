SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[d_reversepayselect_sp] @p_ord_hdrnumber  int
AS
Set Nocount On
 
/**
 *
 * NAME:
 * dbo.d_reversepayselect_sp
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
	June 2012	PTS 62528	Created.	
 **/

if Not ( ( select gi_string1 from generalinfo where gi_name = 'ReversePayPresentUI' ) = 'Y' ) return

if @p_ord_hdrnumber is null set @p_ord_hdrnumber = 0

Declare @DistinctAssetType TABLE (asgn_type varchar(6) null)
Insert	@DistinctAssetType(asgn_type)
Select	Distinct(asgn_type) 
		from paydetail	
		where paydetail.ord_hdrnumber = @p_ord_hdrnumber
		and @p_ord_hdrnumber > 0
		

Declare @Pay_UpdateSrc TABLE(pyd_updsrc char(1) null, pyd_uppydsrcdesc varchar(20) null)
Insert @Pay_UpdateSrc (pyd_updsrc, pyd_uppydsrcdesc) Values('', 'Automatic')
Insert @Pay_UpdateSrc (pyd_updsrc, pyd_uppydsrcdesc) Values('M', 'Manual')
Insert @Pay_UpdateSrc (pyd_updsrc, pyd_uppydsrcdesc) Values('F', 'Fuel')
Insert @Pay_UpdateSrc (pyd_updsrc, pyd_uppydsrcdesc) Values('A', 'Custom')
Insert @Pay_UpdateSrc (pyd_updsrc, pyd_uppydsrcdesc) Values('J', 'Custom')
Insert @Pay_UpdateSrc (pyd_updsrc, pyd_uppydsrcdesc) Values('C', 'Custom')
Insert @Pay_UpdateSrc (pyd_updsrc, pyd_uppydsrcdesc) Values('I', 'Custom')

If ( select count(asgn_type) from @DistinctAssetType where asgn_type = 'TPR' ) > 0 
BEGIN
		select 0 as 'cc_select',
		pd.ord_hdrnumber, 
		pd.pyd_updsrc, 
		pd.asgn_id, 
		pd.asgn_type, 
		pd.pyt_itemcode, 
		pd.pyd_offsetpay_number,
		paytype.pyt_paying_to, 
		paytype.pyt_offset_for, 
		pd.cht_itemcode,
		pd.pyd_ivh_hdrnumber ,
		pd.asgn_number, 
		pd.lgh_number, 
		pd.pyd_credit_pay_flag, 
		pd.pyd_description,
		pd.pyr_ratecode,
		pd.pyd_quantity,
		pd.pyd_rateunit,
		pd.pyd_unit,
		pd.pyd_rate,
		pd.pyd_amount,
		pd.pyd_pretax,
		pd.pyd_minus,
		pd.pyd_glnum,
		pd.pyd_currency, 	 
		pd.pyd_number, 
		pd.pyd_sequence,
		pyd_adj_flag,
		pyh_payperiod,	
		psd_id,
		pd.mov_number,
		IsNull(pdsrc.pyd_uppydsrcdesc , 'Automatic') as 'cc_pyd_updsrc',
		(select LTrim(RTrim(ord_number)) from orderheader where ord_hdrnumber = @p_ord_hdrnumber ) 'ord_number',
		(select min(ivh_applyto) from invoiceheader where  ord_hdrnumber = @p_ord_hdrnumber ) 'ivh_invoicenumber',		
		(select min(pyt_basisunit) from paytype where  pd.pyt_itemcode = paytype.pyt_itemcode ) 'pyt_basisunit',	
		(select min(pyt_basis) from paytype where  pd.pyt_itemcode = paytype.pyt_itemcode ) 'pyt_basis'	
		from paydetail pd
		left join assetassignment 
			on ( pd.asgn_number = assetassignment.asgn_number AND 
					pd.asgn_id = assetassignment.asgn_id AND 
					pd.asgn_type = assetassignment.asgn_type AND 
					pd.lgh_number = assetassignment.lgh_number AND pd.lgh_number > 0 AND pd.asgn_type <> 'TPR' )
		left join thirdpartyassignment  
			on ( 	pd.asgn_id = thirdpartyassignment.tpr_id AND 			
			pd.lgh_number = thirdpartyassignment.lgh_number AND pd.lgh_number > 0 AND pd.asgn_type = 'TPR' )				
		left join paytype		
			on ( pd.pyt_itemcode = paytype.pyt_itemcode AND
					pd.asgn_type = paytype.pyt_paying_to AND  pd.pyd_offsetpay_number is not null )
		left join @Pay_UpdateSrc as pdsrc on pd.pyd_updsrc = pdsrc.pyd_updsrc				
		where pd.ord_hdrnumber = @p_ord_hdrnumber
		and pd.ord_hdrnumber > 0
		order by pd.ord_hdrnumber, pd.asgn_id, pd.asgn_type 
END		
ELSE
BEGIN

	select 0 as 'cc_select',
		pd.ord_hdrnumber, 
		pd.pyd_updsrc, 
		pd.asgn_id, 
		pd.asgn_type, 
		pd.pyt_itemcode, 
		pd.pyd_offsetpay_number,
		paytype.pyt_paying_to, 
		paytype.pyt_offset_for, 
		pd.cht_itemcode,
		pd.pyd_ivh_hdrnumber ,
		pd.asgn_number, 
		pd.lgh_number, 
		pd.pyd_credit_pay_flag, 
		pd.pyd_description,
		pd.pyr_ratecode,
		pd.pyd_quantity,
		pd.pyd_rateunit,
		pd.pyd_unit,
		pd.pyd_rate,
		pd.pyd_amount,
		pd.pyd_pretax,
		pd.pyd_minus,
		pd.pyd_glnum,
		pd.pyd_currency, 	 
		pd.pyd_number, 
		pd.pyd_sequence,
		pyd_adj_flag,
		pyh_payperiod,
		psd_id,
		pd.mov_number,
		IsNull(pdsrc.pyd_uppydsrcdesc , 'Automatic') as 'cc_pyd_updsrc',
		(select LTrim(RTrim(ord_number)) from orderheader where ord_hdrnumber = @p_ord_hdrnumber ) 'ord_number',
		(select min(ivh_applyto) from invoiceheader where  ord_hdrnumber = @p_ord_hdrnumber ) 'ivh_invoicenumber',		
		(select min(pyt_basisunit) from paytype where  pd.pyt_itemcode = paytype.pyt_itemcode ) 'pyt_basisunit',	
		(select min(pyt_basis) from paytype where  pd.pyt_itemcode = paytype.pyt_itemcode ) 'pyt_basis'	
		from paydetail pd
		left join assetassignment 
			on ( pd.asgn_number = assetassignment.asgn_number AND 
					pd.asgn_id = assetassignment.asgn_id AND 
					pd.asgn_type = assetassignment.asgn_type AND 
					pd.lgh_number = assetassignment.lgh_number AND pd.lgh_number > 0 AND pd.asgn_type <> 'TPR' )
		left join paytype		
			on ( pd.pyt_itemcode = paytype.pyt_itemcode AND
					pd.asgn_type = paytype.pyt_paying_to AND  pd.pyd_offsetpay_number is not null )
		left join @Pay_UpdateSrc as pdsrc on pd.pyd_updsrc = pdsrc.pyd_updsrc				
			where pd.ord_hdrnumber = @p_ord_hdrnumber
		and pd.ord_hdrnumber > 0
		order by pd.ord_hdrnumber, pd.asgn_id, pd.asgn_type 

END


GO
GRANT EXECUTE ON  [dbo].[d_reversepayselect_sp] TO [public]
GO
