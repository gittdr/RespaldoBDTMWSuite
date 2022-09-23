SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_TCKFuelOptimizationCreate]
		@tck_fuel_optimization_tfo_id int,
		@tck_fuel_optimization_tfo_expiration_date datetime,
		@tck_fuel_optimization_tfo_maximum_truck_volume money,
		@tck_fuel_optimization_tfo_status varchar (6),
		@tck_fuel_optimization_tfo_sitenumber varchar (10),
		@tck_fuel_optimization_tck_account_number varchar (10),
		@tck_fuel_optimization_crd_cardnumber varchar (20),
		@tck_fuel_optimization_crd_cardnumbershort varchar (20)
    	
	
		 
		
AS
INSERT INTO [tck_fuel_optimization] (
    	tfo_id,
	tfo_expiration_date,
	tfo_maximum_truck_volume,
	tfo_status,
	tfo_sitenumber,
	tck_account_number,
	crd_cardnumber,
	crd_cardnumbershort,
	tfo_updated_on,
    	tfo_updated_by,
    	tfo_created_date)
VALUES (
	@tck_fuel_optimization_tfo_id,
	@tck_fuel_optimization_tfo_expiration_date,
	@tck_fuel_optimization_tfo_maximum_truck_volume,
	@tck_fuel_optimization_tfo_status,
	@tck_fuel_optimization_tfo_sitenumber,
	@tck_fuel_optimization_tck_account_number,
	@tck_fuel_optimization_crd_cardnumber,
	@tck_fuel_optimization_crd_cardnumbershort,
	GetDate(),
	user,
	GetDate()
)

SELECT tfo_id as tck_fuel_optimization_tfo_id,
    tfo_updated_on,
    tfo_updated_by,
    tfo_created_date
FROM [tck_fuel_optimization]
WHERE tfo_id = @tck_fuel_optimization_tfo_id

GO
GRANT EXECUTE ON  [dbo].[core_TCKFuelOptimizationCreate] TO [public]
GO
