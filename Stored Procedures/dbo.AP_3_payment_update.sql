SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  proc [dbo].[AP_3_payment_update] @pad_batch int,@success int OUTPUT, @failure int OUTPUT
as
set nocount on

/**
 * 
 * NAME:	AP_3_payment_update
 *
 * TYPE:	[StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure updates paydetail table with accounts payable payment data.  
 *
 * This proc is called from AP_1_payment_file proc.
 *
 * REVISION HISTORY:
 * JSwindell PTS# 41779	created   7-29-2008
 * JSwindell 8-13-2008 Changed Procs to match Client Raw Data file.
 * PTS 47018 4-29-2009 Client wants to add new column to the transfer.
 *
 **/
 
declare @current_batch 		int

select @current_batch = pad_batch
from AP_payment_data

select @failure = 0, @success = 0


--  test pay_detail key - is it numeric?
INSERT INTO AP_payment_errorlog (pad_batch, pad_err_date, pad_err_record_id, pad_err_description, pad_ap_voucher_nbr)
select pad_batch, GETDATE(), pyd_number, 'pyd_number ' + Rtrim(LTrim(pyd_number)) + ' is not numeric'
,pad_ap_voucher_nbr
from	AP_payment_data
where IsNumeric(pyd_number) = 0 

delete AP_payment_data
where IsNumeric(pyd_number) = 0 

--  test check date - is it a valid date?
INSERT INTO AP_payment_errorlog (pad_batch, pad_err_date, pad_err_record_id, pad_err_description, pad_ap_voucher_nbr )
select pad_batch, GETDATE(), pad_ap_check_dt, 'Not a valid date'
,pad_ap_voucher_nbr
from	AP_payment_data
where ISDate(pad_ap_check_dt) = 0

delete AP_payment_data
where ISDate(pad_ap_check_dt) = 0

--  test pay_detail key - IS IT FOUND IN THE PAYDETAIL FILE?  If not - do not process it.
INSERT INTO AP_payment_errorlog (pad_batch, pad_err_date, pad_err_record_id, pad_err_description, pad_ap_voucher_nbr )
select pad_batch, GETDATE(), pyd_number, 'This Paydetail number ' + RTrim(LTrim(pyd_number)) + ' was not found in paydetail table.'
,pad_ap_voucher_nbr
from	AP_payment_data
where cast(pyd_number as integer) not in (select pyd_number from paydetail) 

delete AP_payment_data
where cast(pyd_number as integer) not in (select pyd_number from paydetail) 


select @failure = count(*)
from AP_payment_errorlog
where pad_batch = @current_batch

select @success = count(*)
from AP_payment_data

UPDATE AP_payment_data
SET pyd_number = cast(pyd_number as integer)

--  Whatever is left in the raw data file seems OK to process.
update paydetail 
set		pyd_ap_check_date   = pad_ap_check_dt,	
		pyd_ap_check_number = pad_ap_check_nbr,
		pyd_ap_check_amount = pad_ap_check_amt,
		pyd_ap_vendor_id	= pad_ap_vendor_id, 
		pyd_ap_voucher_nbr  = pad_ap_voucher_nbr,		-- PTS 47018
		pyd_updatedon = getdate(), 
		pyd_ap_updated_by = 'AP_Upload'
from    AP_payment_data 
where	paydetail.pyd_number = AP_payment_data.pyd_number

delete AP_payment_data 


-- Original code.  Tests & update changed due to client raw data file changes.
--INSERT INTO AP_payment_errorlog (pad_batch, pad_err_date, pad_err_record_id, pad_err_description )
--select pad_batch, GETDATE(), pad_invoice_nbr, 'pyd_number not numeric'
--from	AP_payment_data 
--where IsNumeric(pad_invoice_nbr) = 0 
--
--delete AP_payment_data 
--where IsNumeric(pad_invoice_nbr) = 0 
--
--INSERT INTO AP_payment_errorlog (pad_batch, pad_err_date, pad_err_record_id, pad_err_description )
--select pad_batch, GETDATE(), pad_ap_check_dt, 'Not a valid date'
--from	AP_payment_data 
--where IsDate((substring(pad_ap_check_dt, 5, 2) + '/' + substring(pad_ap_check_dt, 7, 2) + '/' + substring(pad_ap_check_dt, 1, 4))) = 0 
--
--delete AP_payment_data 
--where IsDate((substring(pad_ap_check_dt, 5, 2) + '/' + substring(pad_ap_check_dt, 7, 2) + '/' + substring(pad_ap_check_dt, 1, 4))) = 0 
--
--
--INSERT INTO AP_payment_errorlog (pad_batch, pad_err_date, pad_err_record_id, pad_err_description )
--select pad_batch, GETDATE(), pad_invoice_nbr, 'Not a valid pyd_number'
--from	AP_payment_data 
--where cast(pad_invoice_nbr as integer) not in (select pyd_number from paydetail) 

--update paydetail 
--set		pyd_ap_check_date = convert(Datetime, (substring(pad_ap_check_dt, 5, 2) + '/' + substring(pad_ap_check_dt, 7, 2) + '/' + substring(pad_ap_check_dt, 1, 4)), 101),
--		pyd_ap_check_number = pad_ap_check_nbr,
--		pyd_ap_check_amount = pad_ap_check_amt,
--		pyd_updatedon = getdate(), 
--		pyd_updatedby = 'AP_Upload'
--from	AP_payment_data 
--where	paydetail.pyd_number = AP_payment_data .pyd_number

GO
GRANT EXECUTE ON  [dbo].[AP_3_payment_update] TO [public]
GO
