SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Expstatus_GetCompletedExpirationNew_fn]
(
  @asgnType     VARCHAR(6),
  @asgnId       VARCHAR(13),
  @compareDate  DATETIME,
  @minCode      INTEGER,
  @expLabel     VARCHAR(20)
)
RETURNS @ExpstatusGetCompletedExpirationNew TABLE 
    (ExpirationCode       INTEGER     NULL,
     ExpirationEndDate    DATETIME    NULL,
     ExpirationStartDate  DATETIME    NULL,
     ExpirationCompany    VARCHAR(8)  NULL,
     ExpirationCity       INTEGER     NULL,
     ExpirationStatus     VARCHAR(6)  NULL,
     ExpirationAbbr       VARCHAR(6)  NULL)
AS
BEGIN
  INSERT @ExpstatusGetCompletedExpirationNew
    SELECT TOP 1
            l.code,
            e.exp_compldate,
            e.exp_expirationdate,
            e.exp_routeto,
            CASE WHEN ISNULL(e.exp_routeto, 'UNKNOWN') = 'UNKNOWN' THEN e.exp_city ELSE c.cmp_city END,
            'AVL',
            e.exp_code
      FROM  expiration e
              INNER JOIN labelfile l ON l.abbr = e.exp_code AND l.labeldefinition = @expLabel
              INNER JOIN company c ON c.cmp_id = e.exp_routeto
     WHERE  e.exp_idtype = @asgnType
       AND  e.exp_id = @asgnId
       AND  e.exp_completed = 'Y'
       AND  e.exp_expirationdate <= @compareDate
       AND  l.code >= @minCode
       AND  (l.code >= 200 OR l.create_move = 'Y')
       AND  e.exp_compldate < '20491231'
       AND  (e.exp_routeto <> 'UNKNOWN'
        OR   e.exp_city > 0)
    ORDER BY exp_compldate DESC
  RETURN
END  
GO
GRANT SELECT ON  [dbo].[Expstatus_GetCompletedExpirationNew_fn] TO [public]
GO
