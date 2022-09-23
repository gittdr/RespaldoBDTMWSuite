SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RowSecDescForUserID] AS

UPDATE RowSecColumnValues
SET  rscv_description = isnull(usr.usr_lname + ', ', '') + isnull(usr.usr_fname, '')
FROM RowSecColumnValues rscv
  INNER JOIN RowSecColumns rsc on rscv.rsc_id = rsc.rsc_id
  INNER JOIN ttsusers usr on rscv.rscv_value = usr.usr_userid
WHERE rsc.rsc_column_type = 'UserID'
  and rsc.rsc_selected = 1
  and rscv_description <> isnull(usr.usr_lname + ', ', '') + isnull(usr.usr_fname, '')
GO
GRANT EXECUTE ON  [dbo].[RowSecDescForUserID] TO [public]
GO
