SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [dbo].[billing_validation_falcon_sp] (@ivh_invoicenumber varchar(12),
						@ErrorMessage varchar(255) output)
as

/**
 * 
 * NAME:
 * dbo.billing_validation_falcon_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Validates invoices on save in Ready to print status for Falcon. 
 *
 * RETURNS:
 * err message if validation fails 
 *
 * RESULT SETS: 
 * N/A
 *
 * PARAMETERS:
 * 001 - @ivh_invoicenumber varchar(12),
 * 002 - @ErrorMessage varchar varchar(255) output
 *
 *  EDITS DONE
 *     EXCEPTIONS
 *       Do not edit supplemental invoices (no order number)
 *       Do not edit credit memos
 *       Edit only if the invoice is in Ready to Print Status
 *
 *     If bill to is Chrysler (must have an entry in labelfile for ValidationCmpIds where abbr starts with "C")
 *           -a BL# ref is required and the BL# ref number cannot be the same for any prrior Chrysler bill to invoice in the past 3 months
 *           -there must be a 'CHRTYP' reference that contains one of the following: 48AR, 48CT,48DD,48ST,53AR,53ST,53DD,53CT
 *           -if mutiple PUPS or multiple DRPS must have geoship ref (GEO) that has a number of  GR or GS followed by 4 numbers
 *           -If there is weight recorded on the invoice it must be greater than 3,500 
 *
 *    If bill to is GM (must have labefile entry with abbr starting with G) 
 *           -If a TRAK reference exists on the order (optional) it must be 9 numeric digits
 *           -If a ROUTE# reference exists on the order (optional) it must be 4-6 characters in length 
 
 *     For all Ford (labelfile ValidationCmpIds abbr starting with F), or Chrysler  bill to companies
 *         -  Bill Date cannot be prior to delivery date
 *         - the bill of lading ref number cannot be the same as the order number.
 *         - there must be a valid EDI location entry for every company on the order 
 *         - For Chrysler bill to companies only, there must be a valid EDI location entry for the bill to company.      
 *
 * REFERENCES:
 * CALLED BY billing_validation_sp if GI entry  'InvValidationProc' has 'billing_validation_falcon_sp' in gi_string1 field
 * 
 * REVISION HISTORY:
 * 3/7/7 - PTS 34952 DPETE created 
 *
 **/

/* only validate if the invoice is in ready to print status */
create table #OrdRefs (ref_type varchar(6) null,ref_number varchar(50) null)
create table #ChryslerCmps(cmp_id varchar(8) null)



declare @v_ivhhdrnumber int,@v_billdate datetime,@v_deliverydate datetime,@v_ordhdrnumber int,@v_ordnumber varchar(12),@v_bollist varchar(500)
declare @v_BOLSearchBackDate datetime,@v_ivhtotalweight money,@v_PupDrpCmpCount smallint,@v_badcmps varchar(1000),@v_ivhbillto varchar(8)
declare @v_batchnbr int, @v_ivhdefinition varchar(6)

select @ivh_invoicenumber = isnull(@ivh_invoicenumber,'')

select @ErrorMessage = ''

If not exists (select 1 from invoiceheader where ivh_invoicenumber = @ivh_invoicenumber and ivh_invoicestatus in ('RTP','NTP')
    and ivh_mbstatus in ('RTP','NTP'))
    GOTO Exit_Point

select @v_ivhhdrnumber = ivh_hdrnumber
        ,@v_ordnumber = ord_number
        ,@v_ivhbillto = ivh_billto
        ,@v_billdate = ivh_billdate
        ,@v_deliverydate = ivh_deliverydate
        ,@v_ordhdrnumber = ord_hdrnumber
        ,@v_ivhtotalweight = isnull(ivh_totalweight,0.0)
        ,@v_ivhdefinition = isnull(ivh_definition,'LH')
from invoiceheader where ivh_invoicenumber = @ivh_invoicenumber

/* should never happen */
If (@v_ivhhdrnumber is null)
   BEGIN
     Select @ErrorMessage = 'Invalid invoice number passed for validation - '+@ivh_invoicenumber
     GOTO Exit_Point
   END

/* do not edit a supplemental invoice */
if @v_ordhdrnumber = 0 GOTO Exit_Point

/* DO not edit credit memos */
If @v_ivhdefinition = 'CRD' GOTO Exit_Point

/* build table of order ref numbers used throughout validation */
Insert into #ordRefs (ref_type,ref_number)
   Select ref_type,ref_number from referencenumber where ord_hdrnumber = @v_ordhdrnumber
   and ref_table = 'orderheader'

/* Chrysler only edits */
If exists (select 1 from labelfile where labeldefinition = 'ValidationCmpIds' and name = @v_ivhbillto and left(abbr,1) = 'C')
  BEGIN
    /* a BL# ref must exists an it cannot duplicate a BL# ref number on previous invoices for all Chrysler bill tos in last 3 months  */
    if not exists (select 1 from #ordRefs where ref_type = 'BL#')
       select @ErrorMessage = @ErrorMessage + '/BL# ref missing. '
    else
      BEGIN
       insert into #ChryslerCmps
       select upper(name) from labelfile
       where labeldefinition = 'ValidationCmpIds'
       and left(abbr,1) = 'C'  /* ask customer to prefix the chrysler cmps with c in case others added later for other billtos */
       and exists (select 1 from company where cmp_id = name and cmp_id <> 'UNKNOWN')

       Select @v_BOLSearchBackDate = dateadd(m,-3,getdate())

       if exists (select 1 
       from referencenumber
       join (select distinct ord_hdrnumber 
             from invoiceheader 
                  join #chryslerCmps on ivh_billto = #chryslerCmps.cmp_id
                  where ivh_billdate >= @v_BOLSearchBackDate 
                  and ord_hdrnumber <> @v_ordhdrnumber) #ords
          on (ref_tablekey = #ords.ord_hdrnumber and ref_table = 'orderheader')
       join (select ref_number from #OrdRefs where  ref_type = 'BL#') #nbrs
          on referencenumber.ref_number = #nbrs.ref_number
       where ref_type = 'BL#' and ref_table = 'orderheader')
       select @ErrorMessage = @ErrorMessage + '/BL# ref matches prior invoice. '
      END


     /* trailer type ref must exist and be one of the valid values */
      If not exists
      (select 1 from #ordRefs
      where ref_type = 'CHRTYP'
      and charindex('^'+ref_number+'^','^48AR^48CT^48DD^48ST^53AR^53ST^53DD^53CT^') > 0)

      select @ErrorMessage = @ErrorMessage + '/Missing or Invalid Chrysler Trl Type ref. '
 

    /* if mutiple PUPS or multiple DRPS must have geoship ref GR or GS followed by 4 numbers */
     if (select count(*) from stops where ord_hdrnumber = @v_ordhdrnumber and stp_type in ('PUP','DRP')) > 2
     BEGIN
         If not exists
         (select 1 from #ordRefs
         where ref_type = 'GEO'
         and charindex('^'+left(ref_number,2)+'^','^GR^GS^') > 0
         and len(ref_number) = 6
         and isnumeric(right(ref_number,4)) = 1)
  
         select @ErrorMessage = @ErrorMessage + '/Missing Chrysler Geo ship ref. '   
     END
    
     /* weight must be =0 or > 3,500 (ignore negatives which would occur on credit memos */
    If @v_ivhtotalweight > 0 and @v_ivhtotalweight < 3500
    select @ErrorMessage = @ErrorMessage + '*Low weight '+convert(varchar(9),@v_ivhtotalweight) + '. '

  END

/* GM bill to edits  */
If exists (select 1 from labelfile where labeldefinition = 'ValidationCmpIds' and name = @v_ivhbillto and left(abbr,1) = 'G')
  BEGIN
     /* tracking ref must by 9 digits if exists */
     If exists (select 1 from #ordrefs
           where ref_type = 'TRAK'
         and (len(rtrim(ref_number)) < 9 
                or len(rtrim(ref_number)) > 9 
                or isnumeric(ref_number) = 0))
     select @ErrorMessage = @ErrorMessage + '/Missing or Invalid TRAK ref#. '
 
     /* If route reference exists it must be 4-6 characters in length */
     If exists (select 1 from #OrdRefs
           where ref_type = 'ROUTE#'
           and (len(rtrim(ref_number)) < 4 
                or len(rtrim(ref_number)) > 6))
     select @ErrorMessage = @ErrorMessage + '/Missing or Invalid ROUTE# ref#. '
  END


/* For all Ford & Chrysler companies in the labelfile EDIValidationCmps */
If exists
(Select *  from labelfile where labeldefinition = 'ValidationCmpIds' and abbr <> 'UNK' and name = @v_ivhbillto 
   and left(abbr,1) in ('F','C'))
  BEGIN
     /*  Bill date cannot be prior to delivery date */
     If @v_billdate < @v_deliverydate Select @ErrorMessage = @ErrorMessage + '/Bill date prior to del date. '

      /* BILL of lading cannot be the same as the order number */
     If exists (select 1 from #ordRefs 
           where ref_type = 'BL#'
           and ref_number = @v_ordnumber)  
     select @ErrorMessage =  @ErrorMessage + '/BL# ref matches the ord number. '

      /*  must have plant codes for all billto, PUP and DRP companies */
      select @v_badcmps = ''
      select @v_badcmps = @v_badcmps + stops.cmp_id + ' '
      from stops 
      where ord_hdrnumber = @v_ordhdrnumber
      and stp_type in ('PUP','DRP')
      and not exists (select 1 from cmpcmp where cmpcmp.billto_cmp_id = @v_ivhbillto and stops.cmp_id = cmpcmp.cmp_id and rtrim(isnull(ediloc_code,'')) > '')

      /* Chrysler only, bill to comp must be in EDI location  */
      If exists
         (Select 1  from labelfile where labeldefinition = 'ValidationCmpIds' and abbr <> 'UNK' and name = @v_ivhbillto 
          and left(abbr,1) ='C')
         if not exists(select 1
         from cmpcmp 
         where cmpcmp.billto_cmp_id = @v_ivhbillto and  cmpcmp.cmp_id = @v_ivhbillto and rtrim(isnull(ediloc_code,'')) > '')
         select @v_badcmps = @v_badcmps + @v_ivhbillto 


      if rtrim(@v_badcmps) > '' select @ErrorMessage = @ErrorMessage + '/Missing EDI loc code for '+@v_badcmps+'. ' 

  END

Exit_Point:

If len(@ErrorMessage) > 0 
  BEGIN
    EXEC @v_batchnbr =  getsystemnumber 'BATCHQ', NULL
    select @ErrorMessage = 'Status set On Hold, '+@ErrorMessage+ ' (Log '+ convert(varchar(12),@v_batchnbr)+')'
    insert into tts_errorlog(err_batch,err_user_id,err_message,err_date,err_number,err_title,err_icon)
    values(@v_batchnbr,'Inv# '+@ivh_invoicenumber,Substring(@ErrorMessage,1,254),getdate(),1,'Failed Billing Validation proc','!')

    update invoiceheader set ivh_invoicestatus = 'HLD',ivh_mbstatus = 'HLD' where ivh_invoicenumber = @ivh_invoicenumber

    select @ErrorMessage = substring(@ErrorMessage,1,255)  /* make sure it fits the variable */

  END


drop table #ordrefs
drop table #ChryslerCmps


Return
GO
GRANT EXECUTE ON  [dbo].[billing_validation_falcon_sp] TO [public]
GO
