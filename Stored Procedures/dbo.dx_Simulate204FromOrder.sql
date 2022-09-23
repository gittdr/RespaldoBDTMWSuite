SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_Simulate204FromOrder]
	@p_OrderHeaderNumber int
AS


declare @dx_sourcedate datetime, @dx_docnumber varchar(9), @ord_number varchar(12), @dx_ordernumber varchar(50), @ord_status varchar(6)
declare @dx_trpid varchar (20)
declare @dx_billto varchar(8)

select @ord_status = ord_status, @dx_billto = ord_billto, @dx_trpid = ord_editradingpartner	FROM 
		orderheader (nolock) 
	where ord_hdrnumber = @p_OrderHeaderNumber

-- determine status of original order. If it is still pending, don't compare live data, it hasn't changed. 
-- Compare dx_archive that created the order.
SELECT  
		top 1 @dx_sourcedate = dx_sourcedate, 
				@dx_docnumber = dx_docnumber, 
				@dx_ordernumber = dx_ordernumber 
	FROM 
		dx_archive_header (nolock) 
	WHERE dx_importid =  'dx_204'
	  AND dx_orderhdrnumber = @p_OrderHeaderNumber 
	  AND dx_processed = 'DONE'
	ORDER BY dx_sourcedate DESC

IF (@ord_status = 'PND')
	BEGIN
	exec dx_EDIOrderDocumentForCompare	
			@dx_ordernumber,
			@dx_docnumber,
			@dx_sourcedate,
			'dx_204'
			RETURN
	END


declare @dx_archive table (
		[dx_ident] [bigint] IDENTITY (1, 1) NOT NULL ,
		[dx_importid] [varchar] (8) NOT NULL ,
		[dx_sourcename] [varchar] (255) NOT NULL ,
		[dx_sourcedate] [datetime] NOT NULL ,
		[dx_seq] [int] NULL ,
		[dx_updated] [char] (1) NULL ,
		[dx_accepted] [bit] NULL ,
		[dx_ordernumber] [varchar] (30) NULL ,
		[dx_orderhdrnumber] [int] NULL ,
		[dx_movenumber] [int] NULL ,
		[dx_stopnumber] [int] NULL ,
		[dx_freightnumber] [int] NULL ,
		[dx_docnumber] [varchar] (9) NULL ,
		[dx_manifestnumber] [varchar] (20) NULL ,
		[dx_manifeststop] [int] NULL ,
		[dx_batchref] [int] NULL ,
		[dx_field001] [varchar] (200) NULL ,
		[dx_field002] [varchar] (200) NULL ,
		[dx_field003] [varchar] (200) NULL ,
		[dx_field004] [varchar] (200) NULL ,
		[dx_field005] [varchar] (200) NULL ,
		[dx_field006] [varchar] (200) NULL ,
		[dx_field007] [varchar] (200) NULL ,
		[dx_field008] [varchar] (200) NULL ,
		[dx_field009] [varchar] (200) NULL ,
		[dx_field010] [varchar] (200) NULL ,
		[dx_field011] [varchar] (200) NULL ,
		[dx_field012] [varchar] (200) NULL ,
		[dx_field013] [varchar] (200) NULL ,
		[dx_field014] [varchar] (200) NULL ,
		[dx_field015] [varchar] (200) NULL ,
		[dx_field016] [varchar] (200) NULL ,
		[dx_field017] [varchar] (200) NULL ,
		[dx_field018] [varchar] (200) NULL ,
		[dx_field019] [varchar] (200) NULL ,
		[dx_field020] [varchar] (200) NULL ,
		[dx_field021] [varchar] (200) NULL ,
		[dx_field022] [varchar] (200) NULL ,
		[dx_field023] [varchar] (200) NULL ,
		[dx_field024] [varchar] (200) NULL ,
		[dx_field025] [varchar] (200) NULL ,
		[dx_field026] [varchar] (200) NULL ,
		[dx_field027] [varchar] (200) NULL ,
		[dx_field028] [varchar] (200) NULL ,
		[dx_field029] [varchar] (200) NULL ,
		[dx_field030] [varchar] (200) NULL ,
		[dx_field031] [varchar] (200) NULL ,
		[dx_field032] [varchar] (200) NULL ,
		[dx_field033] [varchar] (200) NULL ,
		[dx_field034] [varchar] (200) NULL ,
		[dx_field035] [varchar] (200) NULL ,
		[dx_doctype] [varchar] (8) NULL,
		[dx_billto] [varchar] (8) NULL,
		[dx_sourcedate_reference] [datetime] NULL,
		[dx_processed] [varchar](6) NULL,
		[dx_createdby] [varchar](20) NULL,
		[dx_createdate] [datetime] NULL,
		[dx_updatedby] [varchar](20) NULL,
		[dx_updatedate] [datetime] NULL,
		[dx_trpid] [varchar] (20) Null,
		[dx_archive_header_id] bigint Null,
		[sort_level] int null
	)

declare @dx_seq int, @sort_level int
declare @dx_orderhdrnumber varchar(20)
declare @settingDefault varchar(6)
declare @ord_currency varchar(1)
select top 1 @settingDefault = settingDefault from dx_Settings (nolock) where settingKeyword='UserVars' and settingValue='LtslTextOrdRefID'


IF (SELECT COUNT(1) FROM referencenumber (nolock) where ref_table = 'orderheader' and ref_tablekey = @p_OrderHeaderNumber and ref_type = @settingDefault) > 0
	SELECT TOP 1 @dx_ordernumber = ref_number
				  FROM referencenumber (nolock)
				 WHERE ref_table = 'orderheader'
				   AND ref_tablekey = @p_OrderHeaderNumber 
				   AND ref_type = @settingDefault
ELSE
	SELECT @dx_ordernumber = ord_refnum
				  FROM orderheader (nolock)
				 WHERE ord_hdrnumber = @p_OrderHeaderNumber

-- 02 record
declare @dx_purpose varchar(1)
if @ord_status = 'CAN'
	set @dx_purpose = 'C'
else
	set @dx_purpose = 'N'

if @dx_trpid is null and @dx_billto <> 'UNKNOWN'
	select top 1 @dx_trpid = IsNull(etp_partnerid,'')  
	from edi_tender_partner (nolock) 
	where @dx_billto = etp_CompanyID 
	group by IsNull(etp_partnerid,'')  
	order by IsNull(etp_partnerid,'') desc

insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005
		, dx_field006
		, dx_field007 
		,dx_field008, dx_field009, dx_field010, dx_field011, dx_field012, dx_field013, dx_field014, 
		dx_field015, dx_field016, dx_field017, dx_field018, dx_field019, dx_field020, dx_field021, 
		dx_field022, dx_field023, dx_field024, dx_field025, dx_field026, dx_field027, dx_field028, 
		dx_field029, dx_field030, dx_trpid, dx_billto 
		)

SELECT 
		'dx_204', 'manual entry treated like 204', last_updatedate,'Y', 0, 
		@dx_ordernumber, 
		ord_hdrnumber, 
		mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'02', '39', ord_editradingpartner, @dx_purpose, @dx_ordernumber 
		 ,CONVERT(varchar(8),ord_bookdate,112) + SUBSTRING(CONVERT(varchar(8),ord_bookdate,8),1,2) + SUBSTRING(CONVERT(varchar(8),ord_bookdate,8),4,2)
		,CONVERT(varchar(8),ord_startdate,112) + SUBSTRING(CONVERT(varchar(8),ord_startdate,8),1,2) + SUBSTRING(CONVERT(varchar(8),ord_startdate,8),4,2) 
		,CONVERT(varchar(8),ord_completiondate,112) + SUBSTRING(CONVERT(varchar(8),ord_completiondate,8),1,2) + SUBSTRING(CONVERT(varchar(8),ord_completiondate,8),4,2), 
		IsNull((select top 1 IsNull(dx_lookuprawdatavalue,ord_terms) from  dx_lookup (nolock) where  dx_lookuptable = 'Payment' and dx_lookuptranslatedvalue = ord_terms order by dx_lookuprawdatavalue),ord_terms), 
		IsNull((select top 1 IsNull(dx_lookuprawdatavalue,ord_currency) from  dx_lookup (nolock) where  dx_lookuptable = 'Currency' and dx_lookuptranslatedvalue = ord_currency order by dx_lookuprawdatavalue), ord_currency), 
		REPLICATE('0',12-LEN(convert(varchar(12),convert(int,ISNULL(ord_totalcharge,0.00)*100))))+convert(varchar(12),convert(int,ISNULL(ord_totalcharge,0.00)*100)),
		REPLICATE('0',12-LEN(convert(varchar(12),convert(int,ISNULL(ord_totalweight,0.00)*100))))+convert(varchar(12),convert(int,ISNULL(ord_totalweight,0.00)*100)),
		REPLICATE('0',12-LEN(convert(varchar(12),convert(int,ISNULL(ord_totalmiles,0.00)*100))))+convert(varchar(12),convert(int,ISNULL(ord_totalmiles,0.00)*100)),
		REPLICATE('0',12-LEN(convert(varchar(12),convert(int,ISNULL(ord_totalpieces,0.00)*100))))+convert(varchar(12),convert(int,ISNULL(ord_totalpieces,0.00)*100)),
		substring(IsNull((Select ref_number FROM referencenumber (nolock) WHERE ref_table = 'orderheader' AND ref_tablekey = @p_OrderHeaderNumber and isnull(ref_type,'') = 'EDICT#'),''),1,9),
		'', '', '', '', '', null, 
		null, null, null, null, null, null, null, 
		null, null, @dx_trpid, @dx_billto 
	FROM 
		orderheader (nolock) 
		
	where ord_hdrnumber = @p_OrderHeaderNumber
	-- 05 records
	declare @revtype1 varchar(30),@revtype2 varchar(30),@revtype3 varchar(30),@revtype4 varchar(30)
	declare @extrainfo1 varchar(30),@extrainfo2 varchar(30),@extrainfo3 varchar(30),@extrainfo4 varchar(30),@extrainfo5 varchar(30)
	declare @extrainfo6 varchar(30),@extrainfo7 varchar(30),@extrainfo8 varchar(30),@extrainfo9 varchar(30), @trl_type1 varchar(30)
	declare @remark varchar(256)
	declare @mov_number int
	declare @ord_consignee varchar(8), @ord_shipper varchar(8), @ord_billto varchar(8), @ord_supplier varchar(8), @ord_company varchar(8)
	declare @ord_editradingpartner varchar(20)
	select @revtype1 = isnull(ord_revtype1,'UNK'), @revtype2 = isnull(ord_revtype2,'UNK'), 
			@revtype3 = isnull(ord_revtype3,'UNK'), @revtype4 = isnull(ord_revtype4,'UNK'),
			@dx_sourcedate = IsNull(@dx_sourcedate,last_updatedate), @mov_number = mov_number,
			@ord_consignee =ord_consignee , @ord_shipper =ord_shipper , @ord_billto =ord_billto, @ord_supplier = ord_supplier, @ord_company = ord_company,
			@ord_currency = substring(isnull(ord_currency,'U'),1,1), @remark = IsNull(ord_remark,''),
			@extrainfo1 = IsNull(ord_extrainfo1,'') ,@extrainfo2 = IsNull(ord_extrainfo2,'') ,@extrainfo3 = IsNull(ord_extrainfo3,'') ,@extrainfo4 = IsNull(ord_extrainfo4,'') ,@extrainfo5 = IsNull(ord_extrainfo5,''), 
			@extrainfo6 = IsNull(ord_extrainfo6,'') ,@extrainfo7 = IsNull(ord_extrainfo7,'') ,@extrainfo8 = IsNull(ord_extrainfo8,'') ,@extrainfo9 = IsNull(ord_extrainfo9,''),
			@dx_orderhdrnumber = ord_hdrnumber, @ord_editradingpartner = ord_editradingpartner, @trl_type1 = isnull(trl_type1,'UNK')
	from orderheader (nolock) where ord_hdrnumber = @p_OrderHeaderNumber
	

		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
	select
		'dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', 'RES', CONVERT(VARCHAR(12), exp_expirationdate, 112) + REPLACE(CONVERT(VARCHAR(5), exp_expirationdate, 108),':',''), '', ''
		, @dx_trpid, @dx_billto
	from expiration where exp_idtype = 'ORD' and exp_id = @p_OrderHeaderNumber

IF 	@revtype1 <> 'UNK'
	BEGIN
		
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_R1', @revtype1 , '', ''
		, @dx_trpid, @dx_billto )
	END
	
	IF 	@revtype2 <> 'UNK'
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_R2', @revtype2 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@revtype3 <> 'UNK'
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_R3', @revtype3 , '', ''
		, @dx_trpid, @dx_billto )
	END
	IF 	@revtype4 <> 'UNK'
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_R4', @revtype4 , '', ''
		, @dx_trpid, @dx_billto )
	END
	IF 	@extrainfo1 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E1', @extrainfo1 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@extrainfo2 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E2', @extrainfo2 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@extrainfo3 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E3', @extrainfo3 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@extrainfo4 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E4', @extrainfo4 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@extrainfo5 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E5', @extrainfo5 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@extrainfo6 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E6', @extrainfo6 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@extrainfo7 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E7', @extrainfo7 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@extrainfo8 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E8', @extrainfo8 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@extrainfo9 <> ''
	BEGIN
				
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_E9', @extrainfo9 , '', ''
		, @dx_trpid, @dx_billto )
	END

	IF 	@trl_type1 <> ''
	BEGIN
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_T1', @trl_type1 , '', ''
		, @dx_trpid, @dx_billto )
	END
	
	declare @remark2 varchar(176)
	IF 	@remark <> ''
	BEGIN
				
		IF LEN(@remark) > 80
			BEGIN
				SET @remark2 = substring(@remark,81,176)
				SET @remark = substring(@remark,1,80)
			END
		ELSE
			SET @remark2 = ''
			
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto )
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_RM', @remark , 'REMARK', @remark2
		, @dx_trpid, @dx_billto)
	END
	declare @not_number int
	declare @not_type varchar(255)
	set @not_number = 0
	
		 Create Table #DistinctNotes (not_number integer)
		insert into #DistinctNotes 		SELECT  distinct      min(not_number)  OVER(PARTITION BY not_text,not_type)  
    	FROM  notes (nolock)
		WHERE
			ntb_table = 'orderheader' 
			and nre_tablekey = convert(varchar,@p_OrderHeaderNumber )
			and isnull(not_text,'') > ''
	while 1=1
	begin
	SELECT   distinct top 1  @not_number=min(not_number) 
		FROM #DistinctNotes (nolock)
	 WHERE  not_number > @not_number 
	If @not_number is null BREAK
	
	select @remark = not_text,@not_type=not_type
	from notes (nolock)
	where not_number = @not_number
	IF LEN(@remark) > 80
		BEGIN
			SET @remark2 = substring(@remark,81,176)
			SET @remark = substring(@remark,1,80)
		END
	ELSE
		SET @remark2 = ''
	
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto)
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_RM', @remark , @not_type, @remark2
		, @dx_trpid, @dx_billto)

	end		   

	declare @ref_id int
	set @ref_id = 0
	while 1=1
	begin
	SELECT @ref_id = min(ref_id)
		FROM referencenumber (nolock)
	 WHERE ref_table = 'orderheader'
		AND ref_tablekey = @p_OrderHeaderNumber 
		AND isnull(ref_number,'') <> ''
		and isnull(ref_type,'') <> 'EDICT#'
		and isnull(ref_type,'') <> @settingDefault
		AND ref_id > @ref_id
	If @ref_id is null BREAK
	
	
	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto)
	select
		'dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', isNull(edicode,substring(ref_type,1,3)), ref_number , '', ''
		, @dx_trpid, @dx_billto
	  FROM referencenumber (nolock) left join labelfile (nolock) on labeldefinition = 'referencenumbers' and abbr = ref_type AND edicode <>''
				 WHERE ref_id = @ref_id
	end	
		   
	-- shipper 
		
    declare @companyname varchar(35), @companyaddress1 varchar(35), @companyaddress2 varchar(35)
    declare @cityname varchar(20), @state varchar(2), @altid varchar(12)
    declare @country varchar(3), @phone varchar(20), @companyzip varchar(9)
    
 		
-- retrieve company info and translate back to what came in that may have been matched to company_xref			
-- shipper may be ord_company depending on 
-- Asish Removed the old setting need as Shipper and orderby are same for almost everyone but orderby trading partner could be 0 
	exec dx_retrieve_companyinfo @ord_company, 
		@ord_editradingpartner, 
		@companyname Output, 
		@companyaddress1 output, 
		@cityname output,
		@state output,
		@companyaddress2 output,
		@altid output,
		@country output,
		@phone output, 
		@companyzip output


	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		,dx_field007, dx_field008, dx_field009, dx_field010, dx_field011, dx_field012
		,dx_field013
		, dx_trpid, dx_billto)
		values
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'06', '39', 'SH', @companyname, substring(@companyaddress1,1,35) , @companyaddress2 
		,@cityname, @state, @companyzip, @country, @phone, @companyaddress1
		,@altid
		, @dx_trpid, @dx_billto)

-- consignee 
	exec dx_retrieve_companyinfo @ord_consignee, 
		@ord_editradingpartner, 
		@companyname Output, 
		@companyaddress1 output, 
		@cityname output,
		@state output,
		@companyaddress2 output,
		@altid output,
		@country output,
		@phone output, 
		@companyzip output
	
  	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		,dx_field007, dx_field008, dx_field009, dx_field010, dx_field011, dx_field012
		,dx_field013
		, dx_trpid, dx_billto)
		values
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'06', '39', 'CO', @companyname, substring(@companyaddress1,1,35) , @companyaddress2 
		,@cityname, @state, @companyzip, @country, @phone, @companyaddress1
		,@altid
		, @dx_trpid, @dx_billto)

-- billto
			
	if @ord_billto <> 'UNKNOWN'
	BEGIN
		exec dx_retrieve_companyinfo @ord_billto, 
			@ord_editradingpartner, 
			@companyname Output, 
			@companyaddress1 output, 
			@cityname output,
			@state output,
			@companyaddress2 output,
			@altid output,
			@country output,
			@phone output, 
			@companyzip output		

	 
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
			dx_ordernumber, dx_orderhdrnumber, 
			dx_movenumber, dx_stopnumber, dx_freightnumber 
			,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
			,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
			,dx_field007, dx_field008, dx_field009, dx_field010, dx_field011, dx_field012
			,dx_field013
			, dx_trpid, dx_billto)
			values
			('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
			@dx_ordernumber, 
			@dx_orderhdrnumber, 
			@mov_number, 0, 0 
			,null, null, null, null, 'EDI204' 
			,'06', '39', 'BT', @companyname, substring(@companyaddress1,1,35) , @companyaddress2 
			,@cityname, @state, @companyzip, @country, @phone, @companyaddress1
			,@altid
			, @dx_trpid, @dx_billto)
	END
	
	if @ord_supplier <> 'UNKNOWN'
	BEGIN
		exec dx_retrieve_companyinfo @ord_supplier, 
			@ord_editradingpartner, 
			@companyname Output, 
			@companyaddress1 output, 
			@cityname output,
			@state output,
			@companyaddress2 output,
			@altid output,
			@country output,
			@phone output, 
			@companyzip output		

	 		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
			dx_ordernumber, dx_orderhdrnumber, 
			dx_movenumber, dx_stopnumber, dx_freightnumber 
			,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
			,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
			,dx_field007, dx_field008, dx_field009, dx_field010, dx_field011, dx_field012
			,dx_field013
			, dx_trpid, dx_billto)
			values
			('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
			@dx_ordernumber, 
			@dx_orderhdrnumber, 
			@mov_number, 0, 0 
			,null, null, null, null, 'EDI204' 
			,'06', '39', 'SU', @companyname, substring(@companyaddress1,1,35) , @companyaddress2 
			,@cityname, @state, @companyzip, @country, @phone, @companyaddress1
			,@altid
			, @dx_trpid, @dx_billto)
	END

-- load requirements
	
	declare @loadrequirement_id int
	set @loadrequirement_id = 0
	while 1=1
	begin
	SELECT @loadrequirement_id = min(loadrequirement_id)
		FROM	loadrequirement (nolock)
	 WHERE ord_hdrnumber = @p_OrderHeaderNumber
		AND loadrequirement_id > @loadrequirement_id
	If @loadrequirement_id is null BREAK
	
	--print '@dx_sourcedate=' + convert(varchar(14), @dx_sourcedate) + ''''
	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		,dx_field007
		, dx_trpid, dx_billto)
	select
		'dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, 0, 0 
		,null, null, null, null, 'EDI204' 
		,'08', '39', lrq_equip_type, lrq_type, lrq_manditory, lrq_not, 
		lrq_quantity
		, @dx_trpid, @dx_billto
	  FROM loadrequirement (nolock) 
		 WHERE loadrequirement_id = @loadrequirement_id
	end	-- load requirements
	
	
	declare @maxrevseq int, @minrevseq int
	SELECT @maxrevseq = MAX(stp_mfh_sequence), @minrevseq = MIN(stp_mfh_sequence)
       FROM stops (nolock)
      WHERE ord_hdrnumber = @p_OrderHeaderNumber
	
	declare @stop_mfh_id int
	set @stop_mfh_id = 0
	while 1=1
	begin
	SELECT @stop_mfh_id = min(stp_mfh_sequence)
	FROM	stops (nolock)
	 WHERE ord_hdrnumber = @p_OrderHeaderNumber 
		AND stp_mfh_sequence > @stop_mfh_id 
	If @stop_mfh_id is null BREAK
	
	declare @stp_number int	
	declare @stp_arrivaldate datetime, @stp_earliestdate datetime, @stp_latestdate datetime
	declare @event varchar(6), @stp_cmp_id varchar(8)
	select @stp_number = stp_number, @stp_arrivaldate=stp_arrivaldate,@stp_earliestdate =stp_schdtearliest,
			@stp_latestdate = stp_schdtlatest,  
			@event = IsNull(dx_field003,case when rTrim(isnull(edicode,'')) > '' then edicode when stp_event in ('IBMT','IEMT','BMT','EMT','NBCST') then stp_event else stp_type end), 
			@stp_cmp_id = cmp_id,
			@remark = IsNull(stp_comment,'')
		from stops (nolock) 
		left JOIN dx_archive_detail (nolock) on dx_stopnumber = stp_Number and dx_field001 = '03'
		left join dx_archive_header (nolock) on dx_archive_detail.dx_Archive_header_id = dx_Archive_header.dx_Archive_header_id  and dx_sourcedate = @dx_sourcedate 		
  	    join eventcodetable (nolock) on stp_event = abbr
		where stp_mfh_sequence = @stop_mfh_id
		and ord_hdrnumber = @p_OrderHeaderNumber 
	
	
	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		,dx_field007
		, dx_trpid, dx_billto)
	values
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, @stp_number, 0 
		,null, null, null, null, 'EDI204' 
		,'03', '39', substring(@event,1,2), 
		CONVERT(varchar(8),@stp_arrivaldate,112) + SUBSTRING(CONVERT(varchar(8),@stp_arrivaldate,8),1,2) + SUBSTRING(CONVERT(varchar(8),@stp_arrivaldate,8),4,2), 
		CONVERT(varchar(8),@stp_earliestdate,112) + SUBSTRING(CONVERT(varchar(8),@stp_earliestdate,8),1,2) + SUBSTRING(CONVERT(varchar(8),@stp_earliestdate,8),4,2), 
		CONVERT(varchar(8),@stp_latestdate,112) + SUBSTRING(CONVERT(varchar(8),@stp_latestdate,8),1,2) + SUBSTRING(CONVERT(varchar(8),@stp_latestdate,8),4,2), 
		''
		, @dx_trpid, @dx_billto)
		
--	stop reference numbers
	
	set @ref_id = 0
	while 1=1
	begin
	SELECT @ref_id = min(ref_id)
					FROM	referencenumber (nolock)
	 WHERE ref_table = 'stops'
		AND ref_tablekey = @stp_number
		AND isnull(ref_number,'') <> ''
		AND ref_id > @ref_id
	If @ref_id is null BREAK
	
	
	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto)
	select
		'dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, @stp_number, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', isNull(edicode,substring(ref_type,1,3)), ref_number , '', ''
		, @dx_trpid, @dx_billto
	  FROM referencenumber (nolock) left join labelfile (nolock) on labeldefinition = 'referencenumbers' and abbr = ref_type AND edicode <>''
		 WHERE ref_id = @ref_id
	end	-- stop ref	   
	--delivery instructions	

	IF 	@remark <> ''
	BEGIN
				
		IF LEN(@remark) > 80
			BEGIN
				SET @remark2 = substring(@remark,81,176)
				SET @remark = substring(@remark,1,80)
			END
		ELSE
			SET @remark2 = ''
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto)
		Values 
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, @stp_number, 0 
		,null, null, null, null, 'EDI204' 
		,'05', '39', '_DI', @remark , '', @remark2
		, @dx_trpid, @dx_billto)
	END

	--	freight
	 
	declare @fgt_number int
	set @fgt_number = 0
	while 1=1
	begin
	SELECT @fgt_number = min(fgt_number)
				FROM	freightdetail (nolock)
	 WHERE stp_number = @stp_number
	 AND (cmd_code <> 'UNKNOWN' or fgt_weight <> 0 or fgt_count <> 0 or fgt_volume <> 0)
	 AND fgt_number > @fgt_number 
	If @fgt_number is null BREAK
	
	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004
		,dx_field005, dx_field006
		,dx_field007, dx_field008
		,dx_field009, dx_field010
		,dx_field011, dx_field012
		,dx_field013, dx_field014
		,dx_field015, dx_field016
		,dx_field017, dx_field018
		,dx_field019, dx_field020
		,dx_field021, dx_field022, dx_field024
		, dx_trpid, dx_billto)
	select
		'dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, @stp_number, @fgt_number 
		,null, null, null, null, 'EDI204' 
		,'04', '39'
		, (select top 1 IsNull(dx_lookuprawdatavalue,fgt_unit) from  dx_lookup (nolock) where  dx_lookuptable = 'CountUOM' and dx_lookuptranslatedvalue = fgt_unit order by dx_lookuprawdatavalue)
		, REPLICATE('0',10-LEN(convert(varchar(10),convert(int,ISNULL(fgt_quantity,0.00)*100))))+convert(varchar(10),convert(int,ISNULL(fgt_quantity,0.00)*100))
		, (select top 1 IsNull(dx_lookuprawdatavalue,fgt_weightunit) from  dx_lookup (nolock) where  dx_lookuptable = 'WeightUOM' and dx_lookuptranslatedvalue = fgt_weightunit order by dx_lookuprawdatavalue)
		, REPLICATE('0',10-LEN(convert(varchar(10),convert(int,ISNULL(fgt_weight,0.00)*100))))+convert(varchar(10),convert(int,ISNULL(fgt_weight,0.00)*100))
		, (select top 1 IsNull(dx_lookuprawdatavalue,fgt_volumeunit) from  dx_lookup (nolock) where  dx_lookuptable = 'VolumeUOM' and dx_lookuptranslatedvalue = fgt_volumeunit order by dx_lookuprawdatavalue)
		, REPLICATE('0',10-LEN(convert(varchar(10),convert(int,ISNULL(fgt_volume,0.00)*100))))+convert(varchar(10),convert(int,ISNULL(fgt_volume,0.00)*100))
		, fgt_rateunit
		,REPLICATE('0',10-LEN(convert(varchar(10),convert(int,ISNULL(fgt_rate,0.00)*100))))+convert(varchar(10),convert(int,ISNULL(fgt_rate,0.00)*100))
		,'' --currency
		,REPLICATE('0',10-LEN(convert(varchar(10),convert(int,ISNULL(fgt_charge,0.00)*100))))+convert(varchar(10),convert(int,ISNULL(fgt_charge,0.00)*100))
		, fgt_description, cmd_code
		, REPLICATE('0',8-LEN(convert(varchar(8),convert(int,ISNULL(fgt_length,0.00)*100))))+convert(varchar(8),convert(int,ISNULL(fgt_length,0.00)*100))
		, (select top 1 IsNull(dx_lookuprawdatavalue,fgt_lengthunit) from  dx_lookup (nolock) where  dx_lookuptable = 'SizeUOM' and dx_lookuptranslatedvalue = fgt_lengthunit order by dx_lookuprawdatavalue)
		, REPLICATE('0',8-LEN(convert(varchar(8),convert(int,ISNULL(fgt_width,0.00)*100))))+convert(varchar(8),convert(int,ISNULL(fgt_width,0.00)*100))
		, (select top 1 IsNull(dx_lookuprawdatavalue,fgt_widthunit) from  dx_lookup (nolock) where  dx_lookuptable = 'SizeUOM' and dx_lookuptranslatedvalue = fgt_widthunit order by dx_lookuprawdatavalue)
		, REPLICATE('0',8-LEN(convert(varchar(8),convert(int,ISNULL(fgt_height,0.00)*100))))+convert(varchar(8),convert(int,ISNULL(fgt_height,0.00)*100))
		, (select top 1 IsNull(dx_lookuprawdatavalue,fgt_heightunit) from  dx_lookup (nolock) where  dx_lookuptable = 'SizeUOM' and dx_lookuptranslatedvalue = fgt_heightunit order by dx_lookuprawdatavalue)
		, (select top 1 IsNull(dx_lookuprawdatavalue,fgt_count2unit) from  dx_lookup (nolock) where  dx_lookuptable = 'CountUOM' and dx_lookuptranslatedvalue = fgt_count2unit order by dx_lookuprawdatavalue)
		, REPLICATE('0',10-LEN(convert(varchar(10),convert(int,ISNULL(fgt_count2,0.00)*100))))+convert(varchar(10),convert(int,ISNULL(fgt_count2,0.00)*100))
		, REPLICATE('0',10-LEN(convert(varchar(10),convert(int,ISNULL(fgt_actual_quantity,0.00)*100))))+convert(varchar(10),convert(int,ISNULL(fgt_actual_quantity,0.00)*100))
		, @dx_trpid, @dx_billto
	  FROM freightdetail (nolock) 					      
		 WHERE fgt_number= @fgt_number
	declare @freight_ref_id int
	set @freight_ref_id = 0
	while 1=1
	begin
	
	SELECT @freight_ref_id = min(ref_id)
					FROM	referencenumber (nolock)
	 WHERE ref_table = 'freightdetail'
		AND ref_tablekey = @fgt_number
		AND isnull(ref_number,'') <> ''
		AND ref_id > @freight_ref_id 
	If @freight_ref_id is null BREAK
	
	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto)
	select
		'dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, @stp_number, @fgt_number 
		,null, null, null, null, 'EDI204' 
		,'05', '39', isNull(edicode,substring(ref_type,1,3)), ref_number , '', ''
		, @dx_trpid, @dx_billto
	  FROM referencenumber (nolock) left join labelfile (nolock) on labeldefinition = 'referencenumbers' and abbr = ref_type
		 WHERE ref_id = @freight_ref_id 
	end	-- freight ref	   
	end		   
	-- freight reference numbers
	 
	 
	-- 06 record
	exec dx_retrieve_companyinfo @stp_cmp_id, 
		@ord_editradingpartner, 
		@companyname Output, 
		@companyaddress1 output, 
		@cityname output,
		@state output,
		@companyaddress2 output,
		@altid output,
		@country output,
		@phone output, 
		@companyzip output
     
 
	insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		,dx_field007, dx_field008, dx_field009, dx_field010, dx_field011, dx_field012
		,dx_field013
		, dx_trpid, dx_billto)
		values
		('dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, @stp_number, 0 
		,null, null, null, null, 'EDI204' 
		,'06', '39', 'ST', @companyname, substring(@companyaddress1,1,35) , @companyaddress2 
		,@cityname, @state, @companyzip, @country, @phone, @companyaddress1
		,@altid
		, @dx_trpid, @dx_billto)
	
		-- 07 records
		
		insert @dx_archive(dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006
		, dx_trpid, dx_billto)
		select 
		'dx_204', 'manual entry treated like 204', @dx_sourcedate,'Y', 0, 
		@dx_ordernumber, 
		@dx_orderhdrnumber, 
		@mov_number, @stp_number, 0 
		,null, null, null, null, 'EDI204' 
		,'07', '39', dx_field003, dx_field004, dx_field005, dx_field006
		, @dx_trpid, @dx_billto
		from dx_archive where dx_sourcedate = (select max(dx_sourcedate) from dx_archive where dx_orderhdrnumber = @dx_orderhdrnumber and isnull(dx_processed,'DONE') = 'DONE' and dx_importid= 'dx_204')
						and dx_field001 = '07'
						and dx_stopnumber = @stp_number
		order by dx_seq
	end		-- stop
	declare @dx_ident int 
	declare @dx_field001 varchar(100), @dx_field003 varchar(100), @last_field001 varchar(100)
	set @sort_level = 0
	set @dx_ident = 0
	set @dx_seq = 0
	set @last_field001 = ''

		WHILE 1=1
	BEGIN
		select @dx_ident= min(dx_ident)
		from @dx_archive
		where dx_ident > @dx_ident and dx_field001 in ('02', '05')
		if @dx_ident is null break
		select @dx_field001 = dx_field001, @dx_field003 = dx_field003
		from @dx_archive
		where dx_ident = @dx_ident
		if @dx_field001 = '02'
			begin
			set @sort_level = @sort_level + 1
			update @dx_archive
				set sort_level = @sort_level
				where dx_ident = @dx_ident
			end
		else
		if @dx_field001 = '05' and @dx_field003 = '_RM'
			begin
			set @sort_level = @sort_level + 1
			update @dx_archive
				set sort_level = @sort_level
				where dx_ident = @dx_ident
			END

		set @last_field001 = @dx_field001 
	END
	set @dx_ident = 0
	set @sort_level = @sort_level + 1

	WHILE 1=1
	BEGIN
		select @dx_ident= min(dx_ident)
		from @dx_archive
		where dx_ident > @dx_ident and sort_level is null
		if @dx_ident is null break
		select @dx_field001 = dx_field001
		from @dx_archive
		where dx_ident = @dx_ident
		if @dx_field001 <> @last_field001 or @dx_field001 = '04'
			set @sort_level = @sort_level + 1
			
		update @dx_archive
			set sort_level = @sort_level
			where dx_ident = @dx_ident
		set @last_field001 = @dx_field001 
		--print '@sort_level='+convert(varchar, @sort_level) 
		--print '@last_field001='+@last_field001 
	END
	set @dx_ident = 0
	set @dx_seq = 0
	set @sort_level = @sort_level + 1
	WHILE 1=1
	BEGIN
		set @dx_ident = null
		select top 1 @dx_ident = dx_ident
		from @dx_archive
		where dx_seq is null
		order by sort_level, dx_field003, dx_field004
		if @dx_ident is null break
		
		
		set @dx_seq = @dx_seq + 1
		update @dx_archive
			set dx_seq = @dx_seq
			where dx_ident = @dx_ident
	END
	
	select 
		dx_ident, dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, dx_accepted, 
		dx_ordernumber, 
		dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber, 
		dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype, 
		dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006, dx_field007, 
		dx_field008, dx_field009, dx_field010, dx_field011, dx_field012, dx_field013, dx_field014, 
		dx_field015, dx_field016, dx_field017, dx_field018, dx_field019, dx_field020, dx_field021, 
		dx_field022, dx_field023, dx_field024, dx_field025, dx_field026, dx_field027, dx_field028, 
		dx_field029, dx_field030,dx_field031,dx_field032,dx_field033,dx_field034,dx_field035,dx_processed, dx_billto, dx_trpid,dx_sourcedate_reference ,
		dx_processed,dx_createdby,dx_createdate,dx_updatedby,dx_updatedate, convert(bigint, 0) as dx_archive_header_id
		from @dx_archive order by dx_seq
GO
GRANT EXECUTE ON  [dbo].[dx_Simulate204FromOrder] TO [public]
GO
