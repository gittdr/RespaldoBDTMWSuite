SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[getinvwgtstl_sp] (@pl_invnumber int,@pf_wgt float out, @pf_wgt_unit varchar(6) out) 
as

declare @ordHdrnumber int
select @ordhdrnumber = ord_hdrnumber from invoiceheader where ivh_hdrnumber = @pl_invnumber 

-- PTS 34010 -- BL
--   Alter the PROC to also return the Weight Units
select @pf_wgt = isnull(sum(ivd_quantity),0), 
		@pf_wgt_unit = isnull(isnull(min(ivd_unit),(select ord_totalweightunits
		from orderheader where ord_hdrnumber = @ordHdrnumber)),'LBS')
  from invoicedetail,labelfile,chargetype  
  where ivh_hdrnumber = @pl_invnumber
         and invoicedetail.cht_itemcode = chargetype.cht_itemcode 
         and chargetype.cht_basis = 'SHP'        --PTS 55038 SPN Commented, --	LOR	PTS# 56776 uncommented
	 and ivd_quantity > 0 
	 and invoicedetail.cht_itemcode <> 'DEL'   --PTS 55038 SPN Commented--	LOR	PTS# 56776 uncommented
	 and ivd_unit = labelfile.abbr 
	 and labeldefinition = 'WeightUnits'	
	 
--	LOR	PTS# 56776
If @pf_wgt = 0 
BEGIN
	select @pf_wgt = isnull(ivh_totalweight, 0)
	from  invoiceheader 
	where ivh_hdrnumber = @pl_invnumber
         
	select @pf_wgt_unit = isnull(ivd_wgtunit,'LBS')
  from invoicedetail,labelfile
  where ivh_hdrnumber = @pl_invnumber
	 and ivd_wgt > 0 
	  and invoicedetail.cht_itemcode = 'DEL'  
	 and ivd_unit = labelfile.abbr 
	 and labeldefinition = 'WeightUnits'
end

GO
GRANT EXECUTE ON  [dbo].[getinvwgtstl_sp] TO [public]
GO
