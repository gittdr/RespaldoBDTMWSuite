SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptCarrierSubLedger]
 @cut_off datetime
AS
BEGIN
 
 CREATE TABLE #carriersubledger(
   car_id VARCHAR(8),
    lgh_number integer,
    oc_id integer,
    ocd_id integer,
    glnum varchar(32),
    amount money,
 currency varchar(6)    
 );

 DECLARE @lgh_number INT;
 DECLARE @car_id varchar(8);
 DECLARE @currency varchar(6);

 DECLARE c_leg CURSOR FOR 
select lgh_number, ord_booked_carrier, currency
from legheader_brokered
where pay_status in ('Adjust','Audit','Complete')
and exists(
select 1 from legheader_brokered_status 
where lgh_number = legheader_brokered.lgh_number 
and status_code = 'Adjust'
and updateddate < @cut_off)
and not exists(
select 1 from legheader_brokered_status 
where lgh_number = legheader_brokered.lgh_number 
and status_code = 'Complete'
and updateddate < @cut_off);
  

 OPEN c_leg;
 FETCH c_leg INTO @lgh_number, @car_id, @currency;
 WHILE @@FETCH_STATUS = 0
 BEGIN

    DECLARE @oc_id INT;
    DECLARE @ocd_id INT;
    DECLARE @charges money;

    DECLARE c_carrier CURSOR FOR
select oc.id, ocd.id, ocd.charges
from ordercarrier oc
left outer join ordercarrierdetails ocd on ocd.ordercarrier_id = oc.id
where oc.lgh_number = @lgh_number
and oc.pay_type = 'Payable'
and oc.gl_type = 'Accural'; 

   OPEN c_carrier;
    FETCH c_carrier INTO @oc_id, @ocd_id, @charges;
    WHILE @@FETCH_STATUS = 0
    BEGIN
      DECLARE @glnum varchar(32);
      select @glnum = glnum
      from ordercarrierdetails_gl
      where oc_id = @oc_id
      and ocd_id = @ocd_id
      and account_type = 'CarAcc';

      insert into #carriersubledger( car_id, lgh_number, oc_id, ocd_id, glnum, amount, currency)
        values (@car_id, @lgh_number, @oc_id, @ocd_id, @glnum, @charges, @currency);    

      FETCH c_carrier INTO @oc_id, @ocd_id, @charges;
    END
   CLOSE c_carrier;
    DEALLOCATE c_carrier;


   FETCH c_leg INTO @lgh_number, @car_id, @currency;
 END;

 CLOSE c_leg;
 DEALLOCATE c_leg;


 SELECT * from #carriersubledger order by car_id, lgh_number

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptCarrierSubLedger] TO [public]
GO
