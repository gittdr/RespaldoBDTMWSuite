SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[tmw_purgedata_by_pur_id] (@pur_id	int,
					@archive_date datetime,
					@include_standard char(1) = 'N',
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
					@include_log_driverlogs char(1) = 'N')
AS
--This is the SQL Server 2000 version of the tmw_purgedata_by_pur_id stored procedure
Declare 	@sql	nvarchar(1024)

update tmw_purge_summary
set pur_status = 'Deleting from list tables'
where pur_id = @pur_id

if (@include_standard = 'Y')
begin
	--1. legheader (arc_legheader_list)
	select @sql = N'alter table legheader disable trigger all'
	exec sp_executesql @sql
	delete from legheader with (xlock tablock)
	where exists (select 	* from pur_legheader_list
			where 	pur_legheader_list.pur_id  = @pur_id and
				pur_legheader_list.lgh_number = legheader.lgh_number) 
	select @sql = N'alter table legheader enable trigger all'
	exec sp_executesql @sql
	
	
	--2.	Stops (arc_stops_list)
	select @sql = N'alter table stops disable trigger all'
	exec sp_executesql @sql
	delete from stops with (xlock tablock)
	where exists (select 	* from pur_stops_list
			where 	pur_stops_list.pur_id  = @pur_id and
				pur_stops_list.stp_number = stops.stp_number) 
	select @sql = N'alter table stops enable trigger all'
	exec sp_executesql @sql
	 
	--3.	Assetassignment (arc_assetassignment_list)
	select @sql = N'alter table assetassignment disable trigger all'
	exec sp_executesql @sql
	delete from assetassignment with (xlock tablock)
	where exists (select 	* from pur_assetassignment_list
			where 	pur_assetassignment_list.pur_id  = @pur_id and
				pur_assetassignment_list.asgn_number = assetassignment.asgn_number) 
	select @sql = N'alter table assetassignment enable trigger all'
	exec sp_executesql @sql
	
	
	--4.	Paydetail (arc_pay_list)
	select @sql = N'alter table paydetail disable trigger all'
	exec sp_executesql @sql
	delete from paydetail with (xlock tablock)
	where exists (select 	* from pur_pay_list
			where 	pur_pay_list.pur_id  = @pur_id and
				pur_pay_list.pyd_number = paydetail.pyd_number) 
	select @sql = N'alter table paydetail enable trigger all'
	exec sp_executesql @sql
	
	--4.2	Payheader (arc_pay_hdr_list)
	select @sql = N'alter table Payheader disable trigger all'
	exec sp_executesql @sql
	delete from Payheader with (xlock tablock)
	where exists (select 	* from pur_pay_hdr_list
			where 	pur_pay_hdr_list.pur_id  = @pur_id and
				pur_pay_hdr_list.pyh_number = payheader.pyh_pyhnumber) 
	select @sql = N'alter table Payheader enable trigger all'
	exec sp_executesql @sql
	
	
	--5.	event (by stp_number )
	select @sql = N'alter table event disable trigger all'
	exec sp_executesql @sql
	delete from event with (xlock tablock)
	where exists (select 	* from pur_stops_list
			where 	pur_stops_list.pur_id  = @pur_id and
				pur_stops_list.stp_number = event.stp_number) 
	select @sql = N'alter table event enable trigger all'
	exec sp_executesql @sql
	
	
	--6.	Freightdetail (by stp_number )
	select @sql = N'alter table freightdetail disable trigger all'
	exec sp_executesql @sql
	delete from freightdetail with (xlock tablock)
	where exists (select 	* from pur_stops_list
			where 	pur_stops_list.pur_id  = @pur_id and
				pur_stops_list.stp_number = freightdetail.stp_number) 
	select @sql = N'alter table freightdetail enable trigger all'
	exec sp_executesql @sql
	
	--7.	Orderheader (arc_order_list)
	select @sql = N'alter table orderheader disable trigger all'
	exec sp_executesql @sql
	delete from orderheader with (xlock tablock)
	where exists (select 	* from pur_order_list
			where 	pur_order_list.pur_id  = @pur_id and
				pur_order_list.ord_hdrnumber = orderheader.ord_hdrnumber) 
	select @sql = N'alter table orderheader enable trigger all'
	exec sp_executesql @sql
	
	 
	--8.	Invoiceheader ( arc_inv_list)
	select @sql = N'alter table invoiceheader disable trigger all'
	exec sp_executesql @sql
	delete from invoiceheader with (xlock tablock)
	where exists (select 	* from pur_inv_list
			where 	pur_inv_list.pur_id  = @pur_id and
				pur_inv_list.ivh_hdrnumber = invoiceheader.ivh_hdrnumber) 
	select @sql = N'alter table invoiceheader enable trigger all'
	exec sp_executesql @sql
	
	
	--9.	Invoicedetail ( arc_inv_list)
	select @sql = N'alter table invoicedetail disable trigger all'
	exec sp_executesql @sql
	delete from invoicedetail with (xlock tablock)
	where exists (select 	* from pur_inv_list
			where 	pur_inv_list.pur_id  = @pur_id and
				pur_inv_list.ivh_hdrnumber = invoicedetail.ivh_hdrnumber) and
				invoicedetail.ivh_hdrnumber > 0
	select @sql = N'alter table invoicedetail enable trigger all'
	exec sp_executesql @sql
	
	--10.	Referencenumber (one call for each type delete by removing orp)
	select @sql = N'alter table referencenumber disable trigger all'
	exec sp_executesql @sql
	
	delete from Referencenumber with (xlock tablock)
	where  ref_table = 'stops' and
		not exists (select * from stops where stops.stp_number = ref_tablekey) 
	
	delete from Referencenumber with (xlock tablock)
	where  ref_table = 'freightdetail' and
		not exists (select * from freightdetail where freightdetail.fgt_number = ref_tablekey) 
	
	delete from Referencenumber with (xlock tablock)
	where  ref_table = 'invoiceheader' and
		not exists (select * from invoiceheader where invoiceheader.ivh_hdrnumber= ref_tablekey) 
	
	delete from Referencenumber with (xlock tablock)
	where  ref_table = 'ORDERHEADER' and
		not exists (select * from orderheader where orderheader.ord_hdrnumber= ref_tablekey) 
	
	select @sql = N'alter table referencenumber enable trigger all'
	exec sp_executesql @sql
	 
	--12) Paperwork
	select @sql = N'alter table paperwork disable trigger all'
	exec sp_executesql @sql
	delete from paperwork with (xlock tablock)
	where exists (select 	* from pur_order_list
			where 	pur_order_list.pur_id  = @pur_id and
				pur_order_list.ord_hdrnumber = paperwork.ord_hdrnumber) 
	select @sql = N'alter table paperwork enable trigger all'
	exec sp_executesql @sql
	
	select 'starting notes'
	--13) Notes
	select @sql = N'alter table notes disable trigger all'
	exec sp_executesql @sql
	
	delete from notes with (xlock tablock)
	where ntb_table = 'movement' and 
		not exists (select * from stops	where stops.mov_number = nre_tablekey) 
	
	delete from notes with (xlock tablock)
	where ntb_table = 'ETA' and 
		not exists (select * from stops	where stops.mov_number = nre_tablekey) 
	
	-- Delete notes where the key is the ord_hdrnumber
	delete from notes with (xlock tablock)
	where ntb_table = 'orderheader' and 
		not exists (select * from orderheader where convert(varchar, ord_hdrnumber) = nre_tablekey) 
	
	-- Delete notes where the key is the ord_number
	delete from notes with (xlock tablock)
	where ntb_table = 'orderheader' and 
		not exists (select * from orderheader where ord_number = nre_tablekey) 
	
	-- Delete notes where the key is the ivh_invoicenumber
	delete from notes with (xlock tablock)
	where ntb_table = 'invoiceheader' and 
		not exists (select * from invoiceheader where ivh_invoicenumber = nre_tablekey) 
	
	-- delete notes where the key is the ivh_hdrnumber
	delete from notes with (xlock tablock)
	where ntb_table = 'invoiceheader' and 
		not exists (select * from invoiceheader where convert(varchar, ivh_hdrnumber) = nre_tablekey) 
	
	select @sql = N'alter table notes enable trigger all'
	
	exec sp_executesql @sql
end  --standard purge

--14) Extra Info
if (@include_xtra_info = 'Y')
begin
	select @sql = N'alter table extra_info_data disable trigger all'
	exec sp_executesql @sql
	delete from extra_info_data with (xlock tablock) where last_updatedate < @archive_date and extra_id = 7 
	select @sql = N'alter table extra_info_data enable trigger all'
exec sp_executesql @sql
end
--15) Chargetype Audit
if (@include_chargetypeaudit = 'Y')
begin
	select @sql = N'alter table chargetypeaudit disable trigger all'
	exec sp_executesql @sql
	delete from chargetypeaudit with (xlock tablock) where audit_dttm < @archive_date
	select @sql = N'alter table chargetypeaudit enable trigger all'
end
--16) Disp Audit
if (@include_dispaudit = 'Y')
begin
	select @sql = N'alter table dispaudit disable trigger all'
	exec sp_executesql @sql
	delete from dispaudit with (xlock tablock)  where updated_dt < @archive_date
	select @sql = N'alter table dispaudit enable trigger all'
end
--17) Expidite Audit
if (@include_expiditeaudit = 'Y')
begin
	select @sql = N'alter table expedite_audit disable trigger all'
	exec sp_executesql @sql
	delete from expedite_audit with (xlock tablock) where updated_dt < @archive_date
	select @sql = N'alter table expedite_audit enable trigger all'
end
--18) InvoiceDetail Audit
if (@include_invoicedetailaudit = 'Y')
begin
	select @sql = N'alter table invoicedetailaudit disable trigger all'
	exec sp_executesql @sql
	delete from invoicedetailaudit with (xlock tablock) where audit_date < @archive_date
	select @sql = N'alter table invoicedetailaudit enable trigger all'
end
--19) PayType Audit
if (@include_paytypeaudit = 'Y')
begin
	select @sql = N'alter table paytypeaudit disable trigger all'
	exec sp_executesql @sql
	delete from paytypeaudit with (xlock tablock) where audit_dttm < @archive_date
	select @sql = N'alter table paytypeaudit enable trigger all'
end
--20) PayDetail Audit
if (@include_paydetailaudit = 'Y')
begin
	select @sql = N'alter table paydetailaudit disable trigger all'
	exec sp_executesql @sql
	delete from paydetailaudit with (xlock tablock) where audit_date < @archive_date
	select @sql = N'alter table paydetailaudit enable trigger all'
end
--21) Trip Audit
if (@include_tripaudit = 'Y')
begin
	select @sql = N'alter table tripaudit disable trigger all'
	exec sp_executesql @sql
	delete from tripaudit with (xlock tablock) where upd_date < @archive_date
	select @sql = N'alter table tripaudit enable trigger all'
end
--22) Order Cancel Log
if (@include_orderheader_cancel = 'Y')
begin
	select @sql = N'alter table orderheader_cancel_log disable trigger all'
	exec sp_executesql @sql
	delete from orderheader_cancel_log with (xlock tablock)  where ohc_cancelled_date < @archive_date
	select @sql = N'alter table orderheader_cancel_log enable trigger all'
end
--23) Tariff Error Log
if (@include_tarifferrorlog = 'Y')
begin
	select @sql = N'alter table tarifferrorlog disable trigger all'
	exec sp_executesql @sql
	delete from tarifferrorlog with (xlock tablock) where tel_dttm < @archive_date
	select @sql = N'alter table tarifferrorlog enable trigger all'
end
--24) TTS Errorlog
if (@include_ttserrorlog = 'Y')
begin
	select @sql = N'alter table tts_errorlog disable trigger all'
	exec sp_executesql @sql
	delete from tts_errorlog with (xlock tablock) where err_date < @archive_date
	select @sql = N'alter table tts_errorlog enable trigger all'
end
--25) Log_driverlogs
if (@include_log_driverlogs = 'Y')
begin
	select @sql = N'alter table log_driverlogs disable trigger all'
	exec sp_executesql @sql
	delete from log_driverlogs with (xlock tablock) where log_date < @archive_date
	select @sql = N'alter table log_driverlogs enable trigger all'
end

update tmw_purge_summary
set pur_status = 'FINISHED PURGE'
where pur_id = @pur_id

GO
GRANT EXECUTE ON  [dbo].[tmw_purgedata_by_pur_id] TO [public]
GO
