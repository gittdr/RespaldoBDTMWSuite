SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[setinvscheduleforinvoice_sp] (@p_ivhhdr int)
AS
 /*
 Pass the ivh_hdrnumber of an invoice. Use the delivery date on the invoice to select a 
 billing period end date from the invschedulesheader table. Stamp the ivh_revenue_date,
 ivh_bookyear and ivh_book month from that schedule. 
 
  REVISION
  7/26/11 DPETE created for PTS 56953 given the ivh_hdrnumber for an invoice
  determine the closest open billing period in the billing schedules table and tag the
  ivh_revenue_date with that period end date, the ivh_bookyear to the year and the
  ivh_bookmonth to the billing period from the schedule     
9/10/12 DPETE PTS 64782 must use max delivery date from all invoices when the invoice passed is part of a dedicated bill
  */

     declare @deliverydate datetime, @ordhdrnumber int, @perioddate datetime, @periodyear int,@period int
     declare @dbhid int, @ivhdefinition varchar(10),@billdate datetime
     
     select @deliverydate = ivh_deliverydate
      ,@ordhdrnumber = ord_hdrnumber 
      , @dbhid = dbh_id
      ,@ivhdefinition = ivh_definition
      , @billdate = ivh_billdate
     from invoiceheader
     where ivh_hdrnumber = @p_ivhhdr
     
     /* for a dedicated bill or misc invoice on a dedicated bill
         use the latest delivery date from all
         invoices on the ded bill

        it appears that a misc inovice is created with todays date in the delivery date field
      */
    -- If @ordhdrnumber   = 0  and @dbhid > 0
   if @dbhid > 0
       select @deliverydate  = MAX(ivh_deliverydate)
       from invoiceheader
       where dbh_id = @dbhid 
       --and ord_hdrnumber > 0
       and ivh_deliverydate < '20491231 23:59'

      /* for misc invoices not on a dedicated bill use the bill date */ 
      If @ordhdrnumber = 0 and @dbhid = 0
        Select @deliverydate = @billdate
       
       select @perioddate = min(ish_end_date)
       from invscheduleheader
       where ish_end_date >= @deliverydate
       and ish_status = 'OPN'
     
     if @perioddate  is not null
       BEGIN
        select @periodyear = ish_year
        ,@period = ish_period
        from invscheduleheader
        where ish_end_date = @perioddate
        
        update invoiceheader
        set ivh_revenue_date = @perioddate
         , ivh_bookyear = convert(tinyint,(@periodyear % 100))
         , ivh_bookmonth = convert(tinyint,@period)
         where ivh_hdrnumber = @p_ivhhdr
         
       END

GO
GRANT EXECUTE ON  [dbo].[setinvscheduleforinvoice_sp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[setinvscheduleforinvoice_sp] TO [public]
GO
