SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptTrailerManifest]
 @MfhNumber int
AS
BEGIN
 
 CREATE TABLE #trlrmanifest(
   mfh_number  INT,
   mfd_number  INT,
   ord_hdrnumber  INT,
   ord_number  VARCHAR(12),
   origin   VARCHAR(8),
   destination  VARCHAR(8),
   unit_id   VARCHAR(13),
   stp_etd   DATETIME,
   stp_departure  DATETIME,
   stp_arrival  DATETIME,
   unit_pos   VARCHAR(6) DEFAULT '',
   weight   FLOAT DEFAULT 0,
   pcs    DECIMAL(10,2) DEFAULT 0,
   hu    DECIMAL(10,2) DEFAULT 0,
   pallets   FLOAT DEFAULT 0,
   hazmat varchar(1),
   cmd_code varchar(8),
   feet MONEY,
   pro_number  VARCHAR(30),

   origin_name VARCHAR(30),
   origin_address VARCHAR(40),
   origin_city VARCHAR(18),
   origin_state VARCHAR(6),
   origin_zip VARCHAR(10),

   consignee_name    VARCHAR(30),
   consignee_address VARCHAR(40),
   consignee_city VARCHAR(18),
   consignee_state VARCHAR(6),
   consignee_zip     VARCHAR(10),
   delivery_terminal VARCHAR(8),
   seal_number VARCHAR(30)
 );
 
 INSERT INTO #trlrmanifest(mfh_number, mfd_number, ord_hdrnumber, origin, destination, unit_id, stp_etd, stp_departure, stp_arrival, unit_pos, seal_number)
 
 SELECT mh.mfh_number, md.mfd_number, md.ord_hdrnumber, o.cmp_id origin, d.cmp_id destination,
 mh.unit_id, o.stp_etd planned_depart, o.stp_departuredate actual_depart, d.stp_arrivaldate, md.unit_pos, mh.seal_number
 
 FROM manifestheader mh, manifestdetail md, stops o, stops d
 WHERE mh.mfh_number = md.mfh_number
 AND mh.mfh_number = @MfhNumber
 AND mh.stp_number_start = o.stp_number
 AND mh.stp_number_end = d.stp_number;

 DECLARE @weight FLOAT;

 DECLARE @pcs DECIMAL(10,2);

 DECLARE @ord_hdrnumber INT;
 DECLARE @ord_number VARCHAR(12);

 DECLARE @originName VARCHAR(30);
 DECLARE @originAddress VARCHAR(40);
 DECLARE @originCity VARCHAR(18);
 DECLARE @originState VARCHAR(6);
 DECLARE @originZip VARCHAR(10);

 DECLARE @consigneeName VARCHAR(30);
 DECLARE @consigneeAddress VARCHAR(40);
 DECLARE @consigneeCity VARCHAR(18);
 DECLARE @consigneeState VARCHAR(6);
 DECLARE @consigneeZip VARCHAR(10);
 DECLARE @delivery_terminal VARCHAR(8);
 DECLARE @hazmat varchar(1);
 DECLARE @pallets FLOAT;
 DECLARE @cmd_code varchar(8);
 DECLARE @feet MONEY;
 DECLARE @hu DECIMAL(10,2);
 DECLARE @pro_number VARCHAR(30);


 DECLARE c_order CURSOR FOR SELECT ord_hdrnumber from #trlrmanifest;

 OPEN c_order;

 FETCH c_order INTO @ord_hdrnumber;

 WHILE @@FETCH_STATUS = 0
 BEGIN

   --SET @weight = (SELECT COALESCE(SUM(fgt_weight),0) FROM freightdetail where stp_number = 
   --(SELECT stp_number FROM stops WHERE ord_hdrnumber = @ord_hdrnumber AND stp_event = 'LUL'));
   --SET @ord_number = (SELECT ord_number FROM orderheader where ord_hdrnumber = @ord_hdrnumber);

   SELECT @ord_number = ord_number, @weight = ord_totalweight, @pcs = ord_totalpieces, @pallets = ord_totalpallets,
    @hu = ord_totalcount2, @delivery_terminal = ol.delivery_terminal, 
    @hazmat = ol.hazmat, @cmd_code=oh.cmd_code,
    @feet = oh.ord_length
    FROM orderheader oh, orderheaderltlinfo ol
  WHERE oh.ord_hdrnumber = @ord_hdrnumber
  AND ol.ord_hdrnumber = oh.ord_hdrnumber;

  SELECT @originName = s.cmp_name, 
   @originAddress = s.stp_address,
    @originCity = c.cty_name, 
    @originState = s.stp_state, 
    @originZip = s.stp_zipcode  
  FROM stops s INNER JOIN city c ON c.cty_code = s.stp_city 
  WHERE s.ord_hdrnumber = @ord_hdrnumber
  AND s.stp_type = 'PUP'

  SELECT @consigneeName = s.cmp_name, 
   @consigneeAddress = s.stp_address,
    @consigneeCity = c.cty_name, 
    @consigneeState = s.stp_state, 
    @consigneeZip = s.stp_zipcode  
  FROM stops s INNER JOIN city c ON c.cty_code = s.stp_city 
  WHERE s.ord_hdrnumber = @ord_hdrnumber
  AND s.stp_type = 'DRP'

   SET @pro_number = (SELECT TOP 1 ref_number FROM referencenumber WHERE  ord_hdrnumber = @ord_hdrnumber AND ref_type = 'PRO#');
   
   UPDATE #trlrmanifest SET weight = @weight,
     pcs = @pcs,
  hu = @hu,
  pallets = @pallets,
     ord_number = @ord_number,
  hazmat = @hazmat,
  cmd_code = @cmd_code,
  feet = @feet,
  origin_name = @originName, 
  origin_Address = @originAddress,
  origin_city = @originCity, 
  origin_state = @originState, 
  origin_zip = @originZip,
  consignee_name = @consigneeName, 
  consignee_Address = @consigneeAddress,
  consignee_city = @consigneeCity, consignee_state = @consigneeState, consignee_zip = @consigneeZip,
  delivery_terminal = @delivery_terminal,
  pro_number = @pro_number

   
    WHERE ord_hdrnumber = @ord_hdrnumber;

   FETCH c_order INTO @ord_hdrnumber;

 END;

 CLOSE c_order;
 DEALLOCATE c_order;

 SELECT *  FROM #trlrmanifest order by unit_pos;

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptTrailerManifest] TO [public]
GO
