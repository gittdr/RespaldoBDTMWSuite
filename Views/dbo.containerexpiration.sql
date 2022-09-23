SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[containerexpiration] AS 
	SELECT t.trl_id exp_id, e.exp_code exp_code, e.exp_expirationdate exp_expirationdate, e.exp_compldate exp_compldate, 
	        e.exp_completed exp_completed, e.exp_priority exp_priority
	  FROM expiration e (nolock) JOIN trailerprofile t (nolock) ON t.trl_id = e.exp_id
	 WHERE e.exp_idtype = 'TRL'
	   AND t.trl_equipmenttype = 'CONTAINER'
GO
GRANT SELECT ON  [dbo].[containerexpiration] TO [public]
GO
