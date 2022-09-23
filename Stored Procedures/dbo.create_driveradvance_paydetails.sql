SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[create_driveradvance_paydetails] @driver_id             VARCHAR(8),
                                                     @lgh_number            INTEGER,
                                                     @pay_type              VARCHAR(6),
                                                     @amount                MONEY,
                                                     @transcard_approval    VARCHAR(20),
                                                     @cashcard              VARCHAR(20),
                                                     @pay_status            VARCHAR(6),
                                                     @fee1                  MONEY,
                                                     @ord_hdrnumber         INTEGER
AS
DECLARE @pyt_otflag       CHAR(1),
        @pyt_description  VARCHAR(30),
        @pyt_basisunit    VARCHAR(6),
        @pyt_rateunit     VARCHAR(6),
        @pyt_unit         VARCHAR(6),
        @pyt_minus        CHAR(1),
        @pyt_pretax       CHAR(1),
        @current_date     DATETIME,
        @date             DATETIME,
        @pyd_number       INTEGER,
        @minusint         SMALLINT,
        @rate             MONEY,
        @quantity		  MONEY



SET @current_date = GETDATE()
SET @date = CONVERT(VARCHAR(10), @current_date, 101) + ' 00:00:00'
SET @current_date = @date

SELECT @pyt_otflag = pyt_otflag,
       @pyt_description = pyt_description,
       @pyt_basisunit = pyt_basisunit,
       @pyt_rateunit = pyt_rateunit,
       @pyt_unit = pyt_unit,
       @pyt_minus = pyt_minus,
       @pyt_pretax = pyt_pretax
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

SET @amount = (@amount + @fee1) * @minusint

EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM', ''
INSERT INTO paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type,
                       asgn_id, pyd_prorap, pyt_itemcode, mov_number, pyd_description,
                       pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
                       pyd_rate, pyd_amount, pyd_pretax, pyd_currency, pyd_status,
                       pyd_refnumtype, pyd_refnum, pyh_payperiod, pyd_workperiod, pyd_transdate,
                       pyd_minus, pyd_loadstate, ord_hdrnumber, pyt_fee1, pyt_fee2,
                       pyd_grossamount, psd_id, pyd_updsrc, pyd_thirdparty_split_percent,
                       crd_cardnumber)         
               VALUES (@pyd_number, 0, @lgh_number, 0, 'DRV',
                       @driver_id, 'P', @pay_type, 0, @pyt_description, 
                       @pyt_basisunit, @quantity, @pyt_rateunit, @pyt_unit,
                       @rate, @amount, @pyt_pretax, 'US$', @pay_status,
                       'TRCRD', @transcard_approval, '2049-12-31 23:59:59', '2049-12-31 23:59:59', @current_date, 
                       @minusint, 'NA', @ord_hdrnumber, @fee1, 0,
                       @amount, 0, 'M', 0,
                       @cashcard)

SELECT @pyd_number pyd_number
GO
GRANT EXECUTE ON  [dbo].[create_driveradvance_paydetails] TO [public]
GO
