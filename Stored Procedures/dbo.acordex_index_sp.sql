SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[acordex_index_sp] @p_order varchar(15),@p_doctype varchar(20),@p_scandate datetime,@p_uploaddate datetime
as
/**  
 *   
 * NAME:  
 * dbo.acordex_index_sp     
 *  
 * TYPE:  
 * [StoredProcedure]  
 *  
 * DESCRIPTION:  
 * For Acordex imaging interface. used to create web service
 * to validate trip number entered on scanning docs
 *  
 * RETURNS:  
 * -1 if @p_order is not a valid order number
 *  0  no match on doc type to TMW labelfile
 * 1  if success 
 *  
 * RESULT SETS:   
 * Orderisvalid Char(1)  Y if valid N if not valid
 *  
 * PARAMETERS:  
 * 001 - @p_order varchar(15) order number
 * 002 - @p_doctype varchar(20)  scanned document type
 * 003 - @p_scandate datetime   date of scan
 * 004 - @p_uploaddate datetime  date uploaded to Acordex
 *  
 * REFERENCES:   
  
 *   
 * REVISION HISTORY:  
 * 08/02/2006.01 ? PTS??? - D Petersen ? Created for Acordex imaging interface for Custome Companies
 *  
 **/  
/*

 Return 1 = Success
        -1 = invalid trip
        0 = no match on doc type

*/ 

declare @v_ordhdr int, @v_abbr varchar(6),@v_lgh int

Select @v_ordhdr =ord_hdrnumber 
from orderheader where ord_number = @p_order

/* invalid order number */

If @v_ordhdr is null 
 BEGIN
  select 'N'
  return -1
 END

select @v_lgh=lgh_number 
from  stops 
where  stops.ord_hdrnumber = @v_ordhdr
   and stp_sequence = (Select min(stp_sequence) from stops s2 where s2.ord_hdrnumber = @v_ordhdr)

/* try to match on doc type = abbr */
update paperwork
set pw_received = 'Y'
,pw_dt = @p_scandate
,last_updatedby = 'ACORDEX'
,last_updateddatetime = @p_uploaddate
,pw_imaged = 'Y'
where ord_hdrnumber = @v_ordhdr
and abbr = @p_doctype

If @@rowcount > 0 
 BEGIN
   select 'Y'
   return 1
 END

/* try to match on doctype = name */
update paperwork
set pw_received = 'Y'
,pw_dt = @p_scandate
,last_updatedby = 'ACORDEX'
,last_updateddatetime = @p_uploaddate
where ord_hdrnumber = @v_ordhdr
and abbr = (Select abbr from labelfile where labeldefinition = 'PaperWork' and name = @p_doctype)

if @@rowcount > 0 
 BEGIN
   select 'Y'
   return 1
 END
/* if no match, is doctype valid? */
select @v_abbr = min(abbr) from labelfile where labeldefinition = 'PaperWork' and (abbr = @p_doctype
or name = @p_doctype)


If @v_abbr is null 
 BEGIN
   select 'Y'  -- Acordex is not interested if doc tyupe is not valid
   return 0
 END
/* if valid doc type (and not in paperwork) add paperwork record */
insert into paperwork(abbr,pw_received,ord_hdrnumber,pw_dt,last_updatedby,last_updateddatetime,lgh_number,pw_imaged)
values(@v_abbr,'Y',@v_ordhdr,@p_scandate,'ACORDEX',@p_uploaddate,0,'Y')

select 'Y' 
return 0
GO
GRANT EXECUTE ON  [dbo].[acordex_index_sp] TO [public]
GO
