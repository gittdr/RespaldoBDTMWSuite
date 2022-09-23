SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TMWImaging_UpdatePaperwork_CarrierInvoice] (@ordnum varchar(12),@doctype varchar(6), @lghnumber int = 0, @carrier varchar(8) = 'UNKNOWN'
   , @carrierinvoice varchar(20)= ' ', @invoiceamt money = 0.00, @invoicedate datetime = '19500101 00:00')    
As

/*******************************************************************************************************************  
  Object Description:
  This procedure is used by the vendor to update paperwork records in TMW SUITE and add a record to a file of carrier invoice amounts. Originally named image_SetPWReceivedY003_sp.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  08/04/2017   Jennifer Jackson	WE-209292    Created
*******************************************************************************************************************/

/**
 * 
 * NAME:
 * dbo.image_SetPWReceivedY001_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure is used by the vendor to update paperwork records in TMW SUITE and add a record to a file of carrier invoice amounts
 *   Special version for CRST
 *    Vendors using this are:   Pegasus
 *
 * RETURNS:
 *  1 Success
 * -10 invalid order number
 * -11 invalid doc type
 * -1 paperwork updated but invalid carrier
 * -2 paperwork updated but carrier not valid on leg 
 * -3 paperwork processed but carrier is not valid for order 
 * -4 paperwork processed but record exists for this carrier and amount on this leg
 *
 * RESULT SETS: 
 * See SELECT statement.
 *
 * PARAMETERS:
 * 001 - @ordnum varchar(12) - Takes ord_number so we must get the ord_hdrnumber int
 * 002 - @doctype varchar(20) - Passes the long version of the doctype, it is the name field in labelfile
 * in additon to recording hte document as scanned, this customer wants us to add a record to a table with the carrier invoice information
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 
 * 8/26/09 - History Log:
 * DPETE 48703 created form image_setpwreceivedy001_sp proc
 **/
 
Declare @Prefix varchar(1), @abbr varchar(7), @v_ordhdrnumber INT, @v_lghnumber INT -- PRB PTS33321 added abbr


Declare @paperworkchecklevel varchar(6), @returnvalue int


SELECT @paperworkchecklevel = gi_string1 FROM generalinfo WHERE upper(gi_name) = 'PAPERWORKCHECKLEVEL'



/*    supports Microdea email document functionality   */
Select @prefix =  gi_string1 from generalinfo where gi_name = 'MicrodeaEmailFlagPrefix'
If @prefix is Null Select @prefix = ''

--PRB PTS33321 modifications.
-- doctypes must be retired,not removed when nolonger in use
Select @abbr = MIN(abbr) from labelfile WHERE labeldefinition='PaperWork' AND 
   (abbr = @doctype or abbr = @prefix+@doctype)

IF (@abbr IS NULL)
BEGIN
   RETURN -10  -- scanning a doc type not in TMWS
END

--Set values for use downstream.
    SELECT @v_ordhdrnumber = MIN(o.ord_hdrnumber), @v_lghnumber = MIN(ISNULL(l.lgh_number, 0))
    FROM orderheader o
    LEFT OUTER JOIN legheader l
    ON o.mov_number = l.mov_number
    WHERE ord_number = @OrdNum


-- Return error back to calling vendor - no ordernumber exists in our db for this order
If (@v_ordhdrnumber IS NULL)
BEGIN 
   RETURN -10
END 


IF Not Exists (Select * From paperwork 
   Where ord_hdrnumber = @v_ordhdrnumber
   and (abbr = @doctype or abbr = @prefix+@doctype))
  -- and pw_received = 'Y')
BEGIN
   
	IF @paperworkchecklevel = 'LEG' BEGIN
		INSERT INTO paperwork (abbr,pw_received, ord_hdrnumber, pw_dt, last_updatedby, last_updateddatetime, lgh_number, pw_imaged)
			  SELECT lbl.abbr, 'N', @v_ordhdrnumber, getdate(), 'TMWImaging_UpdatePaperwork_CarrierInvoice', getdate(), lgh.lgh_number, 'N'
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
		INSERT INTO paperwork (abbr,pw_received,ord_hdrnumber,pw_dt,last_updatedby,last_updateddatetime,lgh_number,pw_imaged)
			  SELECT labelfile.abbr,'N',@v_ordhdrnumber,getdate(),'TMWImaging_UpdatePaperwork_CarrierInvoice',getdate(),@v_lghnumber,'N'
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
       return -11
      --Now we can feel free to update the record that imaging wanted to update.
  	UPDATE Paperwork 
	SET pw_Imaged = 'Y', 
	pw_Received = 'Y', 
	pw_dt = GETDATE(),
	last_updatedby = 'TMWImaging_UpdatePaperwork_CarrierInvoice',
	last_updateddatetime = getdate()
		WHERE ord_hdrnumber = @v_ordhdrnumber
	AND (abbr =  @doctype or abbr =  @prefix + @doctype ) --@abbr

END
Else
BEGIN

      	UPDATE Paperwork 
	SET pw_Imaged = 'Y', 
	pw_Received = 'Y', 
	pw_dt = GETDATE(),
	last_updatedby = 'TMWImaging_UpdatePaperwork_CarrierInvoice',
    last_updateddatetime = getdate()
    WHERE ord_hdrnumber = @v_ordhdrnumber
	AND (abbr = @doctype or abbr = @prefix + @doctype) -- @abbr 
END

/* only do the work to add a record for the carrier invoice amount if the carrier ID is passed */
select @returnvalue = 1
If @carrier is not null and @carrier <> 'UNKNOWN' and @carrier > ' '
  BEGIN  -- carrier ID passed
    IF exists (select 1 from carrier where car_id = @carrier)
      BEGIN  -- carrier is valid
        If @lghnumber > 0 
          BEGIN  -- validate lgh_number passed 
            If exists (select 1 from stops join event on stops.stp_number = event.stp_number and evt_sequence = 1
                       where stops.lgh_number = @lghnumber and evt_carrier = @carrier)
                select @returnvalue = 1
            else
                return -2
          END
        If @v_ordhdrnumber > 0          
          BEGIN  -- carrier could not 
            if exists (select 1 from stops join event on stops.stp_number = event.stp_number and evt_sequence = 1
                       where stops.ord_hdrnumber = @v_ordhdrnumber and evt_carrier = @carrier)
              select @returnvalue = 1
            else
              return -3  /* error carrier is not valid on the order nor the trip */
          END
          --END  -- lgh_number passed
       /* rules per SRussell 
            match on carrier, lgh_number and amount is a duplicate, do not process
            match on carrier, leg but different amount, add to table
       */
        If exists (select 1 from  paper_invoice 
                   where --ord_hdrnumber = @v_ordhdrnumber 
                   pi_carrier = @carrier
                   and lgh_number  = @lghnumber
                   and pi_charge  = @invoiceamt )
     
           return -4  /* record exists for this carrier and amount on this leg */
        else
        /* add a record to the table */
          BEGIN
            If @invoiceamt is not null and @invoiceamt <> 0
               insert into paper_invoice(
               ord_hdrnumber
               ,pi_car_invnum
               ,pi_car_invdate
               ,pi_desc
               ,pi_charge
               ,pi_carrier
               ,lgh_number
               ,pi_date_created
               ,pi_createdby)
               Values (
               @v_ordhdrnumber
               ,@carrierinvoice
               ,@invoicedate
               ,''
               ,@invoiceamt
               ,@carrier
               ,@lghnumber
               ,getdate()
               ,'PEGASUS'
               )
               
          END
 
      END  -- carrier is valid  
    ELSE
      return -1  /* error carrier is not valid */
  END  -- carrier ID passed  
  return @returnvalue  
GO
GRANT EXECUTE ON  [dbo].[TMWImaging_UpdatePaperwork_CarrierInvoice] TO [public]
GO
