SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[d_carrierauction_list_sp]

	(
		@ID_type			int,
		@ID					varchar(255),
		@ca_statuslist		varchar(255),
		@Lane_Auction		char(1)					-- PTS 46628 new parameter
	)

AS

-- PTS 46628 Modified for Lane Auction Process

DECLARE @ord_number char(12)
DECLARE @lgh_number int
DECLARE @mov_number int
DECLARE @carrier_id varchar(8)

IF @ID_type = 1 BEGIN
	SELECT @ord_number = @ID
END 
ELSE IF @ID_type = 3 BEGIN
	SELECT @mov_number = convert(int, @ID)
END
ELSE IF @ID_type = 4 BEGIN
	SELECT @lgh_number = convert(int, @ID)
END
ELSE IF @ID_type = 9 BEGIN
	SELECT @carrier_id = @ID
END

-- PTS 46628 <<start>>
IF @Lane_Auction <> 'Y' and @Lane_Auction <> 'N' 
Begin
	select @Lane_Auction = 'N'
End

IF @Lane_auction <> 'Y' OR  (  @Lane_Auction = 'Y' and @ID_type <> 77 and @ID_type <> 88  ) 
BEGIN 
-- run ORIGINAL Code if Not lane auction
			SELECT  oh.ord_number, ca.ord_hdrnumber, ca.lgh_number, oh.mov_number, 
					oh.ord_originpoint, oh.ord_destpoint, 
					cty_origin.cty_nmstct AS origin_cty_nmstct, 
					cty_destination.cty_nmstct AS dest_cty_nmstct, 
					oh.ord_startdate, oh.ord_completiondate, 
					oh.ord_totalcharge, ca.ca_id, 
					ca.ca_description, ca.ca_status, oh.ord_billto
			FROM     carrierauctions AS ca INNER JOIN
						   orderheader AS oh ON ca.ord_hdrnumber = oh.ord_hdrnumber INNER JOIN
						   legheader AS lgh ON oh.ord_hdrnumber = lgh.ord_hdrnumber LEFT OUTER JOIN
						   city AS cty_destination ON oh.ord_destcity = cty_destination.cty_code LEFT OUTER JOIN
						   city AS cty_origin ON oh.ord_origincity = cty_origin.cty_code
			WHERE  (	(isnull(@ID, '') = '') OR
						(oh.ord_number = @ord_number) OR
						(lgh.lgh_number = @lgh_number) OR
						(lgh.mov_number	= @mov_number) OR
						(EXISTS(SELECT * 
								FROM carrierbids cb 
								WHERE cb.ca_id = ca.ca_id 
									AND cb.car_id = @carrier_id))
					)
						AND (CHARINDEX(',' + ca.ca_status + ',', ',' + @ca_statuslist + ',') > 0 or @ca_statuslist = '(all)')
						
END 					
							

IF @Lane_auction = 'Y' and @ID_type = 77		-- looking for master orders
BEGIN 
	-- 5-24-2010 Proc-bug fix <<start>>
	IF @ord_number is null
	begin
		select @ord_number = @ID
	end 	
	-- 5-24-2010 Proc-bug fix <<end>>
	
			SELECT  oh.ord_number, ca.ord_hdrnumber, ca.lgh_number, oh.mov_number, 
					oh.ord_originpoint, oh.ord_destpoint, 
					cty_origin.cty_nmstct AS origin_cty_nmstct, 
					cty_destination.cty_nmstct AS dest_cty_nmstct, 
					oh.ord_startdate, oh.ord_completiondate, 
					oh.ord_totalcharge, ca.ca_id, 
					ca.ca_description, ca.ca_status, oh.ord_billto, oh.ord_status
			FROM     carrierauctions AS ca INNER JOIN
						   orderheader AS oh ON ca.ord_hdrnumber = oh.ord_hdrnumber INNER JOIN
						   ----------------legheader AS lgh ON oh.ord_hdrnumber = lgh.ord_hdrnumber LEFT OUTER JOIN
						   city AS cty_destination ON oh.ord_destcity = cty_destination.cty_code LEFT OUTER JOIN
						   city AS cty_origin ON oh.ord_origincity = cty_origin.cty_code
			WHERE  (	(isnull(@ID, '') = '') OR
						(oh.ord_number = @ord_number) OR
						----------(lgh.lgh_number = @lgh_number) OR
						----------(lgh.mov_number	= @mov_number) OR
						(EXISTS(SELECT * 
								FROM carrierbids cb 
								WHERE cb.ca_id = ca.ca_id 
									AND cb.car_id = @carrier_id))									
					)
						AND (CHARINDEX(',' + ca.ca_status + ',', ',' + @ca_statuslist + ',') > 0 or @ca_statuslist = '(all)')
						AND ord_status = 'MST'
						
END 					
							


IF @Lane_auction = 'Y' and @ID_type = 88		-- looking for lane auction
BEGIN 
			SELECT  oh.ord_number, ca.ord_hdrnumber, ca.lgh_number, oh.mov_number, 
					oh.ord_originpoint, oh.ord_destpoint, 
					cty_origin.cty_nmstct AS origin_cty_nmstct, 
					cty_destination.cty_nmstct AS dest_cty_nmstct, 
					oh.ord_startdate, oh.ord_completiondate, 
					oh.ord_totalcharge, ca.ca_id, 
					ca.ca_description, ca.ca_status, oh.ord_billto, oh.ord_status
			FROM     carrierauctions AS ca INNER JOIN
						   orderheader AS oh ON ca.ord_hdrnumber = oh.ord_hdrnumber INNER JOIN
						   ----------------legheader AS lgh ON oh.ord_hdrnumber = lgh.ord_hdrnumber LEFT OUTER JOIN
						   city AS cty_destination ON oh.ord_destcity = cty_destination.cty_code LEFT OUTER JOIN
						   city AS cty_origin ON oh.ord_origincity = cty_origin.cty_code
			WHERE  (	(isnull(@ID, '') = '') OR
						( ca.ca_id = @ID ) OR			-- 5-24-2010 Proc-bug fix (won't find specified id)
						(oh.ord_number = @ord_number) OR
						----------(lgh.lgh_number = @lgh_number) OR
						----------(lgh.mov_number	= @mov_number) OR
						(EXISTS(SELECT * 
								FROM carrierbids cb 
								WHERE cb.ca_id = ca.ca_id 
									AND cb.car_id = @carrier_id))									
					)
						AND (CHARINDEX(',' + ca.ca_status + ',', ',' + @ca_statuslist + ',') > 0 or @ca_statuslist = '(all)')						
						AND ca.ca_createdby_lane_auction = 'Y'
END 					
							








-- PTS 46628 <<end>>

-- PTS 46628 Original Code commented out
--SELECT  oh.ord_number, ca.ord_hdrnumber, ca.lgh_number, oh.mov_number, oh.ord_originpoint, oh.ord_destpoint, cty_origin.cty_nmstct AS origin_cty_nmstct, cty_destination.cty_nmstct AS dest_cty_nmstct, oh.ord_startdate, 
--               oh.ord_completiondate, oh.ord_totalcharge, ca.ca_id, ca.ca_description, ca.ca_status, oh.ord_billto
--FROM     carrierauctions AS ca INNER JOIN
--               orderheader AS oh ON ca.ord_hdrnumber = oh.ord_hdrnumber INNER JOIN
--               legheader AS lgh ON oh.ord_hdrnumber = lgh.ord_hdrnumber LEFT OUTER JOIN
--               city AS cty_destination ON oh.ord_destcity = cty_destination.cty_code LEFT OUTER JOIN
--               city AS cty_origin ON oh.ord_origincity = cty_origin.cty_code
--WHERE  (	(isnull(@ID, '') = '') OR
--			(oh.ord_number = @ord_number) OR
--			(lgh.lgh_number = @lgh_number) OR
--			(lgh.mov_number	= @mov_number) OR
--			(EXISTS(SELECT * 
--					FROM carrierbids cb 
--					WHERE cb.ca_id = ca.ca_id 
--						AND cb.car_id = @carrier_id))
--		)
--			AND (CHARINDEX(',' + ca.ca_status + ',', ',' + @ca_statuslist + ',') > 0 or @ca_statuslist = '(all)')
		
				

GO
GRANT EXECUTE ON  [dbo].[d_carrierauction_list_sp] TO [public]
GO
