SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TMWImaging_UpdatePaperwork_LegOrDriver] (@ordnum varchar(12),@doctype varchar(6),@p_lghnumber int = 0,@p_drv varchar(8) = 'UNKNOWN')    
As

/*******************************************************************************************************************  
  Object Description:
  This procedure is used by the vendor to update paperwork records in TMW SUITE created when paperwork by leg became important. Allows setting a paperwork record for a specific leg by passing either a lgh_number or driver ID. Originally named image_SetPWReceivedY002_sp.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  08/04/2017   Jennifer Jackson	WE-209292    Created
*******************************************************************************************************************/

/**
 * 
 * NAME:
 * dbo.image_SetPWReceivedY002_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure is used by the vendor to update paperwork records in TMW SUITE
* created when paperwork by leg became important. Allows settign a paperwork record for a specific leg by passign eith a lgh_number or diriver ID
 * Vendors using this are:  Microdea, Paperwise, Pegasus, TMW
 *
 * RETURNS:
 * -1 if passed order number is  not valid
 * -2 if passed lgh_number is not valid for the order
 * -3 if the passed driver ID is not valid for the order
 * -10 doc type is not valid in TMW
 * RESULT SETS: 
 * See SELECT statement.
 *
 * PARAMETERS:
 * 001 - @ordnum varchar(12) - Takes ord_number so we must get the ord_hdrnumber int
 * 002 - @doctype varchar(20) - Passes the long version of the doctype, it is the name field in labelfile
 * 003 - @p_lghnumber int (optional) lgh_number of trip segment to which paperwork belongs If passed and nto valied get error return
 * 004 - @p_drv varchar(8) (optional) driver ID of trip segment to paperwork belongs if passed and not valid get error return
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 
 * 1/14/2008.01 - History Log:
 * 1/14/08 - PTS 40950 created froom image_SetPWReceivedY002_sp to allow for paperwork by leg or driver add optional parameters
 * 11/17/08 DPETE PTS 45171 set updatedby to 002 proc
 * PTS 74921 vjh	ignore lgh
 **/
 
Declare @Prefix varchar(1), @abbr varchar(7), @v_ordhdrnumber INT, @v_lghnumber INT, @v_movnumber INT,@v_checklevel varchar(20) -- PRB PTS33321 added abbr

/*    supports Microdea email document functionality   */
Select @prefix =  gi_string1 from generalinfo where gi_name = 'MicrodeaEmailFlagPrefix'
If @prefix is Null Select @prefix = ''
if @p_lghnumber is null select @p_lghnumber = 0
if @p_drv is null select @p_drv = 'UNKNOWN'
select @v_lghnumber = 0
select @v_checklevel = rtrim(upper(gi_string1)) from generalinfo where gi_name = 'paperworkchecklevel'

-- doctypes must be retired,not removed when nolonger in use
Select @abbr = MIN(abbr) from labelfile WHERE labeldefinition='PaperWork' AND 
   (abbr = @doctype or abbr = @prefix+@doctype)
IF (@abbr IS NULL)
BEGIN
   RETURN -10  -- scanning a doc type not in TMWS
END

Declare @ignorelgh varchar(1)	--vjh 74921
Select @ignorelgh =  upper(left(gi_string1,1)) from generalinfo where gi_name = 'PWR_002sp_ignore_lgh'
If @ignorelgh is Null Select @ignorelgh = 'N'

select @v_ordhdrnumber = MIN(ord_hdrnumber),@v_movnumber=MIN(o.mov_number)
  from orderheader o
  where o.ord_number = @OrdNum
/***** ERROR -1 invalid order number ******/
if @v_ordhdrnumber is null RETURN -1

if @p_lghnumber > 0 
   if exists (select 1 from stops s where s.ord_hdrnumber = @v_ordhdrnumber and s.lgh_number = @p_lghnumber)
      select @v_lghnumber = @p_lghnumber
   else
/***** ERROR -2 invalid leg number for order ******/
      return -2

if @v_lghnumber = 0 and @p_drv <> 'UNKNOWN'
 BEGIN
    select @v_lghnumber = lgh_number
    from assetassignment
    where mov_number in (select distinct mov_number from stops where ord_hdrnumber = @v_ordhdrnumber)
    and asgn_id = @p_drv
    and asgn_type = 'DRV'
    if @v_lghnumber is null or @v_lghnumber = 0 return -3 /***** ERROR -3 invalid dribver for order ******/
 END

/*Set values for use downstream if not passed */
if @ignorelgh='N' begin
	if @v_lghnumber is null or @v_lghnumber = 0
		SELECT  @v_lghnumber =  MIN(ISNULL(lgh_number, 0))
		FROM paperwork
		where ord_hdrnumber = @v_ordhdrnumber
	if @v_lghnumber is null or @v_lghnumber = 0
		SELECT  @v_lghnumber =  MIN(ISNULL(lgh_number, 0))
		FROM stops
		where ord_hdrnumber = @v_ordhdrnumber
end else SELECT  @v_lghnumber =0
/*   
If the paperwork record does not exists, then add a record
Otherwise if the record exists , set it to received 

*/

IF Not Exists (Select 1 From paperwork 
   Where ord_hdrnumber = @v_ordhdrnumber and Mov_Number=@v_movnumber
   and (abbr = @doctype or abbr = @prefix+@doctype)
   and lgh_number = @v_lghnumber  )

BEGIN
   If exists (select 1 from labelfile where labeldefinition = 'PaperWork' and abbr = @doctype and isnull(retired,'N') = 'N')

    INSERT INTO paperwork (abbr,pw_received,ord_hdrnumber,pw_dt,last_updatedby,last_updateddatetime,lgh_number,pw_imaged,Mov_Number)
	      VALUES( @doctype,'Y',@v_ordhdrnumber,getdate(),'TMWImaging_UpdatePaperwork_LegOrDriver',getdate(),@v_lghnumber,'Y',@v_movnumber)
	      

END
Else
BEGIN

      	UPDATE Paperwork 
	SET pw_Imaged = 'Y', 
	pw_Received = 'Y', 
	pw_dt = GETDATE(),
	last_updatedby = 'TMWImaging_UpdatePaperwork_LegOrDriver',
    last_updateddatetime = getdate()
	
    WHERE ord_hdrnumber = @v_ordhdrnumber and (Mov_number=@v_movnumber or Mov_number is null)
	AND (abbr = @doctype or abbr = @prefix + @doctype) -- @abbr 
    AND lgh_number = (case @p_lghnumber when 0 then lgh_number else @v_lghnumber end )  -- set by leg if leg passed
END

GO
GRANT EXECUTE ON  [dbo].[TMWImaging_UpdatePaperwork_LegOrDriver] TO [public]
GO
DECLARE @xp numeric (2, 1)
SELECT @xp=1.3
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'TMWImaging_UpdatePaperwork_LegOrDriver', NULL, NULL
GO
