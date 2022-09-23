SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[CMDseplist_fn] 
  (@p_ordhdrnumber int )
RETURNS varchar(200)
AS
/*
 * NAME:
 * dbo.CMDseplist_fn
 *
 * TYPE:
 * function
 *
 * DESCRIPTION:
 * Create a string with a list of commodities delivered on an order

 * RETURNS:
 * varchar(200)  separated list of refeencenumbers
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_ordhdrnumber th eord_hdnrunber for the order
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 5/26/09 DPETE PT47593 DPETE  - Created function to be called from proc for mastwer bill format

 *
 **/ 
BEGIN
   DECLARE @v_cmdlist varchar(2000)
   select @v_cmdlist = ''

   select @v_cmdlist = @v_cmdlist
      + cmd_name+', '
   from stops
   join freightdetail on stops.stp_number = freightdetail.stp_number 
   join commodity on freightdetail.cmd_code = commodity.cmd_code
   where stops.ord_hdrnumber = @p_ordhdrnumber
   and stops.ord_hdrnumber > 0
   and stp_type = 'DRP'
   and freightdetail.cmd_code <> 'UNKNOWN'
   order by stp_sequence,fgt_sequence

   if len(@v_cmdlist) > 3 select @v_cmdlist = substring(rtrim(@v_cmdlist),1,len(rtrim(@v_cmdlist)) -1 )

   RETURN @v_cmdlist
END
GO
GRANT EXECUTE ON  [dbo].[CMDseplist_fn] TO [public]
GO
