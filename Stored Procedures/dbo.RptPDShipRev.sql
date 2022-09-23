SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptPDShipRev]
 @cmp_id varchar(8),
 @start_date datetime,
 @end_date datetime,
 @style char(1)
AS
BEGIN
 
 DECLARE @pdshiprev TABLE(
     cmp_id varchar(8),
  pro_number varchar(30),
  deliveries int,
  del_weight float,
  del_revenue money,
  pickups int,
  pick_weight float,
  pick_revenue money 
 );
 
 insert into @pdshiprev (cmp_id, pro_number, pick_weight, pick_revenue, pickups, del_weight, del_revenue, deliveries)
  select pickup_terminal, r.ref_number, isnull(o.ord_totalweight, 0), ol.net_charges, 1, 0, 0, 0
    from orderheader o with (NOLOCK)
    join orderheaderltlinfo ol with (NOLOCK)
    on ol.ord_hdrnumber = o.ord_hdrnumber
    left join referencenumber r with (NOLOCK)
    on r.ord_hdrnumber = o.ord_hdrnumber
    and r.ref_type='PRO#'
    where 
    cast(o.ord_startdate as date) between cast(@start_date as date) and cast(@end_date as date)
    and o.ord_status not in ('CAN','AVL', 'QTE', 'MST', 'MPU', 'STD')

 insert into @pdshiprev (cmp_id, pro_number, del_weight, del_revenue, deliveries, pick_weight, pick_revenue, pickups)
  select delivery_terminal, r.ref_number, isnull(o.ord_totalweight, 0), ol.net_charges, 1, 0, 0, 0
    from orderheader o with (NOLOCK)
    join orderheaderltlinfo ol with (NOLOCK)
    on ol.ord_hdrnumber = o.ord_hdrnumber
    left join referencenumber r with (NOLOCK)
    on r.ord_hdrnumber = o.ord_hdrnumber
    and r.ref_type='PRO#'
    where 
    cast(o.ord_completiondate as date) between cast(@start_date as date) and cast(@end_date as date)
    and o.ord_status = 'CMP'

 if (@style = 'D')
 begin
    if (@cmp_id = '*')
    begin  
   --SELECT * from #pdshiprev;
   SELECT cmp_id 'Terminal', pickups 'Pickups', pick_weight 'Pickup Weight', pick_revenue 'Pickup Net Revenue',
     deliveries 'Deliveries', del_weight 'Delivery Weight', del_revenue 'Delivery Net Revenue', IsNull(pro_number,'') as 'ProNumber'
     from @pdshiprev
    end
    else
    begin
   --SELECT * from #pdshiprev WHERE cmp_id = @cmp_id;
   SELECT cmp_id 'Terminal', pickups 'Pickups', pick_weight 'Pickup Weight', pick_revenue 'Pickup Net Revenue',
     deliveries 'Deliveries', del_weight 'Delivery Weight', del_revenue 'Delivery Net Revenue', IsNull(pro_number,'') as 'ProNumber'
     from @pdshiprev WHERE cmp_id = @cmp_id;
    end
  end 
 else
  begin
    if (@cmp_id = '*')
    begin
   SELECT 
   cmp_id 'Terminal', sum(pickups) 'Pickups', sum(pick_weight) 'Pickup Weight', sum(pick_revenue) 'Pickup Net Revenue',
   sum(deliveries) 'Deliveries', sum(del_weight) 'Delivery Weight', sum(del_revenue) 'Delivery Net Revenue'   
   into #T1
   from @pdshiprev
   group by cmp_id
   
   select *, '-1' as ProNumber from #T1
   drop table #T1
   
    end
    else
    begin
   SELECT cmp_id 'Terminal', sum(pickups) 'Pickups', sum(pick_weight) 'Pickup Weight', sum(pick_revenue) 'Pickup Net Revenue',
   sum(deliveries) 'Deliveries', sum(del_weight) 'Delivery Weight', sum(del_revenue) 'Delivery Net Revenue'
   into #T2
   from @pdshiprev
   where cmp_id=@cmp_id
   group by cmp_id
   
   select *, '-1' as ProNumber from #T2
   drop table #T2
   
   end
 end

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptPDShipRev] TO [public]
GO
