SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PurgeLTL]
AS
BEGIN
 
begin transaction

/* LTL Tables - just delete all */
delete from terminaltask

commit transaction

/* Not sure what to do */
/*delete from ShiftSchedules where ss_date > '2011-01-01' */

/* Trips */
/* Delete based on stopltlinfo */

select distinct s.lgh_number
into #Legs
from stops s
INNER JOIN stopltlinfo ltl ON ltl.stp_number = s.stp_number
where not exists( 
select ord_hdrnumber 
from orderheader oh 
where oh.ord_hdrnumber = s.ord_hdrnumber 
and oh.ord_status = 'MST')

DECLARE @legNumber INT;
DECLARE c_legs CURSOR FOR SELECT lgh_number from #Legs;

OPEN c_legs;

FETCH c_legs INTO @legNumber;

WHILE @@FETCH_STATUS = 0
BEGIN
  exec PurgeManifestLTL @legNumber
  
  FETCH c_legs INTO @legNumber;
END;

CLOSE c_legs;
DEALLOCATE c_legs;

drop table #Legs

begin transaction
delete from stopltlinfo
commit transaction

/* Delete orders. */
/* Delete based on orderheaderltlinfo */

/* select ord_hdrnumber */
/* into #Orders */
/* from orderheaderltlinfo */
select ltl.ord_hdrnumber
into #Orders
from orderheaderltlinfo ltl
inner join orderheader oh ON oh.ord_hdrnumber = ltl.ord_hdrnumber
where oh.ord_status <> 'MST'

DECLARE @orderNumber INT;
DECLARE c_orders CURSOR FOR SELECT ord_hdrnumber from #Orders;

OPEN c_orders;

FETCH c_orders INTO @orderNumber;

WHILE @@FETCH_STATUS = 0
BEGIN
  exec PurgeOrderLTL @orderNumber
  
  FETCH c_orders INTO @orderNumber;
END;

CLOSE c_orders;
DEALLOCATE c_orders;

drop table #Orders

/* Reset some tables.
  */
begin transaction

update terminaldoor set mfh_number = 0, unit_type='', unit_id=''
update asset_ltl_info set dock_zone = '', move_status='', work_status='', door_number=0

commit transaction


RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[PurgeLTL] TO [public]
GO
