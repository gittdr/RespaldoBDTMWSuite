SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[create_driverseating_paydetails]
AS
DECLARE @trainer_pyt_itemcode     VARCHAR(6),
        @trainer_pyt_otflag       CHAR(1),
        @trainer_pyt_description  VARCHAR(30),
        @trainer_pyt_basisunit    VARCHAR(6),
        @trainer_pyt_rateunit     VARCHAR(6),
        @trainer_pyt_unit             VARCHAR(6),
        @trainer_pyt_minus        CHAR(1),
        @trainer_pyt_pretax       CHAR(1),
        @trainer_pyt_fee1         MONEY,
        @trainer_pyt_fee2         MONEY,
        @trainee_pyt_itemcode     VARCHAR(6),
        @trainee_pyt_otflag       CHAR(1),
        @trainee_pyt_description  VARCHAR(30),
        @trainee_pyt_basisunit    VARCHAR(6),
        @trainee_pyt_rateunit     VARCHAR(6),
        @trainee_pyt_unit             VARCHAR(6),
        @trainee_pyt_minus        CHAR(1),
        @trainee_pyt_pretax       CHAR(1),
        @trainee_pyt_fee1         MONEY,
        @trainee_pyt_fee2         MONEY,
        @trainer_rate             MONEY,
        @trainee_rate             MONEY,
        @trainer_minusint         SMALLINT,
        @trainee_minusint         SMALLINT,
        @current_date             DATETIME,
        @date                     VARCHAR(20),
        @minid                    INTEGER,
        @ds_driver1               VARCHAR(8),
        @ds_driver2               VARCHAR(8),
        @ds_driver3               VARCHAR(8),
        @pyd_number               INTEGER,
        @count                    INTEGER,
        @ds_driver1_misc1         VARCHAR(254),
        @ds_driver2_misc1         VARCHAR(254),
        @ds_driver3_misc1         VARCHAR(254)

CREATE TABLE #driverseating (
   ds_id            INTEGER NULL,
   ds_driver1       VARCHAR(8) NULL,
   ds_driver1_misc1 VARCHAR(254) NULL,
   ds_driver2       VARCHAR(8) NULL,
   ds_driver2_misc1 VARCHAR(254) NULL,
   ds_driver3       VARCHAR(8) NULL,
   ds_driver3_misc1 VARCHAR(254) NULL
)

SELECT @trainer_pyt_itemcode = UPPER(gi_string1),
       @trainer_rate = CONVERT(MONEY, gi_string2),
       @trainee_pyt_itemcode = UPPER(gi_string3),
       @trainee_rate = CONVERT(MONEY, gi_string4)
  FROM generalinfo
 WHERE gi_name = 'DriverSeatingPayDetails'

IF @trainer_pyt_itemcode IS NULL OR @trainee_pyt_itemcode Is NULL
   RETURN

SET @current_date = DATEADD(dd, -1, GETDATE())
SET @date = CONVERT(VARCHAR(10), @current_date, 101) + ' 00:00:00'
SET @current_date = @date

SELECT @trainer_pyt_otflag = pyt_otflag,
       @trainer_pyt_description = pyt_description,
       @trainer_pyt_basisunit = pyt_basisunit,
       @trainer_pyt_rateunit = pyt_rateunit,
       @trainer_pyt_unit = pyt_unit,
       @trainer_pyt_minus = pyt_minus,
       @trainer_pyt_pretax = pyt_pretax,
       @trainer_pyt_fee1 = pyt_fee1,
       @trainer_pyt_fee2 = pyt_fee2
  FROM paytype
 WHERE pyt_itemcode = @trainer_pyt_itemcode

IF @trainer_pyt_minus = 'Y'
   SET @trainer_minusint = -1
ELSE
   SET @trainer_minusint = 1

SELECT @trainee_pyt_otflag = pyt_otflag,
       @trainee_pyt_description = pyt_description,
       @trainee_pyt_basisunit = pyt_basisunit,
       @trainee_pyt_rateunit = pyt_rateunit,
       @trainee_pyt_unit = pyt_unit,
       @trainee_pyt_minus = pyt_minus,
       @trainee_pyt_pretax = pyt_pretax,
       @trainee_pyt_fee1 = pyt_fee1,
       @trainee_pyt_fee2 = pyt_fee2
  FROM paytype
 WHERE pyt_itemcode = @trainee_pyt_itemcode

IF @trainee_pyt_minus = 'Y'
   SET @trainee_minusint = -1
ELSE
   SET @trainee_minusint = 1

INSERT INTO #driverseating
   SELECT ds_id, ds_driver1, mpp1.mpp_misc1, ds_driver2, mpp2.mpp_misc1,
          ds_driver3, mpp3.mpp_misc1
     FROM driverseating JOIN manpowerprofile mpp1 ON ds_driver1 = mpp1.mpp_id
                        JOIN manpowerprofile mpp2 ON ds_driver2 = mpp2.mpp_id
                        JOIN manpowerprofile mpp3 ON ds_driver3 = mpp3.mpp_id
    WHERE @current_date BETWEEN ds_seated_dt AND ds_unseated_dt

SET @minid = 0
WHILE 1=1
BEGIN
   SELECT @minid = MIN(ds_id)
     FROM #driverseating
    WHERE ds_id > @minid

   IF @minid IS NULL
      BREAK

   SELECT @ds_driver1 = ds_driver1,
          @ds_driver1_misc1 = ds_driver1_misc1,
          @ds_driver2 = ds_driver2,
          @ds_driver2_misc1 = ds_driver2_misc1,
          @ds_driver3 = ds_driver3,
          @ds_driver3_misc1 = ds_driver3_misc1
     FROM #driverseating
    WHERE ds_id = @minid

   /* Check for trainee pay */
   IF @ds_driver1 <> 'UNKNOWN' AND @ds_driver1_misc1 = 'TE-TRAINEE'
   BEGIN
      SET @count = 0
      SELECT @count = COUNT(*)
        FROM paydetail
       WHERE asgn_type = 'DRV' AND
             asgn_id = @ds_driver1 AND
             pyt_itemcode = @trainee_pyt_itemcode AND
             pyd_transdate = @current_date
      IF @count = 0
      BEGIN
         EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM', ''
         INSERT INTO paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type,
                                asgn_id, pyd_prorap, pyt_itemcode, mov_number, pyd_description,
                                pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
                                pyd_rate, pyd_amount, pyd_pretax, pyd_currency, pyd_status,
                                pyd_refnumtype, pyh_payperiod, pyd_workperiod, pyd_transdate,
                                pyd_minus, pyd_loadstate, ord_hdrnumber, pyt_fee1, pyt_fee2,
                                pyd_grossamount, psd_id, pyd_updsrc, pyd_thirdparty_split_percent)         
                        VALUES (@pyd_number, 0, 0, 0, 'DRV',
                                @ds_driver1, 'P', @trainee_pyt_itemcode, 0, @trainee_pyt_description, 
                                @trainee_pyt_basisunit, 1, @trainee_pyt_rateunit, @trainee_pyt_unit,
                                @trainee_rate, @trainee_rate, @trainee_pyt_pretax, 'US$', 'PND',
                                'REF', '2049-12-31 23:59:59', '2049-12-31 23:59:59', @current_date, 
                                @trainee_minusint, 'NA', 0, @trainee_pyt_fee1, @trainee_pyt_fee2,
                                @trainee_rate, 0, 'M', 0)
      END
   END

   IF @ds_driver2 <> 'UNKNOWN' AND @ds_driver2_misc1 = 'TE-TRAINEE'
   BEGIN
      SET @count = 0
      SELECT @count = COUNT(*)
        FROM paydetail
       WHERE asgn_type = 'DRV' AND
             asgn_id = @ds_driver2 AND
             pyt_itemcode = @trainee_pyt_itemcode AND
             pyd_transdate = @current_date
      IF @count = 0
      BEGIN
         EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM', ''
         INSERT INTO paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type,
                                asgn_id, pyd_prorap, pyt_itemcode, mov_number, pyd_description,
                                pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
                                pyd_rate, pyd_amount, pyd_pretax, pyd_currency, pyd_status,
                                pyd_refnumtype, pyh_payperiod, pyd_workperiod, pyd_transdate,
                                pyd_minus, pyd_loadstate, ord_hdrnumber, pyt_fee1, pyt_fee2,
                                pyd_grossamount, psd_id, pyd_updsrc, pyd_thirdparty_split_percent)         
                        VALUES (@pyd_number, 0, 0, 0, 'DRV',
                                @ds_driver2, 'P', @trainee_pyt_itemcode, 0, @trainee_pyt_description, 
                                @trainee_pyt_basisunit, 1, @trainee_pyt_rateunit, @trainee_pyt_unit,
                                @trainee_rate, @trainee_rate, @trainee_pyt_pretax, 'US$', 'PND',
                                'REF', '2049-12-31 23:59:59', '2049-12-31 23:59:59', @current_date, 
                                @trainee_minusint, 'NA', 0, @trainee_pyt_fee1, @trainee_pyt_fee2,
                                @trainee_rate, 0, 'M', 0)
      END
   END

   IF @ds_driver3 <> 'UNKNOWN' AND @ds_driver3_misc1 = 'TE-TRAINEE'
   BEGIN
      SET @count = 0
      SELECT @count = COUNT(*)
        FROM paydetail
       WHERE asgn_type = 'DRV' AND
             asgn_id = @ds_driver3 AND
             pyt_itemcode = @trainee_pyt_itemcode AND
             pyd_transdate = @current_date
      IF @count = 0
      BEGIN
         EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM', ''
         INSERT INTO paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type,
                                asgn_id, pyd_prorap, pyt_itemcode, mov_number, pyd_description,
                                pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
                                pyd_rate, pyd_amount, pyd_pretax, pyd_currency, pyd_status,
                                pyd_refnumtype, pyh_payperiod, pyd_workperiod, pyd_transdate,
                                pyd_minus, pyd_loadstate, ord_hdrnumber, pyt_fee1, pyt_fee2,
                                pyd_grossamount, psd_id, pyd_updsrc, pyd_thirdparty_split_percent)         
                        VALUES (@pyd_number, 0, 0, 0, 'DRV',
                                @ds_driver3, 'P', @trainee_pyt_itemcode, 0, @trainee_pyt_description, 
                                @trainee_pyt_basisunit, 1, @trainee_pyt_rateunit, @trainee_pyt_unit,
                                @trainee_rate, @trainee_rate, @trainee_pyt_pretax, 'US$', 'PND',
                                'REF', '2049-12-31 23:59:59', '2049-12-31 23:59:59', @current_date, 
                                @trainee_minusint, 'NA', 0, @trainee_pyt_fee1, @trainee_pyt_fee2,
                                @trainee_rate, 0, 'M', 0)
      END
   END

   /* Check for trainer pay */
   IF @ds_driver1 <> 'UNKNOWN' AND @ds_driver1_misc1 = 'TR-TRAINER' AND
     ((@ds_driver2 <> 'UNKNOWN' AND @ds_driver2_misc1 = 'TE-TRAINEE') OR
      (@ds_driver3 <> 'UNKNOWN' AND @ds_driver3_misc1 = 'TE-TRAINEE'))
   BEGIN
      SET @count = 0
      SELECT @count = COUNT(*)
        FROM paydetail
       WHERE asgn_type = 'DRV' AND
             asgn_id = @ds_driver1 AND
             pyt_itemcode = @trainer_pyt_itemcode AND
             pyd_transdate = @current_date
      IF @count = 0
      BEGIN
         EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM', ''
         INSERT INTO paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type,
                                asgn_id, pyd_prorap, pyt_itemcode, mov_number, pyd_description,
                                pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
                                pyd_rate, pyd_amount, pyd_pretax, pyd_currency, pyd_status,
                                pyd_refnumtype, pyh_payperiod, pyd_workperiod, pyd_transdate,
                                pyd_minus, pyd_loadstate, ord_hdrnumber, pyt_fee1, pyt_fee2,
                                pyd_grossamount, psd_id, pyd_updsrc, pyd_thirdparty_split_percent)         
                        VALUES (@pyd_number, 0, 0, 0, 'DRV',
                                @ds_driver1, 'P', @trainer_pyt_itemcode, 0, @trainer_pyt_description, 
                                @trainer_pyt_basisunit, 1, @trainer_pyt_rateunit, @trainer_pyt_unit,
                                @trainer_rate, @trainer_rate, @trainer_pyt_pretax, 'US$', 'PND',
                                'REF', '2049-12-31 23:59:59', '2049-12-31 23:59:59', @current_date, 
                                @trainer_minusint, 'NA', 0, @trainer_pyt_fee1, @trainer_pyt_fee2,
                                @trainer_rate, 0, 'M', 0)
      END
   END

   IF @ds_driver2 <> 'UNKNOWN' AND @ds_driver2_misc1 = 'TR-TRAINER' AND
     ((@ds_driver1 <> 'UNKNOWN' AND @ds_driver1_misc1 = 'TE-TRAINEE') OR
      (@ds_driver3 <> 'UNKNOWN' AND @ds_driver3_misc1 = 'TE-TRAINEE'))
   BEGIN
      SET @count = 0
      SELECT @count = COUNT(*)
        FROM paydetail
       WHERE asgn_type = 'DRV' AND
             asgn_id = @ds_driver2 AND
             pyt_itemcode = @trainer_pyt_itemcode AND
             pyd_transdate = @current_date
      IF @count = 0
      BEGIN
         EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM', ''
         INSERT INTO paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type,
                                asgn_id, pyd_prorap, pyt_itemcode, mov_number, pyd_description,
                                pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
                                pyd_rate, pyd_amount, pyd_pretax, pyd_currency, pyd_status,
                                pyd_refnumtype, pyh_payperiod, pyd_workperiod, pyd_transdate,
                                pyd_minus, pyd_loadstate, ord_hdrnumber, pyt_fee1, pyt_fee2,
                                pyd_grossamount, psd_id, pyd_updsrc, pyd_thirdparty_split_percent)         
                        VALUES (@pyd_number, 0, 0, 0, 'DRV',
                                @ds_driver2, 'P', @trainer_pyt_itemcode, 0, @trainer_pyt_description, 
                                @trainer_pyt_basisunit, 1, @trainer_pyt_rateunit, @trainer_pyt_unit,
                                @trainer_rate, @trainer_rate, @trainer_pyt_pretax, 'US$', 'PND',
                                'REF', '2049-12-31 23:59:59', '2049-12-31 23:59:59', @current_date, 
                                @trainer_minusint, 'NA', 0, @trainer_pyt_fee1, @trainer_pyt_fee2,
                                @trainer_rate, 0, 'M', 0)
      END
   END

   IF @ds_driver3 <> 'UNKNOWN' AND @ds_driver3_misc1 = 'TR-TAINER' AND
     ((@ds_driver1 <> 'UNKNOWN' AND @ds_driver1_misc1 = 'TE-TRAINEE') OR
      (@ds_driver2 <> 'UNKNOWN' AND @ds_driver2_misc1 = 'TE-TRAINEE'))
   BEGIN
      SET @count = 0
      SELECT @count = COUNT(*)
        FROM paydetail
       WHERE asgn_type = 'DRV' AND
             asgn_id = @ds_driver3 AND
             pyt_itemcode = @trainer_pyt_itemcode AND
             pyd_transdate = @current_date
      IF @count = 0
      BEGIN
         EXECUTE @pyd_number = dbo.getsystemnumber 'PYDNUM', ''
         INSERT INTO paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type,
                                asgn_id, pyd_prorap, pyt_itemcode, mov_number, pyd_description,
                                pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit,
                                pyd_rate, pyd_amount, pyd_pretax, pyd_currency, pyd_status,
                                pyd_refnumtype, pyh_payperiod, pyd_workperiod, pyd_transdate,
                                pyd_minus, pyd_loadstate, ord_hdrnumber, pyt_fee1, pyt_fee2,
                                pyd_grossamount, psd_id, pyd_updsrc, pyd_thirdparty_split_percent)         
                        VALUES (@pyd_number, 0, 0, 0, 'DRV',
                                @ds_driver3, 'P', @trainer_pyt_itemcode, 0, @trainer_pyt_description, 
                                @trainer_pyt_basisunit, 1, @trainer_pyt_rateunit, @trainer_pyt_unit,
                                @trainer_rate, @trainer_rate, @trainer_pyt_pretax, 'US$', 'PND',
                                'REF', '2049-12-31 23:59:59', '2049-12-31 23:59:59', @current_date, 
                                @trainer_minusint, 'NA', 0, @trainer_pyt_fee1, @trainer_pyt_fee2,
                                @trainer_rate, 0, 'M', 0)
      END
   END
END

GO
GRANT EXECUTE ON  [dbo].[create_driverseating_paydetails] TO [public]
GO
