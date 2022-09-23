SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[fnc_AccCharges]
 (@ord_hdrnumber int) 
 returns varchar(1000)
as

begin

 declare @AccCharges varchar(1000)
 Declare @tblAccCharges Table (AccCharges varchar(1000), ID int)

 insert into @tblAccCharges (AccCharges, ID)
 Select ivd_description + ' $' +  Cast(ivd_charge as varchar(20)), 1 
 from invoicedetail WITH (NOLOCK)
 where ord_hdrnumber =@ord_hdrnumber
 and ivd_tariff_type = 'N'

 select  @AccCharges = MAX(STUFF(t2.ID,1,1,''))  
 FROM @tblAccCharges t1  
 CROSS apply(  
 SELECT ', ' + t2.AccCharges  
 FROM @tblAccCharges t2  
 WHERE t2.ID = t1.ID AND t2.AccCharges > ''  
 FOR XML PATH('')  
 ) AS t2 (ID)  
 GROUP BY  
 t1.id  
 
 --Calculate total as well------
 declare @total money
 
 select @total = 
 (
  select sum(ivd_charge) as total
  from invoicedetail WITH (NOLOCK)
  where ord_hdrnumber =@ord_hdrnumber
  and ivd_tariff_type = 'N' 
 )
  
 return LTRIM(RTRIM(@AccCharges)) + ' (Total: $' + Cast(@total as varchar(20)) + ')'

end
GO
GRANT EXECUTE ON  [dbo].[fnc_AccCharges] TO [public]
GO
