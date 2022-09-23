SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill138_sp] (@p_reprintflag 		varchar(10),
                                @p_mbnumber 		int,
                                @p_billdate     datetime,
                                @p_billto 		  varchar(8),
                                @p_shipper 		  varchar(8),
                                @p_consignee 		varchar(8),
                                @p_orderby      varchar(8),
                                @p_company      varchar(8), 
                                @p_revtype1 		varchar(6),
                                @p_revtype2 		varchar(6),
                                @p_revtype3 		varchar(6),
                                @p_revtype4 		varchar(6),                                
                                @p_shipstart 		datetime,
                                @p_shipend 		  datetime,
                                @p_deliverystart 		datetime,
                                @p_deliveryend 		datetime,
                                @p_billsatrt datetime,
                                @p_billend   datetime,
                                @p_copy 		int, 
                                @p_lastupdateby 	varchar(20),
                                @p_fromorder         varchar(30))
AS

/*
Format must break into a separate master bill for every $5,000 of charges

Will return all invoice for the bill to meeting the selection criteria but the mbcounter field will be incremented
form 1 to 2 or 3 or 4 if this master bill must be split into multiple bills. Issue if they want multiple copies
the copy rints will need to be done before going to filter on next maste bill (by counter) and a new mb nubmer
will need to be assigned. Breaks on job number which is a remark on the master order from which this order was copied.
Use the break on FROMORD to accomplish this

DPETE 51699 created
DPETE 52750 proc will nto run on SQL Server 2000 database. Need to explicitly ocnvert and name all comuns for the insert because of the ident.
*/

declare @runningtotal money, @maxamoutnperbill money,@nextshipdate datetime, @nextinvoice int, @nextinvoicenumber varchar(13)
declare @NextID int, @MBadder int, @maxamountperbill money, @unit varchar(6),@ratefactor float,@rollintolhamount money
declare @rateunit varchar(6)
declare @FirstInvoiceprocessed varchar(10), @begininvoiceID int, @begininvoiceNbr varchar(13)


declare @results table (
 recident int identity,
 mbnumber int null,
 mbcounter int null,
 copy int null,
 ivh_totalcharge money null,
 ivh_billto varchar(8) NULL,
 billto_name varchar(100) NULL,
 billto_address1 varchar(100) null,
 billto_address2 varchar(100) null,
 billto_citystatezip varchar(100) null,
 ivh_shipdate datetime null,
 ivh_invoicenumber varchar(13) null,
 bill_date datetime null,
 ord_number varchar(13)  null,
 ivh_shipper varchar(8) null,
 shipper_name varchar(100) null,
 shipper_cityname varchar(30) null,
 ivh_consignee varchar(8) null,
 consignee_name varchar(100) null,
 consignee_cityname varchar(30) null,
 job_number varchar(15) null,
 reference_number varchar(30) null,
 charge_description varchar(60) null,  
 ivd_quantity  decimal(18,6) null,
 ivd_rate money null,
 ivd_charge money null,
 cht_basisunit varchar(6) null,
 cht_rollintoLH   int null,
 ivd_type varchar(6) null,
 ivh_hdrnumber int null,
 commodityname varchar(60) null,
 cht_itemcode varchar(8) null,
 ivd_unit varchar(6) null,
 ivd_rateunit varchar(6) null
    )
    
select @maxamountperbill = convert( money,gi_string1 ) from generalinfo where gi_name = 'MBFormatMaxPerBill'
select @maxamountperbill = isnull(@maxamountperbill,5000.00)
select @p_fromorder = isnull(@p_fromorder,'')

If @p_reprintflag = 'REPRINT' 
  BEGIN
  Insert into @results (mbnumber ,
 mbcounter ,
 copy ,
 ivh_totalcharge ,
 ivh_billto,
 billto_name ,
 billto_address1,
 billto_address2,
 billto_citystatezip,
 ivh_shipdate,
 ivh_invoicenumber,
 bill_date ,
 ord_number,
 ivh_shipper,
 shipper_name,
 shipper_cityname ,
 ivh_consignee,
 consignee_name,
 consignee_cityname ,
 job_number,
 reference_number ,
 charge_description ,  
 ivd_quantity ,
 ivd_rate,
 ivd_charge,
 cht_basisunit,
 cht_rollintoLH,
 ivd_type,
 ivh_hdrnumber,
 commodityname ,
 cht_itemcode ,
 ivd_unit ,
 ivd_rateunit
    )
  Select ivh_mbnumber mbnumber,
     0 mbcounter,   -- will always be zero on a reprint 
     copy = 1,
     ivh_totalcharge,
     ivh_billto,
     case rtrim(isnull(bcmp.cmp_mailto_name,''))
        when '' then bcmp.cmp_name
        else bcmp.cmp_mailto_name
        end  billto_name,
     case rtrim(isnull(bcmp.cmp_mailto_name,''))
        when '' then isnull(bcmp.cmp_address1,'')
        else isnull(bcmp.cmp_mailto_address1,'')
        end  billto_address1,
     case rtrim(isnull(bcmp.cmp_mailto_name,''))
        when '' then isnull(bcmp.cmp_address2,'')
        else isnull(bcmp.cmp_mailto_address2,'')
        end  billto_address2,
     case rtrim(isnull(bcmp.cmp_mailto_name,''))
        when '' then bcty.cty_name+', '+ isnull(bcmp.cmp_state,'')  + '    '+isnull(bcmp.cmp_zip,'')
        else  bmcty.cty_name+', '+ isnull(bcmp.cmp_mailto_state,'')  + '    '+isnull(bcmp.cmp_mailto_zip,'')
        end  billto_citystate,
    ivh_shipdate,
    ivh_invoicenumber,
    @p_billdate bill_date,
    invoiceheader.ord_number,
    ivh_shipper,
    scmp.cmp_name shipper_name,
    scty.cty_name shipper_city,
    ivh_consignee,
    ccmp.cmp_name consignee_name,
    ccty.cty_name consignee_city,
    isnull(masterord.ord_remark,'') job_number,
    reference_number =  Case invoiceheader.ord_hdrnumber
      When 0 then (select top 1 ref_number from referencenumber where ref_type = 'REF'
                          and ref_table = 'invoiceheader' and ref_tablekey = invoiceheader.ivh_hdrnumber)
      Else (select top 1 ref_number from referencenumber where ref_type = 'REF'
                          and ref_table = 'orderheader' and ref_tablekey = invoiceheader.ord_hdrnumber)
      End ,
    case isnull(ivd_description,'UNKNOWN')
       when 'UNKNOWN' then cht_description
       else ivd_description
       end charge_description,
    ivd_quantity,
    ivd_rate,
    ivd_charge,
    chargetype.cht_basisunit,
    invoicedetail.cht_rollintolh,
    ivd_type,
    invoiceheader.ivh_hdrnumber,
    commodityname = (select top 1 ivd_description from invoicedetail d2 where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
                        and ivd_type = 'DRP' and ivd_description <> 'UNKNOWN'),
    invoicedetail.cht_itemcode,
    invoicedetail.ivd_unit,
    invoicedetail.ivd_rateunit
    from invoiceheader
    join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
    left outer join orderheader on invoiceheader.ord_number = orderheader.ord_number
    left outer join orderheader masterord on orderheader.ord_fromorder = masterord.ord_number
    left outer join company bcmp on invoiceheader.ivh_billto = bcmp.cmp_id
    left outer join city bcty on bcmp.cmp_city = bcty.cty_code
    left outer join city bmcty on bcmp.cmp_mailto_city = bmcty.cty_code
    left outer join company scmp on invoiceheader.ivh_shipper = scmp.cmp_id
    left outer join city scty on scmp.cmp_city = scty.cty_code
    left outer join company ccmp on invoiceheader.ivh_consignee = ccmp.cmp_id
    left outer join city ccty on ccmp.cmp_city = ccty.cty_code
    left outer join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode      
    where  ivh_mbnumber  = @p_mbnumber 
    order by ivh_shipdate,ivh_invoicenumber
    

  END
else
  BEGIN
  Insert into @results(mbnumber ,
 mbcounter ,
 copy ,
 ivh_totalcharge ,
 ivh_billto,
 billto_name ,
 billto_address1,
 billto_address2,
 billto_citystatezip,
 ivh_shipdate,
 ivh_invoicenumber,
 bill_date ,
 ord_number,
 ivh_shipper,
 shipper_name,
 shipper_cityname ,
 ivh_consignee,
 consignee_name,
 consignee_cityname ,
 job_number,
 reference_number ,
 charge_description ,  
 ivd_quantity ,
 ivd_rate,
 ivd_charge,
 cht_basisunit,
 cht_rollintoLH,
 ivd_type,
 ivh_hdrnumber,
 commodityname ,
 cht_itemcode ,
 ivd_unit ,
 ivd_rateunit
    )
  Select @p_mbnumber mbnumber,
     0 mbcounter,  
     copy = 1,
     ivh_totalcharge,
     ivh_billto,
     case rtrim(isnull(bcmp.cmp_mailto_name,''))
        when '' then bcmp.cmp_name
        else bcmp.cmp_mailto_name
        end  billto_name,
     case rtrim(isnull(bcmp.cmp_mailto_name,''))
        when '' then isnull(bcmp.cmp_address1,'')
        else isnull(bcmp.cmp_mailto_address1,'')
        end  billto_address1,
     case rtrim(isnull(bcmp.cmp_mailto_name,''))
        when '' then isnull(bcmp.cmp_address2,'')
        else isnull(bcmp.cmp_mailto_address2,'')
        end  billto_address2,
     case rtrim(isnull(bcmp.cmp_mailto_name,''))
        when '' then bcty.cty_name+', '+ isnull(bcmp.cmp_state,'')  + '    '+isnull(bcmp.cmp_zip,'')
        else  bmcty.cty_name+', '+ isnull(bcmp.cmp_mailto_state,'')  + '    '+isnull(bcmp.cmp_mailto_zip,'')
        end  billto_citystate,
    ivh_shipdate,
    ivh_invoicenumber,
    @p_billdate bill_date,
    invoiceheader.ord_number,
    ivh_shipper,
    scmp.cmp_name shipper_name,
    scty.cty_name shipper_city,
    ivh_consignee,
    ccmp.cmp_name consignee_name,
    ccty.cty_name consignee_city,
    isnull(masterord.ord_remark,'') job_number,
    reference_number =  Case invoiceheader.ord_hdrnumber
      When 0 then (select top 1 ref_number from referencenumber where ref_type = 'REF'
                          and ref_table = 'invoiceheader' and ref_tablekey = invoiceheader.ivh_hdrnumber)
      Else (select top 1 ref_number from referencenumber where ref_type = 'REF'
                          and ref_table = 'orderheader' and ref_tablekey = invoiceheader.ord_hdrnumber)
      End ,
    case isnull(ivd_description,'UNKNOWN')
       when 'UNKNOWN' then cht_description
       else ivd_description
       end charge_description,
    ivd_quantity,
    ivd_rate,
    ivd_charge,
    chargetype.cht_basisunit,
    invoicedetail.cht_rollintolh,
    ivd_type,   
    invoiceheader.ivh_hdrnumber,
    commodityname = (select top 1 ivd_description from invoicedetail d2 where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
                        and ivd_type = 'DRP' and ivd_description <> 'UNKNOWN'),
    invoicedetail.cht_itemcode,
    invoicedetail.ivd_unit,
    invoicedetail.ivd_rateunit
    from invoiceheader
    join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
    left outer join orderheader on invoiceheader.ord_number = orderheader.ord_number
    left outer join orderheader masterord on orderheader.ord_fromorder = masterord.ord_number
    left outer join company bcmp on invoiceheader.ivh_billto = bcmp.cmp_id
    left outer join city bcty on bcmp.cmp_city = bcty.cty_code
    left outer join city bmcty on bcmp.cmp_mailto_city = bmcty.cty_code
    left outer join company scmp on invoiceheader.ivh_shipper = scmp.cmp_id
    left outer join city scty on scmp.cmp_city = scty.cty_code
    left outer join company ccmp on invoiceheader.ivh_consignee = ccmp.cmp_id
    left outer join city ccty on ccmp.cmp_city = ccty.cty_code
    left outer join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode        
    where  ivh_billto = @p_billto 
    and ivh_mbstatus = 'RTP'
    and isnull(orderheader.ord_fromorder,'')   = @p_fromorder  
    and ivh_shipdate between @p_shipstart and @p_shipend 
    and ivh_deliverydate between @p_deliverystart and @p_deliveryend 
    and ivh_billdate between @p_billsatrt and @p_billend  
    and @p_revtype1 in (ivh_revtype1,'UNK')
    and @p_revtype2 in (ivh_revtype2,'UNK')
    and @p_revtype3 in (ivh_revtype3,'UNK')
    and @p_revtype4 in (ivh_revtype4,'UNK') 
    and @p_shipper in (ivh_shipper,'UNKNOWN')
    and @p_consignee in (ivh_consignee,'UNKNOWN')
    and @p_company in (ivh_company ,'UNKNOWN')
    and @p_lastupdateby in (invoiceheader.last_updateby,'UNK')
    and invoicedetail.ivd_charge <> 0 /*  */
    order by ivh_shipdate,ivh_invoicenumber,ivd_sequence

   /* this code will do roll into line haul on rate by total invoices with rollinto charges */
  If exists (select 1 from @results where cht_rollintolh = 1 and ivd_type = 'LI') and 
     exists (select 1 from @results where ivd_type = 'SUB')
    BEGIN  /* roll into lne haul charges exist */
       select  @NextID = min(recident) 
       from @results
       where ivd_type = 'SUB'
       While @NextID > 0
         BEGIN  /* Next invoice with SUB row */
           Select @nextinvoice = ivh_hdrnumber from @results where recident = @NextID
           If exists (select 1 from @results where ivh_hdrnumber = @nextinvoice and cht_rollintolh = 1 and ivd_type = 'LI')
             BEGIN  /* Invoice had roll into charges */
   -- select '............#Roll invoice',ivh_invoicenumber from @results where ivh_hdrnumber = @nextinvoice
               Select @rollintolhamount = sum(ivd_charge) 
               from @results
               where ivh_hdrnumber = @nextinvoice
               and cht_rollintolh = 1
               and ivd_type = 'LI'
               
               select @rollintolhamount = isnull(@rollintolhamount,0.00)
    --select '#          amount to roll',@rollintolhamount
               If @rollintolhamount > 0
                 Begin  /* roll into amount is <> 0 */
                    If exists (select 1 from @results where  ivh_hdrnumber = @nextinvoice and cht_itemcode = 'MIN')
                      BEGIN /* invoice has min charge */
   
                        select @unit = ivd_unit,
                        @rateunit = ivd_rateunit
                        from @results tbl
                        where ivh_hdrnumber = @nextinvoice and cht_itemcode = 'MIN'
     
                        select @ratefactor = unc_factor
                        from unitconversion
                        where unc_from = @unit
                        and unc_to = @rateunit
                        and unc_convflag = 'R'
--select '#            has min row convert from to factor',@unit,@rateunit,@ratefactor
                        select @ratefactor = isnull(@ratefactor,1)
 
		                    update @results
	                      set ivd_charge = ivd_charge + @rollintolhamount,
                        ivd_rate = case ivd_quantity 
                          when 0 then ivd_charge + @rollintolhamount
                          else  round((ivd_charge + @rollintolhamount) / (ivd_quantity * @ratefactor),4)
                          end
                        where ivh_hdrnumber = @nextinvoice and cht_itemcode = 'MIN'
--select '#    result for invoice ',* from @results where ivh_hdrnumber = @nextinvoice
                      END  /* invoice has min charge */
                    else 
                      BEGIN  /* invoice does not have MIN charge */
                        select @unit = ivd_unit,
                        @rateunit = ivd_rateunit
                        from @results tbl
                        where ivh_hdrnumber = @nextinvoice and ivd_type = 'SUB'
     
                        select @ratefactor = unc_factor
                        from unitconversion
                        where unc_from = @unit
                        and unc_to = @rateunit
                        and unc_convflag = 'R'
--select '#            NO MIN row convert from to factor',@unit,@rateunit,@ratefactor
                        select @ratefactor = isnull(@ratefactor,1)
                        if @ratefactor <= 0 select @ratefactor = 1
 --select '#    before update ',ivd_quantity,ivd_unit,ivd_rate,ivd_rateunit,ivd_charge,* from @results where ivh_hdrnumber = @nextinvoice
		                    update @results
	                      set ivd_charge = ivd_charge + @rollintolhamount,
                        ivd_rate = case ivd_quantity 
                           when 0 then ivd_charge + @rollintolhamount
                           else  round((ivd_charge + @rollintolhamount) / (ivd_quantity * @ratefactor),4)
                           end
                        where ivh_hdrnumber = @nextinvoice and ivd_type = 'SUB'
  --select '#    result for invoice ',ivd_quantity,ivd_unit,ivd_rate,ivd_rateunit,ivd_charge,* from @results where ivh_hdrnumber = @nextinvoice
                      END /* invoice does not have MIN charge */
        
                    delete from @results 
                    where ivh_hdrnumber = @nextinvoice and cht_rollintolh = 1 and ivd_type = 'LI'
--select '### after rool into lh',ivd_quantity,ivd_unit,ivd_rate,ivd_rateunit,ivd_charge,* from @results where ivh_hdrnumber = @nextinvoice

                  END /* roll into amount is <> 0 */
                END  /* Invoice had roll into charges */  
            select  @NextID = min(recident) 
            from @results
            where ivd_type = 'SUB'  and recident > @NextID   
         END  /* Next invoice with SUB row WHILE loop */         
    END /* roll into lne haul charges exist */          

    
    
    /* need to look for invoices that push the total over $5,000 and split by incrementing the mbcounter */
    Select @nextshipdate = '19500101',@nextinvoicenumber = '',@MBadder = 0,@runningtotal = 0
    /* since we order by shipdate nd invoice number, search for next invoice in that sequence */
    select @NextID = min(recident) 
    from @results
    where ivh_shipdate > @nextshipdate or ivh_invoicenumber >  @nextinvoicenumber
    select @FirstInvoiceprocessed = 'NO'
    
    While @NextID > 0 
      BEGIN
  --select '##A','Next ID top of loop ',@NextID,' next ship ',@nextshipdate,' next invoice ',@nextinvoicenumber
        select @runningtotal = @runningtotal + ivh_totalcharge, @nextshipdate = ivh_shipdate, 
            @nextinvoice = ivh_hdrnumber,@nextinvoicenumber = ivh_invoicenumber
        from @results
        where recident = @NextID
  --select '##B',' running total', @runningtotal, 'first invoice?',@FirstInvoiceprocessed     
         --select '# next total',@runningtotal, @NextID, @nextshipdate, @nextinvoice
        
        If @runningtotal > @maxamountperbill and @nextinvoicenumber  > ''  -- rare chance first invoice total > max
          BEGIN
          /* increment the master bill counter on all subsequent records , reset the running total to the invoice that pushed it over max */
            --select '......# over max reset ',@runningtotal, @NextID, @nextshipdate, @nextinvoice
            if @FirstInvoiceprocessed = 'NO' /* avoids issue setting counter to 2 on first invoice if first invoice exceeds maximum */
               BEGIN
               /* Find beginning of next invoice and increment counter from this invoice on  */
                 select  @begininvoiceID = min(recident) from @results 
                 where ivh_shipdate > @nextshipdate or ivh_invoicenumber >  @nextinvoicenumber
 --select '##C first invoice' , 'begin ID',  @begininvoiceID           
                 Update @results
                 set mbcounter = mbcounter + 1 where recident >= @begininvoiceID
               END
            else
            /* find start of this invoice and increment counter for all records from that point on */
              BEGIN
                 select @begininvoiceID = min(recident) from @results 
                 where (ivh_shipdate = @nextshipdate and ivh_invoicenumber =  @nextinvoicenumber)
 -- select '##D not first invoice' , 'begin ID',  @begininvoiceID ,@nextshipdate,@nextinvoicenumber                 
                 Update @results
                 set mbcounter = mbcounter + 1 where recident >= @begininvoiceID
              END
            
            Select @runningtotal = ivh_totalcharge from @results where recident = @NextID
          END

        Select @FirstInvoiceprocessed = 'YES'
          /* find next invoice */
        select @NextID = min(recident) 
        from @results
        where (ivh_shipdate > @nextshipdate or ivh_invoicenumber >  @nextinvoicenumber)
        and recident > @nextID
      
      END
  END 
  
 -- select '##$#',recident,mbcounter,ivh_invoicenumber,ivd_charge,ivh_totalcharge from @results

   


Select  
recident,
 mbnumber,
 mbcounter,
 copy,
 ivh_totalcharge,
 ivh_billto,
 billto_name ,
 billto_address1,
 billto_address2,
 billto_citystatezip,
 ivh_shipdate,
 ivh_invoicenumber,
 bill_date,
 ord_number,
 ivh_shipper,
 shipper_name,
 shipper_cityname,
 ivh_consignee,
 consignee_name,
 consignee_cityname,
 job_number,
 reference_number ,
 charge_description,  
 ivd_quantity,
 ivd_rate,
 ivd_charge,
 cht_basisunit,
 ivh_hdrnumber,
 commodityname  --cht_itemcode ,ivd_unit ,  ivd_rateunit 
 from @results
GO
GRANT EXECUTE ON  [dbo].[d_masterbill138_sp] TO [public]
GO
