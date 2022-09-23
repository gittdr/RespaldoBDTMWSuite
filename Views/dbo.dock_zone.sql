SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[dock_zone]
AS
SELECT
  DISTINCT cmp_id cmp_id, 
  dock_zone dock_zone,
  staging_area staging_area
  FROM
  terminaldoor
UNION
SELECT
  DISTINCT cmp_id cmp_id, 
  dock_zone dock_zone,
  dock_zone staging_area
  FROM
  terminalzone where zone_type = 'Z'
GO
GRANT DELETE ON  [dbo].[dock_zone] TO [public]
GO
GRANT INSERT ON  [dbo].[dock_zone] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dock_zone] TO [public]
GO
GRANT SELECT ON  [dbo].[dock_zone] TO [public]
GO
GRANT UPDATE ON  [dbo].[dock_zone] TO [public]
GO
