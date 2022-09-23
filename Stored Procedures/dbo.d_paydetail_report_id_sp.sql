SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROC	[dbo].[d_paydetail_report_id_sp] (
	@driver_id varchar(8), 
	@driver_type1 varchar(6), 
	@driver_type2 varchar(6), 
	@driver_type3 varchar(6), 
	@driver_type4 varchar(6), 
	@payment_status_array varchar(100), 
	@company varchar(6), 
	@fleet varchar(6), 
	@division varchar(6), 
	@terminal varchar(6),
	@beg_work_date datetime, 
	@end_work_date datetime, 
	@beg_pay_date datetime, 
	@end_pay_date datetime, 
	@payment_type_array varchar(8000),
	@driver_accounting_type varchar(6), 
	@beg_transfer_date datetime, 
	@end_transfer_date datetime,
	@beg_invoice_bill_date datetime, 
	@end_invoice_bill_date datetime,
	@sch_date1 datetime, 
	@sch_date2 datetime,
	@revtype1 varchar(6), 
	@revtype2 varchar(6), 
	@revtype3 varchar(6), 
	@revtype4 varchar(6),
	@excl_revtype1 char(1), 
	@excl_revtype2 char(1), 
	@excl_revtype3 char(1), 
	@excl_revtype4 char(1),
	@resourcetypeonleg char(1)
)  
AS  
set nocount on
set transaction isolation level read uncommitted 
/**
 * DESCRIPTION:
 *   Created to get driver paydetail for settlement detail report  
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * -- PTS 35274 11/2008 JSwindell RECODE:  Add Revtype1 -> 4 and excl_revtype1 -> 4
 * -- PTS 51698 05/2010 SPN - introducing subquery from temp_report_arguments instead of payment_type_array
 * PTS 48237 - DJM - 6/15/2010 - Added 'resourcetypeonleg' parameter to allow the proc to look at the asset type
 *							on the leg instead of just the Asset Master (Driver and Tractor only)
 * PTS 66651 Change select statement to be dynamic SQL to improve performance.
 *
 **/

if @payment_status_array <> 'UNK' and @payment_status_array <> '' and @payment_status_array <> 'XXX'
	begin
		CREATE TABLE #PAYMENT_STATUS (payment_status_values varchar(10) not null)
		create unique clustered index ux_ps_temp on #PAYMENT_STATUS(payment_status_values)
		insert #PAYMENT_STATUS select distinct value from dbo.CSVStringsToTable_fn(@payment_status_array) order by value
	end 

-- Create temporary table    
CREATE TABLE #driver_paydetail_temp  (
asgn_type varchar(6) Null, 
asgn_id varchar(8) Null, 
pyd_payto varchar(12) Null, 
pyt_itemcode varchar(6) Null, 
mov_number int Null, 
pyd_description varchar(75) Null, 
pyd_quantity float Null, 
pyd_rate money Null, 
pyd_amount money Null, 
pyd_glnum varchar(32) Null, 
pyd_pretax char(1) Null, 
pyd_status varchar(6) Null, 
pyd_refnumtype varchar(6) Null, 
pyd_refnum varchar(30) Null, 
pyh_payperiod datetime Null, 
pyd_workperiod datetime Null, 
lgh_startcity int Null, 
lgh_endcity int Null, 
driver_name varchar(64) Null,
start_city varchar(30) Null, 
end_city varchar(30) Null,
paydetail_pyt_itemcode varchar(6) Null,
ivh_billdate datetime Null,
ivh_invoicenumber varchar(12) Null,
ord_hdrnumber int null,
-- PTS 25416 -- BL (start)
--pyh_number int null)
-- PTS 25416 -- BL (end)
-- PTS 35274 11/2008 JSwindell RECODE<<start>>
pyh_number int null,
ord_revtype1 varchar(6) NULL,
ord_revtype2 varchar(6) NULL,
ord_revtype3 varchar(6) NULL,
ord_revtype4 varchar(6) NULL,
-- PTS 35274 11/2008 JSwindell RECODE<<end>>
lgh_number	int	null)

declare @sql nvarchar(4000)
select @sql = N'SELECT p.asgn_type,p.asgn_id,p.pyd_payto,p.pyt_itemcode,p.mov_number,p.pyd_description,'
select @sql = @sql + N'p.pyd_quantity,p.pyd_rate,p.pyd_amount,p.pyd_glnum,p.pyd_pretax,p.pyd_status,'
select @sql = @sql + N'p.pyd_refnumtype,p.pyd_refnum,p.pyh_payperiod,p.pyd_workperiod,p.lgh_startcity,' 
select @sql = @sql + N'p.lgh_endcity,mpp.mpp_lastname + '',  '' + mpp.mpp_firstname name,sc.cty_nmstct,ec.cty_nmstct,p.pyt_itemcode, NULL, NULL, p.ord_hdrnumber,'
select @sql = @sql + N'p.pyh_number, oh.ord_revtype1,oh.ord_revtype2,oh.ord_revtype3,oh.ord_revtype4,p.lgh_number '

 
select @sql = @sql + N'FROM paydetail p '
select @sql = @sql + N'INNER JOIN manpowerprofile mpp ON p.asgn_id = mpp.mpp_id ' 
select @sql = @sql + N'LEFT JOIN city sc ON p.lgh_startcity = sc.cty_code '	    
select @sql = @sql + N'LEFT JOIN city ec ON  ec.cty_code = p.lgh_endcity '
select @sql = @sql + N'LEFT JOIN orderheader oh ON  p.ord_hdrnumber  = oh.ord_hdrnumber ' 
 
if @payment_type_array <> 'UNK' and @payment_type_array <> '' and @payment_type_array <> 'XXX'
select @sql = @sql + N'INNER JOIN temp_report_arguments tra ON p.pyt_itemcode = tra.temp_report_argument_value '

if @payment_status_array <> 'UNK' and @payment_status_array <> '' and @payment_status_array <> 'XXX'
	select @sql = @sql + N'INNER JOIN #PAYMENT_STATUS ps ON p.pyd_status = ps.payment_status_values '       

--begin where clause
select @sql = @sql + N'WHERE (p.pyd_transdate between ''' + convert(varchar(20),@beg_transfer_date) + ''' and ''' + convert(varchar(20),@end_transfer_date) + ''' '
select @sql = @sql + N'OR p.pyd_transdate is null) '
select @sql = @sql + N'AND p.pyh_payperiod between ''' + convert(varchar(20),@beg_pay_date) + ''' and ''' + convert(varchar(20),@end_pay_date) + ''' '
select @sql = @sql + N'AND (p.pyd_workperiod between ''' + convert(varchar(20),@beg_work_date) + ''' and ''' + convert(varchar(20),@end_work_date) + ''' '
select @sql = @sql + N'OR p.pyd_workperiod is null) '

if @driver_type1 <> 'UNK'
	select @sql = @sql + N'AND mpp.mpp_type1 = ''' + @driver_type1 + ''' '
if @driver_type2 <> 'UNK'
	select @sql = @sql + N'AND mpp.mpp_type2 = ''' + @driver_type2 + ''' '
if @driver_type3 <> 'UNK'
	select @sql = @sql + N'AND mpp.mpp_type3 = ''' + @driver_type3 + ''' '
if @driver_type4 <> 'UNK'
	select @sql = @sql + N'AND mpp.mpp_type4 = ''' + @driver_type4 + ''' '

if @payment_type_array <> 'UNK' and @payment_type_array <> '' and @payment_type_array <> 'XXX'
begin
	select @sql = @sql + N'AND tra.current_session_id = ' + convert(varchar(10),@@SPID) + ' '
	select @sql = @sql + N'AND tra.temp_report_name = ''PAYDETAIL_REPORT'' '
	select @sql = @sql + N'AND tra.temp_report_argument_name = ''PAYTYPE'' '
	select @sql = @sql + N'and temp_report_argument_value IS NOT NULL '
end

if @driver_id = 'UNKNOWN'
	select @sql = @sql + N'AND p.asgn_type = ''DRV'' '
else
	select @sql = @sql + N'AND p.asgn_type = ''DRV'' and p.asgn_id = ''' + @driver_id + ''' '

if @company <> 'UNK'
	select @sql = @sql + N'AND mpp.mpp_company = ''' + @company + ''' '     
           
if @fleet <> 'UNK'
	select @sql = @sql + N'AND mpp.mpp_fleet = ''' + @fleet + ''' '
 
if @division <> 'UNK'
	select @sql = @sql + N'AND mpp.mpp_division = ''' + @division + ''' '

if @driver_accounting_type <> 'X'
	select @sql = @sql + N'AND mpp.mpp_actg_type = ''' + @driver_accounting_type + ''' '

if @terminal <> 'UNK'  
	select @sql = @sql + N'and mpp.mpp_terminal = ''' + @terminal  + ''' ' 

--	select @sql
--	return

insert into #driver_paydetail_temp
exec sp_executesql @sql

declare @status_qty int
select @status_qty = count(*) from #PAYMENT_STATUS where payment_status_values in ('XFR','COL')
If @status_qty > 0

BEGIN

	select @sql = N'SELECT p.asgn_type,p.asgn_id,p.pyd_payto,p.pyt_itemcode,p.mov_number,p.pyd_description'
	select @sql = @sql + N',p.pyd_quantity,p.pyd_rate,p.pyd_amount,p.pyd_glnum,p.pyd_pretax,p.pyd_status,'
	select @sql = @sql + N'p.pyd_refnumtype,p.pyd_refnum,p.pyh_payperiod,p.pyd_workperiod,p.lgh_startcity,' 
	select @sql = @sql + N'p.lgh_endcity,mpp.mpp_lastname + '',  '' + mpp.mpp_firstname name,sc.cty_nmstct,ec.cty_nmstct,p.pyt_itemcode,NULL,NULL,p.ord_hdrnumber,'
	select @sql = @sql + N'p.pyh_number,oh.ord_revtype1,oh.ord_revtype2,oh.ord_revtype3,oh.ord_revtype4,p.lgh_number '
	 
	select @sql = @sql + N'FROM payheader ph inner join paydetail p on ph.pyh_pyhnumber = p.pyh_number ' 
	select @sql = @sql + N'INNER JOIN manpowerprofile mpp ON p.asgn_id = mpp.mpp_id '  
	select @sql = @sql + N'LEFT JOIN city ec ON  ec.cty_code = p.lgh_endcity '
	select @sql = @sql + N'LEFT JOIN city sc ON  sc.cty_code = p.lgh_startcity '
	select @sql = @sql + N'LEFT JOIN orderheader oh ON  p.ord_hdrnumber  = oh.ord_hdrnumber ' 
	select @sql = @sql + N'LEFT JOIN legheader l ON p.lgh_number = l.lgh_number '  

	if @payment_type_array <> 'UNK' and @payment_type_array <> '' and @payment_type_array <> 'XXX'
	select @sql = @sql + N'INNER JOIN temp_report_arguments tra ON p.pyt_itemcode = tra.temp_report_argument_value '

	--we already know that we were either passed XFR or COL or both for this branch
	select @sql = @sql + N'INNER JOIN #PAYMENT_STATUS ps ON p.pyd_status = ps.payment_status_values and ph.pyh_paystatus = ps.payment_status_values '       

	--begin where clause
	select @sql = @sql + N'WHERE (p.pyd_transdate between ''' + convert(varchar(20),@beg_transfer_date) + ''' and ''' + convert(varchar(20),@end_transfer_date) + ''' '
	select @sql = @sql + N'OR p.pyd_transdate is null) '
	select @sql = @sql + N'AND p.pyh_payperiod between ''' + convert(varchar(20),@beg_pay_date) + ''' and ''' + convert(varchar(20),@end_pay_date) + ''' '
	select @sql = @sql + N'AND (p.pyd_workperiod between ''' + convert(varchar(20),@beg_work_date) + ''' and ''' + convert(varchar(20),@end_work_date) + ''' '
	select @sql = @sql + N'OR p.pyd_workperiod is null) '

	if @driver_type1 <> 'UNK'
		select @sql = @sql + N'AND mpp.mpp_type1 = ''' + @driver_type1 + ''' '
	if @driver_type2 <> 'UNK'
		select @sql = @sql + N'AND mpp.mpp_type2 = ''' + @driver_type2 + ''' '
	if @driver_type3 <> 'UNK'
		select @sql = @sql + N'AND mpp.mpp_type3 = ''' + @driver_type3 + ''' '
	if @driver_type4 <> 'UNK'
		select @sql = @sql + N'AND mpp.mpp_type4 = ''' + @driver_type4 + ''' '

	if @payment_type_array <> 'UNK' and @payment_type_array <> '' and @payment_type_array <> 'XXX'
	begin
		select @sql = @sql + N'AND tra.current_session_id = ' + convert(varchar(10),@@SPID) + ' '
		select @sql = @sql + N'AND tra.temp_report_name = ''PAYDETAIL_REPORT'' '
		select @sql = @sql + N'AND tra.temp_report_argument_name = ''PAYTYPE'' '
		select @sql = @sql + N'and temp_report_argument_value IS NOT NULL '
	end

	if @driver_id = 'UNKNOWN'
		select @sql = @sql + N'AND p.asgn_type = ''DRV'' '
	else
		select @sql = @sql + N'AND p.asgn_type = ''DRV'' and p.asgn_id = ''' + @driver_id + ''' '
		
	if @company <> 'UNK'
		select @sql = @sql + N'AND mpp.mpp_company = ''' + @company + ''' '     
	           
	if @fleet <> 'UNK'
		select @sql = @sql + N'AND mpp.mpp_fleet = ''' + @fleet + ''' '
	 
	if @division <> 'UNK'
		select @sql = @sql + N'AND mpp.mpp_division = ''' + @division + ''' '

	if @driver_accounting_type <> 'X'
		select @sql = @sql + N'AND mpp.mpp_actg_type = ''' + @driver_accounting_type + ''' '

	if @terminal <> 'UNK'  
	select @sql = @sql + N'and mpp.mpp_terminal = ''' + @terminal  + ''' ' 


	select @sql = @sql + N'and p.pyh_number not in (select pyh_number from #driver_paydetail_temp)'

	INSERT INTO #driver_paydetail_temp
	exec sp_executesql @sql
END

update 	#driver_paydetail_temp
set 	ivh_billdate = innertbl.max_ivh_billdate,
		ivh_invoicenumber = innertbl.max_ivh_invoicenumber
from	#driver_paydetail_temp temp inner join (
			select ih.ord_hdrnumber, max(ih.ivh_billdate) as max_ivh_billdate, max(ih.ivh_invoicenumber) as max_ivh_invoicenumber
			from #driver_paydetail_temp t inner join invoiceheader ih on t.ord_hdrnumber = ih.ord_hdrnumber
			group by ih.ord_hdrnumber
		) as innertbl on temp.ord_hdrnumber = innertbl.ord_hdrnumber where temp.ord_hdrnumber > 0

-- See if user entered in an Invoice bill_date range
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR 
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59') 
	delete from #driver_paydetail_temp where ivh_billdate between @beg_invoice_bill_date and @end_invoice_bill_date

--LOR	PTS# 32588
if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR 
      @sch_date2 < convert(datetime, '2049-12-31 23:59') 
	Delete from #driver_paydetail_temp  
	where #driver_paydetail_temp.ord_hdrnumber > 0 and 
		#driver_paydetail_temp.ord_hdrnumber in (select ord_hdrnumber 
						from stops
						where stp_sequence = 1 and
							(stp_schdtearliest > @sch_date2  or 
							stp_schdtearliest < @sch_date1))	

	IF isNull(@revtype1,'UNK') <> 'UNK'
		Begin
			If @excl_revtype1 = 'Y'
				DELETE FROM #driver_paydetail_temp WHERE isNull(#driver_paydetail_temp.ord_revtype1,'UNK') = @revtype1
			Else
				DELETE FROM #driver_paydetail_temp WHERE isNull(#driver_paydetail_temp.ord_revtype1,'UNK') <> @revtype1
		End
	IF isNull(@revtype2,'UNK') <> 'UNK'
		Begin
			If @excl_revtype2 = 'Y'
				DELETE FROM #driver_paydetail_temp WHERE isNull(#driver_paydetail_temp.ord_revtype2,'UNK') = @revtype2
			Else
				DELETE FROM #driver_paydetail_temp WHERE isNull(#driver_paydetail_temp.ord_revtype2,'UNK') <> @revtype2
		End
	IF isNull(@revtype3,'UNK') <> 'UNK'
		Begin
			If @excl_revtype3 = 'Y'
				DELETE FROM #driver_paydetail_temp WHERE isNull(#driver_paydetail_temp.ord_revtype3,'UNK') = @revtype3
			Else
				DELETE FROM #driver_paydetail_temp WHERE isNull(#driver_paydetail_temp.ord_revtype3,'UNK') <> @revtype3
		End
	IF isNull(@revtype4,'UNK') <> 'UNK'
		Begin
			If @excl_revtype4 = 'Y'
				DELETE FROM #driver_paydetail_temp WHERE isNull(#driver_paydetail_temp.ord_revtype4,'UNK') = @revtype4
			Else
				DELETE FROM #driver_paydetail_temp WHERE isNull(#driver_paydetail_temp.ord_revtype4,'UNK') <> @revtype4
		End


SELECT 	asgn_type ,
	asgn_id ,
	pyd_payto ,
	pyt_itemcode,
	mov_number ,
	pyd_description ,
	pyd_quantity ,
	pyd_rate ,
	pyd_amount ,
	pyd_glnum ,
	pyd_pretax ,
	pyd_status ,
	pyd_refnumtype ,
	pyd_refnum ,
	pyh_payperiod ,
	pyd_workperiod ,
	lgh_startcity ,
	lgh_endcity ,
	driver_name ,
	start_city ,
	end_city ,
	paydetail_pyt_itemcode ,
	ivh_billdate ,
	ivh_invoicenumber 
 from #driver_paydetail_temp  
DROP TABLE #driver_paydetail_temp  
  
GO
GRANT EXECUTE ON  [dbo].[d_paydetail_report_id_sp] TO [public]
GO
