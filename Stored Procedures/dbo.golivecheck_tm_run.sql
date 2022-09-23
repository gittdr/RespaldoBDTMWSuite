SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROC [dbo].[golivecheck_tm_run]


AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


--declare @glc_rundate datetime
--set @glc_rundate = GetDate()


	
declare @glc_cnt_tm_active_trc int
declare @glc_cnt_tm_active_trc_no_mct int
declare @glc_cnt_tm_non_error_msg int
declare @glc_cnt_tm_error_msg int
declare @glc_cnt_tm_users int
declare @glc_cnt_tm_active_trc_no_grp int
declare @glc_cnt_tm_ret_macro int 
declare @glc_cnt_tm_active_macro int
declare @glc_pct_tm_cir_service_macros float
declare @glc_cnt_tm_admin_inbox int
declare @glc_pct_tm_admin_unread float 



select @glc_cnt_tm_active_trc = count(*) from tblTrucks where Retired = 0

select @glc_cnt_tm_active_trc_no_mct = count(*) from tblTrucks where Retired = 0 and DefaultCabUnit is null

select @glc_cnt_tm_non_error_msg = count(*) from tblmessages m inner join tblrs f on m.folder = convert(int,f.text) where f.keycode = 'history' and not exists (select * from tblmsgproperties p where p.msgsn = m.sn and p.propsn = 6)

select @glc_cnt_tm_error_msg = count(*)from tblmessages m inner join tblrs f on m.folder = convert(int,f.text) where f.keycode = 'history' and exists (select * from tblmsgproperties p where p.msgsn = m.sn and p.propsn = 6)

select @glc_cnt_tm_users = count(*) from tbllogin

select @glc_cnt_tm_active_trc_no_grp = count(*) from tbltrucks where Retired = 0 and isnull(tbltrucks.CurrentDispatcher, 0) = 0

select @glc_cnt_tm_ret_macro = count(*) from tblforms f where f.direction = 0 and f.status = 'Current' and exists (select * from tblselectedmobilecomm s where s.formsn = f.sn)

select @glc_cnt_tm_active_macro = count(*) from tblforms f where f.status = 'Current' and exists (select * from tblselectedmobilecomm m where m.formsn = f.sn)

declare @cnt_cir_service_macros float
declare @cnt_err_cir_service_macros float
select @cnt_cir_service_macros = count(*) from tblmessages m inner join tblrs f on m.folder = convert(int,f.text) where f.keycode = 'history' and exists (select * from tblmsgproperties p inner join tblforms f on p.propsn = 2 and p.Value = convert(varchar(20), f.sn) inner join tblselectedviews s on f.sn = s.formsn inner join tblviews v on s.viewnumber = v.sn where v.viewcode in ('UpdMove', 'BeginMove', 'AcceptLoad') and p.msgsn = m.sn)
select @cnt_err_cir_service_macros = count(*) from tblmessages m inner join tblrs f on m.folder = convert(int,f.text) where f.keycode = 'history'  and exists (select * from tblmsgproperties p inner join tblforms f on p.propsn = 2 and p.Value = convert(varchar(20), f.sn) inner join tblselectedviews s on f.sn = s.formsn inner join tblviews v on s.viewnumber = v.sn where v.viewcode in ('UpdMove', 'BeginMove', 'AcceptLoad') and p.msgsn = m.sn) and exists (select * from tblmsgproperties p2 where p2.msgsn = m.sn and p2.propsn = 6)
if @cnt_cir_service_macros = 0
begin
set @glc_pct_tm_cir_service_macros = 0
end
else
set @glc_pct_tm_cir_service_macros = @cnt_err_cir_service_macros / @cnt_cir_service_macros


select @glc_cnt_tm_admin_inbox = count(*) from tblmessages inner join tblserver on tblserver.inbox = tblmessages.folder where tblserver.servercode = 'A'

declare @cnt_admin_inbox float
declare @cnt_admin_inbox_unread float
select @cnt_admin_inbox = count(*) from tblmessages inner join tblserver on tblserver.inbox = tblmessages.folder where tblserver.servercode = 'A'
select @cnt_admin_inbox_unread = count(*) from tblmessages inner join tblserver on tblserver.inbox = tblmessages.folder where tblserver.servercode = 'A' and tblmessages.dtread is null
if @cnt_admin_inbox = 0
begin
set @glc_pct_tm_admin_unread = 0
end
else
set @glc_pct_tm_admin_unread =  @cnt_admin_inbox_unread / @cnt_admin_inbox


INSERT INTO golivecheck_totalmail 
		(glc_rundate, glc_cnt_tm_active_trc, glc_cnt_tm_active_trc_no_mct, glc_cnt_tm_non_error_msg,
		 glc_cnt_tm_error_msg, glc_cnt_tm_users, glc_cnt_tm_active_trc_no_grp, glc_cnt_tm_ret_macro,
		 glc_cnt_tm_active_macro, glc_pct_tm_cir_service_macros, glc_cnt_tm_admin_inbox, glc_pct_tm_admin_unread)
VALUES (null, @glc_cnt_tm_active_trc, @glc_cnt_tm_active_trc_no_mct, @glc_cnt_tm_non_error_msg,
		@glc_cnt_tm_error_msg, @glc_cnt_tm_users, @glc_cnt_tm_active_trc_no_grp, @glc_cnt_tm_ret_macro,
		@glc_cnt_tm_active_macro, @glc_pct_tm_cir_service_macros, @glc_cnt_tm_admin_inbox, @glc_pct_tm_admin_unread)





GO
GRANT EXECUTE ON  [dbo].[golivecheck_tm_run] TO [public]
GO
