SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Set_TaxFlag3_on_commodities] (@p_code varchar(8), @p_val char(1) )

AS

/**
 * 
 * NAME:
 * Set_TaxFlag3_on_commodities
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: \
 * none
 *
 * PARAMETERS: @p_code	varchar(8) 'UNKNOWN' to set tax code on for all commodities; pass a code and flag is set for that code only 
 * @p_val set to "Y" to set flag on , "N" to set flag off.  If any other value is passed nothing will be done
 *
 * REVISION HISTORY:
 * 11/28/2006.01 ? PTS35284 - DPETE ? Created Procedure
 *
 **/
SET NOCOUNT ON



declare @v_next varchar (8)
select @p_val = upper(@p_val),@v_next = ''

If @p_val <> 'Y' and @p_val <> 'N' Return


If @p_code <> 'UNKNOWN' and @p_code <> ''
   update commodity
   set  cmd_taxtable3   = @p_val
   where cmd_code = @p_code and (cmd_taxtable3 is null or cmd_taxtable3 <> @p_val)
else
 BEGIN
   Select @v_next = min(cmd_code) from commodity 
   WHile @v_next is not null
     BEGIN
       update commodity
       set cmd_taxtable3   = @p_val
       where cmd_code = @v_next
       and (cmd_taxtable3 is null or cmd_taxtable3 <> @p_val)

       select @v_next = min(cmd_code) from commodity where cmd_code > @v_next
     END
 END



GO
GRANT EXECUTE ON  [dbo].[Set_TaxFlag3_on_commodities] TO [public]
GO
