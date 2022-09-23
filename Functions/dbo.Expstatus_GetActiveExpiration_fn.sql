SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Expstatus_GetActiveExpiration_fn]
(
  @asgnType     VARCHAR(6),
  @asgnId       VARCHAR(13),
  @compareDate  DATETIME,
  @minCode      INTEGER,
  @expLabel     VARCHAR(20),
  @statusLabel  VARCHAR(20)
)
RETURNS @ExpstatusGetActiveExpiration TABLE 
    (ExpirationCode       INTEGER     NULL,
     ExpirationEndDate    DATETIME    NULL,
     ExpirationStartDate  DATETIME    NULL,
     ExpirationCompany    VARCHAR(8)  NULL,
     ExpirationCity       INTEGER     NULL,
     ExpirationStatus     VARCHAR(6)  NULL,
     ExpirationAbbr       VARCHAR(6)  NULL)
AS
BEGIN
  INSERT @ExpstatusGetActiveExpiration
    SELECT TOP 1 
            lc.code,
            e.exp_compldate,
            e.exp_expirationdate,
            e.exp_routeto,
            CASE WHEN e.exp_routeto = 'UNKOWN' THEN e.exp_city ELSE c.cmp_city END,
            ls.abbr,
            e.exp_code
	    FROM  expiration e
              INNER JOIN labelfile lc ON lc.abbr = e.exp_code AND lc.labeldefinition = @expLabel
              INNER JOIN company c ON c.cmp_id = e.exp_routeto
              LEFT OUTER JOIN labelfile ls ON ls.code = lc.code and ls.labeldefinition = @StatusLabel
     WHERE  e.exp_idtype = @asgnType
       AND  e.exp_id = @asgnId
       AND  e.exp_completed = 'N'
     ---by emolvera 12/30/19 10:01pm  -- AND  e.exp_expirationdate <= @compareDate
       AND  lc.code >= @minCode
	   AND  e.exp_expirationdate <= @compareDate
    ORDER BY CASE WHEN lc.code = 900 THEN 0 ELSE 1 END ASC, e.exp_compldate DESC
  RETURN
END  
GO
GRANT SELECT ON  [dbo].[Expstatus_GetActiveExpiration_fn] TO [public]
GO
