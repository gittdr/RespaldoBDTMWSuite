SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[auto_complete_expirations_sp]
as

/* PTS 27430 - 03/03/2006- DJM - Modified to remove the restriction on what type of Expirations to auto-expire.
					was not tied to a GI setting so it was not user-definable.  No reason to not do
					EVERY type of expiration.
*/

UPDATE expiration
   SET exp_completed = 'Y',
       exp_updateby = 'AUTO',
       exp_updateon = GETDATE()
  FROM expiration
 WHERE expiration.exp_compldate <= GETDATE() AND
       ISNULL(expiration.exp_completed, 'N') = 'N' AND
       expiration.exp_code IN (SELECT abbr 
                                FROM labelfile
			       WHERE auto_complete = 'Y' AND
                                     SUBSTRING(labelfile.labeldefinition, 4, 6) = 'EXP' AND
                                     SUBSTRING(labelfile.labeldefinition, 1, 3) = expiration.exp_idtype)
                                      

GO
GRANT EXECUTE ON  [dbo].[auto_complete_expirations_sp] TO [public]
GO
