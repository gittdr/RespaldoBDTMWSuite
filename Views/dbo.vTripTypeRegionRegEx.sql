SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vTripTypeRegionRegEx]
AS

  SELECT ttr_number
       , ttr_code
       , ttr_triptypeorregion
       , ttr_billto
       , (SELECT TOP 1 ttrd_include_or_exclude FROM dbo.ttrdetail WHERE ttr_number = h.ttr_number AND ttrd_level = 'CITY' AND ttrd_terminusnbr = 1) AS cityRegEx1IncludeExclude
       , STUFF((SELECT '|', '^'+ CAST(ttrd_intvalue AS VARCHAR(10)) + '$'
                  FROM dbo.ttrdetail
                 WHERE ttr_number = h.ttr_number
                   AND ttrd_level = 'CITY'
                   AND ttrd_terminusnbr = 1
                   AND ttrd_intvalue <> 0
                   AND ttrd_include_or_exclude <> 'N'
                FOR XML PATH ('')), 1, 1, ''
              ) AS cityRegEx1
       , (SELECT TOP 1 ttrd_include_or_exclude FROM dbo.ttrdetail WHERE ttr_number = h.ttr_number AND ttrd_level = 'CITY' AND ttrd_terminusnbr = 2) AS cityRegEx2IncludeExclude
       , STUFF((SELECT '|', '^'+ CAST(ttrd_intvalue AS VARCHAR(10)) + '$'
                  FROM dbo.ttrdetail
                 WHERE ttr_number = h.ttr_number
                   AND ttrd_level = 'CITY'
                   AND ttrd_terminusnbr = 2
                   AND ttrd_intvalue <> 0
                   AND ttrd_include_or_exclude <> 'N'
                FOR XML PATH ('')), 1, 1, ''
              ) AS cityRegEx2
       , (SELECT TOP 1 ttrd_include_or_exclude FROM dbo.ttrdetail WHERE ttr_number = h.ttr_number AND ttrd_level = 'STATE' AND ttrd_terminusnbr = 1) AS stateRegEx1IncludeExclude
       , STUFF((SELECT '|', '^'+ CAST(ttrd_value AS VARCHAR(10)) + '$'
                  FROM dbo.ttrdetail
                 WHERE ttr_number = h.ttr_number
                   AND ttrd_level = 'STATE'
                   AND ttrd_terminusnbr = 1
                   AND ISNULL(ttrd_value, '') <> ''
                   AND ttrd_include_or_exclude <> 'N'
                FOR XML PATH ('')), 1, 1, ''
              ) AS stateRegEx1
       , (SELECT TOP 1 ttrd_include_or_exclude FROM dbo.ttrdetail WHERE ttr_number = h.ttr_number AND ttrd_level = 'STATE' AND ttrd_terminusnbr = 2) AS stateRegEx2IncludeExclude
       , STUFF((SELECT '|', '^'+ CAST(ttrd_value AS VARCHAR(10)) + '$'
                  FROM dbo.ttrdetail
                 WHERE ttr_number = h.ttr_number
                   AND ttrd_level = 'STATE'
                   AND ttrd_terminusnbr = 2
                   AND ISNULL(ttrd_value, '') <> ''
                   AND ttrd_include_or_exclude <> 'N'
                FOR XML PATH ('')), 1, 1, ''
              ) AS stateRegEx2
       , (SELECT TOP 1 ttrd_include_or_exclude FROM dbo.ttrdetail WHERE ttr_number = h.ttr_number AND ttrd_level = 'ZIP' AND ttrd_terminusnbr = 1) AS zipRegEx1IncludeExclude
       , STUFF((SELECT '|', '^'+ CAST(ttrd_value AS VARCHAR(10))
                  FROM dbo.ttrdetail
                 WHERE ttr_number = h.ttr_number
                   AND ttrd_level = 'ZIP'
                   AND ttrd_terminusnbr = 1
                   AND ISNULL(ttrd_value, '') <> ''
                   AND ttrd_include_or_exclude <> 'N'
                FOR XML PATH ('')), 1, 1, ''
              ) AS zipRegEx1
       , (SELECT TOP 1 ttrd_include_or_exclude FROM dbo.ttrdetail WHERE ttr_number = h.ttr_number AND ttrd_level = 'ZIP' AND ttrd_terminusnbr = 2) AS zipRegEx2IncludeExclude
       , STUFF((SELECT '|', '^'+ CAST(ttrd_value AS VARCHAR(10))
                  FROM dbo.ttrdetail
                 WHERE ttr_number = h.ttr_number
                   AND ttrd_level = 'ZIP'
                   AND ttrd_terminusnbr = 2
                   AND ISNULL(ttrd_value, '') <> ''
                   AND ttrd_include_or_exclude <> 'N'
                FOR XML PATH ('')), 1, 1, ''
              ) AS zipRegEx2
       , (SELECT TOP 1 ttrd_include_or_exclude FROM dbo.ttrdetail WHERE ttr_number = h.ttr_number AND ttrd_level = 'CNTRY' AND ttrd_terminusnbr = 1) AS countryRegEx1IncludeExclude
       , STUFF((SELECT '|', '^'+ CAST(ttrd_value AS VARCHAR(10)) + '$'
                  FROM dbo.ttrdetail
                 WHERE ttr_number = h.ttr_number
                   AND ttrd_level = 'CNTRY'
                   AND ttrd_terminusnbr = 1
                   AND ISNULL(ttrd_value,'') <> ''
                   AND ttrd_include_or_exclude <> 'N'
                FOR XML PATH ('')), 1, 1, ''
              ) AS countryRegEx1
       , (SELECT TOP 1 ttrd_include_or_exclude FROM dbo.ttrdetail WHERE ttr_number = h.ttr_number AND ttrd_level = 'CNTRY' AND ttrd_terminusnbr = 2) AS countryRegEx2IncludeExclude
       , STUFF((SELECT '|', '^'+ CAST(ttrd_value AS VARCHAR(10)) + '$'
                  FROM dbo.ttrdetail
                 WHERE ttr_number = h.ttr_number
                   AND ttrd_level = 'CNTRY'
                   AND ttrd_terminusnbr = 2
                   AND ISNULL(ttrd_value,'') <> ''
                   AND ttrd_include_or_exclude <> 'N'
                FOR XML PATH ('')), 1, 1, ''
              ) AS countryRegEx2

    FROM dbo.ttrheader h

GO
GRANT SELECT ON  [dbo].[vTripTypeRegionRegEx] TO [public]
GO
