SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE PROC [dbo].[d_masterbill101b_sp](  
@p_reprintflag varchar(10),  
@p_mbnumber int,  
@p_billto varchar(8),   
@p_revtype1 varchar(6),   
@p_mbstatus varchar(6),  
@p_shipstart datetime,  
@p_shipend datetime, 
@p_billdate datetime,   
@p_shipper varchar(8),  
@p_consignee varchar(8),  
@p_copy int
)  
AS  
  
/*  
 *   
 * NAME:d_masterbill101b_sp  
 * dbo.  
 *  
 * TYPE:  
 * StoredProcedure  
 *  
 * DESCRIPTION:  
 * For a summary sheet to master bill format 101
 * assumes rate by detail with only FSCR accessorial charges (although other acc are accommodated)
 * allocates FSCR charges the the delivery cmp / total charges for cmd_class cobo to
 * attemp to allocate the single FSCR charge per invoice across all commodity charges
 * and present a summary report by delivery location / commodity class charges
 *  
 * RETURNS:  
 *  
 * RESULT SETS:   
 * none.  
 *  
 * PARAMETERS:  
 * 001 - @p_reprintflag, int, input, null;  
 *       Has the masterbill been printed  
 * 002 - @p_mbnumber, varchar(20), input, null;  
 *       masterbill number  
 * 003 - @p_billto, varchar(6), input, null;  
 *       Billto selected  
 * 004 - @p_revtype1, varchar(8), input, null;  
 *       revtype 1 value  
 * 005 - @p_mbstatus, int, output, null;  
 *       status of masterbill ie XFR   
 * 006 - @p_shipstart, int, input, null;  
 *       start date  
 * 007 - @p_shipend, varchar(20), input, null;  
 *       end date  
 * 008 - @p_billdate, varchar(6), input, null;  
 *       bill date  
 * 009 - @p_copy, varchar(8), input, null;  
 *       number of copies requested  
 * 010 - @p_ivh_invoicenumber, varchar(12), input, null;  
 *       invoiceheader invoice number (ie. Master)  
 * REFERENCES: (called by and calling references only, don't   
 *              include table/view/object references)  
 * N/A  
 *   
 *   
 *   
 * REVISION HISTORY:  
 * 09/26/07 DPETE created 
 * 1/25/08 BDH 40289 - added consig_city and consig_state
 * DPETE 2/8/8 41334 not handling MIN charges (did not solve problem
 *          on MIN charge we do not have the cmd_code there for no fgt class)
 *       until cmd_code is copied to the MIN charge line we must leave this at 'Minimum'
 *      for the fgt class description
 **/  
  
declare @invoices table (ivh_hdrnumber int null,ivh_charge money null)
declare @fgtclasstotals table 
   (ivh_hdrnumber int null
   ,cmp_id varchar(8) null
   ,cmd_class varchar(8) null  --6
   ,ccl_description varchar(20)null
   ,classqty float null
   , classcharge money null)
declare @results table 
   ( cmp_id varchar(8) null
   ,consignee varchar(100) null
   ,sequence int null
   ,cmd_class varchar(8) null  --6
   ,ccl_description varchar(20)null
   ,description varchar(50) null
   ,classqty float null,
  charge money null,
	consig_city varchar(18) null,  -- BDH 40289
	consig_state varchar(6)null)  -- BDH 40289



DECLARE @V_billname varchar(100),@v_address1 varchar(100),@v_address2 varchar(100),@v_address3 varchar(100),
 @v_address4 varchar(100)
/* this does the work of formating the name and address of the bill to company removing blank lines */
If exists (select 1 from company where cmp_id = @p_billto and   rtrim(isnull(cmp_mailto_name,'')) = '')
  /* no mail to override */
  select @v_billname = cmp_name
  ,@v_address1 = case rtrim(isnull(cmp_address1,'')) when '' then cty_name+ ', ' + cty_state +'    '+isnull(cmp_zip,'') else upper(cmp_address1) end
  ,@v_address2 = case rtrim(isnull(cmp_address2,'')) 
     when '' then case rtrim(isnull(cmp_address1,'')) 
                  when '' then '' 
                  else cty_name+ ', ' + cty_state +'    '+isnull(cmp_zip,'') end
     else upper(cmp_address2)
     end
  ,@v_address3 = case rtrim(isnull(cmp_address3,'')) 
     when '' then 
         case rtrim(isnull(cmp_address2,'')) 
         when '' then ''
         else cty_name+ ', ' + cty_state +'    '+isnull(cmp_zip,'') 
         end
     else upper(cmp_address3)
     end
  ,@v_address4 =  
     case rtrim(isnull(cmp_address3,'')) 
     when '' then ''
     else cty_name+ ', ' + cty_state +'    '+isnull(cmp_zip,'') 
     end
  from company 
  join city on company.cmp_city = cty_code
  where cmp_id = @p_billto
else
  select @v_billname = upper(cmp_mailto_name)
  ,@v_address1 = case rtrim(isnull(cmp_mailto_address1,'')) when '' then cty_name+ ', ' + cty_state +'    '+isnull(cmp_mailto_zip,'') else upper(cmp_mailto_address1) end
  ,@v_address2 = case rtrim(isnull(cmp_mailto_address2,'')) 
     when '' then case rtrim(isnull(cmp_mailto_address1,'')) 
                  when '' then '' 
                  else cty_name+ ', ' + cty_state +'    '+isnull(cmp_mailto_zip,'') end
     else upper(cmp_mailto_address2)
     end
  ,@v_address3 =
         case rtrim(isnull(cmp_mailto_address2,'')) 
         when '' then ''
         else cty_name+ ', ' + cty_state +'    '+isnull(cmp_mailto_zip,'') 
         end
  from company 
  join city on company.cmp_mailto_city = cty_code
  where cmp_id = @p_billto


SELECT  @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT  @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'

/**** Step one get a list of all the invoices and the total delivered volumes that were on the master bill */

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@p_reprintflag) = 'REPRINT' 
  BEGIN
    insert into @invoices(ivh_hdrnumber ,ivh_charge )
    select ivh_hdrnumber,ivh_charge
    from invoiceheader
    where invoiceheader.ivh_mbnumber = @p_mbnumber

  END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
  BEGIN
    insert into @invoices(ivh_hdrnumber ,ivh_charge )
    select ivh_hdrnumber,ivh_charge
    FROM invoiceheader
    WHERE invoiceheader.ivh_billto = @p_billto and 
            invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend and 
            invoiceheader.ivh_mbstatus = 'RTP' and 
            @p_revtype1 in (invoiceheader.ivh_revtype1,'UNK') and 
            @p_shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
            @p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN')


  END

/**** Step 2 - get the total volumes by delivery company/commodity class for each invoice */
Insert into @fgtclasstotals 
select
 inv.ivh_hdrnumber
 ,cmp_id
 ,commodity.cmd_class
 , case cht_itemcode when 'MIN' then 'Minimum' else isnull(ccl_description,'NO FGT CLASS') end
 ,classqty = sum(ivd_quantity)
 ,classcharge = sum (round(ivd_charge,2))
from @invoices inv
join invoicedetail on inv.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
join commodity on invoicedetail.cmd_code = commodity.cmd_code
left outer join commodityclass on commodity.cmd_class = ccl_code
where (ivd_type = 'DRP' or cht_itemcode = 'MIN')
and isnull(ivd_charge,0) > 0 -- eliminate min charge original lines
group by inv.ivh_hdrnumber,cmp_id,commodity.cmd_class,case cht_itemcode when 'MIN' then 'Minimum' else isnull(ccl_description,'NO FGT CLASS') end
/* put records in the return set for gas and diesel charges */
Insert into @results( cmp_id,consignee ,sequence ,cmd_class ,ccl_description,description,classqty, charge )
select fct.cmp_id
  ,consignee = cmp_name
  ,sequence = 1  -- forces fgt charges ahead of fscr for cmd class
  ,cmd_class
  ,fct.ccl_description
  ,description = fct.ccl_description+' Delivery(Volume) '
  ,classqty = sum(classqty)
  ,charge = round(sum(classcharge),2)
 from @fgtclasstotals fct
 join company on fct.cmp_id = company.cmp_id
 group by fct.cmp_id
  ,cmp_name
--  , 1  -- forces fgt charges ahead of fscr
  ,cmd_class
  ,fct.ccl_description
  , (fct.ccl_description+' Delivery(Volume) ')


/* add records for the fuel surcharge (these will need to be summed*/
Insert into @results( cmp_id ,consignee ,sequence ,cmd_class ,ccl_description,description,classqty, charge )
select fct.cmp_id
  ,consignee = cmp_name
  ,sequence = 2  -- forces fgt charges ahead of fscr
  ,fct.cmd_class
  ,fct.ccl_description
  ,description = fct.ccl_description+' FSC '
  ,claassqty = Sum (0)
-- later add sum to this and group by 
  ,charge = round(sum(case ivh_charge when 0 then 0 else (classcharge/ivh_charge) * ivd_charge * 1.00  end),2)
 from @invoices inv -- to get invoice totalcharges
 join @fgtclasstotals fct on inv.ivh_hdrnumber = fct.ivh_hdrnumber
 join invoicedetail on fct.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
 join company on fct.cmp_id = company.cmp_id
 where invoicedetail.cht_itemcode = 'FSCR' or invoicedetail.cht_itemcode = 'FSC'
 group by fct.cmp_id,cmp_name,fct.cmd_class,fct.ccl_description,(fct.cmd_class+' FSC ')

/* add records for other accessorials */
Insert into @results ( cmp_id ,consignee ,sequence ,cmd_class ,ccl_description,description,classqty, charge )
select ivh_consignee
,consignee = cmp_name
,sequence = 3  -- get it to the end
,cmd_class = 'ZZZZZZ'  
,''
,description = 'Other Accessorials'
,classqty = 0
,charge = sum(round(ivd_charge,2))
from @invoices inv
 join invoiceheader on inv.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
 join invoicedetail on inv.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
 join company on ivh_consignee = company.cmp_id
 where invoicedetail.cht_itemcode <> 'FSCR' and invoicedetail.cht_itemcode <> 'FSC' and ivd_type = 'LI' and invoicedetail.cht_itemcode <> 'MIN'
group by ivh_consignee,cmp_name

-- BDH 40289 01/23/08:  added city and state
update @results set consig_city = c.cty_name,
consig_state = c.cty_state
from @results r
join company co on  r.cmp_id = co.cmp_id
join city c on c.cty_code = co.cmp_city


/* return results */

select 
cmp_id 
,consignee 
,sequence 
,cmd_class
,ccl_description
,description
,classqty
,charge
,billtoname = @v_billname
,addressline1 = @v_address1
,addressline2 = @v_address2
,addressline3 = @v_address3
,addressline4 = @v_address4
,consig_city
,consig_state
from @results
order by consignee,cmd_class,sequence

 
GO
GRANT EXECUTE ON  [dbo].[d_masterbill101b_sp] TO [public]
GO
