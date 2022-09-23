SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetReqPpwkforinvoice_sp] (
  @ordhdrnumber int
, @invoiceby varchar(3)
, @billto varchar(8)
, @chargetypescsv varchar (1000)
, @forapp char(1)
, @leg int = 0
 ) 
   
AS    

/**
 * 
 * NAME:
 * dbo.Getpaperworkforinvoice
 *
 * TYPE:
 * [StoredProcedure]
 *
 * REFERENCE
 *  called by PpwkDocsCount to get derive coutnof docs required and count of docs received
 *  called by applciation w_paperworkcheck to get lest of docs required for this leg of the trip
 *     if ppwk by leg lools at leg events
 *
 * ARGUMENTS
 * @ordhdrnumber int used when called by PpwkDocsCount to get return set of required
 *     docs for this order (or if invoice by move, the orders on the move for the same billto)
 * @invoiceby  'ORD' means one invoice for one order 'MOV' means one invoice for all orders
 *     fo the ame bill to company on the move
 * @billto varchar(8) can be used to determine paperwork requirements before order is saved
 * @chargetypescsv  a xcomma separated list of charge types on the invoice passed form invoicing
 *    to get paperwork requirments by charge type (could be passed by OE in future)
 * @forapp  'I' Invoiing,'S' settlements, 'B' both invoicing and settlements (uesed by OE and DIS)
 *  @leg  passes by w_paperworkcheck window to get requirements by leg
 * 
 * DESCRIPTION:
 * This procedure gets all the required paperwork for an invoice with an indication
 *    of whether or not the document has been received
 *
 *  Steps
 *   (##1) convert the passed list of charge types on the invoice to a table
 *
 *   (##2) Determine the orders on the invoice by using the cmp_invoiceby
 *     (if the GI says that PPWK is by leg, include distinc torders and lgh_numbers)
 *
 *   (##3) Determine for each order (and leg if applicable) the required paperwork
 *
 *   (##4) Add records for any paperwork required because the chargetype appears (regardless of billto)
 * 
 *   (##5) Add any ppwk requirements because this charge type is present for htis bill to
 *
 *   (##6) Add any ppwk requirmeents because the charge type requires it for all bill to except some others  
 *
 *   (##7)  Determine which have been received
 *
 * REFERENCES: called by proc PpwkDocsCount proc

 * 
 * REVISION HISTORY:
 * PTS 43837 created by DPETE
 *    1/23/09 enhance for settlements
 *      add argument @forapp and @leg 
 *      so billdoctypes can be checked for proper application
 *  PTS45978 2/9/9 QA wants to see chargetype paperwork in paperwork window
 *  PTS44417 add invoice by move/consignee CON
 *  PTS 45733 Remove paperwork requirement if Billto is on Exclusion List of chargetype 
*/





declare @PPWKchecklevel varchar(15),@PPWKMode varchar(15) 
declare @movnumber int,@minord varchar(12)
declare @consignee varchar(8)

declare @ordlegeventtyp table (ord_hdrnumber int,lgh_number int null,ord_number varchar(12) null,ord_billto varchar(8)
  ,puptype varchar(3) null,drptype varchar(3) null, bothtype char(1) null)

declare @results table (
  labelfile_bdt_doctype  varchar(6) null
  ,cht_itemcode varchar(6) null
  ,billdoctypes_ivh_invoicenumber  varchar(12) null
  ,billdoctypes_bdt_invrequired  char(1) null
  ,pw_received char(1) null
  ,paperwork_abbr varchar(6) null
  ,ord_hdrnumber int null
  ,lgh_number int null
)
declare @chargetypesoninvoice table (cht_itemcode varchar(6) )

declare @legevents table (ord_hdrnumber int null ,stp_type varchar(6) null) 


Select @PPWKchecklevel = gi_string1 from generalinfo where gi_name = 'PaperWorkCheckLevel'
If     @PPWKchecklevel = 'ORD'  Select @PPWKchecklevel = 'ORDER'
Select @PPWKchecklevel = isnull(@PPWKchecklevel,'ORDER')
/* avoid overhead of paperwork by setting GI PaperWorkCheckLevel to NONE  */
if @PPWKchecklevel  = 'NONE'  GOTO EXITPROC
Select @PPWKMode       = gi_string1 from generalinfo where gi_name = 'PaperWorkMode'
Select @PPWKMode       = isnull(@PPWKMode,'A')

  
Select @forapp = isnull(@forapp,'B')

Select @movnumber      = mov_number,
@consignee = ord_consignee
from orderheader where ord_hdrnumber = @ordhdrnumber


if @ordhdrnumber > 0 and (@billto is null or @billto = '')
   select @billto = ord_billto from orderheader where ord_hdrnumber = @ordhdrnumber

/* ##1 */
INSERT @chargetypesoninvoice(cht_itemcode) 
SELECT * FROM CSVStringsToTable_fn(@chargetypescsv) where value <> 'UNK'



/* ##2 create a table of the orders and leg numbers (0 means ppwk check level not leg) to check */
If @forapp = 'I'  -- For invoicing paperwork requirements only  
  BEGIN
    If @invoiceby = 'MOV'
      BEGIN
        if @PPWKchecklevel  = 'ORDER' 
          insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
          select distinct ord_hdrnumber,0 , ord_number,ord_billto,'','',''
          from orderheader
          where mov_number = @movnumber
          and ord_billto = @billto
        if @PPWKchecklevel  = 'LEG'
          BEGIN 
             insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
             select distinct stops.ord_hdrnumber,stops.lgh_number , ord_number, ord_billto,'','',''
             from stops
             join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
             where stops.mov_number = @movnumber
             and ord_billto = @billto
             and stops.ord_hdrnumber > 0
      
          END
      END 
    If @invoiceby = 'CON'
      BEGIN
        if @PPWKchecklevel  = 'ORDER' 
          insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
          select distinct ord_hdrnumber,0 , ord_number,ord_billto,'','',''
          from orderheader
          where mov_number = @movnumber
          and ord_billto = @billto
          and ord_consignee = @consignee
        if @PPWKchecklevel  = 'LEG'
          BEGIN 
             insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
             select distinct stops.ord_hdrnumber,stops.lgh_number , ord_number, ord_billto,'','',''
             from stops
             join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
             where stops.mov_number = @movnumber
             and ord_billto = @billto
             and ord_consignee = @consignee
             and stops.ord_hdrnumber > 0
      
          END
      END 
    If @invoiceby = 'ORD'
      BEGIN
        if @leg > 0  /* w_paperworkcheck passes leg  */
          BEGIN  

             insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
             select distinct stops.ord_hdrnumber, Case @PPWKchecklevel when 'LEG' then lgh_number else 0 end, ord_number, ord_billto,'','',''
             from stops
             join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
             where lgh_number = @leg
             and stops.ord_hdrnumber > 0

          END  
        else  /* proc PpwklDocsCount proc does nto pass leg */
           BEGIN

             if @PPWKchecklevel  = 'ORDER' 
                insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
                select ord_hdrnumber,0, ord_number, ord_billto,'','',''
                from orderheader where ord_hdrnumber =  @ordhdrnumber
             if @PPWKchecklevel  = 'LEG'  
                insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
                select distinct stops.ord_hdrnumber,lgh_number,ord_number,ord_billto,'','',''
                from stops
                join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
                where stops.ord_hdrnumber = @ordhdrnumber
                and stops.ord_hdrnumber > 0
           END
       END
END
If @forapp = 'S'  
  BEGIN
    insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
    select distinct stops.ord_hdrnumber,
    case @PPWKchecklevel 
      when  'LEG' then @leg
      else 0
      end, ord_number, ord_billto,'','',''
    from stops 
    join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
    where stops.lgh_number = @leg
    and stops.ord_hdrnumber > 0
  
  END
If @forapp = 'B'  /* for order entry and Dispatch w_paperworkcheck will pass leg */
  BEGIN
    insert into @ordlegeventtyp(ord_hdrnumber,lgh_number,ord_number,ord_billto,puptype,drptype,bothtype)
    select distinct stops.ord_hdrnumber,
    case @PPWKchecklevel 
      when  'LEG' then @leg
      else 0
      end, ord_number, ord_billto,'','',''
    from stops 
    join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
    where stops.lgh_number = @leg
    and stops.ord_hdrnumber > 0
  
  END

/*  Set events that occured on the leg  */
 if @PPWKchecklevel  = 'LEG' and @PPWKMode = 'B' 
  BEGIN
             update @ordlegeventtyp
             set puptype = 'PUP'
             from @ordlegeventtyp ords
             where exists (select 1 from stops where stops.ord_hdrnumber = ords.ord_hdrnumber and stops.lgh_number = ords.lgh_number and stp_type = 'PUP')
             
             update @ordlegeventtyp
             set drptype = 'DRP'
             from @ordlegeventtyp ords
             where exists (select 1 from stops where stops.ord_hdrnumber = ords.ord_hdrnumber and stops.lgh_number = ords.lgh_number and stp_type = 'DRP')
            
             update @ordlegeventtyp
             set bothtype = 'B'
             from @ordlegeventtyp ords
             where exists (select 1 from stops where stops.ord_hdrnumber = ords.ord_hdrnumber and stops.lgh_number = ords.lgh_number and stp_type = 'PUP')
             and  exists (select 1 from stops where stops.ord_hdrnumber = ords.ord_hdrnumber and stops.lgh_number = ords.lgh_number and stp_type = 'DRP')
 END


/* ##3    Get required docs by order  into @result set for paperwork mode ( A or B)  */

if @PPWKMode = 'A' 
       Insert into @results
       SELECT abbr,
         '[ALL]' as cht_itemcode,
         '[ALL]' as ivh_invoicenumber,
         'Y' bdt_inv_required,
         'N' pw_received,
         abbr,
         ords.ord_hdrnumber,
         ords.lgh_number
       FROM labelfile
         ,@ordlegeventtyp ords
       WHERE labeldefinition = 'PaperWork'
       AND isnull(labelfile.retired,'N') = 'N'
If @PPWKMode = 'B' 
  BEGIN
   If @forapp <> 'B'
     BEGIN
       if @PPWKchecklevel = 'LEG' -- paperwork for leg must look at events
         Insert into @results
         SELECT bdt_doctype,
         '[ALL]' as cht_itemcode,
         '[ALL]' as ivh_invoicenumber,
         isnull(bdt_inv_required,'Y'),
         'N' pw_received,
         bdt_doctype,
         ords.ord_hdrnumber,
         ords.lgh_number
         FROM billdoctypes
         ,@ordlegeventtyp ords
         WHERE billdoctypes.cmp_id = ords.ord_billto
         and isnull(bdt_required_for_application,'B') in 
         ('B', @forapp )
         and isnull(bdt_inv_required,'Y') = 'Y'
         and (Isnull(bdt_required_for_fgt_event,'B') in ('B','APUP', ords.puptype)
          or Isnull(bdt_required_for_fgt_event,'B') in ('B', 'ADRP',ords.drptype)
          or Isnull(bdt_required_for_fgt_event,'B') in ( 'ASTOP' ,ords.bothtype))


       else -- paperwork not by leg
         Insert into @results
         SELECT bdt_doctype,
         '[ALL]' as cht_itemcode,
         '[ALL]' as ivh_invoicenumber,
         isnull(bdt_inv_required,'Y'),
         'N' pw_received,
         bdt_doctype,
         ords.ord_hdrnumber,
         ords.lgh_number
         FROM billdoctypes
         ,@ordlegeventtyp ords
         WHERE billdoctypes.cmp_id = ords.ord_billto
         and isnull(bdt_required_for_application,'B') in 
         ('B', @forapp )
         and isnull(bdt_inv_required,'Y') = 'Y'
     END
    Else 
       Insert into @results
       SELECT bdt_doctype,
         '[ALL]' as cht_itemcode,
         '[ALL]' as ivh_invoicenumber,
         isnull(bdt_inv_required,'Y'),
         'N' pw_received,
         bdt_doctype,
         ords.ord_hdrnumber,
         ords.lgh_number
       FROM billdoctypes
         ,@ordlegeventtyp ords
       WHERE billdoctypes.cmp_id = ords.ord_billto
       and isnull(bdt_required_for_application,'B') in 
         ('B', 'S','I' )
       and isnull(bdt_inv_required,'Y') = 'Y'
       and (Isnull(bdt_required_for_fgt_event,'B') in ('B', 'APUP',ords.puptype)
          or Isnull(bdt_required_for_fgt_event,'B') in ('B','ADRP', ords.drptype)
          or Isnull(bdt_required_for_fgt_event,'B') in ( 'ASTOP' ,ords.bothtype))

  END
--select '##a',* from @ordlegeventtyp
--select '##a',* from @results
--select * from billdoctypes where cmp_id = 'spliter'
/*    BILLING ONLY paperwork by charge type      */
  
--If @forapp = 'I'
If @forapp = 'I' or (@forapp = 'B' and (select count(*) from @chargetypesoninvoice) > 0)
  BEGIN
    /* DESIGN DECISION if a paperwork doc is required for a charge type, add requirement to one order only */
    /* remove the following line to make it create a doc for each order
       when invoice by = MOV       */
    delete from @ordlegeventtyp where ord_number >
    (select min(ord_number) from @ordlegeventtyp)


    /* ##4 Add to required docs chargetype paperwork requirements   */
    /*  .....   where it is always required for the chargetype  */
    Insert into @results
           SELECT cpw_paperwork,
             chg.cht_itemcode,
             '[ALL]' as ivh_invoicenumber,
             isnull(cpw_inv_required,'Y'),
             'N' pw_received,   -- fill in later
             cpw_paperwork,
             ords.ord_hdrnumber,
             ords.lgh_number
           FROM @ordlegeventtyp ords,
             @chargetypesoninvoice chg
             join chargetype on chg.cht_itemcode = chargetype.cht_itemcode
             join chargetypepaperwork cpw on chargetype.cht_number = cpw.cht_Number
           WHERE chargetype.cht_paperwork_requiretype = 'A'
           and isnull(cpw_inv_required,'Y') = 'Y'
           and not exists (select 1 from @results res where res.labelfile_bdt_doctype = cpw_paperwork)  -- no dups



    /* ##5  Add to required docs chargetype paperwork requirements   */
    /*  .....   where it is required for this bill to  */
    Insert into @results
           SELECT cpw_paperwork,
             chg.cht_itemcode,
             '[ALL]' as ivh_invoicenumber,
             isnull(cpw_inv_required,'Y'),
             'N' pw_received,   -- fill in later
             cpw_paperwork,
             ords.ord_hdrnumber,
             ords.lgh_number
           FROM @ordlegeventtyp ords,
             @chargetypesoninvoice chg        
             join chargetype on chg.cht_itemcode = chargetype.cht_itemcode
             join chargetypepaperwork cpw on chargetype.cht_number = cpw.cht_Number
             join chargetypepaperworkcmp on  chargetype.cht_number = chargetypepaperworkcmp.cht_number
           WHERE chargetype.cht_paperwork_requiretype = 'O'
           and chargetypepaperworkcmp.cmp_id = @billto
           and isnull(cpw_inv_required,'Y') = 'Y'
           and not exists (select 1 from @results res where res.labelfile_bdt_doctype = cpw_paperwork)



    /* ##6  Add to required docs chargetype paperwork requirements   */
    /*  .....   where it is required for all but this bill to  */
    Insert into @results
           SELECT cpw_paperwork,
             chg.cht_itemcode,
             '[ALL]' as ivh_invoicenumber,
             isnull(cpw_inv_required,'Y'),
             'N' pw_received,   -- fill in later
             cpw_paperwork,
             ords.ord_hdrnumber,
             ords.lgh_number    
           FROM @ordlegeventtyp ords,
             @chargetypesoninvoice chg        
             join chargetype on chg.cht_itemcode = chargetype.cht_itemcode
             join chargetypepaperwork cpw on chargetype.cht_number = cpw.cht_Number
             join chargetypepaperworkcmp on  chargetype.cht_number = chargetypepaperworkcmp.cht_number
           WHERE chargetype.cht_paperwork_requiretype = 'E'
           and chargetypepaperworkcmp.cmp_id <> @billto
           and isnull(cpw_inv_required,'Y') = 'Y'
           and not exists (select 1 from @results res where res.labelfile_bdt_doctype = cpw_paperwork)
          
      /* ##7  Remove Paperwork if it is excluded by Chargetype*/
      /* PTS 45733 SGB 05/12/10 This will remove paperwork required by Billto but Excluded by Chargetype*/
          delete @results
          FROM @ordlegeventtyp ords,  
             @chargetypesoninvoice chg          
             join chargetype on chg.cht_itemcode = chargetype.cht_itemcode  
             join chargetypepaperwork cpw on chargetype.cht_number = cpw.cht_Number  
             join chargetypepaperworkcmp on  chargetype.cht_number = chargetypepaperworkcmp.cht_number  
           WHERE chargetype.cht_paperwork_requiretype = 'E'  
						and chargetypepaperworkcmp.cmp_id = @billto  
           and isnull(cpw_inv_required,'Y') = 'Y' 
          and paperwork_abbr = cpw.cpw_paperwork  

  END

/* now lets find out which have been recived  */ 

update @results set pw_received = 'Y' 
from @results res
join paperwork ppwk on res.ord_hdrnumber =  ppwk.ord_hdrnumber 
                       and res.paperwork_abbr = ppwk.abbr
                       and (res.lgh_number = ppwk.lgh_number or  res.lgh_number = 0 )
where ppwk.pw_received = 'Y'


EXITPROC:
select 
  res.labelfile_bdt_doctype   -- useless info
  ,res.cht_itemcode      -- useless info
  ,res.billdoctypes_ivh_invoicenumber   -- useless info
  ,res.billdoctypes_bdt_invrequired  -- useless info
  ,res.pw_received 
  ,res.paperwork_abbr 
  ,res.ord_hdrnumber 
  ,res.lgh_number
  ,orderheader.ord_number
from @results res
join orderheader on res.ord_hdrnumber = orderheader.ord_hdrnumber
order by labelfile_bdt_doctype,orderheader.ord_number

GO
GRANT EXECUTE ON  [dbo].[GetReqPpwkforinvoice_sp] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'GetReqPpwkforinvoice_sp', NULL, NULL
GO
