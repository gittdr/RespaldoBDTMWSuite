SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46118 JJF 20090602 Derived from d_scroll_master_orders_toe

CREATE PROCEDURE [dbo].[d_freight_managment_planning_masters] (
	@shipper			VARCHAR(8),
	@shipper_city		INTEGER,
	@consignee			VARCHAR(8),
	@consignee_city		INTEGER,
	@commodity			VARCHAR(8),
	@billto				VARCHAR(8),
	@orderedby			VARCHAR(8),
	@revtype1			VARCHAR(6),
	@revtype2			VARCHAR(6),
	@revtype3			VARCHAR(6),
	@revtype4			VARCHAR(6),
	@ref_type			VARCHAR(6),
	@ref_number			VARCHAR(30),
	@ord_number			VARCHAR(12),
	@ord_status			varchar(255) = 'ALL',
	@delivery_date_from	DATETIME,					
	@delivery_date_to	DATETIME,		
	@pickup_date_from	DATETIME,
	@pickup_date_to		DATETIME,
	@toem_plan_status	varchar(255) = 'ALL',
	@ce_contact_type	varchar(6),
	@ce_contact_name	varchar(30),
	@ce_phone			varchar(20),
	@ce_email			varchar(50),
	@trl_type1			varchar(6),
	@trl_type2			varchar(6),
	@trl_type3			varchar(6),
	@trl_type4			varchar(6), 
	@notes				varchar(254)

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

	DECLARE @ref_type_displayed VARCHAR(6)

	SET @Debug = 'N'
	SET @Crlf = char(10)

	SELECT @ord_status = ',' + isnull(@ord_status, 'ALL') + ','
	SELECT @toem_plan_status = ',' + isnull(@toem_plan_status, 'ALL') + ','

	-- KMM PTS 33283, add ord_status as criteria
	IF @ord_status = ',ALL,' BEGIN
		SELECT @ord_status = ',MST,QTE,PLM,'
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
			@ord_number = ISNULL(RTRIM(LTRIM(@ord_number)), ''),
			@ce_contact_type = isnull(@ce_contact_type, 'UNK'),
			@ce_contact_name = isnull(@ce_contact_name, ''),
			@ce_phone = isnull(@ce_phone, ''),
			@ce_email = isnull(@ce_email, ''),
			@trl_type1 = isnull(@trl_type1, 'UNK'),
			@trl_type2 = isnull(@trl_type2, 'UNK'),
			@trl_type3 = isnull(@trl_type3, 'UNK'),
			@trl_type4 = isnull(@trl_type4, 'UNK'),
			@notes = isnull(@notes, '')

	SELECT @ref_type_displayed = @ref_type 

	IF @ref_number = '%' BEGIN
		SET @ref_type = 'UNK'
	END 

	CREATE TABLE #ResultSet(
		ord_number				char(12),
		ord_hdrnumber			int,
		cmd_code				varchar(8)	null,
		ord_shipper				varchar(8)	null,
		ord_consignee			varchar(8)	null,
		ord_billto				varchar(8)	null,
		ord_company				varchar(8)	null,
		revtype1_t				varchar(8)	null,
		ord_revtype1			varchar(6)	null,
		revtype2_t				varchar(8)	null,
		ord_revtype2			varchar(6)	null,
		revtype3_t				varchar(8)	null,
		ord_revtype3			varchar(6)	null,
		revtype4_t				varchar(8)	null,
		ord_revtype4			varchar(6)	null,
		shipper_city			int			null,
		consignee_city			int			null,
		ref_type				varchar(6)	null,
		ref_number				varchar(30)	null,
		shipper_address			varchar(100)null,
		consignee_address		varchar(100)null,
		shipper_name			varchar(100)null,
		consignee_name			varchar(100)null,
		cmd_name				varchar(60)	null,
		string_mov_number		varchar(12)	null,
		ord_quantity			float		null,
		ord_unit				varchar(6)	null,
		cht_itemcode			varchar(6)	null,
		ord_rate				money		null,
		ord_remark				varchar(254)null,
		tar_number				int			null,
		ord_bookedby			varchar(20)	null,
		ord_bookdate			datetime	null,
		ord_status				varchar(6)	null,
		ord_terms				varchar(6)	null,
		ship_citynm				varchar(18)	null,
		cons_citynm				varchar(18)	null,
		toem_plan_status		varchar(6)	null,
		ord_invoicestatus		varchar(6)	null,
		--PTS 49184 JJF 20090923
		ord_paystatus_override	varchar(6)	null,
		--PTS 49184 JJF 20090923
		ord_origin_earliestdate datetime	null,
		ord_origin_latestdate	datetime	null,
		ord_dest_earliestdate	datetime	null,
		ord_dest_latestdate		datetime	null,
		toep_ordered_count		int			null,
		toep_planned_count		int			null,
		ord_created_count		int			null,
		ord_available_count		int			null,
		ord_planned_count		int			null,
		ord_dispatched_count	int			null,
		ord_completed_count		int			null,
		ord_cancelled_count		int			null
	)


	SET @SelectList = 
			'SELECT	DISTINCT oh.ord_number,' + @Crlf +
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
					'r.ref_type ref_type,' + @Crlf +
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
					'cons_city.cty_name AS ''cons_citynm'',' + @crlf +
					'isnull(toem.toem_plan_status, ''PND''),' + @crlf +
					'oh.ord_invoicestatus,' + @crlf +
					--PTS 49184 JJF 20090923
					'oh.ord_paystatus_override,' + @crlf +
					--END PTS 49184 JJF 20090923
					'oh.ord_origin_earliestdate,' + @crlf + 
					'oh.ord_origin_latestdate,' + @crlf + 
					'oh.ord_dest_earliestdate,' + @crlf + 
					'oh.ord_dest_latestdate,' + @crlf + 
					'toep_ordered_count = 0,' + @crlf +
					'toep_planned_count = 0,' + @crlf +
					'ord_created_count = 0,' + @crlf +
					'ord_available_count = 0,' + @crlf + 
					'ord_planned_count = 0,' + @crlf + 
					'ord_dispatched_count = 0,' + @crlf + 
					'ord_completed_count = 0,' + @crlf +
					'ord_cancelled_count = 0' + @crlf 


	SET @FromClause =
		  'FROM	orderheader oh WITH (NOLOCK)' + @Crlf +
					'INNER JOIN company shipper WITH (NOLOCK) ON shipper.cmp_id = oh.ord_shipper ' + @Crlf +
					'INNER JOIN company consignee WITH (NOLOCK) ON consignee.cmp_id = oh.ord_consignee' + @Crlf +
					'INNER JOIN commodity cmd WITH (NOLOCK) ON oh.cmd_code = cmd.cmd_code' + @Crlf +
					'Inner Join city ship_city WITH (NOLOCK) on ship_city.cty_code = shipper.cmp_city' + @Crlf +
					'Inner Join city cons_city WITH (NOLOCK) on cons_city.cty_code = consignee.cmp_city' + @Crlf +
					'LEFT OUTER JOIN ticket_order_entry_master toem WITH (NOLOCK) on oh.ord_hdrnumber = toem.ord_hdrnumber' + @Crlf +
					'LEFT OUTER JOIN ordercompanyemail oce WITH (NOLOCK) on oh.ord_hdrnumber = oce.ord_hdrnumber' + @Crlf +
					'LEFT OUTER JOIN companyemail ce WITH (NOLOCK) on oce.ce_id = ce.ce_id' + @Crlf +
					'LEFT OUTER JOIN notes ordnotes WITH (NOLOCK) on oh.ord_hdrnumber = ordnotes.nre_tablekey and ntb_table = ''orderheader''' + @Crlf +
					'LEFT OUTER JOIN referencenumber r WITH (NOLOCK) ON r.ref_tablekey = oh.ord_hdrnumber AND' + @Crlf +
											'r.ref_number LIKE @ref_number AND' + @Crlf +
											'r.ref_type = CASE @ref_type_displayed WHEN ''UNK'' THEN r.ref_type ELSE @ref_type_displayed END'

	SET @WhereClause = 'WHERE 1=1 '
	--either for one ord_number...
	IF @ord_number <> '' BEGIN
		SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_number = @ord_number)'
	END
	--or criteria list
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
		IF @delivery_date_from > '1950-01-01' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_startdate >= @delivery_date_from)'
		END
		IF @delivery_date_to < '2049-12-31' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_startdate <= @delivery_date_to)'
		END
		IF @pickup_date_from > '1950-01-01' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_completiondate >= @pickup_date_from)'
		END
		IF @pickup_date_to < '2049-12-31' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_completiondate <= @pickup_date_to)'
		END

		IF @toem_plan_status <> ',ALL,' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND charindex('','' + isnull(toem.toem_plan_status, ''PND'') + '','', @toem_plan_status) > 0'
		END

		IF @ce_contact_type <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ce.ce_contact_type = @ce_contact_type)'
		END
		IF @ce_contact_name <> '' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ce.contact_name like ''%'' +  @ce_contact_name + ''%'')'
		END
		IF @ce_phone <> '' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND ((ce.ce_phone1 like ''%'' +  @ce_phone + ''%'') OR (ce.ce_phone2 like ''%'' +  @ce_phone + ''%'') OR (ce.ce_mobilenumber like ''%'' +  @ce_phone + ''%'') OR (ce.ce_faxnumber like ''%'' +  @ce_phone + ''%''))'
		END
		IF @ce_email <> '' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ce.email_address like ''%'' +  @ce_email + ''%'')'
		END


		IF @trl_type1 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.trl_type1 = @trl_type1)'
		END
		IF @trl_type2 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_trl_type2 = @trl_type2)'
		END
		IF @trl_type3 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_trl_type2 = @trl_type3)'
		END
		IF @trl_type4 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (oh.ord_trl_type2 = @trl_type4)'
		END

		IF @notes <> '' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND ((ordnotes.not_text_large like ''%'' + @notes + ''%'') OR ordnotes.not_text like ''%'' +  @notes + ''%'')'
		END
		
	END	
	SET @WhereClause = @WhereClause + @Crlf + 'AND charindex('','' + oh.ord_status + '','', @ord_status) > 0'
	--PTS 51570 JJF 20100510
	--SET @WhereClause = @WhereClause + @Crlf + 'AND dbo.RowRestrictByUser (ord_belongsto, '''', '''', '''') = 1'-- 12/12/2007 MDH PTS 40119: Added		
	SET @WhereClause = @WhereClause + @Crlf + 'AND dbo.RowRestrictByUser(''orderheader'', ohmaster.rowsec_rsrv_id, '''', '''', '''') = 1'-- 12/12/2007 MDH PTS 40119: Added		

	SET @SQLString = 'INSERT INTO #ResultSet ' + @Crlf + @SelectList + @Crlf + @FromClause + @Crlf + @WhereClause

	SET @ParmDefinition = 
							N'@shipper				VARCHAR(8),' +
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
							'@ref_type				VARCHAR(6),' +
							'@ref_type_displayed	VARCHAR(6),' +
							'@ref_number			VARCHAR(30),' +
							'@ord_number			VARCHAR(12),' +
							'@ord_status			varchar(255),' +
							'@delivery_date_from	DATETIME,' +
							'@delivery_date_to		DATETIME,' +
							'@pickup_date_from		DATETIME,' +
							'@pickup_date_to		DATETIME,' +
							'@toem_plan_status		varchar(255),' +
							'@ce_contact_type		varchar(6),' +
							'@ce_contact_name		varchar(30),' +
							'@ce_phone				varchar(20),' +
							'@ce_email				varchar(50),' +
							'@trl_type1				varchar(6),' +
							'@trl_type2				varchar(6),' +
							'@trl_type3				varchar(6),' +
							'@trl_type4				varchar(6),' +
							'@notes					varchar(254)'


						

	--debug generated sql stmt
	IF @Debug = 'Y' BEGIN
		PRINT @ParmDefinition
		PRINT ''
		PRINT '@delivery_date_to: ' + convert(varchar(20), @delivery_date_to)
		PRINT '@pickup_date_to: ' + convert(varchar(20), @pickup_date_to)
		PRINT '@ord_status: ' + convert(varchar(20), @ord_status)
		PRINT '@toem_plan_status: ' + convert(varchar(20), @toem_plan_status)
		PRINT '@ref_type: ' + convert(varchar(20), @ref_type)
		PRINT '@ref_number: ' + convert(varchar(20), @ref_number)

		PRINT ''

		PRINT @SQLString
		PRINT ''
		PRINT 'LEN(@SQLString) (4000 is max in SQL2005): ' + convert(varchar(9), LEN(@SQLString))
	END
	


	EXECUTE sp_executesql @SQLString, @ParmDefinition,
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
			@ref_type,
			@ref_type_displayed,
			@ref_number,
			@ord_number,
			@ord_status,
			@delivery_date_from,
			@delivery_date_to,
			@pickup_date_from,
			@pickup_date_to,
			@toem_plan_status,
			@ce_contact_type,
			@ce_contact_name,
			@ce_phone,
			@ce_email,
			@trl_type1,
			@trl_type2,
			@trl_type3,
			@trl_type4,
			@notes


	UPDATE #ResultSet
	SET
		
		toep_ordered_count = isnull(	(SELECT	sum(isnull(toep_ordered_count, 0))
										FROM	ticket_order_entry_plan toepinner 
										WHERE	toepinner.ord_hdrnumber = oh.ord_hdrnumber 
												and toepinner.toep_delivery_date between @delivery_date_from and @delivery_date_to
												and toepinner.toep_status in ('N', 'P', 'C')), 0),

		toep_planned_count = isnull(	(SELECT	sum(isnull(toep_planned_count, 0))
										FROM	ticket_order_entry_plan toepinner 
										WHERE	toepinner.ord_hdrnumber = oh.ord_hdrnumber 
												and toepinner.toep_delivery_date between @delivery_date_from and @delivery_date_to
												and toep_status in ('N', 'P', 'C')), 0),

		ord_created_count = (	SELECT	count(*) 
								FROM	ticket_order_entry_plan toepinner 
										INNER JOIN ticket_order_entry_plan_orders toepoinner 
											on toepinner.toep_id = toepoinner.toep_id 
										INNER JOIN orderheader ohinner 
											on toepoinner.ord_hdrnumber = ohinner.ord_hdrnumber 
								WHERE	toepinner.ord_hdrnumber = oh.ord_hdrnumber 
										and toepinner.toep_delivery_date between @delivery_date_from and @delivery_date_to),
		ord_available_count = (SELECT	count(*) 
								FROM	ticket_order_entry_plan toepinner 
										INNER JOIN ticket_order_entry_plan_orders toepoinner 
											on toepinner.toep_id = toepoinner.toep_id 
										INNER JOIN orderheader ohinner 
											on toepoinner.ord_hdrnumber = ohinner.ord_hdrnumber 
								WHERE	ohinner.ord_status = 'AVL' 
										and toepinner.ord_hdrnumber = oh.ord_hdrnumber 
										and toepinner.toep_delivery_date between @delivery_date_from and @delivery_date_to),
		ord_planned_count = (	SELECT	count(*) 
								FROM	ticket_order_entry_plan toepinner 
										INNER JOIN ticket_order_entry_plan_orders toepoinner 
											on toepinner.toep_id = toepoinner.toep_id 
										INNER JOIN orderheader ohinner 
											on toepoinner.ord_hdrnumber = ohinner.ord_hdrnumber 
								WHERE	ohinner.ord_status = 'PLN' 
										and toepinner.ord_hdrnumber = oh.ord_hdrnumber 
										and toepinner.toep_delivery_date between @delivery_date_from and @delivery_date_to),
		ord_dispatched_count = (SELECT	count(*) 
								FROM	ticket_order_entry_plan toepinner 
										INNER JOIN ticket_order_entry_plan_orders toepoinner 
											on toepinner.toep_id = toepoinner.toep_id 
										INNER JOIN orderheader ohinner 
											on toepoinner.ord_hdrnumber = ohinner.ord_hdrnumber 
								WHERE	ohinner.ord_status = 'DSP' 
										and toepinner.ord_hdrnumber = oh.ord_hdrnumber 
										and toepinner.toep_delivery_date between @delivery_date_from and @delivery_date_to),
		ord_completed_count = (	SELECT	count(*) 
								FROM	ticket_order_entry_plan toepinner 
										INNER JOIN ticket_order_entry_plan_orders toepoinner 
											on toepinner.toep_id = toepoinner.toep_id 
										INNER JOIN orderheader ohinner 
											on toepoinner.ord_hdrnumber = ohinner.ord_hdrnumber 
								WHERE	ohinner.ord_status = 'CMP' 
										and toepinner.ord_hdrnumber = oh.ord_hdrnumber 
										and toepinner.toep_delivery_date between @delivery_date_from and @delivery_date_to),
		ord_cancelled_count = (	SELECT	count(*) 
								FROM	ticket_order_entry_plan toepinner 
										INNER JOIN ticket_order_entry_plan_orders toepoinner 
											on toepinner.toep_id = toepoinner.toep_id 
										INNER JOIN orderheader ohinner 
											on toepoinner.ord_hdrnumber = ohinner.ord_hdrnumber 
								WHERE	ohinner.ord_status = 'CAN' 
										and toepinner.ord_hdrnumber = oh.ord_hdrnumber 
										and toepinner.toep_delivery_date between @delivery_date_from and @delivery_date_to) 
	FROM #ResultSet oh

	SELECT
		ord_number,
		ord_hdrnumber,
		cmd_code,
		ord_shipper,
		ord_consignee,
		ord_billto,
		ord_company,
		revtype1_t,
		ord_revtype1,
		revtype2_t,
		ord_revtype2,
		revtype3_t,
		ord_revtype3,
		revtype4_t,
		ord_revtype4,
		shipper_city,
		consignee_city,
		ref_type,
		ref_number,
		shipper_address,
		consignee_address,
		shipper_name,
		consignee_name,
		cmd_name,
		string_mov_number,
		ord_quantity,
		ord_unit,
		cht_itemcode,
		ord_rate,
		ord_remark,
		tar_number,
		ord_bookedby,
		ord_bookdate,
		ord_status,
		ord_terms,
		ship_citynm,
		cons_citynm,
		toem_plan_status,
		ord_invoicestatus,
		--PTS 49184 JJF 20090923
		ord_paystatus_override,
		--PTS 49184 JJF 20090923
		ord_origin_earliestdate,
		ord_origin_latestdate,
		ord_dest_earliestdate,
		ord_dest_latestdate,
		toep_ordered_count,
		toep_planned_count,
		ord_created_count,
		ord_available_count,
		ord_planned_count,
		ord_dispatched_count,
		ord_completed_count,
		ord_cancelled_count
	FROM #ResultSet
GO
GRANT EXECUTE ON  [dbo].[d_freight_managment_planning_masters] TO [public]
GO
