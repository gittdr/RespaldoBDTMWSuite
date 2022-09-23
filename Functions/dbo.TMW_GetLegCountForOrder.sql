SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TMW_GetLegCountForOrder]
  (@p_ordhdrnumber int,@p_IncludeRelayLegs char(1)) 
RETURNS int
AS
/*
 * NAME:
 * dbo.TMW_GetLegCountForOrder
 *
 * TYPE:
 * function
 *
 * DESCRIPTION:
 * Returns a count of hte number of legs the order was on, if the argumetn IncludeRelayLegs = 'Y , includes count of legs with no order stops
 *
 * Arguments
 *  the ord_hdrnumber of the order
 *  flag to include relay legs in count (Y,N)
 * RETURNS:
 * int count of legs
 *
 * RESULT SETS: 
 * 
 * 
 * REVISION HISTORY:
 * 5/25/10 DPETE created for dot net
 *
 * Sample call
    declare @x int
    exec @x = TMW_GetLegCountForOrder 5282,'N'
    select @x
 */   
  
BEGIN
   DECLARE @v_count int
   
   if not exists (select 1 from orderheader where ord_hdrnumber = @p_ordhdrnumber )
      select @v_count = 0
   
   Else If @p_IncludeRelayLegs = 'Y'
          select @v_count = count(distinct lgh_number)
          from stops where mov_number in (select distinct mov_number from stops where ord_hdrnumber = @p_ordhdrnumber)
        
        Else
          select @v_count = count(distinct lgh_number)
          from stops where ord_hdrnumber = @p_ordhdrnumber
          and stp_event not in ('XDU','XDL')
 
   
   RETURN @v_count
END
GO
GRANT EXECUTE ON  [dbo].[TMW_GetLegCountForOrder] TO [public]
GO
