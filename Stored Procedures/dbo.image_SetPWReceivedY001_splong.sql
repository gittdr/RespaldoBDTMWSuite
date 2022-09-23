SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[image_SetPWReceivedY001_splong] (@ordnum varchar(12),@doctype varchar(20))    
As 

/**
 * 
 * NAME:
 * dbo.image_SetPWReceivedY001_splong
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure is used by the vendor to update paperwork records in TMW SUITE
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * See SELECT statement.
 *
 * PARAMETERS:
 * 001 - @ordnum varchar(12) - Takes ord_number so we must get the ord_hdrnumber int
 * 002 - @doctype varchar(20) - Passes the long version of the doctype, it is the name field in labelfile
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 
 * 7/17/2006.01 - History Log:
 * DPETE 27668 an e prefix to a paperwork abbreviation or description (there is a choice as to which is
 *    used for the paperwork identification tells microdea to email the document.  Microdea
 *    may scan a POD or a Proof of Deleivery, but if we assign a required document of EPOD or eProof of Delevery
 *    then they will email it.  COming back and checking off the requirement we mus update a requirement for
 *    the doc ID in microdea or the dci ID with an e prefix.
 * DPETE PTS28369 do not set received status if already set (to preserve updated by to original value)
 * DPETE 31482 1/25/06 update pw_dt when flag is set
 * 7/17/2006.02 - PTS33321 - PRB - Created this log and altered the proc to handle unknown doctypes
 *                               - as well as unknown ordernumbers.
 * 
 *
 * 8/4/6.03 - PTS 34025 if the  cusotmer set up a E prefix paperwork entry so Microdea would email it
 *     the proper record in the paperwork table is not getting set when scanned. Problem that label file
 *     does nto allow duplicate names (even if different codes)
 * 9/28/06 - PTS 34647 disabe triggers is causing a permissions problem
 * 10/11/2013 - PTS 72032 Check paperwork by mov (cmp_invoiceby='MOV' on billto)
 * 10/07/2015 - PTS 95567 Remove <or> condition for better query plan
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
		'image_SetPWReceivedY001_splong',
		@ordnum,
		@doctype,
		null,
		null,
		null,
		null,
		null,
		null)		
end

Declare @Prefix varchar(1),@abbr varchar(7), @v_ordhdrnumber INT, @v_movnumber INT,@v_lghnumber INT --PRB PTS33321
Declare @gi_bymove varchar(1), @mov INT, @rows INT, @min_ordnum INT, @ord_billto VARCHAR(12), @inv_bymove VARCHAR(3) --PTS72032
declare @orders table (ord_hdrnumber INT)			--PTS72032
/*    supports Microdea email document functionality   */
Select @prefix =  gi_string1 from generalinfo where gi_name = 'MicrodeaEmailFlagPrefix'
If @prefix is Null Select @prefix = ''
-- Microde return the doctype or doc name  without the E prefix
--If @prefix > ''
 Select @abbr = MIN(abbr) from labelfile WHERE labeldefinition='PaperWork' AND  ( name = @prefix+@doctype
     or name = @doctype)
--else
-- Select @abbr = MIN(abbr) from labelfile WHERE labeldefinition='PaperWork' AND name = @doctype 
--      and left(abbr,1) <> @prefix
--PRB PTS33321 - We will reject any updates that contain a doctype that doesn't exist in our
--               labelfile under PaperWork.


IF (@abbr IS NULL)
BEGIN
    RETURN -10
END


--Set values for use downstream.
SELECT @v_ordhdrnumber = MIN(o.ord_hdrnumber), @v_lghnumber = MIN(ISNULL(l.lgh_number, 0)),@v_movnumber=MIN(o.mov_number)
	,@ord_billto = MIN(o.ord_billto)	--PTS 72032 nloke
FROM orderheader o
LEFT OUTER JOIN legheader l
ON o.mov_number = l.mov_number
WHERE ord_number = @OrdNum

-- Return error back to calling vendor - no ordernumber exists in our db for this order
If (@v_ordhdrnumber IS NULL)
BEGIN 
   RETURN - 20
END 

--PTS 72032 nloke 
-- When GI is turned on, get orders with the same move.
Select @gi_bymove = isnull(Left(gi_string1,1),'N') from generalinfo where gi_name = 'Image_PW_ByMove'
Select @inv_bymove = isnull(cmp_invoiceby,'') from company where cmp_id = @ord_billto
If @gi_bymove = 'Y' and @inv_bymove = 'MOV'		--get all orders that is on the same move as the @OrdNum
	begin
		select @mov = mov_number
		from orderheader 
		--PTS95567 where ord_hdrnumber = @OrdNum
		WHERE ord_number = @ordNum --PTS95567 -- changed to ord_number for better consistency.
		
		
		INSERT INTO @orders
		Select ord_hdrnumber
		from orderheader
		where mov_number = @mov
			and ord_billto in (select cmp_id from company where cmp_invoiceby = 'MOV')
	end
--else  --PTS95567 --removed this <else> section and used one below instead
--	begin
--		insert into @orders values (@v_ordhdrnumber)
--	end

--PTS95567 -- always add v_ordhdrnumber so that an OR is never needed below
IF not exists (select 1 from @orders where ord_hdrnumber = @v_ordhdrnumber)
  insert into @orders values (@v_ordhdrnumber)
	
select @min_ordnum = min (ord_hdrnumber) from @orders

while @min_ordnum > 0 
begin

	-- Check if the doctype exists in paperwork. If it doesn't we will do what Order Entry
	-- does and create all the paperwork records necessary from the labelfile.  A situation may occur
	-- where TotalMail imports an order but PaperWork records fail to be created.  We will address
	-- that with the statements below.
	IF NOT EXISTS (SELECT 1 FROM paperwork WHERE ord_hdrnumber = @v_ordhdrnumber
		 and abbr in (select abbr from labelfile where labeldefinition = 'PaperWork' and (name = @doctype
					 or name = @prefix+@doctype)))
			 --  AND (abbr = @abbr OR abbr = @prefix+@abbr))
	BEGIN
		-- We could do this which would be to insert the doctype and mark it as received...
		-- I saved this for use later if the other method doesn't work out.
		/*
		   INSERT INTO PaperWork (abbr, pw_recieved, ord_hdrnumber, pw_dt, last_updatedby, last_updateddatetime,
				  pw_imaged, lgh_number)
		   VALUES (@abbr, 'Y', @v_ordhdrnumber, getdate(), 'image_SetPWReceivedY001_splong', getdate(), 'Y', @v_lghnumber

		*/

		-- Here we are doing the insert like the order table trigger, creating all the proper entries.
	  --  alter table paperwork disable trigger all
		INSERT INTO paperwork (abbr,pw_received,ord_hdrnumber,pw_dt,last_updatedby,last_updateddatetime,lgh_number,pw_imaged,Mov_Number)
			  SELECT labelfile.abbr,'N',@v_ordhdrnumber,getdate(),'ReceivedY001_splong',getdate(),@v_lghnumber,'N',@v_movnumber
			  FROM labelfile
			  WHERE labelfile.labeldefinition = 'PaperWork'
			  and labelfile.abbr <> 'TEMP'
			  and IsNull(labelfile.retired,'N') <> 'Y'
				  --This will cover us in case we have some of the entries in paperwork already.
 			  AND labelfile.abbr NOT IN (SELECT abbr
						 FROM paperwork
						 --WHERE ord_hdrnumber = @v_ordhdrnumber)
						 --WHERE (ord_hdrnumber = @v_ordhdrnumber or ord_hdrnumber in (select ord_hdrnumber from @orders)))		--PTS72032 --Removed at PTS95567
						 WHERE ord_hdrnumber in (select ord_hdrnumber from @orders))		                                    --PTS95567
	   --   alter table paperwork enable trigger all

		  --Now we can feel free to update the record that imaging wanted to update.
      		UPDATE Paperwork 
		SET pw_Imaged = 'Y', 
		pw_Received = 'Y', 
		pw_dt = GETDATE(),
		last_updatedby = 'ReceivedY001_splong',
		last_updateddatetime = getdate()
    		--WHERE (ord_hdrnumber = @v_ordhdrnumber or ord_hdrnumber in (select ord_hdrnumber from @orders))	--PTS72032 --Removed at PTS95567
    		WHERE ord_hdrnumber in (select ord_hdrnumber from @orders)		                                    --PTS95567
			and (Mov_number=@v_movnumber or Mov_number is null)
		AND abbr in (select abbr from labelfile where labeldefinition = 'PaperWork' and (name = @doctype
					 or name = @prefix+@doctype))
	END
	ELSE
	-- Here we handle one that we have already in paperwork, just update it.  If the above if statement
	-- was called the first time, we will come here on the next call.
	BEGIN
		-- Moved this to the if statement above.
		/*If Not Exists (Select 1 From paperwork   
		   Where ord_hdrnumber = @v_ordhdrnumber  
		   and (abbr = @abbr or abbr = @prefix+@abbr)  
		   and pw_received = 'Y')
		  Update paperwork Set pw_imaged = 'Y',pw_received = 'Y',pw_dt = getdate()
		  where ord_hdrnumber = @v_ordhdrnumber
		  and abbr = @abbr
		Else */
	--END PRB PTS33321
		  UPDATE Paperwork 
		  SET pw_Imaged = 'Y', 
		  pw_Received = 'Y', 
		  pw_dt = GETDATE(),
		  last_updatedby = 'ReceivedY001_splong',
		  last_updateddatetime = getdate()
		  WHERE (ord_hdrnumber = @v_ordhdrnumber or ord_hdrnumber in (select ord_hdrnumber from @orders))		--PTS 72032
		   and (Mov_number=@v_movnumber or Mov_number is null)
		  and abbr in (select abbr from labelfile where labeldefinition = 'PaperWork' and (name = @doctype
					 or name = @prefix+@doctype))     
	END

	/** Code pre PTS33321
	If Not Exists (Select * From paperwork   
	   Where ord_hdrnumber = (Select ord_hdrnumber From orderheader where ord_number = @OrdNum)  
	   and (abbr = @abbr or abbr = @prefix+@abbr)  
	   and pw_received = 'Y')
	  Update paperwork Set pw_imaged = 'Y',pw_received = 'Y',pw_dt = getdate()
	  where ord_hdrnumber = (Select ord_hdrnumber From orderheader where ord_number = @OrdNum)
	  and abbr = @abbr
	Else
	   Update paperwork Set pw_imaged = 'Y'
	  where ord_hdrnumber = (Select ord_hdrnumber From orderheader where ord_number = @OrdNum)
	  and abbr = @abbr
	**/
	select @min_ordnum = min (ord_hdrnumber) from @orders
            where ord_hdrnumber > @min_ordnum
end
GO
GRANT EXECUTE ON  [dbo].[image_SetPWReceivedY001_splong] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.32
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'image_SetPWReceivedY001_splong', NULL, NULL
GO
