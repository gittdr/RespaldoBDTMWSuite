SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[split_payheader_sp]
( @cur_pyh_number INT
)
AS

/*
*
*
* NAME:
* dbo.split_payheader_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to split payheader
*
* PARAMETERS:
* @cur_pyh_number INT
*
* RETURNS:
*
* NOTHING:
*
* 01/04/2013 PTS64409 SPN - Created Initial Version
* 06/06/2013 PTS69957 SPN - Must split per trip (lgh_number)
*
*/

BEGIN

   DECLARE @temp_pyh TABLE
   ( seqno                 INT IDENTITY
   , pyh_number            INT
   , pyh_payperiod         DATETIME
   , pyh_paystatus         VARCHAR(6)
   , pyh_prorap            CHAR(1)
   , pyh_payto             VARCHAR(12)
   , asgn_type             VARCHAR(6)
   , asgn_id               VARCHAR(13)
   , pyh_currency          VARCHAR(6)
   , pyh_currencydate      DATETIME
   , crd_cardnumber        CHAR(10)
   , pyh_checknumber       INT
   , pyh_issuedate         DATETIME
   , payee_invoice_number  VARCHAR(30)
   , payee_invoice_date    DATETIME
   , pyh_lgh_number        INT
   , c_ind                 INT
   , u_ind                 INT
   )

   DECLARE @temp_pyd TABLE
   ( seqno                 INT IDENTITY
   , pyd_number            INT
   , lgh_number				INT
   , pyt_currency          VARCHAR(6)
   , pyh_number            INT
   , u_ind                 INT
   )

	DECLARE @debug_ind			CHAR(1)
	
   DECLARE @gi_feature_on     CHAR(1)
   DECLARE @gi_asset_type     VARCHAR(100)

   DECLARE @maxseqno          INT
   DECLARE @seqno             INT
   DECLARE @d_pyd_number      INT
   DECLARE @d_pyh_number      INT
   DECLARE @d_lgh_number      INT
   DECLARE @d_pyt_currency    VARCHAR(6)
   DECLARE @h_pyh_number      INT
   DECLARE @h_lgh_number		INT
   DECLARE @h_pyh_currency    VARCHAR(6)
   DECLARE @sister_pyh_number INT
   DECLARE @c_ind             INT
   DECLARE @u_ind             INT

	SELECT @debug_ind = 'N'

   SELECT @gi_feature_on = UPPER(SUBSTRING(IsNull(gi_string1,'N'),1,1))
        , @gi_asset_type = RTRIM(LTRIM(IsNull(gi_string2,'*x*')))
     FROM generalinfo
    WHERE gi_name = 'STL_PostCloseCurrencySplit'
   IF RIGHT(@gi_asset_type,1) <> ','
      SELECT @gi_asset_type = @gi_asset_type + ','
   IF LEFT(@gi_asset_type,1) <> ','
      SELECT @gi_asset_type = ',' + @gi_asset_type

   IF @gi_feature_on <> 'Y'
		RETURN 0

   IF @cur_pyh_number <= 0
   BEGIN
      RAISERROR('Current Pay Header# is required.',16,1)
      RETURN -1
   END

   --Get All related payheaders
   INSERT INTO @temp_pyh
   ( pyh_number
   , pyh_payperiod
   , pyh_paystatus
   , pyh_prorap
   , pyh_payto
   , asgn_type
   , asgn_id
   , pyh_currency
   , pyh_currencydate
   , crd_cardnumber
   , pyh_checknumber
   , pyh_issuedate
   , payee_invoice_number
   , payee_invoice_date
   , pyh_lgh_number
   )
   SELECT pyh_pyhnumber
        , pyh_payperiod
        , pyh_paystatus
        , pyh_prorap
        , pyh_payto
        , asgn_type
        , asgn_id
        , IsNull(pyh_currency,'UNK')
        , pyh_currencydate
        , crd_cardnumber
        , pyh_checknumber
        , pyh_issuedate
        , payee_invoice_number
        , payee_invoice_date
        , pyh_lgh_number
     FROM payheader
    WHERE pyh_paystatus <> 'XFR'
      AND IsNull(asgn_type,'UNK') + ',' + IsNull(asgn_id,'UNK') + ',' + convert(varchar,IsNull(pyh_payperiod,GetDate()))
       IN (SELECT IsNull(asgn_type,'UNK') + ',' + IsNull(asgn_id,'UNK') + ',' + convert(varchar,IsNull(pyh_payperiod,GetDate()))
             FROM payheader
            WHERE pyh_pyhnumber = @cur_pyh_number
          )
          
   --Validate Asset Types restricted by GI
   IF (SELECT MAX(CHARINDEX(',' + LTRIM(RTRIM(asgn_type)) + ',' , @gi_asset_type))
         FROM @temp_pyh
      ) = 0
   BEGIN
      RAISERROR('Asset not qualified for Currency Split.',10,1) WITH NOWAIT
      RETURN -1
   END

   --Get paydetails for current payheader; Get pyd_currency from paytype.pyt_currency always
   INSERT INTO @temp_pyd
   ( pyd_number
   , pyh_number
   , lgh_number
   , pyt_currency
   )
   SELECT d.pyd_number
        , d.pyh_number
        , IsNull(d.lgh_number,0)
        , IsNull(t.pyt_currency,'UNK')
     FROM paydetail d
     JOIN paytype t ON d.pyt_itemcode = t.pyt_itemcode
     JOIN payheader h ON d.pyh_number = h.pyh_pyhnumber
    WHERE d.pyh_number = @cur_pyh_number
      AND h.pyh_paystatus <> 'XFR'
   ORDER BY d.pyd_number
      
   --Split
   SELECT @maxseqno = MAX(seqno) FROM @temp_pyd
   SELECT @seqno = 0
   WHILE @seqno < @maxseqno
   BEGIN
      SELECT @seqno = @seqno + 1

		--read each detail
      SELECT @d_pyd_number   = pyd_number
           , @d_pyh_number   = pyh_number
           , @d_lgh_number   = IsNull(lgh_number,0)
           , @d_pyt_currency = pyt_currency
        FROM @temp_pyd
       WHERE seqno = @seqno
      
		--Only for first detail
      IF @seqno = 1
      BEGIN
			--If all of the currencies in temp_pyh are UNK then set the first one from first temp_pyd
			IF NOT EXISTS (SELECT 1
								  FROM @temp_pyh
								 WHERE pyh_currency <> 'UNK'
							  )
			BEGIN
				UPDATE @temp_pyh
					SET u_ind = 1
					  , pyh_currency = @d_pyt_currency
				 WHERE pyh_number = @d_pyh_number
			END
			--If all of the legs in temp_pyh are 0 then set the first one from first temp_pyd
			IF NOT EXISTS (SELECT 1
								  FROM @temp_pyh
								 WHERE IsNull(pyh_lgh_number,0) <> 0
							  )
			BEGIN
				UPDATE @temp_pyh
					SET u_ind = 1
					  , pyh_lgh_number = @d_lgh_number
				 WHERE pyh_number = @d_pyh_number
			END
		END
		      
		--read header for the current detail (currency/leg may have been adjusted)
      SELECT @h_lgh_number = IsNull(pyh_lgh_number,0)
           , @h_pyh_currency = pyh_currency
        FROM @temp_pyh
       WHERE pyh_number = @d_pyh_number

		--PYH currency/leg does not match with this PYD; Look for Or Create another PYH otherwise continue
      IF @h_pyh_currency = @d_pyt_currency AND @h_lgh_number = @d_lgh_number CONTINUE

		SELECT @sister_pyh_number = 0
      SELECT @sister_pyh_number = MAX(pyh_number)
        FROM @temp_pyh
       WHERE IsNull(pyh_lgh_number,0) = @d_lgh_number
         AND pyh_currency = @d_pyt_currency
			
		IF IsNull(@sister_pyh_number,0) > 0
		--Move this detail under another PYH that has the same currency and leg (flag to update both payheaders for amounts)
			BEGIN                            
            UPDATE @temp_pyh
               SET u_ind = 1
             WHERE pyh_number IN (@d_pyh_number,@sister_pyh_number)
         END
		ELSE
		--Move this detail under a new PYH (flag to update the payheader for amounts)
         BEGIN                 
            --Create new payheader
            EXECUTE @sister_pyh_number = dbo.getsystemnumber 'PYHNUM',''
            INSERT INTO @temp_pyh
            ( pyh_number
            , pyh_payperiod
            , pyh_paystatus
            , pyh_prorap
            , pyh_payto
            , asgn_type
            , asgn_id
            , pyh_currency
            , pyh_currencydate
            , crd_cardnumber
            , pyh_checknumber
            , pyh_issuedate
            , payee_invoice_number
            , payee_invoice_date
            , pyh_lgh_number
            , c_ind
            )
            SELECT @sister_pyh_number
                 , pyh_payperiod
                 , pyh_paystatus
                 , pyh_prorap
                 , pyh_payto
                 , asgn_type
                 , asgn_id
                 , @d_pyt_currency
                 , pyh_currencydate
                 , crd_cardnumber
                 , pyh_checknumber
                 , pyh_issuedate
                 , payee_invoice_number
                 , payee_invoice_date
                 , @d_lgh_number
                 , 1
              FROM @temp_pyh
             WHERE pyh_number = @d_pyh_number
            --Update flag
            UPDATE @temp_pyh
               SET u_ind = 1
             WHERE pyh_number = @d_pyh_number
         END
            
      --Now update this paydetail with existing/new payheader
      UPDATE @temp_pyd
         SET u_ind = 1
           , pyh_number = @sister_pyh_number
       WHERE seqno = @seqno
         
   END   --LOOP

	If @debug_ind = 'Y'
	BEGIN
		SELECT * FROM @temp_pyh
		SELECT * FROM @temp_pyd
		RETURN 1
	END

	--Now update permanent tables
	
   --Insert New PYH from the temp table
   SELECT @maxseqno = MAX(seqno) FROM @temp_pyh
   SELECT @seqno = 0
   WHILE @seqno < @maxseqno
   BEGIN
      SELECT @seqno = @seqno + 1
      SELECT @h_pyh_number = pyh_number
           , @h_pyh_currency = pyh_currency
           , @c_ind = IsNull(c_ind,0)
        FROM @temp_pyh
       WHERE seqno = @seqno
      IF @c_ind <> 1 CONTINUE

      --Create New
      BEGIN
         INSERT INTO payheader
         ( pyh_pyhnumber
         , pyh_payperiod
         , pyh_paystatus
         , pyh_prorap
         , pyh_payto
         , asgn_type
         , asgn_id
         , pyh_currency
         , pyh_currencydate
         , crd_cardnumber
         , pyh_checknumber
         , pyh_issuedate
         , payee_invoice_number
         , payee_invoice_date
         , pyh_lgh_number
         )
         SELECT pyh_number
              , pyh_payperiod
              , pyh_paystatus
              , pyh_prorap
              , pyh_payto
              , asgn_type
              , asgn_id
              , pyh_currency
              , pyh_currencydate
              , crd_cardnumber
              , pyh_checknumber
              , pyh_issuedate
              , payee_invoice_number
              , payee_invoice_date
              , pyh_lgh_number
           FROM @temp_pyh
          WHERE seqno = @seqno
      END
   END

   --BEGIN Update PYD from the temp table
   SELECT @maxseqno = MAX(seqno) FROM @temp_pyd
   SELECT @seqno = 0
   WHILE @seqno < @maxseqno
   BEGIN
      SELECT @seqno = @seqno + 1
      SELECT @d_pyd_number = pyd_number
           , @d_pyh_number = pyh_number
           , @u_ind = IsNull(u_ind,0)
        FROM @temp_pyd
       WHERE seqno = @seqno
      IF @u_ind <> 1 CONTINUE

      --Update pyh_number
      BEGIN
         UPDATE paydetail
            SET pyh_number = @d_pyh_number
          WHERE pyd_number = @d_pyd_number
      END
   END

   --BEGIN Update PYH from the temp table Also update PYH amounts
   SELECT @maxseqno = MAX(seqno) FROM @temp_pyh
   SELECT @seqno = 0
   WHILE @seqno < @maxseqno
   BEGIN
      SELECT @seqno = @seqno + 1
      SELECT @h_pyh_number = pyh_number
           , @h_lgh_number = pyh_lgh_number
           , @h_pyh_currency = pyh_currency
           , @c_ind = IsNull(c_ind,0)
           , @u_ind = IsNull(u_ind,0)
        FROM @temp_pyh
       WHERE seqno = @seqno
      IF @c_ind <> 1 AND @u_ind <> 1 CONTINUE

      --Update Existing
      IF @u_ind = 1
      BEGIN
         UPDATE payheader
            SET pyh_lgh_number = @h_lgh_number
              , pyh_currency = @h_pyh_currency
          WHERE pyh_pyhnumber = @h_pyh_number

      END
      --Update Amounts
      EXEC update_payheader @h_pyh_number
   END
   --END Update PYH and PYD from the temp tables

   RAISERROR('Currency Split Complete.',10,1) WITH NOWAIT

   RETURN 1

END
GO
GRANT EXECUTE ON  [dbo].[split_payheader_sp] TO [public]
GO
