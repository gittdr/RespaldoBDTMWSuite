SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Interactive_Fuel_Update_sp](@asset_type char(3), @asset_id varchar(8), @lgh_number int = 0, @update_type varchar(20) = "TRIP")
AS
	if (select count(*) from cashcard where crd_vendor = 'QUIKQI') > 0
		begin
			if ((select count(*) from FuelCardUpdateQueue where fcuq_update_type = @update_type and fcuq_asgn_type = @asset_type and fcuq_asgn_id = @asset_id and lgh_number = @lgh_number) = 0) and isnull(@asset_id,'UNKNOWN') <> 'UNKNOWN'
				insert into FuelCardUpdateQueue (fcuq_update_type, fcuq_asgn_type, fcuq_asgn_id, lgh_number, fcuq_updatedon)
					values  (isnull(@update_type, 'TRIP'), isnull(@asset_type, 'DRV'), isnull(@asset_id, 'UNKNOWN'), isnull(@lgh_number, 0), getdate())
		end
	else
		begin 
			if ((select count(*) from FuelCardUpdateQueue where fcuq_update_type = @update_type and fcuq_asgn_type = @asset_type and fcuq_asgn_id = @asset_id) = 0) and isnull(@asset_id,'UNKNOWN') <> 'UNKNOWN'
				insert into FuelCardUpdateQueue (fcuq_update_type, fcuq_asgn_type, fcuq_asgn_id, lgh_number, fcuq_updatedon)
					values  (isnull(@update_type, 'TRIP'), isnull(@asset_type, 'DRV'), isnull(@asset_id, 'UNKNOWN'), isnull(@lgh_number, 0), getdate())
		end

GO
GRANT EXECUTE ON  [dbo].[Interactive_Fuel_Update_sp] TO [public]
GO
