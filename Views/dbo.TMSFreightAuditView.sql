SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSFreightAuditView]
AS
SELECT ISNULL(lh.mov_number,0) 'Id', 
       s1.WindowDateLatest 'Pickup Date',
    pick_city.cty_nmstct 'Pickup',        
    s2.WindowDateLatest 'Delivery Date', 
    delv_city.cty_nmstct 'Delivery',            
    sum(lh.lgh_miles) 'Miles', /* TODO: DNA - No idea???*/
       (SELECT COUNT(*) FROM orderheader where mov_number=lh.mov_number) OrderCount,
       SUM(ISNULL(pd.pyd_amount,0)) 'Paid Amount',
       '' 'Carrier',
       CASE 
         WHEN ISNULL(pd.pyd_status,'') IN ('PND','REL') THEN 'Approved'         
         ELSE 'Active'
       END  'Status'
  FROM TMSOrder o
  left join TMSStops as s1 on s1.OrderId = o.OrderId and s1.StopType = 'PUP'
  left join TMSStops as s2 on s2.OrderId = o.OrderId and s2.StopType = 'DRP'
  left join company pick on pick.cmp_id = s1.LocationId
  left join city pick_city on pick_city.cty_code = s1.LocationCityCode
  left join company delv on delv.cmp_id = s2.LocationId 
  left join city delv_city on delv_city.cty_code = s2.LocationCityCode
  left join orderheader oh on o.ord_hdrnumber = oh.ord_hdrnumber
  left join legheader_active lh on lh.ord_hdrnumber= oh.ord_hdrnumber
  join paydetail pd on lh.mov_number = pd.mov_number
  WHERE lh.mov_number NOT IN (SELECT mov_number from paydetaildisputes where mov_number = lh.mov_number)
GROUP BY lh.mov_number, s1.WindowDateLatest, pick_city.cty_nmstct, s2.WindowDateLatest, delv_city.cty_nmstct,pd.pyd_status
HAVING SUM(ISNULL(pd.pyd_amount,0)) > 0
UNION
SELECT ISNULL(lh.mov_number,0) 'Id', 
       s1.WindowDateLatest 'Pickup Date',
    pick_city.cty_nmstct 'Pickup',        
    s2.WindowDateLatest 'Delivery Date', 
    delv_city.cty_nmstct 'Delivery',            
    sum(lh.lgh_miles) 'Miles', /* TODO: DNA - No idea???*/
       (SELECT COUNT(*) FROM orderheader where mov_number=lh.mov_number) OrderCount,
       SUM(ISNULL(pd.Amount,0)) 'Paid Amount',
       '' 'Carrier',
       'Disputed' 'Status'
  FROM TMSOrder o
  left join TMSStops as s1 on s1.OrderId = o.OrderId and s1.StopType = 'PUP'
  left join TMSStops as s2 on s2.OrderId = o.OrderId and s2.StopType = 'DRP'
  left join company pick on pick.cmp_id = s1.LocationId
  left join city pick_city on pick_city.cty_code = s1.LocationCityCode
  left join company delv on delv.cmp_id = s2.LocationId 
  left join city delv_city on delv_city.cty_code = s2.LocationCityCode
  left join orderheader oh on o.ord_hdrnumber = oh.ord_hdrnumber
  left join legheader_active lh on lh.ord_hdrnumber= oh.ord_hdrnumber
  join PayDetailDisputes pd on lh.mov_number = pd.mov_number
GROUP BY lh.mov_number, s1.WindowDateLatest, pick_city.cty_nmstct, s2.WindowDateLatest, delv_city.cty_nmstct
GO
GRANT SELECT ON  [dbo].[TMSFreightAuditView] TO [public]
GO
