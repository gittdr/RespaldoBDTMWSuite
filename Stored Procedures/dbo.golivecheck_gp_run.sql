SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROC [dbo].[golivecheck_gp_run]


AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


declare @glc_rundate datetime
set @glc_rundate = GetDate()

--- GP SETUP VARIABLES ----
declare @glc_cnt_gp_cust_invalid_class int 
declare @glc_cnt_gp_vend_invalid_class int 
declare @glc_cnt_gp_gl_acct_structure int 
declare @glc_cnt_gp_bal_acct_sheets int
declare @glc_cnt_gp_income_stmnt_accts int 
declare @glc_cnt_gp_acct_yr_setup int 
declare @glc_cnt_gp_cust_no_ar_acct int 
declare @glc_cnt_gp_vend_no_ap_acct int 
declare @glc_cnt_gp_ten99_vend int
declare @glc_gp_ztrans_setup varchar(1) 
declare @glc_cnt_gp_cust_classes int
declare @glc_gp_cust_class_defined varchar(1) 
declare @glc_gp_vend_class_defined varchar(1)
declare @glc_cnt_act_employee_payroll int 
declare @glc_cnt_paycode_asgn_employee int 
declare @glc_cnt_dedcode_asgn_employee int 
declare @glc_cnt_fedtax_emp_recs int 
declare @glc_cnt_act_statetax_emp_recs int 
declare @glc_cnt_act_localtax_emp_recs int 
declare @glc_cnt_act_dirdep_emp_recs int 
declare @glc_cnt_act_dirdep_emp_accts int 
declare @glc_cnt_act_dirdep_recs_prenote int 
declare @glc_gp_payroll_dirdep_setup varchar(1) 
declare @glc_cnt_eft_vend_recs int 
declare @glc_gp_eft_vend_setup varchar(1) 


--- GP TRANSACTIONS VARIABLES ----
declare @glc_cnt_post_gl_entries int
declare @glc_cnt_unpost_gl_entries int
declare @glc_cnt_post_ap_invoices int
declare @glc_cnt_unpost_ap_invoices int
declare @glc_cnt_post_ap_check_credit int
declare @glc_cnt_payroll_checks_dirdep int
declare @glc_cnt_post_ar_invoices int
declare @glc_cnt_unpost_ar_invoices int
declare @glc_cnt_check_credit_applied int



------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--- GP SETUP ----
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--Number of customers with a blank or invalid class
select @glc_cnt_gp_cust_invalid_class = count(*) from rm00101 where custclas not in (select classid from rm00201)

--Number of vendors with a blank or invalid class
select @glc_cnt_gp_vend_invalid_class = count(*) from pm00200 where vndclsid not in (select vndclsid from pm00100)

--GL Segments Defined
select @glc_cnt_gp_gl_acct_structure = count(*) from sy00300

--Number of Balance Sheet Accounts
select @glc_cnt_gp_bal_acct_sheets = count(*) from gl00100 where pstngtyp = 0

--Number of Income Statement Accounts
select @glc_cnt_gp_income_stmnt_accts = count(*) from gl00100 where pstngtyp = 1

--Accounting year setup
select @glc_cnt_gp_acct_yr_setup = count(*) from sy40101

--Number of customers without AR account 
select @glc_cnt_gp_cust_no_ar_acct = count(*) from rm00101 where rmaracc = 0

--Number of vendors without AP account
select @glc_cnt_gp_vend_no_ap_acct = count(*) from pm00200 where pmapindx = 0

--Number of 1099 Vendors
select @glc_cnt_gp_ten99_vend = count(*) from pm00200 where ten99type <> 1

--ZTRANSFER CheckBook set up?
select @glc_gp_ztrans_setup = case when (select count(*) from cm00100 where chekbkid = 'ZTRANSFER') > 0 then 'Y' else 'N' end

--Number of Customer Classes
select @glc_cnt_gp_cust_classes = count(*) from rm00201

--Default customer class defined
select @glc_gp_cust_class_defined = case when (select count(*) as DefaultClass from rm00201 where defltcls = 1) > 0 then 'Y' else 'N' end

--Default vendor class defined
select @glc_gp_vend_class_defined = case when (select count(*) from pm00100 where defltcls = 1) > 0 then 'Y' else 'N' end

--Number of Active Employees in Payroll
select @glc_cnt_act_employee_payroll = count(*) from upr00100 where inactive = 0

--Number of Pay Codes assigned to Employees
select @glc_cnt_paycode_asgn_employee = count(*) from upr00400 where inactive = 0

--Number of Deduction Codes assigned to Employees
select @glc_cnt_dedcode_asgn_employee = count(*) from upr00500 where inactive = 1

--Number of Federal Tax Employee Records
select @glc_cnt_fedtax_emp_recs = count(*) from upr00300

--Number of Active State Tax Employee Records
select @glc_cnt_act_statetax_emp_recs = count(*) from upr00700 where inactive = 0

--Number of Active Local Tax Employee Records
select @glc_cnt_act_localtax_emp_recs = count(*) from upr00800 where inactive = 0

--Number of Active Direct Deposit Employee Records
select @glc_cnt_act_dirdep_emp_recs = count(*) from dd00100 where inactive = 0

--Active Direct Deposit Employee Accounts 
select @glc_cnt_act_dirdep_emp_accts = count(*) from dd00200 where inactive = 0

--Active direct deposit records set to Prenote 
select @glc_cnt_act_dirdep_recs_prenote = count(*) from dd00200 where inactive = 0 and ddpre = 1

-- Payroll Direct Deposit Setup
select @glc_gp_payroll_dirdep_setup = case when (select count(*) from dd40100) > 0 then 'Y' else 'N' end

-- EFT Vendor Records
IF EXISTS (select * from sysobjects where xtype = 'U' and name = 'me27606')
BEGIN
select @glc_cnt_eft_vend_recs = count(*) from me27606
END
ELSE
set @glc_cnt_eft_vend_recs = 0


-- EFT Vendor Setup
IF EXISTS (select * from sysobjects where xtype = 'U' and name = 'me27605')
BEGIN
select @glc_gp_eft_vend_setup = case when (select count(*) from me27605) > 0 then 'Y' else 'N' end
END
ELSE
set @glc_gp_eft_vend_setup = 'N'



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--- GP TRANSACTIONS ----
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--Number of posted GL entries 
select @glc_cnt_post_gl_entries = count(distinct jrnentry) from gl20000

--Number of unposted GL entries 
select @glc_cnt_unpost_gl_entries = count(distinct jrnentry) from gl10000

--Number of Posted AP Invoices
select @glc_cnt_post_ap_invoices = count(*) from pm20000 where doctype = 1

--Number of Unposted AP Invoices
select @glc_cnt_unpost_ap_invoices = count(distinct docnumbr) from pm10000 where doctype = 1

--Number of Posted AP Checks and Credits
select @glc_cnt_post_ap_check_credit = count(distinct apfrdcnm) from pm30300 

--Payroll Checks and Direct Deposits
select @glc_cnt_payroll_checks_dirdep = count(*) from upr30100

-- Number of Posted AR Invoices
select @glc_cnt_post_ar_invoices = count(*) from rm20101 where rmdtypal = 1

-- Number of unposted AR Invoices 
select @glc_cnt_unpost_ar_invoices = count(distinct docnumbr) from rm10301 where rmdtypal = 1

-- Number of Checks and Credits applied to invoices
select @glc_cnt_check_credit_applied = count(distinct apfrdcnm) from rm20201


INSERT INTO golivecheck_greatplains 
			 (glc_rundate, glc_cnt_gp_cust_invalid_class, glc_cnt_gp_vend_invalid_class, glc_cnt_gp_gl_acct_structure, glc_cnt_gp_bal_acct_sheets,
				glc_cnt_gp_income_stmnt_accts, glc_cnt_gp_acct_yr_setup, glc_cnt_gp_cust_no_ar_acct, glc_cnt_gp_vend_no_ap_acct, glc_cnt_gp_ten99_vend,
				glc_gp_ztrans_setup, glc_cnt_gp_cust_classes, glc_gp_cust_class_defined, glc_gp_vend_class_defined, glc_cnt_act_employee_payroll,
				glc_cnt_paycode_asgn_employee, glc_cnt_dedcode_asgn_employee, glc_cnt_fedtax_emp_recs, glc_cnt_act_statetax_emp_recs, glc_cnt_act_localtax_emp_recs,
				glc_cnt_act_dirdep_emp_recs, glc_cnt_act_dirdep_emp_accts, glc_cnt_act_dirdep_recs_prenote, glc_gp_payroll_dirdep_setup, glc_cnt_eft_vend_recs,
				glc_gp_eft_vend_setup, glc_cnt_post_gl_entries, glc_cnt_unpost_gl_entries, glc_cnt_post_ap_invoices, glc_cnt_unpost_ap_invoices,
				glc_cnt_post_ap_check_credit, glc_cnt_payroll_checks_dirdep, glc_cnt_post_ar_invoices, glc_cnt_unpost_ar_invoices, glc_cnt_check_credit_applied)

VALUES (@glc_rundate, @glc_cnt_gp_cust_invalid_class, @glc_cnt_gp_vend_invalid_class, @glc_cnt_gp_gl_acct_structure, @glc_cnt_gp_bal_acct_sheets,
				@glc_cnt_gp_income_stmnt_accts, @glc_cnt_gp_acct_yr_setup, @glc_cnt_gp_cust_no_ar_acct, @glc_cnt_gp_vend_no_ap_acct, @glc_cnt_gp_ten99_vend,
				@glc_gp_ztrans_setup, @glc_cnt_gp_cust_classes, @glc_gp_cust_class_defined, @glc_gp_vend_class_defined, @glc_cnt_act_employee_payroll,
				@glc_cnt_paycode_asgn_employee, @glc_cnt_dedcode_asgn_employee, @glc_cnt_fedtax_emp_recs, @glc_cnt_act_statetax_emp_recs, @glc_cnt_act_localtax_emp_recs,
				@glc_cnt_act_dirdep_emp_recs, @glc_cnt_act_dirdep_emp_accts, @glc_cnt_act_dirdep_recs_prenote, @glc_gp_payroll_dirdep_setup, @glc_cnt_eft_vend_recs,
				@glc_gp_eft_vend_setup, @glc_cnt_post_gl_entries, @glc_cnt_unpost_gl_entries, @glc_cnt_post_ap_invoices, @glc_cnt_unpost_ap_invoices,
				@glc_cnt_post_ap_check_credit, @glc_cnt_payroll_checks_dirdep, @glc_cnt_post_ar_invoices, @glc_cnt_unpost_ar_invoices, @glc_cnt_check_credit_applied)




GO
GRANT EXECUTE ON  [dbo].[golivecheck_gp_run] TO [public]
GO
