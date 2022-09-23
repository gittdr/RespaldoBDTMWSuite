SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[IntnlBillingRuleForOrder] @p_ordhdrnumber int
As  
/*   
Created 8/19/10 SR 51802 DPETE Company eliminates stops ar mile son invoice when trip goes outside country
 
*/ 
Declare @DomesticCountry varchar(50),@billto varchar(8)

select @DomesticCountry = rtrim(gi_string2) from generalinfo where gi_name = 'ApplyIntnlBillingRule'

If @DomesticCountry is null or len(@DomesticCountry) < 2 select @DomesticCountry = 'USA'

if not exists (select 1 from invoiceheader where ord_hdrnumber = @p_ordhdrnumber)
   select @billto = ord_billto from orderheader where ord_hdrnumber = @p_ordhdrnumber
else
   select @billto = ivh_billto from invoiceheader where ivh_hdrnumber =
    (select min(ivh_hdrnumber) from invoiceheader where ord_hdrnumber = @p_ordhdrnumber)

Select 
ibr_country,
ibr_direction,
ibr_DistanceRule,
ibr_showstopsrule
From IntnlBillingRule
Where cmp_id = @billto



GO
GRANT EXECUTE ON  [dbo].[IntnlBillingRuleForOrder] TO [public]
GO
