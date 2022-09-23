SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_cost_profit_margin_sp] @ord_hdrnumber int AS

SET NOCOUNT ON

declare @results  table(ident						int IDENTITY(1,1),
						lgh_number					int					NOT NULL,
						ord_hdrnumber				int					NOT NULL,
						linehaul_charges			money				NULL,
						acc_charges					money				NULL,
						total_rev					money				NULL,
						lh_cost_alloc				money				NULL,
						acc_cost_alloc				money				NULL,
						total_cost_alloc			money				NULL,
                        rev_alloc					money				NULL,
						seg_miles					float				NULL,
						total_miles					float				NULL,
						margin_percentage			money				NULL,
						margin						money				NULL,
						resource					varchar(13)			NULL
						)
declare	@ll_ivh_hdrnumber	int


insert into @results(lgh_number, ord_hdrnumber)
select distinct lgh_number, @ord_hdrnumber
  from stops 
 where ord_hdrnumber = @ord_hdrnumber

--see if there is an invoice created if so get the invoiced charges from there
select @ll_ivh_hdrnumber = max(ivh_hdrnumber) 
  from invoiceheader 
 where ord_hdrnumber = @ord_hdrnumber
   and ivh_definition in ('LH','RBIL')

if @ll_ivh_hdrnumber is null or @ll_ivh_hdrnumber < 1  --no invoiceheader take from the the order
begin
	update @results
       set linehaul_charges = (select ord_charge
                                 from orderheader
                                where ord_hdrnumber = @ord_hdrnumber)
	update @results
       set acc_charges = (select ord_accessorial_chrg
                            from orderheader
                           where ord_hdrnumber = @ord_hdrnumber)
end
else  --invoiceheader exists get the charges from the invoicedetails
begin
	update @results
	   set linehaul_charges = (select sum(ivd_charge)
								 from invoicedetail
								 join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode and cht_basis = 'SHP'
								where ivh_hdrnumber = @ll_ivh_hdrnumber)

	update @results
	   set acc_charges = (select sum(ivd_charge)
							from invoicedetail
							join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode and cht_basis <> 'SHP'
						   where ord_hdrnumber = @ord_hdrnumber)
end

update @results
   set resource = (select min(asgn_id)
					 from paydetail
					 join paytype on paydetail.pyt_itemcode = paytype.pyt_itemcode and paytype.pyt_basis = 'LGH'
					where r.lgh_number = paydetail.lgh_number)
  from @results r

update @results
   set total_rev = isnull(linehaul_charges,0.00) + isnull(acc_charges,0.00)

update @results
   set lh_cost_alloc = isnull(lca_linehaul,0.00),
       acc_cost_alloc = isnull(lca_accessorial,0.00),
       total_cost_alloc = isnull(lca_linehaul,0.00) + isnull(lca_accessorial,0.00)
  from legheader_cost_allocation lca, @results r
 where r.lgh_number = lca.lgh_number
   and lca.ord_hdrnumber = @ord_hdrnumber

update @results
   set seg_miles = lgh_miles
  from legheader, @results r
  where r.lgh_number = legheader.lgh_number

update @results
   set total_miles = (select sum(seg_miles) from @results)

update @results 
   set total_miles = 1
 where total_miles = 0 or total_miles is null

update @results
   set rev_alloc = (seg_miles/total_miles)*total_rev

update @results
   set margin = rev_alloc - total_cost_alloc

update @results 
   set rev_alloc = 1
 where rev_alloc = 0 or rev_alloc is null

update @results
   set margin_percentage =  (margin / rev_alloc)

select  ord_hdrnumber,
		lgh_number,	
		resource,
		linehaul_charges,
		acc_charges,
		total_rev,
		lh_cost_alloc,
		acc_cost_alloc,
		total_cost_alloc,
		seg_miles,
		rev_alloc,
		margin_percentage,
		margin
from @results

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[d_cost_profit_margin_sp] TO [public]
GO
