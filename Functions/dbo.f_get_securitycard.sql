SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[f_get_securitycard] (@account_code varchar (20), @customer_code varchar (10), @user_id varchar (10), @vendor varchar (50)) 
RETURNS @card TABLE
	(
	csc_cardnumber varchar (10),
	csc_userid		 varchar (20),
	csc_vendor		varchar (50)
	)
AS 
BEGIN
	IF RTRIM(@account_code) = '' SELECT @account_code = NULL
	IF RTRIM(@customer_code) = '' SELECT @customer_code = NULL
	IF @account_code is not null and @customer_code is not null 
		INSERT INTO @card 
			SELECT csc_cardnumber, csc_userid, csc_vendor
			FROM cdsecuritycard
			WHERE cac_id = @account_code
			AND ccc_id = @customer_code
			AND csc_userid = @user_id
	ELSE
		INSERT INTO @card 
			SELECT csc_cardnumber, csc_userid, csc_vendor
			FROM cdsecuritycard
			WHERE csc_userid = @user_id
	IF RTRIM(@vendor) = '' SELECT @vendor = NULL
	IF @vendor is not null 
		DELETE FROM @card WHERE csc_vendor <> @vendor
	RETURN
END

GO
GRANT SELECT ON  [dbo].[f_get_securitycard] TO [public]
GO
