SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




 CREATE VIEW [dbo].[usersGroupsTMW]
 AS
	SELECT tgpas.grp_id, tgro.grp_name AS 'group_name', tgpas.usr_userid, tuse.usr_fname + ' ' + tuse.usr_lname AS 'nombre'
	FROM ttsgroupasgn tgpas
	INNER JOIN ttsgroups tgro
	ON tgpas.grp_id = tgro.grp_id
	INNER JOIN ttsusers tuse
	ON tgpas.usr_userid = tuse.usr_userid
GO
