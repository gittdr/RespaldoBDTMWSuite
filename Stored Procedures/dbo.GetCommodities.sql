SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetCommodities] (
 @ps_type varchar(20), @pi_key int, @ps_fromwhere varchar(20))

as
/* Used for LTL rating for Settlements, this proc returns the commodity code, 
   weight and weight units needed to pass to RateWare XL for the stops (PUP or DRP or ANY)
   indicated by the argument

5/1/12 PTS 62237 DPETE created
10/25/12 PTS65583 when passed a zero key do not bother to select 
*/
IF  @pi_key = 0
  BEGIN
    SELECT cmd_code,0,'UNK'
    FROM stops  
    WHERE 0 = 1
    
    RETURN
  
  END
select @ps_fromwhere = UPPER(@ps_fromwhere)
select @ps_fromwhere = 
   case @ps_fromwhere
     when 'PUP' then @ps_fromwhere
     when 'DRP' then @ps_fromwhere
     when 'ANY' then @ps_fromwhere
     when 'P' then 'PUP'
     when 'PICKUP' then 'PUP'
     when 'D' then 'DRP'
     when 'DROP' then 'DRP'
     else 'DRP'
     end
select @ps_type = UPPER(left(@ps_type,1))
   
if @ps_type = 'O' /* get commodities on order */
  BEGIN
    select  f.cmd_code,convert(decimal(19,2),f.fgt_weight),f.fgt_weightunit
    from
    stops s
    join freightdetail f on s.stp_number = f.stp_number
    where s.ord_hdrnumber = @pi_key
    and (stp_type =  @ps_fromwhere or @ps_fromwhere = 'ANY')
    and isnull(f.cmd_code,'UNKNOWN') <> 'UNKNOWN'
  END
if @ps_type = 'L'
   BEGIN
    /* need to find all orders that might be on this leg. Tries to handle
       a cross dock situation or relay by going to the move on the leg and then
       getting commodites on the move  */
    declare @ords table (ord_hdrnumber int)
    declare @movnum int
    select @movnum = MAX(mov_number) from stops where lgh_number = @pi_key
    /* get all orders on the mov that the leg in on
       for cross doc legs  this will pick up the order on the XDL or XDU
       for non cross doc gets all orders on stops 
       
       but if you consolidated, do you want the rates for all orders on the leg???? */
       
    Insert into @ords
    select Distinct ord_hdrnumber
    from stops
    where mov_number = @movnum
    and ord_hdrnumber > 0
    
    select f.cmd_code,convert(decimal(19,2),f.fgt_weight),f.fgt_weightunit 
    from @ords ord
    join stops s on ord.ord_hdrnumber = s.ord_hdrnumber
    join freightdetail f on s.stp_number = f.stp_number
    where s.lgh_number = @pi_key
    and (stp_type =  @ps_fromwhere or @ps_fromwhere = 'ANY')
    and isnull(f.cmd_code,'UNKNOWN') <> 'UNKNOWN'
   END
if @ps_type = 'M'
   BEGIN
    select f.cmd_code,convert(decimal(19,2),f.fgt_weight),f.fgt_weightunit from
    stops s
    join freightdetail f on s.stp_number = f.stp_number
    where s.mov_number = @pi_key
    and (stp_type =  @ps_fromwhere or @ps_fromwhere = 'ANY')
    and isnull(f.cmd_code,'UNKNOWN') <> 'UNKNOWN'
   END

GO
GRANT EXECUTE ON  [dbo].[GetCommodities] TO [public]
GO
