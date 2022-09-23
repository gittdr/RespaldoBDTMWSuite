SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptStripManifest]
 @MfhNumber int,
 @cmpId VARCHAR(8)
AS
BEGIN
 
 --// list of shipments on this manifest that are to be unloaded
 CREATE TABLE #stripmanifest(
   mfh_number  INT,
   unl_door_number INT,
   mfd_number  INT,
   ord_hdrnumber  INT,
   ord_number  VARCHAR(12),
   pro_number  VARCHAR(30),
   origin   VARCHAR(8),
   destination  VARCHAR(8),
   unit_type   VARCHAR(3),
   unit_id   VARCHAR(13),
   stp_etd   DATETIME,
   stp_departure  DATETIME,
   stp_arrival  DATETIME,
   unit_pos   VARCHAR(6),
   weight   FLOAT DEFAULT 0,
   pallets   FLOAT DEFAULT 0,
   pcs    DECIMAL(10,2) DEFAULT 0,
   hu    DECIMAL(10,2) DEFAULT 0,
   cube    FLOAT DEFAULT 0,
   --load_to_terminal  VARCHAR(8),
   take_to   VARCHAR(40),
   consignee_name    VARCHAR(30),
   consignee_city VARCHAR(18),
   consignee_state VARCHAR(6),
   consignee_zip     VARCHAR(10),
   route_code  VARCHAR(10)
   --del_route   INT,
   --del_route_code VARCHAR(10)
 );
 
 INSERT INTO #stripmanifest(mfh_number, mfd_number, ord_hdrnumber, origin, destination, unit_type, unit_id, stp_etd, stp_departure, stp_arrival, unit_pos)
 
 --// get list of shipments on this manifest that are unloading
 SELECT mh.mfh_number, md.mfd_number, md.ord_hdrnumber, o.cmp_id origin, d.cmp_id destination, mh.unit_type,
 mh.unit_id, o.stp_etd planned_depart, o.stp_departuredate actual_depart, d.stp_arrivaldate, md.unit_pos
 
 FROM manifestheader mh, manifestdetail md, stops o, stops d, event e, stops cs
 WHERE mh.mfh_number = md.mfh_number
 AND mh.mfh_number = @MfhNumber
 AND mh.stp_number_start = o.stp_number
 AND mh.stp_number_end = d.stp_number
 AND e.evt_mfh_number = mh.mfh_number
 AND e.ord_hdrnumber = md.ord_hdrnumber
 AND e.evt_eventcode = 'XDU'
 AND cs.stp_number = e.stp_number
 AND cs.cmp_id = @cmpId;

 --ORDER BY md.unit_qtr;

 DECLARE @weight FLOAT; 
 DECLARE @pallets FLOAT; 
 DECLARE @cube FLOAT; 
 DECLARE @ord_hdrnumber INT;
 DECLARE @ord_number VARCHAR(12);
 DECLARE @pro_number VARCHAR(30);
 DECLARE @door_number INT;
 DECLARE @take_to VARCHAR(40);
 DECLARE @mfh_number INT;
 DECLARE @door_mfh_number INT;
 DECLARE @staging_area VARCHAR(10);
 DECLARE @load_to_terminal VARCHAR(8);
 DECLARE @override_terminal VARCHAR(8);
 DECLARE @unit_pos VARCHAR(6);
 DECLARE @unl_door_number INT;
 DECLARE @consigneeName VARCHAR(30);
 DECLARE @consigneeCity VARCHAR(18);
 DECLARE @consigneeState VARCHAR(6);
 DECLARE @consigneeZip VARCHAR(10);
 --DECLARE @del_route INT;
 DECLARE @route_code VARCHAR(10);
 DECLARE @pcs DECIMAL(10,2);
 DECLARE @hu DECIMAL(10,2);
 DECLARE @delivery_terminal VARCHAR(8);
 DECLARE @door_description VARCHAR(40);
 DECLARE @zone_description VARCHAR(40);
 DECLARE @unit_id VARCHAR(13);
 DECLARE @unit_type VARCHAR(6);

 DECLARE c_order CURSOR FOR SELECT ord_hdrnumber from #stripmanifest;

 OPEN c_order;

 FETCH c_order INTO @ord_hdrnumber;

 WHILE @@FETCH_STATUS = 0
 BEGIN

   --SET @weight = (SELECT COALESCE(SUM(fgt_weight),0) FROM freightdetail where stp_number = (SELECT stp_number FROM stops WHERE ord_hdrnumber = @ord_hdrnumber AND stp_type = 'DRP'));
   --SET @ord_number = (SELECT ord_number FROM orderheader WHERE ord_hdrnumber = @ord_hdrnumber);
   SELECT @ord_number = ord_number, @consigneeZip = ord_dest_zip, @weight = ord_totalweight, @pcs = ord_totalpieces, @pallets = oh.ord_totalpallets,
    @hu = oh.ord_totalcount2, @cube = oh.ord_totalvolume, @delivery_terminal = ol.delivery_terminal FROM orderheader oh, orderheaderltlinfo ol
  WHERE oh.ord_hdrnumber = @ord_hdrnumber
  AND ol.ord_hdrnumber = oh.ord_hdrnumber;

   SET @pro_number = (SELECT TOP 1 ref_number FROM referencenumber WHERE  ord_hdrnumber = @ord_hdrnumber AND ref_type = 'PRO#');

   --// get outbound xdl event for this terminal
   --SET @door_number = (SELECT CASE WHEN el.override_door_number <> 0 THEN el.override_door_number ELSE el.door_number END door_number 
   -- FROM event e, eventltlinfo el, stops s
   -- WHERE s.stp_number = e.stp_number
   -- AND el.evt_number = e.evt_number
   -- AND e.ord_hdrnumber = @ord_hdrnumber
   -- AND s.cmp_id = @cmpId
   -- AND e.evt_eventcode = 'XDL');
   
   --// get outbound door number either from LUL for delivery or XDL for xdock
   IF @cmpId = @delivery_terminal
   BEGIN
  SELECT @door_number = CASE WHEN el.override_door_number <> 0 THEN el.override_door_number ELSE el.door_number END, @mfh_number = e.evt_mfh_number,
    @load_to_terminal = el.cmp_id, @override_terminal = COALESCE(override_cmp_id, ''), @unit_pos = unit_pos
    FROM event e, eventltlinfo el
    WHERE el.evt_number = e.evt_number
    AND e.ord_hdrnumber = @ord_hdrnumber
    AND el.cmp_id = @cmpId
    AND e.evt_eventcode = 'LUL';
   END 
   ELSE 
   BEGIN
  SELECT @door_number = CASE WHEN el.override_door_number <> 0 THEN el.override_door_number ELSE el.door_number END, @mfh_number = e.evt_mfh_number,
    @load_to_terminal = el.cmp_id, @override_terminal = COALESCE(override_cmp_id, ''), @unit_pos = unit_pos
    FROM event e, eventltlinfo el, stops s
    WHERE s.stp_number = e.stp_number
    AND el.evt_number = e.evt_number
    AND e.ord_hdrnumber = @ord_hdrnumber
    AND s.cmp_id = @cmpId
    AND e.evt_eventcode = 'XDL';
    END

    if @door_number <> 0
    BEGIN
   SELECT @door_mfh_number = mfh_number, @staging_area = staging_area, @door_description = door_description,
    @zone_description = zone_description, @unit_type = unit_type, @unit_id = unit_id FROM terminaldoor,
   terminalzone WHERE terminalzone.cmp_id = terminaldoor.cmp_id AND terminalzone.dock_zone = terminaldoor.staging_area
   AND terminaldoor.cmp_id = @cmpId AND door_number = @door_number;   
    END
    ELSE
    BEGIN
      SET @staging_area = '';
    END

    --// outbound door number if manifest is currently at a door
    SELECT @unl_door_number = COALESCE(door_number, 0) FROM terminaldoor
    WHERE cmp_id = @cmpId AND mfh_number = @MfhNumber;
    IF @unl_door_number IS NULL
    BEGIN
      SET @unl_door_number = 0;
    END

    IF @override_terminal <> ''
    BEGIN
      SET @load_to_terminal = @override_terminal;
    END

    IF @door_mfh_number = @mfh_number AND @door_mfh_number <> 0
    BEGIN
  --SET @take_to = replace(str(@door_number, 5), ' ', '0');
   SET @take_to = @door_description;
   SET @take_to = SUBSTRING(@door_description,1,10) + ' ' +@unit_type + ' ' + @unit_id;
    END
    ELSE
    BEGIN
      --SET @take_to = @staging_area;
   SET @take_to = @zone_description;
    END

  --// Consignee
  SELECT @consigneeName = s.cmp_name, @consigneeCity = c.cty_name, @consigneeState = s.stp_state, 
  @route_code = tr.route_code FROM stops s, event e, city c,
  stopltlinfo sl, terminalroute tr WHERE e.ord_hdrnumber = @ord_hdrnumber
  AND e.stp_number = s.stp_number AND e.evt_eventcode = 'LUL'
  AND c.cty_code = s.stp_city
  AND tr.id = sl.route_id
  AND sl.stp_number = s.stp_number;

   IF @cmpId <> @delivery_terminal
   BEGIN
     SET @route_code = @load_to_terminal;
   END


   UPDATE #stripmanifest SET weight = @weight, pcs = @pcs,
     ord_number = @ord_number, take_to = @take_to, unit_pos = @unit_pos, pro_number = @pro_number,
  unl_door_number = @unl_door_number,
  consignee_name = @consigneeName, consignee_city = @consigneeCity, consignee_state = @consigneeState, consignee_zip = @consigneeZip,
  route_code = @route_code,
  hu = @hu, pallets = @pallets, cube = @cube
   
    WHERE ord_hdrnumber = @ord_hdrnumber;

   FETCH c_order INTO @ord_hdrnumber;

 END;

 CLOSE c_order;
 DEALLOCATE c_order;

 SELECT *  FROM #stripmanifest order by unit_pos desc;

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptStripManifest] TO [public]
GO
