SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


 CREATE PROC [dbo].[AddOrdersToInvoiceMaster] (@p_ordhdrnumber int,@p_invoiceby varchar(3),@p_addordelete varchar(10))   
AS  
/* 
  
  PTS43837 12/2/08 DPETE new proc to insert records into invoicemaster when invoiced by some 
      grouping such as move number 
  PTS44417 add CON  DPETE for invoice by orders delivered to same consignee on move
*/  

declare @ords table (ord_hdrnumber int)
declare @ret int,@billto varchar(8),@movnumber int,@nextord int,@consignee varchar(8)


If @p_invoiceby = 'MOV'
  BEGIN
    select @billto = ord_billto,@movnumber = mov_number
    from orderheader
    where ord_hdrnumber = @p_ordhdrnumber

    Insert into @ords
    Select ord_hdrnumber
    from orderheader
    where mov_number = @movnumber
    and ord_billto = @billto
  END
If @p_invoiceby = 'CON'
  BEGIN
    select @billto = ord_billto,@movnumber = mov_number,@consignee = ord_consignee
    from orderheader
    where ord_hdrnumber = @p_ordhdrnumber

    Insert into @ords
    Select ord_hdrnumber
    from orderheader
    where mov_number = @movnumber
    and ord_billto = @billto
    and ord_consignee = @consignee
  END

if @p_addordelete = 'ADD'
  insert into invoicemaster (ivm_invoiceby
   ,ord_hdrnumber
   ,mov_number
   ,ivm_invoiceordhdrnumber
   )
  select @p_invoiceby
   ,ords.ord_hdrnumber
   ,@movnumber
   ,@p_ordhdrnumber
  from @ords ords
else -- delete
   delete 
   from  invoicemaster 
   where ivm_invoiceordhdrnumber = @p_ordhdrnumber
 
Select @ret = @@rowcount
-- update the invoicestatus on the orderheader for the additional orders in the aggregate
select @nextord = @p_ordhdrnumber -- this is the order on the invoice for an aggregate
select @nextord = min(ord_hdrnumber) from @ords where ord_hdrnumber > @nextord
While @nextord is not null
  BEGIN
    update orderheader
    set ord_invoicestatus = case @p_addordelete when 'ADD' then 'PPD' else 'AVL' end
    where ord_hdrnumber = @nextord

    select @nextord = min(ord_hdrnumber) from @ords where ord_hdrnumber > @nextord
  END



return @ret

GO
GRANT EXECUTE ON  [dbo].[AddOrdersToInvoiceMaster] TO [public]
GO
