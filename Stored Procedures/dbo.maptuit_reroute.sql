SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[maptuit_reroute] @lgh_number INT
AS
DECLARE @now     		DATETIME,
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
        @stp_type		VARCHAR(6)

SET @now = GETDATE()
EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
INSERT INTO m2msgqdtl VALUES (@m2qhid, 'DispatchID', 'HIL', CONVERT(varchar, @lgh_number))

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
          @ord_hdrnumber = ord_hdrnumber,
          @stp_type = stp_type
     FROM stops, city
    WHERE lgh_number = @lgh_number AND
          stp_mfh_sequence = @minstp AND
          stp_city = cty_code
   SET @fieldname = 'RoutelinePoint' + LTRIM(STR(@ctr)) + '_CityName'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @cty_name)
   SET @fieldname = 'RoutelinePoint' + LTRIM(STR(@ctr)) + '_RegionCode'
   INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', @cty_state)
   SET @fieldname = 'RoutelinePoint' + LTRIM(STR(@ctr)) + '_RoutelinePointType'
   IF @stp_type = 'DRP'
      INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', 'LOADED')
   ELSE
      INSERT INTO m2msgqdtl VALUES (@m2qhid, @fieldname, 'HIL', 'EMPTY')

   SET @ctr = @ctr + 1
   
END

INSERT INTO m2msgqdtl VALUES(@m2qhid, 'Timestamp', 'HIL', CONVERT(varchar, GETDATE(), 20))
   
INSERT INTO m2msgqhdr VALUES (@m2qhid, 'Reroute', GETDATE(), 'R')
GO
GRANT EXECUTE ON  [dbo].[maptuit_reroute] TO [public]
GO
