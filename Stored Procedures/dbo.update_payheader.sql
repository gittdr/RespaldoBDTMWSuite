SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- JET - PTS 4845 1/5/99 adjust totals on the pay header from the pay details

CREATE PROCEDURE [dbo].[update_payheader] (@payheader int)
AS 
set nocount on --38174 JD ported for Mindy Curnutt ISI 7/27/07
-- jet - PTS31296 - 1/11/2006, removed the if check because the SQL had to do the same work twice to do the update
--      also added pyd_refnumtype = 'EXPCHK' to the where clause to make it use the index on the paydetail
--		table to find matching rows in paydetail and cdexpresscheck table.
--		the following are stat changes based on the new code
-- OLD values: SQL:BatchCompleted	exec update_payheader 62379;	Microsoft SQL Server Management Studio - Query		tmwstaff	438	155612	0	1470	2504	76	2006-01-12 09:12:47.863	
-- NEW values: SQL:BatchCompleted	exec update_payheader 62379;	Microsoft SQL Server Management Studio - Query		tmwstaff	0	2861	0	466	2504	76	2006-01-12 09:17:26.220	
----vjh 30642 problems found running with pyh=0, exclude paydetails that do not have a payheader from the update
--28923 JD
--PTS 54596 Changed temp table to be a table variable to avoid contention in tempdb for CEVA
--if exists (select * from paydetail ,cdexpresscheck where pyh_number = @payheader and pyd_status <> 'HLD' and 
--			pyd_refnumtype = 'EXPCHK' and pyd_refnum = ceh_customerid + ' ' + ceh_sequencenumber  and ceh_registered = 'R' and pyh_number <> 0)
If exists (select * from generalinfo where gi_name = 'UncashedExpChkStaysOnHold' and gi_string1 = 'Y')
BEGIN
	update paydetail set pyh_payperiod = '20491231 23:59:59',pyh_number = 0 , pyd_status = 'HLD'
	 from  cdexpresscheck 
	where pyd_refnumtype = 'EXPCHK' and pyd_refnum = ceh_customerid + ' ' + ceh_sequencenumber and pyd_status <> 'HLD' and pyh_number = @payheader
	and ceh_registered = 'R'  and pyh_number <> 0
END
-- end 28923 JD

--38174 JD ported for Mindy Curnutt ISI 7/27/07. Creation of temp table added by ISI
	-- sum the total compensation, deductions and reimbursements from the pay details for the pay header  
--	LOR	PTS# 39898	add null to table definition
	
/*
BEGIN PTS 54596
--create table #paydetail (pyd_number int not null, pyd_pretax char(1) null, pyd_status varchar(6) null, pyd_amount money null, pyd_minus int null)
*/
declare @paydetail table (pyd_number int not null, pyd_pretax char(1) null, pyd_status varchar(6) null, pyd_amount money null, pyd_minus int null)
/*
END PTS 54596
*/

--BEGIN PTS 57444 SPN
IF IsNull(@payheader,0) = 0
   RETURN
--END PTS 57444 SPN

	insert @paydetail
	select pyh_number, pyd_pretax, pyd_status, pyd_amount, pyd_minus from paydetail
	where pyh_number = @payheader  
	
	declare @sumpyd_amount money, @sumpyd_totaldeduct money, @sumpyd_totalreimbrs money
	set @sumpyd_amount = 0
	set @sumpyd_totaldeduct = 0
	set @sumpyd_totalreimbrs = 0
	 
	select @sumpyd_amount = sum(IsNull(pyd_amount,0)) from @paydetail where pyd_pretax = 'Y' and pyd_status <> 'HLD'
	select @sumpyd_totaldeduct = sum(IsNull(pyd_amount,0)) from @paydetail where pyd_pretax = 'N' and pyd_status <> 'HLD' and pyd_minus = -1
	select @sumpyd_totalreimbrs = sum(IsNull(pyd_amount,0)) from @paydetail where pyd_pretax = 'N' and pyd_status <> 'HLD' and pyd_minus = 1
	
	UPDATE payheader   
	   SET pyh_totalcomp = isnull(@sumpyd_amount,0),
		   pyh_totaldeduct = isnull(@sumpyd_totaldeduct,0),
	       pyh_totalreimbrs = isnull(@sumpyd_totalreimbrs,0)  
		WHERE pyh_pyhnumber = @payheader  
-- end 38174 JD for Mindy Curnutt ISI
GO
GRANT EXECUTE ON  [dbo].[update_payheader] TO [public]
GO
