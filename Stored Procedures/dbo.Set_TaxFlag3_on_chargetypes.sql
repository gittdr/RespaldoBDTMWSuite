SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Set_TaxFlag3_on_chargetypes] ( @p_val char(1) )

AS

/**
 * 
 * NAME:
 * Set_TaxFlag3_on_chargetypes
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * sets the cht_taxtable3 to the value passed for all  non tax charge types.  
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: \
 * none
 *
 * PARAMETERS: 
 * @p_val set to "Y" to set flag on , "N" to set flag off, "M" to set the flag to match the tax type 1 flag .  If any other value is passed nothing will be done
 *
 * REVISION HISTORY:
 * 11/28/2006.01 ? PTS35284 - DPETE ? Created Procedure
 *
 **/
SET NOCOUNT ON



declare @v_next varchar (8)
select @p_val = upper(@p_val),@v_next = ''

If @p_val <> 'Y' and @p_val <> 'N' and @p_val <> 'M' Return


if @p_val <> 'M'
 BEGIN
   Select @v_next = min(cht_itemcode) from chargetype where cht_basis <> 'TAX' and cht_itemcode <> 'QST' 
   WHile @v_next is not null
     BEGIN
       update chargetype
       set cht_taxtable3   = @p_val
       where cht_itemcode = @v_next
       and (cht_taxtable3 is null or cht_taxtable3 <> @p_val)

       select @v_next = min(cht_itemcode) from chargetype where cht_itemcode > @v_next and cht_basis <> 'TAX' and cht_itemcode <> 'QST'
     END
 end
else 
  BEGIN
   Select @v_next = min(cht_itemcode) from chargetype where cht_basis <> 'TAX' and cht_itemcode <> 'QST' 
   WHile @v_next is not null
     BEGIN
       update chargetype
       set cht_taxtable3   = cht_taxtable1
       where cht_itemcode = @v_next
       and (cht_taxtable3 is null or cht_taxtable3 <> cht_taxtable1)

       select @v_next = min(cht_itemcode) from chargetype where cht_itemcode > @v_next and cht_basis <> 'TAX' and cht_itemcode <> 'QST'
     END
 end

GO
GRANT EXECUTE ON  [dbo].[Set_TaxFlag3_on_chargetypes] TO [public]
GO
