SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[create_offset_pay] (@drv_id		varchar(8), 
					@trc_id		varchar(8), 
					@trl_id		varchar(8), 
					@car_id		varchar(8), 
					@ord_hdrnumber	int, 
					@pay_id		varchar(8),
					@warning	int out)
as



--  11-16-2009:  Modification for PTS 49419: add pyt_offset_basis feature.



declare @li_count	int,
	@li_try		int,
	@pyd_number	int,
	@li_number	int,
	@del_pyd_number int

select @warning = 1

create  table #temp_paydetail
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
	pyt_paying_to		char(3)		null, 
	pyt_offset_percent	float		null, 
	pyt_offset_for		char(3)		null,
	pyt_offset_basis    varchar(6)  null )					---   pts 49419

select pd.pyd_number,
	pd.pyh_number,
  	pd.lgh_number,
  	pd.asgn_number,
 	pd.asgn_type,
 	pd.asgn_id,
  	pd.ivd_number,
  	pd.pyd_prorap,
 	pd.pyd_payto,
    	pd.pyt_itemcode,
 	pd.mov_number,
  	pd.pyd_description,
  	pd.pyr_ratecode,
 	pd.pyd_quantity,
 	pd.pyd_rateunit,
 	pd.pyd_unit,
 	pd.pyd_rate,
 	pd.pyd_amount, 
	pd.pyd_pretax,
 	pd.pyd_glnum, 
	pd.pyd_currency,
 	pd.pyd_currencydate, 
	pd.pyd_status,
 	pd.pyd_refnumtype,
 	pd.pyd_refnum,
        pd.pyh_payperiod,
        pd.pyd_workperiod,
        pd.lgh_startpoint,
 	pd.lgh_startcity,
 	pd.lgh_endpoint,
 	pd.lgh_endcity,
 	pd.ivd_payrevenue,
	pd.pyd_revenueratio,
        pd.pyd_lessrevenue,
        pd.pyd_payrevenue,
        pd.pyd_transdate,
        pd.pyd_minus,
   	pd.pyd_sequence,
 	pd.std_number,
  	pd.pyd_loadstate,
 	pd.pyd_xrefnumber,
 	pd.ord_hdrnumber,
 	pd.pyt_fee1,
        pd.pyt_fee2,
        pd.pyd_grossamount,
        pd.pyd_adj_flag,
 	pd.pyd_updatedby,
        pd.psd_id,
      	pd.pyd_transferdate,
        pd.pyd_exportstatus,
 	pd.pyd_releasedby,
       	pd.cht_itemcode,
 	pd.pyd_billedweight,
 	pd.tar_tarriffnumber,
 	pd.psd_batch_id,
	pd.pyd_updsrc,
 	pd.pyd_updatedon,
	pd.pyd_offsetpay_number,
	pt.pyt_paying_to, 
	pt.pyt_offset_percent, 
	pt.pyt_offset_for,
	ISNULL(pt.pyt_offset_basis, 'REV')	as 'pyt_offset_basis'		---   pts 49419		
into #temp_paydetail_1
from paydetail pd, paytype pt
where pt.pyt_itemcode = pd.pyt_itemcode and
	pd.ord_hdrnumber = @ord_hdrnumber and
	pt.pyt_paying_to = pd.asgn_type and
	pd.asgn_id = @pay_id

select * 
into #new_paydetail
from #temp_paydetail_1
where pyd_offsetpay_number is not null and
	pyd_offsetpay_number > 0  

If (select count(*) from #new_paydetail) > 0 and 
	(select count(*) from #new_paydetail) = (select count(*) from #temp_paydetail_1)
begin
	Select @warning = -1
	Return @warning
end

delete from #temp_paydetail_1 
where pyd_offsetpay_number is not null and
	pyd_offsetpay_number > 0  

insert into #temp_paydetail
select * 
from #temp_paydetail_1

If (select count(*) from #temp_paydetail) > 0
Begin
update #temp_paydetail
set	asgn_type = pyt_offset_for,
 	asgn_id = @drv_id,
	pyd_prorap = mpp_actg_type,
	pyd_payto = mpp_payto,
	--pyd_amount = -(pyd_amount * pyt_offset_percent)/100.0,			---   pts 49419 (add case statement)
	pyd_amount = case pyt_offset_basis
					WHEN 'FLT' THEN -( convert(money, pyt_offset_percent) ) 
					ELSE -(pyd_amount * pyt_offset_percent)/100.0
				end,
	pyd_quantity = -pyd_quantity
from	#temp_paydetail, manpowerprofile
where 	pyt_offset_for = 'DRV' and
	mpp_id = @drv_id

update #temp_paydetail
set	asgn_type = pyt_offset_for,
 	asgn_id = @trc_id,
	pyd_prorap = trc_actg_type,
	pyd_payto = trc_owner,
	--pyd_amount = -(pyd_amount * pyt_offset_percent)/100.0,			---   pts 49419 (add case statement)
	pyd_amount = case pyt_offset_basis
					WHEN 'FLT' THEN -( convert(money, pyt_offset_percent) ) 
					ELSE -(pyd_amount * pyt_offset_percent)/100.0
				end,
	pyd_quantity = -pyd_quantity
from	#temp_paydetail, tractorprofile
where 	pyt_offset_for = 'TRC' and
	trc_number = @trc_id


update #temp_paydetail
set	asgn_type = pyt_offset_for,
 	asgn_id = @trl_id,
	pyd_prorap = trl_actg_type,
	pyd_payto = trl_owner,
	--pyd_amount = -(pyd_amount * pyt_offset_percent)/100.0,			---   pts 49419 (add case statement)
	pyd_amount = case pyt_offset_basis
					WHEN 'FLT' THEN -( convert(money, pyt_offset_percent) ) 
					ELSE -(pyd_amount * pyt_offset_percent)/100.0
				end,
	pyd_quantity = -pyd_quantity
from	#temp_paydetail, trailerprofile
where 	pyt_offset_for = 'TRL' and
	trl_number = @trl_id

update #temp_paydetail
set	asgn_type = pyt_offset_for,
 	asgn_id = @car_id,
	pyd_prorap = car_actg_type,
	pyd_payto = pto_id,
	--pyd_amount = -(pyd_amount * pyt_offset_percent)/100.0,			---   pts 49419 (add case statement)
	pyd_amount = case pyt_offset_basis
					WHEN 'FLT' THEN -( convert(money, pyt_offset_percent) ) 
					ELSE -(pyd_amount * pyt_offset_percent)/100.0
				end,
	pyd_quantity = -pyd_quantity
from	#temp_paydetail, carrier
where 	pyt_offset_for = 'CAR' and
	car_id = @car_id

update #temp_paydetail 
set	asgn_number = a.asgn_number
from assetassignment a, #temp_paydetail t
where 	a.asgn_id = t.asgn_id and
	a.asgn_type = t.asgn_type and
	a.lgh_number = t.lgh_number

update #temp_paydetail 
set	pyd_offsetpay_number = pd.pyd_number
from paydetail pd, #temp_paydetail tpd
where 	pd.ord_hdrnumber = @ord_hdrnumber and
	pd.asgn_id = @pay_id and
	pd.pyd_number = tpd.pyd_number

-- Get new pyd_number
select @li_count = count(*) 
from #temp_paydetail

select @li_try = 1	
while @li_try <= @li_count
Begin
	EXEC @pyd_number = getsystemnumber 'PYDNUM', ''   

	update #temp_paydetail
	set	pyd_number = @pyd_number
	where	row_id = @li_try

	select @li_try = @li_try + 1
End

update paydetail 
set	pyd_offsetpay_number = tpd.pyd_number
from paydetail pd, #temp_paydetail tpd
where 	pd.ord_hdrnumber = @ord_hdrnumber and
	pd.asgn_id = @pay_id and
	tpd.pyd_offsetpay_number = pd.pyd_number 

insert into paydetail
	 (pyd_number,
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
	pyd_offsetpay_number)
select	pd.pyd_number,
	pd.pyh_number,
  	pd.lgh_number,
  	pd.asgn_number,
 	pd.asgn_type,
 	pd.asgn_id,
  	pd.ivd_number,
  	pd.pyd_prorap,
 	pd.pyd_payto,
    	pd.pyt_itemcode,
 	pd.mov_number,
  	pd.pyd_description,
  	pd.pyr_ratecode,
 	pd.pyd_quantity,
 	pd.pyd_rateunit,
 	pd.pyd_unit,
 	pd.pyd_rate,
 	pd.pyd_amount, 
	pd.pyd_pretax,
 	pd.pyd_glnum, 
	pd.pyd_currency,
 	pd.pyd_currencydate, 
	pd.pyd_status,
 	pd.pyd_refnumtype,
 	pd.pyd_refnum,
        pd.pyh_payperiod,
        pd.pyd_workperiod,
        pd.lgh_startpoint,
 	pd.lgh_startcity,
 	pd.lgh_endpoint,
 	pd.lgh_endcity,
 	pd.ivd_payrevenue,
	pd.pyd_revenueratio,
        pd.pyd_lessrevenue,
        pd.pyd_payrevenue,
        pd.pyd_transdate,
        pd.pyd_minus,
   	pd.pyd_sequence,
 	pd.std_number,
  	pd.pyd_loadstate,
 	pd.pyd_xrefnumber,
 	pd.ord_hdrnumber,
 	pd.pyt_fee1,
        pd.pyt_fee2,
        pd.pyd_grossamount,
        pd.pyd_adj_flag,
 	pd.pyd_updatedby,
        pd.psd_id,
      	pd.pyd_transferdate,
        pd.pyd_exportstatus,
 	pd.pyd_releasedby,
       	pd.cht_itemcode,
 	pd.pyd_billedweight,
 	pd.tar_tarriffnumber,
 	pd.psd_batch_id,
	pd.pyd_updsrc,
 	pd.pyd_updatedon,
	pd.pyd_offsetpay_number
from #temp_paydetail pd

/*	LOR	don't need this
update assetassignment  
set pyd_status = 'PPD'  
from #temp_paydetail pd, assetassignment a
where a.asgn_number = pd.asgn_number		*/

End

Return @warning

GO
GRANT EXECUTE ON  [dbo].[create_offset_pay] TO [public]
GO
