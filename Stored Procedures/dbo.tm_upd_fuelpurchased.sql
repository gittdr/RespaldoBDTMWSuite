SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_upd_fuelpurchased] @trc_number varchar(8), 	--1
					   @trl_number varchar(13), 					--2
					   @mpp_id varchar(8), 							--3
					   @fp_date_c varchar(22), 						--4
					   @fp_purchcode varchar(6) = 'CMD',			--5
					   @fp_vendorname varchar(30),					--6
					   @fp_quantity_c varchar(15),					--7
 					   @fp_odometer_c varchar(10)					--8
AS

	RAISERROR ('This procedure is no longer valid, please use the highest numbered tm_upd_fuelpurchased procedure available..', 16, 1)
	RETURN 1


GO
GRANT EXECUTE ON  [dbo].[tm_upd_fuelpurchased] TO [public]
GO
