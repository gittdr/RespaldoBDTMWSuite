SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_dedicated_bill_adddelete_invoices_list_sp] (	
@dbh_id				int,
@Billto					varchar(8),
@revtype1		varchar(6),
@revtype2		varchar(6),
@revtype3		varchar(6),
@revtype4		varchar(6),
@branch				varchar(12),
@startdate		datetime,
@enddate			datetime,
@usedate			varchar(8)
,@ivh_splitgroup		varchar(6)	--PTS 63450 nloke
)
AS

/*
*Created for PTS 53511 in order to bring in notes check 
* Removed in line datawindow SQL and now call this stored procedure
* PTS 53507 SGB exclude any invoice that has a dbh_id 
* PTS 53507 SGB Include the column ivh_definition
* PTS 53500 SGB Added two new @Usedate values 'LAST' and 'DRPA' for dates on trips
* PTS 57140 NQIAO Added new field 'allocate_flag' in #results for output
* PTS 59328 NQIAO Output invoiceheader.ivh_dballocate_flag instead of 'N' for allocate_flag
* PTS 59166 Added new Use Date options
* PTS 63574 Changed @branch from varchar(8) to varchar(12)
* PTS 62719 NQIAO Added new codes for the dedicated bills
*/

DECLARE @notes_count int,
@Order int,
@nextrec int,
@mov_number int,
@key						char(18), 
@table					char(18) , 
@Shipper			varchar(8),
@Consignee	varchar(8),
@CmdCode   varchar(8),
@Commodity varchar(8),
@Tractor      varchar(8), 
@Trailer1			varchar(13),
@Trailer2			varchar(13),
@Driver1				varchar(8),
@Driver2				varchar(8),
@Carrier				varchar(8) 


--arguments=(("dbh_id", number),("billto", string),("revtype1", string),("revtype2", string),("revtype3", string),("revtype4", string),("branch", string),("startdate", datetime),("enddate", datetime)) )

CREATE table #results (
ivh_invoicenumber char(12),
ivh_totalcharge money,
ivh_invoicecharge money,
ivh_allocated money,
ivh_billto varchar(8),
ivh_shipper varchar(8),
ivh_consignee varchar(8),
ivh_deliverydate datetime,
ivh_shipdate datetime,
ivh_billdate datetime,
ivh_revtype1 varchar(6),
ivh_revtype2 varchar(6),
ivh_revtype3 varchar(6),
ivh_revtype4 varchar(6),
ivh_booked_revtype1 char(12),
ivh_mbstatus char(6),
dbd_id int,
dbh_id int,
ivh_hdrnumber int,
created_date datetime,
created_user char(20),
modified_date datetime,
modified_user char(20),
include_flag char(1),
ord_hdrnumber int,
notes_count int,
ivh_definition varchar(6), --PTS 53507 SGB
mov_number int, --PTS 53500 SGB
retrieval_date datetime, --PTS 53500 SGB
allocate_flag char(1)	-- PTS 57140 NQIAO
,ivh_splitgroup	varchar(6)	--PTS 63450 nloke
)

IF @usedate = 'BILL' 
BEGIN 
	Insert into #results
	SELECT 
	C.ivh_invoicenumber, 
	C.ivh_totalcharge, 
	C.ivh_totalcharge, 
	0.0000, 
	C.ivh_billto, 
	C.ivh_shipper, 
	C.ivh_consignee,
	C.ivh_deliverydate,
	C.ivh_shipdate, 
	C.ivh_billdate, 
	C.ivh_revtype1, 
	C.ivh_revtype2, 
	C.ivh_revtype3, 
	C.ivh_revtype4, 
	C.ivh_booked_revtype1, 
	C.ivh_mbstatus, 
	B.dbd_id, 
	B.dbh_id, 
	A.ivh_hdrnumber, 
	B.created_date, 
	B.created_user, 
	B.modified_date, 
	B.modified_user, 
	'N', 
	C.ord_hdrnumber, 
	0,
	C.ivh_definition, --PTS 53507 SGB
	C.mov_number, -- PTS 53500 SGB
	C.ivh_billdate,		-- PTS 53500 SGB
	--'N'		-- PTS 57140 NQIAO
	ISNULL(C.ivh_dballocate_flag, 'N')		-- PTS59328
	/*,ISNULL(C.ivh_splitgroup, 'UNKNOWN')	--PTS 63450 nloke*/
	,C.ivh_splitgroup --PTS 66208

	from (	select ivh_hdrnumber 
			from dedbillingdetail
			where dbh_id = @dbh_id
			union
			select ivh_hdrnumber
			from invoiceheader
			-- where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO', 'PRN') -- PTS53812 SGB Do not include PRN
			where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO')
			AND invoiceheader.ivh_billto = @billto
			AND (invoiceheader.ivh_revtype1 = @revtype1 OR @revtype1 = 'UNK')
			AND (invoiceheader.ivh_revtype2 = @revtype2 OR @revtype2 = 'UNK')
			AND (invoiceheader.ivh_revtype3 = @revtype3 OR @revtype3 = 'UNK')
			AND (invoiceheader.ivh_revtype4 = @revtype4 OR @revtype4 = 'UNK')
			AND (invoiceheader.ivh_booked_revtype1 = @branch OR @branch = 'UNKNOWN')
			AND invoiceheader.ivh_billdate <= @enddate
			AND IsNull (invoiceheader.ivh_definition, '') <> 'DEDBIL'
			AND ivh_hdrnumber NOT in (select ivh_hdrnumber from dedbillingdetail where dedbillingdetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
			AND isnull(invoiceheader.dbh_id,0) = 0 
			AND IsNull(invoiceheader.ivh_splitgroup,'')= @ivh_splitgroup) A   /*PTS 66208 CGK Add Parenthesis and Removed OR*/ 
	left outer join	(select dbd_id, dbh_id, ivh_hdrnumber, created_date, created_user, modified_date, modified_user	
	from dedbillingdetail where dbh_id = @dbh_id) B on A.ivh_hdrnumber = B.ivh_hdrnumber
	join invoiceheader C on A.ivh_hdrnumber = C.ivh_hdrnumber  
	

END	--BILL
ELSE IF @usedate = 'SHIP' 
BEGIN
	Insert into #results
	SELECT 
	C.ivh_invoicenumber, 
	C.ivh_totalcharge, 
	C.ivh_totalcharge, 
	0.0000, 
	C.ivh_billto, 
	C.ivh_shipper, 
	C.ivh_consignee,
	C.ivh_deliverydate,
	C.ivh_shipdate, 
	C.ivh_billdate, 
	C.ivh_revtype1, 
	C.ivh_revtype2, 
	C.ivh_revtype3, 
	C.ivh_revtype4, 
	C.ivh_booked_revtype1, 
	C.ivh_mbstatus, 
	B.dbd_id, 
	B.dbh_id, 
	A.ivh_hdrnumber, 
	B.created_date, 
	B.created_user, 
	B.modified_date, 
	B.modified_user, 
	'N', 
	C.ord_hdrnumber, 
	0,
	C.ivh_definition, -- PTS 53507 SGB
	C.mov_number, -- PTS 53500 SGB
	C.ivh_shipdate, -- PTS 53500 SGB
	--'N'		-- PTS 57140 NQIAO
	ISNULL(C.ivh_dballocate_flag, 'N'),		-- PTS59328
	--,ISNULL(C.ivh_splitgroup, 'UNKNOWN')	--PTS 63450 nloke
	C.ivh_splitgroup --PTS 66208
	from (	select ivh_hdrnumber 
			from dedbillingdetail
			where dbh_id = @dbh_id
			union
			select ivh_hdrnumber
			from invoiceheader
			-- where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO', 'PRN') -- PTS53812 SGB Do not include PRN
			where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO')
			AND invoiceheader.ivh_billto = @billto
			AND (invoiceheader.ivh_revtype1 = @revtype1 OR @revtype1 = 'UNK')
			AND (invoiceheader.ivh_revtype2 = @revtype2 OR @revtype2 = 'UNK')
			AND (invoiceheader.ivh_revtype3 = @revtype3 OR @revtype3 = 'UNK')
			AND (invoiceheader.ivh_revtype4 = @revtype4 OR @revtype4 = 'UNK')
			AND (invoiceheader.ivh_booked_revtype1 = @branch OR @branch = 'UNKNOWN')
			AND invoiceheader.ivh_shipdate <= @enddate
			AND IsNull (invoiceheader.ivh_definition, '') <> 'DEDBIL'
			AND ivh_hdrnumber NOT in (select ivh_hdrnumber from dedbillingdetail where dedbillingdetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
			AND isnull(invoiceheader.dbh_id,0) = 0  -- PTS 53507 Exclude Invoices with dbh_id
			AND IsNull(invoiceheader.ivh_splitgroup,'')= @ivh_splitgroup) A	/*PTS 66208 CGK Removed OR*/  
	left outer join	(select dbd_id, dbh_id, ivh_hdrnumber, created_date, created_user, modified_date, modified_user	
	from dedbillingdetail where dbh_id = @dbh_id) B on A.ivh_hdrnumber = B.ivh_hdrnumber
	join invoiceheader C on A.ivh_hdrnumber = C.ivh_hdrnumber  
END --SHIP

--BEGIN PTS 59166 SGB Consolidated  LAST and DRPA Added DRPS for date restrictions
--ELSE IF @usedate = 'LAST' or @usedate = 'DRPA' or @usedate = 'DRPS'  --NQIAO 12/12/12 PTS 62719
ELSE IF @usedate in ('LAST', 'DRPA', 'DRPS', 'AVIL', 'AFSP', 'DFSP', 'DLSP', 'BKDT', 'ESSP', 'FPSD') -- NQIAO 12/12/12 PTS 62719 <start>
BEGIN
	Insert into #results
	SELECT 
	C.ivh_invoicenumber, 
	C.ivh_totalcharge, 
	C.ivh_totalcharge, 
	0.0000, 
	C.ivh_billto, 
	C.ivh_shipper, 
	C.ivh_consignee,
	C.ivh_deliverydate,
	C.ivh_shipdate, 
	C.ivh_billdate, 
	C.ivh_revtype1, 
	C.ivh_revtype2, 
	C.ivh_revtype3, 
	C.ivh_revtype4, 
	C.ivh_booked_revtype1, 
	C.ivh_mbstatus, 
	B.dbd_id, 
	B.dbh_id, 
	A.ivh_hdrnumber, 
	B.created_date, 
	B.created_user, 
	B.modified_date, 
	B.modified_user, 
	'N', 
	C.ord_hdrnumber, 
	0,
	C.ivh_definition, -- PTS 53507 SGB
	C.mov_number, -- PTS 53500 SGB
	ivh_dedicated_includedate,
	ISNULL(C.ivh_dballocate_flag, 'N')		-- PTS59328
	--,ISNULL(C.ivh_splitgroup, 'UNKNOWN')		--PTS 63450 nloke
	,C.ivh_splitgroup	--PTS 66208


	from (	select ivh_hdrnumber 
			from dedbillingdetail
			where dbh_id = @dbh_id
			union
			select ivh_hdrnumber
			from invoiceheader
			-- where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO', 'PRN') -- PTS53812 SGB Do not include PRN
			where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO')
			AND invoiceheader.ivh_billto = @billto
			AND (invoiceheader.ivh_revtype1 = @revtype1 OR @revtype1 = 'UNK')
			AND (invoiceheader.ivh_revtype2 = @revtype2 OR @revtype2 = 'UNK')
			AND (invoiceheader.ivh_revtype3 = @revtype3 OR @revtype3 = 'UNK')
			AND (invoiceheader.ivh_revtype4 = @revtype4 OR @revtype4 = 'UNK')
			AND (invoiceheader.ivh_booked_revtype1 = @branch OR @branch = 'UNKNOWN')
			AND invoiceheader.ivh_dedicated_includedate <= @enddate -- PTS 59166 ivh_dedicated_includedate updated by invoice header trigger
			AND IsNull (invoiceheader.ivh_definition, '') <> 'DEDBIL'
			AND ivh_hdrnumber NOT in (select ivh_hdrnumber from dedbillingdetail where dedbillingdetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
			AND isnull(invoiceheader.dbh_id,0) = 0  -- PTS 53507 Exclude Invoices with dbh_id
			AND IsNull(invoiceheader.ivh_splitgroup,'')= @ivh_splitgroup) A  /*PTS 66208 CGK Removed OR*/ 
	left outer join	(select dbd_id, dbh_id, ivh_hdrnumber, created_date, created_user, modified_date, modified_user	
	from dedbillingdetail where dbh_id = @dbh_id) B on A.ivh_hdrnumber = B.ivh_hdrnumber
	join invoiceheader C on A.ivh_hdrnumber = C.ivh_hdrnumber  

/*	
	UPDATE #results
	set retrieval_date = (select max(s.stp_arrivaldate) from stops s where s.mov_number = r.mov_number )
	FROM #results r
	
	delete #results where retrieval_date > @enddate
	*/
END -- LAST, DRPA, DRPS

--END PTS 59166
/*
--BEGIN PTS 53500 Added LAST and DRPA for date restrictions
ELSE IF @usedate = 'LAST' 
BEGIN
	Insert into #results
	SELECT 
	C.ivh_invoicenumber, 
	C.ivh_totalcharge, 
	C.ivh_totalcharge, 
	0.0000, 
	C.ivh_billto, 
	C.ivh_shipper, 
	C.ivh_consignee,
	C.ivh_deliverydate,
	C.ivh_shipdate, 
	C.ivh_billdate, 
	C.ivh_revtype1, 
	C.ivh_revtype2, 
	C.ivh_revtype3, 
	C.ivh_revtype4, 
	C.ivh_booked_revtype1, 
	C.ivh_mbstatus, 
	B.dbd_id, 
	B.dbh_id, 
	A.ivh_hdrnumber, 
	B.created_date, 
	B.created_user, 
	B.modified_date, 
	B.modified_user, 
	'N', 
	C.ord_hdrnumber, 
	0,
	C.ivh_definition, -- PTS 53507 SGB
	C.mov_number, -- PTS 53500 SGB
	NULL,
	--'N'		-- PTS 57140 NQIAO
	ISNULL(C.ivh_dballocate_flag, 'N')		-- PTS59328

	from (	select ivh_hdrnumber 
			from dedbillingdetail
			where dbh_id = @dbh_id
			union
			select ivh_hdrnumber
			from invoiceheader
			-- where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO', 'PRN') -- PTS53812 SGB Do not include PRN
			where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO')
			AND invoiceheader.ivh_billto = @billto
			AND (invoiceheader.ivh_revtype1 = @revtype1 OR @revtype1 = 'UNK')
			AND (invoiceheader.ivh_revtype2 = @revtype2 OR @revtype2 = 'UNK')
			AND (invoiceheader.ivh_revtype3 = @revtype3 OR @revtype3 = 'UNK')
			AND (invoiceheader.ivh_revtype4 = @revtype4 OR @revtype4 = 'UNK')
			AND (invoiceheader.ivh_booked_revtype1 = @branch OR @branch = 'UNKNOWN')
			--AND invoiceheader.ivh_shipdate <= @enddate -- PTS 53500 Do not filter initial retrieval by date
			AND IsNull (invoiceheader.ivh_definition, '') <> 'DEDBIL'
			AND ivh_hdrnumber NOT in (select ivh_hdrnumber from dedbillingdetail where dedbillingdetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
			AND isnull(invoiceheader.dbh_id,0) = 0) A -- PTS 53507 Exclude Invoices with dbh_id
	left outer join	(select dbd_id, dbh_id, ivh_hdrnumber, created_date, created_user, modified_date, modified_user	
	from dedbillingdetail where dbh_id = @dbh_id) B on A.ivh_hdrnumber = B.ivh_hdrnumber
	join invoiceheader C on A.ivh_hdrnumber = C.ivh_hdrnumber  
	
	UPDATE #results
	set retrieval_date = (select max(s.stp_arrivaldate) from stops s where s.mov_number = r.mov_number )
	FROM #results r
	
	delete #results where retrieval_date > @enddate
END -- LAST

ELSE IF @usedate = 'DRPA' 
BEGIN
	Insert into #results
	SELECT 
	C.ivh_invoicenumber, 
	C.ivh_totalcharge, 
	C.ivh_totalcharge, 
	0.0000, 
	C.ivh_billto, 
	C.ivh_shipper, 
	C.ivh_consignee,
	C.ivh_deliverydate,
	C.ivh_shipdate, 
	C.ivh_billdate, 
	C.ivh_revtype1, 
	C.ivh_revtype2, 
	C.ivh_revtype3, 
	C.ivh_revtype4, 
	C.ivh_booked_revtype1, 
	C.ivh_mbstatus, 
	B.dbd_id, 
	B.dbh_id, 
	A.ivh_hdrnumber, 
	B.created_date, 
	B.created_user, 
	B.modified_date, 
	B.modified_user, 
	'N', 
	C.ord_hdrnumber, 
	0,
	C.ivh_definition, -- PTS 53507 SGB
	C.mov_number, -- PTS 53500 SGB
	NULL,
	--'N'		-- PTS 57140 NQIAO
	ISNULL(C.ivh_dballocate_flag, 'N')		-- PTS59328

	from (	select ivh_hdrnumber 
			from dedbillingdetail
			where dbh_id = @dbh_id
			union
			select ivh_hdrnumber
			from invoiceheader
			-- where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO', 'PRN') -- PTS53812 SGB Do not include PRN
			where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO')
			AND invoiceheader.ivh_billto = @billto
			AND (invoiceheader.ivh_revtype1 = @revtype1 OR @revtype1 = 'UNK')
			AND (invoiceheader.ivh_revtype2 = @revtype2 OR @revtype2 = 'UNK')
			AND (invoiceheader.ivh_revtype3 = @revtype3 OR @revtype3 = 'UNK')
			AND (invoiceheader.ivh_revtype4 = @revtype4 OR @revtype4 = 'UNK')
			AND (invoiceheader.ivh_booked_revtype1 = @branch OR @branch = 'UNKNOWN')
			-- AND invoiceheader.ivh_shipdate <= @enddate -- PTS 53500 Do not filter initial retrieval by date
			AND IsNull (invoiceheader.ivh_definition, '') <> 'DEDBIL'
			AND ivh_hdrnumber NOT in (select ivh_hdrnumber from dedbillingdetail where dedbillingdetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
			AND isnull(invoiceheader.dbh_id,0) = 0) A -- PTS 53507 Exclude Invoices with dbh_id
	left outer join	(select dbd_id, dbh_id, ivh_hdrnumber, created_date, created_user, modified_date, modified_user	
	from dedbillingdetail where dbh_id = @dbh_id) B on A.ivh_hdrnumber = B.ivh_hdrnumber
	join invoiceheader C on A.ivh_hdrnumber = C.ivh_hdrnumber  
	
	UPDATE #results
	set retrieval_date = (select min(s.stp_arrivaldate) from stops s where s.mov_number = r.mov_number and s.stp_type = 'DRP')
	FROM #results r
	
	delete #results where retrieval_date > @enddate
	 
	
END --DRPA
--END PTS 53500 Added LAST and DRPA for date restrictions
*/
ELSE
BEGIN 
	Insert into #results
	SELECT 
	C.ivh_invoicenumber, 
	C.ivh_totalcharge, 
	C.ivh_totalcharge, 
	0.0000, 
	C.ivh_billto, 
	C.ivh_shipper, 
	C.ivh_consignee,
	C.ivh_deliverydate,
	C.ivh_shipdate, 
	C.ivh_billdate, 
	C.ivh_revtype1, 
	C.ivh_revtype2, 
	C.ivh_revtype3, 
	C.ivh_revtype4, 
	C.ivh_booked_revtype1, 
	C.ivh_mbstatus, 
	B.dbd_id, 
	B.dbh_id, 
	A.ivh_hdrnumber, 
	B.created_date, 
	B.created_user, 
	B.modified_date, 
	B.modified_user, 
	'N', 
	C.ord_hdrnumber, 
	0,
	C.ivh_definition, -- PTS 53507 SGB
	C.mov_number, -- PTS 53500 SGB
	NULL,
	--'N'		-- PTS 57140 NQIAO
	ISNULL(C.ivh_dballocate_flag, 'N')		-- PTS59328
	--,ISNULL(C.ivh_splitgroup, 'UNKNOWN')		--PTS 63450 nloke
	,C.ivh_splitgroup	--PTS 66208

	from (	select ivh_hdrnumber 
			from dedbillingdetail
			where dbh_id = @dbh_id
			union
			select ivh_hdrnumber
			from invoiceheader
			-- where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO', 'PRN') -- PTS53812 SGB Do not include PRN
			where invoiceheader.ivh_mbstatus IN ('RTP', 'PRO')
			AND invoiceheader.ivh_billto = @billto
			AND (invoiceheader.ivh_revtype1 = @revtype1 OR @revtype1 = 'UNK')
			AND (invoiceheader.ivh_revtype2 = @revtype2 OR @revtype2 = 'UNK')
			AND (invoiceheader.ivh_revtype3 = @revtype3 OR @revtype3 = 'UNK')
			AND (invoiceheader.ivh_revtype4 = @revtype4 OR @revtype4 = 'UNK')
			AND (invoiceheader.ivh_booked_revtype1 = @branch OR @branch = 'UNKNOWN')
			AND invoiceheader.ivh_deliverydate <= @enddate
			AND IsNull (invoiceheader.ivh_definition, '') <> 'DEDBIL'
			AND ivh_hdrnumber NOT in (select ivh_hdrnumber from dedbillingdetail where dedbillingdetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
			AND isnull(invoiceheader.dbh_id,0) = 0 -- PTS 53507 Exclude Invoices with dbh_id 
			AND IsNull(invoiceheader.ivh_splitgroup,'')= @ivh_splitgroup) A /*PTS 66208 CGK Removed OR*/  
	left outer join	(select dbd_id, dbh_id, ivh_hdrnumber, created_date, created_user, modified_date, modified_user	
	from dedbillingdetail where dbh_id = @dbh_id) B on A.ivh_hdrnumber = B.ivh_hdrnumber
	join invoiceheader C on A.ivh_hdrnumber = C.ivh_hdrnumber  

END --ELSE
	
	
select  @nextrec = min(ivh_hdrnumber) from #results
 While @nextrec is not null
    BEGIN	
    
			--Select @Order = ord_hdrnumber from #results where ivh_hdrnumber = @nextrec
			Select 
			@mov_number	= isnull(mov_number,0),
			@Billto					= isnull(ivh_Billto,'UNKNOWN'),
			@Shipper			= isnull(ivh_shipper,'UNKNOWN'),
			@Consignee	= isnull(ivh_consignee,'UNKNOWN'),
			@Tractor      = isnull(ivh_tractor,'UNKNOWN'),
			@Trailer1				= isnull(ivh_trailer,'UNKNOWN'),
			@Trailer2			= isnull(ivh_trailer2,'UNKNOWN'),
			@Driver1				= isnull(ivh_driver,'UNKNOWN'),
			@Driver2				= isnull(ivh_driver2,'UNKNOWN'),
			@Carrier				= isnull(ivh_carrier,'UNKNOWN'),
			@CmdCode   = isnull(ivh_order_cmd_code,'UNKNOWN'),
			@Order = isnull(ord_hdrnumber,0)
			From invoiceheader where ivh_hdrnumber = @nextrec
		
				
			EXEC @notes_count = d_notes_check_sp	2, 
			@mov_number, 
			@Order, 
			@nextrec, 
			@Driver1	, 
			@Driver2, 
			@Tractor, 
			@Trailer1, 
			@Trailer2, 
			@carrier, 
			@Shipper, 
			@Consignee, 
			@Billto, 
			0,
			@CmdCode,
			'',
			0
			-- DEBUG Statement
			--select @order,@nextrec,@notes_count
			   
			Update #results	
			Set Notes_count = @notes_count
			Where 	ivh_hdrnumber = @nextrec
			
			select @nextrec = min(ivh_hdrnumber) from #results where ivh_hdrnumber > @nextrec	
	END
		       	
	
Select        ivh_invoicenumber ,
ivh_totalcharge,
ivh_invoicecharge,
ivh_allocated,
ivh_billto,
ivh_shipper,
ivh_consignee,
ivh_deliverydate,
ivh_shipdate,
ivh_billdate,
ivh_revtype1,
ivh_revtype2,
ivh_revtype3,
ivh_revtype4,
ivh_booked_revtype1,
ivh_mbstatus,
dbd_id,
dbh_id,
ivh_hdrnumber,
created_date,
created_user,
modified_date,
modified_user,
include_flag,
ord_hdrnumber,
notes_count,
ivh_definition, -- PTS 53507 SGB
retrieval_date, -- PTS 53500 SGB
allocate_flag	-- PTS 57140 NQIAO
ivh_splitgroup	-- PTS 63450 nloke
from #results         
	
	
	
GO
GRANT EXECUTE ON  [dbo].[d_dedicated_bill_adddelete_invoices_list_sp] TO [public]
GO
