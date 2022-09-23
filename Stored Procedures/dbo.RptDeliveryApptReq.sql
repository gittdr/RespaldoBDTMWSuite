SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptDeliveryApptReq]
 @cmp_id varchar(8)
AS
BEGIN

 --help temp table --------------------------------------------------------------
 select distinct ord.ord_consignee, c.cmp_name as consignee_name, city.cty_name as consignee_city, 
 c.cmp_state as consignee_state, c.cmp_zip as consignee_zip, IsNull(c.cmp_primaryphone,'') as consignee_phone
 into #temp
 from orderheader ord 
 inner join company c on ord.ord_consignee = c.cmp_id
 inner join city on c.cmp_city = city.cty_code
 --------------------------------------------------------------------------------
 
 
 CREATE TABLE #deliveryapptreq(
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
   weight   FLOAT DEFAULT 0,
   pcs    DECIMAL(10,2) DEFAULT 0,
   hu    DECIMAL(10,2) DEFAULT 0,
   pro_number VARCHAR(30),
   consignee_name VARCHAR(100),
   consignee_city VARCHAR(18),
   consignee_state VARCHAR(6),
   consignee_zip VARCHAR(10),
   consignee_phone VARCHAR(20)
 );

 INSERT INTO #deliveryapptreq(mfh_number, stp_sequence, ord_hdrnumber, 
 ord_number, delivery_terminal, shipper, consignee, current_loc, 
 door_number, ord_dest_earliestdate, ord_dest_latestdate, pro_number, 
 consignee_name, consignee_city,consignee_state,consignee_zip,consignee_phone)

 SELECT e.evt_mfh_number, s.stp_sequence, orderheader.ord_hdrnumber, orderheader.ord_number, 
 oltl.delivery_terminal, ord_shipper, ord_consignee, oltl.cmp_id,
  CASE WHEN el.override_door_number <> 0 THEN el.override_door_number ELSE el.door_number END 
  door_number, orderheader.ord_dest_earliestdate, orderheader.ord_dest_latestdate, 
  
    (
   SELECT TOP 1 ref_number 
   FROM referencenumber 
   WHERE  ord_hdrnumber = orderheader.ord_hdrnumber AND ref_type = 'PRO#'
   ),
   (select #temp.consignee_name from #temp where ord_consignee = orderheader.ord_consignee),
   (select #temp.consignee_city from #temp where ord_consignee = orderheader.ord_consignee),
   (select #temp.consignee_state from #temp where ord_consignee = orderheader.ord_consignee),
   (select #temp.consignee_zip from #temp where ord_consignee = orderheader.ord_consignee),
   (select #temp.consignee_phone from #temp where ord_consignee = orderheader.ord_consignee)
  
  FROM orderheader
  INNER JOIN orderheaderltlinfo oltl ON oltl.ord_hdrnumber = orderheader.ord_hdrnumber
        INNER JOIN event e ON e.ord_hdrnumber = orderheader.ord_hdrnumber
  INNER JOIN eventltlinfo el ON el.evt_number = e.evt_number   
        INNER JOIN stops s ON s.stp_number = e.stp_number 
        INNER JOIN legheader l ON l.lgh_number = s.lgh_number
        INNER JOIN stopltlinfo sltl on sltl.stp_number = s.stp_number
  WHERE oltl.delivery_terminal = @cmp_id
  AND l.lgh_outstatus <> 'CMP'
  AND e.evt_pu_dr = 'DRP'
  AND el.plan_status='C'
  AND oltl.dest_apmt_required='Y'
  AND oltl.dest_apmt_made = 'N'

  SELECT * from #deliveryapptreq 
  order by ord_dest_earliestdate;
  
  drop table #temp
  DROP TABLE #deliveryapptreq

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptDeliveryApptReq] TO [public]
GO
