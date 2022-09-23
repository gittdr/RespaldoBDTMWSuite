SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS46118 JJF 20090717
CREATE PROCEDURE [dbo].[d_planning_records_orders] (
	--retrieves either for one toep_id...
	@toep_id			int,
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

	SELECT	@ord_status = ',' + isnull(@ord_status, 'ALL') + ','
	SELECT @toem_plan_status = ',' + isnull(@toem_plan_status, 'ALL') + ','
	
	IF @ord_status = ',ALL,' BEGIN
		SELECT @ord_status = ',MST,QTE,PLM,'
	END

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
		toep_id						int,
		mst_ord_hdrnumber			int,
		mst_ord_number				char(12),
		child_ord_hdrnumber			int,
		child_mov_number			int,
		child_ord_number			char(12),
		child_ord_status			varchar(6),
		child_ord_startdate			datetime	null,
		child_ord_shipper			varchar(6)	null,
		child_ord_consignee			varchar(6)	null,
		child_cmd_code				varchar(8)	null,
		child_ord_totalmiles		int			null,
		child_ord_totalvolumeunits	varchar(6)	null,
		child_ord_totalvolume		float		null,
		child_ord_totalweightunits	varchar(6)	null,
		child_ord_totalweight		float		null,
		child_ord_totalcountunits	varchar(6)	null,
		child_ord_totalpieces		float		null,
		--PTS 49960 JJF 20091216
		child_ord_carrier			varchar(8)	null,
		child_ord_rate				money		null,
		child_ord_reftype			varchar(6)	null,
		child_ord_reftype_name		varchar(20)	null,
		child_ord_refnum			varchar(30)	null,
		child_ord_refcount			int				null,
		--END PTS 49960 JJF 20091216


	)


	SET @SelectList = 
		--PTS 49184 JJF 20090924
		--'SELECT	toepo.toep_id,' + @Crlf +
		'SELECT	DISTINCT toepo.toep_id,' + @Crlf +
		--END PTS 49184 JJF 20090924
				'ohmaster.ord_hdrnumber as mst_ord_hdrnumber,' + @Crlf +
				'ohmaster.ord_number as mst_ord_number,' + @Crlf +
				'ohchild.ord_hdrnumber as child_ord_hdrnumber,' + @Crlf +
				'ohchild.mov_number as child_mov_number,' + @Crlf +
				'ohchild.ord_number as child_ord_number,' + @Crlf +
				'ohchild.ord_status as child_ord_startdate,' + @Crlf +
				'ohchild.ord_startdate as child_ord_startdate,' + @Crlf +
				'ohchild.ord_shipper as child_ord_shipper,' + @Crlf +
				'ohchild.ord_consignee as child_ord_consignee,' + @Crlf +
				'ohchild.cmd_code as child_cmd_code,' + @Crlf +
				'ohchild.ord_totalmiles as child_ord_totalmiles,' + @Crlf +
				'ohchild.ord_totalvolumeunits as child_ord_totalvolumeunits,' + @Crlf +
				'ohchild.ord_totalvolume as child_ord_totalvolume,' + @Crlf +
				'ohchild.ord_totalweightunits as child_ord_totalweightunits,' + @Crlf +
				'ohchild.ord_totalweight as child_ord_totalweight,' + @Crlf +
				'ohchild.ord_totalcountunits as child_ord_totalcountunits,' + @Crlf +
				--PTS 49960 JJF 20091216
				--'ohchild.ord_totalpieces as child_ord_totalpieces' + @Crlf
				'ohchild.ord_totalpieces as child_ord_totalpieces,' + @Crlf +
				'ohchild.ord_carrier as child_ord_carrier,' + @Crlf + 
				'ohchild.ord_rate as child_ord_rate,' + @Crlf +
				'ohchild.ord_reftype as child_ord_reftype,' + @Crlf +
				'null child_ord_reftype_name,' + @Crlf +
				'ohchild.ord_refnum as child_ord_refnum,' + @Crlf +
				'(SELECT COUNT(*) FROM referencenumber ref WHERE ref.ord_hdrnumber = ohchild.ord_hdrnumber and ref.ref_table = ''orderheader'') child_ord_refcount' + @Crlf
				--END PTS 49960 JJF 20091216

	SET @FromClause =
		'FROM    ticket_order_entry_plan_orders toepo ' + @Crlf +
			'INNER JOIN orderheader ohchild ON toepo.ord_hdrnumber = ohchild.ord_hdrnumber' + @Crlf +
			'INNER JOIN company shipper WITH (NOLOCK) ON shipper.cmp_id = ohchild.ord_shipper ' + @Crlf +
			'INNER JOIN company consignee WITH (NOLOCK) ON consignee.cmp_id = ohchild.ord_consignee' + @Crlf +
			'INNER JOIN ticket_order_entry_plan toep on toepo.toep_id = toep.toep_id' + @Crlf +
			'INNER JOIN orderheader ohmaster ON ohmaster.ord_hdrnumber = toep.ord_hdrnumber' + @Crlf +
			'LEFT OUTER JOIN ticket_order_entry_master toem WITH (NOLOCK) on ohmaster.ord_hdrnumber = toem.ord_hdrnumber' + @Crlf +
			'LEFT OUTER JOIN ordercompanyemail oce WITH (NOLOCK) on ohmaster.ord_hdrnumber = oce.ord_hdrnumber' + @Crlf +
			'LEFT OUTER JOIN companyemail ce WITH (NOLOCK) on oce.ce_id = ce.ce_id' + @Crlf +
			'LEFT OUTER JOIN notes ordnotes WITH (NOLOCK) on ohmaster.ord_hdrnumber = ordnotes.nre_tablekey and ntb_table = ''orderheader''' + @Crlf 


	SET @WhereClause = 'WHERE 1=1 '
	--either for one toep_id...
	IF @toep_id > 0 BEGIN
		SET @WhereClause = @WhereClause + @Crlf + 'AND (toepo.toep_id = @toep_id)'
	END
	--or criteria list
	ELSE BEGIN
		IF @shipper <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_shipper = @shipper)'
		END
		IF @shipper_city <> 0 BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (shipper.cmp_city = @shipper_city)'
		END
		IF @consignee <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_consignee = @consignee)'
		END
		IF @consignee_city <> 0 BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (consignee.cmp_city = @consignee_city)'
		END
		IF @commodity <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.cmd_code = @commodity)'
		END
		IF @billto <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_billto = @billto)'
		END
		IF @orderedby <> 'UNKNOWN' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_company = @orderedby)'
		END
		IF @revtype1 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_revtype1 = @revtype1)'
		END
		IF @revtype2 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_revtype2 = @revtype2)'
		END
		IF @revtype3 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_revtype3 = @revtype3)'
		END
		IF @revtype4 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_revtype4 = @revtype4)'
		END
		IF @ref_number <> '%' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND 				EXISTS(SELECT	1' + @Crlf +
							 'FROM	referencenumber r WITH (NOLOCK)' + @Crlf +
							'WHERE	 r.ref_type = CASE @ref_type WHEN ''UNK'' THEN r.ref_type ELSE @ref_type END AND' + @Crlf +
									 'r.ref_number LIKE @ref_number AND' + @Crlf +
									 'r.ref_tablekey = ohchild.ord_hdrnumber AND' + @Crlf +
									 'r.ref_table = ''orderheader'')' 
		END
		IF @ord_number <> '' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohmaster.ord_number = @ord_number)'
		END
		IF @delivery_date_from > '1950-01-01' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_startdate >= @delivery_date_from)'
		END
		IF @delivery_date_to < '2049-12-31' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_startdate <= @delivery_date_to)'
		END
		IF @pickup_date_from > '1950-01-01' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_completiondate >= @pickup_date_from)'
		END
		IF @pickup_date_to < '2049-12-31' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_completiondate <= @pickup_date_to)'
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
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.trl_type1 = @trl_type1)'
		END
		IF @trl_type2 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_trl_type2 = @trl_type2)'
		END
		IF @trl_type3 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_trl_type2 = @trl_type3)'
		END
		IF @trl_type4 <> 'UNK' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND (ohchild.ord_trl_type2 = @trl_type4)'
		END

		IF @notes <> '' BEGIN
			SET @WhereClause = @WhereClause + @Crlf + 'AND ((ordnotes.not_text_large like ''%'' + @notes + ''%'') OR ordnotes.not_text like ''%'' +  @notes + ''%'')'
		END

		SET @WhereClause = @WhereClause + @Crlf + 'AND charindex('','' + ohmaster.ord_status + '','', @ord_status) > 0'
	END

	--PTS 51570 JJF 20100510 
	--SET @WhereClause = @WhereClause + @Crlf + 'AND dbo.RowRestrictByUser (ohchild.ord_belongsto, '''', '''', '''') = 1'-- 12/12/2007 MDH PTS 40119: Added		
	SET @WhereClause = @WhereClause + @Crlf + 'AND dbo.RowRestrictByUser(''orderheader'', ohchild.rowsec_rsrv_id, '''', '''', '''') = 1'-- 12/12/2007 MDH PTS 40119: Added

	SET @SQLString = 'INSERT INTO #ResultSet ' + @Crlf + @SelectList + @Crlf + @FromClause + @Crlf + @WhereClause

	SET @ParmDefinition = 
						N'@toep_id				int,' +
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
			@toep_id,
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

	--PTS 49960 JJF 20091216
	UPDATE #ResultSet
	SET		child_ord_reftype_name = lblref.name
	FROM	labelfile lblref
	WHERE	lblref.labeldefinition = 'ReferenceNumbers'
			AND lblref.abbr = #ResultSet.child_ord_reftype
	--END PTS 49960 JJF 20091216
			
	SELECT	toep_id,
			mst_ord_hdrnumber,
			mst_ord_number,
			child_ord_hdrnumber, 
			child_mov_number,
			child_ord_number,
			child_ord_status,
			child_ord_startdate,
			child_ord_shipper,
			child_ord_consignee,
			child_cmd_code,
			child_ord_totalmiles,
			child_ord_totalvolumeunits,
			child_ord_totalvolume,
			child_ord_totalweightunits,
			child_ord_totalweight,
			child_ord_totalcountunits,
			child_ord_totalpieces,
			--PTS 49960 JJF 20091216
			child_ord_carrier,
			child_ord_rate,
			child_ord_reftype,
			child_ord_reftype_name,
			child_ord_refnum,
			child_ord_refcount
			--END PTS 49960 JJF 20091216
	FROM #ResultSet

GO
GRANT EXECUTE ON  [dbo].[d_planning_records_orders] TO [public]
GO
