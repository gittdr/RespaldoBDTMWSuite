SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tmw_purgedata_estimatelists] (	@archive_date 	datetime,
					@include_standard char(1) = 'N',
					@exclude_masters char(1) = 'N',
					@include_xtra_info char(1) = 'N',
					@include_chargetypeaudit char(1) = 'N',
					@include_dispaudit char(1) = 'N',
					@include_expiditeaudit char(1) = 'N',
					@include_invoicedetailaudit char(1) = 'N',
					@include_paydetailaudit char(1) = 'N',
					@include_paytypeaudit char(1) = 'N',
					@include_tripaudit char(1) = 'N',
					@include_orderheader_cancel char(1) = 'N',
					@include_tarifferrorlog char(1) = 'N',
					@include_ttserrorlog char(1) = 'N',
					@include_log_driverlogs char(1) = 'N') as

declare @completedays 	int, 
        @movcount 	int, 
        @invcount 	int, 
        @paycount 	int,
	@xtra_info_count int,
	@chargetypeaudit int,
	@dispaudit int,
	@expiditeaudit int,
	@invoicedetailaudit int,
	@paydetailaudit int,
	@paytypeaudit int,
	@tripaudit int,
	@orderheader_cancel int,
	@tarifferrorlog int,
	@ttserrorlog int,
	@log_driverlogs int,
	@purstatus 	varchar(40)

create table #tmw_purge_summary
	(pur_id int identity primary key,
	 pur_run_date datetime default getdate(),
	 pur_status varchar(40) null,
	 pur_mov_count int null,
	 pur_order_count int null,
	 pur_legheader_count int null,
	 pur_stops_count int null,
	 pur_assetassignment_count int null,
	 pur_inv_count int null,
	 pur_pay_count int null,
	 pur_pay_hdr_count int null,
	 pur_extra_info_data_count int null,
	 pur_chargetype_audit_count int null,
	 pur_disp_audit_count int null,
 	 pur_expidite_audit_count int null,
	 pur_invoicedetail_audit_count int null,
	 pur_paydetail_audit_count int null,
	 pur_paytype_audit_count int null,
	 pur_trip_audit_count int null,
	 pur_orderheader_cancel_log_count int null,
	 pur_tarifferrorlog_count int null,
	 pur_tts_errorlog_count int null,
	 pur_log_driverlogs_count int null)

create table #pur_mov_list(mov_number int)

create table #pur_inv_list(ivh_hdrnumber int)

create table #pur_pay_list(pyd_number int)


create table #pur_pay_hdr_list(pyh_number int)

create table #pur_stops_list(stp_number int)

create table #pur_order_list(ord_hdrnumber int)

create table #pur_legheader_list(lgh_number int)

create table #pur_assetassignment_list(asgn_number int)

INSERT INTO #tmw_purge_summary (pur_run_date, 
                                pur_status, 
                                pur_mov_count, 
                                pur_inv_count, 
                                pur_pay_count,
				pur_order_count,
				pur_legheader_count,
				pur_stops_count,
				pur_assetassignment_count,
				pur_pay_hdr_count,
				pur_extra_info_data_count,
				pur_chargetype_audit_count,
				pur_disp_audit_count,
			 	pur_expidite_audit_count,
				pur_invoicedetail_audit_count,
				pur_paydetail_audit_count,
				pur_paytype_audit_count,
				pur_trip_audit_count,
				pur_orderheader_cancel_log_count,
				pur_tarifferrorlog_count,
				pur_tts_errorlog_count,
				pur_log_driverlogs_count) 
VALUES  (                       getdate(), 
                                @purstatus, 
                                0, 
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0, 
				0,
				0) 

if @include_standard = 'Y'
begin
	--pur_order_list orders that have been invoiced that are older than archive date
	insert #pur_order_list
	select distinct ord_hdrnumber
	from invoiceheader
	where ord_hdrnumber > 0 
	group by ord_hdrnumber having Max(isnull(ivh_billdate, '20491231')) < @archive_date
	
	--pur_order_list orders that are canceled or XIN and completiondate older than archive date
	insert #pur_order_list
	select distinct ord_hdrnumber
	from orderheader
	where ord_completiondate < @archive_date and 
		(ord_status = 'CAN' or ord_invoicestatus='XIN') and
		ord_hdrnumber > 0 
	        and not exists (select * from #pur_order_list where #pur_order_list.ord_hdrnumber = orderheader.ord_hdrnumber) 

	--pur_order_list  remove orders that have a status of MST if masters are to be left in the system
	if @exclude_masters = 'Y'
	delete from #pur_order_list
	where #pur_order_list.ord_hdrnumber in (select distinct ord_hdrnumber from orderheader where ord_status = 'MST')
	
	--pur_mov_list add moves from the pur_order_list
	insert #pur_mov_list
	select distinct mov_number
	from stops, #pur_order_list
	where stops.ord_hdrnumber = #pur_order_list.ord_hdrnumber and
		stops.ord_hdrnumber > 0 and
		mov_number > 0
	
	--pur_mov_list MT moves from the legheader
	insert #pur_mov_list
	select distinct mov_number
	from legheader 
	where ord_hdrnumber = 0 and lgh_enddate < @archive_date and mov_number > 0
	        and not exists (select * from #pur_mov_list where #pur_mov_list.mov_number = legheader.mov_number) 
	
	--pur_order_list add releated crossdocks
	insert #pur_order_list
	select distinct ord_hdrnumber
	from #pur_mov_list, stops
	where #pur_mov_list.mov_number = stops.mov_number and
	not exists (select * from #pur_order_list
			where stops.ord_hdrnumber = #pur_order_list.ord_hdrnumber)
		and stops.ord_hdrnumber > 0
			
	--pur_stops_list Make stops list
	insert #pur_stops_list
	select distinct stp_number
	from stops, #pur_mov_list
	where stops.mov_number = #pur_mov_list.mov_number
	
	--pur_legheader_list Make Legheader list
	insert #pur_legheader_list
	select distinct lgh_number
	from stops, #pur_mov_list
	where stops.mov_number = #pur_mov_list.mov_number and lgh_number > 0 and
		not exists (select * from #pur_legheader_list where stops.lgh_number = #pur_legheader_list.lgh_number)
	
	--arc_assetassignment_list
	insert #pur_assetassignment_list
	select distinct asgn_number
	from assetassignment, #pur_legheader_list
	where assetassignment.lgh_number = #pur_legheader_list.lgh_number and
		not exists (select * from #pur_assetassignment_list where assetassignment.asgn_number = #pur_assetassignment_list.asgn_number)
	
	
	--pur_inv_list load in misc invoices
	insert #pur_inv_list
	select distinct ivh_hdrnumber
	from invoiceheader
	where ord_hdrnumber = 0 and ivh_billdate < @archive_date
	
	--pur_inv_list load invoices based on ord_list
	insert #pur_inv_list
	select distinct ivh_hdrnumber
	from invoiceheader, #pur_order_list
	where invoiceheader.ord_hdrnumber =  #pur_order_list.ord_hdrnumber
	
	--pur_pay_list paydetails by mov number when pay header = 0 
	insert #pur_pay_list
	select distinct pyd_number
	from paydetail, #pur_mov_list
	where paydetail.mov_number = #pur_mov_list.mov_number
	
	--now make payheader list from details
	insert #pur_pay_hdr_list
	select distinct pyh_number
	from paydetail, #pur_pay_list
	where #pur_pay_list.pyd_number = paydetail.pyd_number and 
		isnull(paydetail.pyh_number,0) > 0
	
	--now bring in all paydetail for header
	insert #pur_pay_list
	select distinct pyd_number
	from paydetail, #pur_pay_hdr_list
	where paydetail.pyh_number = #pur_pay_hdr_list.pyh_number and 
		not exists (select * from #pur_pay_list where #pur_pay_list.pyd_number = paydetail.pyd_number )
	
	
	
	--update archive summary with rowcounts
	UPDATE [#tmw_purge_summary]
	SET 	[pur_mov_count]=(select count(*) from #pur_mov_list),
		[pur_order_count]=(select count(*) from #pur_order_list),
		[pur_legheader_count]=(select count(*) from #pur_legheader_list),
		[pur_stops_count]=(select count(*) from #pur_stops_list),
		[pur_assetassignment_count]=(select count(*) from #pur_assetassignment_list),
		[pur_inv_count]=(select count(*) from #pur_inv_list),
		[pur_pay_count]=(select count(*) from #pur_pay_list),
		[pur_pay_hdr_count] = (select count(*) from #pur_pay_hdr_list)
end -- standard purge
if (@include_xtra_info = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_extra_info_data_count = (select count(*) from extra_info_data where last_updatedate < @archive_date and extra_id = 7 )
end
if (@include_chargetypeaudit = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_chargetype_audit_count = (select count(*) from chargetypeaudit where audit_dttm < @archive_date)
end
if (@include_dispaudit = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_disp_audit_count = (select count(*) from dispaudit where updated_dt < @archive_date)
end
if (@include_expiditeaudit = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_expidite_audit_count = (select count(*) from expedite_audit where updated_dt < @archive_date)
end
if (@include_invoicedetailaudit = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_invoicedetail_audit_count = (select count(*) from invoicedetailaudit where audit_date < @archive_date)
end
if (@include_paydetailaudit = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_paydetail_audit_count = (select count(*) from paydetailaudit where audit_date < @archive_date)
end
if (@include_paytypeaudit = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_paytype_audit_count = (select count(*) from paytypeaudit where audit_dttm < @archive_date)
end
if (@include_tripaudit  = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_trip_audit_count = (select count(*) from tripaudit where upd_date < @archive_date)
end
if (@include_orderheader_cancel = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_orderheader_cancel_log_count = (select count(*) from orderheader_cancel_log where ohc_cancelled_date < @archive_date)
end
if (@include_tarifferrorlog = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_tarifferrorlog_count = (select count(*) from tarifferrorlog where tel_dttm < @archive_date)
end
if (@include_ttserrorlog = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_tts_errorlog_count = (select count(*) from tts_errorlog where err_date < @archive_date)
end
if (@include_log_driverlogs = 'Y')
begin
	UPDATE #tmw_purge_summary
	SET 	pur_log_driverlogs_count = (select count(*) from log_driverlogs where log_date < @archive_date)
end

update #tmw_purge_summary
set [pur_status]='Purge Make Lists Complete'

SELECT 	*
FROM	#tmw_purge_summary

GO
GRANT EXECUTE ON  [dbo].[tmw_purgedata_estimatelists] TO [public]
GO
