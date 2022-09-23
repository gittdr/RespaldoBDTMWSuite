SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSTransitCarrierView]
AS
SELECT 
 car_id,
 car_name,
 car_status,
 car_terminationdt
FROM
 Carrier
GO
GRANT SELECT ON  [dbo].[TMSTransitCarrierView] TO [public]
GO
