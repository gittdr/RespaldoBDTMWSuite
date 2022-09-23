SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[credit_pay_paydetail_list_sp]	(@ord_hdrnumber int, 
												@user_id varchar(20), 
												@paydetail_list varchar(200), 
												@nbrpd int, 
												@CalledFrom char(1),
												@nbrPydReversed int Output,
												@ps_returnmsg varchar(500) Output )
AS
Set NoCount ON
-- pts 62528 / Reverse Pay UI feature ; new GI setting:  ReversePayPresentUI
-- PTS 62527	gi_string2 contains pyd_status def value.  valid only if null, hld, pnd.
-- PTS 62527	Add argument @CalledFrom = Billing = 'B', Settlement = 'S'

set @ps_returnmsg = ''
set @nbrPydReversed = 0
declare		@IsError	Char(1)
SET	@IsError = 'N'

-- initial validations --
declare @Cnstnt1_ErrMsg		varchar(100)
declare @Cnstnt2_ErrMsg		varchar(100)
declare @Cnstnt3_ErrMsg		varchar(100)
declare @Cnstnt4_ErrMsg		varchar(100)
declare @Cnstnt5_ErrMsg		varchar(100)
set @Cnstnt1_ErrMsg = 'Err1: General Info Setting not correct to execute this procedure.'			-- 65
set @Cnstnt2_ErrMsg = 'Err2: Number of Paydetails to Reverse not passed into procedure. '			-- 64
set @Cnstnt3_ErrMsg = 'Err3: Number of Paydetails exceeds max allowed for a single procedure call.' -- 75
set	@Cnstnt4_ErrMsg = 'Err4: The Paydetail list passed into procedure is empty.'					-- 56
set @Cnstnt5_ErrMsg	= 'Succeeded: Reversal is Complete for this set of paydetails'

If Not exists ( select 1 from GENERALINFO where gi_name = 'ReversePayPresentUI' and gi_string1 = 'Y' ) 
	set @ps_returnmsg = @Cnstnt1_ErrMsg 
if @nbrpd IS Null OR @nbrpd <= 0 
	set @ps_returnmsg = @ps_returnmsg + @Cnstnt2_ErrMsg 
-- allow max 25 paydetails at a time.
--if @nbrpd > 25 
--	set @ps_returnmsg = @ps_returnmsg + @Cnstnt3_ErrMsg 	
if LEN(LTrim(RTrim(@paydetail_list))) <= 0 
	set @ps_returnmsg = @ps_returnmsg + @Cnstnt4_ErrMsg 
if LEN(LTrim(RTrim(@ps_returnmsg))) > 0 	SET	@IsError = 'Y'

IF @IsError = 'Y' 
begin
	set @nbrPydReversed = -1
	set @ps_returnmsg = LTrim(RTrim(@ps_returnmsg)) 
	RETURN 
end
-- end of initial validations --


-- Populate temptable with specific LIST of paydetails
declare		@li_count		int
declare		@li_try			int
declare		@PDListWork		varchar(200)
declare		@PDL_pydNbrStr	varchar(20)
declare		@pyd_number		int
declare		@loopCntr		int
declare		@PDLCommaPos	int
declare		@PDLNextPydPos	int
declare		@PDL_pydNbrNext	int	
declare		@Len_WorkList	int	
declare		@GI_str2_pydstatus	varchar(6) --PTS 62527	
declare		@pyd_Credit_Pay_Flag char(1)	-- PTS 62527

Set @GI_str2_pydstatus = ( Select IsNull(gi_string2, 'HLD') from GENERALINFO where gi_name = 'ReversePayPresentUI' and gi_string1 = 'Y' ) --PTS 62527
IF @GI_str2_pydstatus IS NULL Set @GI_str2_pydstatus = 'HLD'  --PTS 62527

Set @pyd_Credit_Pay_Flag = NULL
IF @CalledFrom = 'B' Set @pyd_Credit_Pay_Flag = 'Y'
	
Declare @PayDetailList TABLE (pyd_number int null,  PDLIdentity int identity(1,1) NOT NULL)		
Set @PDListWork = LTrim(RTrim(@paydetail_list))	
Set @Len_WorkList = LEN(@PDListWork)	
		
---- Handle last entry missing final comma.		
If SUBSTRING(@PDListWork, @Len_WorkList, 1 ) <> ','
begin
Set @PDListWork = @PDListWork + ','
end 			
		
		
Set @loopCntr = 1
While @loopCntr <= @nbrpd
Begin		
		set @PDLCommaPos = -1
		SELECT @PDLCommaPos = CHARINDEX(',', @PDListWork)
		
			-- populate temptable from pyd list.
			If @PDLCommaPos > 0
			Begin	
				--Select @PDL_pydNbrStr = SUBSTRING(@PDListWork, 1, (@PDLCommaPos - 1)) 
				-- remove the apostrophies
				Select @PDL_pydNbrStr = SUBSTRING(@PDListWork, 2, (@PDLCommaPos - 3))   	
				Select @PDL_pydNbrStr = LTRIM(RTrim(@PDL_pydNbrStr)) 					
				
				Select @PDL_pydNbrNext = CAST(@PDL_pydNbrStr as Integer)
				If @PDL_pydNbrNext > 0
				Begin
					Insert @PayDetailList(pyd_number) Values ( @PDL_pydNbrNext ) 
				End 	
				Set @PDListWork = SUBSTRING(@PDListWork, ( @PDLCommaPos +1), @Len_WorkList )
				Set @Len_WorkList = LEN(@PDListWork)	
				if @Len_WorkList <= 0 BREAK
			End 	

SET @loopCntr = @loopCntr + 1		
End		

If ( Select count(*) From @PayDetailList ) <= 0 
Begin
	set @nbrPydReversed = -1
	set @ps_returnmsg = @Cnstnt4_ErrMsg 
	set @ps_returnmsg = LTrim(RTrim(@ps_returnmsg)) 
	RETURN 
End
-- End Of Populate temptable with specific LIST of paydetails


-- Populate pay data for list of paydetails	
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
And p.pyd_number In ( Select Distinct pyd_number from @PayDetailList ) 
-- End OF Populate pay data for list of paydetails	

-- Reverse Pay compute process
UPDATE assetassignment  
SET pyd_status = 'NPD'  
FROM assetassignment a, #pay_temp t
WHERE a.asgn_id = t.asgn_id and
	a.asgn_type = t.asgn_type and
	a.lgh_number = t.lgh_number and
	( a.asgn_number = t.asgn_number And t.asgn_number > 0 ) 

UPDATE thirdpartyassignment
SET pyd_status = 'NPD'  
FROM thirdpartyassignment a, #pay_temp t
WHERE a.tpr_id = t.asgn_id and
	a.lgh_number = t.lgh_number 

-- PTS 62527; use variable
--UPDATE paydetail
--SET pyd_credit_pay_flag  = 'Y'
--FROM paydetail p, #pay_temp t
--WHERE p.pyd_number = t.pyd_number

-- PTS 62527; use variable
UPDATE paydetail
SET pyd_credit_pay_flag  = @pyd_Credit_Pay_Flag
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

update #pay_temp 
set	pyd_offsetpay_number = p.pyd_offsetpay_number
from #pay_temp pt, #pt p
where p.pyd_number = pt.pyd_number and
	p.asgn_type = pt.asgn_type and
	p.pyt_itemcode = pt.pyt_itemcode 
-- End Of Reverse Pay compute process


-- Update Paydetail Table.
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
	-pyd_quantity,		--  insert "negative" qty
        pyd_rateunit,
	pyd_unit,
	pyd_rate,
        -pyd_amount,		--  insert "negative" pyd_amt
        pyd_pretax,
	pyd_glnum,
        pyd_currency,
	pyd_currencydate,
       --'HLD',
       @GI_str2_pydstatus,		-- PTS 62527
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
        'Y',			-- pyd_adj_flag
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
	--'Y',
	@pyd_Credit_Pay_Flag,	-- PTS 62527	
	pyd_ivh_hdrnumber 
from #pay_temp

begin
	set @nbrPydReversed = (select count(pyd_number) from #pay_temp )
	set @ps_returnmsg = LTrim(RTrim(@Cnstnt5_ErrMsg))	
	RETURN 
end
-- end of Reversal process
GO
GRANT EXECUTE ON  [dbo].[credit_pay_paydetail_list_sp] TO [public]
GO
