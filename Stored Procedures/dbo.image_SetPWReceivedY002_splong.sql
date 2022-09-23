SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[image_SetPWReceivedY002_splong] (@ordnum varchar(12),@doctype varchar(20),@p_lghnumber int = 0,@p_drv varchar(8) = 'UNKNOWN')    
As
/**
 * 
 * NAME:
 * dbo.image_SetPWReceivedY002_splong
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
 * created from image_setpwreceivedy002_sp for PTS65285 DPETE
 * PTS 72634 nloke - add GI setting PWR_002splong_EUpdate to update both original and 'E' paperwork
 * PTS 74921 vjh	ignore lgh
 * PTS 74923 vjh	Support determined abbr needs to compare to abbr, not lon name
 * 10/12/2015 - PTS 95600 - 62841 vjh log calls
 **/

Declare	@ImagingPaperworkTrack char(1)	--vjh 62841
SELECT @ImagingPaperworkTrack = left(upper(gi_string1),1) FROM generalinfo WHERE upper(gi_name) = 'ImagingPaperworkTrack'	--vjh 62841
if @ImagingPaperworkTrack is null SELECT @ImagingPaperworkTrack = 'N'
if @ImagingPaperworkTrack = '' SELECT @ImagingPaperworkTrack = 'N'

if @ImagingPaperworkTrack = 'Y' begin
	insert ImagePaperworkLog (
		ipl_Date,
		ipl_callingproc,
		ipl_ordnum,
		ipl_doctype,
		ipl_lghnumber,
		ipl_driver,
		ipl_carrier,
		ipl_carrierinvoice,
		ipl_invoiceamt,
		ipl_HldPay )
	values (
		getdate(),
		'image_SetPWReceivedY002_splong',
		@ordnum,
		@doctype,
		null,
		null,
		null,
		null,
		null,
		null)		
end
 
Declare @Prefix varchar(1), @abbr varchar(7), @v_ordhdrnumber INT,  @v_movnumber INT,@v_lghnumber INT,@v_checklevel varchar(20) -- PRB PTS33321 added abbr
Declare @eupdate varchar(1)		--PTS 72634 nloke

Declare @ignorelgh varchar(1)	--vjh 74921
Select @ignorelgh =  upper(left(gi_string1,1)) from generalinfo where gi_name = 'PWR_002sp_ignore_lgh'
If @ignorelgh is Null Select @ignorelgh = 'N'

/*    supports Microdea email document functionality   */
Select @prefix =  gi_string1 from generalinfo where gi_name = 'MicrodeaEmailFlagPrefix'
If @prefix is Null Select @prefix = ''
if @p_lghnumber is null select @p_lghnumber = 0
if @p_drv is null select @p_drv = 'UNKNOWN'
select @v_lghnumber = 0
select @v_checklevel = rtrim(upper(gi_string1)) from generalinfo where gi_name = 'paperworkchecklevel'

--PTS 72634 nloke
select @eupdate = upper(gi_string1) from generalinfo where gi_name = 'PWR_002splong_EUpdate'
If @eupdate is NULL Select @eupdate = ''
--end 72634

-- doctypes must be retired,not removed when nolonger in use
Select @abbr = MIN(abbr) from labelfile WHERE labeldefinition='PaperWork' AND 
   ( name = @prefix+@doctype
     or name = @doctype)
IF (@abbr IS NULL)
BEGIN
   RETURN -10  -- scanning a doc type not in TMWS
END


select @v_ordhdrnumber = MIN(ord_hdrnumber)
,@v_movnumber=MIN(o.mov_number)
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
--PTS 72634 nloke
IF @eupdate = 'Y'
BEGIN
	IF NOT EXISTS (SELECT 1 FROM paperwork WHERE ord_hdrnumber = @v_ordhdrnumber
     and abbr in (select abbr from labelfile where labeldefinition = 'PaperWork' and (name = @doctype
                 or name = @prefix+@doctype)))
	BEGIN
        -- Here we are doing the insert like the order table trigger, creating all the proper entries.
		INSERT INTO paperwork (abbr,pw_received,ord_hdrnumber,pw_dt,last_updatedby,last_updateddatetime,lgh_number,pw_imaged,Mov_Number)
	      SELECT labelfile.abbr,'N',@v_ordhdrnumber,getdate(),'ReceivedY001_splong',getdate(),@v_lghnumber,'N',@v_movnumber
	      FROM labelfile
	      WHERE labelfile.labeldefinition = 'PaperWork'
	      and labelfile.abbr <> 'TEMP'
	      and IsNull(labelfile.retired,'N') <> 'Y'
              --This will cover us in case we have some of the entries in paperwork already.
 	      AND labelfile.abbr NOT IN (SELECT abbr
					 FROM paperwork
					 WHERE ord_hdrnumber = @v_ordhdrnumber and Mov_number=@v_movnumber
					 and lgh_number = (case @p_lghnumber when 0 then lgh_number else @v_lghnumber end ))
				
		--Now we can feel free to update the record that imaging wanted to update.
      	UPDATE Paperwork 
		SET pw_Imaged = 'Y', 
		pw_Received = 'Y', 
		pw_dt = GETDATE(),
		last_updatedby = 'ReceivedY002_splong',
		last_updateddatetime = getdate()
    		WHERE ord_hdrnumber = @v_ordhdrnumber and (Mov_number=@v_movnumber or Mov_number is null)
		AND abbr in (select abbr from labelfile where labeldefinition = 'PaperWork' and (name = @doctype
					 or name = @prefix+@doctype))
		and lgh_number = (case @p_lghnumber when 0 then lgh_number else @v_lghnumber end )
	END
	ELSE
	-- Here we handle one that we have already in paperwork, just update it.  If the above if statement
	-- was called the first time, we will come here on the next call.
	BEGIN
		UPDATE Paperwork 
		SET pw_Imaged = 'Y', 
		pw_Received = 'Y', 
		pw_dt = GETDATE(),
		last_updatedby = 'ReceivedY001_splong',
		last_updateddatetime = getdate() 
		WHERE ord_hdrnumber = @v_ordhdrnumber and (Mov_number=@v_movnumber or Mov_number is null)
		and abbr in (select abbr from labelfile where labeldefinition = 'PaperWork' and (name = @doctype
			or name = @prefix+@doctype))   
		and lgh_number = (case @p_lghnumber when 0 then lgh_number else @v_lghnumber end )
	END
END
ELSE
--end 72634
BEGIN
	IF Not Exists (Select 1 From paperwork 
	   Where ord_hdrnumber = @v_ordhdrnumber
	   and (abbr = @abbr)
	   and lgh_number = @v_lghnumber  )

	BEGIN
--	vjh PTS 74923 check in code determined in support
--		If exists (select 1 from labelfile where labeldefinition = 'PaperWork' and abbr = @doctype and isnull(retired,'N') = 'N')
		If exists (select 1 from labelfile where labeldefinition = 'PaperWork' and abbr = @abbr and isnull(retired,'N') = 'N')
		INSERT INTO paperwork (abbr,pw_received,ord_hdrnumber,pw_dt,last_updatedby,last_updateddatetime,lgh_number,pw_imaged,Mov_Number)
			  VALUES( @abbr,'Y',@v_ordhdrnumber,getdate(),'PWReceivedY002_splong',getdate(),@v_lghnumber,'Y',@v_movnumber)
		      

	END
	Else
	BEGIN

      		UPDATE Paperwork 
		SET pw_Imaged = 'Y', 
		pw_Received = 'Y', 
		pw_dt = GETDATE(),
		last_updatedby = 'PWReceivedY002_splong',
		last_updateddatetime = getdate()
		WHERE ord_hdrnumber = @v_ordhdrnumber and (Mov_number=@v_movnumber or Mov_number is null)
		AND (abbr = @abbr )
		AND lgh_number = (case @p_lghnumber when 0 then lgh_number else @v_lghnumber end )  -- set by leg if leg passed
	END
END

GO
GRANT EXECUTE ON  [dbo].[image_SetPWReceivedY002_splong] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.32
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'image_SetPWReceivedY002_splong', NULL, NULL
GO
