SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46118 JJF 20090717
CREATE PROCEDURE [dbo].[d_planning_records] (
	--retrieves either for one @mst_ord_hdrnumber...
	@mst_ord_hdrnumber	int,
	--or criteria list...
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

	DECLARE @SQLString NVARCHAR(4000)
	DECLARE @SelectList NVARCHAR(4000)
	DECLARE @FromClause NVARCHAR(4000)
	DECLARE @WhereClause NVARCHAR(4000)
	DECLARE @ParmDefinition NVARCHAR(1000)
	DECLARE @Crlf as CHAR(1)
	DECLARE @Debug as CHAR(1)


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


	IF @ref_number = '%' BEGIN
		SET @ref_type = 'UNK'
	END 

	CREATE TABLE #ResultSet(
		ord_hdrnumber			int,
		toep_delivery_date		datetime,
		toep_ordered_count		int,
		toep_planned_count		int,
		cmd_code				varchar(8),
		toep_shipper			varchar(8),
		ord_number				char(12),
		toep_id					int,
		toep_status				char(1),
		cmd_name				varchar(60)		null,
		shipper_name			varchar(100)	null,
		--PTS 49960 JJF 20091209
		--ord_consignee			varchar(8),
		toep_consignee			varchar(8),
		--PTS 49960 JJF 20091209
		consignee_name			varchar(100)	null,
		toep_driver				varchar(8),
		toep_tractor			varchar(8),
		toep_trailer			varchar(13)		null,
		ref_count				int				null,
		toepr_ref_type			varchar(6)		null,
		toepr_ref_number		varchar(30)		null,
		toep_comment			varchar(255)	null,
		toep_carrier			varchar(8)		null,
		toep_trailer2			varchar(13)		null,
		toep_delete_reason_code	varchar(6)		null,
		toep_delete_reason_text varchar(255)	null,
		toep_bookedby			varchar(20)		null,
		toep_tarnumber			varchar(12)		null,
		toep_rate				money			null,
		toep_ordered_weight		float			null,
		toep_planned_weight		float			null,
		toep_weight_per_load	float			null,
		toep_weights_units		varchar(6)		null,
		toep_invoicestatus		varchar(6)		null,
		toep_paystatus			varchar(6)		null,
		toep_work_unit			varchar(6)		null,
		toep_ordered_work_quantity	float		null,
		toep_planned_work_quantity	float		null,
		toep_work_quantity_per_load	float		null,
		toep_origin_earliestdate datetime		null,
		toep_origin_latestdate	datetime		null,
		toep_dest_earliestdate	datetime		null,
		toep_dest_latestdate	datetime		null,
		toep_ord_revtype1		varchar(6)		null,
		toep_ord_revtype2		varchar(6)		null,
		toep_ord_revtype3		varchar(6)		null,
		toep_ord_revtype4		varchar(6)		null,
		toep_ord_revtype1_t		varchar(8)		null,
		toep_ord_revtype2_t		varchar(8)		null,
		toep_ord_revtype3_t		varchar(8)		null,
		toep_ord_revtype4_t		varchar(8)		null,
		toep_trl_type1			varchar(6)		null,
		toep_trl_type1_t		varchar(8)		null
	)

	SET @SelectList = 
		--PTS 49184 JJF 20090924
		--'SELECT		toep.ord_hdrnumber,' + @Crlf +
		'SELECT	DISTINCT	toep.ord_hdrnumber,' + @Crlf +
		--END PTS 49184 JJF 20090924
					'toep.toep_delivery_date,' + @Crlf +
					'toep.toep_ordered_count,' + @Crlf +
					'toep.toep_planned_count,' + @Crlf +
					'toep.cmd_code,' + @Crlf +
					'toep.toep_shipper,' + @Crlf +
					'ohmaster.ord_number,' + @Crlf +
					'toep.toep_id,' + @Crlf +
					'toep.toep_status,' + @Crlf +
					'cmd.cmd_name,' + @Crlf +
					'shipper.cmp_name as shipper_name,' + @Crlf +
					--PTS 49960 JJF 20091209
					--'ohmaster.ord_consignee,' + @Crlf +
					'toep.toep_consignee,' + @Crlf +
					--END PTS 49960 JJF 20091209
					'consignee.cmp_name as consignee_name,' + @Crlf +
					'toep.toep_driver,' + @Crlf +
					'toep.toep_tractor,' + @Crlf +
					'toep.toep_trailer,' + @Crlf +
					'(SELECT COUNT(*) FROM ticket_order_entry_plan_ref WHERE toep_id = toep.toep_id) ref_count,' + @Crlf +
					'toepr.toepr_ref_type,' + @Crlf +
					'toepr.toepr_ref_number,' + @Crlf +
					'toep.toep_comment,' + @Crlf +
					'toep.toep_carrier,' + @Crlf +
					'toep.toep_trailer2,' + @Crlf +
					'toep.toep_delete_reason_code,' + @Crlf +
					'toep.toep_delete_reason_text,' + @Crlf +
					'toep.toep_bookedby,' + @Crlf +
					'toep.toep_tarnumber,' + @Crlf +
					'toep.toep_rate,' + @Crlf +
					'toep.toep_ordered_weight,' + @Crlf +
					'toep.toep_planned_weight,' + @Crlf +
					'toep.toep_weight_per_load,' + @Crlf +
					'toep.toep_weights_units,' + @Crlf +
					'toep.toep_invoicestatus,' + @Crlf + 
					'toep.toep_paystatus,' + @Crlf + 
					'toep.toep_work_unit,' + @Crlf + 
					'toep.toep_ordered_work_quantity,' + @Crlf + 
					'toep.toep_planned_work_quantity,' + @Crlf + 
					'toep.toep_work_quantity_per_load,' + @Crlf +
					'toep.toep_origin_earliestdate,' + @Crlf + 
					'toep.toep_origin_latestdate,' + @Crlf + 
					'toep.toep_dest_earliestdate,' + @Crlf + 
					'toep.toep_dest_latestdate,' + @Crlf +
					'toep.toep_ord_revtype1,' + @Crlf +
					'toep.toep_ord_revtype2,' + @Crlf +
					'toep.toep_ord_revtype3,' + @Crlf +
					'toep.toep_ord_revtype4,' + @Crlf +
					'''RevType1'' as toep_ord_revtype1_t,' + @Crlf +
					'''RevType2'' as toep_ord_revtype2_t,' + @Crlf +
					'''RevType3'' as toep_ord_revtype3_t,' + @Crlf +
					'''RevType4'' as toep_ord_revtype4_t,' + @Crlf +
					'toep.toep_trl_type1,' + @Crlf + 
					'''TrlType1'' as toep_trl_type1_t' + @Crlf 

	SET @FromClause =
		'FROM	orderheader ohmaster' + @Crlf +
			'INNER JOIN ticket_order_entry_plan toep ON toep.ord_hdrnumber = ohmaster.ord_hdrnumber AND CHARINDEX(toep_status, ''D'') = 0' + @Crlf +
			'INNER JOIN commodity cmd ON toep.cmd_code = cmd.cmd_code' + @Crlf +
			'INNER JOIN company shipper ON toep.toep_shipper = shipper.cmp_id' + @Crlf +
			--PTS 49960 JJF 20091209
			--'INNER JOIN company consignee ON ohmaster.ord_consignee = consignee.cmp_id' + @Crlf +
			'INNER JOIN company consignee ON toep.toep_consignee = consignee.cmp_id' + @Crlf +
			--END PTS 49960 JJF 20091209
			'LEFT OUTER JOIN ticket_order_entry_master toem WITH (NOLOCK) on ohmaster.ord_hdrnumber = toem.ord_hdrnumber' + @Crlf +
			'LEFT OUTER JOIN ticket_order_entry_plan_ref toepr ON toep.toep_id = toepr.toep_id AND toepr.toepr_ref_sequence = 1' + @Crlf +
			'LEFT OUTER JOIN ordercompanyemail oce WITH (NOLOCK) on ohmaster.ord_hdrnumber = oce.ord_hdrnumber' + @Crlf +
			'LEFT OUTER JOIN companyemail ce WITH (NOLOCK) on oce.ce_id = ce.ce_id' + @Crlf +
			'LEFT OUTER JOIN notes ordnotes WITH (NOLOCK) on ohmaster.ord_hdrnumber = ordnotes.nre_tablekey and ntb_table = ''orderheader''' + @Crlf 

	SET @WhereClause = 'WHERE 1=1 '
	--retrieves either for one @mst_ord_hdrnumber...
	IF @mst_ord_hdrnumber > 0 BEGIN
		SET @WhereClause = @WhereClause + @Crlf + 'AND (toep.ord_hdrnumber = @mst_ord_hdrnumber)'
	END
	--or criteria list...
	ELSE BEGIN
		IF @shipper <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_shipper = @shipper)'
		END
		IF @shipper_city <> 0 BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (shipper.cmp_city = @shipper_city)'
		END
		IF @consignee <> 'UNKNOWN' BEGIN
			--PTS 49960 JJF 20091209
			--SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_consignee = @consignee)'
			SET @WhereClause = @WhereClause + @Crlf + 'AND (toep.toep_consignee = @consignee)'
			--END PTS 49960 JJF 20091209
		END
		IF @consignee_city <> 0 BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (consignee.cmp_city = @consignee_city)'
		END
		IF @commodity <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.cmd_code = @commodity)'
		END
		IF @billto <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_billto = @billto)'
		END
		IF @orderedby <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_company = @orderedby)'
		END
		IF @revtype1 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_revtype1 = @revtype1)'
		END
		IF @revtype2 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_revtype2 = @revtype2)'
		END
		IF @revtype3 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_revtype3 = @revtype3)'
		END
		IF @revtype4 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_revtype4 = @revtype4)'
		END
		IF @ref_number <> '%' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND 				EXISTS(SELECT	1' + @Crlf +
							 'FROM	referencenumber r WITH (NOLOCK)' + @Crlf +
							'WHERE	 r.ref_type = CASE @ref_type WHEN ''UNK'' THEN r.ref_type ELSE @ref_type END AND' + @Crlf +
									 'r.ref_number LIKE @ref_number AND' + @Crlf +
									 'r.ref_tablekey = ohmaster.ord_hdrnumber AND' + @Crlf +
									 'r.ref_table = ''orderheader'')' 
		END
		IF @ord_number <> '' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_number = @ord_number)'
		END
		IF @delivery_date_from > '1950-01-01' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_startdate >= @delivery_date_from)'
		END
		IF @delivery_date_to < '2049-12-31' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_startdate <= @delivery_date_to)'
		END
		IF @pickup_date_from > '1950-01-01' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_completiondate >= @pickup_date_from)'
		END
		IF @pickup_date_to < '2049-12-31' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_completiondate <= @pickup_date_to)'
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
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.trl_type1 = @trl_type1)'
		END
		IF @trl_type2 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_trl_type2 = @trl_type2)'
		END
		IF @trl_type3 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_trl_type2 = @trl_type3)'
		END
		IF @trl_type4 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_trl_type2 = @trl_type4)'
		END

		IF @notes <> '' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND ((ordnotes.not_text_large like ''%'' + @notes + ''%'') OR ordnotes.not_text like ''%'' +  @notes + ''%'')'
		END

		SET @WhereClause = @WhereClause + @Crlf + 'AND charindex('','' + ohmaster.ord_status + '','', @ord_status) > 0'
	END
	--PTS 51570 JJF 20100510
	--SET @WhereClause = @WhereClause + @Crlf + 'AND dbo.RowRestrictByUser (ord_belongsto, '''', '''', '''') = 1'-- 12/12/2007 MDH PTS 40119: Added		
	SET @WhereClause = @WhereClause + @Crlf + 'AND dbo.RowRestrictByUser(''orderheader'', ohmaster.rowsec_rsrv_id, '''', '''', '''') = 1'-- 12/12/2007 MDH PTS 40119: Added		

	SET @SQLString = 'INSERT INTO #ResultSet ' + @Crlf + @SelectList + @Crlf + @FromClause + @Crlf + @WhereClause

	SET @ParmDefinition = 
						N'@mst_ord_hdrnumber	int,' +
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
						'@ref_type				VARCHAR(6),' +
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
		PRINT ''

		PRINT @SQLString
		PRINT ''
		PRINT 'LEN(@SQLString) (4000 is max in SQL2005): ' + convert(varchar(9), LEN(@SQLString))
	END

	EXECUTE sp_executesql @SQLString, @ParmDefinition,
			@mst_ord_hdrnumber,
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

	SELECT	ord_hdrnumber,   
			toep_delivery_date,   
			toep_ordered_count,   
			toep_planned_count,   
			cmd_code,   
			toep_shipper,   
			ord_number,   
			toep_id,   
			toep_status,   
			cmd_name,   
			shipper_name,
			--PTS 49960 JJF 20091209
			--ord_consignee,   
			toep_consignee,   
			--END PTS 49960 JJF 20091209
			consignee_name,   
			toep_driver,   
			toep_tractor,   
			toep_trailer,
			ref_count,
			toepr_ref_type,
			toepr_ref_number,
			toep_comment,
			toep_carrier,
			toep_trailer2,
			toep_delete_reason_code,
			toep_delete_reason_text,
			toep_bookedby,
			toep_tarnumber,
			toep_rate,
			toep_ordered_weight,
			toep_planned_weight,
			toep_weight_per_load,
			toep_weights_units,
			toep_invoicestatus,
			toep_paystatus,
			toep_work_unit,
			toep_ordered_work_quantity,
			toep_planned_work_quantity,
			toep_work_quantity_per_load,
			toep_origin_earliestdate,
			toep_origin_latestdate,
			toep_dest_earliestdate,
			toep_dest_latestdate,
			toep_ord_revtype1,
			toep_ord_revtype2,
			toep_ord_revtype3,
			toep_ord_revtype4,
			toep_ord_revtype1_t,
			toep_ord_revtype2_t,
			toep_ord_revtype3_t,
			toep_ord_revtype4_t,
			toep_trl_type1,
			toep_trl_type1_t

	FROM #ResultSet

GO
GRANT EXECUTE ON  [dbo].[d_planning_records] TO [public]
GO
