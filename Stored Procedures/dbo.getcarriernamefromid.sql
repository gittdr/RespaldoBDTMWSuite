SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.getcarriernamefromid    Script Date: 6/1/99 11:54:03 AM ******/
Create procedure [dbo].[getcarriernamefromid](@carid varchar(8),@carname varchar(64) output) as
	SELECT @carname = car_name
	FROM 	carrier
	WHERE car_id = @carid

return

GO
GRANT EXECUTE ON  [dbo].[getcarriernamefromid] TO [public]
GO
