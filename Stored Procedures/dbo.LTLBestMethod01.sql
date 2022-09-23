SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[LTLBestMethod01] (@p_ivhhdrnumber int)
as
set nocount on
/*

 **** TODO TEST ONE DIMENSIONAL table tariff
 * Assumptions. Rate by detail (consignee is delivery location)
 *    Invoice exists and contains all orders to be rated together
 *    All orders have only one delivery location and are rated by detail
 *    The ratefactor used to convert the billing qty * the rate to the charge is the same for all orders
 *    The weight breaks are the same on all tariffs for this billto to this delivery location (for all cmd classes)
 *    The commodity class must be a number (one decimal max)
 *    All orders on the truck originated at the same location
 *    All of the tariffs have the LTL weight on one dimension 
 *    All of the tariffs have one of the follwoing on the other table dimension (if it exists). And the value is the same on all
 *       Dest zip, Dest zip (3), Dest city, Commodity class
 *
 *  Need to save the invoice before doing this to make sure the tar numbers are on all the commodities
 *
 * Best method example:
 *                                   CWT Rate
 *    Ord#     Cmd Class     Wgt    500-999#    1000-1999#      2000-4999#    
 *     123         60        900      15.91        12.43          11.19
 *     123         70        900      17.86        14.16          12.75
 *     254         60         99      15.91        12.43          11.19
 *
 *  Step one rate each individually at LTLConsdWgt (total wgt delivered to consignee
 *     123        900   @  12.43 (rate for total weight  delivered 1899)  = $111.87
 *     123        900   @  14.16   "                                      = $127.44
 *     254         99   @  12.43   "                                      =  $12.31
 *                                                                    TOTAL $251.62
 *
 *  Best method is rate each at the rate for the next range and then add a charge for the difference in quantity 
 *  at the rate for the lowest commodity class
 *
 *     123        900   @  11.19  (rate for next wgt range 2000)  = $100.71
 *     123        900   @  12.75   "                              = $114.75
 *     254         99   @  11.19   "                              =  $11.07
 *  (2000 - 1899) 101   @  11.19  (rate for lowest cmd class)     =  $11.30    
 *                                                         TOTAL    $237.83
 *
 *  Use rating method with lowest total charge. Add incremental (if next wgt range used)
 *  to Invoice with the last commodity rated for hte delivery to this location
 * 
 *  Does nothing until rating the last commoditiy delivered to this location on 
 *  this move for this billto. It waits until all the invoice detail records exists
 * 
 *  
 * THis proc returns the rate to use. Assumes that all tariffs have the row set to LTL Weight
 * and the cols set to destination ZIP and the index set to the billto, origin zip 
 * and the commodity class          
 * PMILL 02/22/2010 51803 - Even if best method does not apply (ie, best method LH calc is not better than actual LH calc)
 *								the proc is updating invoicedetail records to the best method rate (on all but the current invoice)
 * PMILL 49823 - Changes to support rev based acc flagged as roll into LH for min, and minimums allocated accross invoices
 *				-Bonus - added list of invoices rated to remarks
  * DPETE PTS 57767 Bonus of order list is not making it to all invoices
   * DPETE PTS67383 extra if you rate multiple itmes an one of the invoices not on the screen gets the adjustment ADJUST option
   *   then the billing quantity goes up each time you compute
*/

declare @Debugon Char(1) 
declare @mov int
declare @bestmethodqty float
declare @bestmethodrange money
declare @billto varchar(8)
declare @LTLWeight float
declare @retcode int
declare @DestZip varchar(10)
declare @dest3zip varchar(3)
declare @destcity int
declare @destcmpid varchar(8)
declare @deststate varchar(6)
declare @originzip varchar(10)
declare @origin3zip varchar(3)
declare @origincity int
declare @origincmpid varchar(8)
declare @originstate varchar(6)
declare @wgtisroworcol char(1)
declare @ziproworcolumn char(1)
declare @qtyfactor float
declare @ratefactor float
declare @billunit varchar(6)
declare @rateunit varchar(6)
declare @weightunit varchar(6)
declare @minclass int
declare @cmdcodeforminclass varchar(8) 
declare @bestmethodaddqty float
declare @bestmethodrate money 
declare @freightclasslocation varchar(20)
declare @tarnum int
declare @consignee varchar(8)
declare @ordhdrnumber int
declare @RowMatchvalue varchar(50)
declare @RowRangevalue money
declare @ColMatchvalue varchar(50)
declare @ColRangevalue money
declare @dimensions tinyint
declare @startdate datetime
declare @maxrangevalue money
declare @next  int
declare @nexttarnum int
declare @rate money 
declare @howtoapply varchar(20)
declare @invrows int
declare @bestmethodtotal money
declare @bestmethodtweak money
declare @nextord int
declare @ordratio decimal(9,2)
declare @nextivhhdr int
declare @nextivdnbr int
declare @nextrec INT
declare @sumlh money
declare @sumcharges money
declare @remark varchar(60)
declare @alreadyadjusted char(1)
declare @LTLDeficitQty float
declare @LTLDeficitCharge money
declare @LTLDeficitUnits varchar(6) 
declare @sumLHAdj money  --49823 pmill
declare @minoption varchar(20) --49823 pmill 
declare @lowmin money --49823 pmill
declare @himin money --49823 pmill
declare @mincharge money --49823 pmill
declare @minhirate money --49823 pmill
declare @minlowrate money --49823 pmill
declare @applybestrate varchar(10) --49823 pmill
declare @minacc money --49823 pmill
declare @minadj money --49823 pmill
declare @totalminallocation money --49823 pmill
declare @adjforrounding money --49823 pmill
declare @adjrevacc char(1) --49823 pmill
declare @lastdeliveryrow int --49823 pmill
declare @newivdnum int --49823 pmill
declare @mindesc varchar(60) --49823 pmill
declare @applymincharge char(1) --49823 pmill
declare @bestmethodadj money --49823 pmill
declare @ordlist varchar(200) --49823 pmill

declare @revunits table (abbr varchar(6) null)

declare @invoices table (ord_hdrnumber int null
	, ord_number varchar(12) null
	, ivh_hdrnumber int null
	,ivh_totalweight float null
	,Invoiceweightratio decimal(9,2)
	,adjweight float null  --49823 pmill
	,adjweightratio decimal(9,2) null  --49823 pmill
	)

declare @itemstorate table (
itr_ident int identity 
, ord_hdrnumber int null
, ord_number varchar(12) null
,ivh_hdrnumber int null
,ivd_number int null
,startdate datetime null
,cmd_code varchar(8) null
,fgt_number int null
,Actualweight float null
,weightunit varchar(6) null
,commodityclass varchar(8) null
,cmd_class decimal(9,1) null  -- converted to get the min value
,tar_number int null
,tar_rowbasis varchar(6) null
,tar_colbasis varchar(6) null  
,cht_itemcode varchar(8) null
,quantity decimal(9,1) null
,unit varchar(6) null
,rate money null
,rateunit varchar(6) null
,charge money null
,bestmethodqty decimal(9,1) null
,bestmethodrate money null
,bestmethodcharge money null
,bestmethoddescription varchar(60) null
,wgtisroworcolumn char(1) NULL
,basis varchar(6) null  -- for second dimension on tariff table
,matchvalue varchar(50) null  -- for that second dimension
,rangevalue money null 
,copyrow char(1) NULL
,howtoapply varchar(20) null
,Invoiceweightratio decimal(9,2) null
,spreadamount money null
,lastcmdoninvoice char(1) null
,ActualLTLWeight float null
,alreadyadjusted char(1) 
,tar_mincharge money null  --49823 pmill 
,minchargeallocation money null --49823 pmill
,adjweightratio decimal(9,2) null --49823 pmill
)

create table #t_rates(tra_rate money NULL
,RowNum int NULL
,ColNum int NULL
,RowSeq int NULL
,ColSeq int NULL
,RowVal money NULL
,ColVal money NULL
, ValidCount int NULL
,tra_rateasflat char(1) null
,tra_minqty char(1) null
,tra_minrate money null
,tra_mincharge money null
,tra_billmiles money null
,tra_paymiles money null
,tra_standardhours money null) 

--49823 pmill
declare @revaccessorials table(
	ivh_hdrnumber integer
	,ivd_number integer
	,quantity decimal(9,2) null
	,rate money null
	,charge money null
	,bestmethodcharge money null
	,adjcharge money	
)    

/***** end declarations *****/
-- anticipating mutiple ways to apply the LTL best method
--  assumes while orders are rated by detail, if the best method is applied..
--   ADD-ADJUST adds an extra charge for the deficit after changeing the rates on all commodiies to the best rate
--   ADJUST adds the deficit quantity to one of the commodities (of the lowest commodity class)
--49823 pmill new option indicating how to select minimum charge
select @howtoapply = rtrim(upper(gi_string1)) ,
	@minoption = RTRIM(upper(gi_string2))
from generalinfo where gi_name = 'LTLBestMethodApply'
select @howtoapply =  isnull(@howtoapply,'ADD-ADJUST')
if @howtoapply = ''  select @howtoapply = 'ADD-ADJUST'
select @minoption = ISNULL(@minoption, 'HIMIN')
if @minoption = '' select @minoption = 'HIMIN'

select @debugon = 'Y'

select @retcode = 1

select @freightclasslocation  = gi_string1
from generalinfo 
where gi_name = 'FgtClassForBestMethodLTL'

select @freightclasslocation =
  case @freightclasslocation 
    when 'cmd_class' then 'C1'
    when 'cmd_class1' then 'C1' 
    when 'cmd_class2' then 'C2'
    when 'cmd_nmfc_class' then 'CN' 
    else 'C1'
end


select @billto = ivh_billto,@mov = mov_number ,@ordhdrnumber = ord_hdrnumber,@consignee = ivh_consignee
from invoiceheader 
where ivh_hdrnumber = @p_ivhhdrnumber

-- get list of orders to be rated together and an indication if a non transferred invoice with line haul items on it is out there)
insert into @invoices
select ord_hdrnumber,
		ord_number,
isnull((select max(ivh_hdrnumber) from invoiceheader 
     where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber 
     and isnull(ivh_invoicestatus,'HLD')  <> 'XFR' 
     AND isnull(ivh_mbstatus,'UNK')  <> 'XFR' 
     and ivh_definition   in ('LH','RBIL')
     and exists (select 1 from invoicedetail 
         where invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber 
         and invoicedetail.stp_number > 0)),0) ivh_hdrnumber
,0
,1
,0
,0
from orderheader
where mov_number  = @mov
and   ord_billto  = @billto
and ord_consignee = @consignee  



If (select count(*) from @invoices where ivh_hdrnumber = 0) > 0  -- if any invoices missing can't do deficit rating
    GOTO RETURNFROMPROC

-- used later
insert into @revunits
select abbr
from labelfile
where labeldefinition = 'RevUnits'
and abbr <> 'UNK'

-- get total weight delivered on move to this location for this bill to
select @LTLWeight = 0.0
exec GetLTLConsWeight  @ordhdrnumber , @consignee ,@LTLWeight OUTPUT

-- total weight is used for allocating the adjustment for the best method charges   
update @invoices 
set ivh_totalweight = invoiceheader.ivh_totalweight
,Invoiceweightratio = round(invoiceheader.ivh_totalweight / @LTLWeight,2)
from @invoices ivs
join invoiceheader on ivs.ivh_hdrnumber = invoiceheader.ivh_hdrnumber 

-- make sure allocation of weight ratio across invoices comes to 100%
select @sumcharges = sum(invoiceweightratio) from @invoices 
If @sumcharges <> 1
   update @invoices
   set invoiceweightratio = invoiceweightratio + (1 - @sumcharges)
   where ivh_hdrnumber = @p_ivhhdrnumber
 
/* get items and rating information from the invoice */
insert into @itemstorate(ord_hdrnumber,ord_number,ivh_hdrnumber,ivd_number,startdate,cmd_code,fgt_number
  ,actualweight,weightunit,commodityclass,cmd_class,tar_number,tar_rowbasis,tar_colbasis,cht_itemcode
  ,quantity,unit,rate,rateunit,charge,basis,wgtisroworcolumn,copyrow,Invoiceweightratio
  ,spreadamount,lastcmdoninvoice,ActualLTLWeight,alreadyadjusted
  ,tar_mincharge, minchargeallocation)--49823 pmill 
select  
 invoicedetail.ord_hdrnumber
 ,invoicedetail.ivd_ord_number
 ,invoicedetail.ivh_hdrnumber
 ,invoicedetail.ivd_number
 ,ivh_shipdate
 ,invoicedetail.cmd_code
 ,invoicedetail.fgt_number
 ,invoicedetail.ivd_wgt
 ,invoicedetail.ivd_wgtunit
 ,commodityclass = cmd_class  -- for rate lookup
 ,cmd_class = case isnumeric(cmd_class)
    when 1 then 
      isnull(convert(decimal(9,1),case @freightclasslocation
      when 'C1' then cmd_class
      when 'C2' then cmd_class2
      when 'CN' then commodity.cmd_NMFC_class
      end),0) 
    else 9999
    end
 ,invoicedetail.tar_number
 ,isnull(tariffheader.tar_rowbasis,'')
 ,isnull(tariffheader.tar_colbasis,'')
 ,invoicedetail.cht_itemcode
 ,invoicedetail.ivd_wgt  --need to replace in case invoice was adjusted to flat
 ,tariffheader.cht_unit  --need to replace in case invoice was adjusted to flat
 ,invoicedetail.ivd_rate
 ,tariffheader.cht_rateunit  --need to replace in cas invoice was adjusted
 ,invoicedetail.ivd_charge
 ,basis =  case tar_rowbasis when 'LTLW01' then tar_colbasis else tar_rowbasis end
 ,wgtisroworcolumn = 
    Case 
      when tar_rowbasis = 'LTLW01' then 'R'
      when tar_colbasis = 'LTLW01' then 'C'
      else 'X'  -- should never happen
      end
  , ' ' copyrow
  ,ivs.Invoiceweightratio
  ,0.00
  ,'N'
  ,@LTLWeight
  ,alreadyadjusted = case left(invoiceheader.ivh_remark,9)  -- since adjusting other invoices for spread could reduce per mile
    when '*Adj for ' then 'Y'
    else 'N'
    end
  ,tariffheader.tar_mincharge
  ,0
from  @invoices ivs
join invoiceheader on ivs.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
join commodity on invoicedetail.cmd_code = commodity.cmd_code
left outer join tariffheader on invoicedetail.tar_number = tariffheader.tar_number
where invoicedetail.fgt_number > 0
and invoicedetail.ivd_type = 'DRP'


/* set last commodity on invoice flags */
select @invrows = count(*) from @itemstorate
update @itemstorate
set lastcmdoninvoice = 'Y'
where itr_ident = @invrows

--49823 pmill bonus - get a list of orders that were rated
select @ordlist = RTRIM(ord_number)
from @itemstorate
where itr_ident = @invrows

If (select count(distinct ord_hdrnumber) from @invoices) > 1
   BEGIN
     select @next = 1
     While @next < @invrows
       BEGIN
         if (select ord_hdrnumber from @itemstorate where itr_ident = @next) 
            <> (select ord_hdrnumber from @itemstorate where itr_ident = @next + 1)
			BEGIN
				update @itemstorate set lastcmdoninvoice = 'Y' where itr_ident = @next
				--49823 pmill bonus - get a list of orders that were rated
				select @ordlist = isnull(@ordlist,'') + ',' + RTRIM(ord_number)
				from @itemstorate
				where itr_ident = @next
			END

         select @next = @next + 1
       END
   END

select @ordlist = '[Orders: ' + @ordlist + ']'

/* if everything is rated we can determine if  the best method applies */
If not exists (select 1 from @itemstorate where isnull(tar_number,0) = 0 )
  --and exists (select 1 from @itemstorate where rate <> bestmethodrate)  -- already best method
  BEGIN 
      
     -- if best method is applied the rate will be from this class
     select @minclass = min(cmd_class) from @itemstorate
     select @cmdcodeforminclass  = min(cmd_code) from @itemstorate where cmd_class = @minclass 

     -- try to find matching commodity class in current invoice
     select @next = min( itr_ident)
     from @itemstorate
     where cmd_class = @minclass
     and ivh_hdrnumber = @p_ivhhdrnumber

     if @next is null
       select @next = min( itr_ident)
       from @itemstorate
       where cmd_class = @minclass 
     -- tag which freight record should be copied for the best rate charge ADJ option
     -- ISSUE of invoices are not consolidated invoicedetail for this cmd may not be on current invoice
     update @itemstorate 
     set copyrow = 'Y' 
     where itr_ident = @next

     -- assumes  all tariffs have the same units and rateunits 
     select @billunit = min(unit) from @itemstorate
     select @rateunit = min(rateunit) from @itemstorate
     select @weightunit = min(weightunit) from @itemstorate

     -- need factors for computing best method charge
     select @ratefactor = unc_factor from unitconversion 
     where unc_from  = @billunit
     and unc_to =  @rateunit
     and unc_convflag = 'R'

     select @qtyfactor = unc_factor from unitconversion 
     where unc_from  = @weightunit
     and unc_to =  @billunit
     and unc_convflag = 'Q'

     select @qtyfactor = isnull(@qtyfactor,1)

     -- assumption all tariffs for a billto are set up in the same way
     select @tarnum = max(tar_number) from @itemstorate

     select @wgtisroworcol = case 
         when tar_rowbasis = 'LTLW01' then 'R'
         when tar_colbasis = 'LTLW01' then 'C'
         else ''
         end
     from tariffheader where tar_number = @tarnum

     If isnull(@wgtisroworcol,'') = ''  return -1

     select @destzip = isnull(cmp_zip,''),
     @dest3zip = left(isnull(cmp_zip,''),3),
     @destcity = cmp_city,
     @destcmpid = cmp_id
     from company
     where cmp_id = @consignee

     select @originzip = isnull(cmp_zip,''),
     @origin3zip = left(isnull(cmp_zip,''),3),
     @origincity = cmp_city,
     @origincmpid = cmp_id
     from invoiceheader
     join company on invoiceheader.ivh_shipper = cmp_id
     where invoiceheader.ivh_hdrnumber = @p_ivhhdrnumber

     select @maxrangevalue = max(trc_rangevalue) from tariffrowcolumn

     -- use row or col basis on second dimension of the table for each tariff to determine the match and range values
     update @itemstorate  
     set matchvalue = case basis  -- basis is for the row or col depending on what the LTLW01 was on
        when 'NOT' then 'UNKNOWN'
        when 'DCT' then 'UNKNOWN'
        when 'DCM' then @destcmpid
        when 'DST' then @deststate
        when 'DZP' then left(@destzip,3)
        when 'DZF' then @destzip
        when 'OCT' then 'UNKNOWN'
        when 'OCM' then @origincmpid
        when 'OST' then @originstate
        when 'OZP' then left(@originzip,3)
        when 'OZF' then @originzip
        when 'CLS' then commodityclass
        else '?<>?'
        end,
       rangevalue = case basis
        when 'DCT' then @destcity
        when 'OCT' then @origincity
        else @maxrangevalue
        end
 
      -- make sure every freight item is rated using the regular rate (remove any previously applied best method)
     select @next = min(itr_ident) from @itemstorate
     while @next is not null
       BEGIN
         Select @nexttarnum = tar_number 
        ,@rowmatchValue = case wgtisroworcolumn
           when 'R' then 'UNKNOWN'
           else   matchvalue
           end
         ,@rowrangevalue = case wgtisroworcolumn
           when 'R' then @LTLWeight
           else   rangevalue
           end
         ,@colmatchvalue = case wgtisroworcolumn
           when 'C' then 'UNKNOWN'
           else   matchvalue
           end  
         ,@colrangevalue = case wgtisroworcolumn
           when 'C' then @LTLWeight
           else   rangevalue
           end  
         ,@dimensions = case basis
             when 'NOT' then 1
             else 2
             end
         ,@startdate = startdate   
         from @itemstorate itr
         where itr_ident = @next

         truncate table #t_rates

         insert into #T_rates  
            exec d_tar_gettariffrate_sp @nexttarnum,@rowmatchvalue,@rowrangevalue
                 ,@colmatchvalue,@colrangevalue,@dimensions,@startdate 

         if (select count(*) from #T_rates) = 1
           BEGIN
             select @rate = tra_rate from #t_rates

             update @itemstorate
             set rate = @rate
             ,charge  =  round(isnull(@rate,0) * quantity * @Ratefactor,2)
             where itr_ident = @next
           END

         select @next = min(itr_ident) from @itemstorate where itr_ident > @next
       END
 
     -- find the quantity at the beginning of the next range
     -- must be the same for all tariffs  
     select @bestmethodqty = Min(trc_rangevalue) + 1
     from tariffrowcolumn
     where tar_number = @tarnum  -- the max tar number for all items assume the range is the same for all
     and trc_rowcolumn = @wgtisroworcol  -- LTLW01 may be on row or col
     and trc_rangevalue >= @LTLWeight  -- total weight delivered to this consignee

     select @bestmethodaddqty = @bestmethodqty - sum(quantity)
     from @itemstorate

     select @bestmethodrange = min(trc_rangevalue)  --  weight on the next higher range neede to get table rate
     from tariffrowcolumn
     where tar_number = @tarnum
     and trc_rowcolumn = @wgtisroworcol
     and trc_rangevalue >= @bestmethodqty

--if @debugon = 'Y' select '# best qty',@bestmethodqty ,@wgtisroworcol,* from @itemstorate
  
    select @next = min(itr_ident) from @itemstorate
    while @next is not null
      BEGIN
        Select @nexttarnum = tar_number 
       ,@rowmatchValue = case wgtisroworcolumn
          when 'R' then 'UNKNOWN'
          else   matchvalue
          end
        ,@rowrangevalue = case wgtisroworcolumn
          when 'R' then @bestmethodrange
          else   rangevalue
          end
        ,@colmatchvalue = case wgtisroworcolumn
          when 'C' then 'UNKNOWN'
          else   matchvalue
          end  
        ,@colrangevalue = case wgtisroworcolumn
          when 'C' then @bestmethodrange
          else   rangevalue
          end  
        ,@dimensions = case basis
            when 'NOT' then 1
            else 2
            end
        ,@startdate = startdate   
        from @itemstorate itr
        where itr_ident = @next

        truncate table #t_rates

        insert into #T_rates  
           exec d_tar_gettariffrate_sp @nexttarnum,@rowmatchvalue,@rowrangevalue
              ,@colmatchvalue,@colrangevalue,@dimensions,@startdate 

        if (select count(*) from #T_rates) = 1
          BEGIN
            select @rate = tra_rate from #t_rates

            update @itemstorate
            set bestmethodrate = @rate
            ,bestmethodqty = @bestmethodqty
            ,bestmethodcharge  =  round(isnull(@rate,0) * quantity * @Ratefactor,2)
            where itr_ident = @next
          END

        select @next = min(itr_ident) from @itemstorate where itr_ident > @next
      END
--if @debugon = 'Y' select '## after rating',* from @itemstorate 
 
    -- compute best method charge
    select @bestmethodrate = min(bestmethodrate) -- select only one
    from @itemstorate
    where cmd_class = @minclass

    -- isert a row for the best method adjustment if option is ADJ
    insert into @itemstorate(cmd_code,cmd_class,quantity,bestmethodqty,
       bestmethodrate,bestmethodcharge,bestmethoddescription)     
    select 
    @cmdcodeforminclass,
    @minclass,
    @bestmethodaddqty,
    @bestmethodaddqty,
    @bestmethodrate,
    round(@bestmethodaddqty * @bestmethodrate * @ratefactor,2),
    '*Adj for '+convert(varchar(9),@LTLWeight)+' '+@weightunit+' rated at '+convert(varchar(9),@bestmethodqty) + ' ' + ISNULL(@ordlist,'')  

    -- for option SPREAD (Spread tot best cost across invoices as flat charge by weigh ratio)
    select @bestmethodtotal = sum (bestmethodcharge) from @itemstorate
    update @itemstorate set spreadamount = round(@bestmethodtotal * invoiceweightratio,2)
    where lastcmdoninvoice = 'Y'

    -- make sure the sum of the spread amounts equal the best charge, if not ajust last one
    select @bestmethodtweak = @bestmethodtotal - (select sum(spreadamount) from @itemstorate)
    If @bestmethodtweak > 0 
       update @itemstorate
       set spreadamount = spreadamount + @bestmethodtweak
       where itr_ident = @invrows

	--49823 pmill adjust the weight ratios based on best method
	If @howtoapply = 'ADD-ADJUST'
		--current invoice will get the adjustment
		select @nextivhhdr = @p_ivhhdrnumber
	Else
		select @nextivhhdr = ivh_hdrnumber
		from @itemstorate
		where copyrow = 'Y'
		
	update @invoices 
	set adjweight = ivh_totalweight
	
	update @invoices
	set adjweight = adjweight + @bestmethodaddqty
	where ivh_hdrnumber = @nextivhhdr
	
	update @invoices
	set adjweightratio = ROUND(adjweight / (@LTLWeight + @bestmethodaddqty),2)

	-- make sure allocation of adjusted weight ratio across invoices comes to 100%
	select @sumcharges = sum(adjweightratio) from @invoices 
	If @sumcharges <> 1
	   update @invoices
	   set adjweightratio = adjweightratio + (1 - @sumcharges)
	   where ivh_hdrnumber = @p_ivhhdrnumber

	update @itemstorate
	set adjweightratio = ivs.adjweightratio
	from @itemstorate itr
	join @invoices ivs on ivs.ivh_hdrnumber = itr.ivh_hdrnumber
		and lastcmdoninvoice = 'Y'

	--pmill 51803 Before we start updating invoices and creating adjustments, check to see if the best rate applies
    if (select sum(isnull(bestmethodcharge,0)) from @itemstorate) < (select sum(isnull( charge,0)) from @itemstorate) 
		select @applybestrate = 'Y'
	Else
		select @applybestrate = 'N'     

	--need to account for acc charges flagged as roll into linehaul for total minimum (cht_lh_min = 'Y')
	insert into @revaccessorials (
		ivh_hdrnumber
		,ivd_number
		,quantity
		,rate
		,charge
		)
	(select invoicedetail.ivh_hdrnumber
		,invoicedetail.ivd_number
		,ivd_quantity
		,ivd_rate
		,ivd_charge
		from invoicedetail
		join chargetype on chargetype.cht_itemcode = invoicedetail.cht_itemcode
		join @invoices ivs on ivs.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
		where cht_primary = 'N'
			and invoicedetail.cht_lh_min = 'Y')

	select @nextivdnbr = MIN(ivd_number)
	from @revaccessorials
	
	WHILE @nextivdnbr is not null
		BEGIN
			select @nextivhhdr = ivh_hdrnumber
			from @revaccessorials
			where ivd_number = @nextivdnbr
			
			If @nextivhhdr is not null
				BEGIN
					select @bestmethodadj = SUM(ISNULL(bestmethodcharge,0))
						,@sumcharges = SUM(ISNULL(charge,0))
					from @itemstorate
					where ivh_hdrnumber = @nextivhhdr
					
					update @revaccessorials 
					set bestmethodcharge = @bestmethodadj
						,quantity = @sumcharges
					where ivh_hdrnumber = @nextivhhdr
				END

			select @nextivdnbr = MIN(ivd_number)
			from @revaccessorials
			where ivd_number > @nextivdnbr						
			
		END  --next rev based accessorial
	
	--include bestmethod charge adjustment for the invoice being adjusted
	select @bestmethodadj = ISNULL(bestmethodcharge,0)
	from @itemstorate
	where ivh_hdrnumber is null
	
	If @howtoapply = 'ADD-ADJUST'
		--current invoice will get the adjustment
		update @revaccessorials
		set bestmethodcharge = ISNULL(bestmethodcharge,0) + @bestmethodadj
		where ivh_hdrnumber = @p_ivhhdrnumber
	Else
		--add to the invoice that will receive the adjusted qty/charge
		update @revaccessorials
		set bestmethodcharge = ISNULL(bestmethodcharge,0) + @bestmethodadj
		where ivh_hdrnumber in
			(select ivh_hdrnumber from @itemstorate where copyrow = 'Y')
	
	update @revaccessorials
		set adjcharge = round((bestmethodcharge * rate),2)
		, charge = round((quantity * rate), 2)				

	If @applybestrate = 'Y' 
		--use best method charge
		BEGIN
			select @minacc = SUM(ISNULL(adjcharge,0)) 
			from @revaccessorials
			
			select @sumcharges = SUM(ISNULL(bestmethodcharge,0))
			from @itemstorate
		END
	Else
		--best method charge doesn't apply, so just use the current linehaul charges
		BEGIN
			select @minacc = SUM(ISNULL(charge,0)) 
			from @revaccessorials
			
			select @sumcharges = SUM(ISNULL(charge,0))
			from @itemstorate
		END

	select @minacc = ISNULL(@minacc, 0)

	--See if a minimum charge should be applied
	select @applymincharge = 'Y'
	
	--Determine what the minimum charge should be
	select @himin = MAX(isnull(tar_mincharge,0)) from @itemstorate where ISNULL(tar_mincharge, 0) > 0
	select @lowmin = MIN(isnull(tar_mincharge,0)) from @itemstorate where ISNULL(tar_mincharge, 0) > 0
	select @minhirate = MAX(isnull(rate,0)) from @itemstorate where ISNULL(tar_mincharge,0) > 0
	select @minlowrate = MIN(isnull(rate,0)) from @itemstorate where ISNULL(tar_mincharge,0) > 0
	If @himin = 0 and @lowmin = 0 
		BEGIN
			select @minadj = 0
			select @mindesc = ''
			select @applymincharge = 'N'  --no minimums to apply
			GOTO DOADJUSTMENTS
		END
		
	If @himin = @lowmin 
		select @mincharge = @himin  --minimums are all the same
	Else
		select @mincharge = 
			case 
				when @minoption = 'HIMIN' Then @himin
				when @minoption = 'LOWMIN' Then @lowmin
				when @minoption = 'HIRATE' then (select top 1 tar_mincharge from @itemstorate where rate = @minhirate)
				when @minoption = 'LOWRATE' then (select top 1 tar_mincharge from @itemstorate where rate = @minlowrate)
				else 0 --49823 pmill should not get here, but in case the minoption is not valid
			End

	 if @mincharge = 0
		BEGIN
			select @minadj = 0
			select @mindesc = ''		
			select @applymincharge = 'N'
			GOTO DOADJUSTMENTS --no minimum to apply
		END
	 
	select @sumlh = @sumcharges + @minacc
		
	if @sumlh < @mincharge 
		BEGIN
			select @minadj = @mincharge - @sumlh
			update @itemstorate 
				set minchargeallocation = case @applybestrate
					When 'Y' Then ROUND(@minadj * adjweightratio , 2)
					Else  ROUND(@minadj * Invoiceweightratio , 2)
					End
				Where lastcmdoninvoice = 'Y'
		END
	Else
		BEGIN
			select @minadj = 0
			select @mindesc = ''
			select @applymincharge = 'N'
			GOTO DOADJUSTMENTS --Minimum doesn't apply
		END

	 --make sure minimum allocations add up and adjust if needed
	 select @totalminallocation = SUM(isnull(minchargeallocation, 0)) from @itemstorate
	 if @totalminallocation <> @minadj 
		BEGIN
			select @adjforrounding = @minadj - @totalminallocation
			update @itemstorate
				set minchargeallocation = minchargeallocation + @adjforrounding
				where ivh_hdrnumber = @p_ivhhdrnumber
				and lastcmdoninvoice = 'Y'
		END
	 
	 select @mindesc = convert (varchar(20), @mincharge,  1) + ' Min Charge Adj.'
	 
DOADJUSTMENTS:
	IF (select count(distinct ord_hdrnumber) from @itemstorate) > 1 -- if there is only one invoice, then the work will be done in the app
		BEGIN --DOADJUSTMENTS
			If @howtoapply = 'ADJUST' and @applybestrate = 'Y'
				--determine information we need for making the adjustment
				BEGIN
					select @nextrec = max(itr_ident) from @itemstorate

					select @LTLDeficitQty = bestmethodqty 
						  ,@LTLDeficitCharge = bestmethodcharge
					from @itemstorate where itr_ident = @nextrec

					select @LTLDeficitUnits = min(unit) from @itemstorate where itr_ident <> @nextrec

				END
			
			--Loop through invoices and update
			select @nextivhhdr = min(ivh_hdrnumber)
			from @invoices
				
			WHILE  @nextivhhdr is not null
				BEGIN --Loop through all invoices
					If (@howtoapply = 'ADD-ADJUST') AND ((@applybestrate = 'N') Or (@applybestrate = 'Y' and @nextivhhdr <> @p_ivhhdrnumber))			
						BEGIN
							--Delete any previous adjustment record (only delete on current invoice if best rate does not apply)
							select @nextivdnbr = ivd_number  -- assume there is only one
							from invoicedetail
							where ivh_hdrnumber = @nextivhhdr
							and ivd_type = 'LI'
							and ivd_description  like '*Adj for %'

							if @nextivdnbr is not null
								BEGIN
									delete from invoicedetail 
									where ivd_number = @nextivdnbr
							  
									select @adjrevacc = 'Y' --we need to adjust revenue based accessorials and invoice header information 
								END			
						END --delete previous adjustment record for this invoice				

					If @applybestrate = 'Y' and @nextivhhdr <> @p_ivhhdrnumber
						 BEGIN
						 -- update the rates and charges on each commodity (except for current invoice which will be updated in app)
							select @nextivdnbr = min(ivd_number)
							from @itemstorate
							where ivh_hdrnumber = @nextivhhdr
							
							while @nextivdnbr is not null
								BEGIN
									If @howtoapply = 'ADJUST' 
										BEGIN
											update invoicedetail
											set ivd_rate = bestmethodrate
												,ivd_quantity = case copyrow
													-- 67383 when 'Y' then ivd_quantity + @LTLDeficitQty
													when 'Y' then ActualWeight + @LTLDeficitQty
													else  ActualWeight
													end
												,ivd_charge = case copyrow
													when 'Y' then bestmethodcharge + @LTLDeficitCharge
													else bestmethodcharge
													end
											from @itemstorate itr
											join invoicedetail on itr.ivd_number = invoicedetail.ivd_number
											where itr.ivd_number = @nextivdnbr
										END  --ADJUST update commodity invoicedetails
										
									If @howtoapply = 'ADD-ADJUST'
										BEGIN
										  update invoicedetail
										  set ivd_rate = bestmethodrate
											,ivd_charge = bestmethodcharge
										  from @itemstorate itr
										  join invoicedetail on itr.ivd_number = invoicedetail.ivd_number
										  where itr.ivd_number = @nextivdnbr								
										END --ADD-ADJUST update commodity invoicedetails
							
									select @nextivdnbr = min(ivd_number)  
									from @itemstorate
									where ivh_hdrnumber = @nextivhhdr
									and ivd_number > @nextivdnbr
									
									select @adjrevacc = 'Y' --we need to adjust revenue based accessorials and invoice header information 
								END --Next commodity invoicedetail record for the invoice
						END --update commodities

					If @nextivhhdr <> @p_ivhhdrnumber 
						BEGIN
							--Delete mileage based accessorials, except for current invoice 
							-- assumes all invoices have them and we need only one so keep the one on the current invoice 
							select @nextivdnbr = min(ivd_number)  -- assume there is only one
							from invoicedetail
							where ivh_hdrnumber = @nextivhhdr
							and ivd_unit in ('MIL','KMS','HUB')

							 while @nextivdnbr is not null
							   BEGIN
								  delete from invoicedetail
								  where ivd_number = @nextivdnbr

								  select @nextivdnbr = min(ivd_number)  -- assume there is only one
								  from invoicedetail
								  where ivh_hdrnumber = @nextivhhdr
								  and ivd_unit in ('MIL','KMS','HUB')
								  and ivd_number > @nextivdnbr
								  
								  select @adjrevacc = 'Y' --we need to adjust revenue based accessorials and invoice header information  
					          
							   END 
							-- don't think I need to worry about ivd_sequence on other details if hole is left
						END --delete mileage based accessorials

					If ((@applybestrate = 'N') Or (@applybestrate = 'Y' and @nextivhhdr <> @p_ivhhdrnumber))
					--Delete any previously applied minimum linehaul charges 
						BEGIN  
							select @nextivdnbr = ivd_number  -- assume there is only one
							from invoicedetail
							where ivh_hdrnumber = @nextivhhdr
							and ivd_type = 'LI'
							and cht_itemcode = 'MIN'
						     
							if @nextivdnbr is not null
							  BEGIN
								delete from invoicedetail 
								where ivd_number = @nextivdnbr
								
								select @adjrevacc = 'Y' --we need to adjust revenue based accessorials and invoice header information 
							  END
						END --delete minimum linehaul charge

					IF @applymincharge = 'Y' and ((@applybestrate = 'N') Or (@applybestrate = 'Y' and @nextivhhdr <> @p_ivhhdrnumber))
						BEGIN  
							--add minimum charge, allocated between all the invoices
							--current invoice will be upedated in app if best rate charge is applied; otherwise, the min is added here
							select @nextivdnbr = ivd_number  -- this detail has the minimum allocation for this invoice
									,@minadj = minchargeallocation
							from @itemstorate
							where ivh_hdrnumber = @nextivhhdr
							and lastcmdoninvoice = 'Y'
						     
							if @nextivdnbr is not null
								BEGIN
									--add the minimum after the last delivery
									select @lastdeliveryrow = max(ivd_sequence)
									from invoicedetail 
									where ivh_hdrnumber = @nextivhhdr
									and ivd_type = 'DRP'
									
									--move all the other invoicedetails down
									update invoicedetail 
									set ivd_sequence = ivd_sequence + 1
									where ivh_hdrnumber = @nextivhhdr
									and ivd_sequence > @lastdeliveryrow + 1
									
									--create the initial record using defaults from the MIN charge code, and information from the invoice header
									exec @newivdnum = getsystemnumber 'INVDET', ''
									select @ordhdrnumber = ord_hdrnumber from @itemstorate where ivd_number = @nextivdnbr	
									insert into invoicedetail (
										 ivd_number
										,ivd_sequence
										,ivh_hdrnumber
										,ord_hdrnumber
										,ivd_billto
										,cht_itemcode
										,ivd_description
										,ivd_type
										,cht_basisunit
										,ivd_unit
										,ivd_taxable1
										,ivd_taxable2
										,ivd_taxable3
										,ivd_taxable4
										,cht_lh_min
							--			,cht_lh_prn
										,cht_lh_rev
										,cht_lh_rpt
										,cht_lh_stl
										,cht_rollintolh
										,cht_class
										,ivd_glnum
										,ivd_sign
										,cmp_id
										,cmd_code
										,fgt_supplier
										,ivd_distance
										,ivd_wgt
										,ivd_count
										,ivd_volume
										,ivd_quantity_type
										,ivd_charge_type
										,ivd_rate_type
										,ivd_itemquantity
										,ivd_subtotalptr
										,ivd_ordered_count
										,ivd_ordered_loadingmeters
										,ivd_ordered_volume
										,ivd_ordered_weight
										,ivd_loadingmeters
										,ivd_loaded_distance
										,ivd_empty_distance
										,ivd_MaskFromRating
										) 
										(select
										 @newivdnum
										,@lastdeliveryrow + 1
										,@nextivhhdr
										,@ordhdrnumber
										,@billto
										,cht_itemcode
										,@mindesc
										,'LI'
										,cht_basisunit
										,cht_unit
										,cht_taxtable1
										,cht_taxtable2
										,cht_taxtable3
										,cht_taxtable4
										,cht_lh_min
							--			,cht_lh_prn
										,cht_lh_rev
										,cht_lh_rpt
										,cht_lh_stl
										,cht_rollintolh
										,cht_class
										,cht_glnum
										,cht_sign
										,'UNKNOWN'
										,'UNKNOWN'
										,'UNKNOWN'
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,0
										,'N'
										from chargetype
										where cht_itemcode = 'MIN'
										)
									
									--update information on the minimum row
									--copy some information from the last commodity row
									update invoicedetail 
									set invoicedetail.ivd_distunit = i2.ivd_distunit
										,invoicedetail.ivd_wgtunit = i2.ivd_rateunit
										,invoicedetail.ivd_countunit = i2.ivd_countunit
										,invoicedetail.ivd_volunit = i2.ivd_volunit
										,invoicedetail.ivd_reftype = i2.ivd_reftype
									from invoicedetail 
										inner join invoicedetail i2 on invoicedetail.ivd_number = @nextivdnbr
									where invoicedetail.ivd_number = @newivdnum
									
									--copy some information from the invoice header
									update invoicedetail
									set cur_code = invoiceheader.ivh_currency
										,ivd_revtype1 = invoiceheader.ivh_revtype1
										,ivd_car_key = invoiceheader.car_key
									from invoicedetail
										inner join invoiceheader on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
									where ivd_number = @newivdnum
									
									update invoicedetail
									set ivd_sign = 1
										,ivd_quantity = 1
										,ivd_rate = @minadj
										,ivd_charge = @minadj
										,ivd_unit = 'MIN'
										,ivd_rateunit = 'MIN'
										,ivd_fromord = 'A'
									where ivd_number = @newivdnum
									
									select @adjrevacc = 'Y' --we need to adjust revenue based accessorials and invoice header information 
								END
						END --apply min charge

					If @adjrevacc = 'Y' and (@nextivhhdr <> @p_ivhhdrnumber  or @applybestrate= 'N')
						BEGIN
							--adjust revenue based accessorials and invoice header information
							--if we are not applying a best method adjustment we need to adjust the current invoice as well
							--pmill 49823 need special handling for rev based accessorials flagged as roll into linehaul for minimum
								-- don't want min charge included in computation of linehaul charges
							Select @nextivdnbr = MIN(ivd_number)
							from @revaccessorials 
							where ivh_hdrnumber = @nextivhhdr
							
							While @nextivdnbr is not null
								BEGIN
									If @applybestrate = 'Y'
										select @sumlh = ISNULL(bestmethodcharge,0)
											,@sumcharges = ISNULL(adjcharge,0)
										from @revaccessorials
										where ivd_number = @nextivdnbr
									Else
										select @sumlh = ISNULL(quantity,0)
											,@sumcharges = ISNULL(charge,0)
										from @revaccessorials
										where ivd_number = @nextivdnbr									
										
									update invoicedetail
									set ivd_quantity = @sumlh
										,ivd_charge = @sumcharges
									from invoicedetail
									join (select unc_from,unc_to, unc_factor from unitconversion where unc_convflag = 'R') unc
										on ivd_unit = unc_from and ivd_rateunit = unc_to
									where ivd_number = @nextivdnbr
									
									select @nextivdnbr = MIN(ivd_number) 
									from @revaccessorials
									where ivh_hdrnumber = @nextivhhdr
									and ivd_number > @nextivdnbr
								
								END
							
							--first pass update based on primary, then do another pass including accessorials flagged as cht_lh_rev = 'Y'
							-- figure out new LH charges					
							select @sumLH  = sum( case (cht_primary + invoicedetail.cht_lh_rev)
							   when 'YY' then ivd_charge
									 else 0
									 end)
							from invoicedetail
							join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode 
							where ivh_hdrnumber = @nextivhhdr
					        
							 -- repair revenue based accessorial charges
							select @nextivdnbr = min(ivd_number)
							from invoicedetail
							join @revunits rev on invoicedetail.ivd_unit = abbr
							where ivh_hdrnumber = @nextivhhdr
							and ivd_type = 'LI'
							and cht_lh_min <> 'Y'
					 
							while @nextivdnbr is not null
								BEGIN -- repair next rev based accessorial loop
									update invoicedetail 
									set ivd_quantity = @sumlh
									,ivd_charge = round(@sumlh * ivd_rate * unc_factor,2) 
									from invoicedetail
									join (select unc_from,unc_to, unc_factor from unitconversion where unc_convflag = 'R') unc
										on ivd_unit = unc_from and ivd_rateunit = unc_to 
									where ivd_number = @nextivdnbr
									and ivd_quantity <> @sumlh

									select @nextivdnbr = min(ivd_number)
									from invoicedetail
									join @revunits rev on invoicedetail.ivd_unit = abbr
									where ivh_hdrnumber = @nextivhhdr
									and ivd_type = 'LI' 
									and cht_lh_min <> 'Y'
									and ivd_number >   @nextivdnbr 
								END  -- repair next rev based accessorial loop

							--pmill 49823 second pass, update rev based accessorials accounting for other accessorials flagged as cht_lh_rev = Y'
							select @sumLH  = sum( case (cht_primary + invoicedetail.cht_lh_rev)
							   when 'YY' then ivd_charge
							   when 'NY' then ivd_charge
									 else 0
									 end)
							from invoicedetail
							join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode 
							where ivh_hdrnumber = @nextivhhdr 

							select @nextivdnbr = min(ivd_number)
							from invoicedetail
							join @revunits rev on invoicedetail.ivd_unit = abbr
							where ivh_hdrnumber = @nextivhhdr
							and ivd_type = 'LI'
							and cht_lh_min = 'N'
							and cht_lh_rev = 'N'
					        
							while @nextivdnbr is not null
								BEGIN -- repair next rev based accessorial loop
									update invoicedetail 
									set ivd_quantity = @sumlh
									,ivd_charge = round(@sumlh * ivd_rate * unc_factor,2) 
									from invoicedetail
									join (select unc_from,unc_to, unc_factor from unitconversion where unc_convflag = 'R') unc
										on ivd_unit = unc_from and ivd_rateunit = unc_to 
									where ivd_number = @nextivdnbr
									and ivd_quantity <> @sumlh

									select @nextivdnbr = min(ivd_number)
									from invoicedetail
									join @revunits rev on invoicedetail.ivd_unit = abbr
									where ivh_hdrnumber = @nextivhhdr
									and ivd_type = 'LI' 
									and ivd_number >   @nextivdnbr 
									and cht_lh_rev = 'N'
								END  -- repair next rev based accessorial loop
							--end second pass repair rev based accessorials

							-- finally repair the invoice header totals
							-- add remark
							If @applybestrate = 'Y' 
							  select @remark = max(bestmethoddescription)
							  from @itemstorate
							  
							Else
								IF @applymincharge = 'Y'
									select @remark = @mindesc + ' ' + @ordlist
								Else
									select @remark = @ordlist

							--49823 pmill - include accessorial charges flagged as cht_lh_rev in linehaul charge
							--also adjust ivh_archarge and inv_revenue_pay fields
							  select @sumcharges = sum(ivd_charge)
							  ,@sumLH  = sum( case (cht_primary + invoicedetail.cht_lh_rev)
								 when 'YY' then ivd_charge
								 else 0
								 end)
								,@sumLHAdj  = sum( case (cht_primary + invoicedetail.cht_lh_rev)
								 when 'YY' then ivd_charge
								 when 'NY' then ivd_charge
								 else 0	
								 end)             
							  from invoicedetail
							  join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode 
							  where ivh_hdrnumber = @nextivhhdr

							  update invoiceheader
							  set ivh_charge = @sumLHadj
							  ,ivh_totalcharge = @sumcharges
							  ,ivh_remark = @remark
							  ,ivh_archarge = @sumcharges
							  ,inv_revenue_pay = @sumlh
							  where ivh_hdrnumber = @nextivhhdr
							  and (ivh_charge <> @sumLHAdj or ivh_totalcharge <> @sumcharges)
							
						END  --adjust revenue based accessorials and invoice header
					
					If @applybestrate = 'N' and @applymincharge = 'N' and @adjrevacc = 'N'
						--even if no adjustments are made to invoice, set the remarks to show which invoices were rated
						update invoiceheader
						set ivh_remark = @ordlist
						where ivh_hdrnumber = @nextivhhdr
					
					select @nextivhhdr = min(ivh_hdrnumber)
					from @invoices
					where ivh_hdrnumber > @nextivhhdr     		
				END  --next invoice
		END --DOADJUSTMENTS
/* make sure all the invoices are tagged with the order list */		
 if LEFT(@ordlist,4) = '[Ord' and (select count(*) from @itemstorate) > 1
    update invoiceheader set ivh_remark = (isnull(Ivh_remark,'') + ' ' + @ordlist)
    from @itemstorate itr
    join invoiceheader on itr.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
    where charindex(@ordlist,isnull(ivh_remark,'')) = 0
    
  
    
 --if @debugon = 'Y' select '## Final',* from @itemstorate 
 RETURNFROMPROC: 
 
   /****** If the best method charge is better than total charge resturn data    */
   /*  NOTE: need to delete any existing adj record or update it  
		Also need to add/delete minimum charge if needed 49823 pmill */
    if (select sum(isnull(charge,0)) from @itemstorate)
       > (select sum(isnull( bestmethodcharge,0)) from @itemstorate) 
       BEGIN
         select
         ord_hdrnumber
         ,ord_number
         ,fgt_number
         ,bestmethodqty
         ,bestmethodrate
         ,bestmethodcharge
         ,bestmethoddescription
         ,copyrow
         ,howtoapply = @howtoapply  -- added 
         ,Invoiceweightratio  -- added
         ,spreadamount
         ,ActualLTLWeight
         ,cmd_code
         ,lastcmdoninvoice
         ,minoption = @minoption  --49823 pmill
         ,mincharge = @mincharge --49823 pmill
		 ,minchargeallocation --49823 pmill 
		 ,mindesc = @mindesc  --49823 pmill
		 ,adjweightratio --49823 pmill   
         from @itemstorate 
         order by itr_ident
      END
   else 
       select
       ord_hdrnumber
       ,ord_number
       ,fgt_number
       ,bestmethodqty
       ,bestmethodrate
       ,bestmethodcharge
       ,bestmethoddescription
       ,copyrow
       ,howtoapply = ' '
       ,Invoiceweightratio 
       ,spreadamount
       ,ActualLTLWeight
       ,cmd_code
       ,lastcmdoninvoice
       ,minoption = @minoption  --49823 pmill
       ,mincharge = @mincharge --49823 pmill
       ,minchargeallocation --49823 pmill
       ,mindesc = @mindesc  --49823 pmill
       ,adjweightratio --49823 pmill
       from @itemstorate 
       where 0 = 1 
 

  END

GO
GRANT EXECUTE ON  [dbo].[LTLBestMethod01] TO [public]
GO
