SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptManifest]
 @MfhNumber int
AS
BEGIN
 
 CREATE TABLE #manifest(
   mfh_number  INT,
   mov_number  INT,
   tractor   VARCHAR(8),
   driver1   VARCHAR(8),
   trailer1   VARCHAR(13),
   trailer2   VARCHAR(13),
   stp_number  INT,
   ord_hdrnumber  INT,
   eventcode   VARCHAR(6),
   ord_number  VARCHAR(12),
   pro_number  VARCHAR(30),
   origin   VARCHAR(8),
   unit_id   VARCHAR(13),
   unit_pos   VARCHAR(6) DEFAULT '',
   stop_name   VARCHAR(30),
   stop_city   VARCHAR(18),
   stop_state  VARCHAR(6),
   shipper_name  VARCHAR(30),
   shipper_city  VARCHAR(18),
   shipper_state  VARCHAR(6),
   consignee_name    VARCHAR(30),
   consignee_city VARCHAR(18),
   consignee_state VARCHAR(6),
   weight   FLOAT DEFAULT 0,
   pieces   DECIMAL(10,2) DEFAULT 0,
   hu    DECIMAL(10,2) DEFAULT 0,
   hazardous   CHAR(1),
   cod_amount  DECIMAL(9,2),
   stp_sequence  INT
 );
 
 INSERT INTO #manifest(mfh_number, origin, mov_number, stp_number, unit_id, ord_hdrnumber, eventcode, stp_sequence, stop_name, stop_city,
 stop_state, hazardous, cod_amount, tractor, driver1, trailer1, trailer2)
   SELECT mh.mfh_number, mh.cmp_id, mh.mov_number, s.stp_number, mh.unit_id, e.ord_hdrnumber, e.evt_eventcode, s.stp_mfh_sequence,
   s.cmp_name, c.cty_name, s.stp_state, 'N', 0, lh.lgh_tractor, lh.lgh_driver1, lh.lgh_primary_trailer, lh.lgh_primary_pup

   FROM stops s
        INNER JOIN legheader lh ON lh.mov_number = s.mov_number 
              INNER JOIN city c ON c.cty_code = s.stp_city 
              INNER JOIN manifestheader mh ON mh.mov_number = s.mov_number
     AND mh.mfh_number = @MfhNumber
     LEFT JOIN event e ON e.stp_number = s.stp_number AND E.evt_eventcode IN ('HLT', 'BMT', 'HPL', 'LLD', 'LUL', 'DLT', 'DRL', 'EMT')
   ORDER by s.stp_mfh_sequence;

 DECLARE @weight FLOAT = 0;
 DECLARE @pieces DECIMAL(10,2);
 DECLARE @ordHdrNumber INT;
 DECLARE @ordNumber VARCHAR(12);
 DECLARE @eventCode VARCHAR(6);
 DECLARE @COD MONEY;
 DECLARE @shipperName VARCHAR(30);
 DECLARE @shipperCity VARCHAR(18);
 DECLARE @shipperState VARCHAR(6);
 DECLARE @consigneeName VARCHAR(30);
 DECLARE @consigneeCity VARCHAR(18);
 DECLARE @consigneeState VARCHAR(6);

 DECLARE c_order CURSOR FOR SELECT ord_hdrnumber, eventcode from #manifest;

 OPEN c_order;

 FETCH c_order INTO @ordHdrNumber, @eventCode;

 WHILE @@FETCH_STATUS = 0
 BEGIN

   IF @ordHdrNumber <> 0
   BEGIN
  
  --// Order header
  SELECT @ordNumber = ord_number, @weight = ord_totalweight, @pieces = ord_totalpieces,
         @COD = ord_cod_amount FROM orderheader where ord_hdrnumber = @ordHdrNumber;

  --// Shipper
  SELECT @shipperName = s.cmp_name, @shipperCity = c.cty_name, @shipperState = s.stp_state FROM stops s, event e, city c where e.ord_hdrnumber = @ordHdrNumber
  AND e.stp_number = s.stp_number AND e.evt_eventcode = 'LLD'
  AND c.cty_code = s.stp_city;

  --// Consignee
  SELECT @consigneeName = s.cmp_name, @consigneeCity = c.cty_name, @consigneeState = s.stp_state FROM stops s, event e, city c where e.ord_hdrnumber = @ordHdrNumber
  AND e.stp_number = s.stp_number AND e.evt_eventcode = 'LUL'
  AND c.cty_code = s.stp_city;

  UPDATE #manifest SET weight = @weight, pieces = @pieces, cod_amount = @COD,
   ord_number = @ordNumber, 
   shipper_name = @shipperName, shipper_city = @shipperCity, shipper_state = @shipperState,
   consignee_name = @consigneeName, consignee_city = @consigneeCity, consignee_state = @consigneeState
     WHERE ord_hdrnumber = @ordHdrNumber;
   END;

   FETCH c_order INTO @ordHdrNumber, @eventCode;

 END;

 CLOSE c_order;
 DEALLOCATE c_order;

 SELECT *  FROM #manifest order by stp_sequence;

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptManifest] TO [public]
GO
