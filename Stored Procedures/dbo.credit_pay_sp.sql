SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[credit_pay_sp](@ord_hdrnumber int, @user_id varchar(20))
AS

declare @li_count	int,
	@li_try		int,
	@pyd_number	int

create  table #pay_temp
	(row_id			int		identity,
	pyd_number		int		not null,
	pyh_number		int		null,
  	lgh_number		int		null,
  	asgn_number		int		null,
 	asgn_type		varchar(6)	null,
 	asgn_id			varchar(8)	null,
  	ivd_number		int		null,
  	pyd_prorap		char(1)		null,
 	pyd_payto		varchar(12)	null,
    	pyt_itemcode		varchar(6)	null,
 	mov_number		int		null,
  	pyd_description		varchar(30)	null,
  	pyr_ratecode		varchar(6)	null,
 	pyd_quantity		float		null,
 	pyd_rateunit		varchar(6)	null,
 	pyd_unit		varchar(6)	null,
 	pyd_rate		money		null,
 	pyd_amount		money		null, 
	pyd_pretax		char(1)		null,
 	pyd_glnum		varchar(32)	null, 
	pyd_currency		varchar(6)	null,
 	pyd_currencydate	datetime	null, 
	pyd_status		varchar(6)	null,
 	pyd_refnumtype		varchar(6)	null,
 	pyd_refnum		varchar(30)	null,
        pyh_payperiod		datetime	null,
        pyd_workperiod		datetime	null,
        lgh_startpoint		varchar(8)	null,
 	lgh_startcity		int		null,
 	lgh_endpoint		varchar(8)	null,
 	lgh_endcity		int		null,
 	ivd_payrevenue		money		null,
	pyd_revenueratio	float		null,
        pyd_lessrevenue		money		null,
        pyd_payrevenue		money		null,
        pyd_transdate		datetime	null,
        pyd_minus		int		null,
   	pyd_sequence		int		null,
 	std_number		int		null,
  	pyd_loadstate		varchar(6)	null,
 	pyd_xrefnumber		int		null,
 	ord_hdrnumber		int		null,
 	pyt_fee1		money		null,
        pyt_fee2		money		null,
        pyd_grossamount		money		null,
        pyd_adj_flag		char(1)		null,
 	pyd_updatedby		char(20)	null,
        psd_id			int		null,
      	pyd_transferdate	datetime	null,
        pyd_exportstatus	char(6)		null,
 	pyd_releasedby		char(20)	null,
       	cht_itemcode		varchar(6)	null,
 	pyd_billedweight	int		null,
 	tar_tarriffnumber	varchar(12)	null,
 	psd_batch_id		varchar(16)	null,
	pyd_updsrc		char(1)		null,
 	pyd_updatedon		datetime	null,
	pyd_offsetpay_number	int		null,
	pyd_credit_pay_flag	char(1)		null,
	pyd_ivh_hdrnumber	int		null)

insert into #pay_temp
select pyd_number,
	pyh_number,
	lgh_number,
	asgn_number,
	asgn_type,
	asgn_id,
	ivd_number,
	pyd_prorap,
	pyd_payto,
	p.pyt_itemcode,
	mov_number,
	pyd_description,
        pyr_ratecode,
	pyd_quantity,
        pyd_rateunit,
	pyd_unit,
	pyd_rate,
        pyd_amount,
        pyd_pretax,
	pyd_glnum,
        pyd_currency,
	pyd_currencydate,
        pyd_status,
	pyd_refnumtype,
	pyd_refnum,
        pyh_payperiod,
        pyd_workperiod,
        lgh_startpoint,
	lgh_startcity,
	lgh_endpoint,
	lgh_endcity,
	ivd_payrevenue,
        pyd_revenueratio,
        pyd_lessrevenue,
        pyd_payrevenue,
        pyd_transdate,
        pyd_minus,
	pyd_sequence,
	std_number,
	pyd_loadstate,
	pyd_xrefnumber,
	ord_hdrnumber,
	p.pyt_fee1,
        p.pyt_fee2,
        pyd_grossamount,
        pyd_adj_flag,
	pyd_updatedby,
        psd_id,
      	pyd_transferdate,
        pyd_exportstatus,
	pyd_releasedby,
       	cht_itemcode,
	pyd_billedweight,
	tar_tarriffnumber,
	psd_batch_id,
     	pyd_updsrc,
 	pyd_updatedon,
	pyd_offsetpay_number,
	pyd_credit_pay_flag,
	pyd_ivh_hdrnumber 
from paydetail p
where ord_hdrnumber = @ord_hdrnumber 
--	and
--	pt.pyt_itemcode = p.pyt_itemcode and
--	pt.pyt_basisunit = 'REV'

-- MRH 87141 Intercomany invoices
if (select gi_string1 from generalinfo where gi_name = 'ICARAP_reversepay') = 'N'
	delete from #pay_temp where pyd_number in (select icarap_pyd_number from ICARAPTrxTracking where icarap_ord_hdrnumber = @ord_hdrnumber)

UPDATE assetassignment  
SET pyd_status = 'NPD'  
FROM assetassignment a, #pay_temp t
WHERE a.asgn_id = t.asgn_id and
	a.asgn_type = t.asgn_type and
	a.lgh_number = t.lgh_number 

--	LOR	PTS# 44309
UPDATE thirdpartyassignment
SET pyd_status = 'NPD'  
FROM thirdpartyassignment a, #pay_temp t
WHERE a.tpr_id = t.asgn_id and
	a.lgh_number = t.lgh_number 
--	LOR

UPDATE paydetail
SET pyd_credit_pay_flag  = 'Y'
FROM paydetail p, #pay_temp t
WHERE p.pyd_number = t.pyd_number

-- Get new pyd_number and pyd_sequence
select @li_count = count(*) 
from #pay_temp

select @li_try = 1	
while @li_try <= @li_count
Begin
	EXEC @pyd_number = getsystemnumber 'PYDNUM', ''   

	update #pay_temp
	set	pyd_number = @pyd_number,
		pyd_sequence = (select max(pyd_sequence)
				from #pay_temp) + 1
	where	row_id = @li_try

	select @li_try = @li_try + 1
End

--	LOR	PTS# 22181
--select * from #pay_temp

select pt.pyd_number, pt.asgn_type, pt.pyt_itemcode, 
		p.pyd_number  pyd_offsetpay_number
into #pt
from #pay_temp pt, paytype t, #pay_temp p
where pt.asgn_type = t.pyt_paying_to and
	pt.pyt_itemcode = t.pyt_itemcode and
	pt.pyt_itemcode = p.pyt_itemcode and
	p.asgn_type = t.pyt_offset_for 
	and p.pyd_offsetpay_number is not null

insert into #pt (pyd_number, p.asgn_type, p.pyt_itemcode, pyd_offsetpay_number)
select p.pyd_number, p.asgn_type, p.pyt_itemcode, pt.pyd_number
from #pay_temp pt, paytype t, #pay_temp p
where pt.asgn_type = t.pyt_paying_to and
	pt.pyt_itemcode = t.pyt_itemcode and
	pt.pyt_itemcode = p.pyt_itemcode and
	p.asgn_type = t.pyt_offset_for 
	and p.pyd_offsetpay_number is not null

--select * from #pt

update #pay_temp 
set	pyd_offsetpay_number = p.pyd_offsetpay_number
from #pay_temp pt, #pt p
where p.pyd_number = pt.pyd_number and
	p.asgn_type = pt.asgn_type and
	p.pyt_itemcode = pt.pyt_itemcode 

--select * from #pay_temp
--	LOR

insert into paydetail(
	pyd_number,
	pyh_number,
	lgh_number,
	asgn_number,
	asgn_type,
	asgn_id,
	ivd_number,
	pyd_prorap,
	pyd_payto,
	pyt_itemcode,
	mov_number,
	pyd_description,
        pyr_ratecode,
	pyd_quantity,
        pyd_rateunit,
	pyd_unit,
	pyd_rate,
        pyd_amount,
        pyd_pretax,
	pyd_glnum,
        pyd_currency,
	pyd_currencydate,
        pyd_status,
	pyd_refnumtype,
	pyd_refnum,
        pyh_payperiod,
        pyd_workperiod,
        lgh_startpoint,
	lgh_startcity,
	lgh_endpoint,
	lgh_endcity,
	ivd_payrevenue,
        pyd_revenueratio,
        pyd_lessrevenue,
        pyd_payrevenue,
        pyd_transdate,
        pyd_minus,
	pyd_sequence,
	std_number,
	pyd_loadstate,
	pyd_xrefnumber,
	ord_hdrnumber,
	pyt_fee1,
        pyt_fee2,
        pyd_grossamount,
        pyd_adj_flag,
	pyd_updatedby,
        psd_id,
      	pyd_transferdate,
        pyd_exportstatus,
	pyd_releasedby,
       	cht_itemcode,
	pyd_billedweight,
	tar_tarriffnumber,
	psd_batch_id,
     	pyd_updsrc,
 	pyd_updatedon,
	pyd_offsetpay_number,
	pyd_credit_pay_flag,
	pyd_ivh_hdrnumber )
select pyd_number,
	0,
	lgh_number,
	asgn_number,
	asgn_type,
	asgn_id,
	ivd_number,
	pyd_prorap,
	pyd_payto,
	pyt_itemcode,
	mov_number,
	pyd_description,
        pyr_ratecode,
	-pyd_quantity,
        pyd_rateunit,
	pyd_unit,
	pyd_rate,
        -pyd_amount,
        pyd_pretax,
	pyd_glnum,
        pyd_currency,
	pyd_currencydate,
        'HLD',
	pyd_refnumtype,
	pyd_refnum,
        '20491231 11:59PM',
        getdate(),
        lgh_startpoint,
	lgh_startcity,
	lgh_endpoint,
	lgh_endcity,
	ivd_payrevenue,
        pyd_revenueratio,
        pyd_lessrevenue,
        pyd_payrevenue,
        pyd_transdate,
        pyd_minus,
	pyd_sequence,
	std_number,
	pyd_loadstate,
	pyd_xrefnumber,
	ord_hdrnumber,
	pyt_fee1,
        pyt_fee2,
        pyd_grossamount,
        'Y',
	@user_id,
        psd_id,
      	null,
        '',
	'',
       	cht_itemcode,
	pyd_billedweight,
	tar_tarriffnumber,
	psd_batch_id,
     	pyd_updsrc,
 	getdate(),
	pyd_offsetpay_number,
	'Y',
	pyd_ivh_hdrnumber 
from #pay_temp

GO
GRANT EXECUTE ON  [dbo].[credit_pay_sp] TO [public]
GO
