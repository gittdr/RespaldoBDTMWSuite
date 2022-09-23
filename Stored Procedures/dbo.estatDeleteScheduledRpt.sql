SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
exec estatDeleteScheduledRpt 3
*/
Create procedure [dbo].[estatDeleteScheduledRpt]  @rpt_sched_id int  
AS
SET NOCOUNT ON

declare @reportid varchar(250) 

select @reportid = rpt_id from estatSchedule where rpt_sched_id = @rpt_sched_id

if @reportid = 'RPTCurrentLoadStatus'  delete from estatScheduledCLSReportOptions where rpt_sched_id = @rpt_sched_id
else if @reportid = 'RPTCustomerService' delete from estatScheduledCSReportOptions where rpt_sched_id = @rpt_sched_id
else if @reportid = 'RPTOrderStatus'  delete from estatScheduledOSReportOptions where rpt_sched_id = @rpt_sched_id
else if @reportid = 'RPTCustomerServiceSummary'  delete from estatScheduledCSRptSummaryOptions where rpt_sched_id = @rpt_sched_id


DELETE FROM estatschedule  where rpt_sched_id = @rpt_sched_id

GO
GRANT EXECUTE ON  [dbo].[estatDeleteScheduledRpt] TO [public]
GO
