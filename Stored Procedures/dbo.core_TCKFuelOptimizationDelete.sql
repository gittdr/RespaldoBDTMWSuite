SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKFuelOptimizationDelete]
	@tck_fuel_optimization_tfo_id int
AS
	DELETE FROM [tck_fuel_optimization] 
	WHERE	tfo_id = @tck_fuel_optimization_tfo_id

GO
GRANT EXECUTE ON  [dbo].[core_TCKFuelOptimizationDelete] TO [public]
GO
