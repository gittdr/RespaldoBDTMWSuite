SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollPassengerView] AS
SELECT
dbo.Passenger.*, 
dbo.City.cty_nmstct, 
dbo.City.cty_region1, 
dbo.City.cty_region2, 
dbo.City.cty_region3, 
dbo.City.cty_region4, 
dbo.City.cty_latitude, 
dbo.City.cty_longitude 
FROM dbo.Passenger (NOLOCK) LEFT OUTER JOIN dbo.City (NOLOCK) ON dbo.Passenger.psgr_city = dbo.City.cty_code 

GO
GRANT DELETE ON  [dbo].[TMWScrollPassengerView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollPassengerView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollPassengerView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollPassengerView] TO [public]
GO
