SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROC [dbo].[DeterminePremiumDates] @p_type varchar(10), @p_key int, @p_commasepdates varchar(500) , @p_tarnum int
          
AS   
/*  Returns a list of distinct dates from either the order (type = ORD, key = ord-hdrnumber) or leg (type = LEG
    key = lgh_number) or from the passed list of dates  where the arrivaldate for a pickup or a delivery was on a weekend or holiday.
    Must pass the tar_number because the holdiay table to use (if any) is on the tariffheader. This velue matches the holiday_group
    on the holidays table for determining the holiday status. The tar_number argument also helps by only looking for those
    types of premium days that have rows (or cols) on the tariff. Assume you would never have a tariff with premium days on both rows and columns.
    
    WHen an order is being pre rated in Order Entry (can;t assume antyhing is saved, the stop arrivaldates ar passed as a 
    comma separted list . The @p_type will be MANUAL and p_key will be zero.  WHen rating form DIspatch or invoicing where the trip is 
    saved, the p_type will be ORD and the p_key the ord_hdrnumber.  The otpion for passing the type LEG is for possible use
    in Settlements.
    
    
    created 10/27/10 DPETE PTS 53794
*/
declare @v_rateby varchar(10),@v_billto varchar(8),@v_movnumber int,@V_holidaytable varchar(6)
declare @stopdates table (stopdate datetime, dayofweek smallint, isweekend char(1) null, isholiday char(1) null, isholidayweekend char(1), issaturday char(1), issunday char(1)
 ,ismonday char(1), istuesday char(1), iswednesday char(1), isthursday char(1), isfriday char(1), Stopcount int )
declare @tempdates table (passeddate datetime)
declare @v_Premdaysontariff table (premday varchar(255))

select @v_holidaytable = ISNULL(tar_holiday_group,'')  from tariffheader where tar_number = @p_tarnum

IF exists (select 1 from tariffheader where tar_number = @p_tarnum and tar_rowbasis = 'PREMDA')
  INSERT into @v_Premdaysontariff
  select case isnull(trc_multimatch,'') when '' then trc_matchvalue + ';' else trc_multimatch end
  from tariffrowcolumn
  where tar_number = @p_tarnum
  and trc_rowcolumn = 'R'
ELSE
  INSERT into @v_Premdaysontariff
  select case isnull(trc_multimatch,'') when '' then trc_matchvalue + ';' else trc_multimatch end
  from tariffrowcolumn
  where tar_number = @p_tarnum
  and trc_rowcolumn = 'C'
  
If @p_type = 'MANUAL' 
  SELECT @v_rateby = 'ORDMANUAL'

If @p_type = 'ORD'  -- billing rates given the ord_hdrnumber on the invoice
  BEGIN
   If exists (select 1 from invoiceheader where ord_hdrnumber = @p_key)
     select @v_rateby = ISNULL(cmp_invoiceby,'ORD'),@v_billto = ivh_billto,@v_movnumber = mov_number
     from invoiceheader join company on ivh_billto = cmp_id
     where ivh_hdrnumber = (select min(ivh_hdrnumber)
     from invoiceheader where ord_hdrnumber = @p_key)
    else
     select @v_rateby = ISNULL(cmp_invoiceby,'ORD'),@v_billto = ord_billto,@v_movnumber = mov_number
     from orderheader join company on ord_billto = cmp_id
     where ord_hdrnumber = @p_key
 END
 If @p_type = 'LEG'  -- for settlements (future)
   BEGIN
     select @v_rateby = 'LEG'
   END
 

if @v_rateby = 'MOV'  -- for billing where we invoice by MOV
 insert into @stopdates
 select (CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME)    )
 ,DATEPART(dw,stp_arrivaldate) 
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,count(*)
 from stops
 where mov_number = @v_movnumber
 and stops.ord_hdrnumber > 0 
 and stp_type in ('PUP','DRP')
 group by CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME) ,DATEPART(dw,stp_arrivaldate)

if @v_rateby = 'MOVCON'  -- for billing where we invoice by MOVCON
 insert into @stopdates
 select (CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME)    )
 ,DATEPART(dw,stp_arrivaldate) 
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,count(*)
 from stops
 join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
 where stops.mov_number = @v_movnumber
 and orderheader.ord_billto = @v_billto
 and stops.ord_hdrnumber > 0 
 and stp_type in ('PUP','DRP')
 group by CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME) ,DATEPART(dw,stp_arrivaldate)
 
if @v_rateby = 'ORD'  -- for billign where we invoice the order
 insert into @stopdates 
 select (CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME)    )
 ,DATEPART(dw,stp_arrivaldate) 
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,count(*)
 from stops 
 where ord_hdrnumber = @p_key
 and stp_type in ('PUP','DRP')
 Group by CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME) ,DATEPART(dw,stp_arrivaldate)
 
 if @v_rateby = 'LEG'  -- used for settlements rating
 insert into @stopdates 
 select (CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME)    )
 ,DATEPART(dw,stp_arrivaldate) 
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,'N'
 ,count(*)
 from stops 
 where lgh_number = @p_key
 and stp_type in ('PUP','DRP')
 group by CAST(FLOOR(CAST(stp_arrivaldate AS FLOAT)) AS DATETIME) ,DATEPART(dw,stp_arrivaldate)

If @v_rateby = 'ORDMANUAL'
  BEGIN
   INSERT into @tempdates (passeddate)
   SELECT  * FROM CSVStringsToTable_fn(@p_commasepdates) 
  
   INSERT into @stopdates
   select (CAST(FLOOR(CAST(passeddate AS FLOAT)) AS DATETIME)    )
   ,DATEPART(dw,passeddate) 
   ,'N'
   ,'N'
   ,'N'
   ,'N'
   ,'N'
   ,'N'
   ,'N'
   ,'N'
   ,'N'
   ,'N'
   ,count(*)
   from @tempdates 
   group by CAST(FLOOR(CAST(passeddate AS FLOAT)) AS DATETIME) ,DATEPART(dw,passeddate) 
  END 


/* only tag the premium days that the tariff is looking for */
If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';SAT;',';' + premday) > 0)
  UPDATE @stopdates
  SET issaturday = (case dayofweek when 7 then 'Y'  else 'N' end)

If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';SUN;',';' + premday) > 0)
  UPDATE @stopdates
  SET  issunday = (case dayofweek when 1 then 'Y'  else 'N' end)


If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';WKND;',';' + premday) > 0)

  UPDATE @stopdates
  SET isweekend = (case dayofweek when 1 then 'Y' when 7 then 'Y' else 'N' end)
  
If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';MON;',';' + premday) > 0)
  UPDATE @stopdates
  SET  ismonday = (case dayofweek when 2 then 'Y'  else 'N' end)
     
If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';TUE;',';' + premday) > 0)
  UPDATE @stopdates
  SET  istuesday = (case dayofweek when 3 then 'Y'  else 'N' end)
    
If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';WED;',';' + premday) > 0)
  UPDATE @stopdates
  SET  iswednesday = (case dayofweek when 4 then 'Y'  else 'N' end)
    
If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';THU;',';' + premday) > 0)
  UPDATE @stopdates
  SET  isthursday = (case dayofweek when 5 then 'Y'  else 'N' end)
    
If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';FRI;',';' + premday) > 0)
  UPDATE @stopdates
  SET  isfriday = (case dayofweek when 6 then 'Y'  else 'N' end)

If @v_holidaytable > ''
  BEGIN
    If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';HOL;',';' + premday) > 0)
      UPDATE @stopdates
      SET isholiday = 'Y'
      FROM @stopdates sd
      join holidays on stopdate = holiday and holiday_group = @v_holidaytable
      
      If exists (select 1 from @v_Premdaysontariff pdays where CHARINDEX(';HOLWKND;',';' + premday) > 0)
      UPDATE @stopdates
      SET isholidayweekend = (case dayofweek when 1 then 'Y' when 7 then 'Y' else 'N' end)
      FROM @stopdates sd
      join holidays on stopdate = holiday and holiday_group = @v_holidaytable

  END

select stopdate, dayofweek,isweekend, isholiday, isholidayweekend, issaturday, issunday, ismonday, istuesday, iswednesday, isthursday, isfriday, @p_key keyvalue,stopcount from @stopdates
where isweekend = 'Y' or isholiday = 'Y' or isholidayweekend = 'Y' or issaturday = 'Y' or issunday = 'Y' or ismonday = 'Y' or istuesday = 'Y' or iswednesday = 'Y'or isthursday = 'Y' or isfriday = 'Y'
order by stopdate
GO
GRANT EXECUTE ON  [dbo].[DeterminePremiumDates] TO [public]
GO
