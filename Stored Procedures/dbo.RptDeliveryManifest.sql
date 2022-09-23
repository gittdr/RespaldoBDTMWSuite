SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptDeliveryManifest]
 @cmp_id varchar(8),
 @sort char(1),
 @style char(1)

AS
BEGIN
 
 --// @sort = 'D' - delivery terminal else load_to_terminal
 --// @style = 'S' - summary else detail
 
 CREATE TABLE #deliverymanifest(
   mfh_number        INT,
   stp_sequence  INT,
   ord_hdrnumber  INT,
   ord_number  VARCHAR(12),
   delivery_terminal VARCHAR(8),
   shipper   VARCHAR(8),
   consignee   VARCHAR(8),
   current_loc  VARCHAR(8),
   door_number  INT,
   weight   FLOAT DEFAULT 0,
   pcs    DECIMAL(10,2) DEFAULT 0,
   hu    DECIMAL(10,2) DEFAULT 0
 );
 
 INSERT INTO #deliverymanifest(mfh_number, stp_sequence, ord_hdrnumber, ord_number, delivery_terminal, shipper, consignee, current_loc, door_number)
  
 SELECT e.evt_mfh_number, s.stp_sequence, orderheader.ord_hdrnumber, orderheader.ord_number, oltl.delivery_terminal, ord_shipper, ord_consignee, oltl.cmp_id,
  CASE WHEN el.override_door_number <> 0 THEN el.override_door_number ELSE el.door_number END door_number FROM orderheader
  INNER JOIN orderheaderltlinfo oltl ON oltl.ord_hdrnumber = orderheader.ord_hdrnumber
        INNER JOIN event e ON e.ord_hdrnumber = orderheader.ord_hdrnumber
  INNER JOIN eventltlinfo el ON el.evt_number = e.evt_number   
        INNER JOIN stops s ON s.stp_number = e.stp_number 
        INNER JOIN legheader l ON l.lgh_number = s.lgh_number
        INNER JOIN stopltlinfo sltl on sltl.stp_number = s.stp_number
  WHERE oltl.delivery_terminal = @cmp_id
  AND l.lgh_outstatus <> 'CMP'
  AND e.evt_pu_dr = 'DRP'
  AND el.plan_status='C';

 DECLARE @weight FLOAT ; 
 DECLARE @ord_hdrnumber INT;
 DECLARE @ord_number VARCHAR(12);

 DECLARE c_order CURSOR FOR SELECT ord_hdrnumber from #deliverymanifest;

 OPEN c_order;

 FETCH c_order INTO @ord_hdrnumber;

 WHILE @@FETCH_STATUS = 0
 BEGIN

   SET @weight = (SELECT COALESCE(SUM(fgt_weight),0) FROM freightdetail where stp_number = (SELECT stp_number FROM stops WHERE ord_hdrnumber = @ord_hdrnumber AND stp_type = 'DRP'));
   SET @ord_number = (SELECT ord_number FROM orderheader where ord_hdrnumber = @ord_hdrnumber);

   UPDATE #deliverymanifest SET weight = @weight,
     ord_number = @ord_number
   
    WHERE ord_hdrnumber = @ord_hdrnumber;

   FETCH c_order INTO @ord_hdrnumber;

 END;

 CLOSE c_order;
 DEALLOCATE c_order;
 
 IF @style = 'S'
 --// Summary
 BEGIN
   IF @sort = 'D'
   --// delivery terminal
   BEGIN
  SELECT delivery_terminal, door_number, count(*) cnt, sum(hu) hu, sum(pcs) pcs, sum(weight) weight FROM #deliverymanifest GROUP BY delivery_terminal, door_number;
   END
   --// manifest
   ELSE IF @sort = 'M'
   BEGIN
  SELECT mfh_number, count(*) cnt, sum(hu) hu, sum(pcs) pcs, sum(weight) weight FROM #deliverymanifest WHERE mfh_number <> 0 GROUP BY mfh_number
   END
   ELSE
   BEGIN
     SELECT door_number, delivery_terminal, count(*) cnt, sum(hu) hu, sum(pcs) pcs, sum(weight) weight FROM #deliverymanifest GROUP BY door_number, delivery_terminal;
   END
 END
 ELSE
 --// Detail
 BEGIN
   IF @sort = 'D'
   --// delivery terminal
   BEGIN
  SELECT * from #deliverymanifest order by delivery_terminal, door_number;
   END
   ELSE IF @sort = 'M'
   --// manifest
   BEGIN
  SELECT * from #deliverymanifest where mfh_number <> 0 ORDER BY mfh_number asc, stp_sequence desc
   END
   ELSE
   BEGIN
  SELECT * from #deliverymanifest order by door_number, delivery_terminal;
   END
 END;

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptDeliveryManifest] TO [public]
GO
