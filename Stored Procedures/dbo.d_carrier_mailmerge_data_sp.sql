SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_carrier_mailmerge_data_sp](@from_date    DATETIME,
                                             @to_date      DATETIME,
                                             @contact_type VARCHAR(6))
AS
DECLARE @maxid		INTEGER,
        @maddress1	VARCHAR(100),
	@mcty_code	INTEGER,
	@mzip		VARCHAR(10),
        @paddress1	VARCHAR(100),
	@pcty_code	INTEGER,
	@pzip		VARCHAR(10)

CREATE TABLE #temp_data (
	car_id			VARCHAR(8) NULL,
	insurance_type		VARCHAR(20) NULL,
	expiration_date		DATETIME NULL,
	car_name		VARCHAR(64) NULL,
	cc_fname		VARCHAR(40) NULL,
	cc_lname		VARCHAR(40) NULL,
	cc_title		VARCHAR(30) NULL,
	cc_address1		VARCHAR(100) NULL,
	cc_address2		VARCHAR(100) NULL,
	cc_address3		VARCHAR(100) NULL,
	cty_name		VARCHAR(18) NULL,
	cty_state		VARCHAR(6) NULL,
	cc_zip			VARCHAR(10) NULL,
	cc_fax			VARCHAR(20) NULL,
	cc_email		VARCHAR(128) NULL,
        cc_default_carrier_addr	CHAR(1) NULL,
	cc_id			INTEGER NULL
)

INSERT INTO #temp_data
   SELECT carrier.car_id,
          labelfile.name,
          ci.cai_expiration_dt,
          carrier.car_name,
          cc.cc_fname,
          cc.cc_lname,
          cc.cc_title,
          cc.cc_address1,
          cc.cc_address2,
          cc.cc_address3,
          city.cty_name,
          city.cty_state,
          cc_zip,
          cc_fax,
          cc_email,
          cc_default_carrier_addr,
          cc.cc_id
     FROM carrierinsurance ci JOIN carrier ON ci.car_id = carrier.car_id
                              JOIN carriercontacts cc ON ci.car_id = cc.car_id AND
                                                        cc.cc_contact_type = @contact_type AND
                                                        ISNULL(cc.cc_retired, 'N') = 'N'
                              LEFT OUTER JOIN city ON cc.cc_cty_code = city.cty_code
                              JOIN labelfile ON ci.cai_insurance_type = labelfile.abbr AND
                                                labelfile.labeldefinition = 'CarInsuranceType'
    WHERE ci.cai_expiration_dt BETWEEN @from_date AND @to_date
   ORDER BY cc.cc_id

UPDATE #temp_data
   SET cc_address1 = carrier.car_address1,
       cc_address2 = carrier.car_address2,
       cc_address3 = NULL,
       cty_name = city.cty_name,
       cty_state = city.cty_state,
       cc_zip = carrier.car_zip
  FROM #temp_data JOIN carrier ON #temp_data.car_id = carrier.car_id
                  JOIN city ON carrier.cty_code = city.cty_code
 WHERE #temp_data.cc_default_carrier_addr = 'Y'

SET @maxid = 0
WHILE 1=1
BEGIN
   SELECT @maxid = MIN(cc_id)
     FROM #temp_data
    WHERE cc_id > @maxid AND
          ISNULL(cc_default_carrier_addr, 'N') = 'N'

   IF @maxid is null
      BREAK

   SELECT @maddress1 = cc_mail1,
          @mcty_code = cc_mail_cty_code,
          @mzip      = cc_mail_zip,
          @paddress1 = cc_address1,
          @pcty_code = cc_cty_code,
          @pzip      = cc_zip
     FROM carriercontacts
    WHERE cc_id = @maxid

   IF @maddress1 IS NOT NULL AND LEN(@maddress1) > 0 AND @mcty_code > 0 AND
      @mzip IS NOT NULL AND LEN(@mzip) > 0
      UPDATE #temp_data
         SET cc_address1 = cc.cc_mail1,
             cc_address2 = cc.cc_mail2,
             cc_address3 = cc.cc_mail3,
             cty_name = city.cty_name,
             cty_state = city.cty_state,
             cc_zip = cc.cc_mail_zip
        FROM #temp_data JOIN carriercontacts cc ON #temp_data.cc_id = cc.cc_id
                        JOIN city ON cc.cc_mail_cty_code = city.cty_code
       WHERE #temp_data.cc_id = @maxid
   ELSE IF @paddress1 IS NOT NULL AND LEN(@paddress1) > 0 AND @pcty_code > 0 AND
           @pzip IS NOT NULL AND LEN(@pzip) > 0
      UPDATE #temp_data
         SET cc_address1 = cc.cc_address1,
             cc_address2 = cc.cc_address2,
             cc_address3 = cc.cc_address3,
             cty_name = city.cty_name,
             cty_state = city.cty_state, 
             cc_zip = cc.cc_zip
        FROM #temp_data JOIN carriercontacts cc ON #temp_data.cc_id = cc.cc_id
                        JOIN city ON cc.cc_cty_code = city.cty_code
       WHERE #temp_data.cc_id = @maxid
END

SELECT *
  FROM #temp_data

GO
GRANT EXECUTE ON  [dbo].[d_carrier_mailmerge_data_sp] TO [public]
GO
