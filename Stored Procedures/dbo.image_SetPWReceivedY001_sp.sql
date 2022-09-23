SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[image_SetPWReceivedY001_sp] (@ordnum varchar(12),@doctype varchar(6))    
As
/**
 * 
 * NAME:
 * dbo.image_SetPWReceivedY001_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure is used by the vendor to update paperwork records in TMW SUITE
 * Vendors using this are:  Microdea, Paperwise, Pegasus
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
 *     used for the paperwork identification tells microdea to email the document.  Microdea
 *    may scan a POD or a Proof of Deleivery, but if we assign a required document of EPOD or eProof of Delevery
 *    then they will email it.  COming back and checking off the requirement we mus update a requirement for
 *    the doc ID in microdea or the dci ID with an e prefix.
 * DPETE 28369 do not update the received field if already set to Y
 * DPETE 31482 1/25/06 update pw_dt when flag is set
 * 
 * 7/17/2006.01 - PTS33321 - PRB - Created this log and altered the proc to handle unknown doctypes
 *                               - as well as unknown ordernumbers.
 * 7/19/2006.02 - PTS33321 - As a side note we consolidated all of the image_SetPWReceivedY001_sp from each
 *                         - vendor in VSS we had different versions for different vendors.
 * 8/4/6.03 - PTS 34025 required doc types with the email prefix for Micordea do not get check off when this proc
 *            is called (Maicrodea returns the doc type without the prefix)  EG to email a BOL, set up a required doc type
 *            of EBOL and set the GI MicrodeaEmailFlagPrefix to 'E' (the only value they can use now).  Microdea will
 *            pass back BOL to thsi proc when it is scanned.  Must check off the EBOL record in the paperwork table
 * 09/28/06 - PTS 34647 disable triggers causes permission problems
 * 02/07/13 - PTS 62841 vjh log calls
 **/
 
Declare @Prefix varchar(1), @abbr varchar(7), @v_ordhdrnumber INT,@v_movnumber INT, @v_lghnumber INT -- PRB PTS33321 added abbr

--PTS 40877
Declare @paperworkchecklevel varchar(6)
Declare	@ImagingPaperworkTrack char(1)	--vjh 62841

SELECT @paperworkchecklevel = gi_string1 FROM generalinfo WHERE upper(gi_name) = 'PAPERWORKCHECKLEVEL'

/*    supports Microdea email document functionality   */
Select @prefix =  gi_string1 from generalinfo where gi_name = 'MicrodeaEmailFlagPrefix'
If @prefix is Null Select @prefix = ''

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
		'image_SetPWReceivedY001_sp',
		@ordnum,
		@doctype,
		null,
		null,
		null,
		null,
		null,
		null)		
end
--PRB PTS33321 modifications.
-- doctypes must be retired,not removed when nolonger in use
Select @abbr = MIN(abbr) from labelfile WHERE labeldefinition='PaperWork' AND 
   (abbr = @doctype or abbr = @prefix+@doctype)

IF (@abbr IS NULL)
BEGIN
   RETURN -10  -- scanning a doc type not in TMWS
END

--Set values for use downstream.
    SELECT @v_ordhdrnumber = MIN(o.ord_hdrnumber), @v_lghnumber = MIN(ISNULL(l.lgh_number, 0)),@v_movnumber=MIN(o.mov_number)
    FROM orderheader o
    LEFT OUTER JOIN legheader l
    ON o.mov_number = l.mov_number
    WHERE ord_number = @OrdNum

-- Return error back to calling vendor - no ordernumber exists in our db for this order
If (@v_ordhdrnumber IS NULL)
BEGIN 
   RETURN - 20
END 

/*  Phil's logic is ...  
If the paperwork record does not exists, or if it exists but is not received, then
  (1) Add any records that are missing - because imported orders don't always create records like OE triggers
  (2) then update the status to recieved
Otherwise (if the record exists and is received, set it to received again)

*/

IF Not Exists (Select * From paperwork 
   Where ord_hdrnumber = @v_ordhdrnumber
   and (abbr = @doctype or abbr = @prefix+@doctype))
  -- and pw_received = 'Y')
BEGIN
   
  -- Here we are doing the insert like the order table trigger, creating all the proper entries.
  -- alter table paperwork disable trigger all
	--PTS 40877
	IF @paperworkchecklevel = 'LEG' BEGIN
		INSERT INTO paperwork (abbr,pw_received, ord_hdrnumber, pw_dt, last_updatedby, last_updateddatetime, lgh_number, pw_imaged,Mov_Number)
			  SELECT lbl.abbr, 'N', @v_ordhdrnumber, getdate(), 'ReceivedY001_sp', getdate(), lgh.lgh_number, 'N',@v_movnumber
			  FROM labelfile lbl CROSS JOIN legheader lgh
			  WHERE lbl.labeldefinition = 'PaperWork'
					and lbl.abbr <> 'TEMP'
					and IsNull(lbl.retired,'N') <> 'Y'
					--This will cover us in case we have some of the entries in paperwork already.
 					AND lbl.abbr NOT IN (SELECT abbr
											 FROM paperwork
											WHERE ord_hdrnumber = @v_ordhdrnumber)
					and lgh.ord_hdrnumber = @v_ordhdrnumber
	END
	ELSE BEGIN
		INSERT INTO paperwork (abbr,pw_received,ord_hdrnumber,pw_dt,last_updatedby,last_updateddatetime,lgh_number,pw_imaged,Mov_Number)
			  SELECT labelfile.abbr,'N',@v_ordhdrnumber,getdate(),'ReceivedY001_sp',getdate(),@v_lghnumber,'N',@v_movnumber
			 FROM labelfile
			  WHERE labelfile.labeldefinition = 'PaperWork'
			  and labelfile.abbr <> 'TEMP'
			  and IsNull(labelfile.retired,'N') <> 'Y'
				  --This will cover us in case we have some of the entries in paperwork already.
 			  AND labelfile.abbr NOT IN (SELECT abbr
						 FROM paperwork
						 WHERE ord_hdrnumber = @v_ordhdrnumber)
	END

  --   alter table paperwork enable trigger all

    if not exists (select 1 from labelfile where labeldefinition = 'PaperWork' and (abbr = @doctype or abbr = @prefix + @doctype))
       return -10
      --Now we can feel free to update the record that imaging wanted to update.
  	UPDATE Paperwork 
	SET pw_Imaged = 'Y', 
	pw_Received = 'Y', 
	pw_dt = GETDATE(),
	last_updatedby = 'PWReceivedY001_sp',
	last_updateddatetime = getdate()
	WHERE ord_hdrnumber = @v_ordhdrnumber and (Mov_number=@v_movnumber or Mov_number is null)
	AND (abbr =  @doctype or abbr =  @prefix + @doctype ) --@abbr
END
Else
BEGIN
    UPDATE Paperwork 
	SET pw_Imaged = 'Y', 
	pw_Received = 'Y', 
	pw_dt = GETDATE(),
	last_updatedby = 'PWReceivedY001_sp',
    last_updateddatetime = getdate()
    WHERE ord_hdrnumber = @v_ordhdrnumber and (Mov_number=@v_movnumber or Mov_number is null)
	AND (abbr = @doctype or abbr = @prefix + @doctype) -- @abbr 
END
GO
GRANT EXECUTE ON  [dbo].[image_SetPWReceivedY001_sp] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.3
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'image_SetPWReceivedY001_sp', NULL, NULL
GO
