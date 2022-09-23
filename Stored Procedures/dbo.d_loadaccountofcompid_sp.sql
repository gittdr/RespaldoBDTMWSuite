SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadaccountofcompid_sp] @billto varchar(8) AS

DECLARE @mastercmp	varchar(8),
		@rowcount	int

IF @billto <> ''
BEGIN
	SELECT	@mastercmp = ISNULL(cmp_mastercompany, @billto)
	FROM	company
	WHERE	cmp_id = @billto

	IF	@mastercmp = 'UNKNOWN'
		SELECT @mastercmp = @billto

	SELECT	@rowcount =	COUNT(cmp_id)
	FROM	company 
	WHERE	cmp_mastercompany = @mastercmp
	AND		cmp_accountof = 'Y'
	AND		(cmp_active = 'Y' OR cmp_active is null)
	AND		(cmp_hiddenid = 'N' OR cmp_hiddenid is null)

	IF @rowcount > 0 
		SELECT	Isnull(cmp_name ,''),
				cmp_id ,
				IsNull(cmp_address1,'') ,
				cmp_address2 , 
				cty_nmstct,
				cmp_defaultbillto,
				cmp_defaultpriority,
				ISNULL (cmp_zip, '' ),
				cmp_subcompany,
				cmp_currency,
				cmp_mileagetable,
				cmp_shipper,
				cmp_consingee,
				cmp_billto,
				cmp_contact = IsNull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30),
				Cmp_primaryphone,
				cmp_geoloc = IsnUll(cmp_geoloc,''),
				cmp_city ,
				IsNull(cmp_altid,''),
				IsNull(cmp_address3,'')	
		FROM	company 
		WHERE	cmp_mastercompany = @mastercmp
		AND		cmp_accountof = 'Y'
		AND		(cmp_active = 'Y' OR cmp_active is null)
		AND		(cmp_hiddenid = 'N' OR cmp_hiddenid is null)
		ORDER BY cmp_id 
	ELSE
		SELECT	Isnull(cmp_name ,''),
				cmp_id , 
				ISNULL (cmp_address1, '') , 
				cmp_address2 ,
				cty_nmstct ,
				cmp_defaultbillto,
				cmp_defaultpriority,
				ISNULL (cmp_zip, '' ),
				cmp_subcompany,
				cmp_currency,
				cmp_mileagetable,
				cmp_shipper,
				cmp_consingee,
				cmp_billto,
				cmp_contact = Isnull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30),
		        cmp_Primaryphone,
			    cmp_geoloc = IsNull(cmp_geoloc,''),
				cmp_city,
	            cmp_altid				
		FROM	company 
		WHERE	cmp_id = 'UNKNOWN' 
END
ELSE
BEGIN
	SELECT	@rowcount = COUNT(cmp_id)
	FROM	company 
	WHERE	cmp_accountof = 'Y'
	AND		(cmp_active = 'Y' OR cmp_active is null)
	AND		(cmp_hiddenid = 'N' OR cmp_hiddenid is null)

	IF @rowcount > 0 
		SELECT	Isnull(cmp_name ,''),
				cmp_id ,
				IsNull(cmp_address1,'') ,
				cmp_address2 , 
				cty_nmstct,
				cmp_defaultbillto,
				cmp_defaultpriority,
				ISNULL (cmp_zip, '' ),
				cmp_subcompany,
				cmp_currency,
				cmp_mileagetable,
				cmp_shipper,
				cmp_consingee,
				cmp_billto,
				cmp_contact = IsNull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30),
				Cmp_primaryphone,
				cmp_geoloc = IsnUll(cmp_geoloc,''),
				cmp_city ,
				IsNull(cmp_altid,''),
				IsNull(cmp_address3,'')	
		FROM	company 
		WHERE	cmp_accountof = 'Y'
		AND		(cmp_active = 'Y' OR cmp_active is null)
		AND		(cmp_hiddenid = 'N' OR cmp_hiddenid is null)
		ORDER BY cmp_id 
	ELSE
		SELECT	Isnull(cmp_name ,''),
				cmp_id , 
				ISNULL (cmp_address1, '') , 
				cmp_address2 ,
				cty_nmstct ,
				cmp_defaultbillto,
				cmp_defaultpriority,
				ISNULL (cmp_zip, '' ),
				cmp_subcompany,
				cmp_currency,
				cmp_mileagetable,
				cmp_shipper,
				cmp_consingee,
				cmp_billto,
				cmp_contact = Isnull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30),
		        cmp_Primaryphone,
			    cmp_geoloc = IsNull(cmp_geoloc,''),
				cmp_city,
	            cmp_altid				
		FROM	company 
		WHERE	cmp_id = 'UNKNOWN' 
END
SET ROWCOUNT 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadaccountofcompid_sp] TO [public]
GO
