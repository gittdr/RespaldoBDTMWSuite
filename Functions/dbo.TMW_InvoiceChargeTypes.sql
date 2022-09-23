SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TMW_InvoiceChargeTypes]
  (@p_ivhhdrnumber int )
RETURNS varchar(200)
AS
/*
 * NAME:
 * dbo.TMW_InvoiceChargeTypes
 *
 * TYPE:
 * function
 *
 * DESCRIPTION:
 * Create a ^ separated string with a list of chargetypes on an invoice

 * RETURNS:
 * varchar(200)  separated list of cht_itemcodes
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_ivhhdrnumber the ivh_hdnrunber for the invoice
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 5/10/10 DPETE created for dot net

 *
 * Sample call
    declare @x varchar(500)
    exec @x = InvoiceChargeTypes_fn 2829
    select @x,len(@x),charindex('^DEL^',@x)
 */ 
BEGIN
   DECLARE @v_chtlist varchar(2000)
   select @v_chtlist = '^'

   select @v_chtlist = @v_chtlist
      + rtrim(cht_itemcode)+ '^'
   from invoicedetail
   where ivh_hdrnumber = @p_ivhhdrnumber

  
   RETURN @v_chtlist
END
GO
GRANT EXECUTE ON  [dbo].[TMW_InvoiceChargeTypes] TO [public]
GO
