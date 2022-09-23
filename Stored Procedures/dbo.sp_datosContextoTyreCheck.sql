SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 CREATE PROCEDURE [dbo].[sp_datosContextoTyreCheck]
	
AS
BEGIN
	select trc_number,trc_fleet,(select name from labelfile where labeldefinition = 'fleet' and trc_fleet = abbr) as flotanombre, taller,LocationName
from tractorprofile
inner join [dbo].[ContextoTyreCheck] on [Fleet] = trc_fleet
where trc_status <> 'out' and taller is not null
--union
--select trl_number,trl_fleet,(select name from labelfile where labeldefinition = 'fleet' and trl_fleet = abbr) as flotanombre ,taller,LocationName
--from trailerprofile
--inner join [dbo].[ContextoTyreCheck] on [Fleet] = trl_fleet
--where trl_status <> 'out'  and taller is not null

END


















GO
