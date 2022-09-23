SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[IntnlBillingRuleFirstLastStops] @p_ordhdrnumber int
As  
/*   
Created 8/19/10 SR 51802 DPETE depending on GI option return the first billable (or any billable or non billable) stop info
and the last billable or last bill or non bill stop in the domestinc countr for an order
These may be used for computing miles only within the domestic country or for substituting the shipper or consingee with
the first (or last) stop in the domestic country

string2 of GI  ApplyIntnlBIllingRule determines what country is considered domestic
string3 of GI  ApplyIntnlBIllingRule set to INSIDE/BILLABLE indicates only billable stops are considered, INSIDE/ALL (default) means all stops
   (note INSIDE just in case we have to deal with OUTSIDE (last stop before entering the domesting country, first stop on leaving the 
      domestic country in future)
 
*/ 
Declare @DomesticCountry varchar(50),@billto varchar(8)
Declare @FirstStopSeq int, @LastStopSeq int ,@Origindate datetime, @Destdate datetime,@workdate  datetime
declare @GIStopTYpeOption varchar(30)
Declare @moves table (mov_number int)
declare @stopinfo table (FirstOrLast char(1),cmp_Id varchar(8),stp_city int, stp_event varchar(6),stp_arrivaldate datetime,stp_number int,stp_zipcode varchar(10))

Select @DomesticCountry = rtrim(gi_string2),
@GIStopTypeOption = rtrim(gi_string3)
From generalinfo 
Where gi_name = 'ApplyIntnlBillingRule'
If @DomesticCountry is null select @DomesticCountry = 'USA'  --default
If not exists (select 1 from statecountry where stc_country_c = @DomesticCountry) select  @DomesticCountry = 'USA'
If @GIStopTypeOption is null or (@GIStopTypeOption <> 'INSIDE/BILLABLE' and @GIStopTypeOption <> 'INSIDE/ALL') 
   select @GIStopTypeOption = 'INSIDE/ALL'  -- default

if not exists (select 1 from invoiceheader where ord_hdrnumber = @p_ordhdrnumber)
   select @billto = ord_billto from orderheader where ord_hdrnumber = @p_ordhdrnumber
else
   select @billto = ivh_billto from invoiceheader where ivh_hdrnumber =
    (select min(ivh_hdrnumber) from invoiceheader where ord_hdrnumber = @p_ordhdrnumber)

Insert into @moves
select distinct mov_number from stops
where ord_hdrnumber = @p_ordhdrnumber

/* Find the first billable stop on the order  (sets the boundaries of the stops we look at) */
select @FirstStopSeq = min(stp_sequence)
from stops
join eventcodetable on stops.stp_event = eventcodetable.abbr and ect_billable = 'Y'
where ord_hdrnumber = @p_ordhdrnumber

/* Find the last billable stop on the order */
select @LastStopSeq = max(stp_sequence)
from stops
join eventcodetable on stops.stp_event = eventcodetable.abbr and ect_billable = 'Y'
where ord_hdrnumber = @p_ordhdrnumber

/* find the  arrivaldate of the first billable stop (sets the boundaries of the stops we look at) */
  select @Origindate = stp_arrivaldate
  from stops
  where ord_hdrnumber = @p_ordhdrnumber
  and stp_sequence =  @FirstStopSeq

/* find the arrivaldate of the last billable stop  (sets the boundaries of the stops we look at)*/
select  @DestDate = stp_arrivaldate
from stops
where ord_hdrnumber = @p_ordhdrnumber
and stp_sequence =  @LastStopSeq

/* get first stop in domestic country according to rules */
If @GIStopTypeOption = 'INSIDE/BILLABLE'
  BEGIN
   Select @workdate = Min(stp_arrivaldate)
   From @moves moves
   join stops on moves.mov_number = stops.mov_number
   join eventcodetable on stops.stp_event = eventcodetable.abbr and ect_billable = 'Y'
   join statecountry on stops.stp_state = statecountry.stc_state_c
   where stp_arrivaldate between @origindate and @destDate
   and (stops.ord_hdrnumber = @p_ordhdrnumber) 
   and stops.ord_hdrnumber > 0
   and stc_country_c = @DomesticCountry

   Insert into @stopinfo
   Select top 1 'F' FirstOrLast
   ,cmp_id
   ,stp_city
   ,stp_event
   ,stp_arrivaldate
   ,stp_number
   ,stp_zipcode
   From @moves moves
   join stops on moves.mov_number = stops.mov_number
   join eventcodetable on stops.stp_event = eventcodetable.abbr and ect_billable = 'Y'
   join statecountry on stops.stp_state = statecountry.stc_state_c
   WHere stp_arrivaldate = @WorkDate
   and (stops.ord_hdrnumber = @p_ordhdrnumber) 
   and stops.ord_hdrnumber > 0
   and stc_country_c = @DomesticCountry
   order by stp_sequence -- top 1 / order by overkill???
   
  END
If @GIStopTypeOption = 'INSIDE/ALL'
  BEGIN
   Select @workdate = Min(stp_arrivaldate)
   From @moves moves
   join stops on moves.mov_number = stops.mov_number
   join eventcodetable on stops.stp_event = eventcodetable.abbr 
   join statecountry on stops.stp_state = statecountry.stc_state_c
   where stp_arrivaldate between @origindate and @destDate
   and (stops.ord_hdrnumber = @p_ordhdrnumber or stops.ord_hdrnumber = 0) 
   and stc_country_c = @DomesticCountry

   Insert into @stopinfo
   Select top 1 'F' FirstOrLast
   ,cmp_id
   ,stp_city
   ,stp_event
   ,stp_arrivaldate
   ,stp_number
   ,stp_zipcode
   From @moves moves
   join stops on moves.mov_number = stops.mov_number
   join eventcodetable on stops.stp_event = eventcodetable.abbr
   join statecountry on stops.stp_state = statecountry.stc_state_c
   WHere stp_arrivaldate = @WorkDate
   and (stops.ord_hdrnumber = @p_ordhdrnumber or stops.ord_hdrnumber = 0) 
   and stc_country_c = @DomesticCountry
   order by stp_mfh_sequence -- top 1 / order by overkill???

  END

/* get last stop in domestic country according to rules */
If @GIStopTypeOption = 'INSIDE/BILLABLE'
  BEGIN
   Select @workdate = Max(stp_arrivaldate)
   From @moves moves
   join stops on moves.mov_number = stops.mov_number
   join eventcodetable on stops.stp_event = eventcodetable.abbr and ect_billable = 'Y'
   join statecountry on stops.stp_state = statecountry.stc_state_c
   where stp_arrivaldate between @origindate and @destDate
   and (stops.ord_hdrnumber = @p_ordhdrnumber) 
   and stops.ord_hdrnumber > 0
   and stc_country_c = @DomesticCountry

   Insert into @stopinfo
   Select top 1 'L' FirstOrLast
   ,cmp_id
   ,stp_city
   ,stp_event
   ,stp_arrivaldate
   ,stp_number
   ,stp_zipcode
   From @moves moves
   join stops on moves.mov_number = stops.mov_number
   join eventcodetable on stops.stp_event = eventcodetable.abbr and ect_billable = 'Y'
   join statecountry on stops.stp_state = statecountry.stc_state_c
   WHere stp_arrivaldate = @WorkDate
   and (stops.ord_hdrnumber = @p_ordhdrnumber) 
   and stops.ord_hdrnumber > 0
   and stc_country_c = @DomesticCountry
   order by stp_sequence desc -- top 1 / order by overkill???
   
  END
If @GIStopTypeOption = 'INSIDE/ALL'
  BEGIN
   Select @workdate = Max(stp_arrivaldate)
   From @moves moves
   join stops on moves.mov_number = stops.mov_number
   join eventcodetable on stops.stp_event = eventcodetable.abbr 
   join statecountry on stops.stp_state = statecountry.stc_state_c
   where stp_arrivaldate between @origindate and @destDate
   and (stops.ord_hdrnumber = @p_ordhdrnumber or stops.ord_hdrnumber = 0) 
   and stc_country_c = @DomesticCountry

   Insert into @stopinfo
   Select top 1 'L' FirstOrLast
   ,cmp_id
   ,stp_city
   ,stp_event
   ,stp_arrivaldate
   ,stp_number
   ,stp_zipcode
   From @moves moves
   join stops on moves.mov_number = stops.mov_number
   join eventcodetable on stops.stp_event = eventcodetable.abbr 
   join statecountry on stops.stp_state = statecountry.stc_state_c
   WHere stp_arrivaldate = @WorkDate
   and (stops.ord_hdrnumber = @p_ordhdrnumber or stops.ord_hdrnumber = 0) 
   and stc_country_c = @DomesticCountry
   order by stp_mfh_sequence desc -- top 1 / order by overkill???

  END
  
  select FirstOrLast ,cmp_Id,stp_city , stp_event ,stp_arrivaldate,stp_number  from @stopinfo
GO
GRANT EXECUTE ON  [dbo].[IntnlBillingRuleFirstLastStops] TO [public]
GO
