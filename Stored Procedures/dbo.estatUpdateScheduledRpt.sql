SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
Create 3 new scheduled reports:
------ previoius month, once a week, on Tuesday:
exec estatUpdateScheduledRpt 'xxxxxx', 'RPTCurrentLoadStatus',  0, 4, 1, 'Kxxxxxx@TMWSystems.com', 'CLS REPORT', 1, '0010010', 3, '7:00', null, '11/5/08 13:00'
----- previoius week, 15TH day of the month:
exec estatUpdateScheduledRpt 'xxxxxx', 'RPTCustomerService', 0, 3, 1, 'Kxxxxxx@TMWSystems.com', 'CS Report', 2, '0000000', 15, '5:00', null, '11/5/08 13:00'
----- previoius week, every day, every hour from 8:00 AM to 4:00 PM 
exec estatUpdateScheduledRpt 'xxxxxx', 'RPTOrderStatus', 0, 2, 1, 'Kxxxxxx@TMWSystems.com', 'OS Report', 1, '1111111', 0, '8:00', '18:00', '11/5/08 13:00'
----- Change the stoptime on the 3rd one:
exec estatUpdateScheduledRpt 'xxxxxx', 'RPTOrderStatus', 3, 2, 1, 'Kxxxxxx@TMWSystems.com','OS Report Update',  1, '1111111', 0, '8:00', '18:00', '11/6/08 13:00'
*/
Create procedure [dbo].[estatUpdateScheduledRpt]  
		@login varchar(132),    
		@rpt_id varchar(250), 
-- @rpt_sched_id: if zero, then proc creates a new scheduled report, 
-- otherwise it updates the scheduled report  having this id: 
		@rpt_sched_id int,  
        @rpt_period int, 
		@rpt_active int, 		
		@rpt_email text, 
		@rpt_email_subject text, 
		@rpt_freq int, 
		@rpt_weekday char(7),
		@rpt_nthday int,
		@rpt_start_time varchar(5), 
		@rpt_stop_time varchar(5),
        @nxt_runtime datetime		
AS
SET NOCOUNT ON

declare @xx Integer 

If @rpt_sched_id <> 0 -- update existing scheduled report 
begin
	update estatschedule set 
                login = @login, rpt_id = @rpt_id, rpt_period = @rpt_period,
		rpt_active = @rpt_active, 
		rpt_email = @rpt_email, rpt_freq = @rpt_freq, rpt_weekday = @rpt_weekday,
        rpt_email_subject = @rpt_email_subject,
		rpt_nthday = @rpt_nthday, rpt_start_time = @rpt_start_time, rpt_stop_time = @rpt_stop_time, 
        rpt_nextrun = @nxt_runtime,  
        rpt_sched_lastupdated = getdate()
        
 	where rpt_sched_id = @rpt_sched_id and login = @login
    select @xx = @rpt_sched_id
end 
else  -- create new scheduled report
begin  
	insert estatschedule select
              [login] = @login, rpt_id = @rpt_id, rpt_period = @rpt_period,
		rpt_active = @rpt_active, 				
		rpt_email = @rpt_email, rpt_email_subject = @rpt_email_subject, 
		rpt_freq = @rpt_freq, rpt_weekday = @rpt_weekday,
		rpt_nthday = @rpt_nthday, rpt_start_time = @rpt_start_time, rpt_stop_time = @rpt_stop_time, 
		rpt_lastrun = null, rpt_nextrun = @nxt_runtime, rpt_sched_lastupdated = getdate(), rpt_last_run_successful = null,
		rpt_last_run_message = null
		select @xx = scope_identity() --pickup that identify value ie the new scheduleid

		if @rpt_id = 'RPTCurrentLoadStatus'  
		begin
			Insert into estatScheduledCLSReportOptions (rpt_sched_id,UserName,Clientid,
			Ordstatus, SortbyMove, showtrc, showtrl,showrefnum, trreq, billableeventsonly) 
			values(@xx, @login, @login, 'ALL', 0,0,0,0, 'orderby', 0)
		end
		else
		begin
			if @rpt_id = 'RPTCustomerService' 
			begin
				Insert into estatScheduledCSReportOptions (rpt_sched_id,UserName,Clientid, 
				companytype, reportlevel, tolerancelate, toleranceearly, tolerancelateunit, toleranceearlyunit) 
				values(@xx, @login, @login, 'S', 'N', '30', '30', 'minutes', 'minutes')
			end
			else
			begin  -- ktk
				if @rpt_id = 'RPTCustomerServiceSummary' 
				begin
					Insert into estatScheduledCSRptSummaryOptions (rpt_sched_id,UserName,Clientid, 
					companytype, reportlevel, tolerancelate, toleranceearly, tolerancelateunit, toleranceearlyunit) 
					values(@xx, @login, @login, 'S', 'N', '30', '30', 'minutes', 'minutes')
				end -- ktk
                else
                begin
					if @rpt_id = 'RPTOrderStatus'  
					begin
						Insert into estatScheduledOSReportOptions (rpt_sched_id, UserName, Clientid, 
						Cancelled, NewOrders, Dispatched, Inprogress, Completed, Invoiced, transferred, DonotInvoice, 
						reftype, shipper, consignee, trreq, excel) 
						values(@xx, @login, @login, 0,0,0,0,0,0,0,0, '', 'ALL', 'ALL', 'orderby', 'N')
					end
				end
			end

end







end

select @xx scheduleid

GO
GRANT EXECUTE ON  [dbo].[estatUpdateScheduledRpt] TO [public]
GO
