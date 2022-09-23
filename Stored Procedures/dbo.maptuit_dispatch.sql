SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[maptuit_dispatch] @lgh_number INT
AS
DECLARE @now     		DATETIME,
        @lgh_tractor   		VARCHAR(8),
        @lgh_driver1   		VARCHAR(8), 
        @ord_count     		INTEGER,
	@m2qhid			INTEGER,
	@minstp			INTEGER,
	@ctr			INTEGER,
	@ctr2			INTEGER,
	@stp_number		INTEGER,
	@cty_name		VARCHAR(30),
	@cty_state		VARCHAR(2),
	@cty_region1		VARCHAR(6),
	@fieldname		VARCHAR(50),
	@ord_hdrnumber		INTEGER,
	@cmp_id			VARCHAR(8),
	@mov_number		INTEGER,
	@ord_number		VARCHAR(12),
        @ord_status		VARCHAR(6),
	@stp_type		VARCHAR(6),
	@stp_arrivaldate	DATETIME,
	@stp_departuredate	DATETIME,
	@stp_earliestdate	DATETIME,
	@stp_latestdate		DATETIME,
	@stp_sequence		INTEGER,
	@mpp_teamleader		VARCHAR(6),
	@mpp_fleet		VARCHAR(6),
	@stp_mfh_sequence	INTEGER

SELECT @mov_number = legheader.mov_number,
       @lgh_tractor = legheader.lgh_tractor,
       @lgh_driver1 = legheader.lgh_driver1,
       @ord_hdrnumber = legheader.ord_hdrnumber,
       @mpp_teamleader = manpowerprofile.mpp_teamleader,
       @mpp_fleet = manpowerprofile.mpp_fleet
  FROM legheader, manpowerprofile
 WHERE legheader.lgh_number = @lgh_number AND
       legheader.lgh_driver1 = manpowerprofile.mpp_id

EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Unit_UnitID', 'HIL', @lgh_tractor)
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Unit_DMUserID', 'HIL', @mpp_teamleader)
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Unit_FleetID', 'HIL', @mpp_fleet)
INSERT INTO m2msgqhdr VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')


SET @now = GETDATE()
EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Dispatch_DispatchID', 'HIL', @lgh_number)
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Dispatch_DispatchType', 'HIL', 'PRI')
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Dispatch_UnitID', 'HIL', @lgh_tractor)
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Dispatch_DriverID0', 'HIL', @lgh_driver1)

SET @minstp = 0
SET @ctr = 0
WHILE 1=1
BEGIN
   SELECT @minstp = Min(stp_mfh_sequence)
     FROM stops
    WHERE lgh_number = @lgh_number AND
          stp_mfh_sequence > @minstp

   IF @minstp IS NULL
      BREAK

   SELECT @stp_number = stp_number,
          @cty_name = cty_name,
          @cty_state = cty_state,
          @stp_type = stp_type
     FROM stops, city
    WHERE lgh_number = @lgh_number AND
          stp_mfh_sequence = @minstp AND
          stp_city = cty_code
   SET @fieldname = 'Dispatch_RoutelinePoint' + LTRIM(STR(@ctr)) + '_CityName'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @cty_name)
   SET @fieldname = 'Dispatch_RoutelinePoint' + LTRIM(STR(@ctr)) + '_RegionCode'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @cty_state)
   SET @fieldname = 'Dispatch_RoutelinePoint' + LTRIM(STR(@ctr)) + '_RoutelinePointType'
   IF @stp_type = 'DRP'
      INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', 'LOADED')
   ELSE
      INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', 'EMPTY')

   SET @ctr = @ctr + 1
   
END

SELECT @ord_number = ord_number,
       @ord_status = ord_status
  FROM orderheader
 WHERE ord_hdrnumber = @ord_hdrnumber
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Order_OrderID', 'HIL', @ord_number)
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Order_OrderType', 'HIL', 'REG')
IF @ord_status = 'AVL'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Order_OrderState', 'HIL', 'AVAIL')
IF @ord_status = 'DSP' OR @ord_status = 'PLN'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Order_OrderState', 'HIL', 'DISP')
IF @ord_status = 'STD'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Order_OrderState', 'HIL', 'DISP')
      
SET @ctr = 0
SET @minstp = 0
WHILE 1=1
BEGIN
   SELECT @minstp = Min(stp_mfh_sequence)
     FROM stops
    WHERE lgh_number = @lgh_number AND
          ord_hdrnumber > 0 AND
          stp_mfh_sequence > @minstp

   IF @minstp IS NULL
      BREAK
     
   SELECT @cmp_id = cmp_id,
          @cty_name = cty_name,
          @cty_state = cty_state,
          @cty_region1 = cty_region1,
          @stp_type = stp_type,
          @stp_sequence = stp_sequence,
          @stp_number = stp_number,
	  @stp_arrivaldate = stp_arrivaldate,
          @stp_departuredate = stp_departuredate,
          @stp_earliestdate = stp_schdtearliest,
          @stp_latestdate = stp_schdtlatest,
          @stp_mfh_sequence = stp_mfh_sequence
     FROM stops, city
    WHERE lgh_number = @lgh_number AND
          stp_mfh_sequence = @minstp AND
          stp_city = cty_code

   SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_OrderID'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @ord_number)
   SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_AreaID'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @cty_region1)
   SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_StopID'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @stp_mfh_sequence)
   SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_StopType'
   IF @stp_type = 'PUP' 
      INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', 'PICK')
   IF @stp_type = 'DRP'
      INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', 'DROP')
   IF @cmp_id <> 'UNKNOWN'
   BEGIN
      SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_LocationID'
      INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @cmp_id)
   END
   SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_CityName'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @cty_name)
   SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_RegionCode'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @cty_state)
   SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_WindowStart'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', CONVERT(varchar, @stp_earliestdate, 20))
   SET @fieldname = 'Stop' + LTRIM(STR(@ctr)) + '_WindowEnd'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', CONVERT(varchar, @stp_latestdate, 20))
   
   SET @ctr = @ctr + 1
END

INSERT INTO m2msgqdtl VALUES (@m2qhid, 'Timestamp', 'HIL', CONVERT(varchar, @now, 20))
   
INSERT INTO m2msgqhdr VALUES (@m2qhid, 'Dispatch', @now, 'R')
GO
GRANT EXECUTE ON  [dbo].[maptuit_dispatch] TO [public]
GO
