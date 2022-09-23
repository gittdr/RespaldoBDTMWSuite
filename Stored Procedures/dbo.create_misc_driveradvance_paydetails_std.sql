SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[create_misc_driveradvance_paydetails_std] @asgn_type varchar (6),
                                                     @asgn_id             VARCHAR(13),
                                                     @lgh_number            INTEGER,
                                                     @pay_type              VARCHAR(6),
                                                     @amount                MONEY,
                                                     @pay_status            VARCHAR(6),
                                                     @ord_hdrnumber         INTEGER,
                                                     @pyd_stdnumber					integer,
                                                     @pyd_number            integer output
AS
SET NOCOUNT ON
DECLARE @pyt_otflag       CHAR(1),
        @pyt_description  VARCHAR(30),
        @pyt_basisunit    VARCHAR(6),
        @pyt_rateunit     VARCHAR(6),
        @pyt_unit         VARCHAR(6),
        @pyt_minus        CHAR(1),
        @pyt_pretax       CHAR(1),
        @current_date     DATETIME,
        @date             DATETIME,
        @minusint         SMALLINT,
        @rate             MONEY,
        @quantity		  MONEY,
        @payto 	      varchar (13),
        @actg_type		char (1), 
        @fee1					money,
        @fee2 				money, 
        @pyt_pr_glnum varchar (66),
        @pyt_ap_glnum varchar (66), 
        @glnum				varchar (66) 
        
SET @current_date = GETDATE()
SET @date = CONVERT(VARCHAR(10), @current_date, 101) + ' 00:00:00'
SET @current_date = @date

SELECT @pyt_otflag = pyt_otflag,
       @pyt_description = pyt_description,
       @pyt_basisunit = pyt_basisunit,
       @pyt_rateunit = pyt_rateunit,
       @pyt_unit = pyt_unit,
       @pyt_minus = pyt_minus,
       @pyt_pretax = pyt_pretax, 
       @fee1 = isnull (pyt_fee1, 0),
       @fee2 = isnull (pyt_fee2, 0), 
       @pyt_ap_glnum = ISNULL (pyt_ap_glnum, ''),
       @pyt_pr_glnum = ISNULL (pyt_pr_glnum, '')
  FROM paytype
WHERE pyt_itemcode = @pay_type

IF @pyt_minus = 'Y'
   SET @minusint = -1
ELSE
   SET @minusint = 1

-- 62288 DSK, set rate = 1 if amount = 0
IF @amount = 0
	BEGIN
	SET @rate = 1
	SET @quantity = 0
	END
ELSE
	BEGIN
	SET @rate = @amount
	SET @quantity = 1
	END

SET @amount = (@amount + @fee1 + @fee2) * @minusint

exec dbo.getpayto_sp @asgn_type, @asgn_id, @payto OUTPUT, @actg_type OUTPUT
if @actg_type = 'P' select @glnum = @pyt_pr_glnum else select @glnum = @pyt_ap_glnum

EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM', ''
INSERT INTO paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type,
                       asgn_id, pyd_prorap, pyt_itemcode, mov_number, pyd_description,
                       pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
                       pyd_rate, pyd_amount, pyd_pretax, pyd_currency, pyd_status,
                       pyh_payperiod, pyd_workperiod, pyd_transdate,
                       pyd_minus, pyd_loadstate, ord_hdrnumber, pyt_fee1, pyt_fee2,
                       pyd_grossamount, psd_id, pyd_updsrc, pyd_thirdparty_split_percent,
                       pyd_advstdnum, pyd_payto, pyd_glnum)     
               VALUES (@pyd_number, 0, @lgh_number, 0, @asgn_type,
                       @asgn_id, @actg_type, @pay_type, 0, @pyt_description, 
                       @pyt_basisunit, @quantity, @pyt_rateunit, @pyt_unit,
                       @rate, @amount, @pyt_pretax, 'US$', @pay_status,
                       '2049-12-31 23:59:59', '2049-12-31 23:59:59', @current_date, 
                       @minusint, 'NA', @ord_hdrnumber, @fee1, 0,
                       @amount, 0, 'M', 0, 
                       @pyd_stdnumber, @payto, @glnum)

GO
GRANT EXECUTE ON  [dbo].[create_misc_driveradvance_paydetails_std] TO [public]
GO
