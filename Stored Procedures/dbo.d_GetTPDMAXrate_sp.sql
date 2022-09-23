SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create procedure [dbo].[d_GetTPDMAXrate_sp] @p_ord int,@p_rateEffDate datetime  
as  
  
/**  
 *   
 * NAME:  
 * dbo.d_GetTPDMAXrate_sp  
 *  
 * TYPE:  
 * Stored Procedure  
 *  
 * DESCRIPTION:  Customer MIZAR rating option  
 * For Billing tariff table rating option TPDMAX. Determine the highest PUP city to DRP city  
 *    rate.  Pool all consolidated orders on a move that have tariffs tagged as TPDMAX.  For each order  
 *    determine the rates to every delivery stop on all orders on the move (in the pool) using the tariffs  
 *    for the bill to company on the PUP city order. Do this for all orders on the move and then determine the highest   
 *    rate, return that and use it. Called by nvo_tariff_engine2 function of_gettablerate  
 *  
 *       Move  Order    Billt To      PUP city    PUP city       DRP city       DRP city      
 *       123    444     ABC          Cleveland,OH  Toledo,OH     Detroit,MI     Grand Rapids,MI  
 *       123    565     ABC          Cleveland,OH                Toledo,OH  
 *       123    602     CMJ          Cleveland, OH               Elyria,OH  
 *       123    403     LOP          Toledo,OH                   Southfield,MI,MI  
 *     Assume TPDMAX rates exist for all order but 602. We process every order on the move except 602 like the following  
 * ... For order 444 (look at the PUP cities on 444 to each of the DRP cities on all other orders on the move except 602)  
 *     Determine the rate for  Cleveland to Detroit,MI  
 *                                       to Grand Rapids, MI  
 *                                       to Toledo,OH  
 *                                       to Southfield,MI  
 *              then           Toledo,OH to Detroit,MI  
 *                                       to Grand Rapids,MI  
 *                                       to Toledo,OH  
 *                                       to SOuthfield,MI  
 *    from among the tariffs for bill to company ABC (save the highest)  
 *    Do the same for orders 565 and 403  
 *    Return the highest rate from all combinations on all orders as the rate for order 444 or 565 or 403  
 *   
 *    When the first order is rated, a new field ord_lastratedate is stamped with the current date/time  
 *    When the next order is rated, we look for that first order. If we find an invoice (first) or order (second)  
 *    on the move that has this date set within the threshold set by a new GI setting RateHoldHours, we return that  
 *    rate rather than figuring it all out again. By default the threshold is 24 hours but may be set up to 168 (1 week)  
 *  
 * RETURNS:  
 *   Tar_number int  
 *   tar_tariffnumber varchar(12)  
 *   tar_tariffitem  varchar(12)  
 *   tar_rate money  
 *   tar_unit varchar(6)  
 *   tar_rateunit varchar(6)  
 *   ord_lastratedate datetime  
 *   description - a descritption for the ord_description or ivd_description field  
 *   
 * RESULT SETS:   
 *   
 *  
  * PARAMETERS:  
 * 001 - @p_ord int  
 *       The order header number of the order currently being rated   
 *       
 * 002 - @p_rateffectivedate datetime date being used to select a tariff  
 *  
 *   
 * REFERENCES:   
 *                
 * Calls001: d_tar_gettariffrate_sp     
 *  
 * CalledBy001: nvo_tariff_engine2    
 *  
 *   
 * REVISION HISTORY:  
 * 12/20/07 PTS 34628 - DPETE new  
 *  2/14/07 PTS 34628 - DPETE found customer rates are Dest city to Origin city not vice versa 
 * 44518 DPETE change to d_tar_gettariffrate return set was not refelcted in clall to proc from this proc
 **/  
  
  
/* NOTE add field to orderheader indicating last date on which this rating was done and the rate   
Business Rules  
   1) (for speed) if any of the orders on the trip using this special rating (flag on tariff index)  
       has been rated within the period a tariff is to be held (GI hours with default 24 hours)  
       use it as the rate for all others. Cannot hold a tariff for more than one week.   
   2) Assume all of the tariffs tagged with the special rating flag have only the billto on the index and  
      have table rates with Origin cities as rows and Dest cities as columns.  
   3) Each billto may have more than one tariff participating in the pool. The number of cities is very   
      large so they will be spread over multiple tariffs.  
   4) For each PUP stop city on an order, determine the rate to every DRP stop on the trip (for those orders  
      where a tariff exists for the bill to compnay with a tblratingoption TPDMAX)  
  
      to do this process multiple loops  
  
      From a list of orders & Billto's on the same move as the order being rated (assumes no cross dock)   
  
      Loop thru each bill to company on the trip who has a tariff with tablratingoption TPDMAX (because this selects a group of tariffs)  
        Loop through each order for this bill to on the trip  
          Loop through each PUP stop city on this order  
             Loop through each DRP stop city on the trip for the eligeable orders  
               Loop through each tariff for the current bill to  
                   Call d_tar+gettariffrate to get the tariff (if any)  
                   Save the largest rate  
*/  
  
--declare @t_ords table (ord_hdrnumber int, ord_lastratedate datetime,ord_billto varchar(8),ord_revtype1 varchar(6),ord_revtype4 varchar(6),ord_startdate)  
create table #t_ords (ord_hdrnumber int NULL, ord_lastratedate datetime NULL,ord_billto varchar(8)NULL)  
create table #t_billtotarnums (tar_number int NULL,rowbasisflag char(1) NULL)  
--declare @t_drpstops table (stp_city varchar(12) NULL)  
create table #t_drpstops (stp_city  int NULL)  
/* this table must match the return set from the d_tar_gettariffrate */  
/* 44518 add return values */
/*create table #t_rates(tra_rate money NULL,RowNum int NULL,ColNum int NULL,RowSeq int NULL,ColSeq int NULL,RowVal money NULL,ColVal money NULL, ValidCount int NULL) */ 
create table #t_rates(tra_rate money NULL
,RowNum int NULL
,ColNum int NULL
,RowSeq int NULL
,ColSeq int NULL
,RowVal money NULL
,ColVal money NULL
,ValidCount int NULL
,tra_rateasflat char(1) null
,tra_minqty char(1) null
,tra_minrate money null
,tra_mincharge money null
,tra_billmiles money null
,tra_paymiles money null
,tra_standardhours money null) 
        
create table #t_ratedcombos(PUPcity int NULL,DRPcity int NULL)  
  
declare @v_next_tarnum int,@v_next_ordnum int,  @v_nextDRP int, @v_stparrivaldate datetime, @v_mov int, @v_rateholdhours tinyint  
declare @v_origincity varchar(10),@v_destcity varchar(10),@v_highrate money, @v_rate money, @v_ordratedate datetime,@v_oneweekagodate datetime  
declare @v_earliestratedate datetime, @v_ratedordnumber int,@v_nextbillto varchar(8)  
declare @v_batchnbr int, @v_log char(1),@v_NextOrdPUP int,@v_nextord int,@v_nexttarnum int  
declare @v_MAxtarnumber int,@v_Maxtartariffnumber varchar(12),@v_maxtartariffitem varchar(12),@v_Maxrateunit varchar(6),@v_maxunit varchar(6)  
declare @V_Octynmstct varchar(20),@v_dctynmstct varchar(20),@v_maxratePUP varchar(20),@v_maxrateDRP varchar(20),@v_key int  
declare @v_MaxORDpup int,@v_maxDRP int  ,@v_nextrowbasis char(1), @v_comborated char(1)
  
  
/* private option for debugging, turn on logging with GI setting, search errlog for '## start%'   */  
select @v_log = left(gi_string1,1) from generalinfo where gi_name = 'debugMizar'  
select @v_log = isnull(@v_log,'N')  
  
  
select @v_oneweekagodate = dateadd(hh,-169,getdate())  -- plus one hour to allow holding rate for one week  
/* default time for re using a rate for an order on the move is 24 hours, can override with private GI setting up to one week ago */  
select @v_rateholdhours = convert(tinyint,isnull(gi_string1,24)) from generalinfo where gi_name = 'RateHoldHours'  
select @v_rateholdhours = isnull(@v_rateholdhours,24)  
if @v_rateholdhours = 0 select @v_rateholdhours = 24   
If @v_rateholdhours > 168  select @v_rateholdhours = 168   
select @v_earliestratedate = dateadd(hh, -1 * @v_rateholdhours,getdate())  
  
select @v_mov = mov_number  -- assuming all orders on a single move!!!!!  
from orderheader where ord_hdrnumber = @p_ord  
-- select @v_log = 'Y'  
If @v_log = 'Y'  
  BEGIN  
   EXEC  @v_batchnbr =  getsystemnumberblock 'BATCHQ', NULL, 1  
     INSERT INTO tts_errorlog (   
  err_batch,   
  err_user_id,   
  err_icon,   
  err_message,   
  err_date,   
  err_number)  
  VALUES (  
  @v_batchnbr,  
  'd_GetTPDMAXrate_sp',   
  '1',   
  '## Start rating order '+convert(varchar(10),@p_ord)+' hold rate from '+convert(varchar(8),@v_rateholdhours)+' hours ago',   
  GETDATE ( ),  
  1 )   
  END      
/* in order to save rating time, if any of the orders on the move has been rated within the last 24 (or GI RateHoldHrs) hours, use that rate */  
/* only orders with tariffs having the special flag qualify. May be other orders on the move that  do not qualify */  
/*  
select ord_number,ord_hdrnumber,ord_billto,trk_billto,mov_number  
from orderheader  
join tariffkey on ord_billto = trk_billto  
join tariffheader on tariffkey.tar_number = tariffheader.tar_number  
where mov_number = 6693  
*/  
insert into #t_ords  
select distinct ord_hdrnumber, isnull(ord_lastratedate,@v_oneweekagodate),ord_billto  
from orderheader   
join tariffkey on ord_billto = trk_billto  
join tariffheader on tariffkey.tar_number = tariffheader.tar_number  
where mov_number = @v_mov  
and @p_rateEffDate between trk_startdate and trk_enddate  
and isnull(tar_tblratingoption,'?') = 'TPDMAX'  
  
/* this should never happen, no rates exist for the orders on this move with the flag */  
If @@rowcount = 0  
 BEGIN  
   return  
 END  
  
  
select @v_ordratedate = max(isnull(ord_lastratedate,'19500101 00:00')) from #t_ords  
/* hoped to use existing rate is exists, but is not working  */
if @v_ordratedate > @v_earliestratedate  
  BEGIN  -- one of the orders on the move is rated within  the 'rate is good' threshold , use that rate loop  
    select @v_ratedordnumber = min(ord_hdrnumber) from #t_ords where ord_lastratedate = @v_ordratedate  
    if exists (select 1 from invoicedetail where ord_hdrnumber = @v_ratedordnumber and ivd_type = 'SUB'  
               and ivd_description like 'For route%')  
      BEGIN  
        select @v_key = max(ivd_number) from invoicedetail   
                where ord_hdrnumber = @v_ratedordnumber   
                and ivd_type = 'SUB'  
                and ivd_description like 'For route%'  
        select invoicedetail.tar_number,invoicedetail.tar_tariffnumber,invoicedetail.tar_tariffitem,ivd_rate,ivd_unit,ivd_rateunit,ord_lastratedate,isnull(ivd_description,'')  
        from invoicedetail   
        join orderheader on invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber  
        where ivd_number = @v_key  
      END 
    else  
      BEGIN  
        select tar_number,tar_tarriffnumber,tar_tariffitem,tra_rate = ord_rate,tar_unit = ord_unit,tar_rateunit = ord_rateunit,ord_lastratedate,isnull(ord_description,'')  
        from orderheader where ord_hdrnumber = @v_ratedordnumber  
      END  
  
      
    If @v_log = 'Y'  
      BEGIN  
         INSERT INTO tts_errorlog (   
      err_batch,   
      err_user_id,   
      err_icon,   
      err_message,   
      err_date,   
      err_number)  
      VALUES (  
      @v_batchnbr,  
      'd_GetTPDMAXrate_sp',   
      '1',   
      'Use rate from order '+convert(varchar(10),@v_ratedordnumber),   
      GETDATE ( ),  
      1 )   
      END     
 Return  
  
  END  -- one of the orders on the move is rated within  the 'rate is good' threshold , use that rate loop  
else 

  BEGIN  -- determine the rate loop  
    /* build tables of all distinct DRP stops on the move, must rate each PUP on orders for a bill to (set of tariffs) to every DRP */  
      
    insert into #t_DRPstops  
    select distinct stp_city  
    from stops  
    join #t_ords on stops.ord_hdrnumber = #t_ords.ord_hdrnumber   
    where stp_type = 'DRP'   
  
    select @v_highrate = 0.0  
  
    select @v_nextbillto = min(ord_billto) from #t_ords  
    while @v_nextbillto is not null  
    BEGIN  -- BILL TO CUSTOMER LOOP , used to select the group of tariffs set up for each bill to company on this trip subject to TPDMAX  
      truncate table #t_ratedcombos  
      truncate table #t_billtotarnums  
      -- get all TPDMAX (trip pickup delivery max) tariffs for the bill to so we know which rates to check  
      Insert into #t_billtotarnums  
      select k.tar_number ,  rowbasisflag = left(tar_rowbasis,1) 
      from tariffkey k  
      join tariffheader h on k.tar_number = h.tar_number  
      where  trk_billto = @v_nextbillto                      
      and trk_startdate <= @p_rateEffDate  
      and k.trk_enddate >= @p_rateEffDate  
      and tar_tblratingoption = 'TPDMAX'   
      -- for each order billed to the current billto company, go through all of its PUP stops  
      select @v_nextord = min(ord_hdrnumber) from #t_ords where ord_billto = @v_nextbillto  
      while @v_nextord is not null  
        BEGIN  -- ORDERS FOR BILL TO LOOP  
    select @v_NextOrdPUP = min(stp_city)   
         from stops   
         where stops.ord_hdrnumber = @v_nextord and  
         stp_type = 'PUP'   
  
         while @v_nextOrdPUP is not null  
         BEGIN  -- ORDER PUP STOPS LOOP  
           -- for each PUP stop on an order rate to  each DRP stop on the move (for all bill to companies rated by TPDMAX)  
           select @v_nextDRP = min(stp_city) from  #t_drpstops  
           while @v_nextDRP is not null  
           BEGIN  -- DROP STOPS L0OP  
             --Do not process the same PUP-DRP city combo more than once for a bill to (set of tariffs)   
             if exists (select 1 from #t_ratedcombos where PUPcity = @v_nextOrdPUP and DRPcity = @v_nextDRP) GOTO NextDRPloop
             select @v_comborated = 'N' 
                 
             select @v_nexttarnum = min(tar_number) from #t_billtotarnums  
             while @v_nexttarnum is not null  
             BEGIN  -- TARIFF NUMBERS LOOP    
               truncate table #t_rates
               select @v_Nextrowbasis = min(rowbasisflag) from #t_billtotarnums where tar_number = @v_nexttarnum  
               If @v_nextrowbasis = 'O' 
                  insert into #T_rates  
                  exec d_tar_gettariffrate_sp @v_nexttarnum,@v_NextOrdPUP,0,@v_nextDRP,0,2,@p_rateEffDate  
               else
                  insert into #T_rates  
                  exec d_tar_gettariffrate_sp @v_nexttarnum,@v_nextDRP,0,@v_NextOrdPUP,0,2,@p_rateEffDate  
               If (select count(*) from #t_rates ) > 0 Select @v_comborated = 'Y'
--  select '#',@v_comborated,@v_NextOrdPUP,@v_nextDRP ,c1.cty_nmstct,c2.cty_nmstct from city c1,city c2 where c1.cty_code =@v_NextOrdPUP and c2.cty_code =  @v_nextDRP
--select ')',* from #t_rates
               select @v_rate = max(tra_rate) from #t_rates  
               -- record the fact that this combo has already been rated for this bill to company  
               insert into #t_ratedcombos(PUPcity,DRPCity) Values(@v_NextOrdPUP,@v_nextDRP)  
               If @v_log = 'Y'  
                 BEGIN  
                    SELECT @V_RATE = ISNULL(@V_RATE,0.0)  
                    select  @V_Octynmstct = substring(cty_nmstct,1,20) from city where cty_code = @v_NextORDpup  
                 select  @v_dctynmstct = substring(cty_nmstct,1,20) from city where cty_code = @v_NextDRP  
  
                    INSERT INTO tts_errorlog (   
                 err_batch,   
                 err_user_id,    
                 err_message,   
                 err_date,   
                 err_number)  
                 VALUES (  
                 @v_batchnbr,  
                 'd_GetTPDMAXrate_sp',    
                 'Evaluate bill to '+@v_nextbillto +' rate for ORDER '+CONVERT(VARCHAR(10),@v_nextord) +' tar # '+CONVERT(VARCHAR(10),@v_nexttarnum)+'from '+@V_Octynmstct+' to '+@V_Dctynmstct+' rate '+convert(VARCHAR(10),@v_rate),   
                 GETDATE ( ),  
                 1 )   
                 END       
               if @v_rate is not null and @v_rate > @v_highrate    
                 BEGIN  
                   select @v_highrate = @v_rate  
              ,@v_maxtarnumber = @v_nexttarnum   
                          ,@v_MaxORDpup = @v_nextordPUP  
                          ,@v_maxDRP    = @v_NextDRP  
                 END  
  
/*  considered getting the rate myself but decided enhancement to cells will be coded into d_tar proc, want to keep up  
    with any enhancements to cell processing  
             select @v_rate = max(tra_rate)j   
             from tariffrate r  
             -- all tariffs for this bill to that have the Origin city matching the current origin  
             join (Select tar_number   
                    from tariffrowcolumn  
                    join @t_billtotarnums  
                   where trc_rowcolumn = 'R'  
                   and trc_matchvalue = @v_origincity ) col on r.tar_number = col.tar_number  
             -- all tariffs for this bill to that have the Dest city matching the current dest  
             join (Select tar_number   
                   from tariffrowcolumn  
                   join @t_billtotarnums  
                   where trc_rowcolumn = 'C'  
                   and trc_matchvalue = @v_destcity) row on r.tar_number = row.tarnumber  
             where   
                 trc_number_row = row.trc_number  
             and trc_number_col = col.trc_number  
  
             if @v_rate > @v_highrate   select @v_highrate = @v_rate  
  */        
               select @v_nextTarNum = min(tar_number) from #t_billtotarnums where tar_number > @v_nextTarNum   
  
             END -- TARIFF NUMBERS LOOP  
             NextDRPloop:
             if @v_comborated = 'N' return  /* ##### NO RATE FOUND ON ONE COMBO ##### */
            --select 'COMBORATED' ,@v_comborated,@v_nextordpup,@v_nextdrp            
            select @v_nextDRP =min(stp_city) from  #t_drpstops where stp_city > @v_nextDRP  
  
           END  -- DROP STOPS LOOP  
           select @v_NextOrdPUP = min(stp_city) from stops where ord_hdrnumber = @v_nextord and stp_type = 'PUP' and stp_city > @v_NextOrdPUP  
               
         END   -- ORDER PUP STOPS LOOP  
         select @v_nextord = min(ord_hdrnumber) from #t_ords where ord_billto = @v_nextbillto and ord_hdrnumber > @v_nextord   
       END  -- ORDERS FOR BILL TO LOOP  
       select @v_nextbillto = min(ord_billto) from #t_ords where ord_billto > @v_nextbillto  
    END   --BILL TO CUSTOMER LOO  
  END  -- determine the rate loop  
select   
@v_Maxtartariffnumber = tar_tarriffnumber  
,@v_maxtartariffitem = tar_tariffitem  
,@v_Maxrateunit = cht_rateunit  
,@v_maxunit = cht_unit  
From tariffheader where tar_number  = @v_maxTarnumber  
  
select  @V_maxratePUP = substring(cty_name,1,17)+','+substring(cty_state,1,2) from city where cty_code = @v_MaxORDpup  
select  @v_maxrateDRP = substring(cty_name,1,17)+','+substring(cty_state,1,2) from city where cty_code = @v_MaxDRP  
  
Select  TarNumber = @v_MAxtarnumber, tar_Tariffnumber = @v_Maxtartariffnumber  
  ,tar_tariffitem = @v_maxtartariffitem  
  , tar_rate = @v_highrate  
  ,tar_unit = @v_maxunit  
  , tar_RateUnit = @v_Maxrateunit  
  , ord_lastratedate = getdate()  
  , Description = 'For route '+@V_maxratePUP+' - '+@V_maxrateDRP  
  
drop table #t_ords   
drop table #t_drpstops   
drop table #t_rates   
drop table #t_ratedcombos  
  
GO
GRANT EXECUTE ON  [dbo].[d_GetTPDMAXrate_sp] TO [public]
GO
