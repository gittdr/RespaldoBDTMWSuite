SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[core_CarrierExists] (@id varchar(8)) as
	
select
	count(car.car_id)
from carrier car
where car_id=@id

GO
GRANT EXECUTE ON  [dbo].[core_CarrierExists] TO [public]
GO
