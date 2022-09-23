SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- create procedure
CREATE PROCEDURE [dbo].[d_passenger_sp]
	@p_psgrId     		varchar(8)
AS


SELECT  psgr_id,
	psgr_firstname,
	psgr_lastname,
	psgr_middleinitial,
	psgr_address1,
	psgr_address2,
	psgr_city, --= (SELECT cty_name 
		    -- FROM city, passenger
		    -- WHERE city.cty_code = passenger.psgr_city
		    -- AND passenger.psgr_id = @p_psgrId),
	psgr_ctynmstct = ISNULL(psgr_ctynmstct, 'UNKNOWN'),
	psgr_state,
	psgr_zip,
	psgr_country,
	psgr_gender,
	psgr_dateofbirth,
	psgr_citizenship_status,
	psgr_citizenship_country,
	psgr_driverlicense,
	psgr_licenseclass,
	psgr_license_region,
	psgr_status = 'CitizenshipStatus',
	ISNULL(psgr_aceid_type,'UNK'),
	psgr_aceid_number
FROM passenger

WHERE psgr_id = @p_psgrId

GO
GRANT EXECUTE ON  [dbo].[d_passenger_sp] TO [public]
GO
