SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[fa_get_driver1_card] (@driver varchar (13), @tractor varchar (13), @cardnumber varchar (20) OUTPUT, @accountid varchar (10) OUTPUT, @customerid varchar(10) OUTPUT, @security varchar (20) OUTPUT)
AS 
BEGIN
	DECLARE 	@SendCardInfo	char (1), 
				@CardVendor		varchar (8),
				@SendSecurityCard char (1),
				@CardUserId varchar (20)
	SELECT @SendSecurityCard = LEFT(ISNull(gi_string1, 'N'), 1), @CardUserID = gi_string2
		FROM generalinfo
		WHERE gi_name = 'fa_getsecuritycard'
	SELECT @SendCardInfo = LEFT(ISNull(gi_string1, 'N'), 1), @CardVendor = gi_string2
		FROM generalinfo
		WHERE gi_name = 'fa_getcashcard'
	IF @SendCardInfo <> 'Y' return 
	SELECT @cardnumber=null, @accountid=NULL, @customerid=NULL
	IF @driver <> 'UNKNOWN'
	BEGIN
		SELECT top 1 @cardnumber = crd_cardnumber, @accountid = crd_accountid, @customerid = crd_customerid
			FROM dbo.f_get_cardnumbers ('DRV', @driver, @cardvendor)
			ORDER BY crd_status
		IF @cardnumber is null and @tractor <> 'UNKNOWN'
			SELECT top 1 @cardnumber = crd_cardnumber, @accountid = crd_accountid, @customerid = crd_customerid
				FROM dbo.f_get_cardnumbers ('TRC', @tractor, @cardvendor)
	END
	IF @cardnumber is not null and @SendSecurityCard = 'Y'
		SELECT top 1 @security = csc_cardnumber
			FROM dbo.f_get_securitycard (@accountid, @customerid, @carduserid, @cardvendor)
END
GO
GRANT EXECUTE ON  [dbo].[fa_get_driver1_card] TO [public]
GO
