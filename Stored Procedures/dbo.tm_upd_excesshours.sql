SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_upd_excesshours] @order_num char(12),
					 @type char(1),
					 @pyd_description varchar(75),
					 @lgh_tractor varchar(8),
					 @pyd_start_date datetime,	
					 @pyd_end_date datetime,
					 @odometer_start varchar(15),
					 @odometer_end varchar(15)
AS

DECLARE @pyd_number int,
	 @pyd_glnum varchar(66),
	 @pyt_itemcode varchar(6),
	 @asgn_number int,			-- asset assignment number
	 @asgn_id varchar(13),		-- driver id
	 @pyd_quantity decimal(5,2),	-- delay duration decimal hrs
	 @ord_hdrnumber int,
	 @lgh_number int,
 	 @mov_number int,
	 @ret char(1)

if @type='D'
	select @pyt_itemcode='DLYTM'	

if @type='W'
	select @pyt_itemcode='WTM'		-- temporary stub. Revisit later !!!

select @ret='1'

select @pyd_quantity=DATEDIFF(Minute, @pyd_start_date, @pyd_end_date) / 60.00

select @ord_hdrnumber=ord_hdrnumber from orderheader where ord_number=@order_num		
select @lgh_number=lgh_number, @mov_number=mov_number, @lgh_tractor=lgh_tractor from legheader where ord_hdrnumber=@ord_hdrnumber
select @asgn_number=asgn_number, @asgn_id=asgn_id from assetassignment where lgh_number=@lgh_number and asgn_type='DRV'
select @pyd_glnum=pyt_pr_glnum /*pyt_ap_glnum*/ from paytype where pyt_itemcode=@pyt_itemcode

IF ISNULL(@ord_hdrnumber,0)=0
	select @ret='0'

IF ISNULL(@lgh_number,0)=0
	select @ret='0'

IF ISNULL(@mov_number,0)=0
	select @ret='0'

IF ISNULL(@asgn_id,'')=''
	select @ret='0'

IF ISNULL(@pyt_itemcode,'')=''
	select @ret='0'

if @ret='0'
begin
	select @ret
	return
end

-- next id for Pay Detail Number
update systemcontrol set sys_controlnumber = sys_controlnumber + 1 where sys_controlid='PYDNUM'
select @pyd_number=sys_controlnumber from systemcontrol where sys_controlid='PYDNUM'

INSERT INTO excesshours(pyd_number , pyh_number, lgh_number , asgn_number , asgn_type, asgn_id , ivd_number, pyd_prorap, pyd_payto, pyt_itemcode , mov_number , pyd_description , pyr_ratecode, pyd_quantity , pyd_rateunit, pyd_unit, pyd_rate, pyd_amount, pyd_pretax, pyd_glnum , pyd_currency, pyd_currencydate, pyd_status, pyd_refnumtype, pyd_refnum, pyh_payperiod, pyd_workperiod, lgh_startpoint, lgh_startcity, lgh_endpoint, lgh_endcity, ivd_payrevenue, pyd_revenueratio, pyd_lessrevenue, pyd_payrevenue, pyd_transdate, pyd_minus, pyd_sequence, std_number, pyd_loadstate, pyd_xrefnumber, ord_hdrnumber,  pyt_fee1, pyt_fee2, pyd_grossamount, pyd_adj_flag, pyd_updsrc, pyd_updatedon, xsh_acceptflag)
                VALUES (@pyd_number, 0         , @lgh_number, @asgn_number, 'DRV'    , @asgn_id, 0         , 'P'       , 'UNKNOWN', @pyt_itemcode, @mov_number, @pyd_description, null        , @pyd_quantity, 'UNK'       , 'HRS'   , 0       , 0         , 'Y'       , @pyd_glnum, NULL        , NULL            , 'HLD'     , NULL          , NULL      , NULL         , NULL          , NULL          , 0            , NULL        , 0          , 0             , 0               , 0              , 0             , getdate()    , 1        , 0           , NULL      , 'NA'         , 0             , @ord_hdrnumber, NULL    , NULL    , NULL           , 'N'         , 'TM'      , getdate()    , 'N') 

select @ret

GO
GRANT EXECUTE ON  [dbo].[tm_upd_excesshours] TO [public]
GO
