SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc  [dbo].[sp_actualizacmplatlong]

as

begin


 UPDATE company

SET company.cmp_latseconds = 
(cast(abs(s.lat) AS FLOAT))*3600,
company.cmp_longseconds =
(cast(abs(s.long) AS FLOAT))*3600  
 from    qsp..SkyGuardian_geofences AS S
 inner join company c on S.name = c.cmp_id
 where S.name= c.cmp_id




 end
 


GO
