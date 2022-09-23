SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_dddw_ttsusers_rowsecurity] (@ps_user varchar(20))
AS


  SELECT distinct ttsusers.usr_userid, fullname = ttsusers.usr_fname + ' '+ ttsusers.usr_lname
    FROM UserTypeAssignment 
    JOIN ttsusers on ttsusers.usr_userid = UserTypeAssignment.usr_userid
   WHERE uta_type1 in (
						SELECT uta_type1
						  FROM UserTypeAssignment
						 WHERE usr_userid = @ps_user
						   AND uta_flag = '1'
					   )
	 AND uta_flag = '1' 


GO
GRANT EXECUTE ON  [dbo].[d_dddw_ttsusers_rowsecurity] TO [public]
GO
