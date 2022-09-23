SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptOutbound_2]
 @cmp_id varchar(8),
 @sort char(1) 
 
AS
BEGIN
 
 --// @sort = 'D' - delivery terminal else load_to_terminal
 --// @style = 'S' - summary else detail
 
 CREATE TABLE #outbound(
   mfh_number        INT,
   stp_sequence  INT,
   ord_hdrnumber  INT,
   ord_number  VARCHAR(12),
   load_to_terminal  VARCHAR(8),
   delivery_terminal VARCHAR(8),
   shipper   VARCHAR(8),
   consignee   VARCHAR(8),
   current_loc  VARCHAR(8),
   weight   FLOAT DEFAULT 0,
   pcs    DECIMAL(10,2) DEFAULT 0,
   hu    DECIMAL(10,2) DEFAULT 0,
   cube    FLOAT DEFAULT 0,
   pallets   FLOAT DEFAULT 0
 );
 
 INSERT INTO #outbound(
   mfh_number, stp_sequence, ord_hdrnumber, ord_number, 
   delivery_terminal, load_to_terminal, shipper, consignee, current_loc, 
   cube, pallets, pcs, weight, hu)
 SELECT e.evt_mfh_number, s.stp_sequence, orderheader.ord_hdrnumber, ord_number,    
     oltl.delivery_terminal, 
     IsNull(el.cmp_id,'Unknown'), ord_shipper, ord_consignee, 
     oltl.cmp_id, 
     IsNull(orderheader.ord_totalvolume, 0),
     IsNull(orderheader.ord_totalpallets, 0),
     IsNull(orderheader.ord_totalpieces, 0),
     IsNull(orderheader.ord_totalweight, 0),
     IsNull(orderheader.ord_totalcount2, 0)
 FROM orderheader
            INNER JOIN orderheaderltlinfo oltl ON oltl.ord_hdrnumber = orderheader.ord_hdrnumber
            INNER JOIN event e ON e.ord_hdrnumber = orderheader.ord_hdrnumber
   INNER JOIN eventltlinfo el ON el.evt_number = e.evt_number
            INNER JOIN stops s ON s.stp_number = e.stp_number 
            INNER JOIN legheader l ON l.lgh_number = s.lgh_number
 WHERE s.cmp_id = @cmp_id
   AND e.evt_eventcode = 'XDL' --CODE FOR CROSS DOCK
   AND e.evt_status <> 'DNE' --CODE FOR SHIPMENTS NOT YET LEFT
   AND el.plan_status = 'C';
 
 --DECLARE @weight FLOAT; 
 --DECLARE @ord_hdrnumber INT;
 --DECLARE @ord_number VARCHAR(12);

 --DECLARE c_order CURSOR FOR SELECT ord_hdrnumber from #outbound;

 --OPEN c_order;

 --FETCH c_order INTO @ord_hdrnumber;

 --WHILE @@FETCH_STATUS = 0
 --BEGIN

   --SET @weight = (SELECT COALESCE(SUM(fgt_weight),0) 
 --    FROM freightdetail 
 --    where stp_number = (
 --     SELECT stp_number 
 --     FROM stops 
 --     WHERE ord_hdrnumber = @ord_hdrnumber AND stp_type = 'DRP')
 --    );
     
   --SET @ord_number = (SELECT ord_number 
  --    FROM orderheader 
  --    where ord_hdrnumber = @ord_hdrnumber);

   --UPDATE #outbound 
   --SET weight = @weight,ord_number = @ord_number        
   --WHERE ord_hdrnumber = @ord_hdrnumber;

   --FETCH c_order INTO @ord_hdrnumber;

 --END;

 --CLOSE c_order;
 --DEALLOCATE c_order;
  
 --// Detail
  BEGIN
    IF @sort = 'D'
    --// delivery terminal
    BEGIN
   SELECT *
   from #outbound 
   order by delivery_terminal, load_to_terminal;
    END
    ELSE IF @sort = 'M'
    --// manifest
    BEGIN
   SELECT *
   from #outbound 
   --where mfh_number <> 0 
   order by mfh_number asc, stp_sequence desc
    END
    ELSE
    BEGIN
   SELECT *
   from #outbound 
   order by load_to_terminal, delivery_terminal;
  END
 END;

 
 DROP TABLE #outbound

 RETURN 0
 
 
END
GO
GRANT EXECUTE ON  [dbo].[RptOutbound_2] TO [public]
GO
