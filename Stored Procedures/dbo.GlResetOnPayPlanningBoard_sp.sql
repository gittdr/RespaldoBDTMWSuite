SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GlResetOnPayPlanningBoard_sp]
(
    @PayStatus         VARCHAR(20)
  , @DrvIncl           CHAR(3)
  , @TrcIncl           CHAR(3)
  , @TrlIncl           CHAR(3)
  , @CarIncl           CHAR(3)
  , @PtoIncl           CHAR(3)
  , @TprIncl           CHAR(3)
  , @DrvId             VARCHAR(8)
  , @TrcId             VARCHAR(8)
  , @TrlId             VARCHAR(8)
  , @CarId             VARCHAR(8)
  , @PtoId             VARCHAR(8)
  , @TprId             VARCHAR(8)
  , @DrvPayPeriodBegin DATETIME
  , @DrvPayPeriodEnd   DATETIME
  , @TrcPayPeriodBegin DATETIME
  , @TrcPayPeriodEnd   DATETIME
  , @TrlPayPeriodBegin DATETIME
  , @TrlPayPeriodEnd   DATETIME
  , @CarPayPeriodBegin DATETIME
  , @CarPayPeriodEnd   DATETIME
  , @PtoPayPeriodBegin DATETIME
  , @PtoPayPeriodEnd   DATETIME
  , @TprPayPeriodBegin DATETIME
  , @TprPayPeriodEnd   DATETIME
  , @DrvAccountingType VARCHAR(4)
  , @TrcAccountingType VARCHAR(4)
  , @TrlAccountingType VARCHAR(4)
  , @CarAccountingType VARCHAR(4)
  , @PtoAccountingType VARCHAR(4)
  , @TprAccountingType VARCHAR(4)

)
AS
BEGIN
/*******************************************************************************************************************
  Object Description:
  Returns ap export planning board data
  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  ------------   ----------------------------------------
  02/21/2017   BackOffice       NSUITE-200450  Initial Release
********************************************************************************************************************/
  SET NOCOUNT ON

  CREATE TABLE #PayHeader
  (
      pyh_pyhnumber           INT,
      asgn_type               VARCHAR(6),
      asgn_id                 VARCHAR(13),
      pyh_paystatus           VARCHAR(6),
      pyh_payperiod           DATETIME
  );

  DECLARE @PayHeaderStatus TABLE
  (
    PayStatus CHAR(3)
  );

  DECLARE @AccountingTypes TABLE
  (
      AssetType CHAR(3)
    , AccountingType CHAR(1)
  );

  SET @PayStatus = CASE WHEN LTRIM(RTRIM(COALESCE(@PayStatus, ''))) = '' THEN 'REL' ELSE @PayStatus END;
  INSERT @PayHeaderStatus(PayStatus)
    SELECT [items] from dbo.fn_SplitString(@PayStatus, ',');

  SET @DrvAccountingType = CASE WHEN LTRIM(RTRIM(COALESCE(@DrvAccountingType, ''))) = '' THEN 'P' ELSE @DrvAccountingType END;
  INSERT @AccountingTypes(AssetType, AccountingType)
    SELECT 'DRV', [items] from dbo.fn_SplitString(@DrvAccountingType, ',');

  SET @TrcAccountingType = CASE WHEN LTRIM(RTRIM(COALESCE(@TrcAccountingType, ''))) = '' THEN 'P' ELSE @TrcAccountingType END;
  INSERT @AccountingTypes(AssetType, AccountingType)
    SELECT 'TRC', [items] from dbo.fn_SplitString(@TrcAccountingType, ',');

  SET @TrlAccountingType = CASE WHEN LTRIM(RTRIM(COALESCE(@TrlAccountingType, ''))) = '' THEN 'P' ELSE @TrlAccountingType END;
  INSERT @AccountingTypes(AssetType, AccountingType)
    SELECT 'TRL', [items] from dbo.fn_SplitString(@TrlAccountingType, ',');

  SET @CarAccountingType = CASE WHEN LTRIM(RTRIM(COALESCE(@CarAccountingType, ''))) = '' THEN 'P' ELSE @CarAccountingType END;
  INSERT @AccountingTypes(AssetType, AccountingType)
    SELECT 'CAR', [items] from dbo.fn_SplitString(@CarAccountingType, ',');

  SET @PtoAccountingType = CASE WHEN LTRIM(RTRIM(COALESCE(@PtoAccountingType, ''))) = '' THEN 'P' ELSE @PtoAccountingType END;
  INSERT @AccountingTypes(AssetType, AccountingType)
    SELECT 'PTO', [items] from dbo.fn_SplitString(@PtoAccountingType, ',');

  SET @TprAccountingType = CASE WHEN LTRIM(RTRIM(COALESCE(@TprAccountingType, ''))) = '' THEN 'P' ELSE @TprAccountingType END;
  INSERT @AccountingTypes(AssetType, AccountingType)
    SELECT 'TPR', [items] from dbo.fn_SplitString(@TprAccountingType, ',');

  SELECT
    ph.pyh_pyhnumber,
    'Driver' AS asgn_type,
    ph.asgn_id,
    CASE ph.pyh_paystatus
        WHEN 'PND' THEN 'Released'
        WHEN 'COL' THEN 'Collected'
        WHEN 'REL' THEN 'Closed'
        WHEN 'XFR' THEN 'Transferred'
    END AS pyh_paystatus,
    CONVERT(NVARCHAR(12), ph.pyh_payperiod, 101) AS pyh_payperiod
  FROM dbo.payheader AS ph
      INNER JOIN
    @AccountingTypes AS aty ON ph.pyh_prorap = aty.AccountingType AND aty.AssetType = @DrvIncl
      INNER JOIN
    @PayHeaderStatus AS phs ON ph.pyh_paystatus = phs.PayStatus
  WHERE
    @DrvIncl != 'XXX'
    AND
    ph.asgn_type = @DrvIncl
    AND
    ph.pyh_payperiod BETWEEN @DrvPayPeriodBegin AND @DrvPayPeriodEnd
    AND
    ph.asgn_id = CASE WHEN @DrvId != 'UNKNOWN' THEN @DrvId ELSE ph.asgn_id END

  UNION ALL

  SELECT
    ph.pyh_pyhnumber,
    'Tractor' AS asgn_type,
    ph.asgn_id,
    CASE ph.pyh_paystatus
        WHEN 'PND' THEN 'Released'
        WHEN 'COL' THEN 'Collected'
        WHEN 'REL' THEN 'Closed'
        WHEN 'XFR' THEN 'Transferred'
    END AS pyh_paystatus,
    CONVERT(NVARCHAR(12), ph.pyh_payperiod, 101) AS pyh_payperiod
  FROM dbo.payheader AS ph
      INNER JOIN
    @AccountingTypes AS aty ON ph.pyh_prorap = aty.AccountingType AND aty.AssetType = @TrcIncl
      INNER JOIN
    @PayHeaderStatus AS phs ON ph.pyh_paystatus = phs.PayStatus
  WHERE
    @TrcIncl != 'XXX'
    AND
    ph.asgn_type = @TrcIncl
    AND
    ph.pyh_payperiod BETWEEN @TrcPayPeriodBegin AND @TrcPayPeriodEnd
    AND
    ph.asgn_id = CASE WHEN @TrcId != 'UNKNOWN' THEN @TrcId ELSE ph.asgn_id END

  UNION ALL

  SELECT
    ph.pyh_pyhnumber,
    'Trailer' AS asgn_type,
    ph.asgn_id,
    CASE ph.pyh_paystatus
        WHEN 'PND' THEN 'Released'
        WHEN 'COL' THEN 'Collected'
        WHEN 'REL' THEN 'Closed'
        WHEN 'XFR' THEN 'Transferred'
    END AS pyh_paystatus,
    CONVERT(NVARCHAR(12), ph.pyh_payperiod, 101) AS pyh_payperiod
  FROM dbo.payheader AS ph
      INNER JOIN
    @AccountingTypes AS aty ON ph.pyh_prorap = aty.AccountingType AND aty.AssetType = @TrlIncl
      INNER JOIN
    @PayHeaderStatus AS phs ON ph.pyh_paystatus = phs.PayStatus
  WHERE
    @TrlIncl != 'XXX'
    AND
    ph.asgn_type = @TrlIncl
    AND
    ph.pyh_payperiod BETWEEN @TrlPayPeriodBegin AND @TrlPayPeriodEnd
    AND
    ph.asgn_id = CASE WHEN @TrlId != 'UNKNOWN' THEN @TrlId ELSE ph.asgn_id END

  UNION ALL

  SELECT
    ph.pyh_pyhnumber,
    'Carrier' AS asgn_type,
    ph.asgn_id,
    CASE ph.pyh_paystatus
        WHEN 'PND' THEN 'Released'
        WHEN 'COL' THEN 'Collected'
        WHEN 'REL' THEN 'Closed'
        WHEN 'XFR' THEN 'Transferred'
    END AS pyh_paystatus,
    CONVERT(NVARCHAR(12), ph.pyh_payperiod, 101) AS pyh_payperiod
  FROM dbo.payheader AS ph
      INNER JOIN
    @AccountingTypes AS aty ON ph.pyh_prorap = aty.AccountingType AND aty.AssetType = @CarIncl
      INNER JOIN
    @PayHeaderStatus AS phs ON ph.pyh_paystatus = phs.PayStatus
  WHERE
    @CarIncl != 'XXX'
    AND
    ph.asgn_type = @CarIncl
    AND
    ph.pyh_payperiod BETWEEN @CarPayPeriodBegin AND @CarPayPeriodEnd
    AND
    ph.asgn_id = CASE WHEN @CarId != 'UNKNOWN' THEN @CarId ELSE ph.asgn_id END

  UNION ALL

  SELECT
    ph.pyh_pyhnumber,
    'PayTo' AS asgn_type,
    ph.asgn_id,
    CASE ph.pyh_paystatus
        WHEN 'PND' THEN 'Released'
        WHEN 'COL' THEN 'Collected'
        WHEN 'REL' THEN 'Closed'
        WHEN 'XFR' THEN 'Transferred'
    END AS pyh_paystatus,
    CONVERT(NVARCHAR(12), ph.pyh_payperiod, 101) AS pyh_payperiod
  FROM dbo.payheader AS ph
      INNER JOIN
    @AccountingTypes AS aty ON ph.pyh_prorap = aty.AccountingType AND aty.AssetType = @PtoIncl
      INNER JOIN
    @PayHeaderStatus AS phs ON ph.pyh_paystatus = phs.PayStatus
  WHERE
    @PtoIncl != 'XXX'
    AND
    ph.asgn_type = @PtoIncl
    AND
    ph.pyh_payperiod BETWEEN @PtoPayPeriodBegin AND @PtoPayPeriodEnd
    AND
    ph.asgn_id = CASE WHEN @PtoId != 'UNKNOWN' THEN @PtoId ELSE ph.asgn_id END

  UNION ALL

  SELECT
    ph.pyh_pyhnumber,
    'Third Party' AS asgn_type,
    ph.asgn_id,
    CASE ph.pyh_paystatus
        WHEN 'PND' THEN 'Released'
        WHEN 'COL' THEN 'Collected'
        WHEN 'REL' THEN 'Closed'
        WHEN 'XFR' THEN 'Transferred'
    END AS pyh_paystatus,
    CONVERT(NVARCHAR(12), ph.pyh_payperiod, 101) AS pyh_payperiod
  FROM dbo.payheader AS ph
      INNER JOIN
    @AccountingTypes AS aty ON ph.pyh_prorap = aty.AccountingType AND aty.AssetType = @TprIncl
      INNER JOIN
    @PayHeaderStatus AS phs ON ph.pyh_paystatus = phs.PayStatus
  WHERE
    @TprIncl != 'XXX'
    AND
    ph.asgn_type = @TprIncl
    AND
    ph.pyh_payperiod BETWEEN @TprPayPeriodBegin AND @TprPayPeriodEnd
    AND
    ph.asgn_id = CASE WHEN @TprId != 'UNKNOWN' THEN @TprId ELSE ph.asgn_id END

  ORDER BY asgn_type, asgn_id

END
GO
GRANT EXECUTE ON  [dbo].[GlResetOnPayPlanningBoard_sp] TO [public]
GO
