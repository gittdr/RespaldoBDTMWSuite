SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[f_get_cardnumbers] (@asgn_type varchar (3), @asgn_id varchar (13), @vendor varchar (8)) 
RETURNS @card TABLE
	(
	crd_cardnumber varchar (20),
	crd_accountid varchar (10),
	crd_customerid varchar (10), 
	crd_vendor		varchar (8), 
	crd_status		varchar(6)
	)
AS 
BEGIN
	IF @asgn_type = 'DRV'
		INSERT INTO @card 
			SELECT crd_cardnumber, crd_accountid, crd_customerid, crd_vendor, crd_status
			FROM cashcard 
			WHERE crd_driver = @asgn_id
	IF @asgn_type = 'TRC' 
		INSERT INTO @card 
			SELECT crd_cardnumber, crd_accountid, crd_customerid, crd_vendor, crd_status
			FROM cashcard 
			WHERE crd_unitnumber = @asgn_id
	IF @asgn_type = 'TRL'
		INSERT INTO @card 
			SELECT crd_cardnumber, crd_accountid, crd_customerid, crd_vendor, crd_status
			FROM cashcard 
			WHERE crd_trailernumber = @asgn_id
	IF RTRIM(@vendor) = '' SELECT @vendor = NULL
	IF @vendor is not null 
		DELETE FROM @card WHERE crd_vendor <> @vendor
	RETURN
END

GO
GRANT SELECT ON  [dbo].[f_get_cardnumbers] TO [public]
GO
