SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[WebSystemsLinkTtsUsersMobileAccessView] AS
	SELECT 
			CASE WHEN s.MobileUserId IS NULL THEN 0 ELSE s.MobileUserId END AS 'MobileUserId',
			usr_userid, 
			ISNULL(usr_fname,'') + ' ' + ISNULL(usr_lname,'')AS 'Name',
			ISNULL(HasMobileAccess,0) AS Mobile,
			ISNULL(HasPay,0) AS Pay,
			MaxPerDay,
			MaxPerTrip,
			MaxPercentOfTrip,
			usr_type1,
			usr_type2
	FROM ttsusers t 
	LEFT JOIN WebSystemsLinkMobileUserCredentials s on t.usr_userid = s.TtsUserId
GO
GRANT SELECT ON  [dbo].[WebSystemsLinkTtsUsersMobileAccessView] TO [public]
GO
