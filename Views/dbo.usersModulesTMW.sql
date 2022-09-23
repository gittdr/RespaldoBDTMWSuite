SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[usersModulesTMW]
 AS
SELECT tmap.userid, tuse.usr_fname + ' ' + tuse.usr_lname AS 'Nombre', tmap.moduleid, tmod.modulename
FROM ttsmappings tmap
INNER JOIN ttsusers tuse
ON tmap.userid = tuse.usr_userid
INNER JOIN ttsmodules tmod
ON tmap.moduleid = tmod.moduleid
GO
