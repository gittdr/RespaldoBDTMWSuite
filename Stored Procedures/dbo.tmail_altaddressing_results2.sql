SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 03/2/00 MZ: */
CREATE PROCEDURE [dbo].[tmail_altaddressing_results2] 
						@tractor varchar(8),
 						@driver varchar (8),
						@msgdate datetime,
						@scheme varchar (5),
                        @ordnum varchar(8)
AS

SET NOCOUNT ON 

DECLARE @teamleader char(6),
	@lgh_date datetime,
	@lgh_number int,
	@ord int,
	@region varchar(6),
	@revtype1 varchar(6),
	@revtype2 varchar(6),
	@shipper varchar(25), --PTS 61189 INCREASE LENGTH TO 25
	@shippercity int, 
	@cmpid varchar(25), --PTS 61189 INCREASE LENGTH TO 25
	@cmpidcity int,
	@revtype3 varchar(6),
	@revtype4 varchar(6),
	@destcity int


-- Create temp table to hold results
CREATE TABLE #temp (address varchar(255))

--Check to see if there are any no comparison returns
INSERT INTO #temp (address)
(SELECT alta_address
 FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
 WHERE altt_type = 'None' 
  AND altt_number = alta_type
  AND alta_scheme = @scheme)

-- Check teamleader routing
-- First find the teamleader for this driver
SELECT @teamleader = ''
SELECT @teamleader = ISNULL(mpp_teamleader,'')
FROM manpowerprofile (NOLOCK)
WHERE mpp_id = @driver

IF (@teamleader <> '') 
  INSERT INTO #temp (address)
  (SELECT alta_address
   FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
   WHERE altt_type = 'mpp_teamleader' 
    AND altt_number = alta_type
    AND alta_value = @teamleader
    AND alta_scheme = @scheme)

-- Check driver specific routing
INSERT INTO #temp (address)
(SELECT alta_address
 FROM altaddressing (NOLOCK), altaddressingtypes  (NOLOCK)
 WHERE altt_type = 'mpp_id' 
  AND altt_number = alta_type
  AND alta_value = @driver
  AND alta_scheme = @scheme)

-- Check tractor specific routing
INSERT INTO #temp (address)
(SELECT alta_address
 FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
 WHERE altt_type = 'trc_number'  
  AND altt_number = alta_type
  AND alta_value = @tractor
  AND alta_scheme = @scheme)

-- Check origin region routing
-- Find the current order for this driver
SELECT @Ord = 0
IF ISNULL(@OrdNum, '') <> ''
	SELECT @Ord = ord_hdrnumber 
	FROM orderheader (NOLOCK) 
	WHERE ord_number = @OrdNum
IF ISNULL(@Ord, 0) = 0
	EXECUTE @ord = dbo.tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Find the ord_shipper
	SELECT @shipper = ISNULL(ord_shipper,'UNKNOWN'),  @shippercity = ISNULL(ord_origincity, 0)
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord
	
	IF (@shipper <> 'UNKNOWN') OR (@shippercity <> 0)
	  BEGIN
		-- Look up cty_region1
		SELECT @region = 'UNK'
		IF (@shipper <> 'UNKNOWN')
			SELECT @region = ISNULL(cty_region1,'UNK')
				FROM city(NOLOCK) , company (NOLOCK)
				WHERE cmp_id = @shipper
					AND city.cty_code = company.cmp_city

		-- if shipper not found then see if we can find just the city for the shipper DWG {37382}
		IF (@region = 'UNK') AND (@shippercity <> 0)
			SELECT @region = ISNULL(cty_region1,'UNK')
				FROM city (NOLOCK)
				WHERE city.cty_code = @shippercity

		-- Check alternate addressing and insert address if necessary
		-- Allow the user to set alternate addressing for UNK
		INSERT INTO #temp (address)
		(SELECT alta_address
			 FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
			 WHERE altt_type = 'ord_originregion1' 
			  AND altt_number = alta_type
			  AND alta_value = @region
			  AND alta_scheme = @scheme)	
	  END
  END

-- Check origin region2 routing
-- Find the current order for this driver
SELECT @Ord = 0
IF ISNULL(@OrdNum, '') <> ''
	SELECT @Ord = ord_hdrnumber 
	FROM orderheader (NOLOCK)
	where ord_number = @OrdNum
IF ISNULL(@Ord, 0) = 0
	EXECUTE @ord = dbo.tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Find the ord_shipper
	SELECT @shipper = ISNULL(ord_shipper,'UNKNOWN'),  @shippercity = ISNULL(ord_origincity, 0)
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord
	
	IF (@shipper <> 'UNKNOWN') OR (@shippercity <> 0)
	  BEGIN
		-- Look up cty_region2
		SELECT @region = 'UNK'
		IF (@shipper <> 'UNKNOWN')
			SELECT @region = ISNULL(cty_region2,'UNK')
				FROM city (NOLOCK), company (NOLOCK)
				WHERE cmp_id = @shipper
					AND city.cty_code = company.cmp_city

		-- if shipper not found then see if we can find just the city for the shipper DWG {37382}
		IF (@region = 'UNK') AND (@shippercity <> 0)
			SELECT @region = ISNULL(cty_region2,'UNK')
				FROM city (NOLOCK)
				WHERE city.cty_code = @shippercity

		-- Check alternate addressing and insert address if necessary
		-- Allow the user to set alternate addressing for UNK
		INSERT INTO #temp (address)
		(SELECT alta_address
			 FROM altaddressing (NOLOCK), altaddressingtypes  (NOLOCK)
			 WHERE altt_type = 'ord_originregion2' 
			  AND altt_number = alta_type
			  AND alta_value = @region
			  AND alta_scheme = @scheme)	
	  END
  END


-- Check origin region3 routing
-- Find the current order for this driver
SELECT @Ord = 0
IF ISNULL(@OrdNum, '') <> ''
	SELECT @Ord = ord_hdrnumber 
	FROM orderheader (NOLOCK) 
	where ord_number = @OrdNum
IF ISNULL(@Ord, 0) = 0
	EXECUTE @ord = dbo.tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Find the ord_shipper
	SELECT @shipper = ISNULL(ord_shipper,'UNKNOWN'),  @shippercity = ISNULL(ord_origincity, 0)
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord
	
	IF (@shipper <> 'UNKNOWN') OR (@shippercity <> 0)
	  BEGIN
		-- Look up cty_region3
		SELECT @region = 'UNK'
		IF (@shipper <> 'UNKNOWN')
			SELECT @region = ISNULL(cty_region3,'UNK')
				FROM city (NOLOCK), company (NOLOCK)
				WHERE cmp_id = @shipper
					AND city.cty_code = company.cmp_city

		-- if shipper not found then see if we can find just the city for the shipper DWG {37382}
		IF (@region = 'UNK') AND (@shippercity <> 0)
			SELECT @region = ISNULL(cty_region3,'UNK')
				FROM city (NOLOCK)
				WHERE city.cty_code = @shippercity

		-- Check alternate addressing and insert address if necessary
		-- Allow the user to set alternate addressing for UNK
		INSERT INTO #temp (address)
		(SELECT alta_address
			 FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
			 WHERE altt_type = 'ord_originregion3' 
			  AND altt_number = alta_type
			  AND alta_value = @region
			  AND alta_scheme = @scheme)	
	  END
  END

-- Check origin region4 routing
-- Find the current order for this driver
SELECT @Ord = 0
IF ISNULL(@OrdNum, '') <> ''
	SELECT @Ord = ord_hdrnumber 
	FROM orderheader (NOLOCK)
	where ord_number = @OrdNum
IF ISNULL(@Ord, 0) = 0
	EXECUTE @ord = dbo.tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Find the ord_shipper
	SELECT @shipper = ISNULL(ord_shipper,'UNKNOWN'),  @shippercity = ISNULL(ord_origincity, 0)
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord
	
	IF (@shipper <> 'UNKNOWN') OR (@shippercity <> 0)
	  BEGIN
		-- Look up cty_region4
		SELECT @region = 'UNK'
		IF (@shipper <> 'UNKNOWN')
			SELECT @region = ISNULL(cty_region4,'UNK')
				FROM city (NOLOCK), company (NOLOCK)
				WHERE cmp_id = @shipper
					AND city.cty_code = company.cmp_city

		-- if shipper not found then see if we can find just the city for the shipper DWG {37382}
		IF (@region = 'UNK') AND (@shippercity <> 0)
			SELECT @region = ISNULL(cty_region4,'UNK')
				FROM city (NOLOCK)
				WHERE city.cty_code = @shippercity

		-- Check alternate addressing and insert address if necessary
		-- Allow the user to set alternate addressing for UNK
		INSERT INTO #temp (address)
		(SELECT alta_address
			 FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
			 WHERE altt_type = 'ord_originregion4' 
			  AND altt_number = alta_type
			  AND alta_value = @region
			  AND alta_scheme = @scheme)	
	  END
  END

-- Check ord_destregion1 routing
-- Find the current order for this driver
SELECT @Ord = 0
IF ISNULL(@OrdNum, '') <> ''
	SELECT @Ord = ord_hdrnumber 
	FROM orderheader (NOLOCK)
	where ord_number = @OrdNum
IF ISNULL(@Ord, 0) = 0
	EXECUTE @ord = dbo.tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Find the ord_shipper
	SELECT @cmpid = ISNULL(ord_destpoint,'UNKNOWN'), @destcity = ISNULL(ord_destcity, 0)
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord
		
	IF (@cmpid <> 'UNKNOWN') OR (@destcity <> 0)
	  BEGIN
		-- Look up cty_region1
		SELECT @region = 'UNK'
		IF (@cmpid <> 'UNKNOWN')
			SELECT @region = ISNULL(cty_region1,'UNK')
				FROM city (NOLOCK), company (NOLOCK)
				WHERE cmp_id = @cmpid
					AND city.cty_code = company.cmp_city

		-- if destination not found then see if we can find just the city for the destination - DWG {37382}
		IF (@region = 'UNK') AND (@destcity <> 0)
			SELECT @region = ISNULL(cty_region1,'UNK')
				FROM city (NOLOCK)
				WHERE city.cty_code = @destcity

		-- Check alternate addressing and insert address if necessary
		-- Allow the user to set alternate addressing for UNK
		INSERT INTO #temp (address)
		(SELECT alta_address
			 FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
			 WHERE altt_type = 'ord_destregion1' 
			  AND altt_number = alta_type
			  AND alta_value = @region
			  AND alta_scheme = @scheme)	
	  END
  END

-- Check ord_destregion2 routing
-- Find the current order for this driver
SELECT @Ord = 0
IF ISNULL(@OrdNum, '') <> ''
	SELECT @Ord = ord_hdrnumber 
	FROM orderheader (NOLOCK) 
	where ord_number = @OrdNum
IF ISNULL(@Ord, 0) = 0
	EXECUTE @ord = dbo.tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Find the ord_shipper
	SELECT @cmpid = ISNULL(ord_destpoint,'UNKNOWN'), @destcity = ISNULL(ord_destcity, 0)
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord
		
	IF (@cmpid <> 'UNKNOWN') OR (@destcity <> 0)
	  BEGIN
		-- Look up cty_region2
		SELECT @region = 'UNK'
		IF (@cmpid <> 'UNKNOWN')
			SELECT @region = ISNULL(cty_region2,'UNK')
				FROM city (NOLOCK), company (NOLOCK)
				WHERE cmp_id = @cmpid
					AND city.cty_code = company.cmp_city

		-- if destination not found then see if we can find just the city for the destination - DWG {37382}
		IF (@region = 'UNK') AND (@destcity <> 0)
			SELECT @region = ISNULL(cty_region2,'UNK')
				FROM city (NOLOCK)
				WHERE city.cty_code = @destcity

		-- Check alternate addressing and insert address if necessary
		-- Allow the user to set alternate addressing for UNK
		INSERT INTO #temp (address)
		(SELECT alta_address
			 FROM altaddressing (NOLOCK), altaddressingtypes  (NOLOCK)
			 WHERE altt_type = 'ord_destregion2' 
			  AND altt_number = alta_type
			  AND alta_value = @region
			  AND alta_scheme = @scheme)	
	  END
  END

-- Check ord_destregion3 routing
-- Find the current order for this driver
SELECT @Ord = 0
IF ISNULL(@OrdNum, '') <> ''
	SELECT @Ord = ord_hdrnumber 
	FROM orderheader (NOLOCK) 
	where ord_number = @OrdNum
IF ISNULL(@Ord, 0) = 0
	EXECUTE @ord = dbo.tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Find the ord_shipper
	SELECT @cmpid = ISNULL(ord_destpoint,'UNKNOWN'), @destcity = ISNULL(ord_destcity, 0)
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord
		
	IF (@cmpid <> 'UNKNOWN') OR (@destcity <> 0)
	  BEGIN
		-- Look up cty_region3
		SELECT @region = 'UNK'
		IF (@cmpid <> 'UNKNOWN')
			SELECT @region = ISNULL(cty_region3,'UNK')
				FROM city (NOLOCK), company (NOLOCK)
				WHERE cmp_id = @cmpid
					AND city.cty_code = company.cmp_city

		-- if destination not found then see if we can find just the city for the destination - DWG {37382}
		IF (@region = 'UNK') AND (@destcity <> 0)
			SELECT @region = ISNULL(cty_region3,'UNK')
				FROM city
				WHERE city.cty_code = @destcity

		-- Check alternate addressing and insert address if necessary
		-- Allow the user to set alternate addressing for UNK
		INSERT INTO #temp (address)
		(SELECT alta_address
			 FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
			 WHERE altt_type = 'ord_destregion3' 
			  AND altt_number = alta_type
			  AND alta_value = @region
			  AND alta_scheme = @scheme)	
	  END
  END

-- Check ord_destregion4 routing
-- Find the current order for this driver
SELECT @Ord = 0
IF ISNULL(@OrdNum, '') <> ''
	SELECT @Ord = ord_hdrnumber 
	FROM orderheader (NOLOCK)
	where ord_number = @OrdNum
IF ISNULL(@Ord, 0) = 0
	EXECUTE @ord = dbo.tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Find the ord_shipper
	SELECT @cmpid = ISNULL(ord_destpoint,'UNKNOWN'), @destcity = ISNULL(ord_destcity, 0)
	FROM orderheader (NOLOCK)
	WHERE ord_hdrnumber = @ord
		
	IF (@cmpid <> 'UNKNOWN') OR (@destcity <> 0)
	  BEGIN
		-- Look up cty_region4
		SELECT @region = 'UNK'
		IF (@cmpid <> 'UNKNOWN')
			SELECT @region = ISNULL(cty_region4,'UNK')
				FROM city (NOLOCK), company (NOLOCK)
				WHERE cmp_id = @cmpid
					AND city.cty_code = company.cmp_city

		-- if destination not found then see if we can find just the city for the destination - DWG {37382}
		IF (@region = 'UNK') AND (@destcity <> 0)
			SELECT @region = ISNULL(cty_region4,'UNK')
				FROM city (NOLOCK)
				WHERE city.cty_code = @destcity

		-- Check alternate addressing and insert address if necessary
		-- Allow the user to set alternate addressing for UNK
		INSERT INTO #temp (address)
		(SELECT alta_address
			 FROM altaddressing (NOLOCK), altaddressingtypes  (NOLOCK)
			 WHERE altt_type = 'ord_destregion4' 
			  AND altt_number = alta_type
			  AND alta_value = @region
			  AND alta_scheme = @scheme)	
	  END
  END

-- Check ord_revtype1 specific routing
-- Find the current order for this driver
-- This has already been done! EXECUTE @ord = tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > -1
  BEGIN
	-- Look up ord_revtype1
	SELECT @revtype1 = ''
		SELECT @revtype1 = ISNULL(ord_revtype1, '')
		FROM orderheader (NOLOCK)
		WHERE ord_hdrnumber = @ord

		-- Check alternate addressing
		IF (@revtype1 <> '') 
			INSERT INTO #temp (address)
			(SELECT alta_address
			FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK) 
			WHERE altt_type = 'OrderRevType1' 
			  AND altt_number = alta_type
			  AND alta_value = @revtype1
			  AND alta_scheme = @scheme)				
  END		

-- Check ord_revtype2 specific routing
-- Find the current order for this driver
-- This has already been done! EXECUTE @ord = tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Look up ord_revtype2
	SELECT @revtype2 = ''
		SELECT @revtype2 = ISNULL(ord_revtype2, '')
		FROM orderheader  (NOLOCK)
		WHERE ord_hdrnumber = @ord

		-- Check alternate addressing
		IF (@revtype2 <> '') 
			INSERT INTO #temp (address)
			(SELECT alta_address
			FROM altaddressing (NOLOCK), altaddressingtypes  (NOLOCK)
			WHERE altt_type = 'OrderRevType2' 
			  AND altt_number = alta_type
			  AND alta_value = @revtype2
			  AND alta_scheme = @scheme)				
  END		
	
-- Check ord_revtype3 specific routing
-- Find the current order for this driver
-- This has already been done! EXECUTE @ord = tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Look up ord_revtype3
	SELECT @revtype3 = ''
		SELECT @revtype3 = ISNULL(ord_revtype3, '')
		FROM orderheader (NOLOCK)
		WHERE ord_hdrnumber = @ord

		-- Check alternate addressing
		IF (@revtype3 <> '') 
			INSERT INTO #temp (address)
			(SELECT alta_address
			FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
			WHERE altt_type = 'OrderRevType3' 
			  AND altt_number = alta_type
			  AND alta_value = @revtype3
			  AND alta_scheme = @scheme)				
  END		

-- Check ord_revtype4 specific routing
-- Find the current order for this driver
-- This has already been done! EXECUTE @ord = tmail_get_cur_ordnumber @tractor, @msgdate
IF @ord > 0 
  BEGIN
	-- Look up ord_revtype4
	SELECT @revtype4 = ''
		SELECT @revtype4 = ISNULL(ord_revtype4, '')
		FROM orderheader (NOLOCK)
		WHERE ord_hdrnumber = @ord

		-- Check alternate addressing
		IF (@revtype4 <> '') 
			INSERT INTO #temp (address)
			(SELECT alta_address
			FROM altaddressing (NOLOCK), altaddressingtypes (NOLOCK)
			WHERE altt_type = 'OrderRevType4' 
			  AND altt_number = alta_type
			  AND alta_value = @revtype4
			  AND alta_scheme = @scheme)				
  END		

-- Return the results
SELECT DISTINCT(address) 
FROM #temp
ORDER BY address
GO
GRANT EXECUTE ON  [dbo].[tmail_altaddressing_results2] TO [public]
GO
