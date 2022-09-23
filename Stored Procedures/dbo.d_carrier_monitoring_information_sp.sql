SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_carrier_monitoring_information_sp] 
	@car_id		varchar (8)
AS

SELECT	car_id,
		car_411_monitored,
		monitored_text = 
			CASE car_411_monitored
				WHEN 'Y' THEN 'MONITORED'
				ELSE 'NOT MONITORED'
			END,
		car_iccnum,
		cas_docket_number,
		cas_safety_rating,
		safety_text =
			CASE cas_safety_rating
				 WHEN 'S' THEN 'Satisfactory'
				 WHEN 'C' THEN 'Conditional'
				 WHEN 'U' THEN 'Unsatisfactory'
				 ELSE 'No Data'
			END,
		cas_rate_date,
		cas_safestat_driver,
		cas_safestat_safety,
		cas_safestat_vehicle,
		cas_authority_common_status,
		common_status_text = 
			CASE cas_authority_common_status
				WHEN 'A' THEN 'Common'
				WHEN 'I' THEN 'Inactive common'
				WHEN 'N' THEN 'No Common'
				ELSE ''
			END,
		cas_authority_common_revocation_pending,
		common_revocation_text = 
			CASE cas_authority_common_revocation_pending
				WHEN 'Y' THEN 'Pend Rev Common'
				ELSE ''
			END,
		cas_authority_contract_status,
		contract_status_text =
			CASE cas_authority_contract_status
				WHEN 'A' THEN 'Contract'
				WHEN 'I' THEN 'Inactive contract'
				WHEN 'N' THEN 'No Contract'
				ELSE ''
			END,				
		cas_authority_contract_revocation_pending,
		contract_revocation_text =
			CASE cas_authority_contract_revocation_pending
				WHEN 'Y' THEN 'Pend Rev Contract'
				ELSE ''
			END,
		cas_insurance_cargo_required,
		cas_insurance_cargo_filed,
		cargo_insurance_filed_text =
			CASE cas_insurance_cargo_filed
				WHEN 'Y' THEN 'Cargo filed'
				ELSE ''
			END,
		cargo_insurance_status_text = 
			CASE WHEN cas_insurance_cargo_required = 'Y' AND cas_insurance_cargo_filed <> 'Y' THEN 'No cargo'
				ELSE ''
			END,
		cas_insurance_bipd_required,
		cas_insurance_bipd_filed,
		bipd_insurance_filed_text = 
			CASE 
				WHEN cas_insurance_bipd_filed = 0 THEN 'No Liability'
				WHEN cas_insurance_bipd_filed < cas_insurance_bipd_filed THEN 'Insufficient Liability'
				ELSE ''
			END,
		cas_411_last_update,
		cas_last_update
FROM	carrier car
		Left Join carrierstatus cas on (car.car_iccnum = cas.cas_docket_number OR 'MC' + car.car_iccnum = cas.cas_docket_number)
WHERE car_id = @car_id


GO
GRANT EXECUTE ON  [dbo].[d_carrier_monitoring_information_sp] TO [public]
GO
