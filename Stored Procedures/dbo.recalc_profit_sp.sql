SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[recalc_profit_sp]
		@number int,
		@type varchar(6),
		@profit	decimal (12,4),
		@new_profit decimal(12, 4) output,
		@new_rate decimal(12, 4) output
		--,@round int
as

Create table #temp (
	pyd_number		int			not null, 
	lgh_number		int			null, 
	asgn_number		int			null, 
	asgn_type		varchar(6)	null, 
	asgn_id			varchar(13)	null, 
	ivd_number		int			null, 
	pyd_prorap		char(1)		null, 
	pyd_payto		varchar(12)	null, 
	pyt_itemcode	varchar(6)	null,
	pyd_description varchar(75)	null, 
	pyr_ratecode	varchar(6)	null, 
	pyd_quantity	decimal (12,4) null, 
	pyd_rateunit	varchar(6)	null, 
	pyd_unit		varchar(6)	null, 
	pyd_pretax		char(1)		null, 
	pyd_glnum		varchar(32)	null, 
	pyd_status		varchar(6)	null, 
	pyd_refnumtype	varchar(6)	null, 
	pyd_refnum		varchar(30)	null, 
	pyh_payperiod	datetime	null, 
	ivd_payrevenue	money		null, 
	mov_number		int			null, 
	pyd_minus		int			null, 
	pyd_workperiod	datetime	null, 
	pyd_sequence	int			null, 
	pyd_rate		decimal (12,4) null, 
	pyd_amount		decimal (12,4) null, 
	pyd_revenueratio decimal (12,4) null, 
	pyd_lessrevenue	money		null,  
	pyd_payrevenue	money		null, 
	std_number		int			null, 
	pyd_loadstate	varchar(6)	null, 
	pyd_transdate	datetime	null, 
	pyd_xrefnumber	int			null, 
	ord_hdrnumber	int			null, 
	pyt_basis		varchar(6)	null, 
	pyt_fee1		money		null, 
	pyt_fee2		money		null, 
	pyd_grossamount	money		null, 
	tar_tarriffnumber varchar(12) null, 
	pyd_updsrc			char(1)		null, 
	pyt_basisunit	varchar(6) null,
  	pyd_tprsplit_number	int null,
    pyd_tprdiffbtw_number int null,
    pyt_exclude_3pp	char(1) null,
    tar_reduction	money null,
    tar_reduction_rateunit	varchar(6) null
)
 
declare @additional_pay decimal(12, 4), 
		@reduction decimal(12, 4), @reduction1 int,
		@reduction_rateunit	varchar(6),
		@amount	decimal(12, 4),
		@cmpmin decimal(12,4), @cmpmin1 int

Insert into #temp
SELECT pyd_number, 
		lgh_number,		
		asgn_number, 
		asgn_type, 
		asgn_id, 
		ivd_number, 
		pyd_prorap, 
		pyd_payto, 
		paydetail.pyt_itemcode, 
		pyd_description, 
		pyr_ratecode, 
		pyd_quantity, 
		pyd_rateunit, 
		pyd_unit, 
		pyd_pretax, 
		pyd_glnum, 
		pyd_status, 
		pyd_refnumtype, 
		pyd_refnum, 
		pyh_payperiod, 
		ivd_payrevenue, 
		mov_number, 
		pyd_minus, 
		pyd_workperiod, 
		pyd_sequence, 
		pyd_rate, 
		pyd_amount, 
		pyd_revenueratio, 
		pyd_lessrevenue,  
		pyd_payrevenue, 
		std_number, 
		pyd_loadstate, 
		pyd_transdate, 
		pyd_xrefnumber, 
		ord_hdrnumber, 
		paytype.pyt_basis, 
		paydetail.pyt_fee1, 
		paydetail.pyt_fee2, 
		pyd_grossamount, 
		paydetail.tar_tarriffnumber, 
		pyd_updsrc, 
		paytype.pyt_basisunit, 
      	pyd_tprsplit_number,
		pyd_tprdiffbtw_number,
		paytype.pyt_exclude_3pp,
		tar_reduction, 
		tar_reduction_rateunit
FROM  paydetail
	LEFT OUTER JOIN tariffheaderstl  on paydetail.tar_tarriffnumber = CONVERT(varchar(12), tariffheaderstl.tar_number), 
	paytype
WHERE paydetail.pyt_itemcode = paytype.pyt_itemcode AND 
	((ord_hdrnumber = @number AND @type = 'ORDNUM') OR (mov_number = @number AND @type = 'MOVE')) 

select @additional_pay = sum(pyd_amount )
from #temp 
where (pyt_basisunit <> '3PP' and asgn_type = 'TPR' and pyd_minus = 1 and IsNull(pyd_tprsplit_number, 0) = 0)
	--OR
	--(lgh_number in 
	--		(select lgh_number 
	--		from legheader 
	--		where mov_number in (select distinct mov_number 
	--							from stops 
	--							where ord_hdrnumber = @number and ord_hdrnumber > 0) 
	--			and asgn_type <> 'TPR') and ISNULL(pyt_exclude_3pp, 'N') = 'N')
				
select @new_profit = Convert(decimal(12, 4),(@profit - @additional_pay))

select @reduction = IsNull(tar_reduction, 0), 
	@reduction_rateunit = IsNull(tar_reduction_rateunit, ''),
	@amount = pyd_amount,
	@new_rate = pyd_rate
From #temp 
where Convert(int, tar_tarriffnumber) > 0 and pyt_basisunit = '3PP' and IsNull(pyd_tprsplit_number, 0) = 0

If @reduction_rateunit = 'CMPMIN'
begin
	select @reduction1 = Convert(int, @reduction)
	select @cmpmin = convert(int, (@profit - @amount))
	If @cmpmin <= @reduction1
	begin
		select @new_rate = Convert(decimal(12, 4),(@new_profit - @reduction))
		select @new_rate = Convert(decimal(12, 4),(@new_rate / @new_profit))
	end
end

DROP TABLE #TEMP

Return

GO
GRANT EXECUTE ON  [dbo].[recalc_profit_sp] TO [public]
GO
