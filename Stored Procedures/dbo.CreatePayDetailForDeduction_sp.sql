SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create procedure [dbo].[CreatePayDetailForDeduction_sp] (@asgn_type varchar (6), 
                                                     @asgn_id varchar (13), 
                                                     @actg_type char (1), 
                                                     @payto varchar (12),
                                                     @paytype varchar (6), 
                                                     @p_dec_amount money, 
                                                     @pyd_description varchar (75), 
                                                     @pyd_number integer OUTPUT)
AS

-- Parameters: 
--    @asgn_type,
--    @asgn_id,
--    @actg_type,
--    @payto,
--    @PayType,
--    @p_dec_amount,
--    @pyd_description,
--    @pyd_number integer OUTPUT
declare @ap_glnum     char(32),
        @pr_glnum     char(32), 
        @glnum        char(32),
        @pyd_sequence   int,
        @pyt_minus      int,
        @pyt_rateunit   varchar(6),
        @pyt_unit     varchar(6),
        @spyt_minus     char(1),
        @pyr_ratecode   varchar(20),
        @Apocalypse     datetime
SET NOCOUNT ON

SELECT @Apocalypse = gi_date1
  FROM generalinfo
  WHERE gi_name = 'APOCALYPSE'
If @Apocalypse is null select @Apocalypse = convert(datetime,'20491231 23:59:59')

SELECT  @pyt_rateunit = ISNULL(pyt_rateunit,''),
        @pyt_unit     = ISNULL(pyt_unit,''),
        @ap_glnum     = ISNULL(pyt_ap_glnum,''),
        @pr_glnum     = ISNULL(pyt_pr_glnum,''),
        @spyt_minus   = ISNULL(pyt_minus,''),
        @pyr_ratecode = ISNULL(pyt_basisunit,'')
  FROM  paytype
  WHERE pyt_itemcode = @PayType

SELECT @pyt_minus = 1 -- default to 1
IF @spyt_minus = 'Y' SELECT @pyt_minus = -1

if @actg_type = 'P' select @glnum = @pr_glnum else select @glnum = @ap_glnum

-- Get the next pyd_number from the systemnumber table
EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM',''

INSERT INTO paydetail  
      (pyd_number,
      pyh_number,
      lgh_number,
      asgn_number,
      asgn_type,
      asgn_id,
      pyd_prorap,
      pyd_payto,
      pyt_itemcode,
      mov_number,
      pyd_description,
      pyd_quantity,
      pyd_rateunit,
      pyd_unit,
      pyd_rate,
      pyd_amount,
      pyd_pretax,
      pyd_glnum,
      pyd_currency,
      pyd_status,
      pyd_transdate,
      pyd_minus,
      pyd_sequence,
      pyd_loadstate,
      pyt_fee1,
      pyt_fee2,
      pyd_grossamount,
      pyd_updatedby,
      pyd_updatedon,
      pyh_payperiod,
      pyd_workperiod,
      pyd_vendorpay,
      pyd_updsrc,
      pyr_ratecode,
      ord_hdrnumber,
      psd_id
      )
VALUES (@pyd_number,  --pyd_number, 
    0,                --pyh_number,  
    0,                --lgh_number,  
    0,                --asgn_number, 
    @asgn_type,       --asgn_type,   
    @asgn_id,         --asgn_id,     
    @actg_type,       --pyd_prorap,  
    @payto,           --pyd_payto,   
    @PayType,         --pyt_itemcode,
    0,                --mov_number
    @pyd_description, --pyd_description
    1,                --pyd_quantity
    @pyt_rateunit,    --pyd_rateunit
    @pyt_unit,        --pyd_unit,    
    @p_dec_amount,    --pyd_rate,    
    @p_dec_amount * @pyt_minus,    --pyd_amount,  
    'Y',              --pyd_pretax,  
    @glnum,           --pyd_glnum,   
    NULL,             --pyd_currency,
    'PND',            --pyd_status
    GETDATE(),        --pyd_transdate
    @pyt_minus,       --pyt_minus
    @pyd_sequence,    --pyd_sequence
    'NA',             --pyd_loadstate
    0,                --pyt_fee1
    0,                --pyt_fee2
    0,                --pyd_grossamount 
    suser_sname(),    --pyd_updatedby
    GETDATE(),        --pyd_updatedon
    @Apocalypse,      --pyh_payperiod
    @Apocalypse,      --pyd_workperiod
    'N',              --pyd_vendorpay
    'M',              --pyd_updsrc
    @pyr_ratecode,    --pyr_ratecode
    0,                --ord_hdrnumber
    0                 --psd_id
    )

---select @pyd_number

GO
GRANT EXECUTE ON  [dbo].[CreatePayDetailForDeduction_sp] TO [public]
GO
