SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_update_charges]
	@ord_number varchar(12), @ord_charge money
as

declare @ord_hdrnumber int, @sum money

select @ord_hdrnumber = ord_hdrnumber
  from dbo.orderheader WITH(NOLOCK)
 where ord_number = @ord_number and ord_invoicestatus <> 'PPD'

if isnull(@ord_hdrnumber,0) = 0 return -1

select @sum = sum(ivd_charge)
  from dbo.invoicedetail WITH(NOLOCK)
 where ord_hdrnumber = @ord_hdrnumber

select @sum = isnull(@sum, 0.0)

/*update orderheader
   set ord_charge = @ord_charge
     , ord_accessorial_chrg = @sum
     , ord_totalcharge = @ord_charge + @sum
 where ord_hdrnumber = @ord_hdrnumber*/

--PSL 9/9/2010 update order quantity, unit, rate, and rate unit, in addition to order charge and total charge
update dbo.orderheader
   set ord_charge = @ord_charge,
     ord_accessorial_chrg = @sum,
	ord_rate = @ord_charge,
	ord_rateunit = 'FLT',
	ord_quantity = 1,
	ord_unit = 'FLT',
	ord_totalcharge = @ord_charge + @sum
 where ord_hdrnumber = @ord_hdrnumber


return 1

GO
GRANT EXECUTE ON  [dbo].[dx_update_charges] TO [public]
GO
