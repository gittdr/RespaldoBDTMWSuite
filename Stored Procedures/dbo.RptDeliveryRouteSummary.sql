SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptDeliveryRouteSummary]
 @cmp_id varchar(8)
AS
BEGIN
 
 CREATE TABLE #deliveryroutesummary(
   mfh_number        INT,
   stp_sequence  INT,
   ord_hdrnumber  INT,
   ord_number  VARCHAR(12),
   ord_dest_earliestdate DATETIME,
   ord_dest_latestdate DATETIME,
   delivery_terminal VARCHAR(8),
   shipper   VARCHAR(8),
   consignee   VARCHAR(8),
   current_loc  VARCHAR(8),
   door_number  INT,
   route_id   INT,
   weightunits  VARCHAR(6),
   countunits  VARCHAR(6),
   weight   FLOAT DEFAULT 0,
   pcs    int DEFAULT 0,
   hu    int DEFAULT 0, 
   route_description varchar(40)
 );

 INSERT INTO #deliveryroutesummary(
 mfh_number, stp_sequence, ord_hdrnumber, 
 ord_number, delivery_terminal, shipper, consignee, current_loc, 
 door_number, ord_dest_earliestdate, ord_dest_latestdate, 
 route_id, weightunits,countunits,[weight],pcs, hu, route_description)

 SELECT e.evt_mfh_number, s.stp_sequence, orderheader.ord_hdrnumber, orderheader.ord_number, 
 oltl.delivery_terminal, ord_shipper, ord_consignee, oltl.cmp_id, 
  CASE WHEN el.override_door_number <> 0 
   THEN el.override_door_number 
   ELSE el.door_number 
  END door_number, 
  orderheader.ord_dest_earliestdate, orderheader.ord_dest_latestdate, sltl.route_id,
  IsNull(orderheader.ord_totalweightunits,''),
  IsNull(orderheader.ord_totalcountunits,''),
  IsNull(Cast(orderheader.ord_totalweight as FLOAT),0),
  Cast(IsNull(orderheader.ord_totalpieces,0) as int),
  Cast(IsNull(orderheader.ord_totalpallets,0) as int), tr.route_description       
 FROM orderheader
  INNER JOIN orderheaderltlinfo oltl ON oltl.ord_hdrnumber = orderheader.ord_hdrnumber
        INNER JOIN event e ON e.ord_hdrnumber = orderheader.ord_hdrnumber
  INNER JOIN eventltlinfo el ON el.evt_number = e.evt_number   
        INNER JOIN stops s ON s.stp_number = e.stp_number 
        INNER JOIN legheader l ON l.lgh_number = s.lgh_number
        INNER JOIN stopltlinfo sltl on sltl.stp_number = s.stp_number   
        INNER JOIN terminalroute tr on sltl.route_id = tr.id  
 WHERE oltl.delivery_terminal = @cmp_id
  AND l.lgh_outstatus <> 'CMP'
  AND e.evt_pu_dr = 'DRP'
  AND el.plan_status='C'

 SELECT * from #deliveryroutesummary order by route_id;
 
 DROP TABLE #deliveryroutesummary

RETURN 0

END
GO
GRANT EXECUTE ON  [dbo].[RptDeliveryRouteSummary] TO [public]
GO
