SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 30864 JJF 12/7/05 - added @ord_number
--PTS 40677 JJF 20070110 -- rewrote to streamline criteria

CREATE PROCEDURE [dbo].[d_scroll_master_orders_toe] (
	@delivery_date		DATETIME,					--not used
	@shipper		VARCHAR(8),
	@shipper_city		INTEGER,
	@consignee		VARCHAR(8),
	@consignee_city		INTEGER,
	@commodity		VARCHAR(8),
	@billto			VARCHAR(8),
	@orderedby		VARCHAR(8),
	@revtype1		VARCHAR(6),
	@revtype2		VARCHAR(6),
	@revtype3		VARCHAR(6),
	@revtype4		VARCHAR(6),
	@ref_type		VARCHAR(6),
	@ref_number		VARCHAR(30),
	@ord_number		VARCHAR(12),
	-- KMM PTS 33283, add ord_status as criteria
	@ord_status		varchar(255) = 'ALL'
)

AS
/* Change Control

03/28/2005	KWS	PTS 26613 - Allow reference numbers to be apart of search criteria

*/


	DECLARE @SQLString NVARCHAR(4000)
	DECLARE @SelectList NVARCHAR(4000)
	DECLARE @FromClause NVARCHAR(4000)
	DECLARE @WhereClause NVARCHAR(4000)
	DECLARE @ParmDefinition NVARCHAR(1000)
	DECLARE @Crlf as CHAR(1)
	DECLARE @Debug as CHAR(1)

	--PTS 44203 JJF 20090826
	DECLARE @ref_type_displayed VARCHAR(6)
	--PTS 44203 JJF 20090826
	
	SET @Debug = 'N'
	SET @Crlf = char(10) 

	SELECT @ord_status = ',' + isnull(@ord_status, 'ALL') + ','

	-- KMM PTS 33283, add ord_status as criteria
	IF @ord_status = ',ALL,' BEGIN
		SELECT @ord_status = ',MST,QTE,'
	END
	-- END PTS 33283

	SELECT	@revtype1 = ISNULL(@revtype1, 'UNK'),
			@revtype2 = ISNULL(@revtype2, 'UNK'),
			@revtype3 = ISNULL(@revtype3, 'UNK'),
			@revtype4 = ISNULL(@revtype4, 'UNK'),
			@shipper = ISNULL(@shipper, 'UNKNOWN'), 
			@consignee = ISNULL(@consignee, 'UNKNOWN'), 
			@billto = ISNULL(@billto, 'UNKNOWN'), 
			@orderedby = ISNULL(@orderedby, 'UNKNOWN'),
			@commodity = ISNULL(@commodity, 'UNKNOWN'), 
			@shipper_city = ISNULL(@shipper_city, 0), 
			@consignee_city = ISNULL(@consignee_city, 0),
			@ref_number = ISNULL(RTRIM(LTRIM(@ref_number)),'') + '%',
			@ref_type = ISNULL(@ref_type, 'UNK'),
			@ord_number = ISNULL(RTRIM(LTRIM(@ord_number)), '')  

	--PTS 44203 JJF 20090826
	--So only one is displayed
	SELECT @ref_type_displayed = @ref_type 
	--END PTS 44203 JJF 20090826
	
	IF @ref_number = '%' BEGIN
		SET @ref_type = 'UNK'
	END 

	SET @SelectList = 
			--PTS 44203 JJF 2009Add distinct 
			'SELECT	DISTINCT oh.ord_number,' + @Crlf +
			--'SELECT	oh.ord_number,' + @Crlf +
			--END PTS 44203 JJF 2009Add distinct 
					'oh.ord_hdrnumber,' + @Crlf +
					'oh.cmd_code,' + @Crlf +
					'oh.ord_shipper,' + @Crlf +
					'oh.ord_consignee,' + @Crlf +
					'oh.ord_billto,' + @Crlf +
					'oh.ord_company,' + @Crlf +
					'''RevType1'' revtype1_t,' + @Crlf +
					'oh.ord_revtype1,' + @Crlf +
					'''RevType2'' revtype2_t,' + @Crlf +
					'oh.ord_revtype2,' + @Crlf +
					'''RevType3'' revtype3_t,' + @Crlf +
					'oh.ord_revtype3,' + @Crlf +
					'''RevType4'' revtype4_t,' + @Crlf +
					'oh.ord_revtype4,' + @Crlf +
					'shipper.cmp_city shipper_city,' + @Crlf +
					'consignee.cmp_city consignee_city,' + @Crlf +
					--PTS 44203 JJF 20090826
					'r.ref_type ref_type,' + @Crlf +
					--'@ref_type ref_type,' + @Crlf +
					--END PTS 44203 JJF 20090826
					'r.ref_number ref_number,' + @Crlf +
					'shipper.cmp_address1 shipper_address,' + @Crlf +
					'consignee.cmp_address1 consignee_address,' + @Crlf +
					'shipper.cmp_name shipper_name,' + @Crlf +
					'consignee.cmp_name consignee_name,' + @Crlf +
					'cmd.cmd_name cmd_name,' + @Crlf +
					'CAST(oh.mov_number AS VARCHAR(12)) string_mov_number,' + @Crlf +
					'oh.ord_quantity,' + @Crlf +
					'oh.ord_unit,' + @Crlf +
					'oh.cht_itemcode,' + @Crlf +
					'oh.ord_rate,' + @Crlf +
					'oh.ord_remark,' + @Crlf +
					'oh.tar_number,' + @Crlf +
					'oh.ord_bookedby,' + @Crlf +
					'oh.ord_bookdate,' + @Crlf +
					'oh.ord_status,' + @Crlf +
					'oh.ord_terms,' + @Crlf +
					'ship_city.cty_name AS ''ship_citynm'',' + @Crlf +
					'cons_city.cty_name AS ''cons_citynm''' 

	SET @FromClause =
			  'FROM	orderheader oh WITH (NOLOCK)' + @Crlf +
						'INNER JOIN company shipper WITH (NOLOCK) ON shipper.cmp_id = oh.ord_shipper ' + @Crlf +
						'INNER JOIN company consignee WITH (NOLOCK) ON consignee.cmp_id = oh.ord_consignee' + @Crlf +
						'INNER JOIN commodity cmd WITH (NOLOCK) ON oh.cmd_code = cmd.cmd_code' + @Crlf +
						'Inner Join city ship_city WITH (NOLOCK) on ship_city.cty_code = shipper.cmp_city' + @Crlf +
						'Inner Join city cons_city WITH (NOLOCK) on cons_city.cty_code = consignee.cmp_city' + @Crlf +
						'LEFT OUTER JOIN referencenumber r WITH (NOLOCK) ON r.ref_tablekey = oh.ord_hdrnumber AND' + @Crlf +
												'r.ref_number LIKE @ref_number AND' + @Crlf +
												--PTS 44203 JJF 2009
												--'r.ref_type = CASE @ref_type WHEN ''UNK'' THEN r.ref_type ELSE @ref_type END'
												'r.ref_type = CASE @ref_type_displayed WHEN ''UNK'' THEN r.ref_type ELSE @ref_type_displayed END'
												--END PTS 44203 JJF 2009

	SET @WhereClause = 'WHERE 1=1 '

	IF @ord_number <> '' BEGIN
		SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_number = @ord_number)'
	END
	ELSE BEGIN	
		IF @shipper <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_shipper = @shipper)'
		END
		IF @shipper_city <> 0 BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (shipper.cmp_city = @shipper_city)'
		END
		IF @consignee <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_consignee = @consignee)'
		END
		IF @consignee_city <> 0 BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (consignee.cmp_city = @consignee_city)'
		END
		IF @commodity <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.cmd_code = @commodity)'
		END
		IF @billto <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_billto = @billto)'
		END
		IF @orderedby <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_company = @orderedby)'
		END
		IF @revtype1 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_revtype1 = @revtype1)'
		END
		IF @revtype2 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_revtype2 = @revtype2)'
		END
		IF @revtype3 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_revtype3 = @revtype3)'
		END
		IF @revtype4 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_revtype4 = @revtype4)'
		END
		IF @ref_number <> '%' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND 				EXISTS(SELECT	1' + @Crlf +
							 'FROM	referencenumber r WITH (NOLOCK)' + @Crlf +
							'WHERE	 r.ref_type = CASE @ref_type WHEN ''UNK'' THEN r.ref_type ELSE @ref_type END AND' + @Crlf +
									 'r.ref_number LIKE @ref_number AND' + @Crlf +
									 'r.ref_tablekey = oh.ord_hdrnumber AND' + @Crlf +
									 'r.ref_table = ''orderheader'')' 
		END
		--PTS 45097 JJF 20090114 In order to facilitate preventing retrieval of orders of a particular type, use status passed in
		--SET @WhereClause = @WhereClause + @Crlf + 'AND charindex('','' + oh.ord_status + '','', @ord_status) > 0'
		--END PTS 45097 JJF 20090114 In order to facilitate preventing retrieval of orders of a particular type, use status passed in
	END	
	--PTS 45097 JJF 20090114 In order to facilitate preventing retrieval of orders of a particular type, use status passed in
	--Always add criteria
	SET @WhereClause = @WhereClause + @Crlf + 'AND charindex('','' + oh.ord_status + '','', @ord_status) > 0'
	--END PTS 45097 JJF 20090114 In order to facilitate preventing retrieval of orders of a particular type, use status passed in
	--PTS 38816 JJF 20080312 add additional needed parms
	--PTS 51570 JJF 20100510 
	--SET @WhereClause = @WhereClause + @Crlf + 'AND dbo.RowRestrictByUser (ord_belongsto, '''', '''', '''') = 1'-- 12/12/2007 MDH PTS 40119: Added		
	SET @WhereClause = @WhereClause + @Crlf + 'AND dbo.RowRestrictByUser (''orderheader'', oh.rowsec_rsrv_id, '''', '''', '''') = 1'-- 12/12/2007 MDH PTS 40119: Added		

	SET @SQLString = @SelectList + @Crlf + @FromClause + @Crlf + @WhereClause

	SET @ParmDefinition = N'@delivery_date			DATETIME,' +
							'@shipper				VARCHAR(8),' +
							'@shipper_city			INTEGER,' +
							'@consignee				VARCHAR(8),' +
							'@consignee_city		INTEGER,' +
							'@commodity				VARCHAR(8),' +
							'@billto				VARCHAR(8),' +
							'@orderedby				VARCHAR(8),' +
							'@revtype1				VARCHAR(6),' +
							'@revtype2				VARCHAR(6),' +
							'@revtype3				VARCHAR(6),' +
							'@revtype4				VARCHAR(6),' +
							--PTS 44203 JJF 2009
							--'@ref_type			VARCHAR(6),' +
							'@ref_type_displayed	VARCHAR(6),' +
							--END PTS 44203 JJF 2009
							'@ref_number			VARCHAR(30),' +
							'@ord_number			VARCHAR(12),' +
							'@ord_status			varchar(255)'

	--denug generated sql stmt
	IF @Debug = 'Y' BEGIN
		PRINT @ParmDefinition
		PRINT @SQLString
	END
	


	EXECUTE sp_executesql @SQLString, @ParmDefinition,
			@delivery_date,
			@shipper,
			@shipper_city,
			@consignee,
			@consignee_city,
			@commodity,
			@billto,
			@orderedby,
			@revtype1,
			@revtype2,
			@revtype3,
			@revtype4,
			--PTS 44203 JJF 2009
			--@ref_type,
			--END PTS 44203 JJF 2009
			@ref_type_displayed,
			@ref_number,
			@ord_number,
			@ord_status

/*
--PTS 40677 JJF 20080130  above derived from:
	--PTS 34313 JJF 8/30/06
	--IF @ref_number = '%' AND @ref_type = 'UNK'
	--END PTS 34313 JJF 8/30/06
		SELECT	oh.ord_number,
				oh.ord_hdrnumber,
				oh.cmd_code,
				oh.ord_shipper,
				oh.ord_consignee,
				oh.ord_billto,
				oh.ord_company,
				'RevType1' revtype1_t,
				oh.ord_revtype1,
				'RevType2' revtype2_t,
				oh.ord_revtype2,
				'RevType3' revtype3_t,
				oh.ord_revtype3,
				'RevType4' revtype4_t,
				oh.ord_revtype4,
				shipper.cmp_city shipper_city,
				consignee.cmp_city consignee_city,
				@ref_type ref_type,
				'' ref_number,
				shipper.cmp_address1 shipper_address,
				consignee.cmp_address1 consignee_address,
				shipper.cmp_name shipper_name,
				consignee.cmp_name consignee_name,
				cmd.cmd_name cmd_name,
				CAST(oh.mov_number AS VARCHAR(12)) string_mov_number,
				--PTS XXXXX
				oh.ord_quantity,
				oh.ord_unit,
				oh.cht_itemcode,
				oh.ord_rate,
				oh.ord_remark,
				oh.tar_number,
				oh.ord_bookedby,
				oh.ord_bookdate,
				oh.ord_status,
				oh.ord_terms,
				ship_city.cty_name AS 'ship_citynm',
				cons_city.cty_name AS 'cons_citynm'
				--END PTS XXXXX
		  FROM	orderheader oh WITH (NOLOCK)
					INNER JOIN company shipper WITH (NOLOCK) ON shipper.cmp_id = oh.ord_shipper 
					INNER JOIN company consignee WITH (NOLOCK) ON consignee.cmp_id = oh.ord_consignee
					INNER JOIN commodity cmd WITH (NOLOCK) ON oh.cmd_code = cmd.cmd_code
					--PTS XXXXX
					Inner Join city ship_city WITH (NOLOCK) on ship_city.cty_code = shipper.cmp_city
					Inner Join city cons_city WITH (NOLOCK) on cons_city.cty_code = consignee.cmp_city
					--END PTS XXXXX
		 WHERE	(@ord_number = '') AND --PTS 34313 JJF 8/30/06
			(@ref_number = '%' AND @ref_type = 'UNK') AND --PTS 34313 JJF 8/30/06 
			--PTS 33283
			charindex(',' + oh.ord_status + ',', @ord_status) > 0 AND -- 33283
			--(oh.ord_status = 'MST') AND
			--END PTS 33283
	    	dbo.RowRestrictByUser (ord_belongsto) = 1	AND -- 12/12/2007 MDH PTS 40119: Added		
			(oh.ord_shipper = @shipper or @shipper = 'UNKNOWN') AND
			(shipper.cmp_city = @shipper_city OR @shipper_city = 0) AND
			(oh.ord_consignee = @consignee OR @consignee = 'UNKNOWN') AND
			(consignee.cmp_city = @consignee_city OR @consignee_city = 0) AND
			(oh.cmd_code = @commodity OR @commodity = 'UNKNOWN') AND
			(oh.ord_billto = @billto OR @billto = 'UNKNOWN') AND
			(oh.ord_company = @orderedby OR @orderedby = 'UNKNOWN') AND
			(oh.ord_revtype1 = @revtype1 OR @revtype1 = 'UNK') AND
			(oh.ord_revtype2 = @revtype2 OR @revtype2 = 'UNK') AND
			(oh.ord_revtype3 = @revtype3 OR @revtype3 = 'UNK') AND
			(oh.ord_revtype4 = @revtype4 OR @revtype4 = 'UNK') 
			--(oh.ord_number = @ord_number or @ord_number = '') --PTS 34313 JJF 8/30/06
	
	--PTS 34313 JJF 8/30/06
	--ELSE
	UNION
	--END PTS 34313 JJF 8/30/06
		SELECT	oh.ord_number,
				oh.ord_hdrnumber,
				oh.cmd_code,
				oh.ord_shipper,
				oh.ord_consignee,
				oh.ord_billto,
				oh.ord_company,
				'RevType1' revtype1_t,
				oh.ord_revtype1,
				'RevType2' revtype2_t,
				oh.ord_revtype2,
				'RevType3' revtype3_t,
				oh.ord_revtype3,
				'RevType4' revtype4_t,
				oh.ord_revtype4,
				shipper.cmp_city shipper_city,
				consignee.cmp_city consignee_city,
				@ref_type ref_type,
				r.ref_number ref_number,
				shipper.cmp_address1 shipper_address,
				consignee.cmp_address1 consignee_address,
				shipper.cmp_name shipper_name,
				consignee.cmp_name consignee_name,
				cmd.cmd_name cmd_name,
				CAST(oh.mov_number AS VARCHAR(12)) string_mov_number,
				--PTS XXXXX
				oh.ord_quantity,
				oh.ord_unit,
				oh.cht_itemcode,
				oh.ord_rate,
				oh.ord_remark,
				oh.tar_number,
				oh.ord_bookedby,
				oh.ord_bookdate,
				oh.ord_status,
				oh.ord_terms,
				ship_city.cty_name AS 'ship_citynm',
				cons_city.cty_name AS 'cons_citynm'
				--END PTS XXXXX
		  FROM	orderheader oh WITH (NOLOCK)
					INNER JOIN company shipper WITH (NOLOCK) ON shipper.cmp_id = oh.ord_shipper 
					INNER JOIN company consignee WITH (NOLOCK) ON consignee.cmp_id = oh.ord_consignee
					INNER JOIN commodity cmd WITH (NOLOCK) ON oh.cmd_code = cmd.cmd_code
					--PTS XXXXX
					Inner Join city ship_city WITH (NOLOCK) on ship_city.cty_code = shipper.cmp_city
					Inner Join city cons_city WITH (NOLOCK) on cons_city.cty_code = consignee.cmp_city
					--END PTS XXXXX
					LEFT OUTER JOIN referencenumber r WITH (NOLOCK) ON r.ref_tablekey = oh.ord_hdrnumber AND
											r.ref_number LIKE @ref_number AND
											r.ref_type = CASE @ref_type WHEN 'UNK' THEN r.ref_type ELSE @ref_type END
		 WHERE		(@ord_number = '') AND --PTS 34313 JJF 8/30/06 
				NOT (@ref_number = '%' AND @ref_type = 'UNK') AND --PTS 34313 JJF 8/30/06 
				--PTS 33283
				charindex(',' + oh.ord_status + ',', @ord_status) > 0 AND -- 33283
				--(oh.ord_status = 'MST') AND
				--END PTS 33283
		    	dbo.RowRestrictByUser (ord_belongsto) = 1	AND -- 12/12/2007 MDH PTS 40119: Added		
				(oh.ord_shipper = @shipper or @shipper = 'UNKNOWN') AND
				(shipper.cmp_city = @shipper_city OR @shipper_city = 0) AND
				(oh.ord_consignee = @consignee OR @consignee = 'UNKNOWN') AND
				(consignee.cmp_city = @consignee_city OR @consignee_city = 0) AND
				(oh.cmd_code = @commodity OR @commodity = 'UNKNOWN') AND
				(oh.ord_billto = @billto OR @billto = 'UNKNOWN') AND
				(oh.ord_company = @orderedby OR @orderedby = 'UNKNOWN') AND
				(oh.ord_revtype1 = @revtype1 OR @revtype1 = 'UNK') AND
				(oh.ord_revtype2 = @revtype2 OR @revtype2 = 'UNK') AND
				(oh.ord_revtype3 = @revtype3 OR @revtype3 = 'UNK') AND
				(oh.ord_revtype4 = @revtype4 OR @revtype4 = 'UNK') AND
				--(oh.ord_number = @ord_number or @ord_number = '') AND
				EXISTS(SELECT	1
						 FROM	referencenumber r WITH (NOLOCK)
						WHERE	 r.ref_type = CASE @ref_type WHEN 'UNK' THEN r.ref_type ELSE @ref_type END AND
								 r.ref_number LIKE @ref_number AND
								 r.ref_tablekey = oh.ord_hdrnumber AND
								 r.ref_table = 'orderheader')
	--PTS 34313 JJF 8/30/06
	UNION
		SELECT	oh.ord_number,
				oh.ord_hdrnumber,
				oh.cmd_code,
				oh.ord_shipper,
				oh.ord_consignee,
				oh.ord_billto,
				oh.ord_company,
				'RevType1' revtype1_t,
				oh.ord_revtype1,
				'RevType2' revtype2_t,
				oh.ord_revtype2,
				'RevType3' revtype3_t,
				oh.ord_revtype3,
				'RevType4' revtype4_t,
				oh.ord_revtype4,
				shipper.cmp_city shipper_city,
				consignee.cmp_city consignee_city,
				@ref_type ref_type,
				'' ref_number,
				shipper.cmp_address1 shipper_address,
				consignee.cmp_address1 consignee_address,
				shipper.cmp_name shipper_name,
				consignee.cmp_name consignee_name,
				cmd.cmd_name cmd_name,
				CAST(oh.mov_number AS VARCHAR(12)) string_mov_number,
				--PTS XXXXX
				oh.ord_quantity,
				oh.ord_unit,
				oh.cht_itemcode,
				oh.ord_rate,
				oh.ord_remark,
				oh.tar_number,
				oh.ord_bookedby,
				oh.ord_bookdate,
				oh.ord_status,
				oh.ord_terms,
				ship_city.cty_name AS 'ship_citynm',
				cons_city.cty_name AS 'cons_citynm'
				--END PTS XXXXX
		  FROM	orderheader oh WITH (NOLOCK)
					INNER JOIN company shipper WITH (NOLOCK) ON shipper.cmp_id = oh.ord_shipper 
					INNER JOIN company consignee WITH (NOLOCK) ON consignee.cmp_id = oh.ord_consignee
					INNER JOIN commodity cmd WITH (NOLOCK) ON oh.cmd_code = cmd.cmd_code
					--PTS XXXXX
					Inner Join city ship_city WITH (NOLOCK) on ship_city.cty_code = shipper.cmp_city
					Inner Join city cons_city WITH (NOLOCK) on cons_city.cty_code = consignee.cmp_city
					--END PTS XXXXX
		 --PTS 33283
		 --WHERE	(oh.ord_status = 'MST') AND
			WHERE	charindex(',' + oh.ord_status + ',', @ord_status) > 0 AND -- 33283
		 --END PTS 33283
	    			dbo.RowRestrictByUser (ord_belongsto) = 1	AND -- 12/12/2007 MDH PTS 40119: Added		
					(oh.ord_number = @ord_number) AND (@ord_number <> '') 
	--END PTS 34313 JJF 8/30/06
*/
GO
GRANT EXECUTE ON  [dbo].[d_scroll_master_orders_toe] TO [public]
GO
