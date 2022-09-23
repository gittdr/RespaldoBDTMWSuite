SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cmp_stop_airmiles] (@mov int) 
AS 
DECLARE @minmfh		integer,
		@stp_number	integer,
        @cmp_from	varchar (8),
        @cmp_to     varchar (8),
        @city_from  integer,
        @city_to	integer,
        @miles		decimal (10,2),
        @percent	decimal (10,4),
        @enabled	char (1),
        @mt_type	integer
SET NOCOUNT ON

SELECT @enabled = LEFT (gi_string1,1), @percent = ISNULL (gi_integer1, 20), @mt_type = ISNULL (gi_integer2, 5)
	FROM generalinfo 
	WHERE gi_name = 'CMPAirMiles'
IF @enabled IS NULL SELECT @enabled = 'N'
IF @enabled <> 'Y' RETURN
SELECT @percent = ISNULL (@percent, 20) / 100.0 + 1.0
SELECT @minmfh = 0

WHILE ( SELECT COUNT(*) FROM stops WHERE stp_mfh_sequence > @minmfh AND mov_number = @mov) > 0
BEGIN /* while stops to process */
	SELECT @minmfh = MIN (stp_mfh_sequence) 
		FROM stops
		WHERE stp_mfh_sequence > @minmfh
		AND mov_number = @mov
	SELECT @stp_number = stp_number, @cmp_to = cmp_id, @city_to = stp_city
		FROM stops
		WHERE stp_mfh_sequence = @minmfh
		AND mov_number = @mov
	IF @minmfh > 1
	BEGIN
		-- Check for cached miles
		SELECT @miles = NULL
		SELECT TOP 1 @miles = mt_miles 
			FROM mileagetable
			WHERE mt_type = @mt_type 
			AND mt_origintype = 'M' 
			AND mt_destinationtype = 'M'
			AND mt_origin = @cmp_from
			AND mt_destination = @cmp_to
		IF @miles IS NULL
			SELECT TOP 1 @miles = mt_miles 
				FROM mileagetable
				WHERE mt_type = @mt_type 
				AND mt_origintype = 'M' 
				AND mt_destinationtype = 'M'
				AND mt_origin = @cmp_to
				AND mt_destination = @cmp_from
		IF @miles IS NULL
			SELECT @miles = ROUND (dbo.cmp_airdistance (@cmp_from, @city_from, @cmp_to, @city_to) * @percent, 0)
		UPDATE stops 
			SET stp_lgh_mileage = @miles, 
				stp_ord_mileage = (CASE ord_hdrnumber WHEN 0 THEN 0 ELSE @miles END)
			WHERE stp_number = @stp_number
	END /* IF @minmfh > 1 */
	SELECT @cmp_from = @cmp_to, @city_from = @city_to
END /* while loop */
GO
GRANT EXECUTE ON  [dbo].[cmp_stop_airmiles] TO [public]
GO
